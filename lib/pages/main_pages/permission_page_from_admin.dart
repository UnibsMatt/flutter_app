import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orobix_manager/classes/user_permission.dart';
import 'package:orobix_manager/providers/authentication.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:orobix_manager/providers/firestore.dart';
import 'package:provider/provider.dart';

class PermissionPageFromAdmin extends StatefulWidget {
  const PermissionPageFromAdmin({Key? key, required this.userID}) : super(key: key);
  final String userID;

  @override
  _PermissionPageFromAdminState createState() => _PermissionPageFromAdminState();


}

class _PermissionPageFromAdminState extends State<PermissionPageFromAdmin> {
  String inputText = "";

  @override
  Widget build(BuildContext context) {

    String requestUid = Provider.of<FirebaseAuthManager>(context).userID;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.arrow_back),color: Colors.white,),
      ),
      body: StreamBuilder(stream: FirebaseStoreManager().retrieveUserPermit(widget.userID),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(!snapshot.hasData){
            return const Center(child: Text("No data"));
          }
          List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
          return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index){
                UserPermission perm = UserPermission.fromDocuments(documents[index]);
                return UserPermissionCard(userPermission: perm, requestingUid: requestUid,);
              });
        },),

    );
  }
}
