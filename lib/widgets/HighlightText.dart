import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 用于显示包含HTML高亮标签的文本的Widget
/// 支持 <span class='highlight'>文本</span> 格式的高亮显示
class HighlightText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final int? maxLines;
  final TextOverflow? overflow;

  const HighlightText({
    Key? key,
    required this.text,
    this.style,
    this.highlightStyle,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultStyle = style ?? TextStyle(fontSize: 14.sp);
    final defaultHighlightStyle = highlightStyle ?? 
        TextStyle(
          fontSize: 14.sp,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        );

    // 解析HTML高亮标签
    final spans = _parseHighlightText(text, defaultStyle, defaultHighlightStyle);
    
    return RichText(
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
      text: TextSpan(children: spans),
    );
  }

  /// 解析包含高亮标签的文本
  List<TextSpan> _parseHighlightText(String text, TextStyle normalStyle, TextStyle highlightStyle) {
    final List<TextSpan> spans = [];
    
    // 匹配 <span class='highlight'>内容</span> 的正则表达式
    final highlightRegex = RegExp(r"<span class='highlight'>(.*?)</span>");
    
    int currentIndex = 0;
    
    // 查找所有高亮标签
    final matches = highlightRegex.allMatches(text);
    
    for (final match in matches) {
      // 添加高亮标签前的普通文本
      if (match.start > currentIndex) {
        final normalText = text.substring(currentIndex, match.start);
        if (normalText.isNotEmpty) {
          spans.add(TextSpan(text: normalText, style: normalStyle));
        }
      }
      
      // 添加高亮文本
      final highlightText = match.group(1) ?? '';
      if (highlightText.isNotEmpty) {
        spans.add(TextSpan(text: highlightText, style: highlightStyle));
      }
      
      currentIndex = match.end;
    }
    
    // 添加剩余的普通文本
    if (currentIndex < text.length) {
      final remainingText = text.substring(currentIndex);
      if (remainingText.isNotEmpty) {
        spans.add(TextSpan(text: remainingText, style: normalStyle));
      }
    }
    
    // 如果没有找到任何高亮标签，返回原始文本
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: normalStyle));
    }
    
    return spans;
  }
}
