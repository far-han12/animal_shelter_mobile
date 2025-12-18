import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/status_badge.dart';
import 'package:mobile/features/user/user_service.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class MyDonationsScreen extends ConsumerWidget {
  const MyDonationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationsAsync = ref.watch(myDonationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Donations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/donate'),
            tooltip: 'Make New Donation',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(myDonationsProvider),
        child: donationsAsync.when(
          data: (donations) => _buildList(donations),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildList(List<dynamic> donations) {
    if (donations.isEmpty) {
      return const Center(child: Text('You haven\'t made any donations yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: donations.length,
      itemBuilder: (context, index) {
        final donation = donations[index];
        final amount = donation['amount'];
        final purpose = donation['purpose'];
        final status = donation['ssl']?['status'] ?? 'UNKNOWN';
        final tranId = donation['ssl']?['tranId'] ?? '-';
        final pet = donation['petId'];

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
                      '$amount BDT',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    StatusBadge(text: status, color: _getStatusColor(status)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat.yMMMd().format(
                    DateTime.parse(donation['createdAt']),
                  ),
                  style: const TextStyle(color: AppTheme.mutedForegroundColor),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text('Purpose: $purpose'),
                  ],
                ),
                if (pet != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.pets, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Sponsoring: ${pet['name'] ?? 'Unknown Pet'}'),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'Transaction ID: $tranId',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: AppTheme.mutedForegroundColor,
                  ),
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
      case 'VALID':
        return AppTheme.successColor;
      case 'FAILED':
      case 'CANCELLED':
        return AppTheme.destructiveColor;
      default:
        return Colors.orange;
    }
  }
}
