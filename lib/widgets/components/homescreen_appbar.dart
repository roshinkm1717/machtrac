import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:machtrac/models/user.dart';
import 'package:machtrac/screens/profile_screen.dart';
import 'package:machtrac/widgets/buttons/action_button.dart';
import 'package:machtrac/widgets/dialog/contactInfo_dialog.dart';
import 'package:machtrac/widgets/dialog/logout_dialog.dart';

class HomeScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  HomeScreenAppBar({this.imageUrl, this.displayName});
  final String imageUrl;
  final User user = User();
  final String displayName;
  Size get preferredSize => const Size.fromHeight(60);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(displayName: displayName)));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CircleAvatar(
                child: imageUrl != null
                    ? Image.network(imageUrl, fit: BoxFit.fill)
                    : Icon(FontAwesomeIcons.userAlt, size: 16),
              ),
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
