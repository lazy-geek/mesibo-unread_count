// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:mesibo_flutter_sdk/mesibo.dart';
import 'package:restart_app/restart_app.dart';

void main() async {
  runApp(const FirstMesiboApp());
}

class FirstMesiboApp extends StatelessWidget {
  const FirstMesiboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mesibo Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("First Mesibo App"),
        ),
        body: const HomeWidget(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget>
    implements
        MesiboConnectionListener,
        MesiboMessageListener,
        MesiboSyncListener {
  Mesibo mesibo = Mesibo();
  String mesiboStatus = 'Mesibo status: Not Connected.';
  bool isMesiboInit = false;
  bool isProfilesInit = false;
  MesiboProfile? selfProfile;
  MesiboProfile? remoteProfile;
  types.User? user;
  int unReadMessagesCount = 0;
  int? selectedUser;
  ValueNotifier<List<types.Message>> profileMessages = ValueNotifier([]);
  ValueNotifier<List<types.Message>> summaryMessages = ValueNotifier([]);

  initProfilesUser1() async {
    selfProfile = await mesibo.getSelfProfile() as MesiboProfile;
    remoteProfile = await mesibo.getUserProfile('11');
    user = types.User(
      id: selfProfile!.address.toString(),
      firstName: selfProfile!.name,
    );
    isProfilesInit = true;
    setState(() {});
  }

  initProfilesUser2() async {
    selfProfile = await mesibo.getSelfProfile() as MesiboProfile;
    remoteProfile = await mesibo.getUserProfile('2');
    user = types.User(
      id: selfProfile!.address.toString(),
      firstName: selfProfile!.name,
    );
    isProfilesInit = true;
    setState(() {});
  }

  @override
  void Mesibo_onConnectionStatus(int status) {
    String statusText = status.toString();
    if (status == Mesibo.MESIBO_STATUS_ONLINE) {
      statusText = "Online";
      if (selectedUser == 1) {
        initProfilesUser1();
      } else if (selectedUser == 2) {
        initProfilesUser2();
      }
    } else if (status == Mesibo.MESIBO_STATUS_CONNECTING) {
      statusText = "Connecting";
    } else if (status == Mesibo.MESIBO_STATUS_CONNECTFAILURE) {
      statusText = "Connect Failed";
    } else if (status == Mesibo.MESIBO_STATUS_NONETWORK) {
      statusText = "No Network";
    } else if (status == Mesibo.MESIBO_STATUS_AUTHFAIL) {
      statusText = "The token is invalid.";
    }
    mesiboStatus = 'Mesibo status: $statusText';
    setState(() {});
  }

  initMesiboUser1() async {
    await mesibo.setAccessToken(
        '759b6a38bf5b8867f823ea2a6d96e0a4e0c129d8a31fba3f38eaa4af797za4175518091');
    mesibo.setListener(this);
    await mesibo.setDatabase("6464762.db");
    await mesibo.restoreDatabase('6464762.db', 9999);
    await mesibo.start();

    isMesiboInit = true;
    MesiboReadSession rs = MesiboReadSession.createReadSummarySession(this);
    await rs.read(100);

    setState(() {});
  }

  initMesiboUser2() async {
    await mesibo.setAccessToken(
        'af34e7778c1589c1074dc2cb7e0293056995f96773d3983ecc4b114dwacb66a921ae');
    mesibo.setListener(this);
    await mesibo.setDatabase('6464711.db');
    await mesibo.restoreDatabase('6464711.db', 9999);
    await mesibo.start();
    isMesiboInit = true;
    MesiboReadSession rs = MesiboReadSession.createReadSummarySession(this);
    await rs.read(100);
    setState(() {});
  }

  @override
  void Mesibo_onMessage(MesiboMessage message) {
    // print(
    // "message : ${message.message} , isSummarry :  ${message.isDbSummaryMessage()}");
    if (message.isDbSummaryMessage()) {
      types.User author = types.User(
          id: message.profile!.address.toString(),
          firstName: message.profile!.name ?? 'No name',
          role: types.Role.user);
      types.Message m = types.TextMessage(
        id: message.mid.toString(),
        author: author,
        type: types.MessageType.text,
        text: message.message ?? '',
        createdAt: message.ts?.ts,
      );
      types.Message? msg = summaryMessages.value
          .where((element) => element.id == m.id)
          .lastOrNull;
      if (msg == null) {
        //only add if not added
        final temp = summaryMessages.value;
        temp.add(m);
        temp.sort(
          (a, b) {
            final diff = (b.createdAt ?? 0) - (a.createdAt ?? 0);
            if (diff < 0) {
              return 0;
            } else if (diff > 0) {
              return 1;
            } else {
              return 0;
            }
          },
        );

        summaryMessages.value = [...temp];
      }
    } else {
      types.User currentUser = user!;
      types.User remoteUser = types.User(
          id: message.profile!.address.toString(),
          firstName: message.profile!.name,
          role: types.Role.user);
      types.Message m;
      if (message.isOutgoing()) {
        m = types.TextMessage(
          id: message.mid.toString(),
          author: currentUser,
          type: types.MessageType.text,
          text: message.message ?? '',
          createdAt: message.ts?.ts,
        );
      } else {
        m = types.TextMessage(
            id: message.mid.toString(),
            author: remoteUser,
            type: types.MessageType.text,
            text: message.message ?? '',
            createdAt: message.ts?.ts);
      }

      types.Message? msg = profileMessages.value
          .where((element) => element.id == m.id)
          .lastOrNull;
      if (msg == null) {
        //only add if not added
        final temp = profileMessages.value;
        temp.add(m);
        temp.sort(
          (a, b) {
            final diff = (b.createdAt ?? 0) - (a.createdAt ?? 0);
            if (diff < 0) {
              return 0;
            } else if (diff > 0) {
              return 1;
            } else {
              return 0;
            }
          },
        );

        profileMessages.value = [...temp];
      }

      types.Message? msg2 = summaryMessages.value
          .where((element) => element.id == m.id)
          .lastOrNull;
      if (msg2 == null) {
        //only add if not added
        final temp = summaryMessages.value;
        temp.add(m);
        temp.sort(
          (a, b) {
            final diff = (b.createdAt ?? 0) - (a.createdAt ?? 0);
            if (diff < 0) {
              return 0;
            } else if (diff > 0) {
              return 1;
            } else {
              return 0;
            }
          },
        );

        summaryMessages.value = [...temp];
        print(summaryMessages.value
            .map((e) => (e as types.TextMessage).text)
            .join(' , '));
      }
    }
  }

  _handleSendPressed(types.PartialText partialText) async {
    if (remoteProfile == null) return;
    MesiboMessage message = remoteProfile!.newMessage();
    message.message = partialText.text;
    message.mid = await mesibo.getUniqueMessageId();
    message.send();
  }

  void getUnreadMessagesCount() async {
    final count = await remoteProfile?.getUnreadMessageCount();
    unReadMessagesCount = count ?? 0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  if (selectedUser == null) {
                    selectedUser = 1;
                    setState(() {});
                    initMesiboUser1();
                  } else if (selectedUser == 2) {
                    await Restart.restartApp();
                  }
                },
                child: const Text('Login as user 1'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedUser == null) {
                    selectedUser = 2;
                    setState(() {});
                    initMesiboUser2();
                  } else if (selectedUser == 1) {
                    await Restart.restartApp();
                  }
                },
                child: const Text('Login as user 2'),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: Text(
              mesiboStatus,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          selectedUser == null
              ? const SizedBox()
              : isMesiboInit && isProfilesInit
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              user: user ?? const types.User(id: '0'),
                              selectedUser: selectedUser!,
                              messagesValueListenable: profileMessages,
                              sendMsg: _handleSendPressed,
                              readProfileMsg: () {
                                final rs =
                                    remoteProfile!.createReadSession(this);
                                rs.read(100);
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                                (remoteProfile?.name?.trim()?.isEmpty ?? true)
                                    ? 'N'
                                    : remoteProfile!.name![0]),
                          ),
                          title: Text(
                            remoteProfile?.name ?? 'No name',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Builder(builder: (context) {
                            final types.Message? lastMessage;

                            lastMessage = summaryMessages.value.firstOrNull;

                            return Text(
                              lastMessage == null
                                  ? ''
                                  : (lastMessage as types.TextMessage).text,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                          trailing: CircleAvatar(
                            child: Builder(builder: (context) {
                              getUnreadMessagesCount();
                              return Text(unReadMessagesCount.toString());
                            }),
                          ),
                        ),
                      ),
                    )
                  : const CircularProgressIndicator(),
        ],
      ),
    );
  }

  @override
  void Mesibo_onMessageStatus(MesiboMessage message) {
    // TODO: implement Mesibo_onMessageStatus
  }

  @override
  void Mesibo_onMessageUpdate(MesiboMessage message) {
    // TODO: implement Mesibo_onMessageUpdate
  }

  @override
  void Mesibo_onSync(MesiboReadSession rs, int count) {
    // TODO: implement Mesibo_onSync
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.user,
    required this.selectedUser,
    required this.messagesValueListenable,
    required this.sendMsg,
    required this.readProfileMsg,
  });
  final types.User user;
  final int selectedUser;
  final ValueNotifier<List<types.Message>> messagesValueListenable;
  final Function(types.PartialText) sendMsg;
  final Function() readProfileMsg;

  @override
  State<ChatScreen> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    widget.readProfileMsg();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.messagesValueListenable,
        builder: (context, val, child) {
          return Chat(
            inputOptions: const InputOptions(
              sendButtonVisibilityMode: SendButtonVisibilityMode.always,
            ),
            messages: val.toList(),
            onSendPressed: widget.sendMsg,
            user: widget.user,
          );
        });
  }
}
