import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hiphop_rnb_bingo/widgets/app_button.dart';
import 'package:hiphop_rnb_bingo/widgets/app_colors.dart';
import 'package:hiphop_rnb_bingo/widgets/app_images.dart';
import 'package:hiphop_rnb_bingo/widgets/app_text_style.dart';
import 'package:hiphop_rnb_bingo/widgets/app_sizer.dart';
import 'package:hiphop_rnb_bingo/widgets/app_modal_container.dart';
import 'package:hiphop_rnb_bingo/services/game_sound_service.dart';
import 'package:hiphop_rnb_bingo/widgets/claim_prize_success_modal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiphop_rnb_bingo/blocs/bingo_game/bingo_game_bloc.dart';
import 'package:hiphop_rnb_bingo/blocs/bingo_game/bingo_game_event.dart';
import 'package:hiphop_rnb_bingo/widgets/leaderboard/winner_leaderboard_modal.dart';
import 'package:hiphop_rnb_bingo/blocs/balance/balance_bloc.dart';
import 'package:hiphop_rnb_bingo/blocs/balance/balance_event.dart';

class VictoryModal extends StatefulWidget {
  final VoidCallback onClaimPrize;
  final int roundNumber;
  final int prizeAmount;
  final int nextRoundSeconds;
  final bool isFinalRound;
  final int totalRounds;

  const VictoryModal({
    super.key,
    required this.onClaimPrize,
    required this.roundNumber,
    required this.prizeAmount,
    this.nextRoundSeconds = 60,
    this.isFinalRound = false,
    this.totalRounds = 3,
  });

  @override
  State<VictoryModal> createState() => _VictoryModalState();
}

