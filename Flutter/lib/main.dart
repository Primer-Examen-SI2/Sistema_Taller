import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_cliente/core/theme/app_theme.dart';
import 'package:app_cliente/features/auth/application/auth_provider.dart';
import 'package:app_cliente/features/auth/presentation/login_screen.dart';
import 'package:app_cliente/features/auth/presentation/register_screen.dart';
import 'package:app_cliente/features/vehicles/presentation/vehicles_screen.dart';
import 'package:app_cliente/features/incident_report/presentation/report_screen.dart';
import 'package:app_cliente/features/tracking/presentation/tracking_screen.dart';
import 'package:app_cliente/features/chat/presentation/chat_screen.dart';
import 'package:app_cliente/features/incident_report/presentation/emergency_waiting_screen.dart';
import 'package:app_cliente/features/incident_report/application/incident_provider.dart';

// --- Auth redirect logic ---
final _authRedirectProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).status == AuthStatus.authenticated;
});

// --- Router ---
final _routerProvider = Provider<GoRouter>((ref) {
  final isAuth = ref.watch(_authRedirectProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoginRoute = state.matchedLocation == '/login';
      final isRegisterRoute = state.matchedLocation == '/register';
      final isWaitingRoute = state.matchedLocation.startsWith('/emergency-waiting');

      if (isAuth && (isLoginRoute || isRegisterRoute)) return '/home';
      if (!isAuth && !isLoginRoute && !isRegisterRoute && !isWaitingRoute) return '/login';
      return null;
    },
    routes: [
      // Auth routes (no shell)
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      // Emergency waiting (full screen, no shell)
      GoRoute(
        path: '/emergency-waiting/:id',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          final incident = ref.read(incidentProvider).incidents.where((i) => i.id == id).firstOrNull;
          if (incident == null) return const SizedBox();
          return EmergencyWaitingScreen(incident: incident);
        },
      ),
      // App routes (with bottom nav shell)
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/vehicles', builder: (_, __) => const VehiclesScreen()),
          GoRoute(path: '/report', builder: (_, __) => const ReportScreen()),
          GoRoute(path: '/tracking', builder: (_, __) => const TrackingScreen()),
          GoRoute(
            path: '/chat',
            builder: (_, state) => ChatScreen(
              tallerNombre: state.uri.queryParameters['taller'] ?? 'Taller',
            ),
          ),
        ],
      ),
    ],
  );
});

// --- Bottom Navigation Shell ---
class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    if (location == '/vehicles') {
      currentIndex = 1;
    } else if (location == '/report') {
      currentIndex = 2;
    } else if (location == '/tracking') {
      currentIndex = 3;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0: context.go('/home'); break;
            case 1: context.go('/vehicles'); break;
            case 2: context.go('/report'); break;
            case 3: context.go('/tracking'); break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.directions_car_outlined), selectedIcon: Icon(Icons.directions_car), label: 'Vehículos'),
          NavigationDestination(icon: Icon(Icons.warning_amber_outlined), selectedIcon: Icon(Icons.warning), label: 'Emergencia'),
          NavigationDestination(icon: Icon(Icons.track_changes_outlined), selectedIcon: Icon(Icons.track_changes), label: 'Solicitudes'),
        ],
      ),
    );
  }
}

// --- Home Screen ---
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema Taller'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo
            Text(
              '¡Hola, ${user?.username ?? "Usuario"}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('¿En qué podemos ayudarte hoy?', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 24),

            // Botón de emergencia
            GestureDetector(
              onTap: () => context.go('/report'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD32F2F), Color(0xFFFF6F00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFD32F2F).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                child: const Column(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 48, color: Colors.white),
                    SizedBox(height: 12),
                    Text('REPORTAR EMERGENCIA', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 4),
                    Text('Toca aquí para enviar tu ubicación y recibir ayuda', style: TextStyle(fontSize: 13, color: Colors.white70)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Accesos rápidos
            const Text('Accesos rápidos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                _QuickAction(
                  icon: Icons.directions_car,
                  label: 'Mis Vehículos',
                  color: Colors.blue,
                  onTap: () => context.go('/vehicles'),
                ),
                const SizedBox(width: 12),
                _QuickAction(
                  icon: Icons.track_changes,
                  label: 'Mis Solicitudes',
                  color: Colors.green,
                  onTap: () => context.go('/tracking'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _QuickAction(
                  icon: Icons.chat_outlined,
                  label: 'Chat Taller',
                  color: Colors.purple,
                  onTap: () => context.go('/chat?taller=Taller%20Mecánico'),
                ),
                const SizedBox(width: 12),
                _QuickAction(
                  icon: Icons.history,
                  label: 'Historial',
                  color: Colors.orange,
                  onTap: () => context.go('/tracking'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

// --- App Entry ---
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);

    return MaterialApp.router(
      title: 'Sistema Taller',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
