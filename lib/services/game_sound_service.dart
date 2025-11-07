import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:hiphop_rnb_bingo/widgets/app_sounds.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

/// Service to manage all game sounds throughout the application
class GameSoundService {
  // Singleton instance
  static final GameSoundService _instance = GameSoundService._internal();
  factory GameSoundService() => _instance;
  GameSoundService._internal();

  // Audio player instances
  final AudioPlayer _effectsPlayer = AudioPlayer();
  final AudioPlayer _backgroundPlayer = AudioPlayer();

  // Sound state
  bool _isSoundEnabled = true;
  bool _isVibrateEnabled = true;
  bool _canVibrate = false;
  bool _hasAdvancedHaptics = false; // For iOS CoreHaptics

  // Getters for state
  bool get isSoundEnabled => _isSoundEnabled;
  bool get isVibrateEnabled => _isVibrateEnabled;

  // Initialize the service
  Future<void> initialize() async {
    // Set global options
    await _effectsPlayer.setReleaseMode(ReleaseMode.stop);
    await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
    await _backgroundPlayer.setVolume(0.5); // Lower volume for background music

    // Check if device can vibrate and has advanced haptics
    try {
      _canVibrate = await Haptics.canVibrate();

      // Check for iOS devices with CoreHaptics (iPhone 8 and newer)
      if (Platform.isIOS) {
        _hasAdvancedHaptics = await Haptics.canVibrate();
        if (kDebugMode) {
          print('iOS device supports haptic feedback: $_hasAdvancedHaptics');
        }
      }

      if (kDebugMode) {
        print('Device can vibrate: $_canVibrate');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking vibration capability: $e');
      }
      _canVibrate = false;
    }
  }

  // Toggle sound on/off
  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;

