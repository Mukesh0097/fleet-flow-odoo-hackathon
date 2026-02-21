import jwt from 'jsonwebtoken';
import bcryptjs from 'bcryptjs';
import { AUTH_CONFIG } from '../config/auth.js';
import { prisma } from '../config/db.config.js';


// Generate JWT token
const generateToken = (user) => {
    return jwt.sign(
        { id: user.id, email: user.email, role: user.role },
        AUTH_CONFIG.SECRET_KEY,
        { expiresIn: AUTH_CONFIG.TOKEN_EXPIRY }
    );
};

// Register a new user
export const register = async (req, res) => {
    try {
        const { email, name, password, role } = req.validatedData;

        // Check if user already exists
        const existingUser = await prisma.user.findUnique({
            where: { email }
        });

        if (existingUser) {
            return res.status(409).json({
                success: false,
                message: 'User with this email already exists',
            });
        }

        // Hash password
        const passwordHash = await bcryptjs.hash(password, 10);

        // Create new user
        const user = await prisma.user.create({
            data: {
                email,
                name,
                passwordHash,
                role: role,
                createdById: req.user ? req.user.id : null
            }
        });

        // Generate token
        const token = generateToken(user);

        res.status(201).json({
            success: true,
            message: 'User registered successfully',
            data: {
                id: user.id,
                email: user.email,
                name: user.name,
                role: user.role,
            },
            token,
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error registering user',
            error: error.message,
        });
    }
};

// Login user
export const login = async (req, res) => {
    try {
        const { email, password } = req.validatedData;

        // Find user by email
        const user = await prisma.user.findUnique({
            where: { email }
        });

        if (!user) {
            return res.status(401).json({
                success: false,
                message: 'Invalid email or password',
            });
        }

        // Check if user is active
        if (!user.isActive) {
            return res.status(403).json({
                success: false,
                message: 'User account is inactive',
            });
        }

        // Verify password
        const isPasswordValid = await bcryptjs.compare(password, user.passwordHash);
        if (!isPasswordValid) {
            return res.status(401).json({
                success: false,
                message: 'Invalid email or password',
            });
        }

        // Generate token
        const token = generateToken(user);

        res.status(200).json({
            success: true,
            message: 'Login successful',
            data: {
                id: user.id,
                email: user.email,
                name: user.name,
                role: user.role,
            },
            token,
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error logging in',
            error: error.message,
        });
    }
};

// Get current user
export const getCurrentUser = async (req, res) => {
    try {
        const user = await prisma.user.findUnique({
            where: { id: req.user.id }
        });

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found',
            });
        }

        res.status(200).json({
            success: true,
            data: {
                id: user.id,
                email: user.email,
                name: user.name,
                role: user.role,
                isActive: user.isActive,
            },
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching user',
            error: error.message,
        });
    }
};

// Get all users (Admin only)
export const getAllUsers = async (req, res) => {
    try {
        // Query params: search (name or email), page, limit, role, isActive
        const { search, page = 1, limit = 20, role, isActive } = req.query;

        const pageNum = Math.max(parseInt(page, 10) || 1, 1);
        const take = Math.max(parseInt(limit, 10) || 20, 1);
        const skip = (pageNum - 1) * take;

        // Build where clause
        const where = {};

        if (role) where.role = role;
        if (typeof isActive !== 'undefined') {
            // Accept 'true'|'false' or boolean
            if (isActive === 'true' || isActive === 'false') {
                where.isActive = isActive === 'true';
            } else if (typeof isActive === 'boolean') {
                where.isActive = isActive;
            }
        }

        if (search) {
            where.OR = [
                { name: { contains: search, mode: 'insensitive' } },
                { email: { contains: search, mode: 'insensitive' } }
            ];
        }

        // Exclude the requesting admin user (do not return admin itself)
        if (req.user && req.user.id) {
            if (where.NOT) {
                if (Array.isArray(where.NOT)) {
                    where.NOT.push({ id: req.user.id });
                } else {
                    where.NOT = [where.NOT, { id: req.user.id }];
                }
            } else {
                where.NOT = { id: req.user.id };
            }
        }

        // Get total count for pagination
        const total = await prisma.user.count({ where });

        const users = await prisma.user.findMany({
            where,
            skip,
            take,
            orderBy: { createdAt: 'desc' },
            select: {
                id: true,
                email: true,
                name: true,
                role: true,
                isActive: true,
                createdAt: true
            }
        });

        const totalPages = Math.ceil(total / take) || 1;

        res.status(200).json({
            success: true,
            data: users,
            meta: {
                total,
                page: pageNum,
                limit: take,
                totalPages
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching users',
            error: error.message,
        });
    }
};

// Deactivate user (Admin only)
export const deactivateUser = async (req, res) => {
    try {
        const { userId } = req.params;

        const user = await prisma.user.findUnique({
            where: { id: userId }
        });

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found',
            });
        }

        await prisma.user.update({
            where: { id: userId },
            data: { isActive: false }
        });

        res.status(200).json({
            success: true,
            message: 'User deactivated successfully',
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error deactivating user',
            error: error.message,
        });
    }
};

// Verify token
export const verifyToken = (req, res) => {
    res.status(200).json({
        success: true,
        message: 'Token is valid',
        user: req.user,
    });
};