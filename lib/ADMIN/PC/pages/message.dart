import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class MessagePage extends StatefulWidget {
  final String staffId;
  final String staffAvatar;

  const MessagePage({
    super.key,
    required this.staffId,
    required this.staffAvatar,
  });

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final DatabaseReference _customerRef = FirebaseDatabase.instance.ref('Customer');
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  List<Map<String, dynamic>> customers = [];

  TextEditingController _messageController = TextEditingController();
  Uint8List? _pickedImage;
  late String chatRoomId;
  String? currentUserAvatar;
  String? chatWithUserAvatar;
  String? chatWithUserName;
  String? selectedCustomerId;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  void _fetchCustomers() {
    _customerRef.onValue.listen((event) {
      if (!event.snapshot.exists) {
        setState(() => customers = []);
        return;
      }

      List<Map<String, dynamic>> temp = [];
      for (var child in event.snapshot.children) {
        final data = child.value as Map<dynamic, dynamic>;
        temp.add({
          'id': data['customer_id']?.toString() ?? '',
          'name': '${data['customer_Fname'] ?? ''} ${data['customer_Lname'] ?? ''}',
          'avatar': data['profile_image'] ?? '',
          'lastMessage': data['lastMessage'] ?? "Tap to chat",
          'time': data['lastMessageTime'] ?? "",
        });
      }

      setState(() => customers = temp);
    });
  }

  String _getChatRoomId(String userA, String userB) {
    return userA.hashCode <= userB.hashCode ? '$userA\_$userB' : '$userB\_$userA';
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
      'senderId': widget.staffId,
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
    final bool isMe = message['senderId'] == widget.staffId;
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

  void _openChat(Map<String, dynamic> customer) async {
    selectedCustomerId = customer['id'];
    chatRoomId = _getChatRoomId(widget.staffId, selectedCustomerId!);
    chatWithUserAvatar = await _fetchAvatar(selectedCustomerId!, isStaff: false);
    chatWithUserName = customer['name'];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (selectedCustomerId != null) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppBar(
            backgroundColor: const Color.fromARGB(255, 223, 217, 217),
            elevation: 1,
            leadingWidth: 50,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
              onPressed: () {
                setState(() {
                  selectedCustomerId = null;
                  _pickedImage = null;
                  _messageController.clear();
                });
              },
            ),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: chatWithUserAvatar != null
                      ? MemoryImage(base64Decode(chatWithUserAvatar!))
                      : null,
                  child: chatWithUserAvatar == null
                      ? Text(
                          chatWithUserName != null && chatWithUserName!.isNotEmpty
                              ? chatWithUserName![0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    chatWithUserName ?? 'Chat',
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

    if (customers.isEmpty) {
      return const Center(child: Text("No customers found"));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];

        ImageProvider? avatarImage;
        if (customer['avatar'] != null && customer['avatar'] != '') {
          avatarImage = MemoryImage(base64Decode(customer['avatar']));
        }

        return GestureDetector(
          onTap: () => _openChat(customer),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: avatarImage,
                  child: avatarImage == null
                      ? Text(
                          customer['name'][0].toUpperCase(),
                          style: const TextStyle(fontSize: 20),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer['name'],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customer['lastMessage'],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Text(
                  customer['time'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
