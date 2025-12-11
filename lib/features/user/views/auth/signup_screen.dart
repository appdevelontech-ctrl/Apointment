// import 'package:flutter/material.dart';
// import '../controllers/user_auth_controller.dart';
// import 'otp_screen.dart';
//
//
// class PatientSignupScreen extends StatefulWidget {
//   final String phone;
//
//   const PatientSignupScreen({super.key, required this.phone});
//
//   @override
//   State<PatientSignupScreen> createState() => _PatientSignupScreenState();
// }
//
// class _PatientSignupScreenState extends State<PatientSignupScreen> {
//   final nameController = TextEditingController();
//   final ageController = TextEditingController();
//   bool loading = false;
//
//   Future<void> createAccount() async {
//     if (nameController.text.isEmpty) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Enter Name")));
//       return;
//     }
//
//     setState(() => loading = true);
//
//     try {
//       final res = await PatientAuthController.signupNewUser();
//
//       // Go to OTP screen for new user (second OTP)
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => PatientOtpScreen(phone: widget.phone),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Error: $e")));
//     } finally {
//       setState(() => loading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Create Account")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Text("Phone: ${widget.phone}", style: const TextStyle(fontSize: 18)),
//             const SizedBox(height: 20),
//
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(labelText: "Full Name"),
//             ),
//             const SizedBox(height: 20),
//
//             TextField(
//               controller: ageController,
//               decoration: const InputDecoration(labelText: "Age"),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 30),
//
//             ElevatedButton(
//               onPressed: loading ? null : createAccount,
//               child: loading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text("Create Account"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
