import 'package:flutter/material.dart';

void main() {
  runApp(const SnookerApp());
}

class SnookerApp extends StatelessWidget {
  const SnookerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snooker Shop',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black, // Pure Black Background

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676), // Bright Green
          secondary: Color(0xFFFF5252), // Vibrant Red
          surface: Color(0xFF1E1E1E), // Dark Grey
          onPrimary: Colors.black,
          onSurface: Colors.white,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIconColor: const Color(0xFFFF5252), // Red Icons
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFF00E676),
              width: 2,
            ), // Green Border
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),

        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF00E676),
            foregroundColor: Colors.black,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const AuthSwitcher(),
    );
  }
}

// ---------------------------------------------------------
// 1. THE SWITCHER
// ---------------------------------------------------------
class AuthSwitcher extends StatefulWidget {
  const AuthSwitcher({super.key});

  @override
  State<AuthSwitcher> createState() => _AuthSwitcherState();
}

class _AuthSwitcherState extends State<AuthSwitcher> {
  // REMEMBER: Toggle this to 'false' to see the Login page with the new photo
  final bool _hasLoginBefore = true;

  @override
  Widget build(BuildContext context) {
    if (_hasLoginBefore) {
      return const WelcomeBackPage();
    } else {
      return const LoginPage();
    }
  }
}

// ---------------------------------------------------------
// HELPER WIDGET FOR THE PHOTO LOGO
// ---------------------------------------------------------
// I created a reusable widget for the photo so we don't copy-paste code
class SnookerLogoPhoto extends StatelessWidget {
  const SnookerLogoPhoto({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.0),
        // CHANGED: Use Image.asset instead of Image.network
        child: Image.asset(
          'assets/images/snookerlogo.png', // Ensure this matches your path exactly
          height: 130,
          width: 130,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 2. WELCOME BACK PAGE
// ---------------------------------------------------------
class WelcomeBackPage extends StatelessWidget {
  const WelcomeBackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // REPLACED ICON WITH PHOTO WIDGET HERE
              const SnookerLogoPhoto(),
              const SizedBox(height: 32),
              const Text(
                "Welcome Back\nJunLiTan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Ready to break some frames?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Spacer(),

              FilledButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainDashboard(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text("ENTER SHOP"),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  minimumSize: const Size.fromHeight(50), // Full width button
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  print("Logout pressed");
                },
                child: const Text(
                  "Not Jason? Logout",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 3. LOGIN / SIGNUP PAGE
// ---------------------------------------------------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoginMode = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // REPLACED ICON WITH PHOTO WIDGET HERE
                const Center(child: SnookerLogoPhoto()),
                const SizedBox(height: 24),
                Text(
                  _isLoginMode ? 'Snooker Club' : 'Join the Club',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                if (!_isLoginMode) ...[
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 24),

                FilledButton(
                  onPressed: () {
                    if (_isLoginMode) {
                      print("Logging in...");
                    } else {
                      print("Signing up...");
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(_isLoginMode ? 'LOGIN' : 'SIGN UP'),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLoginMode
                          ? "New member? "
                          : "Already have an account? ",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isLoginMode = !_isLoginMode;
                        });
                      },
                      child: Text(
                        _isLoginMode ? "Create Account" : "Login Here",
                        style: const TextStyle(
                          color: Color(0xFFFF5252),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 4. MAIN DASHBOARD (Home, Bookings, Profile)
// ---------------------------------------------------------
class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  // These are the 3 main pages
  final List<Widget> _pages = [
    const HomeTab(),
    const BookingsTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body changes based on which tab is selected
      body: _pages[_currentIndex],

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF333333), width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.black,
          indicatorColor: const Color(
            0xFF00E676,
          ).withOpacity(0.2), // Subtle green highlight
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.spoke_outlined, color: Colors.grey),
              selectedIcon: Icon(Icons.spoke, color: Color(0xFF00E676)),
              label: 'Play',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined, color: Colors.grey),
              selectedIcon: Icon(
                Icons.calendar_today,
                color: Color(0xFF00E676),
              ),
              label: 'Bookings',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: Colors.grey),
              selectedIcon: Icon(Icons.person, color: Color(0xFF00E676)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// TAB 1: HOME (Action Center)
// ---------------------------------------------------------
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Good Evening,", style: TextStyle(color: Colors.grey)),
                    Text(
                      "Jason",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                // Small Profile Pic or Logo
                const CircleAvatar(
                  backgroundColor: Color(0xFF1E1E1E),
                  child: Icon(Icons.notifications_none, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // BIG ACTION CARD: SCAN QR
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E676), Color(0xFF00C853)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E676).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    size: 60,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Scan Table QR",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "At the shop? Scan the code on the table to start playing immediately.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      // Open Scanner Logic
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("OPEN SCANNER"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Secondary Buttons
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.search,
                    title: "Find Tables",
                    color: const Color(0xFF1E1E1E),
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.history,
                    title: "History",
                    color: const Color(0xFF1E1E1E),
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for small cards
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00E676), size: 30),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// TAB 2: BOOKINGS (List)
// ---------------------------------------------------------
class BookingsTab extends StatelessWidget {
  const BookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "My Bookings",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Toggle Switch (Active vs History) - Visual only for now
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF333333),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          "Upcoming",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "History",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Mock Booking Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 4,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Table #05",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "PENDING",
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        "Tomorrow, 10 Oct",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Icon(Icons.access_time, size: 16, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        "8:00 PM - 10:00 PM (2 hrs)",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// TAB 3: PROFILE (Edit)
// ---------------------------------------------------------
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Image
            Stack(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=11',
                  ), // Mock User Image
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF00E676),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Jason",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "jason@example.com",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // Settings List
            _ProfileMenuItem(
              icon: Icons.person,
              text: "Edit Profile",
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.credit_card,
              text: "Payment Methods",
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.settings,
              text: "Settings",
              onTap: () {},
            ),

            const SizedBox(height: 20),
            const Divider(color: Color(0xFF333333)),
            const SizedBox(height: 20),

            _ProfileMenuItem(
              icon: Icons.logout,
              text: "Log Out",
              textColor: Colors.redAccent,
              iconColor: Colors.redAccent,
              onTap: () {
                // Handle Logout
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Helper for Profile Menu
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  const _ProfileMenuItem({
    required this.icon,
    required this.text,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? Colors.white),
      ),
      title: Text(
        text,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
