import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/status_badge.dart';
import 'package:mobile/features/admin/widgets/admin_scaffold.dart';
import 'package:mobile/features/admin/donations/donation_service.dart';
import 'package:intl/intl.dart';

final adminDonationsProvider = FutureProvider<List<dynamic>>((ref) async {
  final result = await ref.watch(donationServiceProvider).getDonations();
  return result['data'] ?? [];
});

class AdminDonationsScreen extends ConsumerWidget {
  const AdminDonationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationsAsync = ref.watch(adminDonationsProvider);

    return AdminScaffold(
      title: 'Donation History',
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(adminDonationsProvider),
        child: donationsAsync.when(
          data: (donations) => _buildList(donations),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildList(List<dynamic> donations) {
    if (donations.isEmpty)
      return const Center(child: Text('No donations found.'));

    final currencyFormat = NumberFormat.currency(symbol: '৳', decimalDigits: 0);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: donations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final donation = donations[index];
        final donorName = donation['donorName'] ?? 'Anonymous';
        final isSuccess = donation['ssl']?['status'] == 'VALID';

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSuccess
                  ? AppTheme.successColor.withOpacity(0.1)
                  : AppTheme.destructiveColor.withOpacity(0.1),
              child: Icon(
                Icons.volunteer_activism,
                color: isSuccess
                    ? AppTheme.successColor
                    : AppTheme.destructiveColor,
              ),
            ),
            title: Text(
              donorName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donation['purpose'] ?? 'General Donation',
                  style: const TextStyle(fontSize: 12),
                ),
                if (donation['petId'] != null)
                  Text(
                    'For: ${donation['petId']['name']}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                Text(
                  DateFormat.yMMMd().add_jm().format(
                    DateTime.parse(donation['createdAt']),
                  ),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.mutedForegroundColor,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(donation['amount']),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.successColor,
                  ),
                ),
                StatusBadge(
                  text: donation['ssl']?['status'] ?? 'N/A',
                  color: isSuccess ? AppTheme.successColor : Colors.orange,
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
