import 'dart:convert';

import 'package:orobix_manager/classes/user_permission.dart';
import 'package:orobix_manager/constant.dart';
import 'package:orobix_manager/providers/authentication.dart';
import 'package:orobix_manager/providers/firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
          label: 'Remove',
          onPressed: ScaffoldMessenger.of(context).hideCurrentSnackBar)));
}

void showProgressIndicator(context) {
  showDialog(
      context: context,
      builder: (builder) => Container(
              child: SizedBox(
            child: Center(
              child: Wrap(children: const [
                AlertDialog(
                  title: Text("Loading..."),
                  content: Center(child: CircularProgressIndicator()),
                ),
              ]),
            ),
          )));
}

Future<DateTime?> _selectDate(BuildContext context) async {
  TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
  DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020, 1),
      lastDate: DateTime(2030));
  if (picked != null) {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (pickedTime != null) {
      picked = picked
          .add(Duration(hours: pickedTime.hour, minutes: pickedTime.minute));

      return picked;
    }
  }
  return null;
}

Future<void> showPermitDialog(BuildContext context, UserPermission userPermission) async {
  await showDialog(
      context: context,
      builder: (builder) => SizedBox(
            child: Center(
              child: Wrap(
                children: [
                  AlertDialog(
                    title: const Text("Permit confirmation"),
                    content: const ListTile(
                      title: Text("Wanna confirm the permit?"),
                    ),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: Colors.red),
                            onPressed: () {Navigator.of(context).pop(); showToast(context, "Permit refused");},
                            child: const Text(
                              "Refuse",
                              style: TextStyle(color: Colors.white),
                            )),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: Colors.green),
                            onPressed: () {
                              FirebaseStoreManager().approveUSerPermit(userPermission.uuid, userPermission.documentID);
                              Navigator.of(context).pop();
                              },
                            child: const Text(
                              "Accept",
                              style: TextStyle(color: Colors.white),
                            )),
                      ],),
                    ],
                  ),
                ],
              ),
            ),
          ));
}




Future<UserPermission?> addPermit(context) async {
  UserPermission? userPermit;
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _dateStartController = TextEditingController();
  TextEditingController _dateEndController = TextEditingController();
  DateTime? _dateStart = DateTime.now();
  DateTime? _dateEnd = DateTime.now();

  await showDialog(
      context: context,
      builder: (builder) => SizedBox(
            child: Center(
              child: Wrap(children: [
                AlertDialog(
                  title: const Text("Add permit"),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Request description"),
                      defaultSizedBoxH,
                      TextFormField(
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                            hintText: "Description",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            )),
                      ),
                      TextFormField(
                        controller: _dateStartController,
                        readOnly: true,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.date_range_outlined),
                            onPressed: () async {
                              _dateStart = await _selectDate(context);
                              if (_dateStart != null) {
                                _dateStartController.text =
                                    formatDate(_dateStart!);
                              }
                            },
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _dateEndController,
                        readOnly: true,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.date_range_outlined),
                            onPressed: () async {
                              _dateEnd = await _selectDate(context);
                              if (_dateEnd != null) {
                                _dateEndController.text = formatDate(_dateEnd!);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                        onPressed: () async {
                          if (_descriptionController.text.isEmpty) {
                            showToast(context, "Empty description");
                            return;
                          }
                          if (_dateStart!.isAfter(_dateEnd!)) {
                            showToast(context, "Are you a time traveler?");
                            return;
                          }
                          if (_dateStart!.isAtSameMomentAs(_dateEnd!)) {
                            showToast(context,
                                "Start date and end date are the same");
                            return;
                          }
                          if (_dateEnd!.difference(_dateStart!).inMinutes <
                              30) {
                            showToast(context, "Permit is under 30 minutes");
                            return;
                          }

                          FirebaseAuthManager man =
                              Provider.of<FirebaseAuthManager>(context,
                                  listen: false);
                          String? name = await man.getUserName();

                          userPermit = UserPermission(
                              name!,
                              man.userID,
                              _descriptionController.text,
                              _dateStart!,
                              _dateEnd!);
                          userPermit!.uploadUserPermit();
                          Navigator.of(context).pop();
                        },
                        child: const Text("Add")),
                  ],
                )
              ]),
            ),
          ));
  if(userPermit!= null){
    sendNotificationToTopic(userPermit!.name);
  }
  return userPermit;
}

String formatDate(DateTime date) {
  return DateFormat('dd-MM-yyyy – HH:mm').format(date);
}

Future<http.Response> sendNotificationToTopic(String name) {
  return http.post(
    Uri.parse('https://fcm.googleapis.com/fcm/send'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'key=AAAA3PLJn80:APA91bFB8XojeBJ7VzIZpgaCNIfr8icxyaqon96hOj1Cf4-1NJDE8E2iZQj7prdlly6O_vDz7pQQ2gu6upNFS72E5QaHvQtDAlbb0tDZCTKzI-tU4pA0rTJNzfwT6fH95-wdOoHroB5m',
    },
    body: jsonEncode({
      "notification": {
        "title": "Ehi",
        "body": "$name added a request"
      },
      "data": {
        "id": 1,
        "boolean": true
      },
      "priority": "normal",
      "to": "/topics/newRequest"
    }),
  );
}