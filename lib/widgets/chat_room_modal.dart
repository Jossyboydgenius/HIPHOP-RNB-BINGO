import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hiphop_rnb_bingo/widgets/app_sizer.dart';
import 'app_modal_container.dart';
import 'app_colors.dart';
import 'app_icons.dart';
import 'app_text_style.dart';
import 'app_banner.dart';
import 'chat_message_card.dart';
import 'app_button.dart';

class ChatRoomModal extends StatefulWidget {
  final VoidCallback onClose;
  final String userInitials;
  final int activeUsers;
  final bool isConnected;

  const ChatRoomModal({
    super.key,
    required this.onClose,
    required this.userInitials,
    required this.activeUsers,
    this.isConnected = true,
  });

  @override
  State<ChatRoomModal> createState() => _ChatRoomModalState();
}

class _ChatRoomModalState extends State<ChatRoomModal> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final int maxLength = 250;

  // Add this list to store chat messages
  final List<Map<String, dynamic>> messages = [
    {
      'message': 'Lorem ipsum dolor sit amet, Lorem ipsum dolor sit',
      'senderName': 'John Doe',
      'senderInitials': 'JD',
      'time': '08:00',
      'isMe': false,
    },
    {
      'message':
          'Lorem ipsum dolor sit amet, Lorem ipsum dolor sit amet, Lorem ipsum dolor sit',
      'senderName': 'John Doe',
      'senderInitials': 'JD',
      'time': '00:05',
      'isMe': false,
    },
    {
      'message':
          'Lorem ipsum dolor sit amet, Lorem ipsum dolor sit, Lorem ipsum dolor sit amet, Lorem ipsum dolor sit',
      'senderName': 'Me',
      'senderInitials': 'JD', // Use widget.userInitials here
      'time': 'Just Now',
      'isMe': true,
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 14.w,
              height: 14.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isConnected ? AppColors.greenBright : Colors.red,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              widget.isConnected ? 'Connected' : 'Disabled',
              style: AppTextStyle.dmSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            AppIcons(
              icon: AppIconData.people,
              size: 16.w,
            ),
            SizedBox(width: 4.w),
            Text(
              widget.activeUsers.toString(),
              style: AppTextStyle.dmSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChatInput() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: AppDimension.isSmall ? 72.h : 62.h,
            padding: EdgeInsets.symmetric(
                horizontal: AppDimension.isSmall ? 16.w : 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(AppDimension.isSmall ? 20.r : 16.r),
            ),
            child: Material(
              color: Colors.transparent,
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextField(
                    controller: _messageController,
                    maxLength: maxLength,
                    style: AppTextStyle.dmSans(
                      fontSize: AppDimension.isSmall ? 14.sp : 14.sp,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type Here',
                      hintStyle: AppTextStyle.dmSans(
                        fontSize: AppDimension.isSmall ? 14.sp : 14.sp,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.only(
                          right: AppDimension.isSmall ? 4.w : 2.w),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  Positioned(
                    right: 0,
                    bottom: AppDimension.isSmall ? 6.h : 4.h,
                    child: Text(
                      '${_messageController.text.length}/$maxLength',
                      style: AppTextStyle.dmSans(
                        fontSize: AppDimension.isSmall ? 12.sp : 10.sp,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: AppDimension.isSmall ? 12.w : 8.w),
        SizedBox(
          width: AppDimension.isSmall ? 62.w : 62.w,
          height: AppDimension.isSmall ? 72.h : 62.h,
          child: AppButton(
            text: '',
            onPressed:
                _messageController.text.isEmpty ? null : _handleSendMessage,
            fillColor: _messageController.text.isEmpty
                ? AppColors.grayDark
                : AppColors.greenDark,
            layerColor: _messageController.text.isEmpty
                ? AppColors.grayLight
                : AppColors.greenBright,
            borderColor: Colors.white,
            hasBorder: true,
            borderWidth: AppDimension.isSmall ? 3.w : 2.w,
            height: AppDimension.isSmall ? 72.h : 62.h,
            layerHeight: AppDimension.isSmall ? 68.h : 46.h,
            layerTopPosition: -3.h,
            borderRadius: AppDimension.isSmall ? 22.r : 16.r,
            iconPath: AppIconData.send,
            iconSize: AppDimension.isSmall ? 24.w : 22.w,
            disabled: _messageController.text.isEmpty,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppModalContainer(
      width: double.infinity,
      height: AppDimension.isSmall ? 900.h : 550.h,
      fillColor: AppColors.purplePrimary,
      borderColor: AppColors.purpleLight,
      layerColor: AppColors.purpleDark,
      layerTopPosition: -4.h,
      borderRadius: AppDimension.isSmall ? 32.r : 24.r,
      maintainFocus: true,
      onClose: widget.onClose,
      banner: AppBanner(
        text: 'Chat Room',
        fillColor: AppColors.yellowLight,
        borderColor: AppColors.yellowDark,
        textStyle: AppTextStyle.mochiyPopOne(
          fontSize: AppDimension.isSmall ? 20.sp : 18.sp,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        width: AppDimension.isSmall ? 200.w : 180.w,
        height: AppDimension.isSmall ? 45.h : 35.h,
        hasShadow: true,
        shadowColor: Colors.black,
        shadowBlurRadius: 15,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppDimension.isSmall ? 14.w : 16.w),
            child: _buildHeader(),
          ),
          SizedBox(height: AppDimension.isSmall ? 14.h : 16.h),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: AppDimension.isSmall ? 14.w : 16.w),
              padding: EdgeInsets.all(AppDimension.isSmall ? 14.r : 16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AppDimension.isSmall ? 20.r : 16.r),
              ),
              child: Column(
                children: [
                  Text(
                    'Click profile to report or mute a Player',
                    style: AppTextStyle.dmSans(
                      fontSize: AppDimension.isSmall ? 10.sp : 10.sp,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: AppDimension.isSmall ? 14.h : 16.h),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: messages.map((message) {
                          return ChatMessageCard(
                            message: message['message'],
                            senderName: message['senderName'],
                            senderInitials: message['senderInitials'],
                            time: message['time'],
                            isMe: message['isMe'],
                            onProfileTap: message['isMe']
                                ? null
                                : () {
                                    // Handle profile tap for reporting/muting
                                  },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: AppDimension.isSmall ? 14.w : 16.w,
              right: AppDimension.isSmall ? 14.w : 16.w,
              top: AppDimension.isSmall ? 14.h : 16.h,
              bottom: MediaQuery.of(context).viewInsets.bottom +
                  (AppDimension.isSmall ? 16.h : 10.h),
            ),
            child: _buildChatInput(),
          ),
        ],
      ),
    );
  }

  // Add this method to handle sending new messages
  void _handleSendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        messages.add({
          'message': _messageController.text,
          'senderName': 'Me',
          'senderInitials': widget.userInitials,
          'time': 'Just Now',
          'isMe': true,
        });
      });
      _messageController.clear();

      // Scroll to bottom with animation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }
}
