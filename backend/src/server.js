import express from 'express';
import bodyParser from 'body-parser';
import dotenv from 'dotenv';
import authRoutes from './routes/authRoutes.js';
import vehicleRoutes from './routes/vehicleRoutes.js';
import driverRoutes from './routes/driverRoutes.js';
import tripRoutes from './routes/tripRoutes.js';
import maintenanceRoutes from './routes/maintenanceRoutes.js';
import fuelRoutes from './routes/fuelRoutes.js';
import { requestLogger } from './middleware/requestLogger.js';
import { validateContentType, validateRequestSize } from './middleware/requestValidator.js';
import { corsHeaders } from './middleware/corsHeaders.js';
import { securityHeaders } from './middleware/securityHeaders.js';
import { sanitizeInputs } from './middleware/sanitizeInputs.js';
import { rateLimit } from './middleware/rateLimit.js';
import { requestTimeout } from './middleware/requestTimeout.js';
import { notFoundHandler } from './middleware/notFoundHandler.js';
import { errorHandler } from './middleware/errorHandler.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// ==================== BODY PARSING MIDDLEWARE ====================
app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ extended: true, limit: '10mb' }));

// ==================== SECURITY & CORS MIDDLEWARE ====================
app.use(corsHeaders);
app.use(securityHeaders);
app.use(validateContentType);
app.use(validateRequestSize);

// ==================== REQUEST MONITORING MIDDLEWARE ====================
app.use(requestLogger);
app.use(rateLimit);
app.use(requestTimeout(30000)); // 30 second timeout

// ==================== REQUEST SANITIZATION ====================
app.use(sanitizeInputs);

// ==================== HEALTH CHECK ROUTE ====================
app.get('/health', (req, res) => {
    res.status(200).json({
        success: true,
        message: 'Server is running',
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'development'
    });
});

// ==================== API ROUTES ====================
app.use('/api/auth', authRoutes);
app.use('/api/vehicles', vehicleRoutes);
app.use('/api/drivers', driverRoutes);
app.use('/api/trips', tripRoutes);
app.use('/api/maintenance', maintenanceRoutes);
app.use('/api/fuel', fuelRoutes);

// ==================== 404 HANDLER ====================
app.use(notFoundHandler);

// ==================== GLOBAL ERROR HANDLER ====================
app.use(errorHandler);

// ==================== START SERVER ====================
app.listen(PORT, () => {
    console.log(`
    ╔════════════════════════════════════════════════════════════╗
    ║   Fleet & Logistics Management System API                  ║
    ║   Server running on http://localhost:${PORT}                ║
    ║   Environment: ${process.env.NODE_ENV || 'development'}                        ║
    ║   ${new Date().toISOString()}  ║
    ╚════════════════════════════════════════════════════════════╝
    `);
});

// ==================== UNHANDLED PROMISE REJECTION HANDLER ====================
process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

// ==================== UNCAUGHT EXCEPTION HANDLER ====================
process.on('uncaughtException', (error) => {
    console.error('Uncaught Exception:', error);
    process.exit(1);
});

export default app;