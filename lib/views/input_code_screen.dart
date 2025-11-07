import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hiphop_rnb_bingo/services/game_service.dart';
import 'package:hiphop_rnb_bingo/widgets/app_images.dart';
import 'package:hiphop_rnb_bingo/widgets/app_sizer.dart';
import 'package:hiphop_rnb_bingo/widgets/app_toast.dart';
import '../app/locator.dart';
import '../routes/app_routes.dart';
import '../widgets/app_background.dart';
import '../widgets/app_button.dart';
import '../widgets/app_colors.dart';
import '../widgets/app_modal_container.dart';
import '../widgets/app_text_style.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_pin_code.dart';
import '../widgets/sound_vibrate_controls.dart';

class InputCodeScreen extends StatefulWidget {
  final bool isInPerson;

  const InputCodeScreen({
    super.key,
    required this.isInPerson,
  });

  @override
  State<InputCodeScreen> createState() => _InputCodeScreenState();
}

class _InputCodeScreenState extends State<InputCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GameService _gameService = locator<GameService>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Focus the text field when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    // Add listener to update button state
    _codeController.addListener(() {
      setState(() {});
    });
  }

  void _showErrorToast(String message) {
    AppToast.show(
      context,
      message,
      showCloseIcon: true,
      showInfoIcon: true,
      infoIcon: AppImageData.info,
      backgroundColor: AppColors.pinkBg,
      borderColor: AppColors.pinkDark,
      textColor: Colors.black54,
    );
  }

  Future<void> _handleCodeSubmission() async {
    if (_codeController.text.length == 4) {
      final code = _codeController.text;

      // Show loading indicator
      setState(() {
        _isLoading = true;
      });

      try {
        // Try to fetch the game details using the code
        final game = await _gameService.getGameByCode(code);

        if (!mounted) return;

        if (game != null) {
          // Navigate based on game mode
          if (widget.isInPerson && !game.isRemote) {
            // In-person game
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.gameDetails,
              arguments: code,
            );
          } else if (!widget.isInPerson && game.isRemote) {
            // Remote online game
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.remoteGameDetails,
              arguments: code,
            );
          } else {
            // Mode mismatch - show error
            _showErrorToast(widget.isInPerson
                ? 'This is an online game! Please join from the online section.'
                : 'This is an in-person game! Please join from the in-person section.');
          }
        } else {
          // Invalid code
          _showErrorToast(
              'Invalid game code! Please try again with a valid game code.');
        }
      } catch (e) {
        // Error during API call
        _showErrorToast('Error: ${e.toString()}');
      } finally {
        // Hide loading indicator if component is still mounted
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
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
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppModalContainer(
                              width: AppDimension.isSmall ? 320.w : 260.w,
                              height: AppDimension.isSmall ? 280.h : 160.h,
                              fillColor: AppColors.purplePrimary,
                              borderColor: AppColors.purpleLight,
                              layerColor: AppColors.purpleDark,
                              title: 'Input Code',
                              titleStyle: AppTextStyle.poppins(
                                fontSize: AppDimension.isSmall ? 24.sp : 20.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              handleBackNavigation: true,
                              onClose: () {
                                Navigator.pushReplacementNamed(
                                    context, AppRoutes.home);
                              },
                              child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
                                child: Container(
                                  width: AppDimension.isSmall ? 380.w : 320.w,
                                  padding: EdgeInsets.symmetric(
                                    vertical:
                                        AppDimension.isSmall ? 16.h : 12.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Center(
                                    child: AppPinCode(
                                      controller: _codeController,
                                      onCompleted: (_) =>
                                          _handleCodeSubmission(),
                                      onChanged: (value) => setState(() {}),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 50.h),
                            Text(
                              widget.isInPerson
                                  ? 'Enter PIN code for the game'
                                  : 'Enter PIN code provided by the host',
                              textAlign: TextAlign.center,
                              style: AppTextStyle.poppins(
                                fontSize: AppDimension.isSmall ? 12.sp : 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 30.h),
                            _isLoading
                                ? SpinKitCubeGrid(
                                    color: AppColors.yellowPrimary,
                                    size: 50.w,
                                  )
                                : AppButton(
                                    text: 'Enter',
                                    textStyle: AppTextStyle.poppins(
                                      fontSize:
                                          AppDimension.isSmall ? 18.sp : 18.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                    fillColor: _codeController.text.length < 4
                                        ? AppColors.grayDark
                                        : AppColors.greenDark,
                                    layerColor: _codeController.text.length < 4
                                        ? AppColors.grayLight
                                        : AppColors.greenBright,
                                    borderColor: Colors.white,
                                    hasBorder: true,
                                    height: AppDimension.isSmall ? 65.h : 50.h,
                                    width: AppDimension.isSmall ? 140.w : 140.w,
                                    layerHeight:
                                        AppDimension.isSmall ? 52.h : 42.h,
                                    layerTopPosition: -3.h,
                                    borderRadius:
                                        AppDimension.isSmall ? 26.r : 16.r,
                                    borderWidth:
                                        AppDimension.isSmall ? 3.w : 3.w,
                                    nullTextColor: Colors.black,
                                    onPressed: _codeController.text.length == 4
                                        ? _handleCodeSubmission
                                        : null,
                                  ),
                            SizedBox(
                                height: AppDimension.isSmall ? 140.h : 110.h),
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
