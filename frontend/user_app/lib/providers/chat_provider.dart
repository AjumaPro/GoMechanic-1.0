import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:gomechanic_user/config/api.dart';

class ChatProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _baseUrl = 'http://localhost:8007/api'; // Update with your API URL
  final _wsUrl = 'ws://localhost:8007/ws/chat/'; // Change to your WebSocket URL
  WebSocketChannel? _channel;
  final Map<String, List<Map<String, dynamic>>> _messages = {};
  final Map<String, Map<String, dynamic>> _chats = {};
  bool _isLoading = false;

  Map<String, List<Map<String, dynamic>>> get messages => _messages;
  Map<String, Map<String, dynamic>> get chats => _chats;
  bool get isLoading => _isLoading;

  Future<void> loadChats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/chats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Api.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _chats.clear();
        for (final chat in data['chats']) {
          _chats[chat['id']] = chat;
        }
      } else {
        throw Exception('Failed to load chats');
      }
    } catch (e) {
      debugPrint('Error loading chats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages(String chatId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/chats/$chatId/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Api.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _messages[chatId] = List<Map<String, dynamic>>.from(data['messages']);
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String chatId, String content) async {
    try {
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/chats/$chatId/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Api.token}',
        },
        body: json.encode({
          'content': content,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _messages[chatId]?.add(data['message']);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }

  Future<bool> uploadAttachment(String chatId, String filePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${Api.baseUrl}/chats/$chatId/attachments'),
      );

      request.headers['Authorization'] = 'Bearer ${Api.token}';
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
      ));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);

      if (response.statusCode == 201) {
        _messages[chatId]?.add(data['message']);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error uploading attachment: $e');
      return false;
    }
  }

  void clearMessages(String chatId) {
    _messages.remove(chatId);
    notifyListeners();
  }

  Future<bool> archiveChat(String chatId) async {
    try {
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/chats/$chatId/archive'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Api.token}',
        },
      );

      if (response.statusCode == 200) {
        if (_chats.containsKey(chatId)) {
          _chats[chatId]!['is_archived'] = true;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error archiving chat: $e');
      return false;
    }
  }

  Future<bool> unarchiveChat(String chatId) async {
    try {
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/chats/$chatId/unarchive'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Api.token}',
        },
      );

      if (response.statusCode == 200) {
        if (_chats.containsKey(chatId)) {
          _chats[chatId]!['is_archived'] = false;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error unarchiving chat: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}
