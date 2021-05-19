import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pink_fluffy_unicorns/User.dart';

import 'Chat/Message.dart';

part 'ChatService.g.dart';

class ChatService {
  /// Callback to be registered dynamically for adding data to the UI
  late Function(Message) additionCallback;
  //late List<Message> messages;
  final User user;
  late Future<Box> _localStorage;
  static String? _ownEMail;
  //static final LocalStorage _ownStorage = LocalStorage("own");
  static Box? _ownStorage;

  ChatService({required this.user, required this.additionCallback}) {
    _localStorage = Hive.openBox(user.email);
  }

  static Future<void> initialize() async {
    await Hive.initFlutter();
    Hive
      ..registerAdapter(MessageAdapter())
      ..registerAdapter(MessageTypeAdapter())
      ..registerAdapter(MessageStatusAdapter())
      ..registerAdapter(UserAdapter())
      ..registerAdapter(AccountTypeAdapter())
      ..registerAdapter(AppStatusAdapter());
    _ownStorage = await Hive.openBox("own");
  }

  Future<MessageStatus> sendMessage(Message message) async {
    return MessageStatus.Successful;
  }

  Future<List<Message>> readChat() async {
    return ((await _localStorage).get("messages", defaultValue: [])
            as List<dynamic>)
        .cast<Message>();
  }

  Future<void> writeChat(Future<List<Message>> messages) async {
    (await _localStorage).put("messages", await messages);
  }

  static List<User> readAllChatPartners() {
    return (_ownStorage!.get("chats", defaultValue: []) as List<dynamic>)
        .cast<User>();
  }

  static writeAllChatPartners(List<User> users) {
    _ownStorage!.put("chats", users);
  }

  static String? ownEMail() {
    if (_ownEMail == null) {
      _ownEMail = _ownStorage!.get("email");
    }
    return _ownEMail;
  }

  static void writeOwn(
      {required String email,
      required String password,
      required AccountType accountType}) {
    _ownStorage!
      ..put("email", email)
      ..put("password", password)
      ..put("accountType", accountType);
  }

  static void writeProfile(
      {required String partner,
      required String biography,
      required DateTime immatriculation,
      required DateTime exmatriculation}) {
    _ownStorage!
      ..put("partner", partner)
      ..put("biography", biography)
      ..put("immatriculation", immatriculation)
      ..put("exmatriculation", exmatriculation);
  }

  static void writeAppStatus(AppStatus status) async {
    _ownStorage!.put("appStatus", status);
  }

  static Future<StartupCheckData> startupCheck() async {
    AccountType? _accountType = _ownStorage!.get("accountType");
    AppStatus? _appStatus = _ownStorage!.get("appStatus");
    return StartupCheckData(
        _accountType, _appStatus ?? AppStatus.GreeterPending);
  }

  static void clearAllData() async {
    for (var chatPartner in ChatService.readAllChatPartners()) {
      deleteChat(chatPartner);
    }
    Hive.deleteBoxFromDisk("own");
  }

  static void deleteChat(User user) {
    Hive.deleteBoxFromDisk(user.email);
  }
}

@HiveType(typeId: 5)
enum AppStatus {
  @HiveField(0)
  GreeterPending,
  @HiveField(1)
  RegistrationPending,
  @HiveField(2)
  Operational
}

class StartupCheckData {
  final AccountType? accountType;
  final AppStatus appStatus;

  StartupCheckData(this.accountType, this.appStatus);
}
