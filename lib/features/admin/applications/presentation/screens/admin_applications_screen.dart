import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/status_badge.dart';
import 'package:mobile/features/admin/widgets/admin_scaffold.dart';
import 'package:mobile/features/admin/applications/adoption_service.dart';
import 'package:mobile/features/admin/applications/presentation/screens/adoption_detail_screen.dart';

final adminApplicationsProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, page) async {
      return ref.watch(adoptionServiceProvider).getAdoptions(page: page);
    });

class AdminApplicationsScreen extends ConsumerStatefulWidget {
  const AdminApplicationsScreen({super.key});

  @override
  ConsumerState<AdminApplicationsScreen> createState() =>
      _AdminApplicationsScreenState();
}

class _AdminApplicationsScreenState
    extends ConsumerState<AdminApplicationsScreen> {
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final applicationsAsync = ref.watch(
      adminApplicationsProvider(_currentPage),
    );

    return AdminScaffold(
      title: 'Adoption Applications',
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.refresh(adminApplicationsProvider(_currentPage)),
        child: applicationsAsync.when(
          data: (data) => _buildList(data),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildList(Map<String, dynamic> data) {
    final List<dynamic> applications = data['data'];
    final meta = data['meta'];

    if (applications.isEmpty)
      return const Center(child: Text('No applications found.'));

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final app = applications[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () async {
                    final refresh = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AdoptionDetailScreen(application: app),
                      ),
                    );
                    if (refresh == true) {
                      ref.invalidate(adminApplicationsProvider);
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
                              'For: ${app['petId']?['name'] ?? 'Unknown Pet'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            StatusBadge(
                              text: app['status'],
                              color: _getStatusColor(app['status']),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Applicant: ${app['userId']?['name'] ?? 'Unknown'}',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Address: ${app['applicantInfo']?['address'] ?? 'N/A'}',
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
