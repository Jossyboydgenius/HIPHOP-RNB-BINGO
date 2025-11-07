import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'dart:io' show Platform;
import '../widgets/app_background.dart';
import '../widgets/app_button.dart';
import '../widgets/app_images.dart';
import '../widgets/app_colors.dart';
import '../widgets/app_text_style.dart';
import '../widgets/app_modal_container.dart';
import '../widgets/app_icons.dart';
import '../enums/modal_type.dart';
import '../routes/app_routes.dart';
import '../widgets/app_sizer.dart';
import '../widgets/exit_confirmation_modal.dart';
import '../services/google_auth_service.dart';
import '../services/apple_auth_service.dart';
import '../services/facebook_auth_service.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../app/locator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  ModalType? _currentModal;
  bool _isModalVisible = false;
  bool _isLoading = false;
  final GoogleAuthService _googleAuthService = locator<GoogleAuthService>();
  final AppleAuthService _appleAuthService = locator<AppleAuthService>();
  final FacebookAuthService _facebookAuthService =
      locator<FacebookAuthService>();

  // Temporary hardcoded token for development
  final String _temporaryToken =
      "dummy-token"; // This can be any string since we're not actually using it

  void _showModal(ModalType type) {
    setState(() {
      _currentModal = type;
      _isModalVisible = true;
    });
  }

  void _hideModal() {
    setState(() {
      _isModalVisible = false;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _currentModal = null;
        });
      }
    });
  }

  // Show exit confirmation dialog
  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExitConfirmationModal(
        title: 'Exit Game',
        message: 'Are you sure you want to exit the game?',
        confirmButtonText: 'Yes',
        cancelButtonText: 'No',
        exitApp: true,
        onClose: () {
          // Do nothing on close, modal will be dismissed
        },
        onConfirm: () {
          // This will be handled inside the ExitConfirmationModal to exit the app
        },
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Bypass actual Google login and use our hardcoded token
      if (mounted) {
        context.read<AuthBloc>().add(SignInWithGoogle(_temporaryToken));
      }

      /* Original implementation - commented out
      final token = await _googleAuthService.signIn();

      if (token != null && mounted) {
        context.read<AuthBloc>().add(SignInWithGoogle(token));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google sign-in cancelled or failed')),
          );
        }
      }
      */
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in error: ${e.toString()}')),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
    // We don't set _isLoading to false here, as the BlocListener will handle it on successful auth
  }

  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Bypass actual Apple login and use our hardcoded token
      if (mounted) {
        context.read<AuthBloc>().add(SignInWithApple(_temporaryToken));
      }

      /* Original implementation - commented out
      final token = await _appleAuthService.signIn();

      if (token != null && mounted) {
        context.read<AuthBloc>().add(SignInWithApple(token));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Apple sign-in cancelled or failed')),
          );
        }
      }
      */
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Apple sign-in error: ${e.toString()}')),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
    // We don't set _isLoading to false here, as the BlocListener will handle it on successful auth
  }

  Future<void> _handleFacebookSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Bypass actual Facebook login and use our hardcoded token
      if (mounted) {
        context.read<AuthBloc>().add(SignInWithFacebook(_temporaryToken));
      }

      /* Original implementation - commented out
      final token = await _facebookAuthService.signIn();

      if (token != null && mounted) {
        context.read<AuthBloc>().add(SignInWithFacebook(token));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Facebook sign-in cancelled or failed')),
          );
        }
      }
      */
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Facebook sign-in error: ${e.toString()}')),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
    // We don't set _isLoading to false here, as the BlocListener will handle it on successful auth
  }

  Widget _buildModalContent(ModalType type) {
    // Determine if we're on iOS to show Apple sign-in option
    final bool isIOS = Platform.isIOS;

    return Column(
      children: [
        SizedBox(height: AppDimension.isSmall ? 14.h : 12.h),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AppDimension.getResponsiveWidth(20).w),
          child: Column(
            children: [
              AppButton(
                text: 'Google',
                iconPath: AppIconData.google,
                iconSize: AppDimension.isSmall ? 18.sp : 20.sp,
                fillColor: AppColors.purpleOverlay,
                layerColor: Colors.white,
                height: AppDimension.isSmall ? 48.h : 44.h,
                hasBorder: true,
                layerTopPosition: 0,
                layerHeight: AppDimension.isSmall ? 38.h : 34.h,
                borderRadius: 100,
                borderColor: Colors.white,
                textColor: Colors.black,
                fontFamily: AppTextStyle.dmSansFont,
                fontSize: AppDimension.getFontSize(12).sp,
                onPressed: _isLoading ? null : _handleGoogleSignIn,
              ),
              SizedBox(height: AppDimension.isSmall ? 12.h : 8.h),
              AppButton(
                text: 'Facebook',
                iconPath: AppIconData.facebook,
                iconSize: AppDimension.isSmall ? 18.sp : 20.sp,
                fillColor: AppColors.purpleOverlay,
                layerColor: Colors.white,
                height: AppDimension.isSmall ? 48.h : 44.h,
                hasBorder: true,
                layerTopPosition: 0,
                layerHeight: AppDimension.isSmall ? 38.h : 34.h,
                borderRadius: 100,
                borderColor: Colors.white,
                textColor: Colors.black,
                fontFamily: AppTextStyle.dmSansFont,
                fontSize: AppDimension.getFontSize(12).sp,
                onPressed: _isLoading ? null : _handleFacebookSignIn,
              ),
              // Only show Apple sign-in button on iOS devices
              if (isIOS) ...[
                SizedBox(height: AppDimension.isSmall ? 12.h : 8.h),
                AppButton(
                  text: 'Apple',
                  iconPath: AppIconData.apple,
                  iconSize: AppDimension.isSmall ? 18.sp : 20.sp,
                  fillColor: AppColors.purpleOverlay,
                  layerColor: Colors.white,
                  height: AppDimension.isSmall ? 48.h : 44.h,
                  hasBorder: true,
                  layerTopPosition: 0,
                  layerHeight: AppDimension.isSmall ? 38.h : 34.h,
                  borderRadius: 100,
                  borderColor: Colors.white,
                  textColor: Colors.black,
                  fontFamily: AppTextStyle.dmSansFont,
                  fontSize: AppDimension.getFontSize(12).sp,
                  onPressed: _isLoading ? null : _handleAppleSignIn,
                ),
              ],
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: EdgeInsets.only(
            bottom: AppDimension.isSmall ? 16.h : 32.h,
            left: AppDimension.getResponsiveWidth(24).w,
            right: AppDimension.getResponsiveWidth(24).w,
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTextStyle.dmSans(
                fontSize: AppDimension.getFontSize(12).sp,
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
              children: [
                const TextSpan(
                  text: 'By continuing, you agree to our ',
                ),
                TextSpan(
                  text: 'Terms of Services & Privacy Policy',
                  style: AppTextStyle.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: AppDimension.getFontSize(12).sp,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          // Navigate to home screen on successful authentication
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else if (state.status == AuthStatus.error) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.errorMessage ?? 'Authentication failed')),
          );

          // Close the loading state
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          // Show exit confirmation dialog instead of navigating back
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
                      const Spacer(),
                      AppImages(
                        imagePath: AppImageData.bingo,
                        height: AppDimension.isSmall ? 280.h : 200.h,
                      ),
                      SizedBox(height: AppDimension.isSmall ? 80.h : 60.h),
                      Container(
                        margin: EdgeInsets.only(
                            bottom: AppDimension.isSmall ? 120.h : 168.h),
                        child: Center(
                          child: Column(
                            children: [
                              AppButton(
                                text: 'Sign In',
                                textStyle: AppTextStyle.poppins(
                                  fontSize: AppDimension.getFontSize(18).sp,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                                fillColor: AppColors.yellowDark,
                                layerColor: AppColors.yellowPrimary,
                                height: AppDimension.isSmall ? 70.h : 50.h,
                                width: AppDimension.isSmall ? 280.w : 240.w,
                                hasBorder: true,
                                layerTopPosition: -1.h,
                                layerHeight: AppDimension.isSmall ? 58.h : 42.h,
                                borderWidth: AppDimension.isSmall ? 2.w : 2.w,
                                borderRadius:
                                    AppDimension.isSmall ? 24.r : 18.r,
                                fontFamily: AppTextStyle.poppinsFont,
                                fontSize: AppDimension.isSmall ? 24.sp : 20.sp,
                                fontWeight: FontWeight.w900,
                                onPressed: () => _showModal(ModalType.signIn),
                              ),
                              SizedBox(
                                  height: AppDimension.isSmall ? 22.h : 22.h),
                              AppButton(
                                text: 'Sign Up',
                                textStyle: AppTextStyle.poppins(
                                  fontSize: AppDimension.getFontSize(18).sp,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                                fillColor: AppColors.purpleDark,
                                layerColor: AppColors.purplePrimary,
                                height: AppDimension.isSmall ? 70.h : 50.h,
                                width: AppDimension.isSmall ? 280.w : 240.w,
                                hasBorder: true,
                                layerTopPosition: -1.h,
                                layerHeight: AppDimension.isSmall ? 58.h : 42.h,
                                borderWidth: AppDimension.isSmall ? 2.w : 2.w,
                                borderRadius:
                                    AppDimension.isSmall ? 24.r : 18.r,
                                fontFamily: AppTextStyle.poppinsFont,
                                fontSize: AppDimension.isSmall ? 24.sp : 20.sp,
                                fontWeight: FontWeight.w900,
                                onPressed: () => _showModal(ModalType.signUp),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: AppDimension.isSmall ? 30.h : 20.h),
                    ],
                  ),
                ),
              ),
              if (_currentModal != null)
                AnimatedOpacity(
                  opacity: _isModalVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    color: Colors.black54,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppDimension.getResponsiveWidth(20).w),
                        child: Center(
                          child: AppModalContainer(
                            width: AppDimension.isSmall ? 320.w : 280.w,
                            // Adjust height based on platform to accommodate for fewer buttons on Android
                            height: AppDimension.isSmall
                                ? (Platform.isIOS ? 380.h : 320.h)
                                : (Platform.isIOS ? 300.h : 250.h),
                            fillColor: _currentModal == ModalType.signIn
                                ? AppColors.yellowPrimary
                                : AppColors.purplePrimary,
                            borderColor: _currentModal == ModalType.signIn
                                ? AppColors.yellowLight
                                : AppColors.purpleLight,
                            layerColor: _currentModal == ModalType.signIn
                                ? AppColors.yellowDark
                                : AppColors.purpleDark,
                            layerTopPosition: -4,
                            borderRadius: 32,
                            title: _currentModal == ModalType.signIn
                                ? 'Sign In'
                                : 'Sign Up',
                            titleStyle: AppTextStyle.poppins(
                              fontSize: AppDimension.getFontSize(22).sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            onClose: _hideModal,
                            child: _buildModalContent(_currentModal!),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // Loading overlay
              if (_isLoading)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.yellowPrimary),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
