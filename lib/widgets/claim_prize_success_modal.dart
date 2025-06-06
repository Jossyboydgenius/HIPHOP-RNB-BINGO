import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hiphop_rnb_bingo/widgets/app_button.dart';
import 'package:hiphop_rnb_bingo/widgets/app_colors.dart';
import 'package:hiphop_rnb_bingo/widgets/app_images.dart';
import 'package:hiphop_rnb_bingo/widgets/app_modal_container.dart';
import 'package:hiphop_rnb_bingo/widgets/app_text_style.dart';
import 'package:hiphop_rnb_bingo/widgets/app_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hiphop_rnb_bingo/widgets/app_sizer.dart';
import 'package:hiphop_rnb_bingo/services/game_sound_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiphop_rnb_bingo/blocs/balance/balance_bloc.dart';
import 'package:hiphop_rnb_bingo/blocs/balance/balance_event.dart';

class ClaimPrizeSuccessModal extends StatefulWidget {
  final VoidCallback onClose;
  final String amount;
  final bool updateBalance;

  const ClaimPrizeSuccessModal({
    super.key,
    required this.onClose,
    required this.amount,
    this.updateBalance = true,
  });

  @override
  State<ClaimPrizeSuccessModal> createState() => _ClaimPrizeSuccessModalState();
}

class _ClaimPrizeSuccessModalState extends State<ClaimPrizeSuccessModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _soundService = GameSoundService();
  bool _hasUpdatedBalance = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Play a winning sound when showing this modal
    _soundService.playPrizeWin();

    // Update the money balance as soon as the modal appears
    if (widget.updateBalance && !_hasUpdatedBalance) {
      _updateMoneyBalance();
      _hasUpdatedBalance = true;
    }
  }

  void _updateMoneyBalance() {
    try {
      // Get the current money balance from the bloc
      final currentBalance = context.read<BalanceBloc>().state.moneyBalance;

      // Parse the amount string to an integer
      final amountToAdd = int.tryParse(widget.amount) ?? 0;

      // Update the money balance
      if (amountToAdd > 0) {
        context
            .read<BalanceBloc>()
            .add(UpdateMoneyBalance(currentBalance + amountToAdd));
      }
    } catch (e) {
      print('Error updating money balance: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Get appropriate font size based on amount length to prevent overflow
  double _getAmountFontSize() {
    final amountLength = widget.amount.length;
    if (amountLength <= 3) {
      return AppDimension.isSmall ? 78.sp : 68.sp;
    } else if (amountLength <= 5) {
      return AppDimension.isSmall ? 65.sp : 55.sp;
    } else if (amountLength <= 7) {
      return AppDimension.isSmall ? 52.sp : 45.sp;
    } else {
      return AppDimension.isSmall ? 38.sp : 35.sp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppModalContainer(
              width: double.infinity,
              height: AppDimension.isSmall ? 600.h : 300.h,
              fillColor: AppColors.purplePrimary,
              borderColor: AppColors.purpleLight,
              layerColor: AppColors.purpleDark,
              layerTopPosition: -4.h,
              borderRadius: AppDimension.isSmall ? 32.r : 24.r,
              showCloseButton: false,
              onClose: () {},
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: AppDimension.isSmall ? 20.h : 20.h),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      RotationTransition(
                        turns: _controller,
                        child: AppIcons(
                          icon: AppIconData.glowing,
                          size: AppDimension.isSmall ? 120.w : 120.w,
                        ),
                      ),
                      AppImages(
                        imagePath: AppImageData.money1,
                        width: AppDimension.isSmall ? 100.w : 100.w,
                        height: AppDimension.isSmall ? 100.h : 100.h,
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimension.isSmall ? 6.h : 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '+\$${widget.amount}',
                        style: AppTextStyle.textWithStroke(
                          fontSize: _getAmountFontSize(),
                          textColor: AppColors.deepPurple,
                          strokeColor: Colors.white,
                          strokeWidth: AppDimension.isSmall ? 8.w : 6.w,
                          fontFamily: AppTextStyle.poppinsFont,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Claimed',
                    style: AppTextStyle.textWithStroke(
                      fontSize: AppDimension.isSmall ? 16.sp : 12.sp,
                      textColor: Colors.white,
                      strokeColor: AppColors.darkPurple3,
                      strokeWidth: AppDimension.isSmall ? 6.w : 5.w,
                      fontFamily: AppTextStyle.mochiyPopOneFont,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppDimension.isSmall ? 50.h : 40.h),
            SizedBox(
              width: AppDimension.isSmall ? 180.w : 180.w,
              child: AppButton(
                text: 'Close',
                textStyle: AppTextStyle.poppins(
                  fontSize: AppDimension.isSmall ? 16.sp : 16.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                fillColor: AppColors.darkPurple,
                layerColor: AppColors.darkPurple2,
                height: AppDimension.isSmall ? 70.h : 50.h,
                layerHeight: AppDimension.isSmall ? 55.h : 42.h,
                layerTopPosition: -2.h,
                hasBorder: true,
                borderColor: Colors.white,
                onPressed: () {
                  _soundService.playButtonClick();
                  Navigator.of(context).pop();
                  widget.onClose();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
