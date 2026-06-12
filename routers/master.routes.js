// routers/master.routes.js desktop version file
const express = require('express');
const router = express.Router();
const con = require('../config/db');
const db = require('../config/db');
const { notifyMobile } = require('../utils/notifyMobile');
const { sendPushToUsers } = require('../utils/pushNotify');
const PushNotifications = require('@pusher/push-notifications-server');

const beamsClient = new PushNotifications({
    instanceId: '423440a8-1fc5-4373-8e6b-0085dccafc58',
    secretKey: '75EBE2088425312400AD5D15B2476EA23E3CEA61B7DE841FCA0A62E822C3135F',
});

// ── Fire-and-forget push helper — never slows down the response ──
// ✅ Deduplicates IDs here before sending — guarantees 1 notification per user
function pushSilent(ids, title, body) {
  if (!ids || ids.length === 0) return;
  const uniqueIds = [...new Set(ids.map(id => String(id)))];
  sendPushToUsers(uniqueIds, title, body, '/home')
    .catch(err => console.error('[Push] silent error:', err.message));
}

// ==============================
// ADD TASK
// ==============================
router.post('/add-task', async (req, res) => {
  try {
    if (!req.session.role) return res.json({ success: false, message: 'Unauthorized' });

    const { title, description, date, priority, assignedTo, notifyUser } = req.body;

    if (!req.session.adminId && !req.session.userId) {
      return res.status(401).json({ success: false, message: 'Unauthorized' });
    }

    const assigned_by  = req.session.role === 'admin' ? req.session.adminId : req.session.userId;
    const who_assigned = req.session.role;
    const assignerName = req.session.adminName || req.session.userName || 'Someone';
  const pushTitle    = title || 'New Task';
const pushBody     = assignerName;

// sender id (mobile jaisa)
const senderUniqueId = req.session.role === 'admin'
  ? `admin-${req.session.adminId}`
  : `${req.session.userId}`;

    let admin_id;
    if (req.session.role === 'admin') {
      admin_id = req.session.adminId;
    } else {
      const [rows] = await con.execute("SELECT admin_id FROM users WHERE id=?", [req.session.userId]);
      if (rows.length === 0) return res.status(400).json({ success: false, message: 'User not found' });
      admin_id = rows[0].admin_id;
    }

    // ── Resolve self-assignment to 0 ──
    let finalAssignedTo = assignedTo;
    if (req.session.role === 'admin') {
      if (parseInt(assignedTo) === req.session.adminId) finalAssignedTo = 0;
    } else if (req.session.role === 'user' || req.session.role === 'owner') {
      if (assignedTo === 'admin' || parseInt(assignedTo) === admin_id) finalAssignedTo = 0;
    }

    const finalDate = date || new Date().toISOString().slice(0, 10) + " 00:00:00";

    let sectionValue = 'TASK';
    if (req.session.role === 'admin' && parseInt(finalAssignedTo) !== 0) sectionValue = 'OTHERS';
    if (req.session.role !== 'admin' && parseInt(finalAssignedTo) !== parseInt(req.session.userId)) sectionValue = 'OTHERS';

    // ── Beams ID helpers ──
    const toBeamsId   = (userId) => String(userId);
    const adminBeamsId = () => `admin_${admin_id}`;

    
// ═══════════════════════════════════════════════
    // CASE 1 — TEAM ASSIGNMENT  (assignedTo = "team_X")
    // ═══════════════════════════════════════════════
    if (typeof assignedTo === "string" && assignedTo.startsWith("team_")) {
      const teamId = assignedTo.split("_")[1];

      // ✅ Verify team belongs to this company
      const [teamCheck] = await con.execute(
        'SELECT id FROM teams WHERE id=? AND admin_id=?',
        [teamId, admin_id]
      );
      if (!teamCheck.length) {
        return res.status(403).json({ success: false, message: 'Invalid team: does not belong to your company.' });
      }

      const [users] = await con.execute(`
        SELECT u.id 
        FROM users u
        JOIN roles r ON u.role_id = r.id
        WHERE r.team_id = ? AND u.admin_id = ?
      `, [teamId, admin_id]);

const notifyIds = [];

      // ✅ FAST: all inserts run at same time, not one by one
      await Promise.all(users.map(user => {
        const isSelf = (req.session.role !== 'admin') && (user.id === req.session.userId);
        // ✅ Only add each userId ONCE — prevents duplicate notifications
        const beamsId = toBeamsId(user.id);
        if (!isSelf && !notifyIds.includes(beamsId)) notifyIds.push(beamsId);
        return con.execute(
          `INSERT INTO tasks
           (admin_id, title, description, priority, due_date, assigned_to, assigned_by, who_assigned, section, status)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'OTHERS', 'OPEN')`,
          [admin_id, title || 'No Title', description || null,
           (priority || 'LOW').toUpperCase(), finalDate, user.id, assigned_by, who_assigned]
        );
      }));

      // ✅ Fire-and-forget — 1 notification per user, not per device
      if (notifyUser) {
  const interests = [`company-${admin_id}-team-${teamId}`];

await beamsClient.publishToInterests(interests, {
  web: {
    notification: {
      title: pushTitle,
      body: pushBody,
      deep_link: "https://m-tms.thedesigns.live",
    }
  },
  fcm: {
    notification: {
      title: pushTitle,
      body: pushBody,
    },
    data: {
      url: "https://m-tms.thedesigns.live",
      sender_id: senderUniqueId,
    }
  }
});
}

      req.io.emit('update_tasks');
      notifyMobile();
      return res.json({ success: true });
    }

// ═══════════════════════════════════════════════
    // CASE 2 — ALL MEMBERS  (assignedTo = "all")
    // ═══════════════════════════════════════════════
    if (assignedTo === "all") {
      const [users] = await con.execute("SELECT id FROM users WHERE admin_id=?", [admin_id]);
      const notifyIds = [];

      // ✅ FAST: all inserts run at same time
const insertPromises = users
        .filter(user => {
          // Always exclude the person who is assigning — they should NOT receive their own "all" task
          if (req.session.role === 'admin') {
            return true; // admin assigns to all users, no user matches admin's ID
          }
          return user.id !== req.session.userId; // user excludes themselves
        })
        .map(user => {
          // ✅ Only add each userId ONCE — prevents duplicate notifications
          const beamsId = toBeamsId(user.id);
          if (!notifyIds.includes(beamsId)) notifyIds.push(beamsId);
          // ✅ Creator's own task goes to TASK section, everyone else gets OTHERS
          const isSelfUser = (req.session.role !== 'admin') && (user.id === req.session.userId);
          const sectionForUser = isSelfUser ? 'TASK' : 'OTHERS';
          return con.execute(
            `INSERT INTO tasks
             (admin_id, title, description, priority, due_date, assigned_to, assigned_by, who_assigned, section, status)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'OPEN')`,
            [admin_id, title || 'No Title', description || null,
             (priority || 'LOW').toUpperCase(), finalDate, user.id, assigned_by, who_assigned, sectionForUser]
          );
        });

// Also insert for admin (assigned_to = 0) — only if admin is NOT the one assigning
      if (req.session.role !== 'admin') {
        const adminSectionForAll = 'OTHERS';
        insertPromises.push(
          con.execute(
            `INSERT INTO tasks
             (admin_id, title, description, priority, due_date, assigned_to, assigned_by, who_assigned, section, status)
             VALUES (?, ?, ?, ?, ?, 0, ?, ?, ?, 'OPEN')`,
            [admin_id, title || 'No Title', description || null,
             (priority || 'LOW').toUpperCase(), finalDate, assigned_by, who_assigned, adminSectionForAll]
          )
        );
        notifyIds.push(adminBeamsId());
      }

      await Promise.all(insertPromises);

      // ✅ Fire-and-forget — does NOT slow down response
      if (notifyUser) {
  const interests = [
  `company-${admin_id}-all`,
  `admin-${admin_id}`
];

await beamsClient.publishToInterests(interests, {
  web: {
    notification: {
      title: pushTitle,
      body: pushBody,
      deep_link: "https://m-tms.thedesigns.live",
    }
  },
  fcm: {
    notification: {
      title: pushTitle,
      body: pushBody,
    },
    data: {
      url: "https://m-tms.thedesigns.live",
      sender_id: senderUniqueId,
    }
  }
});
}

      req.io.emit('update_tasks');
      notifyMobile();
      return res.json({ success: true, message: 'Task added successfully' });
    }

    // ═══════════════════════════════════════════════
    // CASE 3 — NORMAL SINGLE INSERT
    // ═══════════════════════════════════════════════

    // ✅ Verify assigned user belongs to this company (finalAssignedTo=0 means admin, skip check)
    if (parseInt(finalAssignedTo) !== 0) {
      const [userCheck] = await con.execute(
        'SELECT id FROM users WHERE id=? AND admin_id=?',
        [finalAssignedTo, admin_id]
      );
      if (!userCheck.length) {
        return res.status(403).json({ success: false, message: 'Invalid user: does not belong to your company.' });
      }
    }

    await con.execute(
      `INSERT INTO tasks
       (admin_id, title, description, priority, due_date, assigned_to, assigned_by, who_assigned, section, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'OPEN')`,
      [admin_id, title || 'No Title', description || null,
       (priority || 'LOW').toUpperCase(), finalDate, finalAssignedTo, assigned_by, who_assigned, sectionValue]
    );

    // ── Notify only if notifyUser=true AND it's not a self-task ──
    if (notifyUser) {
      const selfId     = req.session.role === 'admin' ? req.session.adminId : req.session.userId;
      const isSelfTask = parseInt(finalAssignedTo) === 0
        ? (req.session.role === 'admin')  // 0 = admin's own task
        : parseInt(finalAssignedTo) === parseInt(selfId);

      if (!isSelfTask) {
        const notifyId = parseInt(finalAssignedTo) === 0
          ? adminBeamsId()
          : toBeamsId(finalAssignedTo);

        let interests = [];

if (parseInt(finalAssignedTo) === 0) {
 interests = [`admin-user-${admin_id}`];
} else {
  interests = [`user-${finalAssignedTo}`];
}

await beamsClient.publishToInterests(interests, {
  web: {
    notification: {
      title: pushTitle,
      body: pushBody,
      deep_link: "https://m-tms.thedesigns.live",
    }
  },
  fcm: {
    notification: {
      title: pushTitle,
      body: pushBody,
    },
    data: {
      url: "https://m-tms.thedesigns.live",
      sender_id: senderUniqueId,
    }
  }
});
      }
    }

    req.io.emit('update_tasks');
    notifyMobile();
    res.json({ success: true, message: 'Task added successfully' });

  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: 'Error adding task' });
  }
});

