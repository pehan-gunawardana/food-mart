import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/routing/app_router.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  bool _timerFinished = false;

  @override
  void initState() {
    super.initState();
    // Start fade-in animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });

    // Start 2-second delay timer
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _timerFinished = true;
        });
        _checkAuthAndNavigate();
      }
    });
  }

  void _checkAuthAndNavigate() {
    if (!_timerFinished) return;
    
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      final role = authState.user.role.toUpperCase();
      if (role == 'VENDOR') {
        Navigator.of(context).pushReplacementNamed(AppRouter.vendorHome);
      } else if (role == 'RIDER') {
        Navigator.of(context).pushReplacementNamed(AppRouter.riderHome);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRouter.customerHome);
      }
    } else if (authState is Unauthenticated || authState is AuthError) {
      Navigator.of(context).pushReplacementNamed(AppRouter.login);
    }
    // If still in AuthInitial/AuthLoading, the BlocListener will catch the update
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (_timerFinished) {
          _checkAuthAndNavigate();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.secondary, // Charcoal background
        body: Stack(
          children: [
            Center(
              child: AnimatedOpacity(
                opacity: _opacity,
                duration: const Duration(seconds: 1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(24.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.fastfood,
                        size: 80.sp,
                        color: AppTheme.primary, // Vibrant Orange/Red
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'FoodMart',
                      style: GoogleFonts.outfit(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Fast. Fresh. Delivered.',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.grey[400],
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 50.h,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppTheme.primary,
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
