import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/status_badge.dart';
import 'package:mobile/features/admin/widgets/admin_scaffold.dart';
import 'package:mobile/features/admin/volunteers/volunteer_service.dart';
import 'package:mobile/features/admin/volunteers/presentation/screens/volunteer_detail_screen.dart';

final adminVolunteersProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, page) async {
      return ref.watch(volunteerServiceProvider).getVolunteers(page: page);
    });

class AdminVolunteersScreen extends ConsumerStatefulWidget {
  const AdminVolunteersScreen({super.key});

  @override
  ConsumerState<AdminVolunteersScreen> createState() =>
      _AdminVolunteersScreenState();
}

class _AdminVolunteersScreenState extends ConsumerState<AdminVolunteersScreen> {
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final volunteersAsync = ref.watch(adminVolunteersProvider(_currentPage));

    return AdminScaffold(
      title: 'Volunteer Applications',
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.refresh(adminVolunteersProvider(_currentPage)),
        child: volunteersAsync.when(
          data: (data) => _buildList(data),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildList(Map<String, dynamic> data) {
    final List<dynamic> volunteers = data['data'];
    final meta = data['meta'];

    if (volunteers.isEmpty)
      return const Center(child: Text('No volunteer applications found.'));

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: volunteers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final vol = volunteers[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () async {
                    final refresh = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VolunteerDetailScreen(volunteer: vol),
                      ),
                    );
                    if (refresh == true) {
                      ref.invalidate(adminVolunteersProvider);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              vol['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            StatusBadge(
                              text: vol['status'],
                              color: _getStatusColor(vol['status']),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Email: ${vol['email']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Phone: ${vol['phone']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Interests: ${(vol['interests'] as List?)?.join(', ') ?? 'None'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.mutedForegroundColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        _buildPagination(meta),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return AppTheme.successColor;
      case 'REJECTED':
        return AppTheme.destructiveColor;
      default:
        return AppTheme.mutedForegroundColor;
    }
  }

  Widget _buildPagination(dynamic meta) {
    final totalPages = meta['totalPages'] ?? 1;
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
}