// ==============================
// UPDATE TASK STATUS
// ==============================
router.post('/update-task-status', async (req, res) => {
  if (!req.session.role) return res.redirect('/');

  try {
    let { id, status, section } = req.body;
    if (!status || status === null) status = 'OPEN';
    if (!section || section === null) section = 'TASK';

    const completedAt = status === 'COMPLETED' ? new Date() : null;
    await db.execute(
      `UPDATE tasks SET status = ?, section = ?, completed_at = ? WHERE id = ?`,
      [status, section, completedAt, id]
    );

    // ── Repeat logic: spawn next task when completing a repeating task ──
    if (status === 'COMPLETED') {
      const [rows] = await con.query('SELECT * FROM tasks WHERE id=?', [id]);
      if (rows.length > 0) {
  const task = rows[0];
  const repeatType = task.repeat_type;

  console.log('[Repeat Debug] task id:', id, '| repeat_type:', repeatType, '| due_date:', task.due_date);

if (repeatType && repeatType !== 'none') {
          let baseDate = task.due_date ? new Date(task.due_date) : new Date();

          let nextDate = new Date(baseDate);
          if (repeatType === 'daily') {
            nextDate.setDate(nextDate.getDate() + 1);
          } else if (repeatType === 'weekly') {
            nextDate.setDate(nextDate.getDate() + 7);
          } else if (repeatType === 'monthly') {
            nextDate.setMonth(nextDate.getMonth() + 1);
          }

          const nextDateStr = nextDate.toISOString().split('T')[0];

          await con.query(
  `INSERT INTO tasks 
   (admin_id, title, description, priority, due_date, status, section,
    assigned_by, assigned_to, who_assigned, repeat_type)
   VALUES (?, ?, ?, ?, ?, 'OPEN', 'TASK', ?, ?, ?, ?)`,
  [
    task.admin_id,
    task.title,
    task.description,
    task.priority,
    nextDateStr,
    task.assigned_by,
    task.assigned_to,
    task.who_assigned,
    repeatType,
  ]
);

          await con.query(
            'UPDATE task_templates SET last_spawned=? WHERE id=?',
            [nextDateStr, id]
          ).catch(() => {});
        }
      }
    }
    // ── End repeat logic ──

    req.io.emit('update_tasks');
    notifyMobile();
    res.json({ success: true, status, section });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: 'Database error' });
  }
});

