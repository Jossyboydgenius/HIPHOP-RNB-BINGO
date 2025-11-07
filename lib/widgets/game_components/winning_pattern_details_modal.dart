import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hiphop_rnb_bingo/blocs/bingo_game/bingo_game_bloc.dart';
import 'package:hiphop_rnb_bingo/blocs/bingo_game/bingo_game_event.dart';
import 'package:hiphop_rnb_bingo/services/game_sound_service.dart';
import 'package:hiphop_rnb_bingo/widgets/app_colors.dart';
import 'package:hiphop_rnb_bingo/widgets/app_images.dart';
import 'package:hiphop_rnb_bingo/widgets/app_text_style.dart';

class WinningPatternDetailsModal extends StatelessWidget {
  final Map<String, Map<String, dynamic>> winningPatterns;
  final String currentPattern;
  final GameSoundService soundService;

  const WinningPatternDetailsModal({
    Key? key,
    required this.winningPatterns,
    required this.currentPattern,
    required this.soundService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pattern = winningPatterns[currentPattern]!;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: AppColors.purplePrimary,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: AppColors.purpleLight,
            width: 3.w,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current Winning Pattern',
              style: AppTextStyle.mochiyPopOne(
                fontSize: 20.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            // Pattern image
            AppImages(
              imagePath: pattern['image'] as String,
              width: 200.w,
              height: 200.h,
            ),
            SizedBox(height: 16.h),
            // Pattern title
            Text(
              pattern['title'] as String,
              style: AppTextStyle.mochiyPopOne(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            // Pattern description
            Text(
              pattern['description'] as String,
              style: AppTextStyle.dmSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            // Pattern selector
            SizedBox(
              height: 60.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: winningPatterns.length,
                separatorBuilder: (context, index) => SizedBox(width: 12.w),
                itemBuilder: (context, index) {
                  final patternKey = winningPatterns.keys.elementAt(index);
                  final patternData = winningPatterns[patternKey]!;
                  final isSelected = patternKey == currentPattern;

                  return GestureDetector(
                    onTap: () {
                      // Play board tap sound with haptic feedback
                      soundService.playBoardTap();

                      // Update winning pattern
                      context
                          .read<BingoGameBloc>()
                          .add(CheckForWinningPattern(patternType: patternKey));
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 50.w,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.yellowPrimary
                            : AppColors.purplePrimary,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.white,
                          width: 2.w,
                        ),
                      ),
                      child: Center(
                        child: AppImages(
                          imagePath: patternData['image'] as String,
                          width: 40.w,
                          height: 40.h,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 24.h),
            // Close button
            GestureDetector(
              onTap: () {
                // Play board tap sound with haptic feedback
                soundService.playBoardTap();
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 36.w,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.yellowPrimary,
                  borderRadius: BorderRadius.circular(100.r),
                  border: Border.all(
                    color: Colors.white,
                    width: 2.w,
                  ),
                ),
                child: Text(
                  'Got it',
                  style: AppTextStyle.mochiyPopOne(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
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
