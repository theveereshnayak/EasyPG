

// ignore_for_file: use_build_context_synchronously

import 'package:dormease/helper/ui_elements.dart';
import 'package:dormease/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'business_details.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone, required this.verificationId});

  final String phone;
  final String verificationId; // Added verificationId

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final controller1 = TextEditingController();
  final controller2 = TextEditingController();
  final controller3 = TextEditingController();
  final controller4 = TextEditingController();
  final controller5 = TextEditingController(); // Added controller for 5th digit
  final controller6 = TextEditingController(); // Added controller for 6th digit
  final focus1 = FocusNode();
  final focus2 = FocusNode();
  final focus3 = FocusNode();
  final focus4 = FocusNode();
  final focus5 = FocusNode(); // Added focus for 5th digit
  final focus6 = FocusNode(); // Added focus for 6th digit
  var isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to verify OTP
  Future<void> verifyOtp() async {
    final otp = controller1.text + controller2.text + controller3.text + controller4.text + controller5.text + controller6.text;

    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(LocaleKeys.pleaseEnterValidOtp.tr(),
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      // Create PhoneAuthCredential with the entered OTP and verificationId
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId, // Use the verification ID from login.dart
        smsCode: otp,
      );

      // Sign in with the credential
      await _auth.signInWithCredential(credential);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            Text(LocaleKeys.verificationSuccess.tr(),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            const Icon(Icons.done_all, color: Colors.white)
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ));

      await Future.delayed(const Duration(milliseconds: 2500));

      // Navigate to the next screen (BusinessDetails)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => BusinessDetails(phone: widget.phone)),
            (route) => false,
      );
    } catch (e) {
      // If verification fails, show an error
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("OTP verification failed. Please try again.",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    }
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
              Text(LocaleKeys.verificationCode.tr(),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500)),
              Text(LocaleKeys.verificationDesc.tr(),
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(widget.phone,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InputBox(
                        controller: controller1,
                        currentFocus: focus1,
                        nextFocus: focus2),
                    InputBox(
                        controller: controller2,
                        currentFocus: focus2,
                        nextFocus: focus3),
                    InputBox(
                        controller: controller3,
                        currentFocus: focus3,
                        nextFocus: focus4),
                    InputBox(
                        controller: controller4,
                        currentFocus: focus4,
                        nextFocus: focus5),
                    InputBox(
                        controller: controller5,
                        currentFocus: focus5,
                        nextFocus: focus6),
                    InputBox(
                        controller: controller6,
                        currentFocus: focus6,
                        nextFocus: focus6), // Last focus
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: ExpandedButton(
                  label: LocaleKeys.verifyOtp.tr(),
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    await verifyOtp(); // Call OTP verification function
                    setState(() {
                      isLoading = false;
                    });
                  },
                  isLoading: isLoading,
                ),
              ),
              const SizedBox(height: 16),
              Text(LocaleKeys.resendOtp.tr(),
                  style: const TextStyle(
                      fontSize: 17, decoration: TextDecoration.underline))
            ])),
      ),
    );
  }
}

class InputBox extends StatelessWidget {
  const InputBox(
      {super.key,
        required this.controller,
        required this.currentFocus,
        required this.nextFocus});

  final TextEditingController controller;
  final FocusNode currentFocus;
  final FocusNode nextFocus;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: TextField(
        controller: controller,
        focusNode: currentFocus,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w500),
        inputFormatters: [LengthLimitingTextInputFormatter(1)],
        onChanged: (value) {
          if (value.length == 1) {
            if (currentFocus != nextFocus) {
              nextFocus.requestFocus();
            } else {
              currentFocus.unfocus();
            }
          }
        },
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }
}
