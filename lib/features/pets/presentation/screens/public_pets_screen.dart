import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/admin/pets/pet_service.dart';
import 'package:mobile/features/pets/data/pet_model.dart';
import 'package:mobile/core/widgets/button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

class PublicPetsScreen extends ConsumerStatefulWidget {
  const PublicPetsScreen({super.key});

  @override
  ConsumerState<PublicPetsScreen> createState() => _PublicPetsScreenState();
}

class _PublicPetsScreenState extends ConsumerState<PublicPetsScreen> {
  final _searchController = TextEditingController();
  String? _selectedSpecies;
  String? _selectedSize;
  int _currentPage = 1;
  bool _isLoading = false;
  List<Pet> _pets = [];
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _fetchPets();
  }

  Future<void> _fetchPets() async {
    setState(() => _isLoading = true);
    try {
      final response = await ref
          .read(petServiceProvider)
          .getPets(
            page: _currentPage,
            limit: 10,
            q: _searchController.text,
            species: _selectedSpecies,
            size: _selectedSize,
          );
      final List<dynamic> data = response['data'] ?? [];
      setState(() {
        _pets = data.map((json) => Pet.fromJson(json)).toList();
        _totalPages = response['meta']['totalPages'] ?? 1;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.destructiveColor,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() => _currentPage = 1);
    _fetchPets();
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _selectedSpecies = null;
      _selectedSize = null;
      _currentPage = 1;
    });
    _fetchPets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adopt a Pet')),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _pets.isEmpty
                ? const Center(
                    child: Text('No pets found matching your criteria.'),
                  )
                : _buildPetGrid(),
          ),
          if (_totalPages > 1) _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search pets...',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _applyFilters(),
                ),
              ),
              const Gap(12),
              IconButton.filled(
                onPressed: _showFilterSheet,
                icon: const Icon(Icons.filter_list),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          if (_selectedSpecies != null ||
              _selectedSize != null ||
              _searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Text(
                    'Active Filters',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.mutedForegroundColor,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text(
                      'Clear All',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Gap(24),
              const Text(
                'Species',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const Gap(8),
              DropdownButtonFormField<String>(
                value: _selectedSpecies,
                items: ['Dog', 'Cat', 'Bird', 'Other']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setModalState(() => _selectedSpecies = v),
                decoration: const InputDecoration(hintText: 'All Species'),
              ),
              const Gap(24),
              const Text('Size', style: TextStyle(fontWeight: FontWeight.w600)),
              const Gap(8),
              DropdownButtonFormField<String>(
                value: _selectedSize,
                items: ['Small', 'Medium', 'Large']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setModalState(() => _selectedSize = v),
                decoration: const InputDecoration(hintText: 'Any Size'),
              ),
              const Gap(32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _clearFilters();
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _applyFilters();
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetGrid() {
    return RefreshIndicator(
      onRefresh: _fetchPets,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _pets.length,
        itemBuilder: (context, index) => _PetCard(pet: _pets[index]),
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () => setState(() {
                    _currentPage--;
                    _fetchPets();
                  })
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('Page $_currentPage of $_totalPages'),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () => setState(() {
                    _currentPage++;
                    _fetchPets();
                  })
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final Pet pet;
  const _PetCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/pets/${pet.id}', extra: pet),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  pet.photos.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: pet.photos.first,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppTheme.mutedColor,
                          child: const Center(
                            child: Icon(Icons.pets, size: 48),
                          ),
                        ),
                  if (pet.status == 'PENDING_ADOPTION')
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Pending Adoption',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    '${pet.breed} • ${pet.age} yrs • ${pet.gender}',
                    style: const TextStyle(
                      color: AppTheme.mutedForegroundColor,
                      fontSize: 13,
                    ),
                  ),
                  const Gap(12),
                  Text(
                    pet.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                  const Gap(16),
                  AppButton(
                    text: 'Meet ${pet.name}',
                    onPressed: () =>
                        context.push('/pets/${pet.id}', extra: pet),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
