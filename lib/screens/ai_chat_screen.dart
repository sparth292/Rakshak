import 'package:flutter/material.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  _AIChatScreenState createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isFirstMessage = true;

  @override
  void initState() {
    super.initState();
    // Add welcome message when screen opens
    _messages.add(ChatMessage(
      text: "Hi! I'm your Safety Assistant. How can I help you today?",
      isUser: false,
    ));
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text;
    setState(() {
      // Add user message
      _messages.insert(
          0,
          ChatMessage(
            text: userMessage,
            isUser: true,
          ));
      // Add processing message
      _messages.insert(
          0,
          ChatMessage(
            text: "Let me help you with that...",
            isUser: false,
            isProcessing: true,
          ));
    });
    _messageController.clear();

    // Wait for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Replace processing message with actual response
    setState(() {
      _messages.removeAt(0); // Remove processing message
      _messages.insert(
          0,
          ChatMessage(
            text: _getContextualResponse(userMessage.toLowerCase()),
            isUser: false,
          ));
    });
  }

  String _getContextualResponse(String message) {
    // Initialize default response
    String response =
        "I can help you with using any feature of the app - like SOS alerts, WaySecure tracking, finding nearby services, or managing emergency contacts. What would you like to know?";

    // Thank you responses
    if (message.contains('thank') ||
        message.contains('thanks') ||
        message.contains('thankyou') ||
        message.contains('dhanyawad')) {
      response =
          "You're welcome! I'm always here to help keep you safe. Feel free to ask me anything!";
    }
    // WaySecure related
    else if (message.contains('waysecure')) {
      response =
          "WaySecure helps track your journey safely. It monitors your location and alerts your emergency contacts if you deviate from your route. Just tap the WaySecure card on the home screen to start tracking your journey.";
    }
    // Nearby services related
    else if (message.contains('nearby') ||
        message.contains('service') ||
        message.contains('location')) {
      response =
          "On your home screen, you'll see icons for hospitals 🏥, police stations 👮‍♂️, pharmacies 💊, and more. Just tap any icon to find the closest ones to you. It'll show you directions and contact details too.";
    }
    // SOS related
    else if (message.contains('sos') || message.contains('emergency')) {
      response =
          "In an emergency, you have two quick options:\n1. Just say 'SOS' loudly - your voice will trigger the alert\n2. Or press the SOS button on your screen\nThis will immediately alert your emergency contacts with your location.";
    }
    // CareConnect related
    else if (message.contains('care') || message.contains('contact')) {
      response =
          "CareConnect lets you add trusted people who'll be notified in emergencies. Open CareConnect from the home screen, tap the + button to add contacts from your phone or enter them manually.";
    }
    // Help or general queries
    else if (message.contains('help') ||
        message.contains('what') ||
        message.contains('how')) {
      response =
          "I can help you with:\n- Emergency SOS alerts\n- Safe route tracking with WaySecure\n- Finding nearby emergency services\n- Managing your emergency contacts\n\nWhat would you like to know more about?";
    }

    return response; // Always returns a non-null String
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF78143C),
        title: const Text(
          'Safety Assistant',
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            const CircleAvatar(
              backgroundColor: Color(0xFF78143C),
              child: Icon(Icons.smart_toy, color: Colors.white),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: message.isUser ? const Color(0xFFFFC1E3) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(15),
                  topRight: const Radius.circular(15),
                  bottomLeft: message.isUser
                      ? const Radius.circular(15)
                      : const Radius.circular(0),
                  bottomRight: message.isUser
                      ? const Radius.circular(0)
                      : const Radius.circular(15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: message.isProcessing
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.text,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF78143C)),
                          ),
                        ),
                      ],
                    )
                  : Text(
                      message.text,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.black87,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          if (message.isUser)
            const CircleAvatar(
              backgroundColor: Color(0xFFE91E63),
              child: Icon(Icons.person, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -2),
            blurRadius: 4.0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                hintStyle: const TextStyle(
                  color: Colors.black38,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8.0),
          GestureDetector(
            onTap: _sendMessage,
            child: const CircleAvatar(
              backgroundColor: Color(0xFFE91E63),
              radius: 25,
              child: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isProcessing;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.isProcessing = false,
  });
}
