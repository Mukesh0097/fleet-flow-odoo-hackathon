import { prisma } from '../config/db.config.js';

/**
 * GET /api/fuel - Get all fuel logs with pagination
 */
export const getAllFuelLogs = async (req, res) => {
    try {
        const { page = 1, limit = 10, vehicleId } = req.query;
        const skip = (page - 1) * limit;
        const where = {};

        if (vehicleId) where.vehicleId = vehicleId;

        const logs = await prisma.fuelLog.findMany({
            where,
            skip: parseInt(skip),
            take: parseInt(limit),
            include: {
                vehicle: true,
                trip: true
            }
        });

        const total = await prisma.fuelLog.count({ where });

        res.status(200).json({
            success: true,
            data: logs,
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
            message: 'Error fetching fuel logs',
            error: error.message
        });
    }
};

/**
 * GET /api/fuel/:id - Get fuel log by ID
 */
export const getFuelLogById = async (req, res) => {
    try {
        const { id } = req.params;

        const log = await prisma.fuelLog.findUnique({
            where: { id },
            include: {
                vehicle: true,
                trip: true
            }
        });

        if (!log) {
            return res.status(404).json({
                success: false,
                message: 'Fuel log not found'
            });
        }

        res.status(200).json({
            success: true,
            data: log
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching fuel log',
            error: error.message
        });
    }
};

/**
 * POST /api/fuel - Create new fuel log
 */
export const createFuelLog = async (req, res) => {
    try {
        const { vehicleId, quantity, cost, odometerReading, fuelType, logDate, tripId } = req.validatedData;

        // Validate vehicle exists
        const vehicle = await prisma.vehicle.findUnique({ where: { id: vehicleId } });
        if (!vehicle) {
            return res.status(404).json({
                success: false,
                message: 'Vehicle not found'
            });
        }

        // If tripId is provided, validate trip exists
        if (tripId) {
            const trip = await prisma.trip.findUnique({ where: { id: tripId } });
            if (!trip) {
                return res.status(404).json({
                    success: false,
                    message: 'Trip not found'
                });
            }
        }

        // Calculate cost per liter
        const costPerLiter = quantity > 0 ? cost / quantity : 0;

        const log = await prisma.fuelLog.create({
            data: {
                vehicleId,
                tripId: tripId || null,
                quantity: parseFloat(quantity),
                cost: parseFloat(cost),
                costPerLiter: parseFloat(costPerLiter.toFixed(2)),
                odometerReading: parseFloat(odometerReading),
                fuelType: fuelType || 'DIESEL',
                logDate: new Date(logDate)
            },
            include: {
                vehicle: true,
                trip: true
            }
        });

        res.status(201).json({
            success: true,
            message: 'Fuel log created successfully',
            data: log
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error creating fuel log',
            error: error.message
        });
    }
};

/**
 * PATCH /api/fuel/:id - Update fuel log
 */
export const updateFuelLog = async (req, res) => {
    try {
        const { id } = req.params;
        const { quantity, cost, odometerReading, fuelType } = req.validatedData;

        const log = await prisma.fuelLog.findUnique({ where: { id } });
        if (!log) {
            return res.status(404).json({
                success: false,
                message: 'Fuel log not found'
            });
        }

        const newQuantity = quantity || log.quantity;
        const newCost = cost || log.cost;
        const costPerLiter = newQuantity > 0 ? newCost / newQuantity : 0;

        const updatedLog = await prisma.fuelLog.update({
            where: { id },
            data: {
                ...(quantity && { quantity: parseFloat(quantity) }),
                ...(cost && { cost: parseFloat(cost) }),
                ...(cost || quantity) && {
                    costPerLiter: parseFloat(costPerLiter.toFixed(2))
                },
                ...(odometerReading && { odometerReading: parseFloat(odometerReading) }),
                ...(fuelType && { fuelType }),
                updatedAt: new Date()
            },
            include: {
                vehicle: true,
                trip: true
            }
        });

        res.status(200).json({
            success: true,
            message: 'Fuel log updated successfully',
            data: updatedLog
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating fuel log',
            error: error.message
        });
    }
};

/**
 * GET /api/fuel/vehicle/:vehicleId/efficiency - Get fuel efficiency metrics for a vehicle
 */
export const getVehicleFuelEfficiency = async (req, res) => {
    try {
        const { vehicleId } = req.params;

        const vehicle = await prisma.vehicle.findUnique({ where: { id: vehicleId } });
        if (!vehicle) {
            return res.status(404).json({
                success: false,
                message: 'Vehicle not found'
            });
        }

        const logs = await prisma.fuelLog.findMany({
            where: { vehicleId },
            orderBy: { logDate: 'desc' },
            take: 30  // Last 30 fuel logs
        });

        if (logs.length === 0) {
            return res.status(200).json({
                success: true,
                data: {
                    vehicleId,
                    totalLogs: 0,
                    averageCostPerLiter: 0,
                    totalFuelCost: 0
                }
            });
        }

        const totalLiters = logs.reduce((sum, log) => sum + log.quantity, 0);
        const totalCost = logs.reduce((sum, log) => sum + log.cost, 0);
        const averageCostPerLiter = totalLiters > 0 ? totalCost / totalLiters : 0;

        res.status(200).json({
            success: true,
            data: {
                vehicleId,
                totalLogs: logs.length,
                totalLiters: parseFloat(totalLiters.toFixed(2)),
                totalFuelCost: parseFloat(totalCost.toFixed(2)),
                averageCostPerLiter: parseFloat(averageCostPerLiter.toFixed(2)),
                fuelType: logs[0].fuelType,
                recentLogs: logs.slice(0, 5)
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching fuel efficiency',
            error: error.message
        });
    }
};

/**
 * DELETE /api/fuel/:id - Delete fuel log
 */
export const deleteFuelLog = async (req, res) => {
    try {
        const { id } = req.params;

        const log = await prisma.fuelLog.findUnique({ where: { id } });
        if (!log) {
            return res.status(404).json({
                success: false,
                message: 'Fuel log not found'
            });
        }

        await prisma.fuelLog.delete({ where: { id } });

        res.status(200).json({
            success: true,
            message: 'Fuel log deleted successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error deleting fuel log',
            error: error.message
        });
    }
};
