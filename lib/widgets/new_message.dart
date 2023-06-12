import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var _messageController = TextEditingController();

  void _submitMessage() async {
    final String enteredMessage = _messageController.text;
    if (enteredMessage.trim().isEmpty) {
      return;
    }
    if (!kIsWeb) {
      Focus.of(context).unfocus();
    }

    _messageController.clear();

    final currentUser = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser!.uid)
        .get();

    await FirebaseFirestore.instance.collection("chat").add({
      "text": enteredMessage,
      "created_at": Timestamp.now(),
      "user": currentUser.uid,
      "username": userData.data()!["username"],
      "image_url": userData.data()!["image_url"]
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 1,
        bottom: 14,
      ),
      child: Row(children: [
        Expanded(
            child: TextField(
          controller: _messageController,
          textCapitalization: TextCapitalization.sentences,
          autocorrect: true,
          enableSuggestions: true,
          decoration: const InputDecoration(label: Text("Send Message")),
        )),
        IconButton(
          color: Theme.of(context).colorScheme.primary,
          onPressed: _submitMessage,
          icon: const Icon(
            Icons.send,
          ),
        )
      ]),
    );
  }
}