// ==============================
// UPDATE TASK DATE
// ==============================
router.post('/update-task-date', async (req, res) => {
  const { id, due_date } = req.body;

  if (!id || !due_date) return res.json({ success: false });

  try {
    await con.execute("UPDATE tasks SET due_date = ? WHERE id = ?", [due_date, id]);
    req.io.emit('update_tasks');
    notifyMobile();
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});

// ==============================
// GET SINGLE TASK (FOR EDIT)
// ==============================
router.get('/get-task/:id', (req, res) => {
  const { id } = req.params;

  con.query(
    `SELECT id, title, description, priority, DATE_FORMAT(due_date, '%Y-%m-%d') AS due_date 
     FROM tasks WHERE id = ?`,
    [id],
    (err, result) => {
      if (err) return res.status(500).json({ success: false });
      if (result.length === 0) return res.json({ success: false });
      res.json({ success: true, task: result[0] });
    }
  );
});

// ==============================
// EDIT TASK DETAILS
// ==============================
router.post('/edit-task-details', async (req, res) => {
  if (!req.session.role) return res.status(401).json({ success: false, error: "Unauthorized" });

  try {
    const { id, title, description, priority, due_date, assigned_to } = req.body;

    let finalAssignedTo = assigned_to;
    if (req.session.role === 'admin') {
      if (parseInt(assigned_to) === req.session.adminId) finalAssignedTo = 0;
    } else if (req.session.role === 'user' || req.session.role === 'owner') {
      if (assigned_to === 'admin' || parseInt(assigned_to) === req.session.adminId) finalAssignedTo = 0;
    }

    let newSection = 'TASK';
    if (req.session.role === 'admin' && parseInt(finalAssignedTo) !== 0) newSection = 'OTHERS';
    if (req.session.role !== 'admin' && parseInt(finalAssignedTo) !== parseInt(req.session.userId)) newSection = 'OTHERS';

    const finalDesc = (description === "" || description === null) ? null : description;

await db.execute(
      `UPDATE tasks 
       SET title = ?, description = ?, priority = ?, due_date = ?, assigned_to = ?
       WHERE id = ?`,
      [title, finalDesc, priority.toUpperCase(), due_date, finalAssignedTo, id]
    );

    req.io.emit('update_tasks');
    notifyMobile();
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: 'Database error' });
  }
});

