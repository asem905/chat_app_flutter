import 'package:flutter/material.dart';

class TypingIndicatorWidget extends StatefulWidget {
  final Map<int, String> typingUsers;

  const TypingIndicatorWidget({Key? key, required this.typingUsers})
    : super(key: key);

  @override
  State<TypingIndicatorWidget> createState() => _TypingIndicatorWidgetState();
}

class _TypingIndicatorWidgetState extends State<TypingIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getTypingText() {
    final usernames = widget.typingUsers.values.toList();
    print('usernames $usernames');
    if (usernames.isEmpty) return '';

    if (usernames.length == 1) {
      return '${usernames[0]} is typing';
    } else if (usernames.length == 2) {
      return '${usernames[0]} and ${usernames[1]} are typing';
    } else {
      return '${usernames[0]} and ${usernames.length - 1} others are typing';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.typingUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _AnimatedDots(controller: _controller),
          const SizedBox(width: 8),
          Text(
            _getTypingText(),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedDots extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final delay = index * 0.2;
              final value = (controller.value - delay) % 1.0;
              final opacity = value < 0.5 ? value * 2 : (1 - value) * 2;

              return Opacity(
                opacity: opacity.clamp(0.3, 1.0),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
