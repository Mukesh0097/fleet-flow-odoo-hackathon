import bcryptjs from 'bcryptjs';
import 'dotenv/config';
import { prisma } from '../src/config/db.config.js';

// Seed data - Only Fleet Manager (Admin)
const seedUsers = async () => {
    try {
        console.log('🌱 Starting seed data generation...\n');

        // Delete existing users (for fresh seed)
        await prisma.user.deleteMany();
        console.log('✅ Cleared existing users\n');

        // Create Fleet Manager (Admin) user only
        const adminUser = {
            email: 'admin@fleet.com',
            name: 'Fleet Manager',
            password: 'Admin@123456',
            role: 'FLEET_MANAGER',
            description: 'Admin - Full system access. Can manage all users and vehicles.'
        };

        // Hash password and create admin user
        const passwordHash = await bcryptjs.hash(adminUser.password, 10);
        
        const user = await prisma.user.create({
            data: {
                email: adminUser.email,
                name: adminUser.name,
                passwordHash,
                role: adminUser.role,
                isActive: true
            }
        });

        console.log(`✅ Created ADMIN: ${adminUser.email}`);

        console.log('\n' + '='.repeat(80));
        console.log('🎉 FLEET MANAGER (ADMIN) CREATED SUCCESSFULLY\n');
        console.log('='.repeat(80));

        console.log('\n📋 ADMIN USER CREDENTIALS:\n');
        console.log('Name:     ' + adminUser.name);
        console.log('Email:    ' + adminUser.email);
        console.log('Password: ' + adminUser.password);
        console.log('Role:     ' + adminUser.role);
        console.log('Status:   Active');
        console.log('Access:   ' + adminUser.description);

        console.log('\n' + '='.repeat(80));
        console.log('\n🔐 ADMIN CAPABILITIES:\n');
        
        console.log('✅ User Management:');
        console.log('   • View all users');
        console.log('   • Create new users (any role)');
        console.log('   • Edit user details');
        console.log('   • Activate/Deactivate users');
        console.log('   • Delete users\n');

        console.log('✅ Vehicle Management:');
        console.log('   • View all vehicles');
        console.log('   • Create new vehicles');
        console.log('   • Edit vehicle details');
        console.log('   • Retire vehicles');
        console.log('   • Track vehicle maintenance\n');

        console.log('✅ Driver Management:');
        console.log('   • View all drivers');
        console.log('   • Create new drivers');
        console.log('   • Edit driver information');
        console.log('   • Monitor licenses and compliance');
        console.log('   • Suspend/Activate drivers\n');

        console.log('✅ Trip Management:');
        console.log('   • Create and assign trips');
        console.log('   • Monitor trip progress');
        console.log('   • Complete/Cancel trips\n');

        console.log('✅ Maintenance & Reports:');
        console.log('   • View maintenance logs');
        console.log('   • Create maintenance schedules');
        console.log('   • View fuel logs');
        console.log('   • Generate reports');
        console.log('   • View analytics dashboard\n');

        console.log('='.repeat(80));
        console.log('\n🚀 HOW TO USE:\n');
        console.log('1. Login with admin credentials');
        console.log('2. Get JWT token from login endpoint');
        console.log('3. Use token in Authorization header: Bearer <token>');
        console.log('4. Access all endpoints with admin privileges');
        console.log('5. Create additional users as needed\n');

        console.log('='.repeat(80));
        console.log('\n📝 API ENDPOINTS:\n');
        console.log('POST   /api/auth/login              → Login and get token');
        console.log('POST   /api/auth/register           → Create new users');
        console.log('GET    /api/vehicles                → View all vehicles');
        console.log('POST   /api/vehicles                → Create vehicle');
        console.log('GET    /api/drivers                 → View all drivers');
        console.log('POST   /api/drivers                 → Create driver');
        console.log('GET    /api/trips                   → View all trips');
        console.log('POST   /api/trips                   → Create trip\n');

        console.log('='.repeat(80) + '\n');

        process.exit(0);

    } catch (error) {
        console.error('❌ Error seeding database:', error);
        process.exit(1);
    } finally {
        await prisma.$disconnect();
    }
};
// Run seed
seedUsers();
