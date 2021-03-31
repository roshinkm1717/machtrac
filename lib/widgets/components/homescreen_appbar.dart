import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'file:///E:/Flutter%20Projects/Machtrac/Mobile/lib/widgets/buttons/action_button.dart';
import 'file:///E:/Flutter%20Projects/Machtrac/Mobile/lib/widgets/dialog/contactInfo_dialog.dart';
import 'file:///E:/Flutter%20Projects/Machtrac/Mobile/lib/widgets/dialog/logout_dialog.dart';

class HomeScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  HomeScreenAppBar({this.imageUrl});
  final String imageUrl;
  Size get preferredSize => const Size.fromHeight(60);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: CircleAvatar(
              child: imageUrl != null ? Image.network(imageUrl) : Icon(FontAwesomeIcons.userAlt, size: 16),
            ),
          ),
          SizedBox(width: 10),
          Text("Machtrac"),
        ],
      ),
      actions: [
        ActionButton(
          text: "Contact us",
          onPressed: () {
            //show contact info
            showDialog(
              context: (context),
              builder: (BuildContext context) {
                return ContactInfoDialog();
              },
            );
          },
        ), // contact us button
        ActionButton(
            text: "Logout",
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return LogOutDialog();
                  });
            }), //logout button
      ],
    );
  }
}
