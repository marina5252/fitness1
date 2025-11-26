import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voicepump/features/auth/presentation/screens/login_screen.dart';
import 'package:voicepump/features/auth/presentation/screens/register_screen.dart';
import 'package:voicepump/features/home/presentation/screens/home_screen.dart';
import 'package:voicepump/features/trainings/presentation/screens/schedule_screen.dart';
import 'package:voicepump/features/trainings/presentation/screens/training_detail_screen.dart';
import 'package:voicepump/features/subscriptions/presentation/screens/subscriptions_screen.dart';
import 'package:voicepump/features/profile/presentation/screens/profile_screen.dart';
import 'package:voicepump/features/news/presentation/screens/news_screen.dart';
import 'package:voicepump/features/voice_assistant/presentation/screens/voice_assistant_screen.dart';
import 'package:voicepump/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:voicepump/features/admin/presentation/screens/admin_trainings_screen.dart';
import 'package:voicepump/features/admin/presentation/screens/admin_news_screen.dart';
import 'package:voicepump/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoginRoute = state.matchedLocation == '/login' || 
                          state.matchedLocation == '/register';
      
      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }
      
      if (isLoggedIn && isLoginRoute) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: '/training/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TrainingDetailScreen(trainingId: id);
        },
      ),
      GoRoute(
        path: '/subscriptions',
        builder: (context, state) => const SubscriptionsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/news',
        builder: (context, state) => const NewsScreen(),
      ),
      GoRoute(
        path: '/voice-assistant',
        builder: (context, state) => const VoiceAssistantScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/trainings',
        builder: (context, state) => const AdminTrainingsScreen(),
      ),
      GoRoute(
        path: '/admin/news',
        builder: (context, state) => const AdminNewsScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUsersScreen(),
      ),
    ],
  );
});

// Provider для отслеживания состояния аутентификации
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

