import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/widgets/button.dart';
import 'package:mobile/core/widgets/input.dart';
import 'package:mobile/features/admin/stories/story_service.dart';

class StoryEditorScreen extends ConsumerStatefulWidget {
  final dynamic story;
  const StoryEditorScreen({super.key, this.story});

  @override
  ConsumerState<StoryEditorScreen> createState() => _StoryEditorScreenState();
}

class _StoryEditorScreenState extends ConsumerState<StoryEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late final TextEditingController _coverImageController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.story?['title'] ?? '',
    );
    _bodyController = TextEditingController(text: widget.story?['body'] ?? '');
    _coverImageController = TextEditingController(
      text: widget.story?['coverImage'] ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _coverImageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.story != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Story' : 'New Story')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppInput(
                label: 'Title',
                controller: _titleController,
                placeholder: 'Enter story title',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppInput(
                label: 'Body Content',
                controller: _bodyController,
                placeholder: 'Enter story content',
                maxLines: 8,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppInput(
                label: 'Cover Image URL',
                controller: _coverImageController,
                placeholder: 'https://example.com/image.jpg',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              AppButton(
                text: isEditing ? 'Update Story' : 'Create Story',
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(storyServiceProvider);
      final data = {
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'coverImage': _coverImageController.text.trim(),
      };

      if (widget.story != null) {
        await service.updateStory(widget.story['_id'], data);
      } else {
        await service.createStory(data);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
