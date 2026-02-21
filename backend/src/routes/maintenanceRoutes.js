import express from 'express';
import * as maintenanceController from '../controllers/maintenanceController.js';
import { authenticateToken, authorizePermission } from '../middleware/authMiddleware.js';
import { validateRequest, createMaintenanceSchema, updateMaintenanceSchema } from '../validators/maintenanceValidator.js';

const router = express.Router();

// Get all maintenance logs
router.get('/',
    authenticateToken,
    authorizePermission('VIEW_MAINTENANCE'),
    maintenanceController.getAllMaintenanceLogs
);

// Get maintenance log by ID
router.get('/:id',
    authenticateToken,
    authorizePermission('VIEW_MAINTENANCE'),
    maintenanceController.getMaintenanceLogById
);

// Create maintenance log
router.post('/',
    authenticateToken,
    authorizePermission('CREATE_MAINTENANCE'),
    validateRequest(createMaintenanceSchema),
    maintenanceController.createMaintenanceLog
);

// Update maintenance log
router.patch('/:id',
    authenticateToken,
    authorizePermission('EDIT_MAINTENANCE'),
    validateRequest(updateMaintenanceSchema),
    maintenanceController.updateMaintenanceLog
);

// Complete maintenance service
router.patch('/:id/complete',
    authenticateToken,
    authorizePermission('EDIT_MAINTENANCE'),
    maintenanceController.completeMaintenanceLog
);

// Cancel maintenance service
router.patch('/:id/cancel',
    authenticateToken,
    authorizePermission('EDIT_MAINTENANCE'),
    maintenanceController.cancelMaintenanceLog
);

// Delete maintenance log
router.delete('/:id',
    authenticateToken,
    authorizePermission('EDIT_MAINTENANCE'),
    maintenanceController.deleteMaintenanceLog
);

export default router;
