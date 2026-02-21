import { prisma } from '../config/db.config.js';

/**
 * GET /api/drivers - Get all drivers with pagination and filters
 */
export const getAllDrivers = async (req, res) => {
    try {
        const { page = 1, limit = 10, status } = req.query;
        const skip = (page - 1) * limit;
        const where = {};

        if (status) where.status = status;

        const drivers = await prisma.driver.findMany({
            where,
            skip: parseInt(skip),
            take: parseInt(limit),
            include: {
                trips: { select: { id: true, status: true } }
            }
        });

        const total = await prisma.driver.count({ where });

        res.status(200).json({
            success: true,
            data: drivers,
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
            message: 'Error fetching drivers',
            error: error.message
        });
    }
};

/**
 * GET /api/drivers/:id - Get driver by ID
 */
export const getDriverById = async (req, res) => {
    try {
        const { id } = req.params;

        const driver = await prisma.driver.findUnique({
            where: { id },
            include: {
                trips: {
                    orderBy: { createdAt: 'desc' },
                    take: 5
                }
            }
        });

        if (!driver) {
            return res.status(404).json({
                success: false,
                message: 'Driver not found'
            });
        }

        res.status(200).json({
            success: true,
            data: driver
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching driver',
            error: error.message
        });
    }
};

/**
 * POST /api/drivers - Create new driver
 */
export const createDriver = async (req, res) => {
    try {
        const { name, email, phone, licenseNumber, licenseExpiryDate, licenseCategories } = req.validatedData;

        // Check if email already exists
        const existingEmail = await prisma.driver.findUnique({
            where: { email }
        });

        if (existingEmail) {
            return res.status(409).json({
                success: false,
                message: 'Driver with this email already exists'
            });
        }

        // Check if license number already exists
        const existingLicense = await prisma.driver.findUnique({
            where: { licenseNumber }
        });

        if (existingLicense) {
            return res.status(409).json({
                success: false,
                message: 'Driver with this license number already exists'
            });
        }

        const driver = await prisma.driver.create({
            data: {
                name,
                email,
                phone: phone || null,
                licenseNumber,
                licenseExpiryDate: new Date(licenseExpiryDate),
                licenseCategories: licenseCategories || [],
                status: 'OFF_DUTY',
                safetyScore: 100.0,
                totalTrips: 0,
                completedTrips: 0
            }
        });

        res.status(201).json({
            success: true,
            message: 'Driver created successfully',
            data: driver
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error creating driver',
            error: error.message
        });
    }
};

/**
 * PATCH /api/drivers/:id - Update driver details
 */
export const updateDriver = async (req, res) => {
    try {
        const { id } = req.params;
        const { name, phone, licenseExpiryDate, licenseCategories } = req.validatedData;

        const driver = await prisma.driver.findUnique({ where: { id } });
        if (!driver) {
            return res.status(404).json({
                success: false,
                message: 'Driver not found'
            });
        }

        const updatedDriver = await prisma.driver.update({
            where: { id },
            data: {
                ...(name && { name }),
                ...(phone && { phone }),
                ...(licenseExpiryDate && { licenseExpiryDate: new Date(licenseExpiryDate) }),
                ...(licenseCategories && { licenseCategories }),
                updatedAt: new Date()
            }
        });

        res.status(200).json({
            success: true,
            message: 'Driver updated successfully',
            data: updatedDriver
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating driver',
            error: error.message
        });
    }
};

/**
 * PATCH /api/drivers/:id/status - Update driver status
 */
export const updateDriverStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;

        if (!['ON_DUTY', 'OFF_DUTY', 'SUSPENDED'].includes(status)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid status. Must be ON_DUTY, OFF_DUTY, or SUSPENDED'
            });
        }

        const driver = await prisma.driver.findUnique({ where: { id } });
        if (!driver) {
            return res.status(404).json({
                success: false,
                message: 'Driver not found'
            });
        }

        const updatedDriver = await prisma.driver.update({
            where: { id },
            data: {
                status,
                updatedAt: new Date()
            }
        });

        res.status(200).json({
            success: true,
            message: 'Driver status updated successfully',
            data: updatedDriver
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating driver status',
            error: error.message
        });
    }
};

/**
 * PATCH /api/drivers/:id/suspend - Suspend driver
 */
export const suspendDriver = async (req, res) => {
    try {
        const { id } = req.params;

        const driver = await prisma.driver.findUnique({ where: { id } });
        if (!driver) {
            return res.status(404).json({
                success: false,
                message: 'Driver not found'
            });
        }

        const updatedDriver = await prisma.driver.update({
            where: { id },
            data: {
                status: 'SUSPENDED',
                updatedAt: new Date()
            }
        });

        res.status(200).json({
            success: true,
            message: 'Driver suspended successfully',
            data: updatedDriver
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error suspending driver',
            error: error.message
        });
    }
};

/**
 * PATCH /api/drivers/:id/safety-score - Update driver safety score
 */
export const updateSafetyScore = async (req, res) => {
    try {
        const { id } = req.params;
        const { score } = req.body;

        if (typeof score !== 'number' || score < 0 || score > 100) {
            return res.status(400).json({
                success: false,
                message: 'Safety score must be a number between 0 and 100'
            });
        }

        const driver = await prisma.driver.findUnique({ where: { id } });
        if (!driver) {
            return res.status(404).json({
                success: false,
                message: 'Driver not found'
            });
        }

        const updatedDriver = await prisma.driver.update({
            where: { id },
            data: {
                safetyScore: parseFloat(score),
                updatedAt: new Date()
            }
        });

        res.status(200).json({
            success: true,
            message: 'Driver safety score updated successfully',
            data: updatedDriver
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating safety score',
            error: error.message
        });
    }
};

/**
 * DELETE /api/drivers/:id - Delete driver
 */
export const deleteDriver = async (req, res) => {
    try {
        const { id } = req.params;

        const driver = await prisma.driver.findUnique({ where: { id } });
        if (!driver) {
            return res.status(404).json({
                success: false,
                message: 'Driver not found'
            });
        }

        // Check if driver has active trips
        const activeTrips = await prisma.trip.findFirst({
            where: {
                driverId: id,
                status: { in: ['DRAFT', 'DISPATCHED'] }
            }
        });

        if (activeTrips) {
            return res.status(400).json({
                success: false,
                message: 'Cannot delete driver with active trips'
            });
        }

        await prisma.driver.delete({ where: { id } });

        res.status(200).json({
            success: true,
            message: 'Driver deleted successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error deleting driver',
            error: error.message
        });
    }
};
