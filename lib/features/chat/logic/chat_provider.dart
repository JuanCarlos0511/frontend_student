/// State management for chat.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as sio;
import 'package:uni_social_student/core/network/api_constants.dart';
import 'package:uni_social_student/features/chat/data/models/chat_models.dart';
import 'package:uni_social_student/features/chat/data/repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _repository;

  ChatProvider({ChatRepository? repository})
      : _repository = repository ?? ChatRepository();

  List<ChatRoomModel> _rooms = [];
  List<ChatMessageModel> _messages = [];
  bool _isLoadingRooms = false;
  bool _isLoadingMessages = false;
  bool _isSending = false;
  String _errorMessage = '';
  int? _activeRoomId;
  int? _currentStudentId;
  sio.Socket? _socket;

  List<ChatRoomModel> get rooms => _rooms;
  List<ChatMessageModel> get messages => _messages;
  bool get isLoadingRooms => _isLoadingRooms;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSending => _isSending;
  String get errorMessage => _errorMessage;
  int? get currentStudentId => _currentStudentId;

  /// Initialize socket connection.
  Future<void> initSocket() async {
    if (_socket != null) return;

    final prefs = await SharedPreferences.getInstance();
    _currentStudentId = prefs.getInt('student_id');
    final token = prefs.getString('auth_token');

    _socket = sio.io(
      ApiConstants.wsUrl,
      sio.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.on('new_message', (data) {
      if (data is Map<String, dynamic>) {
        final msg = ChatMessageModel.fromJson(data);
        if (msg.chatRoomId == _activeRoomId) {
          _messages.add(msg);
          notifyListeners();
        }
        // Refresh rooms list to update last message
        loadRooms();
      }
    });
  }

  /// Load all chat rooms.
  Future<void> loadRooms() async {
    _isLoadingRooms = true;
    notifyListeners();

    final response = await _repository.getRooms();

    if (response.success && response.data != null) {
      final list = response.data as List;
      _rooms = list
          .map((json) => ChatRoomModel.fromJson(json as Map<String, dynamic>))
          .toList();
      _errorMessage = '';
    } else {
      _errorMessage = response.message;
    }

    _isLoadingRooms = false;
    notifyListeners();
  }

  /// Load messages for a room and join socket room.
  Future<void> loadMessages(int roomId) async {
    _activeRoomId = roomId;
    _isLoadingMessages = true;
    _messages = [];
    notifyListeners();

    // Join socket room
    _socket?.emit('join_chat', roomId);

    final response = await _repository.getMessages(roomId);

    if (response.success && response.data != null) {
      final list = response.data as List;
      _messages = list
          .map((json) =>
              ChatMessageModel.fromJson(json as Map<String, dynamic>))
          .toList();
      _errorMessage = '';
    } else {
      _errorMessage = response.message;
    }

    _isLoadingMessages = false;
    notifyListeners();
  }

  /// Send a message.
  Future<bool> sendMessage(int roomId, String message, {int? referencedProductId}) async {
    _isSending = true;
    notifyListeners();

    final response = await _repository.sendMessage(roomId, message, referencedProductId: referencedProductId);

    if (response.success && response.data != null) {
      final msg =
          ChatMessageModel.fromJson(response.data as Map<String, dynamic>);
      _messages.add(msg);

      // Emit via socket to other participants
      _socket?.emit('send_message', {
        'roomId': roomId,
        'message': response.data,
      });
    }

    _isSending = false;
    notifyListeners();
    return response.success;
  }

  /// Find or create a room — used by market "Contactar" button.
  Future<ChatRoomModel?> findOrCreateRoom({
    required int sellerId,
    required int productId,
    String? productName,
  }) async {
    final response = await _repository.findOrCreateRoom(
      sellerId: sellerId,
      productId: productId,
      productName: productName,
    );

    if (response.success && response.data != null) {
      final room =
          ChatRoomModel.fromJson(response.data as Map<String, dynamic>);
      await loadRooms();
      return room;
    }
    _errorMessage = response.message;
    notifyListeners();
    return null;
  }

  /// Leave active room socket.
  void leaveRoom() {
    if (_activeRoomId != null) {
      _socket?.emit('leave_chat', _activeRoomId);
      _activeRoomId = null;
    }
  }

  @override
  void dispose() {
    _socket?.dispose();
    super.dispose();
  }
}
