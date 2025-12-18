import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/button.dart';
import 'package:mobile/core/widgets/input.dart';
import 'package:mobile/features/auth/auth_notifier.dart';
import 'package:mobile/features/user/user_service.dart';
import 'package:go_router/go_router.dart';

class SubmitPetScreen extends ConsumerStatefulWidget {
  const SubmitPetScreen({super.key});

  @override
  ConsumerState<SubmitPetScreen> createState() => _SubmitPetScreenState();
}

class _SubmitPetScreenState extends ConsumerState<SubmitPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _photoUrlController = TextEditingController();
  final _medicalNotesController = TextEditingController();

  String _species = 'Dog';
  String _size = 'Medium';
  String _gender = 'Male';
  bool _specialNeeds = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    _photoUrlController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = ref.read(authProvider).user;
      final data = {
        'name': _nameController.text.trim(),
        'species': _species,
        'breed': _breedController.text.trim(),
        'age': int.parse(_ageController.text.trim()),
        'size': _size,
        'gender': _gender,
        'description': _descriptionController.text.trim(),
        'medicalNotes': _medicalNotesController.text.trim(),
        'specialNeeds': _specialNeeds,
        'photos': [_photoUrlController.text.trim()],
        'ownerContact': {
          'name': user?['name'],
          'phone': user?['phone'],
          'email': user?['email'],
        },
      };

      await ref.read(userServiceProvider).submitPet(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet submitted for review!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        context.pop();
        context.push('/my-submissions');
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rehome a Pet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pet Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  AppInput(
                    label: 'Pet Name',
                    controller: _nameController,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Name is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    label: 'Species',
                    value: _species,
                    items: ['Dog', 'Cat', 'Bird', 'Other'],
                    onChanged: (v) => setState(() => _species = v!),
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    label: 'Breed',
                    controller: _breedController,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Breed is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    label: 'Age (Years)',
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Age is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: 'Size',
                          value: _size,
                          items: ['Small', 'Medium', 'Large'],
                          onChanged: (v) => setState(() => _size = v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdown(
                          label: 'Gender',
                          value: _gender,
                          items: ['Male', 'Female'],
                          onChanged: (v) => setState(() => _gender = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    label: 'Photo URL',
                    controller: _photoUrlController,
                    placeholder: 'https://...',
                    validator: (value) => value == null || value.isEmpty
                        ? 'Photo URL is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    label: 'Description',
                    controller: _descriptionController,
                    maxLines: 3,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Description is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    label: 'Medical Notes (Optional)',
                    controller: _medicalNotesController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _specialNeeds,
                        onChanged: (v) => setState(() => _specialNeeds = v!),
                      ),
                      const Text('Has Special Needs?'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    text: 'Submit Pet',
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
