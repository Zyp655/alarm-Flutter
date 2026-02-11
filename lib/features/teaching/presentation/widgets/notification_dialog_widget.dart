import 'package:flutter/material.dart';

class NotificationDialogWidget extends StatefulWidget {
  final List<String> studentNames;
  final String? initialMessage;
  final bool isAiGenerated;
  final Function(String title, String message) onSend;

  const NotificationDialogWidget({
    super.key,
    required this.studentNames,
    this.initialMessage,
    this.isAiGenerated = false,
    required this.onSend,
  });

  @override
  State<NotificationDialogWidget> createState() =>
      _NotificationDialogWidgetState();
}

class _NotificationDialogWidgetState extends State<NotificationDialogWidget> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null) {
      _titleController.text = 'Nhắc nhở học tập';
      _messageController.text = widget.initialMessage!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF16213E),
      title: Row(
        children: [
          if (widget.isAiGenerated)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.auto_awesome, color: Color(0xFF6C63FF)),
            ),
          Text(
            widget.isAiGenerated ? 'AI Soạn tin nhắn' : 'Gửi thông báo',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gửi đến: ${widget.studentNames.length} sinh viên',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Tiêu đề',
                labelStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFF0F3460),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Nội dung',
                labelStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFF0F3460),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Hủy', style: TextStyle(color: Colors.grey[400])),
        ),
        ElevatedButton.icon(
          onPressed: () {
            if (_titleController.text.isNotEmpty &&
                _messageController.text.isNotEmpty) {
              Navigator.pop(context);
              widget.onSend(_titleController.text, _messageController.text);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isAiGenerated
                ? const Color(0xFF6C63FF)
                : const Color(0xFFFF6636),
          ),
          icon: Icon(
            widget.isAiGenerated ? Icons.auto_awesome : Icons.send,
            size: 18,
            color: Colors.white,
          ),
          label: Text(
            widget.isAiGenerated ? 'Gửi AI Nudge' : 'Gửi',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
