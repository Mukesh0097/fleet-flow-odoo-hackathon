# fleet_flow

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### API base URL

The frontend reads the backend API base URL from `Constants.baseurl`. To point the app to your local backend, update the value in [frontend/fleet_flow/lib/core/constants/constants.dart](frontend/fleet_flow/lib/core/constants/constants.dart#L1-L3).

Example — set to a local backend running on port 3000:

```dart
class Constants {
	static const String baseurl = 'http://localhost:3000';
}
```

If you are using a remote host or tunnel (e.g., ngrok / devtunnels), replace the value with the full host (including `http://` or `https://`).
