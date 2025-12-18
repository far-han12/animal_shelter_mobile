import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/admin/events/event_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gap/gap.dart';

class PublicEventsScreen extends ConsumerStatefulWidget {
  const PublicEventsScreen({super.key});

  @override
  ConsumerState<PublicEventsScreen> createState() => _PublicEventsScreenState();
}

class _PublicEventsScreenState extends ConsumerState<PublicEventsScreen> {
  int _currentPage = 1;
  bool _isLoading = false;
  List<dynamic> _events = [];
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    try {
      final response = await ref
          .read(eventServiceProvider)
          .getEvents(page: _currentPage, limit: 10);
      final List<dynamic> data = response['data'] ?? [];
      setState(() {
        _events = data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Events')),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _events.isEmpty
                ? const Center(child: Text('No events found.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _events.length,
                    itemBuilder: (context, index) =>
                        _EventCard(event: _events[index]),
                  ),
          ),
          if (_totalPages > 1) _buildPagination(),
        ],
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
                    _fetchEvents();
                  })
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('Page $_currentPage of $_totalPages'),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () => setState(() {
                    _currentPage++;
                    _fetchEvents();
                  })
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final dynamic event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event['images'] != null && event['images'].isNotEmpty)
            CachedNetworkImage(
              imageUrl: event['images'][0],
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppTheme.primaryColor,
                    ),
                    const Gap(8),
                    Text(
                      event['startDateTime'] != null
                          ? DateTime.parse(
                                  event['startDateTime'],
                                ).toLocal().toString().split(':')[0] +
                                ':' +
                                DateTime.parse(
                                  event['startDateTime'],
                                ).toLocal().toString().split(':')[1]
                          : '',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppTheme.destructiveColor,
                    ),
                    const Gap(8),
                    Text(
                      event['location'] ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.mutedForegroundColor,
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                Text(
                  event['description'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Color(0xFF475569),
                  ),
                ),
                const Gap(16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Join us!',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
