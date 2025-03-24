import 'package:flutter/material.dart';
import 'package:hiphop_rnb_bingo/widgets/app_icons.dart';
import 'dart:ui';
import 'app_modal_container.dart';
import 'app_colors.dart';
import 'app_text_style.dart';
import 'app_images.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaymentOptionsModal extends StatelessWidget {
  final VoidCallback onClose;
  final Function(String) onPaymentSelected;
  final bool isInAppPurchase;

  const PaymentOptionsModal({
    super.key,
    required this.onClose,
    required this.onPaymentSelected,
    this.isInAppPurchase = false,
  });

  Widget _buildTitle() {
    return Text(
      isInAppPurchase ? 'Fund from' : 'Pay Fees',
      style: AppTextStyle.poppins(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildPaymentOption(String icon, String title) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onPaymentSelected(title);
          onClose();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      image: DecorationImage(
                        image: AssetImage(icon),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    title,
                    style: AppTextStyle.dmSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              AppIcons(
                icon: AppIconData.arrowRight,
                color: Colors.black,
                size: 24.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Center(
            child: AppModalContainer(
              width: double.infinity,
              height: 300.h,
              fillColor: AppColors.purplePrimary,
              borderColor: AppColors.purpleLight,
              layerColor: AppColors.purpleDark,
              layerTopPosition: -4.h,
              borderRadius: 32.r,
              title: '',
              customTitle: _buildTitle(),
              onClose: onClose,
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Container(
                  width: 320.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 16.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPaymentOption(AppImageData.paypal, 'PayPal'),
                        _buildPaymentOption(AppImageData.cashapp, 'CashApp'),
                        _buildPaymentOption(AppImageData.zelle, 'Zelle'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 