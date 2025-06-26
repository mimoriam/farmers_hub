import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_hub/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:farmers_hub/services/chat_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

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

  final FirebaseService _firebaseService = FirebaseService();

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
          // return const Scaffold(
          //   backgroundColor: Colors.white,
          //   body: Center(child: CircularProgressIndicator(color: onboardingColor)),
          // );

          return Scaffold(
            backgroundColor: homebackgroundColor,
            appBar: AppBar(
              leading: BackButton(color: Colors.white),
              backgroundColor: onboardingColor,
              elevation: 0,
              title: Skeletonizer(
                ignorePointers: true,
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cG9ydHJhaXR8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=100&q=60',
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "initialName",
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                        Text("Time", style: TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            body: Center(
              child: Skeletonizer(
                ignorePointers: true,
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person)),
                      title: Text('User Name'),
                      subtitle: Text('Last message...'),
                    ),

                    Expanded(child: SizedBox()),

                    Padding(
                      padding: EdgeInsets.only(bottom: 20, left: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: textFieldBorderSideColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: textFieldBorderSideColor),
                                ),
                                hintText: "Type your message...",
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            margin: EdgeInsets.only(right: 10),
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.arrow_outward, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          // Scroll to the bottom whenever new message data arrives
          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //   _scrollToBottom();
          // });

          return FutureBuilder(
            future: _firebaseService.getUserDataByEmail(email: widget.receiverEmail),
            builder: (context, userDataSnapshot) {
              if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                // return Scaffold(
                //   backgroundColor: Colors.white,
                //   body: const Center(child: CircularProgressIndicator(color: onboardingColor)),
                // );

                return Scaffold(
                  backgroundColor: homebackgroundColor,
                  appBar: AppBar(
                    leading: BackButton(color: Colors.white),
                    backgroundColor: onboardingColor,
                    elevation: 0,
                    title: Skeletonizer(
                      ignorePointers: true,
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cG9ydHJhaXR8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=100&q=60',
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "initialName",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text("Time", style: TextStyle(color: Colors.white, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  body: Center(
                    child: Skeletonizer(
                      ignorePointers: true,
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(child: Icon(Icons.person)),
                            title: Text('User Name'),
                            subtitle: Text('Last message...'),
                          ),

                          Expanded(child: SizedBox()),

                          Padding(
                            padding: EdgeInsets.only(bottom: 20, left: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: textFieldBorderSideColor),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: textFieldBorderSideColor),
                                      ),
                                      hintText: "Type your message...",
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  margin: EdgeInsets.only(right: 10),
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.arrow_outward, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (userDataSnapshot.hasError || !userDataSnapshot.hasData || userDataSnapshot.data == null) {
                return Scaffold(
                  backgroundColor: Colors.white,
                  body: const Center(child: Text("Failed to load user data.")),
                );
              }

              final userData = userDataSnapshot.data!.data() as Map<String, dynamic>?;

              final initialName = userData?['username'] ?? '';
              final lastSeenAtTimestamp = userData?['lastSeenAt'] as Timestamp;
              final String formattedDateTime = DateFormat(
                'MMM d, y ~ h:mm a',
              ).format(lastSeenAtTimestamp.toDate());

              final profileImageUrl = userData?['profileImage'];

              return Scaffold(
                backgroundColor: homebackgroundColor,
                // appBar: AppBar(title: Text(widget.receiverEmail)),
                appBar: AppBar(
                  leading: BackButton(color: Colors.white),
                  backgroundColor: onboardingColor,
                  elevation: 0,
                  title: Row(
                    children: [
                      // const CircleAvatar(
                      //   backgroundImage: NetworkImage(
                      //     'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cG9ydHJhaXR8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=100&q=60',
                      //   ),
                      // ),
                      profileImageUrl == "default_pfp.jpg"
                          ? CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.deepOrange,
                            child: Text('A', style: TextStyle(fontSize: 26, color: Colors.white)),
                          )
                          : CircleAvatar(
                            radius: 22,
                            backgroundImage: NetworkImage(profileImageUrl), // Use NetworkImage for URLs
                            // Or AssetImage for local assets: AssetImage('assets/your_image.png')
                          ),
                      const SizedBox(width: 12.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            initialName,
                            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                          Text(formattedDateTime, style: TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
                // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
                // floatingActionButton: Padding(
                //   padding: const EdgeInsets.only(bottom: 100),
                //   child: FloatingActionButton.small(
                //     backgroundColor: Colors.green,
                //     onPressed: _scrollDown,
                //     child: Icon(Icons.arrow_downward, color: Colors.black),
                //   ),
                // ),
                body: SafeArea(
                  child: FormBuilder(
                    key: _formKey,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            controller: _controller,
                            children:
                                snapshot.data!.docs
                                    .map((doc) => _buildMessageItemList(doc, userData?['profileImage']))
                                    .toList(),
                          ),
                        ),
                        _buildUserInput(),
                        // ElevatedButton(
                        //                 //   onPressed: () async {
                        //                 //     sendMessageToDB();
                        //                 //   },
                        //                 //   child: Text("ENTER"),
                        //                 // ),
                        // MediaQuery.of(context).viewInsets.bottom == 0.0
                        //     ? Align(
                        //       alignment: Alignment.bottomCenter,
                        //       child: Padding(
                        //         padding: const EdgeInsets.only(bottom: 16.0),
                        //         child: Container(
                        //           // margin: const EdgeInsets.only(bottom: 8.0),
                        //           width: 135,
                        //           height: 5,
                        //           decoration: BoxDecoration(
                        //             color: Colors.grey,
                        //             borderRadius: BorderRadius.circular(2.5),
                        //           ),
                        //         ),
                        //       ),
                        //     )
                        //     : Container(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ); // User is signed in
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildMessageItemList(DocumentSnapshot doc, String? profileImageUrl) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurrentUser = data["senderId"] == widget.user.uid;
    // Own messages at right:
    // return Container(alignment: alignment, child: Text(data["message"]));
    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    final Timestamp timestamp = data['timestamp'] as Timestamp;
    final String formattedTime = DateFormat('h:mm a').format(timestamp.toDate());

    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              // if (!isCurrentUser)
              Padding(
                padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                child:
                    profileImageUrl == "default_pfp.jpg"
                        ? CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.deepOrange,
                          child: Text('A', style: TextStyle(fontSize: 26, color: Colors.white)),
                        )
                        : CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(profileImageUrl!), // Use NetworkImage for URLs
                          // Or AssetImage for local assets: AssetImage('assets/your_image.png')
                        ),
                // child: CircleAvatar(
                //   radius: 19,
                //   backgroundImage: NetworkImage(
                //     'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cG9ydHJhaXR8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=100&q=60',
                //   ),
                // ),
              ),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(14),
                  margin:
                      isCurrentUser
                          ? const EdgeInsets.symmetric(vertical: 4, horizontal: 10)
                          : const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                  child: Text(data["message"]),
                ),
              ),

              // Container(
              //   decoration: BoxDecoration(
              //     // color: isCurrentUser ? Colors.green : Colors.grey.shade500,
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   padding: const EdgeInsets.all(16),
              //   margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 25),
              //   child: Text(data["message"]),
              // ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(formattedTime, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInput() {
    return Padding(
      padding: EdgeInsets.only(bottom: 20, left: 10),
      child: Row(
        children: [
          Expanded(
            child: FormBuilderTextField(
              name: "message",
              style: GoogleFonts.poppins(textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              decoration: InputDecoration(
                hintText: "Type your message...",
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: textFieldBorderSideColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: textFieldBorderSideColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(11),
            ),
            margin: EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  sendMessageToDB(_formKey.currentState?.fields['message']?.value);
                  _formKey.currentState?.reset();
                  // FocusScope.of(context).unfocus();
                }
              },
              icon: Icon(Icons.arrow_outward, color: Colors.grey),
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
