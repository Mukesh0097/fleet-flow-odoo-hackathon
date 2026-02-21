import jwt from 'jsonwebtoken';
import { AUTH_CONFIG, ROLE_PERMISSIONS } from '../config/auth.js';
import { AuthenticationError, AuthorizationError } from '../errors/AppError.js';
import { prisma } from '../config/db.config.js';

// ==================== AUTHENTICATION MIDDLEWARE ====================

export const authenticateToken = async (req, res, next) => {
    try {
        const authHeader = req.headers['authorization'];
        const token = authHeader && authHeader.split(' ')[1];

        if (!token) {
            throw new AuthenticationError('Access token is missing. Please provide Authorization header with Bearer token.');
        }

        jwt.verify(token, AUTH_CONFIG.SECRET_KEY, async (err, user) => {
            if (err) {
                if (err.name === 'TokenExpiredError') {
                    return res.status(401).json({
                        success: false,
                        message: 'Token has expired. Please login again.',
                        code: 'TOKEN_EXPIRED'
                    });
                }
                
                if (err.name === 'JsonWebTokenError') {
                    return res.status(401).json({
                        success: false,
                        message: 'Invalid token format or signature.',
                        code: 'INVALID_TOKEN'
                    });
                }
                
                return res.status(401).json({
                    success: false,
                    message: 'Token verification failed.',
                    code: 'TOKEN_VERIFICATION_FAILED'
                });
            }

            // Verify user still exists and is active
            try {
                const dbUser = await prisma.user.findUnique({
                    where: { id: user.id }
                });

                if (!dbUser) {
                    return res.status(401).json({
                        success: false,
                        message: 'User no longer exists in the system.',
                        code: 'USER_NOT_FOUND'
                    });
                }

                if (!dbUser.isActive) {
                    return res.status(403).json({
                        success: false,
                        message: 'User account has been deactivated.',
                        code: 'USER_INACTIVE'
                    });
                }

                req.user = user;
                req.userId = user.id;
                next();
            } catch (error) {
                return res.status(500).json({
                    success: false,
                    message: 'Error verifying user status. Please try again.',
                    code: 'USER_VERIFICATION_ERROR'
                });
            }
        });
    } catch (error) {
        next(error);
    }
};

// ==================== AUTHORIZATION MIDDLEWARE ====================

export const authorizeRole = (...roles) => {
    return (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({
                success: false,
                message: 'User not authenticated',
                code: 'NOT_AUTHENTICATED'
            });
        }

        if (!roles.includes(req.user.role)) {
            return res.status(403).json({
                success: false,
                message: `Access denied. Required roles: ${roles.join(', ')}. Your role: ${req.user.role}`,
                code: 'INSUFFICIENT_ROLE'
            });
        }

        next();
    };
};

export const authorizePermission = (permission) => {
    return (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({
                success: false,
                message: 'User not authenticated',
                code: 'NOT_AUTHENTICATED'
            });
        }

        const userPermissions = ROLE_PERMISSIONS[req.user.role] || [];
        
        if (!userPermissions.includes(permission)) {
            return res.status(403).json({
                success: false,
                message: `Permission denied. Required permission: ${permission}`,
                code: 'INSUFFICIENT_PERMISSION',
                userRole: req.user.role,
                requiredPermission: permission
            });
        }

        next();
    };
};


