import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String currentUserId;
  final String chatWithUserId;

  const ChatPage({
    super.key,
    required this.currentUserId,
    required this.chatWithUserId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _db = FirebaseDatabase.instance.ref();
  final TextEditingController _messageController = TextEditingController();
  Uint8List? _pickedImage;

  late String chatRoomId;
  String? currentUserAvatar;
  String? chatWithUserAvatar;

  @override
  void initState() {
    super.initState();
    chatRoomId = _getChatRoomId(widget.currentUserId, widget.chatWithUserId);
    _loadAvatars();
  }

  String _getChatRoomId(String userA, String userB) {
    return userA.hashCode <= userB.hashCode ? '$userA\_$userB' : '$userB\_$userA';
  }

  Future<void> _loadAvatars() async {
    currentUserAvatar = await _fetchAvatar(widget.currentUserId, isStaff: false);
    chatWithUserAvatar = await _fetchAvatar(widget.chatWithUserId, isStaff: true);
    setState(() {});
  }

  Future<String?> _fetchAvatar(String userId, {bool isStaff = false}) async {
    final node = isStaff ? 'Staff' : 'Customer';
    final snapshot = await _db.child(node).get();
    if (snapshot.value == null) return null;

    final value = snapshot.value;

    if (value is Map) {
      final entry = value.entries.firstWhere(
          (e) => e.key.toString() == userId,
          orElse: () => MapEntry('', {}));
      if (entry.value is Map && entry.value['profile_image'] != null) {
        return entry.value['profile_image'].toString();
      }
    } else if (value is List) {
      final index = int.tryParse(userId);
      if (index != null && index > 0 && index <= value.length) {
        final entry = value[index - 1];
        if (entry is Map && entry['profile_image'] != null) {
          return entry['profile_image'].toString();
        }
      }
    }

    return null;
  }

  Stream<List<Map<String, dynamic>>> _messagesStream(String chatRoomId) async* {
    final ref = _db.child('Message/$chatRoomId');
    await for (final event in ref.onValue) {
      if (event.snapshot.value == null) {
        yield [];
        continue;
      }

      final value = event.snapshot.value;
      List<Map<String, dynamic>> messages = [];

      if (value is Map) {
        messages = value.values
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      } else if (value is List) {
        messages = value
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }

      messages.sort((a, b) => (a['timestamp'] ?? 0).compareTo(b['timestamp'] ?? 0));
      yield messages;
    }
  }

  Future<void> _sendMessage({String? imageBase64}) async {
    final text = _messageController.text.trim();
    if (text.isEmpty && imageBase64 == null) return;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final messageData = {
      'senderId': widget.currentUserId,
      'text': text,
      'image': imageBase64 ?? '',
      'timestamp': timestamp,
    };

    await _db.child('Message/$chatRoomId').push().set(messageData);
    _messageController.clear();
    setState(() => _pickedImage = null);
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null) {
      setState(() => _pickedImage = result.files.single.bytes);
    }
  }

  Widget _buildMessage(Map message) {
    final bool isMe = message['senderId'] == widget.currentUserId;
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(message['timestamp']);
    final String formattedTime = DateFormat('hh:mm a').format(time);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.green[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message['text'] != null && message['text'].isNotEmpty) Text(message['text']),
            if (message['image'] != null && message['image'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Image.memory(
                  Uint8List.fromList(List<int>.from(base64Decode(message['image']))),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            Text(formattedTime, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: chatWithUserAvatar != null
                  ? MemoryImage(base64Decode(chatWithUserAvatar!))
                  : null,
            ),
            const SizedBox(width: 10),
            Text('Chat with ${widget.chatWithUserId}'),
          ],
        ),
        backgroundColor: Colors.green[700],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _messagesStream(chatRoomId),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) return const Center(child: Text("No messages yet"));

                return ListView.builder(
                  reverse: false,
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      _buildMessage(messages[index]),
                );
              },
            ),
          ),
          if (_pickedImage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Image.memory(_pickedImage!, width: 150, height: 150),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => setState(() => _pickedImage = null),
                      child: const Icon(Icons.cancel, color: Colors.red),
                    ),
                  )
                ],
              ),
            ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.emoji_emotions, color: Colors.grey), onPressed: () {}),
              IconButton(icon: const Icon(Icons.image, color: Colors.grey), onPressed: _pickImage),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.green),
                onPressed: () => _sendMessage(
                  imageBase64: _pickedImage != null ? base64Encode(_pickedImage!) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
