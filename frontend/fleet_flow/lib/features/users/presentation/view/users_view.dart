import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:fleet_flow/features/users/presentation/provider/user_provider.dart';
import 'package:fleet_flow/features/users/presentation/view/add_user_dialog.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUsers();
    });
  }

  void _showAddUserDialog() {
    showDialog(context: context, builder: (context) => const AddUserDialog());
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: const Text('System Users'),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarBuilderItem(
              builder: (context, mode, w) => w,
              wrappedItem: CommandBarButton(
                icon: const Icon(FluentIcons.add),
                label: const Text('Add User'),
                onPressed: _showAddUserDialog,
              ),
            ),
          ],
        ),
      ),
      content: Consumer<UserProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.users.isEmpty) {
            return const Center(child: ProgressRing());
          }

          if (provider.errorMessage != null && provider.users.isEmpty) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: TextStyle(color: Colors.red.normal),
              ),
            );
          }

          if (provider.users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: provider.users.length,
            itemBuilder: (context, index) {
              final user = provider.users[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  title: Text(
                    user.name.isNotEmpty ? user.name : 'Unknown User',
                  ),
                  subtitle: Text(user.email),
                  trailing: Text(
                    user.role,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getRoleColor(user.role),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'FLEET_MANAGER':
        return Colors.blue.darkest;
      case 'DISPATCHER':
        return Colors.orange.darkest;
      case 'SAFETY_OFFICER':
        return Colors.green.darkest;
      case 'FINANCIAL_ANALYST':
        return Colors.purple.darkest;
      default:
        return Colors.grey;
    }
  }
}
