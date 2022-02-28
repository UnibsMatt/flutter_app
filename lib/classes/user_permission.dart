import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orobix_manager/providers/firestore.dart';
import 'package:flutter/material.dart';

import '../utilities.dart';

class UserPermission {
  late bool approved;
  late final String name;
  late final String uuid;
  late final String description;
  late final DateTime requestTime;
  late final DateTime startTime;
  late final DateTime endTime;
  String documentID = "";

  UserPermission(
      this.name, this.uuid, this.description, this.startTime, this.endTime) {
    approved = false;
    requestTime = DateTime.now();
  }

  UserPermission.fromDocuments(QueryDocumentSnapshot documentSnapshot) {
    documentID = documentSnapshot.id;
    approved = documentSnapshot.get("approved");
    name = documentSnapshot.get("name");
    uuid = documentSnapshot.get("uuid");
    description = documentSnapshot.get("description");
    // conversion from TimeStamp to dateTime
    requestTime = DateTime.parse(
        documentSnapshot.get("request_time").toDate().toString());
    startTime =
        DateTime.parse(documentSnapshot.get("start_time").toDate().toString());
    endTime =
        DateTime.parse(documentSnapshot.get("end_time").toDate().toString());
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "uuid": uuid,
      "description": description,
      "request_time": requestTime,
      "start_time": startTime,
      "end_time": endTime,
      "approved": approved,
    };
  }

  void uploadUserPermit() {
    FirebaseStoreManager _manager = FirebaseStoreManager();
    _manager.addUserPermit(uuid, this);
  }
}

class UserPermissionCard extends StatefulWidget {
  const UserPermissionCard({Key? key, required this.userPermission, this.requestingUid})
      : super(key: key);
  final UserPermission userPermission;
  final String? requestingUid;

  @override
  _UserPermissionCardState createState() => _UserPermissionCardState();

  Future<bool> isRequestingAdmin() async {
    if(requestingUid==null) return false;

    FirebaseStoreManager _manager = FirebaseStoreManager();
    return await _manager.getUserRole(requestingUid!) == "admin";

  }
}

class _UserPermissionCardState extends State<UserPermissionCard> {
  bool _expandDescription = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          onTap: () {
            setState(() {
              _expandDescription = !_expandDescription;
            });
          },
          onLongPress: () async{
            if(await widget.isRequestingAdmin()){
              showPermitDialog(context, widget.userPermission);

            }
          },

          title: Center(
              child: Text(
            widget.userPermission.name,
            style: const TextStyle(fontSize: 20),
          )),
          subtitle: Column(
            children: [
              Text(
                "Submitted: ${formatDate(widget.userPermission.requestTime)}",
                textAlign: TextAlign.start,
              ),
              Visibility(
                  visible: _expandDescription,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Text("Description: " + widget.userPermission.description),
                      const SizedBox(
                        height: 10,
                      ),
                      Text("From: " +
                          formatDate(widget.userPermission.startTime)),
                      const SizedBox(
                        height: 10,
                      ),
                      Text("To: " + formatDate(widget.userPermission.endTime)),
                    ],
                  )),
            ],
          ),
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          trailing: widget.userPermission.approved
              ? const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                )
              : const Icon(
                  Icons.pending_outlined,
                  color: Colors.yellow,
                ),
        ),
      ),
    );
  }
}
