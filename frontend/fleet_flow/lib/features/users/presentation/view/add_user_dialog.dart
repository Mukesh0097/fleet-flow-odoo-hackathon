import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:fleet_flow/features/users/presentation/provider/user_provider.dart';
import 'package:fleet_flow/common/widgets/app_toast.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  String? _selectedRole;

  final List<String> _roles = [
    'FLEET_MANAGER',
    'DISPATCHER',
    'SAFETY_OFFICER',
    'FINANCIAL_ANALYST',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _selectedRole != null) {
      final provider = context.read<UserProvider>();

      final success = await provider.registerUser(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
        _selectedRole!,
      );

      if (success) {
        if (mounted) {
          AppToast.success('User registered successfully');
          Navigator.pop(context);
        }
      }
    } else if (_selectedRole == null) {
      AppToast.error('Please select a role');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Add New User'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InfoLabel(
                label: 'Name',
                child: TextFormBox(
                  controller: _nameController,
                  placeholder: 'Full Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              InfoLabel(
                label: 'Email',
                child: TextFormBox(
                  controller: _emailController,
                  placeholder: 'Email address',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              InfoLabel(
                label: 'Password',
                child: TextFormBox(
                  controller: _passwordController,
                  placeholder: 'Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              InfoLabel(
                label: 'Role',
                child: ComboBox<String>(
                  isExpanded: true,
                  placeholder: const Text('Select a role'),
                  value: _selectedRole,
                  items: _roles
                      .map((e) => ComboBoxItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(onPressed: _submit, child: const Text('Add User')),
      ],
    );
  }
}