    if (!_isSoundEnabled) {
      _effectsPlayer.stop();
      _backgroundPlayer.stop();
    }
  }

  // Toggle vibration on/off
  void toggleVibrate() {
    _isVibrateEnabled = !_isVibrateEnabled;
  }

  // Check if vibration is available on the device
  Future<bool> checkVibrationAvailability() async {
    bool canVibrate = await Haptics.canVibrate();

    // Additional check for iOS devices
    if (Platform.isIOS && canVibrate) {
      if (kDebugMode) {
        print('iOS device supports vibration');
      }
    }

    return canVibrate;
  }

  // Perform vibration if enabled - optimized for iOS
  Future<void> vibrate() async {
    if (!_isVibrateEnabled) return;

    try {
      // Use different approaches depending on the platform
      if (Platform.isIOS) {
        // iOS specific haptic feedback
        if (_hasAdvancedHaptics) {
          // Use CoreHaptics-compatible feedback type
          await Haptics.vibrate(HapticsType.selection);
        } else {
          // Fallback for older iOS devices
          HapticFeedback.selectionClick();
        }

        if (kDebugMode) {
          print('iOS haptic feedback triggered');
        }
      } else {
        // Android vibration
        await Haptics.vibrate(HapticsType.light);
        if (kDebugMode) {
          print('Android light vibration triggered');
        }
      }
    } catch (e) {
      // Fallback to built-in haptic feedback if haptic_feedback fails
      try {
        // Use selection click which works well across platforms
        HapticFeedback.selectionClick();
        if (kDebugMode) {
          print('Fallback haptic feedback triggered');
        }
      } catch (e2) {
        if (kDebugMode) {
          print('Error during vibration: $e\nFallback error: $e2');
        }
      }
    }
  }

  // Perform medium vibration - optimized for iOS
  Future<void> vibrateMedium() async {
    if (!_isVibrateEnabled) return;

    try {
      // Use different approaches depending on the platform
      if (Platform.isIOS) {
        // iOS specific haptic feedback
        if (_hasAdvancedHaptics) {
          // Use CoreHaptics-compatible feedback type
          await Haptics.vibrate(HapticsType.warning);
        } else {
          // Fallback for older iOS devices
          HapticFeedback.mediumImpact();
        }

        if (kDebugMode) {
          print('iOS medium haptic feedback triggered');
        }
      } else {
        // Android vibration
        await Haptics.vibrate(HapticsType.medium);
        if (kDebugMode) {
          print('Android medium vibration triggered');
        }
      }
    } catch (e) {
      // Fallback to built-in haptic feedback if haptic_feedback fails
      try {
        HapticFeedback.mediumImpact();
        if (kDebugMode) {
          print('Fallback medium haptic feedback triggered');
        }
      } catch (e2) {
        if (kDebugMode) {
          print('Error during medium vibration: $e\nFallback error: $e2');
        }
      }
    }
  }

  // Perform heavy vibration - optimized for iOS
  Future<void> vibrateHeavy() async {
    if (!_isVibrateEnabled) return;

    try {
      // Use different approaches depending on the platform
      if (Platform.isIOS) {
        // iOS specific haptic feedback
        if (_hasAdvancedHaptics) {
          // Use CoreHaptics-compatible feedback type
          await Haptics.vibrate(HapticsType.error);
        } else {
          // Fallback for older iOS devices
          HapticFeedback.heavyImpact();
        }

        if (kDebugMode) {
          print('iOS heavy haptic feedback triggered');
        }
      } else {
        // Android vibration
        await Haptics.vibrate(HapticsType.heavy);
        if (kDebugMode) {
          print('Android heavy vibration triggered');
        }
      }
    } catch (e) {
      // Fallback to built-in haptic feedback if haptic_feedback fails
      try {
        HapticFeedback.heavyImpact();
        if (kDebugMode) {
          print('Fallback heavy haptic feedback triggered');
        }
      } catch (e2) {
        if (kDebugMode) {
          print('Error during heavy vibration: $e\nFallback error: $e2');
        }
      }
    }
  }

  // Play a sound effect
  Future<void> playSound(String soundPath) async {
    if (!_isSoundEnabled) return;

    try {
      await _effectsPlayer.stop(); // Stop previous sound
      await _effectsPlayer
          .play(AssetSource(soundPath.replaceFirst('assets/', '')));
    } catch (e) {
      if (kDebugMode) {
        print('Error playing sound: $e');
      }
    }
  }

  // Play background music
  Future<void> playBackgroundMusic(String soundPath) async {
    if (!_isSoundEnabled) return;

    try {
      await _backgroundPlayer.stop(); // Stop previous music
      await _backgroundPlayer
          .play(AssetSource(soundPath.replaceFirst('assets/', '')));
    } catch (e) {
      if (kDebugMode) {
        print('Error playing background music: $e');
      }
    }
  }

  // Perform iOS-specific haptic feedback
  Future<void> iosHapticFeedback(String type) async {
    if (!_isVibrateEnabled) return;

    try {
      switch (type) {
        case 'light':
          HapticFeedback.selectionClick();
          break;
        case 'medium':
          HapticFeedback.mediumImpact();
          break;
        case 'heavy':
          HapticFeedback.heavyImpact();
          break;
        case 'success':
          // Success pattern - use haptics success pattern
          await Haptics.vibrate(HapticsType.success);
          break;
        case 'error':
          // Error pattern - use haptics error pattern
          await Haptics.vibrate(HapticsType.error);
          break;
        case 'warning':
          // Warning pattern - use haptics warning pattern
          await Haptics.vibrate(HapticsType.warning);
          break;
        default:
          HapticFeedback.selectionClick();
      }

      if (kDebugMode) {
        print('iOS specific haptic feedback: $type');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error performing iOS haptic feedback: $e');
      }
    }
  }

  // Play button click sound with optimized haptics for iOS
  Future<void> playButtonClick() async {
    await playSound(AppSoundData.buttonClicks);

    // Use platform-specific vibration for best experience
    if (Platform.isIOS) {
      await iosHapticFeedback('light');
    } else {
      await vibrate();
    }
  }

  // Play alert popup sound
  Future<void> playAlertPopup() async {
    await playSound(AppSoundData.alertPopups);

    // Use platform-specific vibration for best experience
    if (Platform.isIOS) {
      await iosHapticFeedback('warning');
    } else {
      await vibrateMedium();
    }
  }

  // Play bingo board tap sound
  Future<void> playBoardTap() async {
    await playSound(AppSoundData.boardTap);

    // Use platform-specific vibration for best experience
    if (Platform.isIOS) {
      await iosHapticFeedback('light');
    } else {
      await vibrate();
    }
  }

  // Play correct bingo sound
  Future<void> playCorrectBingo() async {
    await playSound(AppSoundData.correctBingo);

    // Use platform-specific vibration for best experience
    if (Platform.isIOS) {
      await iosHapticFeedback('success');
    } else {
      await vibrateHeavy();
    }
  }

  // Play wrong bingo sound
  Future<void> playWrongBingo() async {
    await playSound(AppSoundData.wrongBingo);

    // Use platform-specific vibration for best experience
    if (Platform.isIOS) {
      await iosHapticFeedback('error');
    } else {
      await vibrateMedium();
    }
  }

  // Play new round sound
  Future<void> playNewRound() async {
    await playSound(AppSoundData.newRound);

    // Use platform-specific vibration for best experience
    if (Platform.isIOS) {
      await iosHapticFeedback('medium');
    } else {
      await vibrateMedium();
    }
  }

  // Play prize win sound
  Future<void> playPrizeWin() async {
    await playSound(AppSoundData.prizeWin);

    // Use platform-specific vibration for best experience
    if (Platform.isIOS) {
      await iosHapticFeedback('success');
    } else {
      await vibrateHeavy();
    }
  }

  // Clean up resources
  void dispose() {
    _effectsPlayer.dispose();
    _backgroundPlayer.dispose();
  }
}
