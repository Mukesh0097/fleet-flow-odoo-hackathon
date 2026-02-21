import { prisma } from '../config/db.config.js';

/**
 * GET /api/vehicles - Get all vehicles with pagination and filters
 */
export const getAllVehicles = async (req, res) => {
    try {
        const { page = 1, limit = 10, status, region, type } = req.query;
        const skip = (page - 1) * limit;
        const where = {};

        if (status) where.status = status;
        if (region) where.region = region;
        if (type) where.vehicleType = type;

        const vehicles = await prisma.vehicle.findMany({
            where,
            skip: parseInt(skip),
            take: parseInt(limit),
            include: {
                trips: { select: { id: true, status: true } },
                maintenanceLogs: { select: { id: true, maintenanceType: true, serviceDate: true } },
                fuelLogs: { select: { id: true } }
            }
        });

        const total = await prisma.vehicle.count({ where });

        res.status(200).json({
            success: true,
            data: vehicles,
            meta: {
                total,
                page: parseInt(page),
                limit: parseInt(limit),
                totalPages: Math.ceil(total / limit)
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching vehicles',
            error: error.message
        });
    }
};

/**
 * GET /api/vehicles/:id - Get vehicle by ID
 */
export const getVehicleById = async (req, res) => {
    try {
        const { id } = req.params;

        const vehicle = await prisma.vehicle.findUnique({
            where: { id },
            include: {
                trips: {
                    orderBy: { createdAt: 'desc' },
                    take: 5
                },
                maintenanceLogs: {
                    orderBy: { serviceDate: 'desc' },
                    take: 5
                },
                fuelLogs: {
                    orderBy: { logDate: 'desc' },
                    take: 5
                }
            }
        });

        if (!vehicle) {
            return res.status(404).json({
                success: false,
                message: 'Vehicle not found'
            });
        }

        res.status(200).json({
            success: true,
            data: vehicle
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching vehicle',
            error: error.message
        });
    }
};

/**
 * POST /api/vehicles - Create new vehicle
 */
export const createVehicle = async (req, res) => {
    try {
        const { name, model, licensePlate, vehicleType, maxCapacityKg, acquisitionCost, region } = req.validatedData;

        // Check if license plate already exists
        const existingVehicle = await prisma.vehicle.findUnique({
            where: { licensePlate }
        });

        if (existingVehicle) {
            return res.status(409).json({
                success: false,
                message: 'Vehicle with this license plate already exists'
            });
        }

        const vehicle = await prisma.vehicle.create({
            data: {
                name,
                model,
                licensePlate,
                vehicleType,
                maxCapacityKg,
                acquisitionCost: acquisitionCost ? parseFloat(acquisitionCost) : null,
                region: region || null,
                status: 'AVAILABLE',
                currentOdometer: 0
            }
        });

        res.status(201).json({
            success: true,
            message: 'Vehicle created successfully',
            data: vehicle
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error creating vehicle',
            error: error.message
        });
    }
};

/**
 * PATCH /api/vehicles/:id - Update vehicle details
 */
export const updateVehicle = async (req, res) => {
    try {
        const { id } = req.params;
        const { name, model, maxCapacityKg, region } = req.validatedData;

        const vehicle = await prisma.vehicle.findUnique({ where: { id } });
        if (!vehicle) {
            return res.status(404).json({
                success: false,
                message: 'Vehicle not found'
            });
        }

        const updatedVehicle = await prisma.vehicle.update({
            where: { id },
            data: {
                ...(name && { name }),
                ...(model && { model }),
                ...(maxCapacityKg && { maxCapacityKg: parseFloat(maxCapacityKg) }),
                ...(region && { region }),
                updatedAt: new Date()
            }
        });

        res.status(200).json({
            success: true,
            message: 'Vehicle updated successfully',
            data: updatedVehicle
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating vehicle',
            error: error.message
        });
    }
};

/**
 * PATCH /api/vehicles/:id/retire - Retire vehicle from service
 */
export const retireVehicle = async (req, res) => {
    try {
        const { id } = req.params;

        const vehicle = await prisma.vehicle.findUnique({ where: { id } });
        if (!vehicle) {
            return res.status(404).json({
                success: false,
                message: 'Vehicle not found'
            });
        }

        const updatedVehicle = await prisma.vehicle.update({
            where: { id },
            data: {
                status: 'OUT_OF_SERVICE',
                isRetired: true,
                updatedAt: new Date()
            }
        });

        res.status(200).json({
            success: true,
            message: 'Vehicle retired successfully',
            data: updatedVehicle
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error retiring vehicle',
            error: error.message
        });
    }
};

/**
 * DELETE /api/vehicles/:id - Delete vehicle
 */
export const deleteVehicle = async (req, res) => {
    try {
        const { id } = req.params;

        const vehicle = await prisma.vehicle.findUnique({ where: { id } });
        if (!vehicle) {
            return res.status(404).json({
                success: false,
                message: 'Vehicle not found'
            });
        }

        // Check if vehicle has active trips
        const activeTrips = await prisma.trip.findFirst({
            where: {
                vehicleId: id,
                status: { in: ['DRAFT', 'DISPATCHED'] }
            }
        });

        if (activeTrips) {
            return res.status(400).json({
                success: false,
                message: 'Cannot delete vehicle with active trips'
            });
        }

        await prisma.vehicle.delete({ where: { id } });

        res.status(200).json({
            success: true,
            message: 'Vehicle deleted successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error deleting vehicle',
            error: error.message
        });
    }
};

/**
 * PATCH /api/vehicles/:id/odometer - Update vehicle odometer
 */
export const updateOdometer = async (req, res) => {
    try {
        const { id } = req.params;
        const { odometer } = req.body;

        if (!odometer || odometer < 0) {
            return res.status(400).json({
                success: false,
                message: 'Invalid odometer value'
            });
        }

        const vehicle = await prisma.vehicle.findUnique({ where: { id } });
        if (!vehicle) {
            return res.status(404).json({
                success: false,
                message: 'Vehicle not found'
            });
        }

        const updatedVehicle = await prisma.vehicle.update({
            where: { id },
            data: {
                currentOdometer: parseFloat(odometer),
                updatedAt: new Date()
            }
        });

        res.status(200).json({
            success: true,
            message: 'Odometer updated successfully',
            data: updatedVehicle
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating odometer',
            error: error.message
        });
    }
};
