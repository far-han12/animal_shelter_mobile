import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/auth_notifier.dart';
import 'package:mobile/core/widgets/payment_webview.dart';

import 'package:mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:mobile/features/auth/presentation/screens/register_screen.dart';

import 'package:mobile/features/admin/dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'package:mobile/features/admin/users/presentation/screens/admin_users_screen.dart';
import 'package:mobile/features/admin/pets/presentation/screens/admin_pets_screen.dart';
import 'package:mobile/features/admin/applications/presentation/screens/admin_inquiries_screen.dart';
import 'package:mobile/features/admin/volunteers/presentation/screens/admin_volunteers_screen.dart';
import 'package:mobile/features/admin/donations/presentation/screens/admin_donations_screen.dart';
import 'package:mobile/features/admin/applications/presentation/screens/admin_applications_screen.dart';
import 'package:mobile/features/admin/stories/presentation/screens/admin_stories_screen.dart';
import 'package:mobile/features/admin/events/presentation/screens/admin_events_screen.dart';
import 'package:mobile/features/admin/donations/presentation/screens/donate_screen.dart';
import 'package:mobile/features/pets/presentation/screens/user_dashboard_screen.dart';
import 'package:mobile/features/home/presentation/screens/home_screen.dart';
import 'package:mobile/features/home/presentation/screens/volunteer_screen.dart';
import 'package:mobile/features/home/presentation/screens/public_stories_screen.dart';
import 'package:mobile/features/home/presentation/screens/public_story_detail_screen.dart';
import 'package:mobile/features/home/presentation/screens/public_events_screen.dart';
import 'package:mobile/features/pets/presentation/screens/public_pet_detail_screen.dart';
import 'package:mobile/features/pets/presentation/screens/public_pets_screen.dart';
import 'package:mobile/features/pets/data/pet_model.dart';

import 'package:mobile/features/user/presentation/screens/profile_screen.dart';
import 'package:mobile/features/user/presentation/screens/submit_pet_screen.dart';
import 'package:mobile/features/user/presentation/screens/my_submissions_screen.dart';
import 'package:mobile/features/user/presentation/screens/edit_submission_screen.dart';
import 'package:mobile/features/user/presentation/screens/my_adoptions_screen.dart';
import 'package:mobile/features/user/presentation/screens/my_donations_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      final isHome = state.matchedLocation == '/';

      if (!authState.isAuthenticated) {
        if (isLoggingIn || isRegistering || isHome) return null;
        final publicRoutes = [
          '/volunteer',
          '/pets',
          '/stories',
          '/events',
          '/donate',
        ];
        final isPublic = publicRoutes.any(
          (route) => state.matchedLocation.startsWith(route),
        );
        if (isPublic) return null;
        return '/';
      }

      if (isLoggingIn || isRegistering) {
        return authState.role == 'ADMIN'
            ? '/admin/dashboard'
            : '/user/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: '/admin/pets',
        builder: (context, state) => const AdminPetsScreen(),
      ),
      GoRoute(
        path: '/admin/inquiries',
        builder: (context, state) => const AdminInquiriesScreen(),
      ),
      GoRoute(
        path: '/admin/applications',
        builder: (context, state) => const AdminApplicationsScreen(),
      ),
      GoRoute(
        path: '/admin/volunteers',
        builder: (context, state) => const AdminVolunteersScreen(),
      ),
      GoRoute(
        path: '/admin/donations',
        builder: (context, state) => const AdminDonationsScreen(),
      ),
      GoRoute(
        path: '/admin/stories',
        builder: (context, state) => const AdminStoriesScreen(),
      ),
      GoRoute(
        path: '/admin/events',
        builder: (context, state) => const AdminEventsScreen(),
      ),
      GoRoute(
        path: '/admin/donate',
        builder: (context, state) => const DonateScreen(),
      ),
      GoRoute(
        path: '/pets',
        builder: (context, state) => const PublicPetsScreen(),
      ),
      GoRoute(
        path: '/pets/:id',
        builder: (context, state) {
          final pet = state.extra as Pet?;
          if (pet != null) return PublicPetDetailScreen(pet: pet);
          return const Scaffold(body: Center(child: Text('Pet not found')));
        },
      ),
      GoRoute(
        path: '/stories',
        builder: (context, state) => const PublicStoriesScreen(),
      ),
      GoRoute(
        path: '/stories/detail',
        builder: (context, state) {
          final story = state.extra;
          return PublicStoryDetailScreen(story: story);
        },
      ),
      GoRoute(
        path: '/events',
        builder: (context, state) => const PublicEventsScreen(),
      ),
      GoRoute(
        path: '/volunteer',
        builder: (context, state) => const VolunteerScreen(),
      ),
      GoRoute(
        path: '/donate',
        builder: (context, state) => const DonateScreen(),
      ),
      GoRoute(
        path: '/user/dashboard',
        builder: (context, state) => const UserDashboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/submit-pet',
        builder: (context, state) => const SubmitPetScreen(),
      ),
      GoRoute(
        path: '/my-submissions',
        builder: (context, state) => const MySubmissionsScreen(),
      ),
      GoRoute(
        path: '/my-submissions/edit',
        builder: (context, state) {
          final pet = state.extra as Map<String, dynamic>;
          return EditSubmissionScreen(pet: pet);
        },
      ),
      GoRoute(
        path: '/my-adoptions',
        builder: (context, state) => const MyAdoptionsScreen(),
      ),
      GoRoute(
        path: '/donations/my',
        builder: (context, state) => const MyDonationsScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PaymentWebView(
            initialUrl: extra['url'],
            title: extra['title'] ?? 'Payment',
          );
        },
      ),
    ],
  );
});
