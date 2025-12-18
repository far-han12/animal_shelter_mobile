import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/status_badge.dart';
import 'package:mobile/features/user/user_service.dart';
import 'package:intl/intl.dart';

class MyAdoptionsScreen extends ConsumerStatefulWidget {
  const MyAdoptionsScreen({super.key});

  @override
  ConsumerState<MyAdoptionsScreen> createState() => _MyAdoptionsScreenState();
}

class _MyAdoptionsScreenState extends ConsumerState<MyAdoptionsScreen> {
  String _statusFilter = '';

  @override
  Widget build(BuildContext context) {
    final adoptionsAsync = ref.watch(myAdoptionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Applications')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _statusFilter,
                  isExpanded: true,
                  hint: const Text('Filter by Status'),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('All Statuses')),
                    DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
                    DropdownMenuItem(
                      value: 'APPROVED',
                      child: Text('Approved'),
                    ),
                    DropdownMenuItem(
                      value: 'REJECTED',
                      child: Text('Rejected'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _statusFilter = v ?? ''),
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.refresh(myAdoptionsProvider),
              child: adoptionsAsync.when(
                data: (data) {
                  final filtered = _statusFilter.isEmpty
                      ? data
                      : data
                            .where((a) => a['status'] == _statusFilter)
                            .toList();
                  return _buildList(filtered);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<dynamic> apps) {
    if (apps.isEmpty) {
      return const Center(child: Text('No adoption applications found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        final pet = app['petId'] ?? {};
        final submittedBy = pet['submittedByUserId'];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Application for ${pet['name'] ?? 'Unknown Pet'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                  'Applied on ${DateFormat.yMMMd().format(DateTime.parse(app['createdAt']))}',
                  style: const TextStyle(color: AppTheme.mutedForegroundColor),
                ),
                if (app['adminNote'] != null &&
                    app['adminNote'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Admin Note: ${app['adminNote']}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
                if (app['status'] == 'APPROVED') ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[100]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Contact Details for Adoption',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Name: ${submittedBy?['name'] ?? 'Animal Shelter'}',
                        ),
                        Text(
                          'Email: ${submittedBy?['email'] ?? 'support@animalshelter.com'}',
                        ),
                        Text(
                          'Phone: ${submittedBy?['phone'] ?? '+880 1700 000000'}',
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'APPROVED') return AppTheme.successColor;
    if (status == 'REJECTED') return AppTheme.destructiveColor;
    return Colors.orange;
  }
}
