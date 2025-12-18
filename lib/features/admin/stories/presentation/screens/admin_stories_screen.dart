import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/admin/widgets/admin_scaffold.dart';
import 'package:mobile/features/admin/stories/presentation/screens/story_editor_screen.dart';
import 'package:mobile/features/admin/stories/story_service.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

final adminStoriesProvider = FutureProvider.family<Map<String, dynamic>, int>((
  ref,
  page,
) async {
  return ref.watch(storyServiceProvider).getStories(page: page);
});

class AdminStoriesScreen extends ConsumerStatefulWidget {
  const AdminStoriesScreen({super.key});

  @override
  ConsumerState<AdminStoriesScreen> createState() => _AdminStoriesScreenState();
}

class _AdminStoriesScreenState extends ConsumerState<AdminStoriesScreen> {
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final storiesAsync = ref.watch(adminStoriesProvider(_currentPage));

    return AdminScaffold(
      title: 'Stories Management',
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(adminStoriesProvider(_currentPage)),
        child: storiesAsync.when(
          data: (data) => _buildList(data),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final refresh = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const StoryEditorScreen()),
          );
          if (refresh == true) {
            ref.invalidate(adminStoriesProvider);
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildList(Map<String, dynamic> data) {
    final List<dynamic> stories = data['data'];
    final meta = data['meta'];

    if (stories.isEmpty) return const Center(child: Text('No stories found.'));

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: stories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final story = stories[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _showActions(story),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (story['coverImage'] != null)
                        CachedNetworkImage(
                          imageUrl: story['coverImage'],
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: AppTheme.mutedColor),
                          errorWidget: (context, url, err) => Container(
                            color: AppTheme.mutedColor,
                            child: const Icon(Icons.image),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat.yMMMd().format(
                                DateTime.parse(story['createdAt']),
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.mutedForegroundColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              story['body'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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

  Future<void> _showActions(dynamic story) async {
    final result = await showModalActionSheet<String>(
      context: context,
      title: 'Manage Story',
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
        title: 'Delete Story',
        message: 'Are you sure you want to delete "${story['title']}"?',
        isDestructiveAction: true,
      );
      if (ok == OkCancelResult.ok) {
        try {
          await ref.read(storyServiceProvider).deleteStory(story['_id']);
          ref.invalidate(adminStoriesProvider);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Failed: $e')));
          }
        }
      }
    } else if (result == 'EDIT') {
      _showStoryDialog(story: story);
    }
  }

  Future<void> _showStoryDialog({dynamic story}) async {
    final refresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => StoryEditorScreen(story: story)),
    );
    if (refresh == true) {
      ref.invalidate(adminStoriesProvider);
    }
  }
}
