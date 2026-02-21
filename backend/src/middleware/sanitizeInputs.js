// ==================== REQUEST BODY SANITIZATION ====================

export const sanitizeInputs = (req, res, next) => {
    if (req.body && typeof req.body === 'object') {
        sanitizeObject(req.body);
    }
    
    next();
};

function sanitizeObject(obj) {
    for (const key in obj) {
        if (obj.hasOwnProperty(key)) {
            if (typeof obj[key] === 'string') {
                // Remove potential XSS
                obj[key] = obj[key]
                    .trim()
                    .replace(/<script[^>]*>.*?<\/script>/gi, '')
                    .replace(/on\w+\s*=/gi, '')
                    .substring(0, 10000); // Max length to prevent huge payloads
            } else if (typeof obj[key] === 'object' && obj[key] !== null) {
                sanitizeObject(obj[key]);
            }
        }
    }
}
