import 'package:fluent_ui/fluent_ui.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFilled;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFilled = true,
  });

  @override
  Widget build(BuildContext context) {
    final Widget child = isLoading
        ? const SizedBox(
            height: 16,
            width: 16,
            child: ProgressRing(strokeWidth: 2),
          )
        : Text(text);

    return isFilled
        ? FilledButton(onPressed: isLoading ? null : onPressed, child: child)
        : Button(onPressed: isLoading ? null : onPressed, child: child);
  }
}
