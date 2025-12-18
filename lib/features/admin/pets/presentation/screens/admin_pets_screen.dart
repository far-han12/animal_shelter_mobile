import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/status_badge.dart';
import 'package:mobile/features/admin/widgets/admin_scaffold.dart';
import 'package:mobile/features/admin/pets/pet_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/features/admin/pets/presentation/screens/pet_detail_screen.dart';

final adminPetsProvider = FutureProvider.family<Map<String, dynamic>, String>((
  ref,
  token,
) async {
  // Parse token: "page|search|status"
  final parts = token.split('|');
  final page = int.tryParse(parts[0]) ?? 1;
  final search = parts[1].isEmpty ? null : parts[1];
  final status = parts[2].isEmpty ? null : parts[2];

  return ref
      .watch(petServiceProvider)
      .getAdminPets(page: page, search: search, status: status);
});

class AdminPetsScreen extends ConsumerStatefulWidget {
  const AdminPetsScreen({super.key});

  @override
  ConsumerState<AdminPetsScreen> createState() => _AdminPetsScreenState();
}

class _AdminPetsScreenState extends ConsumerState<AdminPetsScreen> {
  int _currentPage = 1;
  String _search = '';
  String? _status;
  final _searchController = TextEditingController();

  void _onSearch() {
    setState(() {
      _search = _searchController.text.trim();
      _currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(
      adminPetsProvider('$_currentPage|$_search|${_status ?? ''}'),
    );

    return AdminScaffold(
      title: 'Pet Management',
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.refresh(
                adminPetsProvider('$_currentPage|$_search|${_status ?? ''}'),
              ),
              child: petsAsync.when(
                data: (data) => _buildList(data),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add Pet
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search pets...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearch();
                      },
                    )
                  : null,
            ),
            onSubmitted: (_) => _onSearch(),
            onChanged: (val) {
              if (val.isEmpty) _onSearch();
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip(null, 'All'),
                _buildStatusChip('AVAILABLE', 'Available'),
                _buildStatusChip('PENDING_REVIEW', 'Pending Review'),
                _buildStatusChip('PENDING_ADOPTION', 'Adopting'),
                _buildStatusChip('ADOPTED', 'Adopted'),
                _buildStatusChip('REJECTED', 'Rejected'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String? status, String label) {
    final isSelected = _status == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          setState(() {
            _status = status;
            _currentPage = 1;
          });
        },
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildList(Map<String, dynamic> data) {
    final List<dynamic> pets = data['data'];
    final meta = data['meta'];

    if (pets.isEmpty) return const Center(child: Text('No pets found.'));

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return _buildPetCard(pet);
            },
          ),
        ),
        _buildPagination(meta),
      ],
    );
  }

  Widget _buildPetCard(dynamic pet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final refresh = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => PetDetailScreen(pet: pet)),
          );
          if (refresh == true) {
            ref.invalidate(adminPetsProvider);
          }
        },
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CachedNetworkImage(
                imageUrl: (pet['photos'] != null && pet['photos'].isNotEmpty)
                    ? pet['photos'][0]
                    : '',
                width: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: AppTheme.mutedColor),
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.mutedColor,
                  child: const Icon(
                    Icons.pets,
                    color: AppTheme.mutedForegroundColor,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              pet['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          StatusBadge(
                            text: pet['status'],
                            color: _getStatusColor(pet['status']),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pet['breed']} • ${pet['age']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.mutedForegroundColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pet['description'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
