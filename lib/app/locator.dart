import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../data/services/api/api.dart';
import '../services/auth_service.dart';
import '../services/google_auth_service.dart';
import '../services/apple_auth_service.dart';
import '../services/facebook_auth_service.dart';
import '../services/game_service.dart';
import '../data/services/local_storage_service.dart';
import 'flavor_config.dart';

final locator = GetIt.instance;

Future<void> setupLocator(AppFlavorConfig config) async {
  await _registerExternalDependencies(config);
  _registerServices();
}

void _registerServices() {
  if (!locator.isRegistered<Api>()) {
    locator.registerLazySingleton<Api>(() => Api());
  }
  if (!locator.isRegistered<AuthService>()) {
    locator.registerLazySingleton<AuthService>(() => AuthService());
  }
  if (!locator.isRegistered<GoogleAuthService>()) {
    locator.registerLazySingleton<GoogleAuthService>(() => GoogleAuthService());
  }
  if (!locator.isRegistered<AppleAuthService>()) {
    locator.registerLazySingleton<AppleAuthService>(() => AppleAuthService());
  }
  if (!locator.isRegistered<FacebookAuthService>()) {
    locator.registerLazySingleton<FacebookAuthService>(
        () => FacebookAuthService());
  }
  if (!locator.isRegistered<LocalStorageService>()) {
    locator.registerLazySingleton<LocalStorageService>(
        () => LocalStorageService());
  }
  if (!locator.isRegistered<GameService>()) {
    locator.registerLazySingleton<GameService>(() => GameService());
  }
}

Future<void> _registerExternalDependencies(AppFlavorConfig config) async {
  locator.registerLazySingleton<AppFlavorConfig>(() => config);
  locator.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());
}