// ==============================
// UPDATE FULL TASK DETAILS
// ==============================
router.post('/update-task-details', async (req, res) => {
  const { id, title, description, priority, due_date, assigned_to } = req.body;

  let finalAssignedTo = assigned_to;
  if (req.session.role === 'admin') {
    if (parseInt(assigned_to) === req.session.adminId) finalAssignedTo = 0;
  } else if (req.session.role === 'user' || req.session.role === 'owner') {
    if (assigned_to === 'admin' || parseInt(assigned_to) === req.session.adminId) finalAssignedTo = 0;
  }

  let newSection = 'TASK';
  if (req.session.role === 'admin' && parseInt(finalAssignedTo) !== 0) newSection = 'OTHERS';
  if (req.session.role !== 'admin' && parseInt(finalAssignedTo) !== parseInt(req.session.userId)) newSection = 'OTHERS';

  try {
    await con.execute(
      "UPDATE tasks SET title=?, description=?, priority=?, due_date=?, assigned_to=?, section=IF(status='COMPLETED', section, ?) WHERE id=?",
      [title, description, priority, due_date || null, finalAssignedTo, newSection, id]
    );
    req.io.emit('update_tasks');
    notifyMobile();
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});

// ==============================
// UPDATE TASK SECTION (DRAG)
// ==============================
router.post('/update-task-section', async (req, res) => {
  const { id, section } = req.body;

  try {
    await con.execute("UPDATE tasks SET section=? WHERE id=?", [section, id]);
    req.io.emit('update_tasks');
    notifyMobile();
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});

// ==============================
// DELETE SINGLE TASK
// ==============================
router.post('/delete-task/:id', async (req, res) => {
  try {
    await con.execute("DELETE FROM tasks WHERE id = ?", [req.params.id]);
    req.io.emit('update_tasks');
    notifyMobile();
    res.status(200).json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false });
  }
});

