/// 保存图片流程公共组件（US-005）
///
/// 统一六爻/梅花/八字结果页的保存图片流程：
/// 1. 弹出小尺寸预览浮窗（半透明遮罩 + 毛玻璃模糊背景），可编辑文件名
/// 2. 点击「保存」后弹出系统目录选择器
/// 3. 选定目录后写入 PNG 文件并返回保存路径
library;

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/utils/logger.dart';

/// 生成默认图片文件名：{prefix}_yyyyMMdd_HHmmss.png
///
/// 例：buildImageFileName('乾为天') → 乾为天_20260731_101530.png
String buildImageFileName(String prefix) {
  final t = DateTime.now();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${prefix}_${t.year}${two(t.month)}${two(t.day)}_'
      '${two(t.hour)}${two(t.minute)}${two(t.second)}.png';
}

/// 保存图片完整流程：预览浮窗(可编辑文件名) → 选择保存目录 → 写入文件。
///
/// [defaultFileName]：默认文件名（建议带卦名，如 乾为天_20260731_101530.png）；
/// 为空时回退为 qiankunyi_yyyyMMdd_HHmmss.png。用户可在浮窗中编辑。
/// 返回保存后的文件路径；用户在浮窗取消或目录选择取消时返回 null（不写文件）。
Future<String?> saveImageWithDialog({
  required BuildContext context,
  required Uint8List pngBytes,
  String? defaultFileName,
}) async {
  final log = Logger.instance;
  log.info('保存图片: 开始保存流程');
  final fileName = await showSaveImageDialog(
    context: context,
    pngBytes: pngBytes,
    defaultFileName: defaultFileName,
  );
  if (fileName == null) {
    log.info('保存图片: 用户在预览浮窗取消，未保存');
    return null;
  }
  final trimmed = fileName.trim();
  if (trimmed.isEmpty) {
    log.info('保存图片: 文件名为空，未保存');
    return null;
  }

  // 点击保存后才选择保存目录
  final directory = await FilePicker.platform.getDirectoryPath(
    dialogTitle: '选择保存目录',
  );
  if (directory == null || directory.isEmpty) {
    log.info('保存图片: 用户取消选择目录，未保存');
    return null;
  }
  log.info('保存图片: 已选择目录 $directory');

  final path = '$directory/$trimmed';
  await File(path).writeAsBytes(pngBytes);
  log.info('保存图片: 已保存到 $path');
  return path;
}

/// 弹出保存图片预览浮窗，返回编辑后的文件名；取消返回 null。
Future<String?> showSaveImageDialog({
  required BuildContext context,
  required Uint8List pngBytes,
  String? defaultFileName,
}) {
  return showDialog<String>(
    context: context,
    barrierColor: Colors.black.withAlpha(140),
    builder: (_) => _SaveImageDialog(
      pngBytes: pngBytes,
      defaultFileName: defaultFileName,
    ),
  );
}

/// 预览浮窗：图片预览 + 文件名输入框 + 取消/保存按钮
class _SaveImageDialog extends StatefulWidget {
  const _SaveImageDialog({
    required this.pngBytes,
    this.defaultFileName,
  });

  final Uint8List pngBytes;

  /// 默认文件名（可含卦名）；为空时使用 qiankunyi_ 前缀兜底
  final String? defaultFileName;

  @override
  State<_SaveImageDialog> createState() => _SaveImageDialogState();
}

class _SaveImageDialogState extends State<_SaveImageDialog> {
  // TextEditingController 必须在 State 中创建，避免 build 内临时创建导致编辑失效
  late final TextEditingController _fileNameCtrl;

  @override
  void initState() {
    super.initState();
    _fileNameCtrl = TextEditingController(text: _initialFileName());
  }

  @override
  void dispose() {
    _fileNameCtrl.dispose();
    super.dispose();
  }

  /// 初始文件名：优先使用传入的 defaultFileName（含卦名），否则回退通用前缀
  String _initialFileName() {
    final d = widget.defaultFileName;
    if (d != null && d.trim().isNotEmpty) return d.trim();
    return buildImageFileName('qiankunyi');
  }

  /// 全屏放大预览：黑色背景大图，支持双指/鼠标滚轮缩放，右上角关闭
  void _showFullPreview() {
    final screenSize = MediaQuery.sizeOf(context);
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withAlpha(220),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: SizedBox(
          // 显式约束，避免 Dialog+InteractiveViewer 在桌面端高度坍缩
          width: screenSize.width * 0.95,
          height: screenSize.height * 0.95,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    maxScale: 5.0,
                    minScale: 0.5,
                    // SizedBox.expand 显式铺满视口，Center + BoxFit.contain
                    // 保证放大预览同样水平垂直居中
                    child: SizedBox.expand(
                      child: Center(
                        child: Image.memory(
                          widget.pngBytes,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                // 右上角关闭按钮（避免 InteractiveViewer 手势吞掉背景点击）
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.black.withAlpha(120),
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      tooltip: '关闭大图',
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = dark
        ? const Color(0xFF1A1A2E).withAlpha(235)
        : const Color(0xFFF5F0EB).withAlpha(245);
    final textColor =
        dark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          // 毛玻璃模糊：模糊浮窗背后的页面内容，配合半透明 barrier 实现背景模糊遮罩
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '保存图片',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 图片预览：点击可放大查看
                    // 用 SizedBox 显式限定预览区尺寸（高度 180、宽度撑满），
                    // Image 在容器内 BoxFit.contain 等比缩放不裁切，外层
                    // Center 保证图片水平垂直居中。此前 Image 直接依赖
                    // 单边 height + 父级 loose 约束计算布局尺寸，部分版本
                    // 下会以 maxWidth 主导导致预览图偏左上、Center 失效。
                    Center(
                      child: GestureDetector(
                        onTap: _showFullPreview,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: double.infinity,
                            height: 180,
                            child: Image.memory(
                              widget.pngBytes,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: InkWell(
                        onTap: _showFullPreview,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.zoom_in,
                                  size: 14, color: textColor.withAlpha(140)),
                              const SizedBox(width: 4),
                              Text(
                                '点击图片放大查看',
                                style: TextStyle(
                                    fontSize: 11, color: textColor.withAlpha(140)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _fileNameCtrl,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: '文件名',
                        labelStyle: TextStyle(color: textColor.withAlpha(180)),
                        prefixIcon:
                            Icon(Icons.image, color: textColor.withAlpha(180)),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('取消'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.of(context).pop(_fileNameCtrl.text),
                          child: const Text('保存'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
