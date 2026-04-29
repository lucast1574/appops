import 'package:flutter/material.dart';
import '../../features/chat/presentation/pages/chat_page.dart';

/// A shared button to open the chat for a specific task.
/// Typically used in the AppBar actions of task execution pages.
class TaskChatActionButton extends StatelessWidget {
  final int taskId;
  final String taskTitle;
  final Color color;

  const TaskChatActionButton({
    super.key,
    required this.taskId,
    required this.taskTitle,
    this.color = const Color(0xFF002B4B),
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.chat_bubble_outline_rounded,
        color: color,
        size: 24,
      ),
      tooltip: 'Chat de la tarea',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(
              taskId: taskId,
              taskTitle: taskTitle,
            ),
          ),
        );
      },
    );
  }
}
