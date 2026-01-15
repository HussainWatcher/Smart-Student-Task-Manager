import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class TaskService {
  // Get all tasks for a student
  Future<List<Map<String, dynamic>>> getTasks(String studentId) async {
    final res = await supabase
        .from('tasks')
        .select()
        .eq('student_id', studentId)
        .order('due_date');
    return res as List<Map<String, dynamic>>;
  }

  // Add a new task
  Future<void> addTask(String studentId, String title, String description, DateTime dueDate) async {
    await supabase.from('tasks').insert({
      'student_id': studentId,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
    });
  }

  // Mark task as done
  Future<void> markDone(String taskId, bool done) async {
    await supabase.from('tasks').update({'is_done': done}).eq('id', taskId);
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    await supabase.from('tasks').delete().eq('id', taskId);
  }
}
