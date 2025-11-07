import 'package:flutter/foundation.dart';
import '../data/services/api/api.dart';
import '../models/game_model.dart';
import '../app/locator.dart';

class GameService {
  final Api _api = locator<Api>();

  /// Fetches game details by code from the API
  /// Returns a GameModel object if successful, null otherwise
  Future<GameModel?> getGameByCode(String code) async {
    try {
      debugPrint('Fetching game with code: $code');
      final response =
          await _api.getData('/api/game/$code/code', hasHeader: true);

      if (response.isSuccessful && response.data != null) {
        debugPrint('Game fetched successfully');
        final gameData = response.data['data'];
        return GameModel.fromJson(gameData);
      } else {
        debugPrint('Failed to fetch game: ${response.message}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching game: $e');
      return null;
    }
  }
}
