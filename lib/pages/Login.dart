import 'package:orobix_manager/constant.dart';
import 'package:orobix_manager/pages/user_page.dart';
import 'package:orobix_manager/providers/authentication.dart';
import 'package:orobix_manager/providers/firestore.dart';
import 'package:orobix_manager/utilities.dart';
import 'package:orobix_manager/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'admin_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool register = false;
  bool _isObscure = true;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final _emailForm = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  final _passwForm = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  final _nameForm = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  final _surnameForm = GlobalKey<FormState>();
  final _surnameController = TextEditingController();


  @override
  void initState() {
    initializeStorage();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
  }

  void initializeStorage() async {
    _passwordController.text = await _storage.read(key: "password") ?? "";
    debugPrint("Inizialization of password");
    _emailController.text = await _storage.read(key: "email") ?? "";
    debugPrint("Inizialization of email");
  }


  @override
  Widget build(BuildContext context) {

    FirebaseAuthManager authManager = Provider.of<FirebaseAuthManager>(context);
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 1.5), //(x,y)
                blurRadius: 8.0,
              )
            ],
          ),
          padding: defaultPadding,
          width: 300,
          height: register ? 500 : 400,
          child: Wrap(
            children: [
              Row(
                children: const [
                  logoImage,
                  defaultSizedBoxW,
                  Text(
                    mainName,
                    style: TextStyle(color: Color(0xff41d8a6), fontSize: 50),
                  ),
                ],
              ),
              defaultSizedBoxH,
              Form(
                key: _emailForm,
                child: TextFormField(
                  decoration: const InputDecoration(hintText: "Email"),
                  validator: (input) => validateEmail(input),
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
              ),
              Form(
                key: _passwForm,
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Password",
                    suffixIcon: IconButton(
                      onPressed: () => setState(() {
                        _isObscure = !_isObscure;
                      }),
                      icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  obscureText: _isObscure,
                  validator: (input) => validatePassword(input),
                  controller: _passwordController,
                ),
              ),
              Visibility(
                visible: register,
                child: Column(
                  children: [
                    Form(
                      key: _nameForm,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          hintText: "Name",
                        ),
                        controller: _nameController,
                        validator: (value) => simpleValidation(value),
                      ),
                    ),
                    Form(
                      key: _surnameForm,
                      child: TextFormField(
                        decoration: const InputDecoration(hintText: "Surname"),
                        controller: _surnameController,
                        validator: (value) => simpleValidation(value),
                      ),
                    ),
                  ],
                ),
              ),
              defaultSizedBoxH,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: register,
                        onChanged: (value) => setState(() {
                          register = !register;
                        }),
                      ),
                      Text(register ? "Login" : "Register"),
                    ],
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        await _storage.write(
                            key: "email", value: _emailController.text);
                        await _storage.write(
                            key: "password", value: _passwordController.text);

                        if (_emailForm.currentState!.validate() &&
                            _passwForm.currentState!.validate()) {
                          if (register) {
                            if (_nameForm.currentState!.validate() &&
                                _surnameForm.currentState!.validate()) {
                              showToast(context, "Logging in...");
                              String? response = await authManager.register(
                                  _emailController.text,
                                  _passwordController.text,
                                  _nameController.text,
                                  _surnameController.text);
                              if (response != null) {
                                showToast(context, response);
                              } else {
                                Get.to(() => const UserPage());
                              }
                            }
                            return;
                          } else {
                            showToast(context, "Logging in...");
                            String? response = await authManager.login(
                                _emailController.text,
                                _passwordController.text);

                            if (response == null) {
                              if (await FirebaseStoreManager()
                                      .getUserRole(authManager.userID) ==
                                  "admin") {
                                Get.to(() => AdminPage());
                              } else {
                                Get.to(() => UserPage());
                              }
                            } else {
                              showToast(context, response);
                            }
                          }
                        }
                      },
                      child: Text(register ? "Register" : "Sign in")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/*
class Data extends StatelessWidget {
  const Data({Key? key, required this.instance, required this.uid})
      : super(key: key);
  final FirebaseFirestore instance;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
          stream: instance
              .collection('users')
              .doc(uid)
              .collection("permessi")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            var request = snapshot.requireData;
            print(request.size);
            return SizedBox(
              width: 300,
              height: 500,
              child: ListView.builder(
                  itemCount: request.size,
                  itemBuilder: (context, index) {
                    DateTime time = DateTime.parse(request.docs[index]["signIn"]);
                    return Card(
                      elevation: 2,
                      child: ListTile(
                        title: Text(request.docs[index]["name"]),
                        subtitle: Text(request.docs[index]["email"]),
                        trailing: request.docs[index]["approved"] ?
                        const Icon(Icons.offline_pin_rounded, color: Colors.green,)
                            : const Icon(Icons.warning_amber_outlined, color: Colors.yellow,),
                        leading: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text("Req: ${time.month}-${time.day} H: ${time.hour}:${time.minute}"),
                          )
                      ),
                    );
                  }),
            );
            return Text(request.toString());
          }),
    );
  }
}*/
