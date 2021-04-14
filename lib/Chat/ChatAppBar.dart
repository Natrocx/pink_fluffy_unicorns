import 'package:flutter/material.dart';

import '../User.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onTapCallback;
  final VoidCallback onPopCallback;
  final User chatPartner;
  late final Text bottomText;
  late bool isExpanded;
  GlobalKey _key = GlobalKey();

  ChatAppBar(
      {Key? key,
      required this.onTapCallback,
      required this.chatPartner,
      isExpanded,
      required this.onPopCallback})
      : super(key: key) {
    bottomText = Text(chatPartner.email, key: _key);
    this.isExpanded = isExpanded ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: this.onTap,
        child: AppBar(
          title: Text(chatPartner.displayName),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    this.onPopCallback();
                    Navigator.pop(context);
                  }
                  /* Inefficient due to large number of Widget rebuilds - keeping for now...
                    Navigator.popAndPushNamed(
                    context, ExtractArgumentsChatListScreen.routeName,
                    arguments: ChatListScreenArguments(chatPartner.email)),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                     */
                  );
            },
          ),
          bottom: isExpanded
              ? PreferredSize(

                  /// null safety check; should always be the height of the bottomText widget
                  preferredSize:
                      _key.currentContext?.size ?? Size.fromHeight(40.0),
                  child: Padding(
                      child: Text(chatPartner.email),
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0)))
              : null,
        ));
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  void onTap() {
    isExpanded = true;
    onTapCallback();
  }
}
