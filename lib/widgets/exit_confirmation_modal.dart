import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hiphop_rnb_bingo/widgets/app_button.dart';
import 'package:hiphop_rnb_bingo/widgets/app_colors.dart';
import 'package:hiphop_rnb_bingo/widgets/app_modal_container.dart';
import 'package:hiphop_rnb_bingo/widgets/app_sizer.dart';
import 'package:hiphop_rnb_bingo/widgets/app_text_style.dart';
import 'package:hiphop_rnb_bingo/services/game_sound_service.dart';

class ExitConfirmationModal extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onConfirm;
  final String title;
  final String message;
  final String confirmButtonText;
  final String cancelButtonText;
  final bool exitApp;

  const ExitConfirmationModal({
    Key? key,
    required this.onClose,
    required this.onConfirm,
    this.title = 'Exit Game',
    this.message = 'Are you sure you want to exit the game?',
    this.confirmButtonText = 'Yes',
    this.cancelButtonText = 'No',
    this.exitApp = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final soundService = GameSoundService();

    return Container(
      color: Colors.black54,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppModalContainer(
                width: double.infinity,
                height: AppDimension.isSmall ? 360.h : 320.h,
                fillColor: AppColors.purplePrimary,
                borderColor: AppColors.purpleLight,
                layerColor: AppColors.purpleDark,
                layerTopPosition: -4.h,
                borderRadius: AppDimension.isSmall ? 24.r : 20.r,
                title: title,
                titleStyle: AppTextStyle.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                onClose: () {
                  soundService.playButtonClick();
                  Navigator.of(context).pop(); // Close modal
                  onClose();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.dmSans(
                          fontSize: AppDimension.isSmall ? 16.sp : 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          // decoration: TextDecoration.none,
                        ),
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Yes button
                        AppButton(
                          text: confirmButtonText,
                          textStyle: AppTextStyle.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          fillColor: AppColors.pinkDark,
                          layerColor: AppColors.accent,
                          height: 60.h,
                          width: 120.w,
                          layerHeight: 48.h,
                          layerTopPosition: -1.h,
                          hasBorder: true,
                          borderWidth: 2,
                          borderColor: Colors.white,
                          onPressed: () {
                            soundService.playButtonClick();
                            if (exitApp) {
                              // Exit the app
                              SystemNavigator.pop();
                            } else {
                              // Navigate to previous screen
                              Navigator.of(context).pop(); // Close modal
                              onConfirm();
                            }
                          },
                        ),

                        SizedBox(width: 20.w),

                        // No button
                        AppButton(
                          text: cancelButtonText,
                          textStyle: AppTextStyle.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          fillColor: AppColors.greenDark,
                          layerColor: AppColors.greenBright,
                          height: 60.h,
                          width: 120.w,
                          layerHeight: 48.h,
                          layerTopPosition: -1.h,
                          hasBorder: true,
                          borderColor: Colors.white,
                          borderWidth: 2,
                          onPressed: () {
                            soundService.playButtonClick();
                            Navigator.of(context).pop(); // Close modal
                            onClose();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
