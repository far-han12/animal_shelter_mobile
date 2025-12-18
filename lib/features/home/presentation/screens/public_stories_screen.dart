import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/admin/stories/story_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

class PublicStoriesScreen extends ConsumerStatefulWidget {
  const PublicStoriesScreen({super.key});

  @override
  ConsumerState<PublicStoriesScreen> createState() =>
      _PublicStoriesScreenState();
}

class _PublicStoriesScreenState extends ConsumerState<PublicStoriesScreen> {
  int _currentPage = 1;
  bool _isLoading = false;
  List<dynamic> _stories = [];
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _fetchStories();
  }

  Future<void> _fetchStories() async {
    setState(() => _isLoading = true);
    try {
      final response = await ref
          .read(storyServiceProvider)
          .getStories(page: _currentPage, limit: 10);
      final List<dynamic> data = response['data'] ?? [];
      setState(() {
        _stories = data;
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
      appBar: AppBar(title: const Text('Success Stories')),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _stories.isEmpty
                ? const Center(child: Text('No stories found.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _stories.length,
                    itemBuilder: (context, index) =>
                        _StoryCard(story: _stories[index]),
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
                    _fetchStories();
                  })
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('Page $_currentPage of $_totalPages'),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () => setState(() {
                    _currentPage++;
                    _fetchStories();
                  })
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final dynamic story;
  const _StoryCard({required this.story});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/stories/detail', extra: story),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (story['coverImage'] != null)
              CachedNetworkImage(
                imageUrl: story['coverImage'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    story['publishedAt'] != null
                        ? DateTime.parse(
                            story['publishedAt'],
                          ).toLocal().toString().split(' ')[0]
                        : '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.mutedForegroundColor,
                    ),
                  ),
                  const Gap(12),
                  Text(
                    story['body'] ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const Gap(16),
                  Text(
                    'Read More',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
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
