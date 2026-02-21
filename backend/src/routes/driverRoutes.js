import express from 'express';
import { authenticateToken, authorizePermission } from '../middleware/authMiddleware.js';
import { validateRequest, createDriverSchema, updateDriverSchema } from '../validators/driverValidator.js';
import { createDriver, deleteDriver, getAllDrivers, getDriverById, suspendDriver, updateDriver, updateDriverStatus, updateSafetyScore } from '../controllers/driverController.js';

const router = express.Router();

// Get all drivers
router.get('/',
    authenticateToken,
    authorizePermission('VIEW_DRIVERS'),
    getAllDrivers
);

// Get driver by ID
router.get('/:id',
    authenticateToken,
    authorizePermission('VIEW_DRIVERS'),
    getDriverById
);

// Create driver
router.post('/',
    authenticateToken,
    authorizePermission('CREATE_DRIVER'),
    validateRequest(createDriverSchema),
    createDriver
);

// Update driver
router.patch('/:id',
    authenticateToken,
    authorizePermission('EDIT_DRIVER'),
    validateRequest(updateDriverSchema),
    updateDriver
);

// Update driver status
router.patch('/:id/status',
    authenticateToken,
    authorizePermission('EDIT_DRIVER'),
    updateDriverStatus
);

// Suspend driver
router.patch('/:id/suspend',
    authenticateToken,
    authorizePermission('SUSPEND_DRIVER'),
    suspendDriver
);

// Update safety score
router.patch('/:id/safety-score',
    authenticateToken,
    authorizePermission('EDIT_DRIVER'),
    updateSafetyScore
);

// Delete driver
router.delete('/:id',
    authenticateToken,
    authorizePermission('EDIT_DRIVER'),
    deleteDriver
);

export default router;
