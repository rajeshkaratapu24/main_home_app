import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_dashboard.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final String adminEmail = "rajeshkaratapu24@gmail.com";
  final String adminPhone = "+918008190113"; // ఇక్కడ నీ ఫోన్ నెంబర్ పెట్టు (+91 తో సహా)
  
  bool isPhoneLogin = false;
  bool otpSent = false;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  ConfirmationResult? confirmationResult;

  // 1. Google Popup Login
  Future<void> _loginWithGoogle() async {
    try {
      final provider = GoogleAuthProvider();
      final userCredential = await FirebaseAuth.instance.signInWithPopup(provider);
      
      // అడ్మిన్ ఈమెయిల్ అయితేనే లోపలికి పంపుతాం
      if (userCredential.user?.email == adminEmail) {
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
      } else {
        await FirebaseAuth.instance.signOut(); // వేరే ఈమెయిల్ అయితే బయటకి గెంటేస్తాం
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Access Denied: కేవలం అడ్మిన్ కి మాత్రమే పర్మిషన్ ఉంది!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google Login Error: $e")));
    }
  }

  // 2. Phone Login - OTP పంపడం
  Future<void> _sendOTP() async {
    String phone = _phoneController.text.trim();
    if (phone != adminPhone) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Access Denied: ఇది అడ్మిన్ ఫోన్ నెంబర్ కాదు!")));
      return;
    }
    
    try {
      // వెబ్ లో ఆటోమేటిక్ గా క్యాచ్ చేసి OTP పంపుతుంది
      confirmationResult = await FirebaseAuth.instance.signInWithPhoneNumber(phone);
      setState(() => otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP పంపబడింది!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // 3. Phone Login - OTP కన్ఫర్మ్ చేయడం
  Future<void> _verifyOTP() async {
    try {
      await confirmationResult!.confirm(_otpController.text.trim());
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP తప్పుగా ఎంటర్ చేసారు!")));
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
          onPressed: () => Navigator.pop(context),
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
          child: !isPhoneLogin 
              ? _buildGoogleLogin() 
              : _buildPhoneLogin(),
        ),
      ),
    );
  }

  // Google Login UI
  Widget _buildGoogleLogin() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.admin_panel_settings, size: 80, color: Colors.blueAccent),
        const SizedBox(height: 30),
        const Text("W O G   A D M I N", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 3)),
        const SizedBox(height: 40),
        
        // Google Button
        ElevatedButton.icon(
          icon: Image.network("https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg", height: 24),
          label: const Text("Sign in with Google", style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, 
            foregroundColor: Colors.black, 
            minimumSize: const Size(double.infinity, 50)
          ),
          onPressed: _loginWithGoogle,
        ),
        const SizedBox(height: 20),
        
        // Phone Button
        ElevatedButton.icon(
          icon: const Icon(Icons.phone_android),
          label: const Text("Sign in with Phone", style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent, 
            foregroundColor: Colors.white, 
            minimumSize: const Size(double.infinity, 50)
          ),
          onPressed: () => setState(() => isPhoneLogin = true),
        ),
      ],
    );
  }

  // Phone Login UI
  Widget _buildPhoneLogin() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.phone_android, size: 60, color: Colors.greenAccent),
        const SizedBox(height: 20),
        const Text("PHONE AUTHENTICATION", style: TextStyle(color: Colors.white, letterSpacing: 2)),
        const SizedBox(height: 30),
        
        if (!otpSent) ...[
          TextField(
            controller: _phoneController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "+91 Enter Phone Number", 
              hintStyle: const TextStyle(color: Colors.white38), 
              filled: true, 
              fillColor: Colors.black,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
            onPressed: _sendOTP, 
            child: const Text("Get OTP")
          ),
        ] else ...[
          TextField(
            controller: _otpController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter 6-digit OTP", 
              hintStyle: const TextStyle(color: Colors.white38), 
              filled: true, 
              fillColor: Colors.black,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
            onPressed: _verifyOTP, 
            child: const Text("Verify & Login")
          ),
        ],
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => setState(() { isPhoneLogin = false; otpSent = false; }), 
          child: const Text("← Back to Google Login", style: TextStyle(color: Colors.white54))
        )
      ],
    );
  }
}
