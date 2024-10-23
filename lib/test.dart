// // lib/main.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'blocs/todo/todo_bloc.dart';
// import 'screens/todo_screen.dart';
// import 'theme/theme_cubit.dart';
// import 'services/storage_service.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   final storageService = StorageService();
  
//   runApp(
//     MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (context) => TodoBloc(storageService: storageService)..add(LoadTodos()),
//         ),
//         BlocProvider(
//           create: (context) => ThemeCubit(),
//         ),
//       ],
//       child: const TodoApp(),
//     ),
//   );
// }

// class TodoApp extends StatelessWidget {
//   const TodoApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ThemeCubit, ThemeData>(
//       builder: (context, theme) {
//         return MaterialApp(
//           title: 'Todo App',
//           theme: theme,
//           home: const TodoScreen(),
//         );
//       },
//     );
//   }
// }

// // lib/models/todo.dart
// import 'package:equatable/equatable.dart';
// import 'package:uuid/uuid.dart';

// enum TodoPriority { low, medium, high }
// enum TodoCategory { personal, work, shopping, health, other }

// class Todo extends Equatable {
//   final String id;
//   final String title;
//   final String description;
//   final DateTime? dueDate;
//   final TodoCategory category;
//   final TodoPriority priority;
//   final bool isCompleted;
//   final List<String> tags;
//   final String? notes;

//   Todo({
//     String? id,
//     required this.title,
//     this.description = '',
//     this.dueDate,
//     this.category = TodoCategory.other,
//     this.priority = TodoPriority.medium,
//     this.isCompleted = false,
//     this.tags = const [],
//     this.notes,
//   }) : id = id ?? const Uuid().v4();

//   Todo copyWith({
//     String? title,
//     String? description,
//     DateTime? dueDate,
//     TodoCategory? category,
//     TodoPriority? priority,
//     bool? isCompleted,
//     List<String>? tags,
//     String? notes,
//   }) {
//     return Todo(
//       id: id,
//       title: title ?? this.title,
//       description: description ?? this.description,
//       dueDate: dueDate ?? this.dueDate,
//       category: category ?? this.category,
//       priority: priority ?? this.priority,
//       isCompleted: isCompleted ?? this.isCompleted,
//       tags: tags ?? this.tags,
//       notes: notes ?? this.notes,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'description': description,
//       'dueDate': dueDate?.toIso8601String(),
//       'category': category.index,
//       'priority': priority.index,
//       'isCompleted': isCompleted,
//       'tags': tags,
//       'notes': notes,
//     };
//   }

//   factory Todo.fromJson(Map<String, dynamic> json) {
//     return Todo(
//       id: json['id'],
//       title: json['title'],
//       description: json['description'],
//       dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
//       category: TodoCategory.values[json['category']],
//       priority: TodoPriority.values[json['priority']],
//       isCompleted: json['isCompleted'],
//       tags: List<String>.from(json['tags']),
//       notes: json['notes'],
//     );
//   }

//   @override
//   List<Object?> get props => [
//         id,
//         title,
//         description,
//         dueDate,
//         category,
//         priority,
//         isCompleted,
//         tags,
//         notes,
//       ];
// }

// // lib/models/todo_statistics.dart
// class TodoStatistics {
//   final int totalTodos;
//   final int completedTodos;
//   final Map<TodoCategory, int> categoryStats;
//   final Map<DateTime, int> completionTrend;

//   TodoStatistics({
//     required this.totalTodos,
//     required this.completedTodos,
//     required this.categoryStats,
//     required this.completionTrend,
//   });

//   double get completionRate => 
//     totalTodos > 0 ? (completedTodos / totalTodos) * 100 : 0;

//   factory TodoStatistics.fromTodos(List<Todo> todos) {
//     final categoryStats = <TodoCategory, int>{};
//     final completionTrend = <DateTime, int>{};
    
//     for (final todo in todos) {
//       categoryStats[todo.category] = 
//         (categoryStats[todo.category] ?? 0) + 1;
      
