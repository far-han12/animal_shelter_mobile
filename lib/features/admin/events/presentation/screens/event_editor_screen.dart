import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/widgets/button.dart';
import 'package:mobile/core/widgets/input.dart';
import 'package:mobile/features/admin/events/event_service.dart';
import 'package:intl/intl.dart';

class EventEditorScreen extends ConsumerStatefulWidget {
  final dynamic event;
  const EventEditorScreen({super.key, this.event});

  @override
  ConsumerState<EventEditorScreen> createState() => _EventEditorScreenState();
}

class _EventEditorScreenState extends ConsumerState<EventEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final startDateTimeStr = widget.event?['startDateTime'];
    DateTime? startDateTime;
    if (startDateTimeStr != null) {
      startDateTime = DateTime.parse(startDateTimeStr);
    }

    _titleController = TextEditingController(
      text: widget.event?['title'] ?? '',
    );
    _locationController = TextEditingController(
      text: widget.event?['location'] ?? '',
    );
    _dateController = TextEditingController(
      text: startDateTime != null
          ? DateFormat('yyyy-MM-dd').format(startDateTime)
          : '',
    );
    _timeController = TextEditingController(
      text: startDateTime != null
          ? DateFormat('hh:mm a').format(startDateTime)
          : '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Event' : 'New Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppInput(
                label: 'Event Title',
                controller: _titleController,
                placeholder: 'e.g., Annual Charity Gala',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppInput(
                label: 'Location',
                controller: _locationController,
                placeholder: 'e.g., City Community Center',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppInput(
                      label: 'Date',
                      controller: _dateController,
                      placeholder: 'YYYY-MM-DD',
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppInput(
                      label: 'Time',
                      controller: _timeController,
                      placeholder: '10:00 AM',
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              AppButton(
                text: isEditing ? 'Update Event' : 'Create Event',
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
      final service = ref.read(eventServiceProvider);
      final datePart = _dateController.text.trim();
      final timePart = _timeController.text.trim();
      // Attempt to combine date and time for backend
      String? startDateTime;
      try {
        final combined = DateFormat(
          'yyyy-MM-dd hh:mm a',
        ).parse('$datePart $timePart');
        startDateTime = combined.toIso8601String();
      } catch (e) {
        startDateTime = datePart; // Fallback to just date if parse fails
      }

      final data = {
        'title': _titleController.text.trim(),
        'location': _locationController.text.trim(),
        'startDateTime': startDateTime,
        'description':
            'Event location: ${_locationController.text.trim()}', // Providing a default description
      };

      if (widget.event != null) {
        await service.updateEvent(widget.event['_id'], data);
      } else {
        await service.createEvent(data);
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
