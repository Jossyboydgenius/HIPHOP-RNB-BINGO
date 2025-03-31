import 'package:flutter_bloc/flutter_bloc.dart';
import 'bingo_game_event.dart';
import 'bingo_game_state.dart';

class BingoGameBloc extends Bloc<BingoGameEvent, BingoGameState> {
  BingoGameBloc() : super(BingoGameState.initial()) {
    on<CallBoardItem>(_onCallBoardItem);
    on<SelectBingoItem>(_onSelectBingoItem);
    on<CheckForWinningPattern>(_onCheckForWinningPattern);
    on<ResetGame>(_onResetGame);
  }

  void _onCallBoardItem(CallBoardItem event, Emitter<BingoGameState> emit) {
    final newCalledBoards = [...state.calledBoards];
    
    // Add the new called board at the beginning of the list
    newCalledBoards.insert(0, {
      'name': event.name,
      'category': event.category,
    });
    
    // Keep only the last 3 called boards
    if (newCalledBoards.length > 3) {
      newCalledBoards.removeLast();
    }
    
    emit(state.copyWith(calledBoards: newCalledBoards));
  }

  void _onSelectBingoItem(SelectBingoItem event, Emitter<BingoGameState> emit) {
    final selectedItems = [...state.selectedItems];
    
    // Toggle selection for this item
    if (selectedItems.contains(event.index)) {
      selectedItems.remove(event.index);
    } else {
      // Only allow selection if this item has been called or is the center free space
      final isCenterItem = event.index == 12; // Center item is at index 12
      final itemIsCalled = state.calledBoards.any((board) => board['name'] == event.text);
      
      if (itemIsCalled || isCenterItem) {
        selectedItems.add(event.index);
      }
    }
    
    emit(state.copyWith(selectedItems: selectedItems));
    
    // Check for winning pattern after selection
    add(CheckForWinningPattern(patternType: state.winningPattern));
  }

  void _onCheckForWinningPattern(CheckForWinningPattern event, Emitter<BingoGameState> emit) {
    final selectedItems = state.selectedItems;
    bool hasWon = false;
    String winningPatternFound = '';
    
    // First check the current winning pattern
    switch (event.patternType) {
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
        // Check all patterns if no specific pattern is specified
        if (_checkStraightLine(selectedItems)) {
          hasWon = true;
          winningPatternFound = 'straightlineBingo';
        } else if (_checkFourCorners(selectedItems)) {
          hasWon = true;
          winningPatternFound = 'fourCornersBingo';
        } else if (_checkTShape(selectedItems)) {
          hasWon = true;
          winningPatternFound = 'tShapeBingo';
        } else if (_checkXPattern(selectedItems)) {
          hasWon = true;
          winningPatternFound = 'xPatternBingo';
        } else if (_checkBlackout(selectedItems)) {
          hasWon = true;
          winningPatternFound = 'blackoutBingo';
        }
        break;
    }
    
    if (hasWon) {
      emit(state.copyWith(
        hasWon: true,
        winningPattern: winningPatternFound.isNotEmpty ? winningPatternFound : state.winningPattern
      ));
    }
  }

  void _onResetGame(ResetGame event, Emitter<BingoGameState> emit) {
    emit(BingoGameState.initial());
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