//       if (todo.isCompleted && todo.dueDate != null) {
//         final date = DateTime(
//           todo.dueDate!.year,
//           todo.dueDate!.month,
//           todo.dueDate!.day,
//         );
//         completionTrend[date] = (completionTrend[date] ?? 0) + 1;
//       }
//     }

//     return TodoStatistics(
//       totalTodos: todos.length,
//       completedTodos: todos.where((todo) => todo.isCompleted).length,
//       categoryStats: categoryStats,
//       completionTrend: completionTrend,
//     );
//   }
// }

// // lib/blocs/todo/todo_bloc.dart
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';
// import '../../models/todo.dart';
// import '../../services/storage_service.dart';

// // Events
// abstract class TodoEvent extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class LoadTodos extends TodoEvent {}

// class AddTodo extends TodoEvent {
//   final Todo todo;
//   AddTodo(this.todo);
//   @override
//   List<Object?> get props => [todo];
// }

// class UpdateTodo extends TodoEvent {
//   final Todo todo;
//   UpdateTodo(this.todo);
//   @override
//   List<Object?> get props => [todo];
// }

// class DeleteTodo extends TodoEvent {
//   final String id;
//   DeleteTodo(this.id);
//   @override
//   List<Object?> get props => [id];
// }

// class ToggleTodo extends TodoEvent {
//   final String id;
//   ToggleTodo(this.id);
//   @override
//   List<Object?> get props => [id];
// }

// // States
// abstract class TodoState extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class TodoInitial extends TodoState {}

// class TodoLoading extends TodoState {}

// class TodoLoaded extends TodoState {
//   final List<Todo> todos;
//   TodoLoaded(this.todos);
//   @override
//   List<Object?> get props => [todos];
// }

// class TodoError extends TodoState {
//   final String message;
//   TodoError(this.message);
//   @override
//   List<Object?> get props => [message];
// }

// // Bloc
// class TodoBloc extends Bloc<TodoEvent, TodoState> {
//   final StorageService storageService;

//   TodoBloc({required this.storageService}) : super(TodoInitial()) {
//     on<LoadTodos>(_onLoadTodos);
//     on<AddTodo>(_onAddTodo);
//     on<UpdateTodo>(_onUpdateTodo);
//     on<DeleteTodo>(_onDeleteTodo);
//     on<ToggleTodo>(_onToggleTodo);
//   }

//   Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
//     emit(TodoLoading());
//     try {
//       final todos = await storageService.loadTodos();
//       emit(TodoLoaded(todos));
//     } catch (e) {
//       emit(TodoError(e.toString()));
//     }
//   }

//   Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
//     final currentState = state;
//     if (currentState is TodoLoaded) {
//       final updatedTodos = List<Todo>.from(currentState.todos)..add(event.todo);
//       await storageService.saveTodos(updatedTodos);
//       emit(TodoLoaded(updatedTodos));
//     }
//   }

//   Future<void> _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) async {
//     final currentState = state;
//     if (currentState is TodoLoaded) {
//       final updatedTodos = currentState.todos.map((todo) {
//         return todo.id == event.todo.id ? event.todo : todo;
//       }).toList();
//       await storageService.saveTodos(updatedTodos);
//       emit(TodoLoaded(updatedTodos));
//     }
//   }

//   Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
//     final currentState = state;
//     if (currentState is TodoLoaded) {
//       final updatedTodos = currentState.todos.where((todo) {
//         return todo.id != event.id;
//       }).toList();
//       await storageService.saveTodos(updatedTodos);
//       emit(TodoLoaded(updatedTodos));
//     }
//   }

//   Future<void> _onToggleTodo(ToggleTodo event, Emitter<TodoState> emit) async {
//     final currentState = state;
//     if (currentState is TodoLoaded) {
//       final updatedTodos = currentState.todos.map((todo) {
//         return todo.id == event.id
//             ? todo.copyWith(isCompleted: !todo.isCompleted)
//             : todo;
//       }).toList();
//       await storageService.saveTodos(updatedTodos);
//       emit(TodoLoaded(updatedTodos));
//     }
//   }
// }

