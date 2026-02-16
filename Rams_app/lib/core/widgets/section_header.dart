import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final EdgeInsets? padding;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.fontSize = 16,
    this.fontWeight = FontWeight.bold,
    this.color,
    this.padding,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final Widget titleWidget = Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? Theme.of(context).textTheme.titleLarge?.color,
      ),
    );

    final Widget content = trailing != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [titleWidget, trailing!],
          )
        : titleWidget;

    return padding != null
        ? Padding(padding: padding!, child: content)
        : content;
  }
}
