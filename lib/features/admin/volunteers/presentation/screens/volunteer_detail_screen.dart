import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/status_badge.dart';
import 'package:mobile/features/admin/volunteers/volunteer_service.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';

class VolunteerDetailScreen extends ConsumerStatefulWidget {
  final dynamic volunteer;
  const VolunteerDetailScreen({super.key, required this.volunteer});

  @override
  ConsumerState<VolunteerDetailScreen> createState() =>
      _VolunteerDetailScreenState();
}

class _VolunteerDetailScreenState extends ConsumerState<VolunteerDetailScreen> {
  late dynamic _vol;

  @override
  void initState() {
    super.initState();
    _vol = widget.volunteer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Application Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _vol['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                StatusBadge(
                  text: _vol['status'],
                  color: _getStatusColor(_vol['status']),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildContentSection('Availability', _vol['availability']),
            _buildContentSection(
              'Interests',
              (_vol['interests'] as List?)?.join(', ') ?? 'None',
            ),
            _buildContentSection('Notes', _vol['notes'] ?? 'No notes provided'),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: _buildBottomActions(),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(Icons.email_outlined, 'Email', _vol['email']),
            const Divider(height: 24),
            _buildInfoRow(Icons.phone_outlined, 'Phone', _vol['phone']),
            if (_vol['address'] != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                Icons.location_on_outlined,
                'Address',
                _vol['address'],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.mutedForegroundColor,
                ),
              ),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.mutedColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(content, style: const TextStyle(height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    if (_vol['status'] != 'PENDING') return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _handleAction('REJECTED'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.destructiveColor,
                side: const BorderSide(color: AppTheme.destructiveColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Reject Application'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _handleAction('APPROVED'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Approve Application'),
            ),
          ),
        ],
      ),
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

  Future<void> _handleAction(String status) async {
    final ok = await showOkCancelAlertDialog(
      context: context,
      title: 'Confirm $status',
      message: 'Are you sure you want to mark this application as $status?',
      okLabel: status,
      isDestructiveAction: status == 'REJECTED',
    );

    if (ok != OkCancelResult.ok) return;

    try {
      await ref
          .read(volunteerServiceProvider)
          .updateVolunteerStatus(_vol['_id'], status);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }
}
