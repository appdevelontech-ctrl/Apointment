// features/patient/screens/patient_otp_screen.dart

import 'package:appointment_app/features/user/controllers/user_auth_controller.dart';
import 'package:appointment_app/features/user/views/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

const Color kTeal = Color(0xFF137C76);
const Color kTealDark = Color(0xFF0E5E59);

class PatientOtpScreen extends StatefulWidget {
  final String phone;
  const PatientOtpScreen({super.key, required this.phone});

  @override
  State<PatientOtpScreen> createState() => _PatientOtpScreenState();
}

class _PatientOtpScreenState extends State<PatientOtpScreen> {
  // Only 4 digits now (matching UI)
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  Timer? _timer;
  int _start = 30;
  bool _isResendEnabled = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      _isResendEnabled = false;
      _start = 30;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          _isResendEnabled = true;
        });
      } else {
        setState(() => _start--);
      }
    });
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto submit when all 4 digits filled
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _verifyOtp();
    }
  }

  // Paste support
  void _onOtpPaste(String text) {
    if (text.length >= 4) {
      final otp = text.substring(0, 4);
      for (int i = 0; i < 4; i++) {
        _controllers[i].text = otp[i];
      }
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 4) return;

    setState(() => _isVerifying = true);

    try {
      final result = await PatientAuthController.verifyOtp(otp);

      // ----------------------------
      // EXISTING USER → LOGIN SUCCESS
      // ----------------------------
      if (result == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => UserDashboardScreen()),
              (route) => false,
        );

        return;
      }

      // ----------------------------
      // NEW USER → WAIT SECOND OTP
      // ----------------------------
      if (result == "SECOND_OTP") {
        setState(() => _isVerifying = false); // ⭐ loader बंद करो

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Enter SECOND OTP sent after signup"),
            backgroundColor: Colors.green,
          ),
        );

        // OTP boxes reset
        for (var c in _controllers) c.clear();
        _focusNodes[0].requestFocus();

        return;
      }

    } catch (e) {
      // TRY SECOND OTP VERIFICATION
      try {
        final ok = await PatientAuthController.verifySecondOtp(otp);
        if (ok) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const UserDashboardScreen()),
                (_) => false,
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Invalid OTP"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    // RESET OTP
    for (var c in _controllers) c.clear();
    _focusNodes[0].requestFocus();

    setState(() => _isVerifying = false);
  }


  Future<void> _resendOtp() async {
    setState(() => _isResendEnabled = false);
    try {
      await PatientAuthController.sendOtp(widget.phone);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP Resent Successfully!"), backgroundColor: kTeal),
      );
      startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to resend: $e"), backgroundColor: Colors.red),
      );
      setState(() => _isResendEnabled = true);
    }
  }

  String get _maskedPhone => "${widget.phone.substring(0, 5)} ${"* " * 4}${widget.phone.substring(9)}";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [kTeal, kTealDark], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Stack(
          children: [
            // Background Lock Icon
            Positioned(
              top: size.height * 0.09,
              right: 0,
              left: 10,
              child: Icon(Icons.lock_outline_rounded, size: 200, color: Colors.white.withOpacity(0.12)),
            ),

            // Header
            Positioned(
              top: size.height * 0.15,
              left: 30,
              right: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Verification", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  Text("We sent a code to +91 $_maskedPhone", style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ),

            // Bottom Card
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: size.height * 0.63,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 25, offset: const Offset(0, -10))],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
                  child: Column(
                    children: [
                      const Text("Enter OTP", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTealDark)),
                      const SizedBox(height: 8),
                      const Text("Enter the 4-digit code below", style: TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 40),

                      // OTP Boxes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          return SizedBox(
                            width: 62,
                            height: 62,
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              maxLength: 1,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                counterText: "",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: kTeal, width: 2.5),
                                ),
                              ),
                              onChanged: (v) => _onOtpChanged(v, index),
                              onSubmitted: (_) => _verifyOtp(),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 35),

                      // Resend Timer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Didn't receive code? ", style: TextStyle(color: Colors.grey.shade600)),
                          _isResendEnabled
                              ? GestureDetector(
                            onTap: _resendOtp,
                            child: const Text("Resend Code", style: TextStyle(color: kTeal, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                          )
                              : Text("Resend in 00:${_start.toString().padLeft(2, '0')}", style: const TextStyle(color: kTeal, fontWeight: FontWeight.bold)),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: kTealDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          onPressed: _isVerifying ? null : _verifyOtp,
                          child: _isVerifying
                              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              : const Text("Verify & Proceed", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}