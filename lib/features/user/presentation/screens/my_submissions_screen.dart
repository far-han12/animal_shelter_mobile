import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/status_badge.dart';
import 'package:mobile/features/user/user_service.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class MySubmissionsScreen extends ConsumerWidget {
  const MySubmissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(mySubmissionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Submissions')),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(mySubmissionsProvider),
        child: submissionsAsync.when(
          data: (submissions) => _buildList(context, ref, submissions),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> submissions,
  ) {
    if (submissions.isEmpty) {
      return const Center(child: Text('You haven\'t submitted any pets yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        final pet = submissions[index];
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
                    Text(
                      pet['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    StatusBadge(
                      text: pet['status'],
                      color: _getStatusColor(pet['status']),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${pet['species']} • ${pet['breed']}'),
                Text(
                  'Submitted on ${DateFormat.yMMMd().format(DateTime.parse(pet['createdAt']))}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.mutedForegroundColor,
                  ),
                ),
                if (pet['adminNotes'] != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Admin Note: ${pet['adminNotes']}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (pet['status'] == 'PENDING_REVIEW')
                      TextButton(
                        onPressed: () =>
                            _confirmWithdraw(context, ref, pet['_id']),
                        child: const Text(
                          'Withdraw',
                          style: TextStyle(color: AppTheme.destructiveColor),
                        ),
                      ),
                    const SizedBox(width: 8),
                    if (pet['status'] == 'PENDING_REVIEW' ||
                        pet['status'] == 'REJECTED') ...[
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          context.push('/my-submissions/edit', extra: pet);
                        },
                        child: const Text('Edit'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'AVAILABLE':
      case 'APPROVED':
        return AppTheme.successColor;
      case 'PENDING_REVIEW':
        return Colors.orange;
      case 'REJECTED':
        return AppTheme.destructiveColor;
      case 'ADOPTED':
        return Colors.blue;
      default:
        return AppTheme.mutedForegroundColor;
    }
  }

  void _confirmWithdraw(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Submission'),
        content: const Text(
          'Are you sure you want to withdraw this submission?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(userServiceProvider).withdrawSubmission(id);
                ref.refresh(mySubmissionsProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text(
              'Withdraw',
              style: TextStyle(color: AppTheme.destructiveColor),
            ),
          ),
        ],
      ),
    );
  }
}
