// పైన ఈ ఇంపోర్ట్స్ యాడ్ చెయ్
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'admin/admin_dashboard.dart';

// ... నీ పాత కోడ్ ...

      // --- DYNAMIC SIDE MENU ---
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: Builder(
          builder: (context) {
            final user = FirebaseAuth.instance.currentUser;
            final isAdmin = user != null && (user.email == "rajeshkaratapu24@gmail.com" || user.phoneNumber == "+919999999999");

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                
                if (user == null) ...[
                  // లాగిన్ అవ్వకపోతే ఇది కనిపిస్తుంది
                  _drawerItem("L O G I N", () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                  }),
                ] else ...[
                  // లాగిన్ అయితే ఇవి కనిపిస్తాయి
                  Padding(
                    padding: const EdgeInsets.only(left: 30, bottom: 20),
                    child: Text(
                      "Hi, ${user.email?.split('@')[0] ?? 'User'}!",
                      style: const TextStyle(color: Colors.blueAccent, fontSize: 16),
                    ),
                  ),
                  _drawerItem("P R O F I L E", () {}),
                  const SizedBox(height: 20),
                  _drawerItem("B O O K M A R K S", () {}),
                  const SizedBox(height: 20),
                  
                  // అడ్మిన్ అయితేనే ఇది కనిపిస్తుంది
                  if (isAdmin) ...[
                    _drawerItem("A D M I N   P A N E L", () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
                    }),
                    const SizedBox(height: 20),
                  ],
                  
                  _drawerItem("L O G O U T", () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                    setState(() {}); // పేజీ రీఫ్రెష్ అవుతుంది
                  }),
                ],
                
                const SizedBox(height: 20),
                _drawerItem("S E T T I N G S", () {}),
                const SizedBox(height: 20),
                _drawerItem("A B O U T", () {}),
                
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.only(left: 30, bottom: 40),
                  child: Text(
                    "W  O  G   S  T  U  D  I  O  S",
                    style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 3),
                  ),
                )
              ],
            );
          }
        ),
      ),
// ... మిగతా కోడ్ ...
