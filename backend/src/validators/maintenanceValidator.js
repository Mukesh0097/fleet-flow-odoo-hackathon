import Joi from 'joi';

export const createMaintenanceSchema = Joi.object({
    vehicleId: Joi.string().required().messages({
        'any.required': 'Vehicle ID is required'
    }),
    serviceType: Joi.string()
        .valid('OIL_CHANGE', 'TIRE_SERVICE', 'ENGINE_CHECK', 'BRAKE_SERVICE', 'GENERAL_MAINTENANCE')
        .required()
        .messages({
            'any.only': 'Service type must be one of: OIL_CHANGE, TIRE_SERVICE, ENGINE_CHECK, BRAKE_SERVICE, GENERAL_MAINTENANCE',
            'any.required': 'Service type is required'
        }),
    description: Joi.string().optional(),
    cost: Joi.number().positive().required().messages({
        'number.positive': 'Cost must be positive',
        'any.required': 'Cost is required'
    }),
    serviceDate: Joi.date().iso().required().messages({
        'date.iso': 'Service date must be in ISO format',
        'any.required': 'Service date is required'
    })
});

export const updateMaintenanceSchema = Joi.object({
    serviceType: Joi.string()
        .valid('OIL_CHANGE', 'TIRE_SERVICE', 'ENGINE_CHECK', 'BRAKE_SERVICE', 'GENERAL_MAINTENANCE')
        .optional(),
    description: Joi.string().optional(),
    cost: Joi.number().positive().optional()
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
