import 'package:flutter/material.dart';
import 'package:hifzh_master/screens/home/home_screen.dart'; // pastikan file ini ada

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Setelah 3 detik masuk ke HomeScreen
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0D2137);
    const darkNavy = Color(0xFF081421);
    const gold = Color(0xFFD4AF37);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [navy, darkNavy],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ======= LOGO =======
            // Removed harsh box container as requested, replaced with subtle glow
            Container(
              width: MediaQuery.of(context).size.width * 0.85, // Increased size significantly
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: gold.withOpacity(0.15),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/splesh.png',
                fit: BoxFit.contain,
              ),
            ),
            
            // ======= LOADING =======
            const SizedBox(height: 80),
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                color: gold,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
