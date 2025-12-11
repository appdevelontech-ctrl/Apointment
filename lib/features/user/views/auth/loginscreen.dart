
import 'package:flutter/material.dart';

import '../../controllers/user_auth_controller.dart';
import 'otp_screen.dart';

const Color kTeal = Color(0xFF137C76);
const Color kTealDark = Color(0xFF0E5E59);

class PatientLoginScreen extends StatefulWidget {
  const PatientLoginScreen({super.key});

  @override
  State<PatientLoginScreen> createState() => _PatientLoginScreenState();
}

class _PatientLoginScreenState extends State<PatientLoginScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _phoneController = TextEditingController();
  int _currentPage = 0;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "text": "Consult top doctors online right from your home",
      "icon": Icons.video_call_rounded,
    },
    {
      "text": "Over 10 Million users trust our medical services",
      "icon": Icons.health_and_safety_rounded,
    },
    {
      "text": "Read patient reviews & book instant appointments",
      "icon": Icons.reviews_rounded,
    },
  ];

  // ------------------------------------------------------------
  // SEND OTP FUNCTION
  // ------------------------------------------------------------
  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty || phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid 10-digit number")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await PatientAuthController.sendOtp(phone);

      if (result["success"] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PatientOtpScreen(phone: phone),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ------------------------------------------------------------
  // UI STARTS
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kTeal, kTealDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // TOP ONBOARDING AREA
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.65,
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.03),

                    // App Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.local_hospital_rounded, color: Colors.white, size: 38),
                        SizedBox(width: 8),
                        Text(
                          "MediPlus",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // PageView Intro Slides
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        itemCount: _onboardingData.length,
                        itemBuilder: (_, index) {
                          final item = _onboardingData[index];
                          return Padding(
                            padding: const EdgeInsets.all(36),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.18),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(item["icon"], size: size.width * 0.2, color: Colors.white),
                                ),
                                const SizedBox(height: 25),
                                Text(
                                  item["text"],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Page Indicator Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingData.length,
                            (i) => AnimatedContainer(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          duration: const Duration(milliseconds: 300),
                          height: 8,
                          width: _currentPage == i ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == i
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ------------------------------------------------------------
            // BOTTOM LOGIN CONTAINER
            // ------------------------------------------------------------
            Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(22, 28, 22, 32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.98),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.26),
                        blurRadius: 22,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: kTeal,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        "Enter your mobile number to continue",
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                      ),

                      const SizedBox(height: 22),

                      // Phone input field
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Text("+91",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                color: Colors.grey),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Mobile Number",
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Send OTP Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kTeal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                              : const Text(
                            "Send OTP",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            "Trouble signing in?",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
