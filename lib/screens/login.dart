import 'package:e_voting_app/controllers/auth_controller.dart';
import 'package:e_voting_app/screens/auth.dart';
import 'package:e_voting_app/screens/screens.dart';
import 'package:e_voting_app/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: SingleChildScrollView(
          child: Form(
        key: _formKey,
        child: SafeArea(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text('Login',
                      style: TextStyle(
                          fontSize: 30.0,
                          color: Colors.green,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                InputField(
                  controller: _emailController,
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email,
                  type: TextInputType.emailAddress,
                  obscure: false,
                ),
                InputField(
                  controller: _passwordController,
                  hintText: 'Enter your password',
                  prefixIcon: Icons.lock,
                  type: TextInputType.text,
                  obscure: true,
                ),
                Consumer<AuthController>(
                  builder: (context, value, child) => Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 40.0),
                      child: ElevatedButton.icon(
                        onPressed: value.isLoading
                            ? () {}
                            : () async {
                                final res = await context
                                    .read<AuthController>()
                                    .loginUser(_emailController.text,
                                        _passwordController.text);

                                if (res == 'OK') {
                                  Get.to(const ElectChain());
                                }
                              },
                        label: Text(value.isLoading ? 'Loading..' : 'SIGN IN'),
                        icon: const Icon(Icons.verified_user),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 40),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        if (_emailController.text.trim().isEmpty) {
                          Get.showSnackbar(const GetSnackBar(
                            message: 'Enter Email Address',
                            duration: Duration(seconds: 2),
                          ));
                        } else {
                          context.read<AuthController>().forgotPassword(
                                _emailController.text,
                              );
                        }
                      },
                      child: const Text("Forgot Password ?"),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                ElevatedButton(
                  onPressed: () => Get.to(const AuthScreen()),
                  child: const Text(
                    'Dont have an account ? Sign up there',
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                )
              ]),
        ),
      )),
    );
  }
}
