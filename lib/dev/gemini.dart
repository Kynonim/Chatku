import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiAI extends StatefulWidget {
  const GeminiAI({super.key});
  @override
  State<GeminiAI> createState() => GeminiAIState();
}

class GeminiAIState extends State<GeminiAI> {
  final TextEditingController pesan = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final apikey = dotenv.env["GEMINI_APIKEY"];

  bool isLoading = false;
  final List<GeminiChats> chats = [GeminiChats(sender: "gemini", message: "Can you help me with a question?")];

  Future<void> kirimChat(String messages) async {
    if (messages.isEmpty) return;
    setState(() => isLoading = true);
    final model = GenerativeModel(model: "gemini-1.5-flash", apiKey: apikey.toString());
    final content = [Content.text(messages)];
    final response = await model.generateContent(content);

    setState(() {
      chats.add(GeminiChats(sender: "user", message: messages));
      chats.add(GeminiChats(sender: "gemini", message: response.text.toString()));
      isLoading = false;
    });
    scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    pesan.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini AI'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: chats.length,
              controller: scrollController,
              itemBuilder: (context, index) {
                final msg = chats[chats.length - 1- index];
                final isUser = msg.sender == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ?  Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      msg.message,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isUser ? Colors.black : Colors.black54,
                      )
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 2,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: isLoading ? const Center(child: CircularProgressIndicator(color: Colors.blue)) : Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: pesan,
                    onSubmitted: (value) {
                      kirimChat(value);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Pesan',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: () => kirimChat(pesan.text),
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          )
        ],
      )
    );
  }
}

class GeminiChats {
  final String sender;
  final String message;

  GeminiChats({required this.sender, required this.message});
}