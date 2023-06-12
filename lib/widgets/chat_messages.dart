import 'package:chatapp/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  ChatMessages({super.key});

  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("chat")
            .orderBy("created_at", descending: true)
            .snapshots(),
        builder: ((context, chatSnapshots) {
          if (chatSnapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
            return const Center(
              child: Text("No messages found"),
            );
          }
          if (chatSnapshots.hasError) {
            return const Text("Error");
          }

          final loadedMessages = chatSnapshots.data!.docs;
          final numMessages = loadedMessages.length;

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
            reverse: true,
            itemCount: numMessages,
            itemBuilder: (ctx, idx) {
              final chatMessage = loadedMessages[idx].data();
              final nextMessage = idx + 1 < loadedMessages.length
                  ? loadedMessages[idx + 1].data()
                  : null;
              final currentMessageUser = chatMessage["user"];
              final nextMessageUser =
                  nextMessage != null ? nextMessage["user"] : null;
              final nextUserIsSame = currentMessageUser == nextMessageUser;
              if (nextUserIsSame) {
                return MessageBubble.next(
                    message: chatMessage["text"],
                    isMe: currentUser.uid == currentMessageUser);
              } else {
                return MessageBubble.first(
                    userImage: chatMessage["image_url"],
                    username: chatMessage["username"],
                    message: chatMessage["text"],
                    isMe: currentUser.uid == currentMessageUser);
              }
            },
          );
        }),
      ),
    );
  }
}
