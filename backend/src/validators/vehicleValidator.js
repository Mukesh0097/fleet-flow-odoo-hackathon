import Joi from 'joi';

export const createVehicleSchema = Joi.object({
    name: Joi.string().min(2).max(100).required().messages({
        'string.min': 'Vehicle name must be at least 2 characters',
        'any.required': 'Vehicle name is required'
    }),
    model: Joi.string().min(2).max(100).required().messages({
        'string.min': 'Model must be at least 2 characters',
        'any.required': 'Model is required'
    }),
    licensePlate: Joi.string().uppercase().required().messages({
        'any.required': 'License plate is required'
    }),
    vehicleType: Joi.string()
        .valid('TRUCK', 'VAN', 'BIKE')
        .required()
        .messages({
            'any.only': 'Vehicle type must be TRUCK, VAN, or BIKE',
            'any.required': 'Vehicle type is required'
        }),
    maxCapacityKg: Joi.number().positive().required().messages({
        'number.positive': 'Max capacity must be a positive number',
        'any.required': 'Max capacity is required'
    }),
    acquisitionCost: Joi.number().positive().optional(),
    region: Joi.string()
        .valid('NORTH', 'SOUTH', 'EAST', 'WEST', 'CENTRAL')
        .optional()
});

export const updateVehicleSchema = Joi.object({
    name: Joi.string().min(2).max(100).optional(),
    model: Joi.string().min(2).max(100).optional(),
    maxCapacityKg: Joi.number().positive().optional(),
    region: Joi.string()
        .valid('NORTH', 'SOUTH', 'EAST', 'WEST', 'CENTRAL')
        .optional()
}).min(1).messages({
    'object.min': 'At least one field must be provided for update'
});

export const validateRequest = (schema) => {
    return (req, res, next) => {
        const { error, value } = schema.validate(req.body, {
            abortEarly: false,
            stripUnknown: true
        });

        if (error) {
            const errors = error.details.map(detail => ({
                field: detail.path.join('.'),
                message: detail.message
            }));
            return res.status(400).json({ success: false, errors });
        }

        req.validatedData = value;
        next();
    };
};
