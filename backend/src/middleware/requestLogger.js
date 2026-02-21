// ==================== REQUEST LOGGING MIDDLEWARE ====================

export const requestLogger = (req, res, next) => {
    const start = Date.now();
    
    res.on('finish', () => {
        const duration = Date.now() - start;
        const logLevel = res.statusCode >= 400 ? 'ERROR' : 'INFO';
        console.log(
            `[${new Date().toISOString()}] ${logLevel} - ${req.method} ${req.originalUrl} - ${res.statusCode} - ${duration}ms`
        );
    });
    
    next();
};
