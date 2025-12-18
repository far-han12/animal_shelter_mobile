import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/status_badge.dart';
import 'package:mobile/features/admin/applications/adoption_service.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';

class AdoptionDetailScreen extends ConsumerStatefulWidget {
  final dynamic application;
  const AdoptionDetailScreen({super.key, required this.application});

  @override
  ConsumerState<AdoptionDetailScreen> createState() =>
      _AdoptionDetailScreenState();
}

class _AdoptionDetailScreenState extends ConsumerState<AdoptionDetailScreen> {
  late dynamic _app;

  @override
  void initState() {
    super.initState();
    _app = widget.application;
  }

  @override
  Widget build(BuildContext context) {
    final pet = _app['petId'];
    final user = _app['userId'];
    final info = _app['applicantInfo'];

    return Scaffold(
      appBar: AppBar(title: const Text('Adoption Application')),
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
                    'For: ${pet?['name'] ?? 'Unknown Pet'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                StatusBadge(
                  text: _app['status'],
                  color: _getStatusColor(_app['status']),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Pet Information'),
            _buildPetInfoCard(pet),
            const SizedBox(height: 24),
            _buildSectionTitle('Applicant Information'),
            _buildUserInfoCard(user),
            const SizedBox(height: 24),
            _buildSectionTitle('Application Details'),
            _buildDetailsCard(info),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: _buildBottomActions(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildPetInfoCard(dynamic pet) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.pets, color: AppTheme.primaryColor),
        title: Text(pet?['name'] ?? 'Unknown'),
        subtitle: Text(
          '${pet?['species'] ?? 'N/A'} • ${pet?['breed'] ?? 'N/A'}',
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(dynamic user) {
    if (user == null)
      return const Card(
        child: ListTile(title: Text('User details not available')),
      );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(
              Icons.person_outline,
              'Name',
              user['name'] ?? 'Unknown',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.email_outlined,
              'Email',
              user['email'] ?? 'N/A',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.phone_outlined,
              'Phone',
              user['phone'] ?? 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(dynamic info) {
    if (info == null)
      return const Card(child: ListTile(title: Text('No details provided')));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailSection('Address', info['address']),
            const Divider(height: 24),
            _buildDetailSection('Experience', info['experience']),
            const Divider(height: 24),
            _buildDetailSection('Household Information', info['householdInfo']),
            const Divider(height: 24),
            _buildDetailSection('Notes', info['notes'] ?? 'No notes provided'),
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
        Column(
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
      ],
    );
  }

  Widget _buildDetailSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.mutedForegroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(height: 1.5)),
      ],
    );
  }

  Widget _buildBottomActions() {
    if (_app['status'] != 'PENDING') return const SizedBox.shrink();

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
          .read(adoptionServiceProvider)
          .updateAdoptionStatus(_app['_id'], status);
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
