import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/admin/widgets/admin_drawer.dart';
import 'package:mobile/features/auth/auth_notifier.dart';
import 'package:mobile/features/home/presentation/widgets/home_drawer.dart';

class AdminScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  const AdminScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.isAuthenticated && authState.role == 'ADMIN';

    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      drawer: isAdmin ? const AdminDrawer() : const HomeDrawer(),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
