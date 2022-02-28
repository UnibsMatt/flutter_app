import 'package:orobix_manager/pages/main_pages/permission_page.dart';
import 'package:orobix_manager/providers/authentication.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:provider/provider.dart';

import 'main_pages/camera_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _navBarIndex = 0;
  final List<Widget> pages = [
    TakePictureScreen(),
    PermissionPage(),
    Text("Req"),
  ];

  final List<MaterialColor> appBarColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context) {
    FirebaseAuthManager authManager = Provider.of<FirebaseAuthManager>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: FutureBuilder(
          future: authManager.getUserName(),
          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
            if (snapshot.hasData) {
              return Text("Welcome ${snapshot.data!}");
            }
            return const Text("Loading");
          },
        ),
        backgroundColor: appBarColors[_navBarIndex],
        leading: TextButton(
          onPressed: () async {
            await FirebaseAuthManager().signOut();

            Get.back();
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: IndexedStack(
        index: _navBarIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: _navBarIndex,
        onTap: (index) {
          setState(() => _navBarIndex = index);
        },
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: "Users",
              backgroundColor: appBarColors[_navBarIndex]),
          BottomNavigationBarItem(
              icon: const Icon(Icons.lock_clock),
              label: "Permit",
              backgroundColor: appBarColors[_navBarIndex]),
          BottomNavigationBarItem(
              icon: const Icon(Icons.monetization_on_outlined),
              label: "Refound",
              backgroundColor: appBarColors[_navBarIndex]),
        ],
      ),
    );
  }
}
