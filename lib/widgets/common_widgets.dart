import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../theme/theme_config.dart';

class PageBackground extends StatelessWidget {
  final Widget child;
  final Gradient? customGradient;
  const PageBackground({
    super.key,
    required this.child,
    this.customGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: customGradient ?? AppTheme.backgroundGradient,
        ),
        child: child,
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final BoxDecoration? decoration;
  final bool showBorder;
  const AppCard({
    super.key,
    required this.child,
    this.decoration,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.cardPadding,
      decoration: decoration ??
          BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: showBorder
                ? Border.all(color: Colors.grey.shade300, width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: AppTheme.focus.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
      child: child,
    );
  }
}

class AppInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final bool obscureText; // ✅ 兼容两种写法
  final bool enabled;
  final TextInputAction? action;
  final void Function(String)? onSubmitted;

  const AppInput({
    super.key,
    required this.label,
    this.hint = "",
    required this.controller,
    this.obscure = false,
    this.obscureText = false,
    this.enabled = true,
    this.action,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final isObscure = obscure || obscureText; // 兼容两种写法
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) Text(label, style: AppTheme.label),
        if (label.isNotEmpty) const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          enabled: enabled,
          textInputAction: action,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.textHint),
            filled: true,
            fillColor: const Color(0xFFFAFCFB),
            border: _border(AppTheme.border),
            enabledBorder: _border(AppTheme.border),
            focusedBorder: _border(AppTheme.focus, width: 2),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? bgColor;
  final Color? textColor;
  const AppButton({
    super.key,
    required this.text,
    required this.onTap,
    this.bgColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor ?? AppTheme.buttonBg,
          foregroundColor: textColor ?? AppTheme.buttonText,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class AppLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const AppLink({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
            padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
        child: Text(text, style: AppTheme.linkStyle),
      ),
    );
  }
}

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBackButton = true,
    this.actions,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    const aspectRatio = kIsWeb ? 9 / 16 : 9 / 19;
    const maxWidth = kIsWeb ? 420.0 : double.infinity;

    return PageBackground(
      child: Center(
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: AppCard(
              showBorder: kIsWeb,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  kIsWeb ? AppTheme.radiusLg : 0,
                ),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    title: Text(title),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    automaticallyImplyLeading: showBackButton,
                    actions: actions,
                  ),
                  body: body,
                  bottomNavigationBar: bottomNavigationBar,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
