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
  String? chatWithUserName;

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
    chatWithUserName = await _fetchFullName(widget.chatWithUserId, isStaff: true);
    setState(() {});
  }

  Future<String?> _fetchAvatar(String userId, {bool isStaff = false}) async {
  final node = isStaff ? 'Staff' : 'Customer';
  final snapshot = await _db.child(node).get();
  if (!snapshot.exists) return null;

  final value = snapshot.value;

  if (value is List) {
    for (var entry in value) {
      if (entry is Map) {
        final idField = isStaff ? entry['staff_id'] : entry['customer_id'];
        if (idField.toString() == userId) {
          return entry['profile_image']?.toString();
        }
      }
    }
  }

  return null;
}

Future<String?> _fetchFullName(String userId, {bool isStaff = false}) async {
  final node = isStaff ? 'Staff' : 'Customer';
  final snapshot = await _db.child(node).get();
  if (!snapshot.exists) return null;

  final value = snapshot.value;

  if (value is List) {
    for (var entry in value) {
      if (entry is Map) {
        final idField = isStaff ? entry['staff_id'] : entry['customer_id'];
        if (idField.toString() == userId) {
          final firstName = isStaff ? entry['staff_Fname'] : entry['customer_Fname'];
          final lastName = isStaff ? entry['staff_Lname'] : entry['customer_Lname'];
          return '$firstName $lastName'.trim();
        }
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
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.all(16), 
      decoration: BoxDecoration(
        color: isMe ? Colors.green[300] : Colors.grey[300],
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(0),
          bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(18),
        ),
      ),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (message['text'] != null && message['text'].isNotEmpty)
            Text(
              message['text'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),

          if (message['image'] != null && message['image'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  Uint8List.fromList(List<int>.from(base64Decode(message['image']))),
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          const SizedBox(height: 6),

          Text(
            formattedTime,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
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
          Text(chatWithUserName ?? 'Chat'),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 223, 217, 217),
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
                icon: const Icon(Icons.send, color: Colors.black),
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
