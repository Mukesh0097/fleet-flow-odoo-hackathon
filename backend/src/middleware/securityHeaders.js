// ==================== SECURITY HEADERS MIDDLEWARE ====================

export const securityHeaders = (req, res, next) => {
    // Prevent clickjacking
    res.header('X-Frame-Options', 'DENY');
    
    // Prevent MIME type sniffing
    res.header('X-Content-Type-Options', 'nosniff');
    
    // Enable XSS protection
    res.header('X-XSS-Protection', '1; mode=block');
    
    // Strict Transport Security
    if (process.env.NODE_ENV === 'production') {
        res.header('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
    }
    
    // Remove powered by header
    res.removeHeader('X-Powered-By');
    
    next();
};
