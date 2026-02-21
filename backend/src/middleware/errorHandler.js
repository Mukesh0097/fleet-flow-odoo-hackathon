// ==================== COMPREHENSIVE ERROR HANDLER ====================

export const errorHandler = (err, req, res, next) => {
    // Log error with context
    const errorLog = {
        timestamp: new Date().toISOString(),
        method: req.method,
        url: req.originalUrl,
        ip: req.ip,
        userId: req.userId,
        userAgent: req.headers['user-agent'],
        error: {
            name: err.name,
            message: err.message,
            statusCode: err.statusCode,
            isOperational: err.isOperational
        }
    };

    console.error('ERROR:', JSON.stringify(errorLog, null, 2));

    // Handle known errors
    if (err.isOperational && err.statusCode) {
        return res.status(err.statusCode).json({
            success: false,
            message: err.message,
            code: err.name,
            timestamp: new Date().toISOString()
        });
    }

    // Handle Joi validation errors
    if (err.details && Array.isArray(err.details)) {
        const errors = err.details.map(detail => ({
            field: detail.path.join('.'),
            message: detail.message
        }));
        
        return res.status(400).json({
            success: false,
            message: 'Validation error',
            code: 'VALIDATION_ERROR',
            errors,
            timestamp: new Date().toISOString()
        });
    }

    // Handle JWT errors
    if (err.name === 'JsonWebTokenError') {
        return res.status(401).json({
            success: false,
            message: 'Invalid token format or signature',
            code: 'INVALID_TOKEN',
            timestamp: new Date().toISOString()
        });
    }

    if (err.name === 'TokenExpiredError') {
        return res.status(401).json({
            success: false,
            message: 'Token has expired',
            code: 'TOKEN_EXPIRED',
            timestamp: new Date().toISOString()
        });
    }

    // Handle Prisma errors
    if (err.code === 'P2002') {
        return res.status(409).json({
            success: false,
            message: `Unique constraint failed on field: ${err.meta?.target?.join(', ')}`,
            code: 'DUPLICATE_ENTRY',
            timestamp: new Date().toISOString()
        });
    }

    if (err.code === 'P2025') {
        return res.status(404).json({
            success: false,
            message: 'Record not found',
            code: 'RECORD_NOT_FOUND',
            timestamp: new Date().toISOString()
        });
    }

    if (err.code === 'P2003') {
        return res.status(400).json({
            success: false,
            message: 'Foreign key constraint violation',
            code: 'FOREIGN_KEY_VIOLATION',
            timestamp: new Date().toISOString()
        });
    }

    // Handle database connection errors
    if (err.name === 'PrismaClientRustPanicError' || err.name === 'PrismaClientValidationError') {
        return res.status(503).json({
            success: false,
            message: 'Database service temporarily unavailable',
            code: 'DATABASE_ERROR',
            timestamp: new Date().toISOString()
        });
    }

    // Handle unexpected errors
    if (process.env.NODE_ENV === 'production') {
        return res.status(500).json({
            success: false,
            message: 'Internal server error',
            code: 'INTERNAL_ERROR',
            timestamp: new Date().toISOString()
        });
    }

    // Development: send full error
    res.status(500).json({
        success: false,
        message: 'Internal server error',
        code: 'INTERNAL_ERROR',
        error: {
            name: err.name,
            message: err.message,
            stack: err.stack
        },
        timestamp: new Date().toISOString()
    });
};
