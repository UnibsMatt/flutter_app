import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orobix_manager/classes/user_permission.dart';
import 'package:orobix_manager/providers/authentication.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utilities.dart';
import 'package:orobix_manager/providers/firestore.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({Key? key}) : super(key: key);

  @override
  _PermissionPageState createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  String inputText = "";


  @override
  Widget build(BuildContext context) {
    String userId = Provider.of<FirebaseAuthManager>(context).userID;

    return Scaffold(
      body: StreamBuilder(stream: FirebaseStoreManager().retrieveUserPermit(userId),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(!snapshot.hasData){
          return const Center(child: Text("No data"));
        }
        List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
        return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index){
              UserPermission perm = UserPermission.fromDocuments(documents[index]);
              return UserPermissionCard(userPermission: perm);
        });
      },),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addPermit(context)
        ,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
