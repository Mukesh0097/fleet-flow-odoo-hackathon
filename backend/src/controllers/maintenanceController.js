import { prisma } from '../config/db.config.js';

/**
 * GET /api/maintenance - Get all maintenance logs with pagination
 */
export const getAllMaintenanceLogs = async (req, res) => {
    try {
        const { page = 1, limit = 10, status } = req.query;
        const skip = (page - 1) * limit;
        const where = {};

        if (status) where.status = status;

        const logs = await prisma.maintenanceLog.findMany({
            where,
            skip: parseInt(skip),
            take: parseInt(limit),
            include: {
                vehicle: true
            }
        });

        const total = await prisma.maintenanceLog.count({ where });

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
            message: 'Error fetching maintenance logs',
            error: error.message
        });
    }
};

/**
 * GET /api/maintenance/:id - Get maintenance log by ID
 */
export const getMaintenanceLogById = async (req, res) => {
    try {
        const { id } = req.params;

        const log = await prisma.maintenanceLog.findUnique({
            where: { id },
            include: { vehicle: true }
        });

        if (!log) {
            return res.status(404).json({
                success: false,
                message: 'Maintenance log not found'
            });
        }

        res.status(200).json({
            success: true,
            data: log
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching maintenance log',
            error: error.message
        });
    }
};

/**
 * POST /api/maintenance - Create new maintenance log
 */
export const createMaintenanceLog = async (req, res) => {
    try {
        const { vehicleId, serviceType, description, cost, serviceDate } = req.validatedData;

        // Validate vehicle exists
        const vehicle = await prisma.vehicle.findUnique({ where: { id: vehicleId } });
        if (!vehicle) {
            return res.status(404).json({
                success: false,
                message: 'Vehicle not found'
            });
        }

        const log = await prisma.maintenanceLog.create({
            data: {
                vehicleId,
                serviceType,
                description: description || null,
                cost: parseFloat(cost),
                serviceDate: new Date(serviceDate),
                status: 'SCHEDULED'
            },
            include: { vehicle: true }
        });

        // Update vehicle status to IN_SHOP
        await prisma.vehicle.update({
            where: { id: vehicleId },
            data: { status: 'IN_SHOP' }
        });

        res.status(201).json({
            success: true,
            message: 'Maintenance log created successfully',
            data: log
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error creating maintenance log',
            error: error.message
        });
    }
};

/**
 * PATCH /api/maintenance/:id - Update maintenance log
 */
export const updateMaintenanceLog = async (req, res) => {
    try {
        const { id } = req.params;
        const { serviceType, description, cost } = req.validatedData;

        const log = await prisma.maintenanceLog.findUnique({ where: { id } });
        if (!log) {
            return res.status(404).json({
                success: false,
                message: 'Maintenance log not found'
            });
        }

        const updatedLog = await prisma.maintenanceLog.update({
            where: { id },
            data: {
                ...(serviceType && { serviceType }),
                ...(description && { description }),
                ...(cost && { cost: parseFloat(cost) }),
                updatedAt: new Date()
            },
            include: { vehicle: true }
        });

        res.status(200).json({
            success: true,
            message: 'Maintenance log updated successfully',
            data: updatedLog
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating maintenance log',
            error: error.message
        });
    }
};

/**
 * PATCH /api/maintenance/:id/complete - Complete maintenance service
 */
export const completeMaintenanceLog = async (req, res) => {
    try {
        const { id } = req.params;
        const { actualCost } = req.body;

        const log = await prisma.maintenanceLog.findUnique({
            where: { id },
            include: { vehicle: true }
        });

        if (!log) {
            return res.status(404).json({
                success: false,
                message: 'Maintenance log not found'
            });
        }

        const completedLog = await prisma.maintenanceLog.update({
            where: { id },
            data: {
                status: 'COMPLETED',
                actualCost: actualCost ? parseFloat(actualCost) : log.cost,
                completedAt: new Date(),
                updatedAt: new Date()
            },
            include: { vehicle: true }
        });

        // Revert vehicle status to AVAILABLE
        await prisma.vehicle.update({
            where: { id: log.vehicleId },
            data: { status: 'AVAILABLE' }
        });

        res.status(200).json({
            success: true,
            message: 'Maintenance service completed successfully',
            data: completedLog
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error completing maintenance service',
            error: error.message
        });
    }
};

/**
 * PATCH /api/maintenance/:id/cancel - Cancel maintenance service
 */
export const cancelMaintenanceLog = async (req, res) => {
    try {
        const { id } = req.params;

        const log = await prisma.maintenanceLog.findUnique({
            where: { id },
            include: { vehicle: true }
        });

        if (!log) {
            return res.status(404).json({
                success: false,
                message: 'Maintenance log not found'
            });
        }

        const cancelledLog = await prisma.maintenanceLog.update({
            where: { id },
            data: {
                status: 'CANCELLED',
                updatedAt: new Date()
            },
            include: { vehicle: true }
        });

        // Revert vehicle status to AVAILABLE if it was IN_SHOP
        if (log.vehicle.status === 'IN_SHOP') {
            await prisma.vehicle.update({
                where: { id: log.vehicleId },
                data: { status: 'AVAILABLE' }
            });
        }

        res.status(200).json({
            success: true,
            message: 'Maintenance service cancelled successfully',
            data: cancelledLog
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error cancelling maintenance service',
            error: error.message
        });
    }
};

/**
 * DELETE /api/maintenance/:id - Delete maintenance log
 */
export const deleteMaintenanceLog = async (req, res) => {
    try {
        const { id } = req.params;

        const log = await prisma.maintenanceLog.findUnique({ where: { id } });
        if (!log) {
            return res.status(404).json({
                success: false,
                message: 'Maintenance log not found'
            });
        }

        if (!['SCHEDULED', 'CANCELLED'].includes(log.status)) {
            return res.status(400).json({
                success: false,
                message: 'Only scheduled or cancelled maintenance logs can be deleted'
            });
        }

        await prisma.maintenanceLog.delete({ where: { id } });

        res.status(200).json({
            success: true,
            message: 'Maintenance log deleted successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error deleting maintenance log',
            error: error.message
        });
    }
};
