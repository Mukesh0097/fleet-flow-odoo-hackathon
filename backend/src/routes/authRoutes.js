import express from 'express';
import * as authController from '../controllers/authController.js';
import { authenticateToken, authorizeRole, } from '../middleware/authMiddleware.js';
import { validateRequest, registerSchema, loginSchema } from '../validators/authValidator.js';
import { errorHandler } from '../middleware/errorHandler.js';

const router = express.Router();

// Public routes
router.post('/register',authenticateToken,authorizeRole('FLEET_MANAGER'),validateRequest(registerSchema), authController.register);
router.post('/login', validateRequest(loginSchema), authController.login);

// Protected routes
router.get('/me', authenticateToken, authController.getCurrentUser);
router.get('/verify', authenticateToken, authController.verifyToken);

// Admin only routes
router.get('/users', authenticateToken, authorizeRole('FLEET_MANAGER'), authController.getAllUsers);
router.patch('/users/:userId/deactivate', authenticateToken, authorizeRole('FLEET_MANAGER'), authController.deactivateUser);

// Error handling
router.use(errorHandler);

export default router;