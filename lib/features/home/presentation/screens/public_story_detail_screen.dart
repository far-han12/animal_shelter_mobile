import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gap/gap.dart';

class PublicStoryDetailScreen extends StatelessWidget {
  final dynamic story;
  const PublicStoryDetailScreen({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Success Story')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (story['coverImage'] != null)
              CachedNetworkImage(
                imageUrl: story['coverImage'],
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    story['publishedAt'] != null
                        ? 'Published on ${DateTime.parse(story['publishedAt']).toLocal().toString().split(' ')[0]}'
                        : '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.mutedForegroundColor,
                    ),
                  ),
                  const Gap(24),
                  const Divider(),
                  const Gap(24),
                  Text(
                    story['body'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Gap(40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
