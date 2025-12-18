import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/status_badge.dart';
import 'package:mobile/features/admin/widgets/admin_scaffold.dart';
import 'package:mobile/features/admin/applications/adoption_service.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';

final adminInquiriesProvider = FutureProvider.family<Map<String, dynamic>, int>(
  (ref, page) async {
    return ref.watch(adoptionServiceProvider).getInquiries(page: page);
  },
);

class AdminInquiriesScreen extends ConsumerStatefulWidget {
  const AdminInquiriesScreen({super.key});

  @override
  ConsumerState<AdminInquiriesScreen> createState() =>
      _AdminInquiriesScreenState();
}

class _AdminInquiriesScreenState extends ConsumerState<AdminInquiriesScreen> {
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final inquiriesAsync = ref.watch(adminInquiriesProvider(_currentPage));

    return AdminScaffold(
      title: 'Adoption Inquiries',
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.refresh(adminInquiriesProvider(_currentPage)),
        child: inquiriesAsync.when(
          data: (data) => _buildList(data),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildList(Map<String, dynamic> data) {
    final List<dynamic> inquiries = data['data'];
    final meta = data['meta'];

    if (inquiries.isEmpty)
      return const Center(child: Text('No inquiries found.'));

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: inquiries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final inquiry = inquiries[index];
              return Card(
                child: ListTile(
                  title: Text(
                    inquiry['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inquiry['email'],
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        inquiry['message'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  trailing: StatusBadge(
                    text: inquiry['status'],
                    color: _getStatusColor(inquiry['status']),
                  ),
                  isThreeLine: true,
                  onTap: () => _showActions(inquiry),
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
      case 'NEW':
        return Colors.blue;
      case 'CONTACTED':
        return Colors.orange;
      case 'CLOSED':
        return AppTheme.successColor;
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

  Future<void> _showActions(dynamic inquiry) async {
    final result = await showModalActionSheet<String>(
      context: context,
      title: 'Update Status',
      actions: [
        const SheetAction(label: 'NEW', key: 'NEW'),
        const SheetAction(label: 'CONTACTED', key: 'CONTACTED'),
        const SheetAction(label: 'CLOSED', key: 'CLOSED'),
      ],
    );

    if (result == null) return;

    try {
      await ref
          .read(adoptionServiceProvider)
          .updateInquiryStatus(inquiry['_id'], result);
      ref.invalidate(adminInquiriesProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }
}
