import 'package:chatku/core/statis.dart';
import 'package:flutter/material.dart';

class SearchUsersUI extends StatelessWidget {
  SearchUsersUI({super.key});

  final TextEditingController cari = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chatku')),
      body: StreamBuilder(
        stream: Static.dbReference.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            List<dynamic> users = data.values.toList();
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                Map<dynamic, dynamic> user = users[index];
                return ListTile(
                  title: Text(user['name']),
                  subtitle: Text(user['email']),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user['photo']),
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