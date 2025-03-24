import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hiphop_rnb_bingo/routes/app_routes.dart';
import 'dart:async';
import '../widgets/app_background.dart';
import '../widgets/app_button.dart';
import '../widgets/app_colors.dart';
import '../widgets/app_images.dart';
import '../widgets/app_text_style.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/game_details_container.dart';

class GameDetailsScreen extends StatefulWidget {
  final String? code;

  const GameDetailsScreen({
    super.key,
    this.code,
  });

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  bool _isWaiting = false;
  bool _canStart = false;
  int _remainingSeconds = 60; // 1 minute countdown
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _isWaiting = true;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isWaiting = false;
          _canStart = true;
        }
      });
    });
  }

  String get _timeString {
    final minutes = (_remainingSeconds / 60).floor();
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        return false;
      },
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Column(
              children: [
                const AppTopBar(
                  initials: 'JD',
                  notificationCount: 1,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              top: 5.h,
                              child: AppImages(
                                imagePath: AppImageData.map,
                                width: 40.w,
                                height: 40.h,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 35.h),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.pinkDark,
                                borderRadius: BorderRadius.circular(100.r),
                              ),
                              child: Text(
                                'Game Location (City + Venue Name)',
                                style: AppTextStyle.mochiyPopOne(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: -10.h,
                              height: 60.h,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.purpleDark,
                                  borderRadius: BorderRadius.circular(24.r),
                                ),
                              ),
                            ),
                            Container(
                              width: 250.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24.r),
                                border: Border.all(
                                  color: AppColors.purplePrimary,
                                  width: 3.w,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24.r),
                                child: AppImages(
                                  imagePath: AppImageData.gameImage,
                                  width: 250.w,
                                  height: 250.h,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Game Name Lorem ipsum dolor sit amet',
                          textAlign: TextAlign.center,
                          style: AppTextStyle.mochiyPopOne(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        GameDetailsContainer(
                          host: 'John Doe',
                          dj: 'DJ Ray',
                          rounds: '3 rounds',
                          musicTheme: '90s R&B',
                          gameType: 'Classic',
                          gameStyles: const [
                            'T-Shape',
                            'Blackout',
                            'X Pattern',
                            'Four Corners',
                            'Straight Line',
                          ],
                          timeRemaining: _timeString,
                        ),
                        SizedBox(height: 24.h),
                        SizedBox(
                          width: 200.w,
                          child: _canStart
                              ? AppButton(
                                  text: 'Start',
                                  fillColor: AppColors.greenDark,
                                  layerColor: AppColors.greenBright,
                                  height: 50.h,
                                  hasBorder: true,
                                  layerTopPosition: -2.h,
                                  layerHeight: 42.h,
                                  fontFamily: AppTextStyle.poppinsFont,
                                  fontSize: 18.sp,
                                  onPressed: () {
                                    // Handle start game
                                  },
                                )
                              : AppButton(
                                  text: _isWaiting ? 'Waiting...' : 'Join Game',
                                  textStyle: AppTextStyle.poppins(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                  fillColor: _isWaiting
                                      ? AppColors.yellowDark
                                      : AppColors.greenDark,
                                  layerColor: _isWaiting
                                      ? AppColors.yellowPrimary
                                      : AppColors.greenBright,
                                  height: 50.h,
                                  hasBorder: true,
                                  layerTopPosition: -2.h,
                                  layerHeight: 42.h,
                                  fontFamily: AppTextStyle.poppinsFont,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                  onPressed: _isWaiting ? null : _startCountdown,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 