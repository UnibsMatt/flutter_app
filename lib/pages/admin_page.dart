import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:orobix_manager/providers/authentication.dart';
import 'package:orobix_manager/providers/notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:provider/provider.dart';

import 'main_pages/camera_page.dart';
import 'main_pages/permission_page.dart';
import 'main_pages/admin_permission_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();

}

class _AdminPageState extends State<AdminPage> {

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    fcmSubscribe();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("asd");
      if(message.notification != null) {
        NotificationManager().sendNotification();
      }
    });
    //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  }

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    //await Firebase.initializeApp();
    NotificationManager().sendNotification();
    return Future<void>.value();
  }
  void fcmSubscribe() async{
    await _firebaseMessaging.subscribeToTopic('newRequest');
    debugPrint("Subscribed");
  }

  void fcmUnSubscribe() async{
    _firebaseMessaging.unsubscribeFromTopic('newRequest');
    debugPrint("Unsubscribed");
  }



  int _navBarIndex = 0;
  final List<Widget> pages = [
    const AdminPermissionPage(),
    const TakePictureScreen(),
    const PermissionPage(),
    const Text("Req"),
  ];

  final List<MaterialColor> appBarColors = [
    Colors.amber,
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
              return Text("Welcome ${snapshot.data??""}");
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
              icon: const Icon(Icons.manage_accounts),
              label: "Admin",
              backgroundColor: appBarColors[_navBarIndex]),
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
