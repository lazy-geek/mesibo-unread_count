// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:mesibo_flutter_sdk/mesibo.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';

class MessagesProvider extends ChangeNotifier {
  List<MesiboMessage> _messages = [];

  List<MesiboMessage> get messages => _messages;

  void addMessage(MesiboMessage newMessage) {
    _messages.add(newMessage);
    notifyListeners();
  }
}

void main() async {
  runApp(const FirstMesiboApp());
}

class FirstMesiboApp extends StatelessWidget {
  const FirstMesiboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MessagesProvider(),
      child: MaterialApp(
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
      ),
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget>
    implements MesiboConnectionListener, MesiboMessageListener {
  Mesibo mesibo = Mesibo();
  String mesiboStatus = 'Mesibo status: Not Connected.';
  bool isMesiboInit = false;
  bool isProfilesInit = false;
  MesiboProfile? selfProfile;
  MesiboProfile? remoteProfile;
  types.User? user;
  int unReadMessagesCount = 0;
  int? selectedUser;

  initProfilesUser1() async {
    selfProfile = await mesibo.getSelfProfile() as MesiboProfile;
    remoteProfile = await mesibo.getUserProfile('35');
    user = types.User(
      id: selfProfile!.address.toString(),
      firstName: selfProfile!.name,
    );
    isProfilesInit = true;
    setState(() {});
  }

  initProfilesUser2() async {
    selfProfile = await mesibo.getSelfProfile() as MesiboProfile;
    remoteProfile = await mesibo.getUserProfile('55');
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
        '864b5bd17f61d46f826f59dbf1aed4d69a1fb6fc14915eff4ab25etaa336df1374');
    mesibo.setListener(this);
    await mesibo.setDatabase('55.db');
    await mesibo.restoreDatabase('55.db', 9999);
    await mesibo.start();
    isMesiboInit = true;
    MesiboReadSession rs = MesiboReadSession.createReadSummarySession(this);
    await rs.read(100);
    rs = MesiboReadSession.createReadSession(this);
    await rs.read(100);
    setState(() {});
  }

  initMesiboUser2() async {
    await mesibo.setAccessToken(
        '59864dc0c3f480fd18a16749efc7fbd73e9ca597eaa3b85edd4a5b6enabaaece8af5');
    mesibo.setListener(this);
    await mesibo.setDatabase('35.db');
    await mesibo.restoreDatabase('35.db', 9999);
    await mesibo.start();
    isMesiboInit = true;
    MesiboReadSession rs = MesiboReadSession.createReadSummarySession(this);
    await rs.read(100);
    rs = MesiboReadSession.createReadSession(this);
    await rs.read(100);
    setState(() {});
  }

  @override
  void Mesibo_onMessage(MesiboMessage message) {
    Provider.of<MessagesProvider>(context, listen: false).addMessage(message);
    // mesiboMessages.add(message);
    setState(() {});
  }

  @override
  void Mesibo_onMessageStatus(MesiboMessage message) {
    print('Mesibo_onMessageStatus: ' + message.status.toString());
  }

  @override
  void Mesibo_onMessageUpdate(MesiboMessage message) {
    print('Mesibo_onMessageUpdate: ' + message.message!);
  }

  _handleSendPressed(types.PartialText partialText) {
    if (remoteProfile == null) return;
    MesiboMessage message = remoteProfile!.newMessage();
    message.message = partialText.text;
    message.send();
    setState(() {});
  }

  void getUnreadMessagesCount() async {
    unReadMessagesCount = await remoteProfile!.getUnreadMessageCount();
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
                              handleSendPressed: _handleSendPressed,
                              user: user ?? const types.User(id: '0'),
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
                            child: Text(remoteProfile?.name?[0] ?? 'N'),
                          ),
                          title: Text(
                            remoteProfile?.name ?? 'No name',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Builder(builder: (context) {
                            MesiboMessage? lastMessage;
                            if (Provider.of<MessagesProvider>(context,
                                    listen: false)
                                .messages
                                .isNotEmpty) {
                              lastMessage = Provider.of<MessagesProvider>(
                                      context,
                                      listen: false)
                                  .messages
                                  .last;
                            }

                            return Text(
                              lastMessage == null
                                  ? ''
                                  : '${lastMessage.isIncoming() ? remoteProfile?.name ?? 'No name' : 'You'}: ${lastMessage.message}',
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
  void dispose() {
    super.dispose();
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.user,
    required this.handleSendPressed,
  });
  final types.User user;
  final void Function(types.PartialText) handleSendPressed;

  @override
  State<ChatScreen> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MessagesProvider>(builder: (context, dataProvider, _) {
      return Chat(
        inputOptions: const InputOptions(
          sendButtonVisibilityMode: SendButtonVisibilityMode.always,
        ),
        messages: dataProvider.messages
            .map(
              (m) => types.TextMessage(
                author: types.User(
                    id: m.isIncoming()
                        ? m.profile?.address ?? ''
                        : widget.user.id),
                text: m.message ?? '',
                id: m.mid.toString(),
              ),
            )
            .toList()
            .reversed
            .toList(),
        onSendPressed: widget.handleSendPressed,
        user: widget.user,
      );
    });
  }
}
