import Joi from 'joi';

export const createDriverSchema = Joi.object({
    name: Joi.string().min(2).max(100).required().messages({
        'string.min': 'Driver name must be at least 2 characters',
        'any.required': 'Driver name is required'
    }),
    email: Joi.string().email().required().messages({
        'string.email': 'Valid email is required',
        'any.required': 'Email is required'
    }),
    phone: Joi.string().optional(),
    licenseNumber: Joi.string().required().messages({
        'any.required': 'License number is required'
    }),
    licenseExpiryDate: Joi.date().iso().required().messages({
        'date.iso': 'License expiry date must be in ISO format',
        'any.required': 'License expiry date is required'
    }),
    licenseCategories: Joi.array()
        .items(Joi.string().valid('VAN', 'TRUCK', 'BIKE', 'HEAVY'))
        .optional()
});

export const updateDriverSchema = Joi.object({
    name: Joi.string().min(2).max(100).optional(),
    phone: Joi.string().optional(),
    licenseExpiryDate: Joi.date().iso().optional(),
    licenseCategories: Joi.array()
        .items(Joi.string().valid('VAN', 'TRUCK', 'BIKE', 'HEAVY'))
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
