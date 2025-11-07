import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import 'bingo_game_event.dart';
import 'bingo_game_state.dart';

class BingoGameBloc extends Bloc<BingoGameEvent, BingoGameState> {
  final Random _random = Random();
  final List<String> _allPatterns = [
    'straightlineBingo',
    'fourCornersBingo',
    'tShapeBingo',
    'xPatternBingo',
    'blackoutBingo',
  ];

  // Flag to indicate if game was reset from game over
  bool _gameOverReset = false;

  // Getter for the game over reset flag
  bool get hasResetFromGameOver => _gameOverReset;

  // Method to reset the game over flag
  void resetGameOverFlag() {
    _gameOverReset = false;
  }

  BingoGameBloc()
      : super(BingoGameState.initial().copyWith(
            // Start with a random pattern instead of the default
            winningPattern: _getRandomPattern())) {
    on<CallBoardItem>(_onCallBoardItem);
    on<SelectBingoItem>(_onSelectBingoItem);
    on<CheckForWinningPattern>(_onCheckForWinningPattern);
    on<ResetGame>(_onResetGame);
    on<ClaimBingo>(_onClaimBingo);
  }

  // Static method to get a random pattern for initial state
  static String _getRandomPattern() {
    final patterns = [
      'straightlineBingo',
      'fourCornersBingo',
      'tShapeBingo',
      'xPatternBingo',
      'blackoutBingo',
    ];
    return patterns[Random().nextInt(patterns.length)];
  }

  // Shuffle to a new pattern different from the current one
  String _shuffleWinningPattern() {
    String newPattern;
    do {
      newPattern = _allPatterns[_random.nextInt(_allPatterns.length)];
    } while (newPattern == state.winningPattern && _allPatterns.length > 1);

    return newPattern;
  }

  void _onCallBoardItem(CallBoardItem event, Emitter<BingoGameState> emit) {
    final newCalledBoards = [...state.calledBoards];

    // Check if this board has already been called and exists in the current list
    final alreadyCalled =
        newCalledBoards.any((board) => board['name'] == event.name);

    if (alreadyCalled) {
      // If already in the list, don't add it again
      return;
    }

    // Add the new called board at the beginning of the list
    newCalledBoards.insert(0, {
      'name': event.name,
      'category': event.category,
    });

    // Keep only the last 8 called boards (increase from 3)
    if (newCalledBoards.length > 8) {
      newCalledBoards.removeLast();
    }

    emit(state.copyWith(calledBoards: newCalledBoards));
  }

  void _onSelectBingoItem(SelectBingoItem event, Emitter<BingoGameState> emit) {
    final selectedItems = [...state.selectedItems];

    // Toggle selection for this item
    if (selectedItems.contains(event.index)) {
      // Don't allow deselection of the center free space (index 12)
      if (event.index != 12) {
        selectedItems.remove(event.index);
      }
    } else {
      // Only allow selection if this item has been called or is the center free space
      final isCenterItem = event.index == 12; // Center item is at index 12
      final itemIsCalled =
          state.calledBoards.any((board) => board['name'] == event.text);

      if (itemIsCalled || isCenterItem) {
        selectedItems.add(event.index);
      }
    }

    emit(state.copyWith(selectedItems: selectedItems));

    // No longer automatically check for winning pattern after selection
    // Now user must press the bingo button
  }

  // New method to handle when user claims bingo by pressing the button
  void _onClaimBingo(ClaimBingo event, Emitter<BingoGameState> emit) {
    final selectedItems = state.selectedItems;
    bool hasWon = false;
    String winningPatternFound = '';

    // First, check the current winning pattern
    final patternType = state.winningPattern;

    switch (patternType) {
      case 'straightlineBingo':
        hasWon = _checkStraightLine(selectedItems);
        if (hasWon) winningPatternFound = 'straightlineBingo';
        break;
      case 'blackoutBingo':
        hasWon = _checkBlackout(selectedItems);
        if (hasWon) winningPatternFound = 'blackoutBingo';
        break;
      case 'fourCornersBingo':
        hasWon = _checkFourCorners(selectedItems);
        if (hasWon) winningPatternFound = 'fourCornersBingo';
        break;
      case 'tShapeBingo':
        hasWon = _checkTShape(selectedItems);
        if (hasWon) winningPatternFound = 'tShapeBingo';
        break;
      case 'xPatternBingo':
        hasWon = _checkXPattern(selectedItems);
        if (hasWon) winningPatternFound = 'xPatternBingo';
        break;
      default:
        break;
    }

    // Only update state if player has actually won
    if (hasWon) {
      emit(state.copyWith(
          hasWon: true,
          winningPattern: winningPatternFound.isNotEmpty
              ? winningPatternFound
              : state.winningPattern));
    } else {
      // Optionally, we could add an incorrect claim count here to penalize
      // players who press Bingo without having a valid pattern.
      // For now, we just don't update the state.
      print("Invalid bingo claim - no winning pattern found");
    }
  }

