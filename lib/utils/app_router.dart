import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoading = authProvider.isLoading;
        final isInitial = authProvider.state == AuthState.initial;
        
        // Show loading while checking auth state
        if (isInitial || isLoading) {
          return null; // Let the current route load
        }
        
        final isAuthRoute = state.matchedLocation.startsWith('/auth');
        
        // If not authenticated and not on auth route, go to login
        if (!isAuthenticated && !isAuthRoute) {
          return '/auth/login';
        }
        
        // If authenticated and on auth route, go to dashboard
        if (isAuthenticated && isAuthRoute) {
          return '/dashboard';
        }
        
        // If authenticated and on root, go to dashboard
        if (isAuthenticated && state.matchedLocation == '/') {
          return '/dashboard';
        }
        
        return null;
      },
      routes: [
        // Root route
        GoRoute(
          path: '/',
          builder: (context, state) {
            return Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.state == AuthState.initial) {
                  return const _LoadingScreen();
                }
                
                if (authProvider.isAuthenticated) {
                  return const DashboardScreen();
                } else {
                  return const LoginScreen();
                }
              },
            );
          },
        ),
        
        // Auth routes
        GoRoute(
          path: '/auth/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/auth/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        
        // Protected routes
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
      ],
      errorBuilder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Halaman tidak ditemukan: ${state.matchedLocation}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Kembali ke Beranda'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 24),
            Text(
              'Memuat aplikasi...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}