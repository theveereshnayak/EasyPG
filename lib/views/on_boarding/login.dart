// ignore_for_file: use_build_context_synchronously

import 'package:dormease/helper/functions.dart';
import 'package:dormease/helper/lists/country_code_list.dart';
import 'package:dormease/helper/ui_elements.dart';
import 'package:dormease/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final phoneController = TextEditingController();
  var phoneValid = true;
  var selectedCountryCode = '+91';
  var isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to send OTP to user's phone
  Future<void> sendOtp() async {
    final phoneNumber = selectedCountryCode + phoneController.text;

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieved OTP (on some devices)
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Failed to verify phone number. Please try again."),
          backgroundColor: Colors.red,
        ));
      },
      codeSent: (String verificationId, int? resendToken) {
        // Store verification ID for later use (OTP verification)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(phone: phoneNumber, verificationId: verificationId),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Handle timeout
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 235, 245),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset('assets/images/logo.png', height: 150, width: 150),
            Text(LocaleKeys.welcomeText.tr(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            Text(LocaleKeys.optMessage.tr(),
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 32, 8, 16),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, phoneValid ? 0 : 28),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
                        child: DropdownButton<String>(
                          underline: Container(height: 0),
                          style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                          value: selectedCountryCode,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCountryCode = newValue!;
                            });
                          },
                          items: countryCodes
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InputText(
                      controller: phoneController,
                      keyboard: TextInputType.number,
                      hint: LocaleKeys.enterPhoneNo.tr(),
                      min: 10,
                      max: 10,
                      valid: phoneValid,
                      error: LocaleKeys.invalidPhoneNo.tr(),
                      updateValid: (bool isValid) {
                        setState(() {
                          phoneValid = isValid;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: ExpandedButton(
                label: LocaleKeys.requestOtp.tr(),
                onPressed: () async {
                  if (phoneController.text.length < 10 ||
                      !isNumeric(phoneController.text)) {
                    setState(() {
                      phoneValid = false;
                    });
                  } else {
                    setState(() {
                      isLoading = true;
                    });
                    await Future.delayed(const Duration(seconds: 2));
                    setState(() {
                      isLoading = false;
                    });
                    sendOtp();  // Call the OTP sending method
                  }
                },
                isLoading: isLoading,
              ),
            )
          ]),
        ),
      ),
    );
  }
}
