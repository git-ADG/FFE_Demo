import 'package:ffe_demo_app/config/config.dart';
import 'package:ffe_demo_app/pages/home/homepage.dart';
import 'package:ffe_demo_app/states/states.dart';
import 'package:flutter/material.dart';
import 'package:ffe_demo_app/widgets/widgets.dart';
import 'package:ffe_demo_app/utils/utils.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  final void Function() onTapSignUp;
  const LoginForm({
    super.key,
    required this.onTapSignUp,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey emailWidgetKey = GlobalKey();
  final GlobalKey passwordWidgetKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool obscurePassword = true;
  bool isLoggingIn = false;

  Future<void> validateAndLogin(
      AuthCharacterStatesProvider authCharacter) async {
    if (!_formKey.currentState!.validate()) {
      authCharacter.fail();
      return;
    }
    setState(() {
      isLoggingIn = true;
    });
    try {
      await Provider.of<AuthProvider>(context, listen: false).login(
        email: emailController.text,
        password: passwordController.text,
      );
      await authCharacter.success();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Homepage.route,
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        isLoggingIn = false;
      });
      await authCharacter.fail();
      rethrow;
    }
  }

  void onTapTextField(
    AuthCharacterStatesProvider authCharacter,
    String? text,
    TextStyle? style,
    GlobalKey key, {
    bool checkForPassword = false,
  }) {
    authCharacter.isChecking = true;
    authCharacter.isHandsUp = false;
    if (checkForPassword && obscurePassword) {
      authCharacter.isHandsUp = true;
    }
    Size? textFieldSize = UIUtils.getWidgetSize(key);
    if (text != null && style != null && textFieldSize != null) {
      authCharacter.look(
        text: text,
        style: style,
        maxFieldWidth: textFieldSize.width,
      );
    }
  }

  void onTapOutsideTextField(
    AuthCharacterStatesProvider authCharacter,
  ) {
    authCharacter.isChecking = false;
    authCharacter.isHandsUp = false;
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle? textStyle = Theme.of(context).textTheme.bodyMedium;
    return Consumer<AuthCharacterStatesProvider>(
        builder: (context, AuthCharacterStatesProvider authCharacter, _) {
      return SingleChildScrollView(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.fromLTRB(10, 50, 10, 0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    CustomTextField(
                      key: emailWidgetKey,
                      keyboardType: TextInputType.emailAddress,
                      label: "Email",
                      controller: emailController,
                      validator: Validator.isEmailValid,
                      onTap: () {
                        onTapTextField(
                          authCharacter,
                          emailController.text,
                          textStyle,
                          emailWidgetKey,
                        );
                      },
                      onTapOutside: () {
                        onTapOutsideTextField(authCharacter);
                      },
                      textStyle: textStyle,
                      onChanged: (String? text) {
                        onTapTextField(
                          authCharacter,
                          emailController.text,
                          textStyle,
                          emailWidgetKey,
                        );
                      },
                    ),
                    CustomTextField(
                      key: passwordWidgetKey,
                      label: "Password",
                      controller: passwordController,
                      validator: Validator.isPasswordValid,
                      obscureText: obscurePassword,
                      onTap: () {
                        onTapTextField(
                          authCharacter,
                          passwordController.text,
                          textStyle,
                          passwordWidgetKey,
                          checkForPassword: true,
                        );
                      },
                      onTapOutside: () {
                        onTapOutsideTextField(authCharacter);
                      },
                      textStyle: textStyle,
                      onChanged: (String? text) {
                        onTapTextField(
                          authCharacter,
                          passwordController.text,
                          textStyle,
                          passwordWidgetKey,
                          checkForPassword: true,
                        );
                      },
                      onSecretChangeButtonPressed: (bool wasObscured) {
                        setState(() {
                          obscurePassword = !wasObscured;
                          authCharacter.isHandsUp = obscurePassword;
                        });
                      },
                    ),
                    CustomElevatedButton(
                      onPressed: () async {
                        authCharacter.isChecking = false;
                        authCharacter.isHandsUp = false;
                        await validateAndLogin(authCharacter);
                      },
                      child: isLoggingIn
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text("Login"),
                    ),
                  ].separate(10),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    CustomTextButton(
                      onPressed: () {
                        onTapOutsideTextField(authCharacter);
                        widget.onTapSignUp();
                      },
                      child: Text(
                        "Sign Up",
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(decoration: TextDecoration.underline),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
