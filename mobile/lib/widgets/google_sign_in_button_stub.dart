import 'package:flutter/material.dart';

Widget buildGoogleSignInButton({required VoidCallback onPressed}) =>
    OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.g_mobiledata, size: 25),
      label: const Text('Continue with Google'),
    );
