import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MessagePage extends StatefulWidget {
  final String customerId;
  final String customerAvatar;

  const MessagePage({
    super.key,
    required this.customerId,
    required this.customerAvatar,
  });

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  late DatabaseReference _chatRef;
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _chatRef = FirebaseDatabase.instance.ref('Chats/${widget.customerId}_admin/messages');

    _chatRef.onValue.listen((event) {
      final snapshot = event.snapshot;
      List<Map<String, dynamic>> newMessages = [];
      if (snapshot.exists) {
        for (var child in snapshot.children) {
          final data = Map<String, dynamic>.from(child.value as Map);
          newMessages.add(data);
        }
      }
      setState(() {
        messages = newMessages;
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = {
      'sender': 'customer',
      'message': text,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _chatRef.push().set(newMessage);
    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Admin'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isCustomer = msg['sender'] == 'customer';
                return Align(
                  alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCustomer ? Colors.green[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg['message'] ?? ''),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
