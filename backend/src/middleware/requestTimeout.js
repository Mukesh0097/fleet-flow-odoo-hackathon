// ==================== REQUEST TIMEOUT MIDDLEWARE ====================

export const requestTimeout = (timeoutMs = 30000) => {
    return (req, res, next) => {
        req.setTimeout(timeoutMs, () => {
            res.status(408).json({
                success: false,
                message: 'Request timeout. The operation took too long.',
                code: 'REQUEST_TIMEOUT'
            });
        });
        
        next();
    };
};
