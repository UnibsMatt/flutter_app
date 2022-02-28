import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orobix_manager/classes/user_permission.dart';


class FirebaseStoreManager {
  final FirebaseFirestore fbInstance = FirebaseFirestore.instance;

  void addUserInfo(String userUid, String name, String surname, String email) async{
    Map<String, dynamic> data = {
      "name": name,
      "surname": surname,
      "role": "user",
      "email": email,
    };
    await fbInstance.collection("users").doc(userUid).set(data);
  }

  Future<String> getUserRole(String userUid) async {
    DocumentSnapshot role = await fbInstance.collection("users").doc(userUid).get();
    return role.get("role");
  }

  Future<String> getUserName(String userUid) async {
    DocumentSnapshot role = await fbInstance.collection("users").doc(userUid).get();
    return role.get("name");
  }

  void addUserPermit(String userUid, UserPermission permit) async{
    Map<String, dynamic> data = permit.toMap();
    await fbInstance.collection("users").doc(userUid).collection("permission").add(data);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> retrieveUserPermit(String userUid){
    return fbInstance.collection("users").doc(userUid).collection("permission").orderBy("request_time", descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> retrieveUsers(){
    return fbInstance.collection("users").snapshots();
  }

  Future<int> retrieveUserPermitLength(String userUid) async {
    var doc = await fbInstance.collection("users").doc(userUid).collection("permission").get();
    int permissionNotApproved = 0;
    for (var e in doc.docs) {
      if(!e.get("approved"))
        {
          permissionNotApproved++;
        }
    }
    return permissionNotApproved;
  }

  approveUSerPermit(String userUid, String permitUid) async {
    await fbInstance.collection("users").doc(userUid).collection("permission").doc(permitUid).update({"approved": true});
  }

}
