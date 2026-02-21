import { prisma } from '../config/db.config.js';

/**
 * GET /api/trips - Get all trips with pagination and filters
 */
export const getAllTrips = async (req, res) => {
    try {
        const { page = 1, limit = 10, status, region } = req.query;
        const skip = (page - 1) * limit;
        const where = {};

        if (status) where.status = status;
        if (region) where.region = region;

        const trips = await prisma.trip.findMany({
            where,
            skip: parseInt(skip),
            take: parseInt(limit),
            include: {
                vehicle: true,
                driver: true,
                statusLogs: true,
                fuelLogs: true,
                expenses: true
            }
        });

        const total = await prisma.trip.count({ where });

        res.status(200).json({
            success: true,
            data: trips,
            pagination: {
                total,
                page: parseInt(page),
                limit: parseInt(limit),
                pages: Math.ceil(total / limit)
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching trips',
            error: error.message
        });
    }
};

/**
 * GET /api/trips/:id - Get trip by ID
 */
export const getTripById = async (req, res) => {
    try {
        const { id } = req.params;

        const trip = await prisma.trip.findUnique({
            where: { id },
            include: {
                vehicle: true,
                driver: true,
                statusLogs: { orderBy: { changedAt: 'desc' } },
                fuelLogs: true,
                expenses: true
            }
        });

        if (!trip) {
            return res.status(404).json({
                success: false,
                message: 'Trip not found'
            });
        }

        res.status(200).json({
            success: true,
            data: trip
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching trip',
            error: error.message
        });
    }
};

/**
 * POST /api/trips - Create new trip
 */
export const createTrip = async (req, res) => {
    try {
        const { vehicleId, driverId, originAddress, destAddress, cargoDescription, cargoWeightKg, region, scheduledAt } = req.validatedData;

        // Validate vehicle exists and is available
        const vehicle = await prisma.vehicle.findUnique({ where: { id: vehicleId } });
        if (!vehicle) {
            return res.status(404).json({
                success: false,
                message: 'Vehicle not found'
            });
        }

        if (vehicle.status !== 'AVAILABLE') {
            return res.status(400).json({
                success: false,
                message: `Vehicle is not available. Current status: ${vehicle.status}`
            });
        }

        // Validate cargo weight
        if (cargoWeightKg > vehicle.maxCapacityKg) {
            return res.status(400).json({
                success: false,
                message: `Cargo weight (${cargoWeightKg}kg) exceeds vehicle capacity (${vehicle.maxCapacityKg}kg)`
            });
        }

        // Validate driver exists and is available
        const driver = await prisma.driver.findUnique({ where: { id: driverId } });
        if (!driver) {
            return res.status(404).json({
                success: false,
                message: 'Driver not found'
            });
        }

        if (driver.status === 'SUSPENDED') {
            return res.status(400).json({
                success: false,
                message: 'Driver is suspended and cannot be assigned trips'
            });
        }

        // Check license expiry
        if (new Date(driver.licenseExpiryDate) < new Date()) {
            return res.status(400).json({
                success: false,
                message: 'Driver license has expired'
            });
        }

        const trip = await prisma.trip.create({
            data: {
                tripCode: `TRP-${Date.now()}`,
                vehicleId,
                driverId,
                originAddress,
                destAddress,
                cargoDescription: cargoDescription || null,
                cargoWeightKg,
                region: region || null,
                scheduledAt: new Date(scheduledAt),
                status: 'DRAFT'
            },
            include: {
                vehicle: true,
                driver: true
            }
        });

        res.status(201).json({
            success: true,
            message: 'Trip created successfully',
            data: trip
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error creating trip',
            error: error.message
        });
    }
};

/**
 * PATCH /api/trips/:id/dispatch - Dispatch trip
 */
export const dispatchTrip = async (req, res) => {
    try {
        const { id } = req.params;

        const trip = await prisma.trip.findUnique({
            where: { id },
            include: { vehicle: true, driver: true }
        });

        if (!trip) {
            return res.status(404).json({
                success: false,
                message: 'Trip not found'
            });
        }

        if (trip.status !== 'DRAFT') {
            return res.status(400).json({
                success: false,
                message: `Trip cannot be dispatched. Current status: ${trip.status}`
            });
        }

        const updatedTrip = await prisma.trip.update({
            where: { id },
            data: {
                status: 'DISPATCHED',
                dispatchedAt: new Date(),
                updatedAt: new Date()
            },
            include: {
                vehicle: true,
                driver: true
            }
        });

        // Update vehicle status
        await prisma.vehicle.update({
            where: { id: trip.vehicleId },
            data: { status: 'ON_TRIP' }
        });

        // Update driver status
        await prisma.driver.update({
            where: { id: trip.driverId },
            data: { status: 'ON_DUTY' }
        });

        res.status(200).json({
            success: true,
            message: 'Trip dispatched successfully',
            data: updatedTrip
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error dispatching trip',
            error: error.message
        });
    }
};

/**
 * PATCH /api/trips/:id/complete - Complete trip
 */
export const completeTrip = async (req, res) => {
    try {
        const { id } = req.params;
        const { endOdometer } = req.body;

        if (!endOdometer || endOdometer < 0) {
            return res.status(400).json({
                success: false,
                message: 'Valid end odometer value is required'
            });
        }

        const trip = await prisma.trip.findUnique({
            where: { id },
            include: { vehicle: true, driver: true }
        });

        if (!trip) {
            return res.status(404).json({
                success: false,
                message: 'Trip not found'
            });
        }

        if (trip.status !== 'DISPATCHED') {
            return res.status(400).json({
                success: false,
                message: `Trip cannot be completed. Current status: ${trip.status}`
            });
        }

        const updatedTrip = await prisma.trip.update({
            where: { id },
            data: {
                status: 'COMPLETED',
                endOdometer: parseFloat(endOdometer),
                completedAt: new Date(),
                updatedAt: new Date()
            },
            include: {
                vehicle: true,
                driver: true
            }
        });

        // Update vehicle status to AVAILABLE
        await prisma.vehicle.update({
            where: { id: trip.vehicleId },
            data: {
                status: 'AVAILABLE',
                currentOdometer: parseFloat(endOdometer)
            }
        });

        // Update driver status to OFF_DUTY and increment trip counts
        await prisma.driver.update({
            where: { id: trip.driverId },
            data: {
                status: 'OFF_DUTY',
                totalTrips: { increment: 1 },
                completedTrips: { increment: 1 }
            }
        });

        res.status(200).json({
            success: true,
            message: 'Trip completed successfully',
            data: updatedTrip
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error completing trip',
            error: error.message
        });
    }
};

/**
 * PATCH /api/trips/:id/cancel - Cancel trip
 */
export const cancelTrip = async (req, res) => {
    try {
        const { id } = req.params;

        const trip = await prisma.trip.findUnique({
            where: { id },
            include: { vehicle: true, driver: true }
        });

        if (!trip) {
            return res.status(404).json({
                success: false,
                message: 'Trip not found'
            });
        }

        if (!['DRAFT', 'DISPATCHED'].includes(trip.status)) {
            return res.status(400).json({
                success: false,
                message: `Trip cannot be cancelled. Current status: ${trip.status}`
            });
        }

        const updatedTrip = await prisma.trip.update({
            where: { id },
            data: {
                status: 'CANCELLED',
                cancelledAt: new Date(),
                updatedAt: new Date()
            },
            include: {
                vehicle: true,
                driver: true
            }
        });

        // Revert vehicle and driver status if trip was dispatched
        if (trip.status === 'DISPATCHED') {
            await prisma.vehicle.update({
                where: { id: trip.vehicleId },
                data: { status: 'AVAILABLE' }
            });

            await prisma.driver.update({
                where: { id: trip.driverId },
                data: { status: 'OFF_DUTY' }
            });
        }

        res.status(200).json({
            success: true,
            message: 'Trip cancelled successfully',
            data: updatedTrip
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error cancelling trip',
            error: error.message
        });
    }
};

/**
 * DELETE /api/trips/:id - Delete trip
 */
export const deleteTrip = async (req, res) => {
    try {
        const { id } = req.params;

        const trip = await prisma.trip.findUnique({ where: { id } });
        if (!trip) {
            return res.status(404).json({
                success: false,
                message: 'Trip not found'
            });
        }

        if (trip.status !== 'DRAFT') {
            return res.status(400).json({
                success: false,
                message: 'Only draft trips can be deleted'
            });
        }

        await prisma.trip.delete({ where: { id } });

        res.status(200).json({
            success: true,
            message: 'Trip deleted successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error deleting trip',
            error: error.message
        });
    }
};
