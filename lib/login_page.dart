import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin/admin_dashboard.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final String adminEmail = "rajeshkaratapu24@gmail.com";
  final String adminPhone = "+919999999999"; // నీ నెంబర్ మార్చుకో
  
  bool isPhoneLogin = false;
  bool otpSent = false;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  ConfirmationResult? confirmationResult;

  // Role బట్టి ఎక్కడికి వెళ్ళాలో డిసైడ్ చేసే ఫంక్షన్
  void _checkRoleAndNavigate() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (user.email == adminEmail || user.phoneNumber == adminPhone) {
      // అడ్మిన్ అయితే డాష్‌బోర్డ్ కి
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
    } else {
      // నార్మల్ యూజర్ అయితే హోమ్ పేజీ కి
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
    }
  }

  // 1. Google Login (Bug Fixed)
  Future<void> _loginWithGoogle() async {
    try {
      final provider = GoogleAuthProvider();
      try {
        await FirebaseAuth.instance.signInWithPopup(provider);
      } catch (e) {
        if (FirebaseAuth.instance.currentUser == null) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Cancelled.")));
          return;
        }
      }
      if (mounted) _checkRoleAndNavigate();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // 2. Phone Login - OTP పంపడం
  Future<void> _sendOTP() async {
    String phone = _phoneController.text.trim();
    if (phone.isEmpty) return;
    
    try {
      confirmationResult = await FirebaseAuth.instance.signInWithPhoneNumber(phone);
      setState(() => otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP పంపబడింది!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // 3. Phone Login - OTP వెరిఫై చేయడం
  Future<void> _verifyOTP() async {
    try {
      try {
        await confirmationResult!.confirm(_otpController.text.trim());
      } catch (e) {
        if (FirebaseAuth.instance.currentUser == null) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP తప్పు!")));
          return;
        }
      }
      if (mounted) _checkRoleAndNavigate();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black, 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage())),
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          width: 400,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A), 
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10)
          ),
          child: !isPhoneLogin ? _buildGoogleLogin() : _buildPhoneLogin(),
        ),
      ),
    );
  }

  Widget _buildGoogleLogin() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.account_circle, size: 80, color: Colors.white),
        const SizedBox(height: 30),
        const Text("L O G I N", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 3)),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          icon: Image.network("https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg", height: 24),
          label: const Text("Sign in with Google", style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
          onPressed: _loginWithGoogle,
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: const Icon(Icons.phone_android),
          label: const Text("Sign in with Phone", style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
          onPressed: () => setState(() => isPhoneLogin = true),
        ),
      ],
    );
  }

  Widget _buildPhoneLogin() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.phone_android, size: 60, color: Colors.greenAccent),
        const SizedBox(height: 20),
        const Text("P H O N E   L O G I N", style: TextStyle(color: Colors.white, letterSpacing: 2)),
        const SizedBox(height: 30),
        if (!otpSent) ...[
          TextField(
            controller: _phoneController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(hintText: "+91 Enter Phone Number", hintStyle: const TextStyle(color: Colors.white38), filled: true, fillColor: Colors.black, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 20),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)), onPressed: _sendOTP, child: const Text("Get OTP")),
        ] else ...[
          TextField(
            controller: _otpController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(hintText: "Enter 6-digit OTP", hintStyle: const TextStyle(color: Colors.white38), filled: true, fillColor: Colors.black, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 20),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)), onPressed: _verifyOTP, child: const Text("Verify & Login")),
        ],
        const SizedBox(height: 20),
        TextButton(onPressed: () => setState(() { isPhoneLogin = false; otpSent = false; }), child: const Text("← Back", style: TextStyle(color: Colors.white54)))
      ],
    );
  }
}
