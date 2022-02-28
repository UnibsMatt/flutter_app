import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orobix_manager/pages/main_pages/permission_page_from_admin.dart';
import 'package:orobix_manager/providers/firestore.dart';
import 'package:orobix_manager/providers/notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class AdminPermissionPage extends StatefulWidget {
  const AdminPermissionPage({Key? key}) : super(key: key);

  @override
  _AdminPermissionPageState createState() => _AdminPermissionPageState();
}

class _AdminPermissionPageState extends State<AdminPermissionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseStoreManager().retrieveUsers(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text("No requests from users"),
            );
          }

          List<QueryDocumentSnapshot> users = snapshot.data!.docs;
          return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 6,
                  child: ListTile(
                    onTap: () => {
                      Get.to(() => PermissionPageFromAdmin(userID: users[index].id))

                    },
                    title: Text(users[index].get("name")),
                    leading: users[index].get("role") == "admin"
                        ? const Icon(Icons.person, color: Colors.deepOrange,)
                        : const Icon(Icons.person),
                    trailing: FutureBuilder<int>(
                      future: FirebaseStoreManager()
                          .retrieveUserPermitLength(users[index].id),
                      builder: (context, snapshot) {
                        return Badge(
                          showBadge: snapshot.data==0 ? false: true,
                          badgeContent: Text(snapshot.data.toString()),
                          position: BadgePosition.topEnd(top: 1, end: 5),
                          child: IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () async{
                              await NotificationManager().initializeNotification();


                              NotificationManager().sendNotification();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              });
        },
      ),
    );
  }
}
