import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class MessagePage extends StatefulWidget {
  final String customerId;       // Logged-in customer ID
  final String customerAvatar;   // Optional customer avatar

  const MessagePage({super.key, required this.customerId, required this.customerAvatar});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final DatabaseReference _staffRef = FirebaseDatabase.instance.ref('Staff');
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  String? adminId;
  String? adminName;
  String? adminAvatar;

  // Chat variables
  TextEditingController _messageController = TextEditingController();
  Uint8List? _pickedImage;
  late String chatRoomId;

  @override
  void initState() {
    super.initState();
    _fetchAdmin();
  }

  Future<void> _fetchAdmin() async {
    final snapshot = await _staffRef.get();
    if (snapshot.exists) {
      final firstStaff = snapshot.children.first.value as Map<dynamic, dynamic>;
      setState(() {
        adminId = firstStaff['staff_id']?.toString() ?? '';
        adminName =
            '${firstStaff['staff_Fname'] ?? ''} ${firstStaff['staff_Lname'] ?? ''}'.trim();
        adminAvatar = firstStaff['profile_image']?.toString();
        chatRoomId = _getChatRoomId(widget.customerId, adminId!);
      });
    }
  }

  String _getChatRoomId(String userA, String userB) {
    return userA.hashCode <= userB.hashCode ? '$userA\_$userB' : '$userB\_$userA';
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
      'senderId': widget.customerId,
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
    if (result != null) setState(() => _pickedImage = result.files.single.bytes);
  }

  Widget _buildMessage(Map message) {
    final bool isMe = message['senderId'] == widget.customerId;
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(message['timestamp']);
    final String formattedTime = DateFormat('hh:mm a').format(time);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isMe ? Colors.green[400] : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(6),
            bottomRight: isMe ? const Radius.circular(6) : const Radius.circular(18),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message['text'] != null && message['text'].isNotEmpty)
              Text(
                message['text'],
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
            if (message['image'] != null && message['image'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
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
            const SizedBox(height: 4),
            Text(
              formattedTime,
              style: TextStyle(fontSize: 17, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (adminId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70), // taller header
        child: AppBar(
          backgroundColor: const Color.fromARGB(255, 223, 217, 217),
          elevation: 1,
          // Back button removed
          title: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: adminAvatar != null
                    ? MemoryImage(base64Decode(adminAvatar!))
                    : null,
                child: adminAvatar == null
                    ? Text(
                        adminName != null && adminName!.isNotEmpty
                            ? adminName![0].toUpperCase()
                            : '?',
                        style: const TextStyle(fontSize: 20, color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  adminName ?? 'Admin',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          centerTitle: false,
        ),
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
                  itemBuilder: (context, index) => _buildMessage(messages[index]),
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
                  ),
                ],
              ),
            ),
          // Bottom input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions, color: Colors.grey, size: 28),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.grey, size: 28),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(fontSize: 18),
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.green[400],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _sendMessage(
                        imageBase64: _pickedImage != null ? base64Encode(_pickedImage!) : null),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
