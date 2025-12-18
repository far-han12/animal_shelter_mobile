import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/pets/data/pet_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/features/admin/applications/adoption_service.dart';
import 'package:mobile/features/admin/donations/donation_service.dart';
import 'package:mobile/features/auth/auth_notifier.dart';
import 'package:mobile/core/widgets/button.dart';
import 'package:gap/gap.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:go_router/go_router.dart';

class PublicPetDetailScreen extends ConsumerStatefulWidget {
  final Pet pet;
  const PublicPetDetailScreen({super.key, required this.pet});

  @override
  ConsumerState<PublicPetDetailScreen> createState() =>
      _PublicPetDetailScreenState();
}

class _PublicPetDetailScreenState extends ConsumerState<PublicPetDetailScreen> {
  bool _isLoadingAction = false;
  bool _showAdoptionForm = false;

  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _experienceController = TextEditingController();
  final _householdController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _experienceController.dispose();
    _householdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(pet.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroImage(pet),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    '${pet.breed} • ${pet.age} yrs • ${pet.gender}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppTheme.mutedForegroundColor,
                    ),
                  ),
                  const Gap(24),
                  _buildInfoGrid(pet),
                  const Gap(32),
                  Text(
                    'About ${pet.name}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    pet.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Color(0xFF475569),
                    ),
                  ),
                  if (_showAdoptionForm) ...[
                    const Gap(40),
                    _buildAdoptionForm(),
                  ],
                  const Gap(40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: !_showAdoptionForm ? _buildActionButtons(pet) : null,
    );
  }

  Widget _buildHeroImage(Pet pet) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: pet.photos.isNotEmpty
          ? CachedNetworkImage(imageUrl: pet.photos.first, fit: BoxFit.cover)
          : Container(
              color: AppTheme.mutedColor,
              child: const Icon(
                Icons.pets,
                size: 80,
                color: AppTheme.mutedForegroundColor,
              ),
            ),
    );
  }

  Widget _buildInfoGrid(Pet pet) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildInfoCard('Species', pet.species),
        _buildInfoCard('Size', pet.size),
        _buildInfoCard('Special Needs', pet.specialNeeds ? 'Yes' : 'No'),
        _buildInfoCard('Status', pet.status, isStatus: true),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, {bool isStatus = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.mutedForegroundColor,
            ),
          ),
          const Gap(2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isStatus && value == 'AVAILABLE'
                  ? AppTheme.successColor
                  : AppTheme.foregroundColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdoptionForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF8FAFC),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adoption Application',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Gap(24),
            const Text(
              'Address',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const Gap(8),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                hintText: 'Enter your full address',
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const Gap(16),
            const Text(
              'Pet Experience',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const Gap(8),
            TextFormField(
              controller: _experienceController,
              decoration: const InputDecoration(
                hintText: 'Have you owned pets before?',
              ),
              maxLines: 3,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const Gap(16),
            const Text(
              'Household Info',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const Gap(8),
            TextFormField(
              controller: _householdController,
              decoration: const InputDecoration(
                hintText: 'e.g., 2 adults, 1 child, fenced yard',
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const Gap(16),
            const Text(
              'Additional Notes',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const Gap(8),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Anything else you\'d like to add?',
              ),
              maxLines: 3,
            ),
            const Gap(32),
            AppButton(
              text: 'Submit Application',
              isLoading: _isLoadingAction,
              onPressed: _submitAdoption,
            ),
            const Gap(12),
            TextButton(
              onPressed: () => setState(() => _showAdoptionForm = false),
              child: const Center(child: Text('Cancel')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitAdoption() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoadingAction = true);
    try {
      await ref
          .read(adoptionServiceProvider)
          .applyForAdoption(
            petId: widget.pet.id,
            applicantInfo: {
              'address': _addressController.text,
              'experience': _experienceController.text,
              'householdInfo': _householdController.text,
              'notes': _notesController.text,
            },
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        setState(() => _showAdoptionForm = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.destructiveColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingAction = false);
    }
  }

  Widget _buildActionButtons(Pet pet) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: AppButton(
              text: 'Adopt Me',
              onPressed: () => _handleAdopt(pet),
            ),
          ),
          const Gap(12),
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: () => _handleInquire(pet),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppTheme.borderColor),
              ),
              child: const Text('Inquire'),
            ),
          ),
          const Gap(12),
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: () => _handleSponsor(pet),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppTheme.borderColor),
              ),
              child: const Text('Sponsor'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAdopt(Pet pet) async {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      final ok = await showOkCancelAlertDialog(
        context: context,
        title: 'Login Required',
        message: 'You need to be logged in to apply for adoption.',
        okLabel: 'Login',
      );
      if (ok == OkCancelResult.ok) {
        context.push('/login');
      }
      return;
    }

    setState(() => _showAdoptionForm = true);
  }

  Future<void> _handleInquire(Pet pet) async {
    final results = await showTextInputDialog(
      context: context,
      title: 'Inquire about ${pet.name}',
      message: 'Leave your contact details and a message.',
      textFields: [
        const DialogTextField(hintText: 'Your Name'),
        const DialogTextField(
          hintText: 'Your Email',
          keyboardType: TextInputType.emailAddress,
        ),
        const DialogTextField(
          hintText: 'Your Phone',
          keyboardType: TextInputType.phone,
        ),
        const DialogTextField(hintText: 'Message', maxLines: 3),
      ],
    );

    if (results == null || results.length < 4) return;

    setState(() => _isLoadingAction = true);
    try {
      await ref
          .read(adoptionServiceProvider)
          .createInquiry(
            petId: pet.id,
            name: results[0],
            email: results[1],
            phone: results[2],
            message: results[3],
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inquiry sent successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.destructiveColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingAction = false);
    }
  }

  Future<void> _handleSponsor(Pet pet) async {
    final amountResults = await showTextInputDialog(
      context: context,
      title: 'Sponsor ${pet.name}',
      message: 'Enter the amount you wish to donate (BDT)',
      textFields: [
        const DialogTextField(
          hintText: 'e.g. 500',
          keyboardType: TextInputType.number,
        ),
      ],
    );

    if (amountResults == null || amountResults.isEmpty) return;

    final amount = double.tryParse(amountResults.first);
    if (amount == null || amount <= 0) return;

    setState(() => _isLoadingAction = true);

    try {
      final authState = ref.read(authProvider);
      final paymentUrl = await ref
          .read(donationServiceProvider)
          .initDonation(
            amount: amount,
            purpose: 'SPONSOR_PET',
            donorName: authState.user?['name'],
            donorEmail: authState.user?['email'],
            userId: authState.user?['_id'],
            petId: pet.id,
          );

      if (!mounted) return;

      await context.push(
        '/payment',
        extra: {'url': paymentUrl, 'title': 'Sponsor ${pet.name}'},
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.destructiveColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingAction = false);
    }
  }
}
