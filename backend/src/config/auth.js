import 'dotenv/config';

export const AUTH_CONFIG = {
    SECRET_KEY: process.env.JWT_SECRET,
    TOKEN_EXPIRY: '24h',
    REFRESH_TOKEN_EXPIRY: '7d',
};

export const ROLE_PERMISSIONS = {
    FLEET_MANAGER: [
        'VIEW_VEHICLES',
        'CREATE_VEHICLE',
        'EDIT_VEHICLE',
        'RETIRE_VEHICLE',
        'VIEW_TRIPS',
        'CREATE_TRIP',
        'CANCEL_TRIP',
        'COMPLETE_TRIP',
        'VIEW_DRIVERS',
        'CREATE_DRIVER',
        'EDIT_DRIVER',
        'SUSPEND_DRIVER',
        'VIEW_MAINTENANCE',
        'CREATE_MAINTENANCE_LOG',
        'VIEW_EXPENSES',
        'CREATE_FUEL_LOG',
        'EXPORT_REPORTS',
        'VIEW_ANALYTICS',
        'VIEW_DASHBOARD',
    ],
    DISPATCHER: [
        'VIEW_VEHICLES',
        'VIEW_TRIPS',
        'CREATE_TRIP',
        'CANCEL_TRIP',
        'COMPLETE_TRIP',
        'VIEW_DRIVERS',
    ],
    SAFETY_OFFICER: [
        'VIEW_DRIVERS',
        'EDIT_DRIVER',
        'SUSPEND_DRIVER',
        'CREATE_DRIVER',
        'VIEW_TRIPS',
        'VIEW_MAINTENANCE',
    ],
    FINANCIAL_ANALYST: [
        'VIEW_VEHICLES',
        'VIEW_TRIPS',
        'VIEW_EXPENSES',
        'VIEW_ANALYTICS',
        'VIEW_DASHBOARD',
        'EXPORT_REPORTS',
    ],
};
