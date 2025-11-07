import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../app/locator.dart';
import '../services/game_service.dart';
import '../widgets/app_colors.dart';
import '../widgets/app_icons.dart';
import '../widgets/app_images.dart';
import '../widgets/app_text_style.dart';
import '../routes/app_routes.dart';
import '../widgets/app_toast.dart';
import 'package:google_ml_kit/google_ml_kit.dart' as ml_kit;

class QRCodeScannerScreen extends StatefulWidget {
  final bool isInPerson;

  const QRCodeScannerScreen({
    super.key,
    required this.isInPerson,
  });

  @override
  State<QRCodeScannerScreen> createState() => _QRCodeScannerScreenState();
}

class _QRCodeScannerScreenState extends State<QRCodeScannerScreen>
    with WidgetsBindingObserver {
  bool _isTorchOn = false;
  bool _isProcessing = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late MobileScannerController cameraController;
  final ImagePicker _imagePicker = ImagePicker();
  final ml_kit.BarcodeScanner _barcodeScanner =
      ml_kit.GoogleMlKit.vision.barcodeScanner();
  final GameService _gameService = locator<GameService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCameraController();
  }

  void _initializeCameraController() {
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: _isTorchOn,
    );
  }

  void _resetScanner() {
    if (_isProcessing) {
      setState(() {
        _isProcessing = false;
      });

      // Dispose and reinitialize camera controller to ensure scanner works again
      cameraController.dispose();
      _initializeCameraController();
      cameraController.start();
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    _barcodeScanner.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      cameraController.start();
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.stop();
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Theme.of(context).platform == TargetPlatform.android) {
      cameraController.stop();
    }
    Future.delayed(const Duration(milliseconds: 100), () {
      cameraController.start();
    });
  }

  Future<void> _handleScannedCode(String? code) async {
    if (code != null && !_isProcessing) {
      debugPrint('QR Code found: $code');

      // Set processing state to prevent multiple scans
      setState(() {
        _isProcessing = true;
      });

      // Show loading toast
      AppToast.show(
        context,
        'QR Code detected! Processing game information...',
        showCloseIcon: false,
      );

      try {
        // Validate the game code by fetching game details
        final game = await _gameService.getGameByCode(code);

        if (!mounted) return;

        if (game != null) {
          // Check if game mode matches the scanner mode (in-person or remote)
          if ((widget.isInPerson && !game.isRemote) ||
              (!widget.isInPerson && game.isRemote)) {
            // Navigate to appropriate screen based on mode
            if (widget.isInPerson) {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.gameDetails,
                arguments: code,
              );
            } else {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.remoteGameDetails,
                arguments: code,
              );
            }
          } else {
            // Wrong game mode - show error and reset processing
            _showErrorToast(widget.isInPerson
                ? 'This is an online game! Please scan from the online section.'
                : 'This is an in-person game! Please scan from the in-person section.');

            // Reset the scanner after a short delay to allow the toast to be visible
            Future.delayed(const Duration(milliseconds: 1500), _resetScanner);
          }
        } else {
          // Game not found - show error and reset processing
          _showErrorToast(
              'Game not found! Please try again with a valid QR code.');

          // Reset the scanner after a short delay to allow the toast to be visible
          Future.delayed(const Duration(milliseconds: 1500), _resetScanner);
        }
      } catch (e) {
        debugPrint('Error validating game code: $e');
        if (!mounted) return;

        _showErrorToast('Error processing QR code. Please try again.');

        // Reset the scanner after a short delay to allow the toast to be visible
        Future.delayed(const Duration(milliseconds: 1500), _resetScanner);
      }
    }
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
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _pickImage() async {
    if (_isProcessing) return;

    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final inputImage = ml_kit.InputImage.fromFilePath(image.path);
        final List<ml_kit.Barcode> barcodes =
            await _barcodeScanner.processImage(inputImage);

        if (barcodes.isNotEmpty) {
          for (final barcode in barcodes) {
            if (!mounted) return;
            _handleScannedCode(barcode.rawValue);
            return;
          }
        } else {
          if (!mounted) return;
          _showErrorToast('No QR code found in the selected image.');
          _resetScanner();
        }
      }
    } catch (e) {
      debugPrint('Error scanning image: $e');
      if (!mounted) return;
      _showErrorToast('Error scanning image. Please try again.');
      _resetScanner();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        cameraController.stop();
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // QR Scanner with overlay
              _isProcessing
                  ? SizedBox.expand(
                      child: Container(
                        color: Colors.black,
                        child: const Center(
                          child: SpinKitCubeGrid(
                            color: AppColors.yellowPrimary,
                            size: 50,
                          ),
                        ),
                      ),
                    )
                  : MobileScanner(
                      controller: cameraController,
                      onDetect: (capture) {
                        if (_isProcessing) return;
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          if (!mounted) return;
                          _handleScannedCode(barcode.rawValue);
                          return;
                        }
                      },
                      scanWindow: Rect.fromCenter(
                        center: Offset(
                          MediaQuery.of(context).size.width / 2,
                          MediaQuery.of(context).size.height / 2,
                        ),
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.width * 0.8,
                      ),
                    ),

              // Top Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const AppImages(
                            imagePath: AppImageData.back,
                            height: 38,
                            width: 38,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'QR Code Scan',
                            textAlign: TextAlign.center,
                            style: AppTextStyle.mochiyPopOne(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ],
                ),
              ),

              // Scan area overlay
              if (!_isProcessing)
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.yellowPrimary.withOpacity(0.5),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CustomPaint(
                      painter: ScannerOverlayPainter(
                        color: AppColors.yellowPrimary,
                      ),
                    ),
                  ),
                ),

              // Bottom Controls
              if (!_isProcessing)
                Positioned(
                  bottom: 48,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 44, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: AppIcons(
                                icon: AppIconData.image,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 46),
                          Container(
                            height: 32,
                            width: 2,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 46),
                          GestureDetector(
                            onTap: () async {
                              try {
                                await cameraController.toggleTorch();
                                setState(() => _isTorchOn = !_isTorchOn);
                              } catch (e) {
                                debugPrint('Error toggling torch: $e');
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Icon(
                                _isTorchOn ? Icons.flash_on : Icons.flash_off,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
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

class ScannerOverlayPainter extends CustomPainter {
  final Color color;

  ScannerOverlayPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    const double cornerLength = 30;
    const double radius = 20;

    // Top left corner
    canvas.drawPath(
      Path()
        ..moveTo(cornerLength, 0)
        ..lineTo(radius, 0)
        ..quadraticBezierTo(0, 0, 0, radius)
        ..lineTo(0, cornerLength),
      paint,
    );

    // Top right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLength, 0)
        ..lineTo(size.width - radius, 0)
        ..quadraticBezierTo(size.width, 0, size.width, radius)
        ..lineTo(size.width, cornerLength),
      paint,
    );

    // Bottom left corner
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - cornerLength)
        ..lineTo(0, size.height - radius)
        ..quadraticBezierTo(0, size.height, radius, size.height)
        ..lineTo(cornerLength, size.height),
      paint,
    );

    // Bottom right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height - cornerLength)
        ..lineTo(size.width, size.height - radius)
        ..quadraticBezierTo(
            size.width, size.height, size.width - radius, size.height)
        ..lineTo(size.width - cornerLength, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