  void _onCheckForWinningPattern(
      CheckForWinningPattern event, Emitter<BingoGameState> emit) {
    // This is now only used for pattern changes, not for win checking
    if (event.patternType != state.winningPattern) {
      emit(state.copyWith(winningPattern: event.patternType));
    }
  }

  void _onResetGame(ResetGame event, Emitter<BingoGameState> emit) {
    // Shuffle to a new pattern between rounds, but only if not resetting due to game over
    final String newPattern;
    if (!event.isGameOver) {
      // If it's a normal round completion, get a new pattern
      newPattern = _shuffleWinningPattern();
    } else {
      // If resetting due to game over, keep the current pattern
      newPattern = state.winningPattern;
    }

    // Create a fresh initial state that will randomize the board
    final newState = BingoGameState.initial();

    // Reset game state with the appropriate winning pattern and shuffled board
    emit(newState.copyWith(winningPattern: newPattern));

    // Set the game over reset flag if this reset is from a game over
    if (event.isGameOver) {
      _gameOverReset = true;
    }
  }

  // Check if there is a straight line (horizontal, vertical, or diagonal)
  bool _checkStraightLine(List<int> selectedItems) {
    // Check horizontal rows
    for (int row = 0; row < 5; row++) {
      int count = 0;
      for (int col = 0; col < 5; col++) {
        int index = row * 5 + col;
        if (selectedItems.contains(index)) {
          count++;
        }
      }
      if (count == 5) return true;
    }

    // Check vertical columns
    for (int col = 0; col < 5; col++) {
      int count = 0;
      for (int row = 0; row < 5; row++) {
        int index = row * 5 + col;
        if (selectedItems.contains(index)) {
          count++;
        }
      }
      if (count == 5) return true;
    }

    // Check diagonal from top-left to bottom-right
    int count = 0;
    for (int i = 0; i < 5; i++) {
      int index = i * 5 + i;
      if (selectedItems.contains(index)) {
        count++;
      }
    }
    if (count == 5) return true;

    // Check diagonal from top-right to bottom-left
    count = 0;
    for (int i = 0; i < 5; i++) {
      int index = i * 5 + (4 - i);
      if (selectedItems.contains(index)) {
        count++;
      }
    }
    if (count == 5) return true;

    return false;
  }

  // Check if all corners are selected
  bool _checkFourCorners(List<int> selectedItems) {
    return selectedItems.contains(0) && // Top-left
        selectedItems.contains(4) && // Top-right
        selectedItems.contains(20) && // Bottom-left
        selectedItems.contains(24); // Bottom-right
  }

  // Check if all boxes are selected (blackout)
  bool _checkBlackout(List<int> selectedItems) {
    return selectedItems.length == 25;
  }

  // Check for T shape
  bool _checkTShape(List<int> selectedItems) {
    // Top row
    bool topRow = selectedItems.contains(0) &&
        selectedItems.contains(1) &&
        selectedItems.contains(2) &&
        selectedItems.contains(3) &&
        selectedItems.contains(4);

    // Middle column
    bool middleCol = selectedItems.contains(2) &&
        selectedItems.contains(7) &&
        selectedItems.contains(12) &&
        selectedItems.contains(17) &&
        selectedItems.contains(22);

    return topRow && middleCol;
  }

  // Check for X pattern
  bool _checkXPattern(List<int> selectedItems) {
    // Diagonal from top-left to bottom-right
    bool diag1 = selectedItems.contains(0) &&
        selectedItems.contains(6) &&
        selectedItems.contains(12) &&
        selectedItems.contains(18) &&
        selectedItems.contains(24);

    // Diagonal from top-right to bottom-left
    bool diag2 = selectedItems.contains(4) &&
        selectedItems.contains(8) &&
        selectedItems.contains(12) &&
        selectedItems.contains(16) &&
        selectedItems.contains(20);

    return diag1 && diag2;
  }
}
