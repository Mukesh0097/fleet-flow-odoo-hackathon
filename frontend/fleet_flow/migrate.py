import os
import shutil
import re

package_name = "fleet_flow"
base_dir = "/home/kazuha/Documents/odoo_hackathon/fleet-flow-odoo-hackathon/frontend/fleet_flow"
lib_dir = os.path.join(base_dir, "lib")

move_map = {
    'lib/theme/app_theme.dart': 'lib/core/themes/app_theme.dart',
    'lib/services/api_service.dart': 'lib/core/services/api_services.dart',
    'lib/router/app_router.dart': 'lib/route_generator.dart',
    
    'lib/repositories/auth_repository.dart': 'lib/features/auth/data/repository/auth_repository.dart',
    'lib/providers/auth_provider.dart': 'lib/features/auth/presentation/provider/auth_provider.dart',
    'lib/screens/login_screen.dart': 'lib/features/auth/presentation/view/login_view.dart',
    
    'lib/providers/driver_provider.dart': 'lib/features/driver/presentation/provider/driver_provider.dart',
    'lib/screens/driver_profiles_screen.dart': 'lib/features/driver/presentation/view/driver_profiles_view.dart',
    
    'lib/providers/fleet_provider.dart': 'lib/features/fleet/presentation/provider/fleet_provider.dart',
    'lib/screens/vehicle_registry_screen.dart': 'lib/features/fleet/presentation/view/vehicle_registry_view.dart',
    'lib/screens/maintenance_logs_screen.dart': 'lib/features/fleet/presentation/view/maintenance_logs_view.dart',
    
    'lib/providers/trip_provider.dart': 'lib/features/trip/presentation/provider/trip_provider.dart',
    'lib/screens/trip_dispatcher_screen.dart': 'lib/features/trip/presentation/view/trip_dispatcher_view.dart',
    
    'lib/screens/analytics_reports_screen.dart': 'lib/features/analytics/presentation/view/analytics_reports_view.dart',
    'lib/screens/expense_fuel_screen.dart': 'lib/features/expense/presentation/view/expense_fuel_view.dart',
    
    'lib/screens/command_center_screen.dart': 'lib/features/dashboard/presentation/view/command_center_view.dart',
    'lib/screens/main_navigation_view.dart': 'lib/features/dashboard/presentation/view/main_navigation_view.dart',
}

def resolve_path(current_file, imported_path):
    if imported_path.startswith("package:") or imported_path.startswith("dart:"): 
        return imported_path
    
    dir_name = os.path.dirname(current_file)
    abs_imported = os.path.normpath(os.path.join(dir_name, imported_path))
    
    try:
        rel_lib = os.path.relpath(abs_imported, lib_dir)
        if rel_lib.startswith(".."): return imported_path
        return f"package:{package_name}/{rel_lib}"
    except:
        return imported_path

def normalize_imports():
    for root, _, files in os.walk(lib_dir):
        for f in files:
            if not f.endswith(".dart"): continue
            file_path = os.path.join(root, f)
            with open(file_path, "r") as f_in:
                content = f_in.read()
            
            def repl(m):
                keyword = m.group(1)
                quote = m.group(2)
                imported = m.group(3)
                rest = m.group(4)
                new_path = resolve_path(file_path, imported)
                return f"{keyword}{quote}{new_path}{quote}{rest}"

            new_content = re.sub(r'^(\s*(?:import|export|part)\s+)([\'"])(.+?)([\'"].*)', repl, content, flags=re.MULTILINE)
            
            if new_content != content:
                with open(file_path, "w") as f_out:
                    f_out.write(new_content)

def update_package_imports():
    for root, _, files in os.walk(lib_dir):
        for f in files:
            if not f.endswith(".dart"): continue
            file_path = os.path.join(root, f)
            with open(file_path, "r") as f_in:
                content = f_in.read()
                
            for src, dst in move_map.items():
                old_pkg = src.replace('lib/', f'package:{package_name}/')
                new_pkg = dst.replace('lib/', f'package:{package_name}/')
                content = content.replace(old_pkg, new_pkg)
                
            with open(file_path, "w") as f_out:
                f_out.write(content)

if __name__ == "__main__":
    os.chdir(base_dir)
    normalize_imports()
    
    new_dirs = set(os.path.dirname(dst) for dst in move_map.values())
    new_dirs.update([
        'lib/common/models', 'lib/common/provider', 'lib/common/widgets',
        'lib/core/constants', 'lib/core/services', 'lib/core/themes', 'lib/core/utils',
    ])
    for d in new_dirs:
        os.makedirs(d, exist_ok=True)
        
    for src, dst in move_map.items():
        if os.path.exists(src):
            shutil.move(src, dst)
            
    update_package_imports()

    for d in ['lib/theme', 'lib/services', 'lib/router', 'lib/repositories', 'lib/providers', 'lib/screens']:
        d_path = os.path.join(base_dir, d)
        if os.path.exists(d_path):
            try:
                os.rmdir(d_path)
            except:
                pass
