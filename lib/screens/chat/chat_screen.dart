import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:farmers_hub/services/chat_service.dart';

import '../../utils/constants.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverEmail;
  final user;

  const ChatScreen({super.key, required this.receiverId, required this.receiverEmail, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatService _chatService;
  final _formKey = GlobalKey<FormBuilderState>();
  final ScrollController _controller = ScrollController();

  void _scrollDown() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(user: widget.user);

    List<String> ids = [widget.user.uid, widget.receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    _chatService.markMessagesAsRead(chatRoomId);

    // Delay the scroll to ensure the list has rendered
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _scrollToBottom();
    // });
  }

  void sendMessageToDB(String message) async {
    await _chatService.sendMessage(widget.receiverId, widget.receiverEmail, widget.user.email, message);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [Expanded(child: _buildMessageList())]);
  }

  Widget _buildMessageList() {
    String senderId = widget.user.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverId, senderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: onboardingColor)));
        }

        if (snapshot.hasData) {
          // Scroll to the bottom whenever new message data arrives
          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //   _scrollToBottom();
          // });

          return SafeArea(
            child: Scaffold(
              appBar: AppBar(title: Text(widget.receiverEmail)),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: FloatingActionButton.small(
                  backgroundColor: Colors.green,
                  onPressed: _scrollDown,
                  child: Icon(Icons.arrow_downward, color: Colors.black),
                ),
              ),
              body: FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        controller: _controller,
                        children: snapshot.data!.docs.map((doc) => _buildMessageItemList(doc)).toList(),
                      ),
                    ),
                    _buildUserInput(),
                    // ElevatedButton(
                    //                 //   onPressed: () async {
                    //                 //     sendMessageToDB();
                    //                 //   },
                    //                 //   child: Text("ENTER"),
                    //                 // ),
                    MediaQuery.of(context).viewInsets.bottom == 0.0
                        ? Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Container(
                              // margin: const EdgeInsets.only(bottom: 8.0),
                              width: 135,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(2.5),
                              ),
                            ),
                          ),
                        )
                        : Container(),
                  ],
                ),
              ),
            ),
          ); // User is signed in
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildMessageItemList(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurrentUser = data["senderId"] == widget.user.uid;
    // Own messages at right:
    // return Container(alignment: alignment, child: Text(data["message"]));
    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isCurrentUser ? Colors.green : Colors.grey.shade500,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 25),
            child: Text(data["message"]),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInput() {
    return Padding(
      padding: EdgeInsets.only(bottom: 30, left: 20),
      child: Row(
        children: [
          Expanded(
            child: FormBuilderTextField(
              name: "message",
              decoration: InputDecoration(
                labelText: "Type a message",
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            margin: EdgeInsets.only(right: 25),
            child: IconButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  sendMessageToDB(_formKey.currentState?.fields['message']?.value);
                  _formKey.currentState?.reset();
                  // FocusScope.of(context).unfocus();
                }
              },
              icon: Icon(Icons.arrow_upward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget ChatBubble() {
    return Container(
      decoration: BoxDecoration(
        // color: isCurrentUser ? Colors.green : Colors.grey.shade500,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 25),
    );
  }
}
