import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_hub/screens/add_post/add_post_screen.dart';
import 'package:farmers_hub/screens/chat/chat_screen.dart';
import 'package:farmers_hub/screens/favorites/favorites_screen.dart';
import 'package:farmers_hub/screens/home/home_screen.dart';
import 'package:farmers_hub/screens/profile/profile_screen.dart';
import 'package:farmers_hub/services/chat_service.dart';
import 'package:flutter/material.dart';

import 'package:farmers_hub/utils/constants.dart';
import 'package:flutter_svg/svg.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MessageItem {
  final String avatarUrl;

  final String id;
  final String name;

  final String email;
  final String lastMessage;
  final String time;
  final String? date; // Nullable for items without a date
  final int unreadCount;

  MessageItem({
    required this.avatarUrl,
    required this.id,
    required this.name,
    required this.email,
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

  String _searchQuery = "";

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

  // Widget _buildUserList() {
  //   if (_isLoading) {
  //     return const Center(child: CircularProgressIndicator(color: onboardingColor));
  //   }
  //   return StreamBuilder(
  //     // stream: _chatService.getUsersStream(),
  //     stream: _chatService.getUsersStreamForChatBasedOnIds(userIds),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return Center(child: CircularProgressIndicator(color: onboardingColor));
  //       }
  //
  //       if (snapshot.hasError) {
  //         // Always good to handle errors
  //         return Center(child: Text("Something went wrong: ${snapshot.error}"));
  //       }
  //
  //       if (snapshot.hasData) {
  //         final users = snapshot.data!;
  //         // snapshot.data?.map((user) {
  //         // });
  //
  //         users.forEach((user) {
  //           // Check if user isn't being duplicated and added to list
  //           if (!(messages.any((item) => item.name == user["username"]))) {
  //             messages.add(
  //               MessageItem(
  //                 avatarUrl:
  //                     'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cG9ydHJhaXR8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=100&q=60',
  //                 // name: user["username"],
  //                 id: "${user["id"]}",
  //                 name: "${user["username"]}",
  //                 lastMessage: 'Hi its available',
  //                 time: '12:00 PM',
  //               ),
  //             );
  //           }
  //         });
  //
  //         print(messages.length);
  //         return ListView(
  //           shrinkWrap: true,
  //           children:
  //               snapshot.data!.map<Widget>((userData) => _buildUserItemList(userData, context)).toList(),
  //         ); // User is signed in
  //       } else {
  //         return Container();
  //       }
  //     },
  //   );
  // }
  //
  // Widget _buildUserItemList(Map<String, dynamic> userData, BuildContext context) {
  //   // Return all users except current user
  //   // print(widget.user.uid);
  //   if (userData["email"] != widget.user.email) {
  //     // return GestureDetector(
  //     // onTap: () {
  //     //   Navigator.of(context).push(
  //     //     MaterialPageRoute(
  //     //       builder:
  //     //           (context) => ChatScreen(
  //     //             receiverId: userData["id"],
  //     //             receiverEmail: userData['email'],
  //     //             user: widget.user,
  //     //           ),
  //     //     ),
  //     //   );
  //     // },
  //     // child: Center(child: ElevatedButton(
  //     return Center(
  //       child: ElevatedButton(
  //         style: ElevatedButton.styleFrom(backgroundColor: onboardingColor),
  //         onPressed: () {
  //           Navigator.of(context).push(
  //             MaterialPageRoute(
  //               builder:
  //                   (context) => ChatScreen(
  //                     receiverId: userData["id"],
  //                     receiverEmail: userData['email'],
  //                     user: widget.user,
  //                   ),
  //             ),
  //           );
  //         },
  //         child: Text(userData['email'], style: TextStyle(color: Colors.white)),
  //       ),
  //     );
  //     // );
  //   } else {
  //     return Container();
  //   }
  // }

  Widget _buildUserList2() {
    if (_isLoading) {
      // return const Center(child: CircularProgressIndicator(color: onboardingColor));
      return Skeletonizer(
        effect: ShimmerEffect(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
        ),
        ignorePointers: true,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text('User Name'),
                subtitle: Text('Last message...'),
              ),

              ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text('User Name'),
                subtitle: Text('Last message...'),
              ),

              ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text('User Name'),
                subtitle: Text('Last message...'),
              ),

              ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text('User Name'),
                subtitle: Text('Last message...'),
              ),
            ],
          ),
        ),
      );
    }
    return StreamBuilder<List<Map<String, dynamic>>>(
      // stream: _chatService.getUsersStream(),
      stream: _chatService.getUsersStreamForChatBasedOnIds(userIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // return Center(child: CircularProgressIndicator(color: onboardingColor));
          return Skeletonizer(
            effect: ShimmerEffect(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            ),
            ignorePointers: true,
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 4, // Number of skeleton items
                itemBuilder: (context, index) {
                  return const ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text('User Name...........'),
                    subtitle: Text('Last message...'),
                  );
                },
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          // Always good to handle errors
          return Center(child: Text("Something went wrong: ${snapshot.error}"));
        }

        if (snapshot.hasData) {
          final users = snapshot.data!;
          // snapshot.data?.map((user) {
          // });

          final filteredUsers =
              _searchQuery.isEmpty
                  ? users
                  : users.where((user) {
                    final username = user['username'].toString().toLowerCase();
                    return username.contains(_searchQuery.toLowerCase());
                  }).toList();

          // print(filteredUsers);

          if (filteredUsers.isEmpty) {
            // return const Center(child: Text("No users found."));
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400, width: 1.5),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Icon(
                      Icons.mark_chat_unread_outlined, // An icon that fits the context
                      color: Colors.grey[700],
                      size: 36.0,
                    ),
                  ),

                  const SizedBox(height: 8.0),

                  const Text(
                    'Nothing to see here',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333A44), // A dark slate gray color
                    ),
                  ),

                  const SizedBox(height: 4.0),

                  Text(
                    'Start a conversation with any of the sellers.\nYour chats will show here.',
                    textAlign: TextAlign.center, // Ensures the text is center-aligned
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                      height: 1.5, // Line height for better readability
                    ),
                  ),
                ],
              ),
            );
          }

          // users.forEach((user) {
          //   // Check if user isn't being duplicated and added to list
          //   if (!(messages.any((item) => item.name == user["username"]))) {
          //     messages.add(
          //       MessageItem(
          //         // avatarUrl:
          //         //     'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cG9ydHJhaXR8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=100&q=60',
          //         avatarUrl: user["profileImage"],
          //         // name: user["username"],
          //         id: "${user["id"]}",
          //         name: "${user["username"]}",
          //         email: "${user["email"]}",
          //         lastMessage: 'Hi its available',
          //         time: '12:00 PM',
          //       ),
          //     );
          //   }
          // });

          return ListView.builder(
            shrinkWrap: true,
            // itemCount: messages.length,
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              final otherUserId = user['id'];
              // final message = messages[index];

              // final useR = users[index];
              // final otherUserId = useR['id'];

              final messageItem = MessageItem(
                avatarUrl: user["profileImage"],
                id: user["id"],
                name: user["username"],
                email: user["email"],
                lastMessage: '',
                // This will be filled by the stream
                time: '', // This will be filled by the stream
              );

              return StreamBuilder<QuerySnapshot>(
                // stream: _chatService.getLastMessage(message.id, widget.user.uid),
                stream: _chatService.getLastMessage(widget.user.uid, otherUserId),
                builder: (context, messageSnapshot) {
                  String lastMessage = 'No messages yet';
                  String time = '';

                  if (messageSnapshot.connectionState == ConnectionState.waiting) {
                    // return Center(child: CircularProgressIndicator(color: onboardingColor));
                    return Skeletonizer(
                      effect: ShimmerEffect(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                      ),
                      ignorePointers: true,
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: 4, // Number of skeleton items
                          itemBuilder: (context, index) {
                            return const ListTile(
                              leading: CircleAvatar(child: Icon(Icons.person)),
                              title: Text('User Name...........'),
                              subtitle: Text('Last message...'),
                            );
                          },
                        ),
                      ),
                    );
                  }

                  if (messageSnapshot.hasError) {
                    // Always good to handle errors
                    return Center(child: Text("Something went wrong: ${snapshot.error}"));
                  }

                  if (messageSnapshot.hasData && messageSnapshot.data!.docs.isNotEmpty) {
                    final messageData = messageSnapshot.data!.docs.first.data() as Map<String, dynamic>;
                    lastMessage = messageData['message'];

                    // Format the timestamp
                    final timestamp = messageData['timestamp'] as Timestamp;
                    final dateTime = timestamp.toDate();
                    time = DateFormat('h:mm a').format(dateTime);
                  }

                  return StreamBuilder<int>(
                    stream: _chatService.getUnreadMessageCount(otherUserId),
                    builder: (context, unreadCountSnapshot) {
                      if (unreadCountSnapshot.connectionState == ConnectionState.waiting) {
                        // return Center(child: CircularProgressIndicator(color: onboardingColor));

                        return Center(
                          child: Skeletonizer(
                            effect: ShimmerEffect(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                            ),
                            ignorePointers: true,
                            child: Column(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(child: Icon(Icons.person)),
                                  title: Text('User Name'),
                                  subtitle: Text('Last message...'),
                                ),

                                ListTile(
                                  leading: CircleAvatar(child: Icon(Icons.person)),
                                  title: Text('User Name'),
                                  subtitle: Text('Last message...'),
                                ),

                                ListTile(
                                  leading: CircleAvatar(child: Icon(Icons.person)),
                                  title: Text('User Name'),
                                  subtitle: Text('Last message...'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (unreadCountSnapshot.hasError) {
                        // Always good to handle errors
                        return Center(child: Text("Something went wrong: ${snapshot.error}"));
                      }

                      // print(unreadCountSnapshot.data);
                      final unreadCount = unreadCountSnapshot.data ?? 0;

                      return MessageListItem(
                        // avatarUrl: message.avatarUrl,
                        // name: message.name,
                        // // lastMessage: message.lastMessage,
                        // lastMessage: lastMessage,
                        // // time: message.time,
                        // time: time,
                        // date: message.date,
                        // unreadCount: unreadCount,
                        avatarUrl: messageItem.avatarUrl,
                        name: messageItem.name,
                        lastMessage: lastMessage,
                        time: time,
                        date: messageItem.date,
                        unreadCount: unreadCount,
                        onTap: () {
                          if (context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => ChatScreen(
                                      // receiverId: message.id,
                                      // receiverEmail: message.email,
                                      receiverId: messageItem.id,
                                      receiverEmail: messageItem.email,
                                      user: widget.user,
                                    ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        } else {
          return Container();
        }
      },
    );
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
  ];

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Contact Support"),
          content: Text("Would you like to contact an admin?"),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Contact", style: TextStyle(color: onboardingColor)),
              onPressed: () {
                // TODO: Implement logic to find and start a chat with an admin.
                print("Initiating chat with admin...");
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: homebackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        // leading: BackButton(color: Colors.white),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.support_agent, color: Colors.white),
        //     onPressed: () {
        //       _showSupportDialog(context);
        //     },
        //   ),
        // ],
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
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddPostScreen()));
          }
        },
        backgroundColor: onboardingColor,
        elevation: 0,
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
        // clipBehavior: Clip.antiAlias,
        clipBehavior: Clip.none,

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
            GestureDetector(
              onTap: () {
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                  ).then((_) {
                    if (mounted) {
                      setState(() {});
                    }
                  });
                }
              },
              child: Column(
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
          child: NestedScrollView(
            headerSliverBuilder:
                (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: FormBuilderTextField(
                        name: "search",
                        // 2. UPDATE the text field to update the state
                        onChanged: (value) {
                          setState(() {
                            // print(value);
                            _searchQuery = value ?? "";
                          });
                        },
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 13.69,
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                          ),
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
                          // suffixIcon: IconButton(
                          //   icon: const Icon(Icons.mic_none_outlined, color: onboardingColor),
                          //   onPressed: null,
                          // ),
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
                  ),
                ],
            body: _buildUserList2(),
            // child: FormBuilder(
            //   key: _formKey,
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     // mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Padding(
            //         padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
            //         child: FormBuilderTextField(
            //           name: "search",
            //           style: GoogleFonts.poppins(
            //             textStyle: TextStyle(fontSize: 13.69, fontWeight: FontWeight.w400, height: 1.43),
            //           ),
            //           decoration: InputDecoration(
            //             hintText: 'Search',
            //             hintStyle: GoogleFonts.poppins(
            //               textStyle: TextStyle(fontSize: 13.69, fontWeight: FontWeight.w400, height: 1.43),
            //               color: Colors.grey,
            //             ),
            //             filled: true,
            //             fillColor: Colors.white,
            //             prefixIcon: const Icon(Icons.search, color: Color(0xFF999999)),
            //             // suffixIcon: IconButton(
            //             //   icon: const Icon(Icons.mic_none_outlined, color: onboardingColor),
            //             //   onPressed: null,
            //             // ),
            //             enabledBorder: OutlineInputBorder(
            //               borderRadius: BorderRadius.circular(10),
            //               borderSide: BorderSide(color: Color(0xFFC1EBCA)),
            //             ),
            //             focusedBorder: OutlineInputBorder(
            //               borderRadius: BorderRadius.circular(10),
            //               borderSide: BorderSide(color: Color(0xFFC1EBCA)),
            //             ),
            //           ),
            //         ),
            //       ),

            // _buildUserList2(),
            // ListView.builder(
            //   shrinkWrap: true,
            //   itemCount: messages.length,
            //   itemBuilder: (context, index) {
            //     final message = messages[index];
            //
            //     return MessageListItem(
            //       avatarUrl: message.avatarUrl,
            //       name: message.name,
            //       lastMessage: message.lastMessage,
            //       time: message.time,
            //       date: message.date,
            //       unreadCount: message.unreadCount,
            //       onTap: () {
            //         // Handle tap on message item, e.g., navigate to chat screen
            //         print('Tapped on ${message.name}');
            //       },
            //     );
            //   },
            // ),
            // ],
          ),
        ),
      ),
      // ),
      // ),
    );
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
            // Dynamic Circle Avatar background and text
            // CircleAvatar(
            //   radius: 28,
            //   backgroundImage:
            //   avatarUrl != "default_pfp.jpg" ? NetworkImage(avatarUrl) : null,
            //   child: avatarUrl == "default_pfp.jpg"
            //       ? Text(
            //     name.isNotEmpty ? name[0].toUpperCase() : '?',
            //     style: TextStyle(
            //         fontSize: 24,
            //         color: Colors.white,
            //         fontWeight: FontWeight.bold),
            //   )
            //       : null,
            // ),
            avatarUrl == "default_pfp.jpg"
                ? CircleAvatar(
                  radius: 24,
                  backgroundColor: onboardingColor,
                  child: Text('A', style: TextStyle(fontSize: 26, color: Colors.white)),
                )
                : CircleAvatar(
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
