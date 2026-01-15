import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with deep linking enabled for mobile OAuth
  await Supabase.initialize(
    url: 'https://plzfgmaneyqiuzvjhuab.supabase.co', // Your Supabase URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBsemZnbWFuZXlxaXV6dmpodWFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg0NTY2NzQsImV4cCI6MjA4NDAzMjY3NH0.0s0xVnmycd88U67V6gNETvArf3iQPejYr0taNgQ-da4', // Replace with your Supabase anon key
    debug: true,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(const MyApp());
}

// ------------------- MyApp -------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const AuthChecker(),
    );
  }
}

// ------------------- AuthChecker -------------------
class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  @override
  void initState() {
    super.initState();
    // Listen for auth state changes (important for OAuth)
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      print('***** Auth state changed: ${data.event}');
      print('***** Session exists: ${data.session != null}');
      if (data.session != null) {
        print('***** User email: ${data.session!.user.email}');
      }
      final session = data.session;
      if (mounted) {
        setState(() {
          // This will trigger a rebuild when auth state changes
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return session != null ? const HomeScreen() : const LoginScreen();
  }
}

// ------------------- LoginScreen -------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  // ---------------- EMAIL SIGN IN ----------------
  Future<void> signInWithEmail() async {
    setState(() => isLoading = true);

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } catch (e) {
      showError(e.toString());
    }

    setState(() => isLoading = false);
  }

  // ---------------- EMAIL SIGN UP ----------------
  Future<void> signUpWithEmail() async {
    setState(() => isLoading = true);

    try {
      await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      showMessage("Account created! You can now log in.");
    } catch (e) {
      showError(e.toString());
    }

    setState(() => isLoading = false);
  }

  // ---------------- GOOGLE SIGN IN ----------------
  Future<void> signInWithGoogle() async {
    setState(() => isLoading = true);
    
    try {
      print('***** Starting Google OAuth flow...');
      print('***** Current auth state: ${Supabase.instance.client.auth.currentSession != null}');
      
      // Use explicit redirectTo with proper scheme and force account picker
      final result = await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
        queryParams: {
          'prompt': 'select_account', // Forces Google account picker to appear
        },
      );
      
      print('***** OAuth launch result: $result');
      
      if (!result) {
        showError('Failed to launch Google Sign-In');
      } else {
        // OAuth browser launched successfully
        print('***** Google Sign-In browser opened successfully');
        print('***** Waiting for callback...');
      }
    } catch (e, stackTrace) {
      print('***** OAuth error: $e');
      print('***** Stack trace: $stackTrace');
      showError('Google Sign-In error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ---------------- HELPERS ----------------
  void showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Student Task Manager",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Organize your academic life",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // -------- EMAIL --------
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // -------- PASSWORD --------
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // -------- LOGIN --------
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : signInWithEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // -------- SIGN UP --------
                  TextButton(
                    onPressed: isLoading ? null : signUpWithEmail,
                    child: Text(
                      'Create new account',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // -------- GOOGLE --------
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.login, size: 20),
                      label: const Text(
                        'Sign in with Google',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: signInWithGoogle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------- HomeScreen -------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String userId;
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      userId = user.id;
      ensureStudentExists();
      fetchTasks();
    }
  }

  // Ensure student record exists
  Future<void> ensureStudentExists() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Check if student record exists
      final existing = await Supabase.instance.client
          .from('student')
          .select()
          .eq('id', userId)
          .maybeSingle();

      // If no student record, create one
      if (existing == null) {
        await Supabase.instance.client.from('student').insert({
          'id': userId,
          'email': user.email ?? '',
          'name': user.userMetadata?['full_name'] ?? user.email?.split('@')[0] ?? 'Student',
        });
        print('***** Student record created');
      }
    } catch (e) {
      print('***** Error ensuring student exists: $e');
    }
  }

  // Fetch tasks for logged-in user
  Future<void> fetchTasks() async {
    try {
      final res = await Supabase.instance.client
          .from('tasks')
          .select()
          .eq('student_id', userId)
          .order('due_date', ascending: true);
      
      if (mounted) {
        setState(() {
          tasks = (res as List).cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  // Show dialog to add a new task
  Future<void> showAddTaskDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                ListTile(
                  title: const Text('Due Date'),
                  subtitle: Text(
                    '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a task title')),
                  );
                  return;
                }

                try {
                  await Supabase.instance.client.from('tasks').insert({
                    'student_id': userId,
                    'title': titleController.text.trim(),
                    'description': descriptionController.text.trim(),
                    'due_date': selectedDate.toIso8601String(),
                    'is_done': false,
                  });

                  Navigator.pop(context);
                  fetchTasks();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Task added successfully!')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                  print('Error adding task: $e');
                }
              },
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  // Toggle task done/undone
  Future<void> toggleDone(String taskId, bool currentStatus) async {
    await Supabase.instance.client
        .from('tasks')
        .update({'is_done': !currentStatus})
        .eq('id', taskId);
    fetchTasks();
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    await Supabase.instance.client.from('tasks').delete().eq('id', taskId);
    fetchTasks();
  }

  // Confirm before deleting
  Future<void> confirmDelete(String taskId, String taskTitle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "$taskTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await deleteTask(taskId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted')),
        );
      }
    }
  }

  // Sign out
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      setState(() {}); // rebuild to go back to LoginScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedTasks = tasks.where((t) => t['is_done'] == true).toList();
    final pendingTasks = tasks.where((t) => t['is_done'] == false).toList();
    final totalTasks = tasks.length;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.school_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'My Tasks',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          if (totalTasks > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${completedTasks.length}/$totalTasks',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Stats Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tasks.isEmpty
                      ? 'Start adding your tasks'
                      : 'Keep up the great work!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Tasks List
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add your first task',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pending Tasks Section
                        if (pendingTasks.isNotEmpty) ...[
                          _buildSectionHeader(
                            context,
                            'Pending Tasks',
                            pendingTasks.length,
                            Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          ...pendingTasks.map((task) => _buildTaskCard(context, task, false)),
                          const SizedBox(height: 24),
                        ],
                        
                        // Completed Tasks Section
                        if (completedTasks.isNotEmpty) ...[
                          _buildSectionHeader(
                            context,
                            'Completed Tasks',
                            completedTasks.length,
                            Colors.green,
                          ),
                          const SizedBox(height: 12),
                          ...completedTasks.map((task) => _buildTaskCard(context, task, true)),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddTaskDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 4,
      ),
    );
  }

  // Build section header widget
  Widget _buildSectionHeader(BuildContext context, String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              title.contains('Completed') ? Icons.check_circle : Icons.pending_actions,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.9),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build task card widget
  Widget _buildTaskCard(BuildContext context, Map<String, dynamic> task, bool isCompleted) {
    final dueDate = DateTime.parse(task['due_date']);
    final isOverdue = dueDate.isBefore(DateTime.now()) && !isCompleted;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.white.withOpacity(0.7) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withOpacity(0.3)
              : isOverdue
                  ? Colors.red.withOpacity(0.3)
                  : Colors.orange.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Opacity(
        opacity: isCompleted ? 0.7 : 1.0,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green.withOpacity(0.15)
                  : isOverdue
                      ? Colors.red.withOpacity(0.15)
                      : Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : isOverdue
                      ? Icons.warning_rounded
                      : Icons.assignment_rounded,
              color: isCompleted
                  ? Colors.green
                  : isOverdue
                      ? Colors.red
                      : Colors.orange,
              size: 28,
            ),
          ),
          title: Text(
            task['title'],
            style: TextStyle(
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isCompleted ? Colors.grey : Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task['description'] != null && task['description'].toString().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  task['description'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverdue && !isCompleted
                      ? Colors.red.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: isOverdue && !isCompleted ? Colors.red : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: isOverdue && !isCompleted ? Colors.red : Colors.grey[600],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: isCompleted,
                onChanged: (_) => toggleDone(task['id'], isCompleted),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                color: Colors.red[400],
                onPressed: () => confirmDelete(task['id'], task['title']),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
