/// State management for the feed (posts).
import 'package:flutter/material.dart';
import 'package:uni_social_student/features/feed/data/models/post_model.dart';
import 'package:uni_social_student/features/feed/data/models/reply_model.dart';
import 'package:uni_social_student/features/feed/data/repositories/feed_repository.dart';

enum FeedStatus { idle, loading, success, error }

class FeedProvider extends ChangeNotifier {
  final FeedRepository _repository;

  FeedProvider({FeedRepository? repository})
      : _repository = repository ?? FeedRepository();

  FeedStatus _status = FeedStatus.idle;
  String _message = '';
  List<PostModel> _posts = [];

  FeedStatus get status => _status;
  String get message => _message;
  List<PostModel> get posts => List.unmodifiable(_posts);
  bool get isLoading => _status == FeedStatus.loading;

  /// Carga todas las publicaciones del feed.
  Future<void> loadPosts() async {
    _status = FeedStatus.loading;
    notifyListeners();

    final response = await _repository.fetchPosts();

    if (response.success && response.data != null) {
      _posts = (response.data as List)
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();
      _status = FeedStatus.success;
      _message = '';
    } else {
      _status = FeedStatus.error;
      _message = response.message;
    }
    notifyListeners();
  }

  /// Crea una nueva publicación.
  Future<bool> createPost({
    required String content,
    String? imagePath,
  }) async {
    final response = await _repository.createPost(
      content: content,
      imagePath: imagePath,
    );

    if (response.success) {
      // Recargar la lista completa para tener el post con datos del autor
      await loadPosts();
      return true;
    } else {
      _message = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Actualiza una publicación existente.
  Future<bool> updatePost({
    required int postId,
    required String content,
    String? imagePath,
  }) async {
    final response = await _repository.updatePost(
      postId: postId,
      content: content,
      imagePath: imagePath,
    );

    if (response.success) {
      await loadPosts();
      return true;
    } else {
      _message = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Elimina una publicación.
  Future<bool> deletePost(int postId) async {
    final response = await _repository.deletePost(postId);

    if (response.success) {
      _posts.removeWhere((p) => p.id == postId);
      notifyListeners();
      return true;
    } else {
      _message = response.message;
      notifyListeners();
      return false;
    }
  }

  // ── Respuestas (Replies) ─────────────────────────────────────

  // Mapea postId -> Lista de respuestas
  final Map<int, List<ReplyModel>> _replies = {};
  Map<int, List<ReplyModel>> get replies => Map.unmodifiable(_replies);

  bool _isLoadingReplies = false;
  bool get isLoadingReplies => _isLoadingReplies;

  /// Carga las respuestas de un post específico.
  Future<void> loadReplies(int postId) async {
    _isLoadingReplies = true;
    notifyListeners();

    final response = await _repository.fetchReplies(postId);

    if (response.success && response.data != null) {
      _replies[postId] = (response.data as List)
          .map((json) => ReplyModel.fromJson(json as Map<String, dynamic>))
          .toList();
      _message = '';
    } else {
      _message = response.message;
    }

    _isLoadingReplies = false;
    notifyListeners();
  }

  /// Crea una nueva respuesta a un post.
  Future<bool> createReply({
    required int postId,
    required String content,
  }) async {
    final response = await _repository.createReply(
      postId: postId,
      content: content,
    );

    if (response.success) {
      await loadReplies(postId);
      await loadPosts(); // Recargar posts para actualizar el replyCount
      return true;
    } else {
      _message = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Actualiza una respuesta existente.
  Future<bool> updateReply({
    required int postId,
    required int replyId,
    required String content,
  }) async {
    final response = await _repository.updateReply(
      postId: postId,
      replyId: replyId,
      content: content,
    );

    if (response.success) {
      await loadReplies(postId);
      return true;
    } else {
      _message = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Elimina una respuesta.
  Future<bool> deleteReply(int postId, int replyId) async {
    final response = await _repository.deleteReply(postId, replyId);

    if (response.success) {
      _replies[postId]?.removeWhere((r) => r.id == replyId);
      await loadPosts(); // Recargar posts para actualizar el replyCount
      notifyListeners();
      return true;
    } else {
      _message = response.message;
      notifyListeners();
      return false;
    }
  }
}
