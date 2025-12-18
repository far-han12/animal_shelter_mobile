import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/status_badge.dart';
import 'package:mobile/features/admin/pets/pet_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:mobile/features/donations/donation_service.dart';
import 'package:mobile/features/auth/auth_notifier.dart';
import 'package:mobile/core/widgets/button.dart';
import 'package:mobile/core/widgets/payment_webview.dart';

class PetDetailScreen extends ConsumerStatefulWidget {
  final dynamic pet;
  const PetDetailScreen({super.key, required this.pet});

  @override
  ConsumerState<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends ConsumerState<PetDetailScreen> {
  late dynamic _pet;
  bool _isInitializingPayment = false;

  @override
  void initState() {
    super.initState();
    _pet = widget.pet;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pet['name'] ?? 'Pet Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _handleAction('DELETE'),
            color: AppTheme.destructiveColor,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageGallery(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _pet['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      StatusBadge(
                        text: _pet['status'],
                        color: _getStatusColor(_pet['status']),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_pet['species']} • ${_pet['breed']} • ${_pet['age']} years old',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.mutedForegroundColor,
                    ),
                  ),
                  const Divider(height: 32),
                  _buildSection('Description', _pet['description']),
                  _buildSection('Medical Notes', _pet['medicalNotes']),
                  _buildDetailRow('Size', _pet['size']),
                  _buildDetailRow('Gender', _pet['gender']),
                  _buildDetailRow(
                    'Special Needs',
                    _pet['specialNeeds'] == true ? 'Yes' : 'No',
                  ),
                  const Divider(height: 32),
                  _buildSubmitterInfo(),
                  const SizedBox(height: 16),
                  _buildOwnerContact(),
                  const SizedBox(height: 80), // Space for bottom actions
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomActions(),
    );
  }

  Widget _buildImageGallery() {
    final List<dynamic> photos = _pet['photos'] ?? [];
    if (photos.isEmpty) {
      return Container(
        height: 250,
        width: double.infinity,
        color: AppTheme.mutedColor,
        child: const Icon(
          Icons.pets,
          size: 64,
          color: AppTheme.mutedForegroundColor,
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: PageView.builder(
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: photos[index],
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Container(color: AppTheme.mutedColor),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, String? content) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.mutedForegroundColor),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSubmitterInfo() {
    final submitter = _pet['submittedByUserId'];
    if (submitter == null)
      return const Text(
        'Submitted by: Admin',
        style: TextStyle(fontStyle: FontStyle.italic),
      );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Submitted By',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text('Name: ${submitter['name'] ?? 'Unknown'}'),
        Text('Email: ${submitter['email'] ?? 'N/A'}'),
      ],
    );
  }

  Widget _buildOwnerContact() {
    final contact = _pet['ownerContact'];
    if (contact == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Owner Contact',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text('Name: ${contact['name'] ?? 'N/A'}'),
        if (contact['phone'] != null) Text('Phone: ${contact['phone']}'),
        if (contact['email'] != null) Text('Email: ${contact['email']}'),
      ],
    );
  }

  Widget _buildBottomActions() {
    if (_pet['status'] == 'AVAILABLE') {
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
        child: AppButton(
          text: 'Sponsor Me',
          isLoading: _isInitializingPayment,
          onPressed: _startSponsorship,
        ),
      );
    }

    if (_pet['status'] != 'PENDING_REVIEW') return const SizedBox.shrink();

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
              onPressed: () => _handleAction('REJECT'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.destructiveColor,
                side: const BorderSide(color: AppTheme.destructiveColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Reject Submission'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _handleAction('APPROVE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Approve & Publish'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'AVAILABLE':
        return AppTheme.successColor;
      case 'PENDING_REVIEW':
        return Colors.orange;
      case 'PENDING_ADOPTION':
        return Colors.blue;
      case 'ADOPTED':
        return AppTheme.primaryColor;
      case 'REJECTED':
        return AppTheme.destructiveColor;
      default:
        return AppTheme.mutedForegroundColor;
    }
  }

  Future<void> _handleAction(String action) async {
    final String title = action == 'APPROVE'
        ? 'Approve Pet'
        : action == 'REJECT'
        ? 'Reject Pet'
        : 'Delete Pet';
    final String message = 'Are you sure you want to $action this pet listing?';

    final ok = await showOkCancelAlertDialog(
      context: context,
      title: title,
      message: message,
      isDestructiveAction: action != 'APPROVE',
    );

    if (ok != OkCancelResult.ok) return;

    try {
      final petService = ref.read(petServiceProvider);
      if (action == 'APPROVE') {
        await petService.updatePet(_pet['_id'], {'status': 'AVAILABLE'});
      } else if (action == 'REJECT') {
        await petService.updatePet(_pet['_id'], {'status': 'REJECTED'});
      } else if (action == 'DELETE') {
        await petService.deletePet(_pet['_id']);
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to signal refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  Future<void> _startSponsorship() async {
    final amountResults = await showTextInputDialog(
      context: context,
      title: 'Sponsor ${_pet['name']}',
      message: 'Enter the amount you wish to donate (BDT)',
      textFields: [
        const DialogTextField(
          hintText: 'e.g., 500',
          keyboardType: TextInputType.number,
        ),
      ],
    );

    if (amountResults == null || amountResults.isEmpty) return;

    final amount = double.tryParse(amountResults.first);
    if (amount == null || amount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount')),
        );
      }
      return;
    }

    setState(() => _isInitializingPayment = true);

    try {
      final user = ref.read(authProvider).user;
      final donationService = ref.read(donationServiceProvider);

      final url = await donationService.initSponsorship(
        amount: amount,
        petId: _pet['_id'],
        donorName: user?['name'] ?? 'Admin',
        donorEmail: user?['email'] ?? 'admin@example.com',
        donorPhone: user?['phone'] ?? '01700000000',
        userId: user?['_id'],
      );

      if (mounted) {
        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebView(
              initialUrl: url,
              title: 'Sponsor ${_pet['name']}',
            ),
          ),
        );

        if (mounted) {
          String message;
          if (result == 'SUCCESS') {
            message = 'Sponsorship successful!';
          } else if (result == 'FAIL') {
            message = 'Payment failed.';
          } else if (result == 'CANCEL') {
            message = 'Payment cancelled.';
          } else {
            message = 'Checkout closed.';
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize payment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isInitializingPayment = false);
      }
    }
  }
}
