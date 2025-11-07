import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hiphop_rnb_bingo/app/locator.dart';
import 'package:hiphop_rnb_bingo/models/game_model.dart';
import 'package:hiphop_rnb_bingo/routes/app_routes.dart';
import 'package:hiphop_rnb_bingo/services/game_service.dart';
import 'package:hiphop_rnb_bingo/widgets/app_sizer.dart';
import 'package:hiphop_rnb_bingo/widgets/app_toast.dart';
import 'dart:async';
import '../widgets/app_background.dart';
import '../widgets/app_button.dart';
import '../widgets/app_colors.dart';
import '../widgets/app_images.dart';
import '../widgets/app_text_style.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/exit_confirmation_modal.dart';
import '../widgets/game_details_container.dart';
import '../widgets/sound_vibrate_controls.dart';

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
  final GameService _gameService = locator<GameService>();
  GameModel? _gameDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.code != null && widget.code!.isNotEmpty) {
      _fetchGameDetails(widget.code!);
    } else {
      _showErrorToast('Invalid game code provided');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showErrorToast(String message) {
    if (mounted) {
      AppToast.show(
        context,
        message,
        backgroundColor: AppColors.pinkDark,
        borderColor: AppColors.pinkLight,
        textColor: Colors.white,
        showInfoIcon: false,
      );
    }
  }

  Future<void> _fetchGameDetails(String code) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final gameDetails = await _gameService.getGameByCode(code);

      if (!mounted) return;

      if (gameDetails != null) {
        setState(() {
          _gameDetails = gameDetails;
          _isLoading = false;
        });

        if (gameDetails.isRemote) {
          // Wrong game mode
          _showErrorToast(
              'This is a remote online game. Please join from the online section.');
        }
      } else {
        _showErrorToast('Game not found or unavailable');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorToast('Error loading game details: ${e.toString()}');
        setState(() {
          _isLoading = false;
        });
      }
    }
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

  // Show exit confirmation dialog
  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExitConfirmationModal(
        title: 'Exit Game Setup',
        message: 'Are you sure you want to go back to the home screen?',
        confirmButtonText: 'Yes',
        cancelButtonText: 'No',
        exitApp: false,
        onClose: () {
          // Do nothing on close, modal will be dismissed
        },
        onConfirm: () {
          // Navigate back to home screen
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show exit confirmation dialog instead of going back immediately
        _showExitConfirmation(context);
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            AppBackground(
              child: SafeArea(
                child: Column(
                  children: [
                    const AppTopBar(
                      initials: 'JD',
                      notificationCount: 1,
                    ),
                    if (_isLoading)
                      Expanded(
                        child: Center(
                          child: SpinKitCubeGrid(
                            color: AppColors.yellowPrimary,
                            size: 50.w,
                          ),
                        ),
                      )
                    else if (_gameDetails != null)
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(16.r),
                          child: Column(
                            children: [
                              if (_gameDetails!.gameLocation != null)
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
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.pinkDark,
                                        borderRadius:
                                            BorderRadius.circular(100.r),
                                      ),
                                      child: Text(
                                        _gameDetails!.gameLocation!,
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
                                        borderRadius:
                                            BorderRadius.circular(24.r),
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
                                      child: _gameDetails!.thumbnail != null
                                          ? Image.network(
                                              _gameDetails!.thumbnail!,
                                              width: 250.w,
                                              height: 250.h,
                                              fit: BoxFit.cover,
                                              errorBuilder: (ctx, obj, stack) =>
                                                  AppImages(
                                                imagePath:
                                                    AppImageData.gameImage,
                                                width: 250.w,
                                                height: 250.h,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : AppImages(
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
                                _gameDetails!.title,
                                textAlign: TextAlign.center,
                                style: AppTextStyle.mochiyPopOne(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              GameDetailsContainer(
                                host: _gameDetails!.hostName,
                                dj: _gameDetails!.djName,
                                rounds:
                                    '${_gameDetails!.numberOfRounds} rounds',
                                musicTheme:
                                    _gameDetails!.musicCategories.join(', '),
                                gameType: _gameDetails!.categoryType,
                                gameStyles: _gameDetails!.winningPattern,
                                timeRemaining: _timeString,
                              ),
                              SizedBox(height: 24.h),
                              SizedBox(
                                width: 200.w,
                                child: _canStart
                                    ? AppButton(
                                        text: 'Start',
                                        textStyle: AppTextStyle.poppins(
                                          fontSize: AppDimension.isSmall
                                              ? 18.sp
                                              : 18.sp,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                        fillColor: AppColors.greenDark,
                                        layerColor: AppColors.greenBright,
                                        height:
                                            AppDimension.isSmall ? 70.h : 50.h,
                                        hasBorder: true,
                                        layerTopPosition: -2.h,
                                        layerHeight:
                                            AppDimension.isSmall ? 54.h : 42.h,
                                        fontFamily: AppTextStyle.poppinsFont,
                                        fontSize: AppDimension.isSmall
                                            ? 14.sp
                                            : 18.sp,
                                        onPressed: () {
                                          Navigator.pushReplacementNamed(
                                              context, AppRoutes.gameScreen);
                                        },
                                      )
                                    : AppButton(
                                        text: _isWaiting
                                            ? 'Waiting...'
                                            : 'Join Game',
                                        textStyle: AppTextStyle.poppins(
                                          fontSize: AppDimension.isSmall
                                              ? 18.sp
                                              : 18.sp,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                        fillColor: _isWaiting
                                            ? AppColors.yellowDark
                                            : AppColors.greenDark,
                                        layerColor: _isWaiting
                                            ? AppColors.yellowPrimary
                                            : AppColors.greenBright,
                                        height:
                                            AppDimension.isSmall ? 70.h : 50.h,
                                        hasBorder: true,
                                        layerTopPosition: -2.h,
                                        layerHeight:
                                            AppDimension.isSmall ? 54.h : 42.h,
                                        fontFamily: AppTextStyle.poppinsFont,
                                        fontSize: AppDimension.isSmall
                                            ? 18.sp
                                            : 18.sp,
                                        fontWeight: FontWeight.w800,
                                        onPressed:
                                            _isWaiting ? null : _startCountdown,
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
            // Add sound vibrate controls
            const SoundVibrateControls(
              topPosition: 100, // Shifted down by 20 points from default
            ),
          ],
        ),
      ),
    );
  }
}
