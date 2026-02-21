// ==================== REQUEST VALIDATION MIDDLEWARE ====================

export const validateContentType = (req, res, next) => {
    if (['POST', 'PUT', 'PATCH'].includes(req.method)) {
        const contentType = req.headers['content-type'];
        
        if (!contentType) {
            return res.status(400).json({
                success: false,
                message: 'Content-Type header is required'
            });
        }
        
        if (!contentType.includes('application/json')) {
            return res.status(415).json({
                success: false,
                message: 'Content-Type must be application/json'
            });
        }
    }
    
    next();
};

export const validateRequestSize = (req, res, next) => {
    const maxSize = 10 * 1024 * 1024; // 10MB
    
    if (req.headers['content-length'] && parseInt(req.headers['content-length']) > maxSize) {
        return res.status(413).json({
            success: false,
            message: 'Request payload too large'
        });
    }
    
    next();
};
