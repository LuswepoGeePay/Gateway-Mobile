import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class AuthenticationWrapper extends StatefulWidget {
  final Widget loginPage;
  final Widget homePage;

  const AuthenticationWrapper({
    super.key,
    required this.loginPage,
    required this.homePage,
  });

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  final storage = GetStorage();
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = storage.read("token");
    final isLoggedIn = storage.read("isLoggedIn") ?? false;
    setState(() {
      _isAuthenticated = token != null && token.isNotEmpty && isLoggedIn;
    });
  }

  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Get saved token
  Future<String?> getAuthToken() async {
    // ignore: await_only_futures
    return await storage.read("token");
  }

  @override
  Widget build(BuildContext context) {
    return _isAuthenticated ? widget.homePage : widget.loginPage;
  }
}
