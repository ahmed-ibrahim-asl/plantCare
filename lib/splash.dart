//-------------------------- flutter_core ------------------------------
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//----------------------------------------------------------------------

//----------------------------- app_local ------------------------------
import 'package:plantcare/login.dart';
import 'package:plantcare/theme/colors.dart';
//----------------------------------------------------------------------

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Lock screen orientation to portrait mode when the screen is initialized
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    // It's good practice to reset orientations when the widget is disposed,
    // in case other parts of the app support landscape.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _updatePage(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          width: _currentPage == index ? 12.0 : 8.0,
          height: _currentPage == index ? 12.0 : 8.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? AppColors.primary : Colors.grey[400],
          ),
        );
      }),
    );
  }

  void _handleNavigation() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _updatePage,
        children: [
          // Splash Screen 1
          Container(
            color: Colors.white,
            child: SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  Image.asset(
                    'assets/plantcare.png',
                    height: size.height * 0.35,
                  ),
                  const Spacer(flex: 2),
                  _buildDotsIndicator(),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),

          // Splash Screen 2
          Container(
            color: AppColors.textDark,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),
                    Image.asset('assets/plant.jpg', height: size.height * 0.2),
                    const SizedBox(height: 24),
                    Text(
                      'PlantCare AI',
                      style: TextStyle(
                        fontSize: (width * 0.1).clamp(
                          32.0,
                          48.0,
                        ), // Responsive font size with limits
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Monitor your plant\'s health with real-time insights and alerts.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: (width * 0.045).clamp(
                          16.0,
                          22.0,
                        ), // Responsive font size
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5, // Improved line spacing
                      ),
                    ),
                    const Spacer(flex: 4),
                    _buildDotsIndicator(),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _handleNavigation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffE4EFE7),
                        minimumSize: Size(double.infinity, size.height * 0.07),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: (width * 0.05).clamp(18.0, 24.0),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff173b1f),
                        ),
                      ),
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