class _VictoryModalState extends State<VictoryModal>
    with SingleTickerProviderStateMixin {
  late Timer _countdownTimer;
  late int _remainingSeconds;
  final _soundService = GameSoundService();
  bool _hasClaimed = false;
  double _grandTotalPrize = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.nextRoundSeconds;
    _grandTotalPrize = widget.prizeAmount.toDouble();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _countdownTimer.cancel();

        // Auto-claim prize if not claimed yet
        if (!_hasClaimed) {
          _claimPrizeAndProceed();
        } else {
          _proceedToNextRound();
        }
      }
    });
  }

  void _proceedToNextRound() {
    // If this is the final round, show the leaderboard
    if (widget.isFinalRound) {
      _showWinnerLeaderboard();
    } else {
      // Shuffle the board for the next round
      context.read<BingoGameBloc>().add(const ResetGame(isGameOver: false));

      Navigator.of(context).pop();
      widget.onClaimPrize();
    }
  }

  void _showWinnerLeaderboard() {
    // Close all existing modals first
    Navigator.of(context).popUntil((route) => route.isFirst);

    // Show the leaderboard with the grand total prize
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WinnerLeaderboardModal(
        totalAmount: _grandTotalPrize,
        // Only update the balance if it hasn't been claimed yet
        updateBalance: !_hasClaimed,
        onBackToHome: () {
          // Reset the game and go back home
          context.read<BingoGameBloc>().add(const ResetGame(isGameOver: true));
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
        },
      ),
    );
  }

  void _claimPrizeAndProceed() {
    // Handle automatic prize claiming when timer expires
    setState(() {
      _hasClaimed = true;
    });

    // Update money balance when prize is claimed
    _updateMoneyBalance(widget.prizeAmount);

    _proceedToNextRound();
  }

  void _updateMoneyBalance(int prizeAmount) {
    // Get current money balance
    final currentBalance = context.read<BalanceBloc>().state.moneyBalance;

    // Update with new prize amount
    context
        .read<BalanceBloc>()
        .add(UpdateMoneyBalance(currentBalance + prizeAmount));
  }

  void _showClaimPrizeSuccessModal() {
    // Stop timer while showing the success modal
    _countdownTimer.cancel();

    // We don't pop the current modal, we just show the claim success over it
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ClaimPrizeSuccessModal(
        amount: widget.prizeAmount.toString(),
        onClose: () {
          // Set the claimed state to true but don't recreate the modal
          setState(() {
            _hasClaimed = true;
          });

          // Update money balance when prize is claimed
          _updateMoneyBalance(widget.prizeAmount);

          // Restart countdown from where it left off
          _startCountdown();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Main container
          AppModalContainer(
            width: AppDimension.isSmall ? 320.w : 280.w,
            height: AppDimension.isSmall ? 420.h : 300.h,
            fillColor: Colors.white,
            borderColor: Colors.white,
            layerColor: AppColors.purpleOverlay,
            showCloseButton: false,
            handleBackNavigation: true,
            onClose: () {
              // Empty function - we'll handle close via button
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 20.h,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Round prize text
                  Text(
                    widget.isFinalRound
                        ? 'Grand Finale Prize'
                        : 'Round ${widget.roundNumber} Prize',
                    style: AppTextStyle.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Prize amount with dollar bill icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppImages(
                        imagePath: AppImageData.money1,
                        width: 36.w,
                        height: 36.h,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        '\$${widget.prizeAmount}',
                        style: AppTextStyle.mochiyPopOne(
                          fontSize: 34.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),

                  // Claim prize instruction text changes based on claimed status
                  Text(
                    _hasClaimed
                        ? 'Claimed prize is added to your wallet'
                        : 'Claim prize to add to your wallet',
                    style: AppTextStyle.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 20.h),

                  // Claim prize or Continue button based on claimed status
                  SizedBox(
                    width: 240.w,
                    child: _hasClaimed
                        ? AppButton(
                            text: 'Continue',
                            textStyle: AppTextStyle.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            fillColor: AppColors.darkPurple,
                            layerColor: AppColors.darkPurple2,
                            extraLayerColor: AppColors.purpleOverlay,
                            extraLayerHeight:
                                AppDimension.isSmall ? 70.h : 50.h,
                            extraLayerTopPosition: 4.h,
                            extraLayerOffset: 1,
                            height: AppDimension.isSmall ? 70.h : 50.h,
                            layerHeight: AppDimension.isSmall ? 57.h : 44.h,
                            layerTopPosition: -1.5.h,
                            hasBorder: true,
                            borderColor: Colors.white,
                            onPressed: () {
                              _soundService.playButtonClick();
                              _proceedToNextRound();
                            },
                            borderRadius: 24.r,
                          )
                        : AppButton(
                            text: 'Claim Prize',
                            textStyle: AppTextStyle.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                            fillColor: AppColors.yellowDark,
                            layerColor: AppColors.yellowPrimary,
                            extraLayerColor: AppColors.purpleOverlay,
                            extraLayerHeight:
                                AppDimension.isSmall ? 70.h : 50.h,
                            extraLayerTopPosition: 4.h,
                            extraLayerOffset: 1,
                            height: AppDimension.isSmall ? 70.h : 50.h,
                            layerHeight: AppDimension.isSmall ? 57.h : 44.h,
                            layerTopPosition: -1.5.h,
                            hasBorder: true,
                            borderColor: Colors.white,
                            onPressed: () {
                              _soundService.playButtonClick();
                              _showClaimPrizeSuccessModal();
                            },
                            borderRadius: 24.r,
                          ),
                  ),

                  SizedBox(height: 16.h),

                  // Next round countdown with specified styling
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.isFinalRound
                              ? 'Proceed to Leaderboard in '
                              : 'Proceed to Round ${widget.roundNumber + 1} in ',
                          style: AppTextStyle.mochiyPopOne(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: '$_remainingSeconds Secs',
                          style: AppTextStyle.mochiyPopOne(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.darkPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // "YOU WON" banner positioned above the modal
          Positioned(
            top: -95.h,
            child: AppImages(
              imagePath: AppImageData.won,
              width: 340.w,
              height: 140.h,
            ),
          ),
        ],
      ),
    );
  }
}
