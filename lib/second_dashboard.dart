import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:webview_flutter/webview_flutter.dart';

Config? config = Config.fromJson({
  'show_onboarding': false,
  'text1': 'text1',
  'text2': 'text2',
  'text3': 'text3',
  'traffic_url': 'https://www.google.com',
});

String iconPath = 'assets/images/icon.png';

class LoadingWidgt extends StatelessWidget {
  const LoadingWidgt({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: const BoxDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: iconPath.endsWith('svg')
                    ? SvgPicture.asset(
                  iconPath,
                  width: 120,
                  height: 120,
                  color: const Color(0xFF23EFB2),
                )
                    : Image.asset(
                  iconPath,
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    ;
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              OnboardingPage(
                imagePath: 'assets/images/icon.png',
                text: config!.text1,
              ),
              OnboardingPage(
                imagePath: 'assets/images/icon.png',
                text: config!.text2,
              ),
              OnboardingPage(
                imagePath: 'assets/images/icon.png',
                text: config!.text3,
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                    (index) => buildDot(index),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: _currentPage == 2
                ? ElevatedButton(
              onPressed: () {
                // goScreen(screenLaunchUrl);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LaunchUrlPage()),
                );
              },
              child: const Text('Get Started'),
            )
                : ElevatedButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 10,
      width: _currentPage == index ? 20 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFF23EFB2) : Colors.black12,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String text;

  const OnboardingPage(
      {super.key, required this.imagePath, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: iconPath.endsWith('svg')
                  ? SvgPicture.asset(
                iconPath,
                width: 120,
                height: 120,
                color: const Color(0xFF23EFB2),
              )
                  : Image.asset(
                iconPath,
                width: 120,
                height: 120,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class LaunchUrlPage extends StatefulWidget {
  const LaunchUrlPage({super.key});

  @override
  State<LaunchUrlPage> createState() => _LaunchUrlPageState();
}

class _LaunchUrlPageState extends State<LaunchUrlPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: SafeArea(
        child: WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadRequest(Uri.parse(config!.trafficUrl)),
        ),
      ),
    );
  }
}

class Config {
  bool showOnboarding;
  String text1;
  String text2;
  String text3;
  String trafficUrl;

  Config({
    required this.showOnboarding,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.trafficUrl,
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      showOnboarding: json['show_onboarding'],
      text1: json['text1'],
      text2: json['text2'],
      text3: json['text3'],
      trafficUrl: json['traffic_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'show_onboarding': showOnboarding,
      'text1': text1,
      'text2': text2,
      'text3': text3,
      'traffic_url': trafficUrl,
    };
  }
}
