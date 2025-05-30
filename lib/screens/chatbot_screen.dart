import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:user_end/theme/vibrant_theme.dart';

class ChatBotScreen extends StatefulWidget {
  final String userEmail;
  final String userName;

  const ChatBotScreen({
    super.key,
    required this.userEmail,
    required this.userName,
  });

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  static const String _apiKey = "AIzaSyANcLW4GibTK4q29-9TP77chbhEPpik34k";
  final GenerativeModel _model = GenerativeModel(model: 'gemini-1.5-flash-002', apiKey: _apiKey);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'sender': 'bot',
      'text': 'Hello ${widget.userName}! How can I assist you today?',
      'date': DateTime.now(),
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _isLoading = true;
      _messages.add({
        'sender': 'user',
        'text': userMessage,
        'date': DateTime.now(),
      });
      _messages.add({
        'sender': 'bot',
        'text': 'Typing...',
        'date': DateTime.now(),
      });
      _controller.clear();
    });

    _scrollToBottom();

    final botResponse = await _getBotResponse(userMessage);
    setState(() {
      _messages.removeWhere((msg) => msg['text'] == 'Typing...');
      _messages.add({
        'sender': 'bot',
        'text': botResponse,
        'date': DateTime.now(),
      });
      _isLoading = false;
    });

    _scrollToBottom();
  }

  Future<String> _getBotResponse(String userMessage) async {
    // Log input for debugging
    debugPrint('Sending message to Gemini API: "$userMessage"');

    // Double-check for empty input
    if (userMessage.isEmpty) {
      debugPrint('Error: Empty message sent to API');
      return "Error: No message provided. Please type something.";
    }

    try {
      final content = [Content.text(userMessage)];
      debugPrint('API request content: $content');
      final response = await _model.generateContent(content);
      final responseText = response.text ?? "Sorry, I couldn't process that. Try again!";
      debugPrint('API response: $responseText');
      return responseText;
    } catch (e) {
      debugPrint('API error: $e');
      if (e.toString().contains('model not found')) {
        return "Model not available. Please check available models or contact support.";
      } else if (e.toString().contains('empty parameter')) {
        return "Error: Invalid request. Please try again or contact support.";
      }
      // Fallback to placeholder logic if API fails
      userMessage = userMessage.toLowerCase();
      if (userMessage.contains('hello') || userMessage.contains('hi')) {
        return 'Hi! How can I help you today?';
      } else if (userMessage.contains('job')) {
        return 'Looking for jobs? You can check the Jobs section for opportunities!';
      } else if (userMessage.contains('quiz')) {
        return 'Interested in quizzes? Head to the Quizzes section to test your skills!';
      }
      else if(userMessage.contains("where i can take quizes")||userMessage.contains("where i can find jobs")){
        return 'On our platform you can find quizzes section and can check your knowledge';
      }
      return "Error connecting to the chatbot service: $e";
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final bool isUser = message['sender'] == 'user';
    final String formattedDate = DateFormat('HH:mm').format(message['date'] as DateTime);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFD32F2F) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['text']!,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 16,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: TextStyle(
                color: isUser ? Colors.white70 : Colors.black54,
                fontSize: 10,
                fontFamily: 'Roboto',
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
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Chat with VibrantBot',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000000),
            fontFamily: 'Poppins',
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFD32F2F)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(_messages[index]),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: VibrantTheme.surfaceColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    style: const TextStyle(fontFamily: 'Roboto'),
                    onSubmitted: (_) => _sendMessage(),
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  backgroundColor: const Color(0xFFD32F2F),
                  onPressed: _isLoading ? null : _sendMessage,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}