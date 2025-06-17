import 'package:farmers_hub/screens/add_post/add_post_screen.dart';
import 'package:farmers_hub/screens/chat/chat_screen.dart';
import 'package:farmers_hub/screens/home/home_screen.dart';
import 'package:farmers_hub/screens/profile/profile_screen.dart';
import 'package:farmers_hub/services/chat_service.dart';
import 'package:flutter/material.dart';

import 'package:farmers_hub/utils/constants.dart';
import 'package:flutter_svg/svg.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';

class MessageItem {
  final String avatarUrl;
  final String name;
  final String lastMessage;
  final String time;
  final String? date; // Nullable for items without a date
  final int unreadCount;

  MessageItem({
    required this.avatarUrl,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.date,
    this.unreadCount = 0,
  });
}

class ChatHome extends StatefulWidget {
  final user;

  const ChatHome({super.key, required this.user});

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  final _formKey = GlobalKey<FormBuilderState>();

  late final ChatService _chatService;

  late List userIds;

  bool _isLoading = true;

  Future<List> _getUserIds() async {
    return await _chatService.getUsersIdForChat();
  }

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(user: widget.user);

    () async {
      final ids = await _getUserIds();

      // print(ids);
      // await Future.delayed(const Duration(seconds: 2));
      if (context.mounted) {
        setState(() {
          userIds = ids;
          _isLoading = false;
        });
      }
    }();
  }

  Widget _buildUserList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return StreamBuilder(
      // stream: _chatService.getUsersStream(),
      stream: _chatService.getUsersStreamForChatBasedOnIds(userIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
            snapshot.data?.map((user) {
              print(user);
              messages.add(
                MessageItem(
                  avatarUrl:
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cG9ydHJhaXR8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=100&q=60',
                  name: user["username"],
                  lastMessage: 'Hi its available',
                  time: '12:00 PM',
                ),
              );
            });

          return ListView(
            shrinkWrap: true,
            children:
                snapshot.data!.map<Widget>((userData) => _buildUserItemList(userData, context)).toList(),
          ); // User is signed in
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildUserItemList(Map<String, dynamic> userData, BuildContext context) {
    // Return all users except current user
    // print(widget.user.uid);
    if (userData["email"] != widget.user.email) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => ChatScreen(
                    receiverId: userData["id"],
                    receiverEmail: userData['email'],
                    user: widget.user,
                  ),
            ),
          );
        },
        child: Center(child: Text(userData['email'])),
      );
    } else {
      return Container();
    }
  }

  // Sample data - replace with your actual data source
  final List<MessageItem> messages = [
    // MessageItem(
    //   avatarUrl:
    //       'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cG9ydHJhaXR8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=100&q=60',
    //   // Placeholder
    //   name: 'Ann',
    //   lastMessage: 'Hi its available',
    //   time: '12:00 PM',
    //   unreadCount: 1,
    // ),
    // MessageItem(
    //   avatarUrl:
    //       'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8cG9ydHJhaXR8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=100&q=60',
    //   // Placeholder
    //   name: 'Angel',
    //   lastMessage: 'Hi its available',
    //   time: '12:00 PM',
    //   date: '12 07 2025',
    // ),
    // MessageItem(
    //   avatarUrl:
    //       'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8cG9ydHJhaXR8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=100&q=60',
    //   // Placeholder
    //   name: 'Kristin',
    //   lastMessage: 'Hi its available',
    //   time: '12:00 PM',
    //   date: '12 07 2025',
    // ),
    // MessageItem(
    //   avatarUrl:
    //       'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8cG9ydHJhaXR8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=100&q=60',
    //   // Placeholder
    //   name: 'Soham',
    //   lastMessage: 'Hi its available',
    //   time: '12:00 PM',
    //   date: '12 07 2025',
    // ),
    // MessageItem(
    //   avatarUrl:
    //       'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8cG9ydHJhaXR8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=100&q=60',
    //   // Placeholder
    //   name: 'Arlene',
    //   lastMessage: 'Hi its available',
    //   time: '12:00 PM',
    //   date: '12 07 2025',
    // ),
    // MessageItem(
    //   avatarUrl:
    //       'https://images.unsplash.com/photo-1521119989659-a83eee488004?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8cG9ydHJhaXR8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=100&q=60',
    //   // Placeholder
    //   name: 'Eduardo',
    //   lastMessage: 'Hi its available',
    //   time: '12:00 PM',
    //   date: '12 07 2025',
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: homebackgroundColor,
      appBar: AppBar(
        // leading: BackButton(color: Colors.white),
        backgroundColor: onboardingColor,
        automaticallyImplyLeading: false,
        title: Text(
          "All Chats",
          // style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AddPostScreen()),
            );
          }
        },
        backgroundColor: onboardingColor,
        elevation: 4,
        shape: CircleBorder(),
        child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 24),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        height: 70,
        // shape: const UpwardNotchedAndRoundedRectangle(topCornerRadius: 12),
        notchMargin: 10,
        color: Colors.white,
        elevation: 0,
        // Shadow for the BottomAppBar
        clipBehavior: Clip.antiAlias,

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          // Children are the navigation items
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(semanticsLabel: 'Home Icon', "images/icons/home.svg"),
                  Text(
                    'Home',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: onboardingColor,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(semanticsLabel: 'Chat Icon', "images/icons/chat_selected.svg"),
                Text(
                  'Chat',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: onboardingColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(semanticsLabel: 'Favorites Icon', "images/icons/favorites.svg"),
                Text(
                  'Favorites',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: onboardingColor,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(semanticsLabel: 'Profile Icon', "images/icons/profile.svg"),
                  Text(
                    'Profile',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: onboardingColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // body: SafeArea(child: _buildUserList()),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
                  child: FormBuilderTextField(
                    name: "search",
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(fontSize: 13.69, fontWeight: FontWeight.w400, height: 1.43),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: GoogleFonts.poppins(
                        textStyle: TextStyle(fontSize: 13.69, fontWeight: FontWeight.w400, height: 1.43),
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF999999)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.mic_none_outlined, color: onboardingColor),
                        onPressed: null,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Color(0xFFC1EBCA)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Color(0xFFC1EBCA)),
                      ),
                    ),
                  ),
                ),

                _buildUserList(),
              ],
            ),
          ),
        ),
      ),
    );
    //
    //
    //               ListView.builder(
    //                 shrinkWrap: true,
    //                 itemCount: messages.length,
    //                 itemBuilder: (context, index) {
    //                   final message = messages[index];
    //
    //                   return MessageListItem(
    //                     avatarUrl: message.avatarUrl,
    //                     name: message.name,
    //                     lastMessage: message.lastMessage,
    //                     time: message.time,
    //                     date: message.date,
    //                     unreadCount: message.unreadCount,
    //                     onTap: () {
    //                       // Handle tap on message item, e.g., navigate to chat screen
    //                       print('Tapped on ${message.name}');
    //                     },
    //                   );
    //                 },
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}

class MessageListItem extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String lastMessage;
  final String time;
  final String? date;
  final int unreadCount;
  final VoidCallback onTap;

  const MessageListItem({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.date,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(avatarUrl), // Use NetworkImage for URLs
              // Or AssetImage for local assets: AssetImage('assets/your_image.png')
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500, // Slightly bolder than normal
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lastMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: unreadCount > 0 ? Colors.black87 : Colors.grey[600],
                      fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 5),
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.green, // Color for unread count badge
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  )
                else if (date != null) // Show date only if no unread count and date is available
                  Text(date!, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
