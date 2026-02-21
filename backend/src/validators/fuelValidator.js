import Joi from 'joi';

export const createFuelLogSchema = Joi.object({
    vehicleId: Joi.string().required().messages({
        'any.required': 'Vehicle ID is required'
    }),
    quantity: Joi.number().positive().required().messages({
        'number.positive': 'Quantity must be positive',
        'any.required': 'Quantity (liters) is required'
    }),
    cost: Joi.number().positive().required().messages({
        'number.positive': 'Cost must be positive',
        'any.required': 'Cost is required'
    }),
    odometerReading: Joi.number().positive().required().messages({
        'number.positive': 'Odometer reading must be positive',
        'any.required': 'Odometer reading is required'
    }),
    fuelType: Joi.string()
        .valid('DIESEL', 'PETROL', 'CNG')
        .optional(),
    logDate: Joi.date().iso().required().messages({
        'date.iso': 'Log date must be in ISO format',
        'any.required': 'Log date is required'
    }),
    tripId: Joi.string().optional()
});

export const updateFuelLogSchema = Joi.object({
    quantity: Joi.number().positive().optional(),
    cost: Joi.number().positive().optional(),
    odometerReading: Joi.number().positive().optional(),
    fuelType: Joi.string()
        .valid('DIESEL', 'PETROL', 'CNG')
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
