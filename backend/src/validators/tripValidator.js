import Joi from 'joi';

export const createTripSchema = Joi.object({
    vehicleId: Joi.string().required().messages({
        'any.required': 'Vehicle ID is required'
    }),
    driverId: Joi.string().required().messages({
        'any.required': 'Driver ID is required'
    }),
    originAddress: Joi.string().required().messages({
        'any.required': 'Origin address is required'
    }),
    destAddress: Joi.string().required().messages({
        'any.required': 'Destination address is required'
    }),
    "cargoDescription": Joi.string().optional(),
    cargoWeightKg: Joi.number().positive().required().messages({
        'number.positive': 'Cargo weight must be positive',
        'any.required': 'Cargo weight is required'
    }),
    region: Joi.string()
        .valid('NORTH', 'SOUTH', 'EAST', 'WEST', 'CENTRAL')
        .optional(),
    scheduledAt: Joi.date().iso().required().messages({
        'date.iso': 'Scheduled date must be in ISO format',
        'any.required': 'Scheduled date is required'
    })
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
