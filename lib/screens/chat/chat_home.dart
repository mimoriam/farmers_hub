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
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:farmers_hub/generated/i18n/app_localizations.dart';

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

  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

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

    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});

    if (!_speechEnabled) {
      _showSpeechNotAvailableDialog();
      return;
    }
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    var locales = await _speechToText.locales();

    await _speechToText.listen(onResult: _onSpeechResult, localeId: "en_US");
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    print(result.recognizedWords);
    setState(() {
      _lastWords = result.recognizedWords;

      _speechToText.isListening
          ? _formKey.currentState?.fields['search']?.didChange(_lastWords)
          : "";
    });
  }

  void _showSpeechNotAvailableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.speechRecognitionIssue),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.speechNotWorking),
            const SizedBox(height: 10),
            Text(AppLocalizations.of(context)!.microphonePermissionNotGranted),
            Text(AppLocalizations.of(context)!.speechServiceDisabled),
            const Text('• Device does not support speech recognition'),
            const SizedBox(height: 10),
            const Text('Please check your device settings and try again.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initSpeech();
            },
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList2() {
    if (_isLoading) {
      // return const Center(child: CircularProgressIndicator(color: onboardingColor));
      return Skeletonizer(
        effect: ShimmerEffect(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!),
        ignorePointers: true,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text(AppLocalizations.of(context)!.userName),
                subtitle: Text(AppLocalizations.of(context)!.lastMessage),
              ),

              ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text(AppLocalizations.of(context)!.userName),
                subtitle: Text(AppLocalizations.of(context)!.lastMessage),
              ),

              ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text(AppLocalizations.of(context)!.userName),
                subtitle: Text(AppLocalizations.of(context)!.lastMessage),
              ),

              ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text(AppLocalizations.of(context)!.userName),
                subtitle: Text(AppLocalizations.of(context)!.lastMessage),
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
            effect: ShimmerEffect(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!),
            ignorePointers: true,
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 4, // Number of skeleton items
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text(AppLocalizations.of(context)!.usernameSpace),
                    subtitle: Text(AppLocalizations.of(context)!.lastMessage),
                  );
                },
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          // Always good to handle errors
          return Center(
            child: Text("${AppLocalizations.of(context)!.somethingWrong} ${snapshot.error}"),
          );
        }

        if (snapshot.hasData) {
          final users = snapshot.data!;
          // snapshot.data?.map((user) {
          // });

          final filteredUsers = _searchQuery.isEmpty
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

          return ListView.builder(
            shrinkWrap: true,
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              final otherUserId = user['id'];

              final messageItem = MessageItem(
                avatarUrl: user["profileImage"],
                id: user["id"],
                name: user["username"],
                email: user["email"],
                lastMessage: '',
                time: '',
              );

              return StreamBuilder<QuerySnapshot>(
                stream: _chatService.getLastMessage(widget.user.uid, otherUserId),
                builder: (context, messageSnapshot) {
                  String lastMessage = AppLocalizations.of(context)!.noMessage;
                  String time = '';

                  if (messageSnapshot.connectionState == ConnectionState.waiting) {
                    return Skeletonizer(
                      effect: ShimmerEffect(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                      ),
                      ignorePointers: true,
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: CircleAvatar(child: Icon(Icons.person)),
                              title: Text(AppLocalizations.of(context)!.usernameSpace),
                              subtitle: Text(AppLocalizations.of(context)!.lastMessage),
                            );
                          },
                        ),
                      ),
                    );
                  }

                  if (messageSnapshot.hasError) {
                    return Center(
                      child: Text(
                        "${AppLocalizations.of(context)!.somethingWrong} ${snapshot.error}",
                      ),
                    );
                  }

                  if (messageSnapshot.hasData && messageSnapshot.data!.docs.isNotEmpty) {
                    final messageData =
                        messageSnapshot.data!.docs.first.data() as Map<String, dynamic>;
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
                                  title: Text(AppLocalizations.of(context)!.userName),
                                  subtitle: Text(AppLocalizations.of(context)!.lastMessage),
                                ),

                                ListTile(
                                  leading: CircleAvatar(child: Icon(Icons.person)),
                                  title: Text(AppLocalizations.of(context)!.userName),
                                  subtitle: Text(AppLocalizations.of(context)!.lastMessage),
                                ),

                                ListTile(
                                  leading: CircleAvatar(child: Icon(Icons.person)),
                                  title: Text(AppLocalizations.of(context)!.userName),
                                  subtitle: Text(AppLocalizations.of(context)!.lastMessage),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (unreadCountSnapshot.hasError) {
                        return Center(
                          child: Text(
                            "${AppLocalizations.of(context)!.somethingWrong} ${snapshot.error}",
                          ),
                        );
                      }

                      final unreadCount = unreadCountSnapshot.data ?? 0;

                      return MessageListItem(
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
                                builder: (context) => ChatScreen(
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

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.contactSupport),
          content: Text(AppLocalizations.of(context)!.contactAdmin),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(color: Colors.grey[600]),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.contact,
                style: TextStyle(color: onboardingColor),
              ),
              onPressed: () {
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
        backgroundColor: onboardingColor,
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context)!.allChats,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AddPostScreen()),
            );
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
        notchMargin: 10,
        color: Colors.white,
        elevation: 0,
        clipBehavior: Clip.none,

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                  SvgPicture.asset(
                    semanticsLabel: AppLocalizations.of(context)!.homeIcon,
                    "images/icons/home.svg",
                  ),
                  Text(
                    AppLocalizations.of(context)!.home,
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
                SvgPicture.asset(
                  semanticsLabel: AppLocalizations.of(context)!.chatIcon,
                  "images/icons/chat_selected.svg",
                ),
                Text(
                  AppLocalizations.of(context)!.chat,
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
                  SvgPicture.asset(
                    semanticsLabel: AppLocalizations.of(context)!.favoritesIcon,
                    "images/icons/favorites.svg",
                  ),
                  Text(
                    AppLocalizations.of(context)!.favorites,
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
                  SvgPicture.asset(
                    semanticsLabel: AppLocalizations.of(context)!.profileIcon,
                    "images/icons/profile.svg",
                  ),
                  Text(
                    AppLocalizations.of(context)!.profile,
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

      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: FormBuilderTextField(
                    name: "search",
                    onChanged: (value) {
                      setState(() {
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
                      hintText: AppLocalizations.of(context)!.search,
                      hintStyle: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 13.69,
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF999999)),
                      suffixIcon: IconButton(
                        // icon: Icon(Icons.mic, color: Color(0xFF999999)),
                        icon: Icon(Icons.mic, color: onboardingColor),
                        onPressed: () {},
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
              ),
            ],
            body: _buildUserList2(),
          ),
        ),
      ),
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
            avatarUrl == "default_pfp.jpg"
                ? CircleAvatar(
                    radius: 24,
                    backgroundColor: onboardingColor,
                    child: Text('A', style: TextStyle(fontSize: 26, color: Colors.white)),
                  )
                : CircleAvatar(radius: 28, backgroundImage: NetworkImage(avatarUrl)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
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
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (date != null)
                  Text(date!, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
