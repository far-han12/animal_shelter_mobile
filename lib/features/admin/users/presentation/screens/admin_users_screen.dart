import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/widgets/status_badge.dart';
import 'package:mobile/features/admin/widgets/admin_scaffold.dart';
import 'package:mobile/features/admin/users/user_service.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';

final usersProvider = FutureProvider.family<Map<String, dynamic>, String>((
  ref,
  token,
) async {
  // Parse token: "page|search|role"
  final parts = token.split('|');
  final page = int.tryParse(parts[0]) ?? 1;
  final search = parts[1].isEmpty ? null : parts[1];
  final role = parts[2].isEmpty ? null : parts[2];

  return ref
      .watch(userServiceProvider)
      .getUsers(page: page, search: search, role: role);
});

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  int _currentPage = 1;
  String _search = '';
  String? _role;
  final _searchController = TextEditingController();

  void _onSearch() {
    setState(() {
      _search = _searchController.text.trim();
      _currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(
      usersProvider('$_currentPage|$_search|${_role ?? ''}'),
    );

    return AdminScaffold(
      title: 'User Management',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearch();
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (_) => _onSearch(),
                    onChanged: (val) {
                      if (val.isEmpty) _onSearch();
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String?>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (val) => setState(() {
                    _role = val;
                    _currentPage = 1;
                  }),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: null, child: Text('All Roles')),
                    const PopupMenuItem(value: 'ADMIN', child: Text('Admins')),
                    const PopupMenuItem(value: 'USER', child: Text('Users')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.refresh(
                usersProvider('$_currentPage|$_search|${_role ?? ''}'),
              ),
              child: usersAsync.when(
                data: (data) => _buildList(data),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(Map<String, dynamic> data) {
    final List<dynamic> users = data['data'];
    final meta = data['meta'];

    if (users.isEmpty) {
      return const Center(child: Text('No users found.'));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(
                  user['name'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  user['email'],
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StatusBadge(
                      text: user['role'],
                      color: user['role'] == 'ADMIN'
                          ? Colors.blue
                          : Colors.orange,
                    ),
                    if (user['isDisabled'] == true) ...[
                      const SizedBox(width: 4),
                      const StatusBadge(text: 'Disabled', color: Colors.red),
                    ],
                  ],
                ),
                onTap: () => _showUserActions(user),
              );
            },
          ),
        ),
        _buildPagination(meta),
      ],
    );
  }

  Widget _buildPagination(dynamic meta) {
    final totalPages = meta['totalPages'];
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 1
                ? () => setState(() => _currentPage--)
                : null,
          ),
          Text('Page $_currentPage of $totalPages'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < totalPages
                ? () => setState(() => _currentPage++)
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _showUserActions(dynamic user) async {
    final result = await showModalActionSheet<String>(
      context: context,
      title: 'Action for ${user['name']}',
      actions: [
        const SheetAction(label: 'Change Role', key: 'ROLE'),
        SheetAction(
          label: user['isDisabled'] == true ? 'Enable User' : 'Disable User',
          key: 'TOGGLE_DISABLE',
          isDestructiveAction: user['isDisabled'] != true,
        ),
        const SheetAction(
          label: 'Delete User',
          key: 'DELETE',
          isDestructiveAction: true,
        ),
      ],
    );

    if (result == null) return;

    final userService = ref.read(userServiceProvider);

    try {
      if (result == 'ROLE') {
        final newRole = await showModalActionSheet<String>(
          context: context,
          title: 'Select Role',
          actions: [
            const SheetAction(label: 'ADMIN', key: 'ADMIN'),
            const SheetAction(label: 'USER', key: 'USER'),
          ],
        );
        if (newRole != null) {
          await userService.updateUser(user['_id'], {'role': newRole});
        }
      } else if (result == 'TOGGLE_DISABLE') {
        await userService.updateUser(user['_id'], {
          'isDisabled': !(user['isDisabled'] ?? false),
        });
      } else if (result == 'DELETE') {
        final ok = await showOkCancelAlertDialog(
          context: context,
          title: 'Confirm Delete',
          message: 'Are you sure you want to delete this user?',
          isDestructiveAction: true,
        );
        if (ok == OkCancelResult.ok) {
          await userService.deleteUser(user['_id']);
        }
      }

      ref.invalidate(usersProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Action failed: $e')));
      }
    }
  }
}
