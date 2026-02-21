import express from 'express';
import * as vehicleController from '../controllers/vehicleController.js';
import { authenticateToken, authorizePermission } from '../middleware/authMiddleware.js';
import { createVehicleSchema, updateVehicleSchema, validateRequest } from '../validators/vehicleValidator.js';

const router = express.Router();

// Get all vehicles
router.get('/',
    authenticateToken,
    authorizePermission('VIEW_VEHICLES'),
    vehicleController.getAllVehicles
);

// Get vehicle by ID
router.get('/:id',
    authenticateToken,
    authorizePermission('VIEW_VEHICLES'),
    vehicleController.getVehicleById
);

// Create vehicle
router.post('/',
    authenticateToken,
    authorizePermission('CREATE_VEHICLE'),
    validateRequest(createVehicleSchema),
    vehicleController.createVehicle
);

// Update vehicle
router.patch('/:id',
    authenticateToken,
    authorizePermission('EDIT_VEHICLE'),
    validateRequest(updateVehicleSchema),
    vehicleController.updateVehicle
);

// Update odometer
router.patch('/:id/odometer',
    authenticateToken,
    authorizePermission('EDIT_VEHICLE'),
    vehicleController.updateOdometer
);

// Retire vehicle
router.patch('/:id/retire',
    authenticateToken,
    authorizePermission('RETIRE_VEHICLE'),
    vehicleController.retireVehicle
);

// Delete vehicle
router.delete('/:id',
    authenticateToken,
    authorizePermission('RETIRE_VEHICLE'),
    vehicleController.deleteVehicle
);

export default router;
