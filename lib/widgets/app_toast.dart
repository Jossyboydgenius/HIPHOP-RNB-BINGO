import 'package:flutter/material.dart';
import 'package:hiphop_rnb_bingo/widgets/app_images.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';
import 'app_text_style.dart';

class AppToast extends StatefulWidget {
  final String message;
  final VoidCallback onClose;
  final Duration duration;
  final bool showCloseIcon;
  final bool showInfoIcon;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final String? infoIcon;

  const AppToast({
    super.key,
    required this.message,
    required this.onClose,
    this.duration = const Duration(seconds: 3),
    this.showCloseIcon = true,
    this.showInfoIcon = true,
    this.textColor,
    this.backgroundColor,
    this.borderColor,
    this.infoIcon,
  });

  static void show(
    BuildContext context,
    String message, {
    bool showCloseIcon = true,
    bool showInfoIcon = true,
    Color? textColor,
    Color? backgroundColor,
    Color? borderColor,
    String? infoIcon,
    Duration duration = const Duration(seconds: 3),
  }) {
    OverlayState? overlay = Overlay.of(context);
    OverlayEntry? entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: AppToast(
            message: message,
            showCloseIcon: showCloseIcon,
            showInfoIcon: showInfoIcon,
            textColor: textColor,
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            infoIcon: infoIcon,
            duration: duration,
            onClose: () {
              entry?.remove();
            },
          ),
        ),
      ),
    );

    overlay.insert(entry);
  }

  @override
  State<AppToast> createState() => _AppToastState();
}

class _AppToastState extends State<AppToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onClose());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? AppColors.yellowLight2,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: widget.borderColor ?? AppColors.yellowDark4,
                width: 2.w,
              ),
            ),
            child: Row(
              children: [
                if (widget.showInfoIcon)
                  AppImages(
                    imagePath: widget.infoIcon ?? AppImageData.info2,
                    height: 24.h,
                    width: 24.w,
                  ),
                if (widget.showInfoIcon) SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    widget.message,
                    style: AppTextStyle.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: widget.textColor ?? Colors.black,
                    ),
                  ),
                ),
                if (widget.showCloseIcon)
                  AppImages(
                    imagePath: AppImageData.close,
                    height: 24.h,
                    width: 24.w,
                    onPressed: () {
                      _controller.reverse().then((_) => widget.onClose());
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
