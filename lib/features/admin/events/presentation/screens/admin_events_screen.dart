import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/status_badge.dart';
import 'package:mobile/features/admin/widgets/admin_scaffold.dart';
import 'package:mobile/features/admin/events/presentation/screens/event_editor_screen.dart';
import 'package:mobile/features/admin/events/event_service.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:intl/intl.dart';

final adminEventsProvider = FutureProvider.family<Map<String, dynamic>, int>((
  ref,
  page,
) async {
  return ref.watch(eventServiceProvider).getEvents(page: page);
});

class AdminEventsScreen extends ConsumerStatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  ConsumerState<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends ConsumerState<AdminEventsScreen> {
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(adminEventsProvider(_currentPage));

    return AdminScaffold(
      title: 'Events Management',
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(adminEventsProvider(_currentPage)),
        child: eventsAsync.when(
          data: (data) => _buildList(data),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final refresh = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const EventEditorScreen()),
          );
          if (refresh == true) {
            ref.invalidate(adminEventsProvider);
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildList(Map<String, dynamic> data) {
    final List<dynamic> events = data['data'];
    final meta = data['meta'];

    if (events.isEmpty) return const Center(child: Text('No events found.'));

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final event = events[index];
              final dateStr = event['startDateTime'] ?? event['date'];
              final date = dateStr != null
                  ? DateTime.parse(dateStr)
                  : DateTime.now();
              final isPast = date.isBefore(DateTime.now());

              return Card(
                child: ListTile(
                  leading: Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('MMM').format(date).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          DateFormat('dd').format(date),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  title: Text(
                    event['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 12,
                            color: AppTheme.mutedForegroundColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event['location'],
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppTheme.mutedForegroundColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat.jm().format(date),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: StatusBadge(
                    text: isPast ? 'Past' : 'Upcoming',
                    color: isPast
                        ? AppTheme.mutedForegroundColor
                        : AppTheme.successColor,
                  ),
                  onTap: () => _showActions(event),
                ),
              );
            },
          ),
        ),
        _buildPagination(meta),
      ],
    );
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

  Future<void> _showActions(dynamic event) async {
    final result = await showModalActionSheet<String>(
      context: context,
      title: 'Manage Event',
      actions: [
        const SheetAction(label: 'Edit', key: 'EDIT'),
        const SheetAction(
          label: 'Delete',
          key: 'DELETE',
          isDestructiveAction: true,
        ),
      ],
    );

    if (result == 'DELETE') {
      final ok = await showOkCancelAlertDialog(
        context: context,
        title: 'Delete Event',
        message: 'Are you sure you want to delete "${event['title']}"?',
        isDestructiveAction: true,
      );
      if (ok == OkCancelResult.ok) {
        try {
          await ref.read(eventServiceProvider).deleteEvent(event['_id']);
          ref.invalidate(adminEventsProvider);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Failed: $e')));
          }
        }
      }
    } else if (result == 'EDIT') {
      _showEventDialog(event: event);
    }
  }

  Future<void> _showEventDialog({dynamic event}) async {
    final refresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => EventEditorScreen(event: event)),
    );
    if (refresh == true) {
      ref.invalidate(adminEventsProvider);
    }
  }
}
