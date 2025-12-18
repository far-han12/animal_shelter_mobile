import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/admin/widgets/admin_scaffold.dart';
import 'package:mobile/features/admin/admin_service.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(adminAnalyticsProvider);

    return AdminScaffold(
      title: 'Dashboard',
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(adminAnalyticsProvider),
        child: analyticsAsync.when(
          data: (data) => _buildContent(context, data),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> data) {
    final donations = data['donations'];
    final pets = data['pets'];
    final adoptions = data['adoptions'];
    final inquiries = data['inquiries'];
    final volunteers = data['volunteers'];
    final recentActivity = data['recentActivity'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryGrid(donations, pets, adoptions, inquiries, volunteers),
          const SizedBox(height: 24),
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRecentPets(recentActivity['pets']),
          const SizedBox(height: 16),
          _buildRecentDonations(recentActivity['donations']),
        ],
      ),
    );
  }

  String _formatCurrency(dynamic amount, {int decimalDigits = 0}) {
    return NumberFormat.currency(
      symbol: '৳',
      decimalDigits: decimalDigits,
    ).format(amount);
  }

  Widget _buildSummaryGrid(
    dynamic donations,
    dynamic pets,
    dynamic adoptions,
    dynamic inquiries,
    dynamic volunteers,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          'Donations',
          _formatCurrency(donations['allTime']),
          'This mo: ${_formatCurrency(donations['thisMonth'])}',
          Icons.account_balance_wallet,
          AppTheme.successColor,
        ),
        _buildStatCard(
          'Total Pets',
          pets['total'].toString(),
          'Available: ${_getCount(pets['breakdown'], 'AVAILABLE')}',
          Icons.pets,
          AppTheme.primaryColor,
        ),
        _buildStatCard(
          'Applications',
          adoptions['pending'].toString(),
          'Pending approval',
          Icons.assignment,
          Colors.orange,
        ),
        _buildStatCard(
          'Inquiries',
          inquiries['new'].toString(),
          'Direct messages',
          Icons.chat_bubble,
          Colors.purple,
        ),
      ],
    );
  }

  int _getCount(List<dynamic> breakdown, String status) {
    final item = breakdown.firstWhere(
      (e) => e['_id'] == status,
      orElse: () => {'count': 0},
    );
    return item['count'];
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.mutedForegroundColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPets(List<dynamic>? pets) {
    if (pets == null || pets.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Recent Pets',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pets.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final pet = pets[index];
              return ListTile(
                title: Text(pet['name'], style: const TextStyle(fontSize: 14)),
                subtitle: Text(
                  DateFormat.yMMMd().format(DateTime.parse(pet['createdAt'])),
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Text(
                  pet['status'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDonations(List<dynamic>? donations) {
    if (donations == null || donations.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Recent Donations',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: donations.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final donation = donations[index];
              return ListTile(
                title: Text(
                  donation['donorName'] ?? 'Anonymous',
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  donation['purpose'],
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Text(
                  _formatCurrency(donation['amount']),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
