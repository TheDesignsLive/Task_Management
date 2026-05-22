// utils/logger.js

const debugLog = (message, data = null) => {
    // This checks the variable you just set in your package.json
    if (process.env.DEBUG_MODE === 'true') {
        const timestamp = new Date().toLocaleTimeString();
        
        if (data) {
            console.log(`[DEBUG | ${timestamp}] ${message}`, data);
        } else {
            console.log(`[DEBUG | ${timestamp}] ${message}`);
        }
    }
};

module.exports = { debugLog };