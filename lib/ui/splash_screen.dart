import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_info.dart';
import '../core/app_palette.dart';
import 'widgets/app_logo.dart';

/// صفحه‌ی ورود کوتاه با لوگو و نام توسعه‌دهنده، سپس محو شدن به برنامه.
class SplashGate extends StatefulWidget {
  const SplashGate({super.key, required this.child});

  final Widget child;

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1700), () {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      child: _ready
          ? KeyedSubtree(key: const ValueKey('app'), child: widget.child)
          : const SplashScreen(key: ValueKey('splash')),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = CalcPalette.of(context);
    return Scaffold(
      backgroundColor: p.background,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [p.backgroundTop, p.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOut,
                builder: (context, opacity, child) =>
                    Opacity(opacity: opacity, child: child),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.7, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppLogo(size: 96),
                      const SizedBox(height: 24),
                      Text(
                        AppInfo.appName,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: p.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppInfo.tagline,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 14,
                          color: p.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 3),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOut,
                builder: (context, opacity, child) =>
                    Opacity(opacity: opacity, child: child),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppInfo.developerLabel,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 12,
                        color: p.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) =>
                          CalcPalette.brandGradient.createShader(bounds),
                      child: Text(
                        AppInfo.developer,
                        style: GoogleFonts.vazirmatn(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
