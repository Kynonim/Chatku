import 'package:chatku/core/statis.dart';
import 'package:flutter/material.dart';

class ChatsUI extends StatelessWidget {
  ChatsUI({super.key});

  int unicode = 0;
  final TextEditingController pesan = TextEditingController();

  void kirimPesan(String uid, String pesan) {
    if (pesan.isNotEmpty) {
      Static.dbReference.child(uid).child('chats').push().set({
        "uid": uid,
        "content": pesan,
        "time": DateTime.now().toIso8601String(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<dynamic, dynamic> user = ModalRoute.of(context)!.settings.arguments as Map<dynamic, dynamic>;
    return Scaffold(
      appBar: AppBar(
        title: Text(user['name']),
        actions: [
          IconButton(
            onPressed: () => {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: Image.network(
                              user['photo'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(user['name']),
                        const SizedBox(height: 16),
                        Text(user['email']),
                      ],
                    ),
                  );
                },
              ),
            },
            icon: CircleAvatar(backgroundImage: NetworkImage(user["photo"])),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: Static.dbReference.child(user["uid"]).child("chats").onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  List<dynamic> chats = data.values.toList();
                  if (chats.isEmpty) {
                    return Center(child: Text(chats.toString()));
                  }
                  return ListView.builder(
                    reverse: true,
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(chats[index][1]),
                        subtitle: Text(chats[index][1]),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: pesan,
                    decoration: InputDecoration(
                      hintText: "Chats mu",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      )
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    kirimPesan(user["uid"], pesan.text.toString());
                    pesan.clear();
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}