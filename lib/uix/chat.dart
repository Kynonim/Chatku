import 'dart:io';
import 'package:chatku/core/statis.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatsUI extends StatefulWidget {
  const ChatsUI({super.key});
  @override
  State<ChatsUI> createState() => ChatsUIState();
}

class ChatsUIState extends State<ChatsUI> {
  XFile? imageFile;
  bool isSending = false;

  final ImagePicker picker = ImagePicker();
  final ScrollController scroll = ScrollController();
  final TextEditingController pesan = TextEditingController();

  Future<void> pilihImage() async {
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => imageFile = file);
  }

  Future<void> kirimPesan(Map<Object?, Object?> user, String pesan, String path) async {
    if (pesan.isNotEmpty) {
      String chatKey = buatRoomId(Static.uid.toString(), user["uid"].toString());
      String key = Static.chatsReference.push().key.toString();
      await Static.chatsReference.child(chatKey).child("messages").child(key).set({
        "key": key,
        "content": {
          "teks": pesan,
          "file": path,
        },
        "time": DateTime.now().toIso8601String(),
        "uid": Static.uid,
      });
      await Static.chatsReference.child(chatKey).child("terakhir").set({
        "uid": Static.uid,
        "time": DateTime.now().toIso8601String(),
        "content": pesan,
      });
      setState(() => imageFile = null);
    }
  }

  Future<void> onSubmit(Map<Object?, Object?> user, TextEditingController pesan) async {
    setState(() => isSending = true);
    if (pesan.text.trim().isEmpty) {
      Static.TampilkanWidget(context, "Pesan kosong", "Tidak dapat mengirim pesan kosong");
      setState(() => isSending = false);
      return;
    }
    if (imageFile != null) {
      Reference ref = Static.storageReference.child("${DateTime.now().millisecondsSinceEpoch}.jpg");
      await ref.putFile(File(imageFile!.path)).then((isi) async {
        await isi.ref.getDownloadURL().then((value) {
          kirimPesan(user, pesan.text, value);
        });
      });
    } else {
      kirimPesan(user, pesan.text, "");
    }
    setState(() {
      isSending = false;
      pesan.clear();
      Future.delayed(const Duration(milliseconds: 100), () {
      scroll.animateTo(
        scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
    });
  }

  static String buatRoomId(String one, String two) {
    List<String> list = [one, two]..sort();
    return "${list[0]}-${list[1]}";
  }

  @override
  Widget build(BuildContext context) {
    Map<Object?, Object?> user = ModalRoute.of(context)!.settings.arguments as Map<Object?, Object?>;
    return Scaffold(
      appBar: AppBar(
        title: Text(user['name'].toString()),
        actions: [
          IconButton(
            onPressed: () {
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
                              user['photo'].toString(),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(user['name'].toString()),
                        const SizedBox(height: 16),
                        Text(user['email'].toString()),
                      ],
                    ),
                  );
                },
              );
            },
            icon: CircleAvatar(backgroundImage: NetworkImage(user["photo"].toString())),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: Static.chatsReference.child(buatRoomId(Static.uid.toString(), user["uid"].toString())).child("messages").onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.snapshot.value == null) {
                    return const Center(child: Text("Pesan kosong"));
                  } else {
                    Map<Object?, Object?> data = snapshot.data!.snapshot.value as Map<Object?, Object?>;
                    List<Object?> chats = data.values.toList();
                    chats.sort((a, b) {
                      String? timeOne = a.toString().substring(a.toString().indexOf("time") + 5, a.toString().indexOf(".", a.toString().indexOf("time") + 5));
                      String? timeTwo = b.toString().substring(b.toString().indexOf("time") + 5, b.toString().indexOf(".", b.toString().indexOf("time") + 5));
                      return timeOne.compareTo(timeTwo);
                    });
                    if (chats.isEmpty) {
                      return const Center(child: Text("Pesan kosong"));
                    }
                    return ListView.builder(
                      reverse: false,
                      controller: scroll,
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        Map<Object?, Object?> message = chats[index] as Map<Object?, Object?>;
                        bool isUsers = message["uid"] == Static.uid;
                        return Align(
                          alignment: isUsers ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isUsers ? Colors.green[300] : Colors.grey[300],
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(10),
                                topRight: const Radius.circular(10),
                                bottomLeft: isUsers ? const Radius.circular(10) : const Radius.circular(0),
                                bottomRight: isUsers ? const Radius.circular(0) : const Radius.circular(10),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if ((message["content"] as Map<Object?, Object?>)["file"].toString().isNotEmpty)
                                  GestureDetector(
                                    onTap: () => showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        child: Image.network(
                                          (message["content"] as Map<Object?, Object?>)["file"].toString(),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    ),
                                    child: Image.network(
                                      (message["content"] as Map<Object?, Object?>)["file"].toString(),
                                      height: 200,
                                      width: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                Text(
                                  (message["content"] as Map<Object?, Object?>)["teks"].toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isUsers ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  message["time"].toString().substring(11, 16),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isUsers ? Colors.white70 : Colors.black54,
                                  )
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          if (imageFile != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => setState(() => imageFile = null),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(imageFile!.path),
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 2,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: ValueListenableBuilder<bool>(
              valueListenable: ValueNotifier<bool>(isSending),
              builder: (context, value, child) {
                if (!value) {
                  return Row(
                    children: [
                      IconButton(
                        onPressed: pilihImage,
                        icon: const Icon(Icons.image_outlined, color: Colors.blue),
                      ),
                      Expanded(
                        child: TextField(
                          controller: pesan,
                          decoration: const InputDecoration(
                            hintText: "Ketik pesan...",
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                          onSubmitted: (value) => onSubmit(user, pesan),
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.send,
                        ),
                      ),
                      IconButton(
                        onPressed: () => onSubmit(user, pesan),
                        icon: const Icon(Icons.send_rounded, color: Colors.green),
                      ),
                    ],
                  );
                }
                return const Center(child: CircularProgressIndicator(color: Colors.green));
              },
            ),
          ),
        ],
      ),
    );
  }
}