// ==============================
// DELETE COMPLETED TASKS
// ==============================
router.post('/delete-completed-tasks', async (req, res) => {
  try {
    const role    = req.session.role;
    const adminId = req.session.adminId;
    const userId  = req.session.userId;

    if (!role) return res.status(401).json({ success: false, message: 'Unauthorized' });

    let query  = '';
    let params = [];

    if (role === 'admin') {
      query  = "DELETE FROM tasks WHERE admin_id = ? AND assigned_to = 0 AND status = 'COMPLETED'";
      params = [adminId];
    } else if (role === 'user' || role === 'owner') {
      query  = "DELETE FROM tasks WHERE admin_id = ? AND assigned_to = ? AND status = 'COMPLETED'";
      params = [adminId, userId];
    } else {
      return res.status(403).json({ success: false, message: 'Forbidden: Invalid role' });
    }

    const [result] = await db.query(query, params);

    if (result.affectedRows > 0) {
      req.io.emit('update_tasks');
      notifyMobile();
    }

    return res.json({
      success: result.affectedRows > 0,
      message: result.affectedRows > 0
        ? 'Completed tasks deleted successfully'
        : 'No completed tasks found to delete'
    });

  } catch (err) {
    console.error('Error deleting completed tasks:', err);
    return res.status(500).json({ success: false, message: 'Server error', error: err.message });
  }
});

// ==============================
// GET TEAM MEMBERS
// ==============================
router.get('/get-team-members/:teamId', async (req, res) => {
  try {
    const { teamId }      = req.params;
    const currentUserId   = req.session.userId || null;

    let query  = `
      SELECT u.id, u.name 
      FROM users u
      JOIN roles r ON u.role_id = r.id
      WHERE r.team_id = ?
    `;
    let params = [teamId];

    if (currentUserId) {
      query += " AND u.id != ?";
      params.push(currentUserId);
    }

    const [rows] = await con.execute(query, params);
    res.json({ success: true, members: rows });

  } catch (err) {
    console.error(err);
    res.json({ success: false });
  }
});

// ==============================
// GET OTHER EMPLOYEES (team_id NULL)
// ==============================
router.get('/get-other-employees', async (req, res) => {
  try {
    const adminId = req.session.adminId;

    const [rows] = await con.execute(`
      SELECT u.id, u.name
      FROM users u
      JOIN roles r ON u.role_id = r.id
      WHERE u.admin_id = ?
      AND r.team_id IS NULL
    `, [adminId]);

    res.json({ success: true, members: rows });

  } catch (err) {
    console.error(err);
    res.json({ success: false });
  }
});

module.exports = router;