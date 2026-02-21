import express from 'express';
import * as tripController from '../controllers/tripController.js';
import { authenticateToken, authorizePermission } from '../middleware/authMiddleware.js';
import { validateRequest, createTripSchema } from '../validators/tripValidator.js';

const router = express.Router();

// Get all trips
router.get('/',
    authenticateToken,
    authorizePermission('VIEW_TRIPS'),
    tripController.getAllTrips
);

// Get trip by ID
router.get('/:id',
    authenticateToken,
    authorizePermission('VIEW_TRIPS'),
    tripController.getTripById
);

// Create trip
router.post('/',
    authenticateToken,
    authorizePermission('CREATE_TRIP'),
    validateRequest(createTripSchema),
    tripController.createTrip
);

// Dispatch trip
router.patch('/:id/dispatch',
    authenticateToken,
    authorizePermission('CREATE_TRIP'),
    tripController.dispatchTrip
);

// Complete trip
router.patch('/:id/complete',
    authenticateToken,
    authorizePermission('COMPLETE_TRIP'),
    tripController.completeTrip
);

// Cancel trip
router.patch('/:id/cancel',
    authenticateToken,
    authorizePermission('CANCEL_TRIP'),
    tripController.cancelTrip
);

// Delete trip
router.delete('/:id',
    authenticateToken,
    authorizePermission('CANCEL_TRIP'),
    tripController.deleteTrip
);

export default router;
