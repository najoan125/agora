import 'package:dio/dio.dart';
import '../api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/exception/app_exception.dart';
import '../models/team/team.dart';

/// 팀 할일 관리 서비스
class TodoService {
  final ApiClient _apiClient;

  TodoService([ApiClient? apiClient]) : _apiClient = apiClient ?? ApiClient();

  /// 할일 목록 조회
  Future<Result<List<Todo>>> getTodos(String teamId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.teamTodos(teamId));
      final List<dynamic> data = response.data['content'] ?? response.data;
      final todos = data.map((json) => Todo.fromJson(json)).toList();
      return Success(todos);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 할일 생성
  Future<Result<Todo>> createTodo(
    String teamId, {
    required String title,
    String? description,
    TodoPriority priority = TodoPriority.medium,
    String? assignedToId,
    DateTime? dueDate,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.teamTodos(teamId),
        data: {
          'title': title,
          if (description != null) 'description': description,
          'priority': priority.name.toUpperCase(),
          if (assignedToId != null) 'assignedToId': assignedToId,
          if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
        },
      );
      return Success(Todo.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 할일 수정
  Future<Result<Todo>> updateTodo(
    String teamId,
    String todoId, {
    String? title,
    String? description,
    TodoPriority? priority,
    String? assignedToId,
    DateTime? dueDate,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.teamTodoById(teamId, todoId),
        data: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (priority != null) 'priority': priority.name.toUpperCase(),
          if (assignedToId != null) 'assignedToId': assignedToId,
          if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
        },
      );
      return Success(Todo.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 할일 삭제
  Future<Result<void>> deleteTodo(String teamId, String todoId) async {
    try {
      await _apiClient.delete(ApiEndpoints.teamTodoById(teamId, todoId));
      return const Success(null);
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }

  /// 할일 완료 처리
  Future<Result<Todo>> completeTodo(String teamId, String todoId) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.teamTodoComplete(teamId, todoId),
      );
      return Success(Todo.fromJson(response.data));
    } on DioException catch (e) {
      return Failure(e.requestOptions.extra['appException'] as AppException? ??
          AppException.unknown(error: e));
    } catch (e) {
      return Failure(AppException.unknown(error: e));
    }
  }
}
