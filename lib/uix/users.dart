import 'package:chatku/core/statis.dart';
import 'package:chatku/uix/chat.dart';
import 'package:flutter/material.dart';

class SearchUsersUI extends StatelessWidget {
  SearchUsersUI({super.key});

  final TextEditingController cari = TextEditingController();

  Future<Widget> chatTerakhir(Map<Object?, Object?> user) async {
    String chatKey = ChatsUI.buatRoomId(Static.uid.toString(), user["uid"].toString());
    return StreamBuilder(
      stream: Static.chatsReference.child(chatKey).child("terakhir").onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.snapshot.value == null) {
            return const Text("belum ada chat");
          } else {
            Map<Object?, Object?> data = snapshot.data!.snapshot.value as Map<Object?, Object?>;
            return Text(data["content"].toString());
          }
        } else {
          return const Text("\u{1F92A}");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chatku')),
      body: StreamBuilder(
        stream: Static.usersReference.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map<Object?, Object?> data = snapshot.data!.snapshot.value as Map<Object?, Object?>;
            List<Object?> users = data.values.toList();
            users.removeWhere((element) => element.toString().contains(Static.uid.toString()));
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                Map<Object?, Object?> user = users[index] as Map<Object?, Object?>;
                return ListTile(
                  title: Text(user["name"].toString()),
                  subtitle: FutureBuilder<Widget>(
                    future: chatTerakhir(user),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return snapshot.data ?? const SizedBox();
                      }
                      return const CircularProgressIndicator(color: Colors.blue);
                    },
                  ),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user['photo'] as String),
                  ),
                  onTap: () => Navigator.pushNamed(context, '/chats', arguments: users[index]),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      )
    );
  }
}