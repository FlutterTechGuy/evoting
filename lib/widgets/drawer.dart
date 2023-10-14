import 'package:e_voting_app/controllers/auth_controller.dart';
import 'package:e_voting_app/controllers/user_controller.dart';
import 'package:e_voting_app/models/election_model.dart';
import 'package:e_voting_app/screens/screens.dart';
import 'package:e_voting_app/screens/user_elections.dart';
import 'package:e_voting_app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

ElectionModel? election;
void getElection(userId, electionId) async {
  election = await DataBase().getElection(userId, electionId);
}

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    Get.put(UserController());
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: const BoxDecoration(),
      child: Drawer(
          child: Container(
        color: Colors.green[100],
        child: ListView(padding: const EdgeInsets.all(0.0), children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Obx(
              () => Text(Get.find<UserController>().user.name ?? ''),
            ),
            accountEmail: Obx(
              () => Text(Get.find<UserController>().user.email ?? 'N/A',
                  style: const TextStyle(color: Colors.white54)),
            ),
            currentAccountPicture: CircleAvatar(
                radius: 60.0,
                backgroundImage:
                    NetworkImage(Get.find<UserController>().user.avatar ?? '')),
            otherAccountsPictures: const <Widget>[
              Icon(
                Icons.notification_important,
                color: Colors.white,
              )
            ],
            // onDetailsPressed: () {},
            decoration: const BoxDecoration(color: Colors.green),
          ),
          ListTile(
            title: const Text('Home'),
            subtitle: const Text('Go to homepage'),
            leading: _leadingIcon(Icons.home),
            onLongPress: () {},
          ),
          ListTile(
            title: const Text('Owned Elections'),
            subtitle: const Text('My elections'),
            leading: _leadingIcon(Icons.how_to_vote),
            onLongPress: () {},
            onTap: () => Get.to(const UserElections()),
          ),
          ListTile(
            title: const Text('Log Out'),
            subtitle: const Text('Log out'),
            leading: _leadingIcon(Icons.logout),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              Get.find<AuthController>().signOut();
              Get.to(const Login());
            },
          ),
          const Spacer(),
        ]),
      )),
    );
  }
}

Widget _leadingIcon(IconData icon) {
  return CircleAvatar(
    backgroundColor: Colors.green,
    child: Icon(
      icon,
      color: Colors.white,
    ),
  );
}
