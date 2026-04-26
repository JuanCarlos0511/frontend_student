import 'package:flutter/material.dart';
import 'package:uni_social_student/core/theme/app_theme.dart';

class AnimatedSearchBar extends StatefulWidget {
  final String hintText;
  final Function(String) onChanged;

  const AnimatedSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
  });

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _focusNode.hasFocus ? AppTheme.primaryRed.withAlpha(100) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            style: const TextStyle(fontSize: 15, color: AppTheme.darkText),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: const TextStyle(color: AppTheme.mediumGrey),
              prefixIcon: const Icon(Icons.search, color: AppTheme.mediumGrey),
              suffixIcon: _textController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppTheme.mediumGrey, size: 20),
                      onPressed: () {
                        _textController.clear();
                        widget.onChanged('');
                        FocusScope.of(context).unfocus();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    );
  }
}
