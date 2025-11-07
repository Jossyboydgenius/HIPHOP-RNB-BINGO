class GameModel {
  final GameSettings settings;
  final String id;
  final String code;
  final String gameType;
  final String? thumbnail;
  final String title;
  final String description;
  final String name;
  final int maxPlayers;
  final List<String> musicCategories;
  final String categoryType;
  final String mode;
  final String hostName;
  final String djName;
  final String? gameLocation;
  final List<String> winningPattern;
  final int numberOfRounds;
  final List<PrizeModel> prizes;
  final String status;
  final String createdBy;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final String? startTime;
  final String? endTime;
  final String? winner;
  final List<WinnerModel>? winners;

  GameModel({
    required this.settings,
    required this.id,
    required this.code,
    required this.gameType,
    this.thumbnail,
    required this.title,
    required this.description,
    required this.name,
    required this.maxPlayers,
    required this.musicCategories,
    required this.categoryType,
    required this.mode,
    required this.hostName,
    required this.djName,
    this.gameLocation,
    required this.winningPattern,
    required this.numberOfRounds,
    required this.prizes,
    required this.status,
    required this.createdBy,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.startTime,
    this.endTime,
    this.winner,
    this.winners,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      settings: GameSettings.fromJson(json['settings']),
      id: json['_id'],
      code: json['code'],
      gameType: json['gameType'],
      thumbnail: json['thumbnail'],
      title: json['title'],
      description: json['description'],
      name: json['name'],
      maxPlayers: json['maxPlayers'],
      musicCategories: List<String>.from(json['musicCategories']),
      categoryType: json['categoryType'],
      mode: json['mode'],
      hostName: json['hostName'],
      djName: json['djName'],
      gameLocation: json['gameLocation'],
      winningPattern: List<String>.from(json['winningPattern']),
      numberOfRounds: json['numberOfRounds'],
      prizes: (json['prizes'] as List)
          .map((prize) => PrizeModel.fromJson(prize))
          .toList(),
      status: json['status'],
      createdBy: json['createdBy'],
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      winner: json['winner'],
      winners: json['winners'] != null
          ? (json['winners'] as List)
              .map((winner) => WinnerModel.fromJson(winner))
              .toList()
          : null,
    );
  }

  bool get isRemote => mode.toLowerCase() == 'online';
  bool get isInPerson => mode.toLowerCase() == 'offline';
  bool get isFree => gameType.toLowerCase() == 'free';
  bool get isPaid => gameType.toLowerCase() == 'paid';
}

class GameSettings {
  final bool fireRounds;
  final bool chatRoom;
  final bool notifyUsers;

  GameSettings({
    required this.fireRounds,
    required this.chatRoom,
    required this.notifyUsers,
  });

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      fireRounds: json['fireRounds'],
      chatRoom: json['chatRoom'],
      notifyUsers: json['notifyUsers'],
    );
  }
}

class PrizeModel {
  final List<String> winningPattern;
  final int roundNumber;
  final int amount;
  final String currency;
  final String description;
  final String id;

  PrizeModel({
    required this.winningPattern,
    required this.roundNumber,
    required this.amount,
    required this.currency,
    required this.description,
    required this.id,
  });

  factory PrizeModel.fromJson(Map<String, dynamic> json) {
    return PrizeModel(
      winningPattern: json['winningPattern'] != null
          ? List<String>.from(json['winningPattern'])
          : [],
      roundNumber: json['roundNumber'],
      amount: json['amount'],
      currency: json['currency'],
      description: json['description'],
      id: json['_id'],
    );
  }
}

class WinnerModel {
  final int round;
  final String playerId;
  final int prize;
  final String id;

  WinnerModel({
    required this.round,
    required this.playerId,
    required this.prize,
    required this.id,
  });

  factory WinnerModel.fromJson(Map<String, dynamic> json) {
    return WinnerModel(
      round: json['round'],
      playerId: json['playerId'],
      prize: json['prize'],
      id: json['_id'],
    );
  }
}
