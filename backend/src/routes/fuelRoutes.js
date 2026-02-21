import express from 'express';
import * as fuelController from '../controllers/fuelController.js';
import { authenticateToken, authorizePermission } from '../middleware/authMiddleware.js';
import { validateRequest, createFuelLogSchema, updateFuelLogSchema } from '../validators/fuelValidator.js';

const router = express.Router();

// Get vehicle fuel efficiency (must be before /:id route)
router.get('/vehicle/:vehicleId/efficiency',
    authenticateToken,
    authorizePermission('VIEW_FUEL_LOGS'),
    fuelController.getVehicleFuelEfficiency
);

// Get all fuel logs
router.get('/',
    authenticateToken,
    authorizePermission('VIEW_FUEL_LOGS'),
    fuelController.getAllFuelLogs
);

// Get fuel log by ID
router.get('/:id',
    authenticateToken,
    authorizePermission('VIEW_FUEL_LOGS'),
    fuelController.getFuelLogById
);

// Create fuel log
router.post('/',
    authenticateToken,
    authorizePermission('CREATE_FUEL_LOG'),
    validateRequest(createFuelLogSchema),
    fuelController.createFuelLog
);

// Update fuel log
router.patch('/:id',
    authenticateToken,
    authorizePermission('EDIT_FUEL_LOG'),
    validateRequest(updateFuelLogSchema),
    fuelController.updateFuelLog
);

// Delete fuel log
router.delete('/:id',
    authenticateToken,
    authorizePermission('EDIT_FUEL_LOG'),
    fuelController.deleteFuelLog
);

export default router;
