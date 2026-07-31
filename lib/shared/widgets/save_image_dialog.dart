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

/// 保存图片完整流程：预览浮窗(可编辑文件名) → 选择保存目录 → 写入文件。
///
/// 返回保存后的文件路径；用户在浮窗取消或目录选择取消时返回 null（不写文件）。
Future<String?> saveImageWithDialog({
  required BuildContext context,
  required Uint8List pngBytes,
}) async {
  final log = Logger.instance;
  log.info('保存图片: 开始保存流程');
  final fileName = await showSaveImageDialog(
    context: context,
    pngBytes: pngBytes,
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
}) {
  return showDialog<String>(
    context: context,
    barrierColor: Colors.black.withAlpha(140),
    builder: (_) => _SaveImageDialog(pngBytes: pngBytes),
  );
}

/// 预览浮窗：图片预览 + 文件名输入框 + 取消/保存按钮
class _SaveImageDialog extends StatefulWidget {
  const _SaveImageDialog({required this.pngBytes});

  final Uint8List pngBytes;

  @override
  State<_SaveImageDialog> createState() => _SaveImageDialogState();
}

class _SaveImageDialogState extends State<_SaveImageDialog> {
  // TextEditingController 必须在 State 中创建，避免 build 内临时创建导致编辑失效
  late final TextEditingController _fileNameCtrl;

  @override
  void initState() {
    super.initState();
    _fileNameCtrl = TextEditingController(text: _defaultImageFileName());
  }

  @override
  void dispose() {
    _fileNameCtrl.dispose();
    super.dispose();
  }

  /// 默认文件名：qiankunyi_yyyyMMdd_HHmmss.png
  String _defaultImageFileName() {
    final t = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return 'qiankunyi_${t.year}${two(t.month)}${two(t.day)}_'
        '${two(t.hour)}${two(t.minute)}${two(t.second)}.png';
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
                    // 图片预览
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          widget.pngBytes,
                          height: 180,
                          fit: BoxFit.contain,
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