// // lib/services/storage_service.dart
// import 'dart:convert';
// import 'package:shared_preferences.dart';
// import '../models/todo.dart';

// class StorageService {
//   static const String _todosKey = 'todos';
//   final SharedPreferences _prefs;

//   StorageService() : _prefs = await SharedPreferences.getInstance();

//   Future<List<Todo>> loadTodos() async {
//     final todosJson = _prefs.getString(_todosKey);
//     if (todosJson == null) return [];
    
//     final List<dynamic> decoded = json.decode(todosJson);
//     return decoded.map((json) => Todo.fromJson(json)).toList();
//   }

//   Future<void> saveTodos(List<Todo> todos) async {
//     final encodedTodos = json.encode(
//       todos.map((todo) => todo.toJson()).toList(),
//     );
//     await _prefs.setString(_todosKey, encodedTodos);
//   }
// }

// // lib/screens/todo_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../blocs/todo/todo_bloc.dart';
// import '../widgets/animated_todo_card.dart';
// import 'add_todo_screen.dart';

// class TodoScreen extends StatelessWidget {
//   const TodoScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Todo List'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.analytics),
//             onPressed: () => Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const StatisticsScreen(),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: BlocBuilder<TodoBloc, TodoState>(
//         builder: (context, state) {
//           if (state is TodoLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
          
//           if (state is TodoError) {
//             return Center(child: Text(state.message));
//           }
          
//           if (state is TodoLoaded) {
//             if (state.todos.isEmpty) {
//               return const Center(
//                 child: Text('No todos yet. Add some!'),
//               );
//             }
            
//             return ListView.builder(
//               itemCount: state.todos.length,
//               itemBuilder: (context, index) {
//                 final todo = state.todos[index];
//                 return AnimatedTodoCard(todo: todo);
//               },
//             );
//           }
          
//           return const SizedBox.shrink();
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => const AddTodoScreen(),
//           ),
//         ),
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

// // lib/widgets/animated_todo_card.dart
// import 'package:flutter/material.dart';
// import '../models/todo.dart';
// import '../utils/animations_helper.dart';

// class AnimatedTodoCard extends StatelessWidget {
//   final Todo todo;
  
//   const AnimatedTodoCard({
//     Key? key,
//     required this.todo,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Dismissible(
//       key: Key(todo.id),
//       background: Container(
//         color: Colors.red,
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.only(right: 16.0),
//         child: const Icon(Icons.delete, color: Colors.white),
//       ),
//       onDismissed: (_) {
//         context.read<TodoBloc>().add(DeleteTodo(todo.id));
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         decoration: BoxDecoration(
//           color: todo.isCompleted
//               ? Colors.grey.withOpacity(0.1)
//               : Colors.white,
//           border: Border(
//             left: BorderSide(
//               color: _getPriorityColor(todo.priority),
//               width: 4,
//             ),
//           ),
//         ),
//         child: ListTile(
//           leading: Checkbox(
//             value: todo.isCompleted,
//             onChanged: (_) {
//               context.read<TodoBloc>().add(ToggleTodo(todo.id));
//             },
//           ),
//           title: Text(
//             todo.title,
//             style: TextStyle(
//               decoration: todo.isCompleted
//                   ? TextDecoration.lineThrough
//                   : null,
//             ),
//           ),
//           subtitle: Text(todo.description),
//           trailing: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (todo.dueDate != null)
//                 Text(
//                   DateFormat('MMM d').format(todo.dueDate!),
//                   style: Theme.of(context).textTheme.caption,
//                 ),
//               const SizedBox(width: 8),
//               Chip(
//                 label: Text(
//                   todo.category.toString().split('.').last,
//                   style: const TextStyle(fontSize: 12),
//                 ),
//                 backgroundColor: _getCategoryColor(todo.category),
//               ),
//             ],
//           ),
//           onTap: () => Navigator.push(
//             context,
//             Material