import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ButtonVariant {
  primary,
  secondary,
  outline,
  text,
}

class CustomButton extends StatelessWidget {
  /// [title] argument is required
  const CustomButton({
    super.key,
    this.title,
    this.onPressed,
    this.titleStyle,
    this.backgroundColor,
    this.gradient,
    this.shape,
    this.width = 140,
    this.height = 56,
    this.loading = false,
    this.isDisabled = false,
    this.icon,
    this.elevation = 0,
    this.gap = 12,
    this.splashColor,
    this.variant = ButtonVariant.primary,
  });

  final String? title;
  final Widget? icon;
  final double gap;
  final double elevation;
  final VoidCallback? onPressed;

  /// [titleStyle] is used to style the button text
  final TextStyle? titleStyle;

  /// [backgroundColor] for solid color button
  final Color? backgroundColor;

  /// [gradient] for gradient button
  final Gradient? gradient;

  /// [shape] is used to apply border radius on button
  final ShapeBorder? shape;

  /// [width] button width, defaults is 140
  final double width;

  /// [height] button height, defaults is 56
  final double height;

  /// [loading] is used to display circular progress indicator on loading event, default is false
  final bool loading;

  /// [isDisabled] is used to disable the button, default is false
  final bool isDisabled;

  final Color? splashColor;
  
  /// [variant] determines the button style
  final ButtonVariant variant;

  ShapeBorder get _shape =>
      shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

  BoxConstraints get _constraints =>
      BoxConstraints.tightFor(width: width, height: height);

  Color _getSplashColor(ColorScheme colorScheme) =>
      splashColor ?? colorScheme.onPrimary.withOpacity(0.2);
      
  Decoration _getDecoration(ColorScheme colorScheme) {
    if (isDisabled) {
      return ShapeDecoration(
        shape: _shape,
        color: colorScheme.surfaceContainerHighest,
      );
    }
    
    switch (variant) {
      case ButtonVariant.primary:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: gradient ?? LinearGradient(
            colors: [
              backgroundColor ?? colorScheme.primary,
              (backgroundColor ?? colorScheme.primary).withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: (backgroundColor ?? colorScheme.primary).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case ButtonVariant.secondary:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: colorScheme.secondaryContainer,
        );
      case ButtonVariant.outline:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.transparent,
        );
      case ButtonVariant.text:
        return const BoxDecoration(
          color: Colors.transparent,
        );
    }
  }
  
  Color _getTextColor(ColorScheme colorScheme) {
    if (isDisabled) {
      return colorScheme.onSurfaceVariant;
    }
    
    switch (variant) {
      case ButtonVariant.primary:
        return Colors.white;
      case ButtonVariant.secondary:
        return colorScheme.onSecondaryContainer;
      case ButtonVariant.outline:
        return colorScheme.primary;
      case ButtonVariant.text:
        return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    
    Widget child;
    
    if (loading) {
      child = Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: _getTextColor(colorScheme),
            strokeWidth: 2,
          ),
        ),
      );
    } else if (icon != null && title != null) {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          SizedBox(width: gap),
          Text(
            title!,
            style: titleStyle ??
                theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(colorScheme),
                ),
          ),
        ],
      );
    } else if (title != null) {
      child = Text(
        title!,
        style: titleStyle ??
            theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: _getTextColor(colorScheme),
            ),
      );
    } else if (icon != null) {
      child = icon!;
    } else {
      child = const SizedBox.shrink();
    }
    
    Widget button = Container(
      width: width,
      height: height,
      decoration: _getDecoration(colorScheme),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: _getSplashColor(colorScheme),
          onTap: isDisabled || loading
              ? null
              : () async {
                  FocusScope.of(context).unfocus();
                  await HapticFeedback.lightImpact();
                  onPressed?.call();
                },
          child: Center(child: child),
        ),
      ),
    );
    
    // Add border for outline variant
    if (variant == ButtonVariant.outline) {
      button = Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDisabled 
                ? colorScheme.outline.withOpacity(0.3)
                : colorScheme.primary,
            width: 1.5,
          ),
        ),
        child: button,
      );
    }
    
    return button;
  }
}