// ignore_for_file: curly_braces_in_flow_control_structures, unnecessary_string_interpolations, prefer_const_constructors

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hiphop_rnb_bingo/widgets/app_colors.dart';
import 'package:hiphop_rnb_bingo/widgets/app_sizer.dart';
import 'package:hiphop_rnb_bingo/widgets/bingo_header_item.dart';
import 'package:hiphop_rnb_bingo/widgets/bingo_board_item.dart';
import 'package:hiphop_rnb_bingo/widgets/called_boards_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hiphop_rnb_bingo/blocs/bingo_game/bingo_game_bloc.dart';
import 'package:hiphop_rnb_bingo/blocs/bingo_game/bingo_game_state.dart';
import 'package:hiphop_rnb_bingo/widgets/app_text_style.dart';
import 'package:hiphop_rnb_bingo/widgets/app_images.dart';
import 'package:hiphop_rnb_bingo/services/game_sound_service.dart';

class BingoBoardBoxContainer extends StatefulWidget {
  const BingoBoardBoxContainer({super.key});

  @override
  State<BingoBoardBoxContainer> createState() => _BingoBoardBoxContainerState();
}

class _BingoBoardBoxContainerState extends State<BingoBoardBoxContainer>
    with SingleTickerProviderStateMixin {
  late List<Map<String, dynamic>> _shuffledItems;
  late AnimationController _winAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  final GameSoundService _soundService = GameSoundService();

  // Track animation state for each tile
  List<bool> _animationCompleted = List.generate(25, (_) => false);

  // Animation types for shuffling
  final List<String> _animationTypes = [
    'scale', // Original scale animation
    'flip', // 3D flip animation
    'slide', // Slide from different directions
    'fade', // Fade with rotation
    'bounce' // Bounce in animation
  ];
  String _currentAnimationType = 'scale';

  // For tracking board shuffle animation
  bool _isShuffling = false;
  List<Map<String, dynamic>> _previousItems = [];

  @override
  void initState() {
    super.initState();
    _shuffledItems = _generateShuffledBoardItems();

    // Choose a random animation type on init
    _selectRandomAnimation();

    // Start with shuffling animation on first load
    _isShuffling = true;
    _startShuffleAnimation();

    // Initialize animation controller for win animation
    _winAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_winAnimationController);

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _winAnimationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));
  }

  @override
  void dispose() {
    _winAnimationController.dispose();
    super.dispose();
  }

  // Select a random animation type
  void _selectRandomAnimation() {
    final random = Random();
    _currentAnimationType =
        _animationTypes[random.nextInt(_animationTypes.length)];
  }

  // Start shuffle animation for the board
  void _startShuffleAnimation() {
    setState(() {
      _isShuffling = true;
      _animationCompleted = List.generate(25, (_) => false);
    });

    // Play shuffle sound
    _soundService.playBoardTap();

    // Determine animation sequence based on the current type
    List<int> animationOrder;
    switch (_currentAnimationType) {
      case 'slide':
        // Animate from one side to another (left to right)
        animationOrder = List.generate(25, (i) => i ~/ 5 * 5 + (i % 5));
        break;
      case 'flip':
        // Animate from center outward
        animationOrder = _generateCenterOutwardOrder();
        break;
      case 'bounce':
        // Bounce in row by row
        animationOrder = List.generate(25, (i) => i);
        break;
      case 'fade':
        // Random order fade in
        animationOrder = List.generate(25, (i) => i)..shuffle();
        break;
      case 'scale':
      default:
        // Default spiral pattern
        animationOrder = _generateSpiralOrder();
        break;
    }

    // Stagger the animations for each tile based on the order
    for (int i = 0; i < animationOrder.length; i++) {
      Future.delayed(Duration(milliseconds: 50 + (i * 30)), () {
        if (mounted) {
          setState(() {
            _animationCompleted[animationOrder[i]] = true;
          });
        }
      });
    }

    // End the shuffle animation after all tiles are done
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isShuffling = false;
        });
      }
    });
  }

  // Generate a spiral order (outside to inside)
  List<int> _generateSpiralOrder() {
    List<int> result = [];
    List<List<int>> matrix =
        List.generate(5, (_) => List.generate(5, (_) => 0));

    int num = 0;
    int top = 0, bottom = 4;
    int left = 0, right = 4;

    while (top <= bottom && left <= right) {
      // Traverse right
      for (int i = left; i <= right; i++) {
        matrix[top][i] = num++;
      }
      top++;

      // Traverse down
      for (int i = top; i <= bottom; i++) {
        matrix[i][right] = num++;
      }
      right--;

      // Traverse left
      if (top <= bottom) {
        for (int i = right; i >= left; i--) {
          matrix[bottom][i] = num++;
        }
        bottom--;
      }

      // Traverse up
      if (left <= right) {
        for (int i = bottom; i >= top; i--) {
          matrix[i][left] = num++;
        }
        left++;
      }
    }

    // Convert 2D matrix order to 1D list indices
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 5; j++) {
        result.add(matrix[i][j]);
      }
    }

    return result;
  }

  // Generate center outward order
  List<int> _generateCenterOutwardOrder() {
    // Start with the center tile (index 12)
    List<int> result = [12];

    // Inner ring (directly adjacent to center)
    result.addAll([7, 11, 13, 17]);

    // Middle ring
    result.addAll([2, 6, 8, 16, 18, 22]);

    // Outer ring (corners and edges)
    result.addAll([0, 1, 3, 4, 5, 9, 10, 14, 15, 19, 20, 21, 23, 24]);

    return result;
  }

  // Regenerate the board with new shuffled items
  void _reshuffleBoard() {
    // Reset the win animation controller
    _winAnimationController.reset();

    // Save the previous items for animation
    _previousItems = List.from(_shuffledItems);

    // Generate new shuffled items
    final newItems = _generateShuffledBoardItems();

    // Select a new random animation type for this shuffle
    _selectRandomAnimation();

    setState(() {
      _shuffledItems = newItems;
    });

    // Start shuffle animation
    _startShuffleAnimation();
  }

  List<Widget> _buildBingoHeader() {
    return [
      const BingoHeaderItem(letter: 'B', color: AppColors.deepBlue1),
      const BingoHeaderItem(letter: 'I', color: AppColors.deepYellow),
      const BingoHeaderItem(letter: 'N', color: AppColors.deepPink),
      const BingoHeaderItem(letter: 'G', color: AppColors.deepGreen),
      const BingoHeaderItem(letter: 'O', color: AppColors.darkPurple1),
    ];
  }

  List<Map<String, dynamic>> _generateShuffledBoardItems() {
    // Define all items by category
    final bItems = [
      {
        'text': "Come and Talk to Me",
        'category': BingoCategory.B,
        'isCenter': false
      },
      {'text': "Real Love", 'category': BingoCategory.B, 'isCenter': false},
      {'text': "Fantasy", 'category': BingoCategory.B, 'isCenter': false},
      {
        'text': "Bad & Bougie / T Shirt",
        'category': BingoCategory.B,
        'isCenter': false
      },
      {'text': "Dazz Band", 'category': BingoCategory.B, 'isCenter': false},
    ];

    final iItems = [
      {
        'text': "Forever my Lady",
        'category': BingoCategory.I,
        'isCenter': false
      },
      {'text': "Sweet Thing", 'category': BingoCategory.I, 'isCenter': false},
      {'text': "Without You", 'category': BingoCategory.I, 'isCenter': false},
      {
        'text': "Walk it Talk it / Fight Night",
        'category': BingoCategory.I,
        'isCenter': false
      },
      {'text': "Comodores", 'category': BingoCategory.I, 'isCenter': false},
    ];

    final nItems = [
      {'text': "Feenin", 'category': BingoCategory.N, 'isCenter': false},
      {
        'text': "I can Love You",
        'category': BingoCategory.N,
        'isCenter': false
      },
      {'text': "", 'category': BingoCategory.N, 'isCenter': true},
      {'text': "Slippery", 'category': BingoCategory.N, 'isCenter': false},
      {
        'text': "Earth Wind and Fire",
        'category': BingoCategory.N,
        'isCenter': false
      },
    ];

    final gItems = [
      {'text': "Freek n You", 'category': BingoCategory.G, 'isCenter': false},
      {
        'text': "I'm going down",
        'category': BingoCategory.G,
        'isCenter': false
      },
      {
        'text': "Always Be My Baby",
        'category': BingoCategory.G,
        'isCenter': false
      },
      {'text': "Straightening", 'category': BingoCategory.G, 'isCenter': false},
      {
        'text': "Montel Jordan - This is How We..",
        'category': BingoCategory.G,
        'isCenter': false
      },
    ];

    final oItems = [
      {'text': "Cry for you", 'category': BingoCategory.O, 'isCenter': false},
      {'text': "Not Gon Cry", 'category': BingoCategory.O, 'isCenter': false},
      {
        'text': "We Belong Together",
        'category': BingoCategory.O,
        'isCenter': false
      },
      {
        'text': "Handsome & Wealthy",
        'category': BingoCategory.O,
        'isCenter': false
      },
      {
        'text': "Parliament-Funkadelic",
        'category': BingoCategory.O,
        'isCenter': false
      },
    ];

    // Shuffle each category separately
    _shuffleList(bItems);
    _shuffleList(iItems);
    // We need to keep the center item fixed
    final nonCenterNItems = [nItems[0], nItems[1], nItems[3], nItems[4]];
    _shuffleList(nonCenterNItems);
    _shuffleList(gItems);
    _shuffleList(oItems);

    // Create a list of all items
    final allItems = <Map<String, dynamic>>[];

    // First part of the board (before the center)
    for (int i = 0; i < 12; i++) {
      Map<String, dynamic> item;
      if (i % 5 == 0)
        item = bItems[i ~/ 5];
      else if (i % 5 == 1)
        item = iItems[i ~/ 5];
      else if (i % 5 == 2)
        item =
            i ~/ 5 < 2 ? nonCenterNItems[i ~/ 5] : nonCenterNItems[i ~/ 5 - 1];
      else if (i % 5 == 3)
        item = gItems[i ~/ 5];
      else
        item = oItems[i ~/ 5];

      allItems.add(item);
    }

    // Add center item
    allItems.add(nItems[2]); // Center is always fixed with the star

    // Last part of the board (after the center)
    for (int i = 13; i < 25; i++) {
      Map<String, dynamic> item;
      if (i % 5 == 0)
        item = bItems[i ~/ 5];
      else if (i % 5 == 1)
        item = iItems[i ~/ 5];
      else if (i % 5 == 2)
        item = i ~/ 5 < 3
            ? nonCenterNItems[i ~/ 5 - 1]
            : nonCenterNItems[i ~/ 5 - 2];
      else if (i % 5 == 3)
        item = gItems[i ~/ 5];
      else
        item = oItems[i ~/ 5];

      allItems.add(item);
    }

    // Shuffle the entire board while keeping the center fixed
    final centerItem = allItems[12];
    final itemsWithoutCenter = [...allItems];
    itemsWithoutCenter.removeAt(12);
    _shuffleList(itemsWithoutCenter);

    // Reinsert the center item
    final result = [...itemsWithoutCenter];
    result.insert(12, centerItem);

    return result;
  }

  void _shuffleList(List list) {
    final random = Random();
    for (int i = list.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
  }

  // Build a board item with shuffle animation
  Widget _buildBoardItemWithAnimation(int index, BingoGameState state) {
    final item = _shuffledItems[index];
    final isSelected = state.isItemSelected(index);

    // Apply shuffle animation
    if (_isShuffling) {
      switch (_currentAnimationType) {
        case 'flip':
          return AnimatedOpacity(
            opacity: _animationCompleted[index] ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeIn,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0.0,
                end: _animationCompleted[index] ? 1.0 : 0.0,
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(pi * (1 - value)),
                  alignment: Alignment.center,
                  child: child,
                );
              },
              child: BingoBoardItem(
                text: item['text'] as String,
                category: item['category'] as BingoCategory,
                isCenter: item['isCenter'] as bool,
                index: index,
              ),
            ),
          );

        case 'slide':
          final random = Random(index);
          final xOffset = random.nextBool() ? -200.0 : 200.0;

          return AnimatedOpacity(
            opacity: _animationCompleted[index] ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
            child: TweenAnimationBuilder<Offset>(
              tween: Tween<Offset>(
                begin: Offset(xOffset, 0),
                end: _animationCompleted[index]
                    ? Offset.zero
                    : Offset(xOffset, 0),
              ),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, offset, child) {
                return Transform.translate(
                  offset: offset,
                  child: child,
                );
              },
              child: BingoBoardItem(
                text: item['text'] as String,
                category: item['category'] as BingoCategory,
                isCenter: item['isCenter'] as bool,
                index: index,
              ),
            ),
          );

        case 'fade':
          return AnimatedOpacity(
            opacity: _animationCompleted[index] ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: -0.5,
                end: _animationCompleted[index] ? 0.0 : -0.5,
              ),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * pi,
                  child: child,
                );
              },
              child: BingoBoardItem(
                text: item['text'] as String,
                category: item['category'] as BingoCategory,
                isCenter: item['isCenter'] as bool,
                index: index,
              ),
            ),
          );

        case 'bounce':
          return AnimatedOpacity(
            opacity: _animationCompleted[index] ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeIn,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: -50.0,
                end: _animationCompleted[index] ? 0.0 : -50.0,
              ),
              duration: const Duration(milliseconds: 800),
              curve: Curves.bounceOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: child,
                );
              },
              child: BingoBoardItem(
                text: item['text'] as String,
                category: item['category'] as BingoCategory,
                isCenter: item['isCenter'] as bool,
                index: index,
              ),
            ),
          );

        case 'scale':
        default:
          return AnimatedOpacity(
            opacity: _animationCompleted[index] ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
            child: AnimatedScale(
              scale: _animationCompleted[index] ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.elasticOut,
              child: BingoBoardItem(
                text: item['text'] as String,
                category: item['category'] as BingoCategory,
                isCenter: item['isCenter'] as bool,
                index: index,
              ),
            ),
          );
      }
    }

    // Normal display without shuffle animation
    return BingoBoardItem(
      text: item['text'] as String,
      category: item['category'] as BingoCategory,
      isCenter: item['isCenter'] as bool,
      index: index,
    );
  }

  // Play win sounds based on pattern
  void _playWinSound(String patternType) {
    // Play correct bingo sound for the win
    _soundService.playCorrectBingo();

    // Depending on the pattern, play an additional sound for more feedback
    switch (patternType) {
      case 'blackoutBingo':
        // For blackout bingo, play prize win sound for bigger achievement
        Future.delayed(const Duration(milliseconds: 500), () {
          _soundService.playPrizeWin();
        });
        break;
      default:
        // Normal win just uses correct bingo sound
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BingoGameBloc, BingoGameState>(
      buildWhen: (previous, current) =>
          previous.hasWon != current.hasWon ||
          previous.calledBoards != current.calledBoards ||
          previous.winningPattern != current.winningPattern,
      listenWhen: (previous, current) =>
          // Listen for reset conditions
          (previous.calledBoards.isNotEmpty && current.calledBoards.isEmpty) ||
          (previous.hasWon == true && current.hasWon == false) ||
          // Listen for win condition
          (previous.hasWon == false && current.hasWon == true),
      listener: (context, state) {
        if (state.calledBoards.isEmpty || !state.hasWon) {
          // Game has been reset
          _reshuffleBoard();
        } else if (state.hasWon) {
          // Game has been won - play winning sound
          _playWinSound(state.winningPattern);

          // Start the win animation
          _winAnimationController.forward();
        }
      },
      builder: (context, state) {
        // Start animation if player has won
        if (state.hasWon &&
            !_winAnimationController.isAnimating &&
            _winAnimationController.status != AnimationStatus.completed) {
          _winAnimationController.forward();
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Layer behind the main container
            Positioned(
              left: 0,
              right: 0,
              top: 4.h,
              child: Container(
                height: AppDimension.isSmall ? 440.h : 390.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
            ),
            // Main container
            Container(
              width: double.infinity,
              height: AppDimension.isSmall ? 440.h : 390.h,
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                  width: 2.w,
                ),
              ),
              child: Column(
                children: [
                  // BINGO Header Row
                  SizedBox(
                    height: 40.h,
                    child: Row(
                      children: _buildBingoHeader()
                          .map((item) => Expanded(
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 4.w),
                                  child: item,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Bingo Board Grid
                  Expanded(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 8.h,
                        crossAxisSpacing: 8.w,
                      ),
                      itemCount: 25,
                      itemBuilder: (context, index) {
                        return _buildBoardItemWithAnimation(index, state);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Win overlay
            if (state.hasWon)
              AnimatedBuilder(
                animation: _winAnimationController,
                builder: (context, child) {
                  return Positioned.fill(
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(
                              color: _getPatternColor(state.winningPattern),
                              width: 3.w,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Background particles effect
                              ...List.generate(20, (index) {
                                final random = Random();
                                final size = random.nextDouble() * 20 + 5;
                                return Positioned(
                                  left: random.nextDouble() * 300,
                                  top: random.nextDouble() * 300,
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0, end: 1),
                                    duration: Duration(
                                        milliseconds:
                                            800 + random.nextInt(1200)),
                                    builder: (context, value, child) {
                                      return Transform.translate(
                                        offset: Offset(
                                          sin(value * 3) * 30,
                                          value * -50,
                                        ),
                                        child: Opacity(
                                          opacity: 1 - value,
                                          child: Container(
                                            width: size,
                                            height: size,
                                            decoration: BoxDecoration(
                                              color: _getPatternColor(
                                                      state.winningPattern)
                                                  .withOpacity(0.6),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }),

                              // Main content
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'BINGO!',
                                      style: AppTextStyle.mochiyPopOne(
                                        fontSize: 32.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 24.h),
                                    AppImages(
                                      imagePath: _getPatternImage(
                                          state.winningPattern),
                                      width: 120.w,
                                      height: 120.h,
                                    ),
                                    SizedBox(height: 24.h),
                                    Text(
                                      'You won with a ${_getPatternName(state.winningPattern)}!',
                                      style: AppTextStyle.mochiyPopOne(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  String _getPatternName(String patternType) {
    switch (patternType) {
      case 'straightlineBingo':
        return 'Straight Line';
      case 'blackoutBingo':
        return 'Blackout';
      case 'fourCornersBingo':
        return 'Four Corners';
      case 'tShapeBingo':
        return 'T-Shape';
      case 'xPatternBingo':
        return 'X-Pattern';
      default:
        return 'Pattern';
    }
  }

  Color _getPatternColor(String patternType) {
    switch (patternType) {
      case 'straightlineBingo':
        return AppColors.greenBright;
      case 'blackoutBingo':
        return AppColors.purplePrimary;
      case 'fourCornersBingo':
        return AppColors.deepYellow;
      case 'tShapeBingo':
        return AppColors.deepPink;
      case 'xPatternBingo':
        return AppColors.bluePrimary;
      default:
        return Colors.white;
    }
  }

  String _getPatternImage(String patternType) {
    switch (patternType) {
      case 'straightlineBingo':
        return AppImageData.straightlineBingo;
      case 'blackoutBingo':
        return AppImageData.blackoutBingo;
      case 'fourCornersBingo':
        return AppImageData.fourCornersBingo;
      case 'tShapeBingo':
        return AppImageData.tShapeBingo;
      case 'xPatternBingo':
        return AppImageData.xPatternBingo;
      default:
        return AppImageData.straightlineBingo;
    }
  }
}
