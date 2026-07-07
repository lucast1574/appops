// Task event bus.
//
// Small in-process pub/sub used to tell task-list pages (dashboard,
// history) to invalidate their cached data and reload. Fired from two
// places right now:
//
//   * PushService message handler in MainPage, when the backend
//     delivers a data-only refresh push (``kind == task.refresh`` or
//     ``kind == task.deleted``).
//   * DashboardPage's AppLifecycle observer, when the app returns to
//     the foreground after being backgrounded.
//
// Any page that renders task lists should subscribe to
// [TaskEventBus.instance.stream] and, on every event, invalidate its
// TaskService cache and refetch. This is what stops tasks that were
// deleted by a supervisor while the app was backgrounded from staying
// on the operator's screen until they pull-to-refresh manually.

import 'dart:async';

/// Kinds of task-list-affecting events.
enum TaskEventKind {
  /// A specific task was deleted server-side. [taskId] is set.
  taskDeleted,

  /// Backend asked us to refresh (generic silent push, foreground
  /// resume, ...). [taskId] may or may not be set.
  refreshRequested,
}

class TaskEvent {
  TaskEvent({required this.kind, this.taskId, this.reason});
  final TaskEventKind kind;
  final int? taskId;
  final String? reason;
}

class TaskEventBus {
  TaskEventBus._();
  static final TaskEventBus instance = TaskEventBus._();

  final StreamController<TaskEvent> _controller =
      StreamController<TaskEvent>.broadcast();

  Stream<TaskEvent> get stream => _controller.stream;

  void emit(TaskEvent event) {
    if (_controller.isClosed) return;
    _controller.add(event);
  }

  /// Convenience: emit a generic refresh-requested event.
  void requestRefresh({int? taskId, String? reason}) {
    emit(TaskEvent(
      kind: TaskEventKind.refreshRequested,
      taskId: taskId,
      reason: reason,
    ));
  }

  /// Convenience: emit a task-deleted event.
  void notifyDeleted(int taskId, {String? reason}) {
    emit(TaskEvent(
      kind: TaskEventKind.taskDeleted,
      taskId: taskId,
      reason: reason,
    ));
  }
}
