// ==================== RATE LIMITING MIDDLEWARE ====================

const requestCounts = {};
const RATE_LIMIT_WINDOW = 60000; // 1 minute
const RATE_LIMIT_MAX_REQUESTS = 100;

export const rateLimit = (req, res, next) => {
    const ip = req.ip || req.connection.remoteAddress;
    const now = Date.now();

    if (!requestCounts[ip]) {
        requestCounts[ip] = [];
    }

    // Clean old requests
    requestCounts[ip] = requestCounts[ip].filter(time => now - time < RATE_LIMIT_WINDOW);

    if (requestCounts[ip].length >= RATE_LIMIT_MAX_REQUESTS) {
        return res.status(429).json({
            success: false,
            message: 'Too many requests. Please try again later.',
            code: 'RATE_LIMIT_EXCEEDED',
            retryAfter: Math.ceil(RATE_LIMIT_WINDOW / 1000)
        });
    }

    requestCounts[ip].push(now);
    
    res.set('X-RateLimit-Limit', RATE_LIMIT_MAX_REQUESTS);
    res.set('X-RateLimit-Remaining', RATE_LIMIT_MAX_REQUESTS - requestCounts[ip].length);
    
    next();
};
