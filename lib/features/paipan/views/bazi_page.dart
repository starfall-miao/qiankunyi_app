/// 八字排盘页面 — 国风卡片风格，与六爻/梅花一致
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/logger.dart';
import '../../../shared/widgets/gua_screenshot_template.dart';
import '../../../shared/widgets/save_image_dialog.dart';
import '../../calendar/views/calendar_picker_dialog.dart';
import '../../cases/models/case_models.dart';
import '../../cases/providers/case_provider.dart';
import '../../reference/data/bazi_reference_data.dart';
import '../models/bazi_models.dart';
import '../providers/bazi_provider.dart';

/// 八字排盘页面
class BaziPage extends StatefulWidget {
  const BaziPage({super.key});

  @override
  State<BaziPage> createState() => _BaziPageState();
}

class _BaziPageState extends State<BaziPage> {
  final _log = Logger.instance;
  final _baziScreenshotKey = GlobalKey();
  // 大运横向滚动控制器（供 Scrollbar 显示/拖拽滚动条）
  final _daYunScrollCtrl = ScrollController();
  DateTime? _birth;
  bool _isMale = true;
  int _hourIndex = 6; // 默认为午时 (索引6)

  static const _hourOptions = [
    '子时\n23-01', '丑时\n01-03', '寅时\n03-05', '卯时\n05-07',
    '辰时\n07-09', '巳时\n09-11', '午时\n11-13', '未时\n13-15',
    '申时\n15-17', '酉时\n17-19', '戌时\n19-21', '亥时\n21-23',
  ];

  @override
  void dispose() {
    _daYunScrollCtrl.dispose();
    super.dispose();
  }

  // 五行色
  static const _wxColors = <String, Color>{
    '木': Color(0xFF2E7D32),
    '火': Color(0xFFD32F2F),
    '土': Color(0xFFEF6C00),
    '金': Color(0xFFF9A825),
    '水': Color(0xFF1565C0),
  };

  // 旺衰标签色
  static const _wangShuaiColors = <String, Color>{
    '旺': Color(0xFF2E7D32),
    '相': Color(0xFF558B2F),
    '休': Color(0xFFF57F17),
    '囚': Color(0xFFE65100),
    '死': Color(0xFFC62828),
  };

  @override
  Widget build(BuildContext context) {
    final bp = context.watch<BaziProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final p = theme.colorScheme.primary;
    final t = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    final b = isDark ? const Color(0xFF444444) : const Color(0xFFE0D5C8);
    final c = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
      child: bp.result != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInputCard(p, t, b, isDark, bp),
                const SizedBox(height: 12),
                Expanded(
                  child: _baziResultSection(context, bp.result!, p, t, b, c, isDark),
                ),
              ],
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInputCard(p, t, b, isDark, bp),
                  const SizedBox(height: 12),
                  _emptyHint(p, t),
                  const SizedBox(height: 60),
                ],
              ),
            ),
    );
  }

  Widget _buildInputCard(Color p, Color t, Color b, bool isDark, BaziProvider bp) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                  // 日期
                  InkWell(
                    onTap: () async {
                      _log.info('八字排盘', '打开日期选择器');
                      final d = await showDialog<DateTime>(
                        context: context,
                        useSafeArea: true,
                        builder: (_) => const CalendarPickerDialog(),
                      );
                      if (!mounted) return;
                      if (d != null) {
                        _log.info('八字排盘', '选择日期: $d');
                        setState(() => _birth = d);
                      } else {
                        _log.info('八字排盘', '取消日期选择');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: b.withAlpha(80)),
                      ),
                      child: Row(children: [
                        Icon(Icons.calendar_today_outlined, size: 18, color: p),
                        const SizedBox(width: 10),
                        Text(
                          _birth != null
                              ? '${_birth!.year} 年 ${_birth!.month} 月 ${_birth!.day} 日'
                              : '请选择出生日期',
                          style: TextStyle(fontSize: 15, color: t),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_drop_down, color: t.withAlpha(120)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 时辰选择
                  Text('选择时辰', style: TextStyle(fontSize: 13, color: t.withAlpha(180))),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: List.generate(12, (i) {
                      final sel = _hourIndex == i;
                      return ChoiceChip(
                        label: Text(
                          _hourOptions[i].split('\n')[0],
                          style: TextStyle(
                            fontSize: 11,
                            color: sel ? p : t,
                          ),
                        ),
                        selected: sel,
                        onSelected: (_) => setState(() => _hourIndex = i),
                        selectedColor: p.withAlpha(40),
                        backgroundColor: isDark
                            ? const Color(0xFF2C2C2C)
                            : const Color(0xFFF9F6F2),
                        side: BorderSide(
                          color: sel ? p : b.withAlpha(80),
                          width: sel ? 1.5 : 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        visualDensity: VisualDensity.compact,
                      );
                    }),
                  ),
                  const SizedBox(height: 12),

                  // 性别
                  Row(children: [
                    Text('性别：', style: TextStyle(fontSize: 13, color: t.withAlpha(180))),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text('男',
                          style: TextStyle(fontSize: 12, color: _isMale ? p : t)),
                      selected: _isMale,
                      onSelected: (_) => setState(() => _isMale = true),
                      selectedColor: p.withAlpha(40),
                      backgroundColor: isDark
                          ? const Color(0xFF2C2C2C)
                          : const Color(0xFFF9F6F2),
                      side: BorderSide(
                        color: _isMale ? p : b.withAlpha(80),
                        width: _isMale ? 1.5 : 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text('女',
                          style: TextStyle(fontSize: 12, color: !_isMale ? p : t)),
                      selected: !_isMale,
                      onSelected: (_) => setState(() => _isMale = false),
                      selectedColor: p.withAlpha(40),
                      backgroundColor: isDark
                          ? const Color(0xFF2C2C2C)
                          : const Color(0xFFF9F6F2),
                      side: BorderSide(
                        color: !_isMale ? p : b.withAlpha(80),
                        width: !_isMale ? 1.5 : 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // 排盘按钮
                  SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: _birth == null || bp.isCalculating
                          ? null
                          : () => _startPaipan(bp),
                      icon: bp.isCalculating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.auto_awesome, size: 18),
                      label: Text(
                        bp.isCalculating ? '排盘中…' : '排盘',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// 空状态提示
  Widget _emptyHint(Color p, Color t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(children: [
        Icon(Icons.auto_awesome, size: 48, color: p.withAlpha(80)),
        const SizedBox(height: 12),
        Text('选择出生信息后点击排盘',
            style: TextStyle(fontSize: 14, color: t.withAlpha(180))),
      ]),
    );
  }

  /// 八字结果展示区
  Widget _baziResultSection(BuildContext context,
      BaziResult r, Color p, Color t, Color b, Color c, bool dark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RepaintBoundary(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
          // ── 四柱卡片 ──
          Row(
            children: [
              _pillarCard('年柱', r.yearZhu, p, t, c, b, dark),
              const SizedBox(width: 4),
              _pillarCard('月柱', r.monthZhu, p, t, c, b, dark),
              const SizedBox(width: 4),
              _pillarCard('日柱', r.dayZhu, p, t, c, b, dark, isRiZhu: true),
              const SizedBox(width: 4),
              _pillarCard('时柱', r.hourZhu, p, t, c, b, dark),
            ],
          ),
          const SizedBox(height: 12),

          // ── 五行旺衰 ──
          _sectionHeader(p, '五行旺衰'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: r.wuXingWangShuai.entries.map((e) {
              final wc = _wxColors[e.key] ?? t;
              final sc = _wangShuaiColors[e.value] ?? t;
              return Container(
                width: 56,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: wc.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: wc.withAlpha(40)),
                ),
                child: Column(
                  children: [
                    Text(e.key,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: wc)),
                    const SizedBox(height: 2),
                    Text(e.value,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: sc)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // ── 五行数量 ──
          _sectionHeader(p, '五行统计'),
          _rowWrap(
            r.wuXingCounts.entries.map((e) {
              final wc = _wxColors[e.key] ?? t;
              return _tag('${e.key} ${e.value}', wc, t);
            }).toList(),
          ),
          const SizedBox(height: 12),

          // ── 藏干 ──
          _sectionHeader(p, '藏干'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cangGanRow('年柱', r.yearZhu.cangGan, p, t),
                  const Divider(height: 12),
                  _cangGanRow('月柱', r.monthZhu.cangGan, p, t),
                  const Divider(height: 12),
                  _cangGanRow('日柱', r.dayZhu.cangGan, p, t),
                  const Divider(height: 12),
                  _cangGanRow('时柱', r.hourZhu.cangGan, p, t),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── 十神 ──
          _sectionHeader(p, '十神关系（以日干为基准）'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: r.shiShenMap.entries
                    .where((e) => e.key != '日主')
                    .map((e) {
                  final label = e.key.contains(':')
                      ? '${e.key.split(':')[0]}:${e.key.split(':')[1]}'
                      : e.key;
                  return _tag('$label → ${e.value}', p, t);
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── 大运 ──
          if (r.daYun.isNotEmpty) ...[
            _sectionHeader(p, '大运'),
            // 桌面/窄屏可横向滚动：允许鼠标/触控板拖拽 + 可见滚动条可拖拽拇指，
            // 避免外层垂直滚动吞掉水平滚动手势导致"显示不全且无法左右滑动"。
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  ui.PointerDeviceKind.touch,
                  ui.PointerDeviceKind.mouse,
                  ui.PointerDeviceKind.stylus,
                  ui.PointerDeviceKind.trackpad,
                },
              ),
              child: Scrollbar(
                controller: _daYunScrollCtrl,
                thumbVisibility: true,
                interactive: true,
                radius: const Radius.circular(8),
                child: SingleChildScrollView(
                  controller: _daYunScrollCtrl,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: r.daYun.map((dy) {
                      return Container(
                        width: 68,
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        decoration: BoxDecoration(
                          color: dark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: b.withAlpha(60)),
                        ),
                        child: Column(
                          children: [
                            Text('${dy.startAge}岁',
                                style: TextStyle(
                                    fontSize: 11, color: t.withAlpha(150))),
                            const SizedBox(height: 2),
                            Text(dy.ganZhi,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: t)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── 流年 ──
          if (r.liuNian != null) ...[
            _sectionHeader(p, '当年流年'),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: b.withAlpha(60)),
              ),
              child: Row(children: [
                const Icon(Icons.calendar_month_outlined, size: 18, color: Colors.deepOrange),
                const SizedBox(width: 8),
                Text('流年：', style: TextStyle(fontSize: 13, color: t)),
                Text(r.liuNian!,
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: p)),
              ]),
            ),
            const SizedBox(height: 12),
          ],

              ],   // close inner children
            ),   // close inner Column
          ),   // close RepaintBoundary

          // ── 截图专用紧凑模板（屏幕外，不影响页面显示；固定 400 宽+浅色国风）──
          ScreenshotSource(
            boundaryKey: _baziScreenshotKey,
            child: BaziScreenshotTemplate(
              birthText: '${r.birth.year}年${r.birth.month}月${r.birth.day}日 '
                  '${_hourOptions[_hourIndex].split('\n')[0]} · ${r.isMale ? '男' : '女'}',
              result: r,
            ),
          ),

          // ── 操作按钮（2×2 四方格）──
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: TextButton.icon(
                    onPressed: () => context.read<BaziProvider>().clear(),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('清空排盘'),
                    style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: TextButton.icon(
                    onPressed: () => _shareResult(context, r),
                    icon: const Icon(Icons.copy_outlined, size: 16),
                    label: const Text('复制结果'),
                    style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
                  )),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextButton.icon(
                    onPressed: () => _saveBaziResult(context, r),
                    icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                    label: const Text('保存卦例'),
                    style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: TextButton.icon(
                    onPressed: () => _saveImage(_baziScreenshotKey, context),
                    icon: const Icon(Icons.image_outlined, size: 16),
                    label: const Text('保存图片'),
                    style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
                  )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── 保存引导提示 ──
          Center(
            child: Text('💡 保存为卦例后可在详情页使用 AI 解卦与人工断语',
                style: TextStyle(fontSize: 12,
                    color: t.withAlpha(180),
                    fontStyle: FontStyle.italic)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// 四柱单张卡片
  Widget _pillarCard(String label, SiZhu zhu, Color p, Color t, Color c,
      Color b, bool dark, {bool isRiZhu = false}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isRiZhu
              ? p.withAlpha(15)
              : (dark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isRiZhu ? p : b.withAlpha(60),
            width: isRiZhu ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(fontSize: 11, color: t.withAlpha(120))),
            const SizedBox(height: 6),
            // 天干 + 地支（可点击查看参考）
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _showGanRef(context, zhu.tianGan, t, p, dark),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: isRiZhu ? p.withAlpha(20) : t.withAlpha(10),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(zhu.tianGan,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isRiZhu ? p : t)),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showZhiRef(context, zhu.diZhi, t, p, dark),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(zhu.diZhi,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: t)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${zhu.tianGan}${zhu.diZhi} · ${zhu.wuXing}',
                style: TextStyle(fontSize: 11, color: t.withAlpha(150))),
          ],
        ),
      ),
    );
  }

  /// 藏干行
  Widget _cangGanRow(String label, Map<String, String> cangGan, Color p, Color t) {
    final items = cangGan.entries
        .where((e) => e.value != '无' && e.value.isNotEmpty)
        .toList();
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: p)),
        ),
        if (items.isEmpty)
          Expanded(
            child: Text('无',
                style: TextStyle(fontSize: 12, color: t.withAlpha(120))),
          )
        else
          Expanded(
            child: Row(
              children: items.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text('${e.key}:${e.value}',
                      style: TextStyle(fontSize: 12, color: t)),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  /// 开始八字排盘（含日志记录）
  Future<void> _startPaipan(BaziProvider bp) async {
    _log.info('八字排盘', '开始排盘: 出生${_birth!.year}-${_birth!.month}-${_birth!.day} '
        '性别${_isMale ? "男" : "女"} 时辰索引$_hourIndex');
    try {
      await bp.calc(birth: _birth!, isMale: _isMale, hourIndex: _hourIndex);
      _log.info('八字排盘', '排盘完成');
    } catch (e) {
      _log.error('八字排盘失败', '$e');
    }
  }

  /// 截图排盘结果并保存（浮窗预览 → 文件名编辑 → 选择目录 → 写入）
  Future<void> _saveImage(GlobalKey key, BuildContext ctx) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        if (ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('截图失败：未找到排盘结果')),
          );
        }
        return;
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();
      if (!ctx.mounted) return; // 截图/编码 await 后页面可能已销毁，避免跨 async 间隙使用 context

      // 先弹出预览浮窗（可编辑文件名），点保存后才选择目录并写入
      final savedPath = await saveImageWithDialog(
        context: ctx,
        pngBytes: pngBytes,
      );
      if (savedPath == null) return; // 用户在浮窗或目录选择中取消，不写文件
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('截图已保存: $savedPath')),
        );
      }
    } catch (e) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('保存图片失败: $e')),
        );
      }
    }
  }

  /// 保存八字结果到卦例库
  void _saveBaziResult(BuildContext context, BaziResult r) {
    final defaultTitle =
        '八字排盘 · ${r.yearZhu.ganZhi} ${r.monthZhu.ganZhi} ${r.dayZhu.ganZhi} ${r.hourZhu.ganZhi}';
    final titleCtrl = TextEditingController(text: defaultTitle);
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('保存排盘'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: '标题',
                hintText: '为排盘取个名字',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                labelText: '备注（可选）',
                hintText: '记录占问事项',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              final cm = CaseModel.fromBaziResult(
                result: r,
                title: titleCtrl.text.trim(),
                notes: notesCtrl.text.trim().isEmpty
                    ? null
                    : notesCtrl.text.trim(),
              );
              context.read<CaseProvider>().addCase(cm);
              _log.info('保存八字排盘: ${cm.title}');
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('已保存到卦例库，可到卦例页查看详情和 AI 解卦'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 分享/复制结果
  void _shareResult(BuildContext context, BaziResult r) {
    final sb = StringBuffer()
      ..writeln('【落·乾坤】八字排盘结果')
      ..writeln('━━━━━━━━━━━━━━')
      ..writeln('出生：${r.birth.year}/${r.birth.month}/${r.birth.day}'
          ' ${r.birth.hour}:${r.birth.minute.toString().padLeft(2, '0')}')
      ..writeln('性别：${r.isMale ? "男" : "女"}')
      ..writeln('━━━━━━━━━━━━━━')
      ..writeln('年柱：${r.yearZhu.ganZhi}  ${r.yearZhu.wuXing}')
      ..writeln('月柱：${r.monthZhu.ganZhi}  ${r.monthZhu.wuXing}')
      ..writeln('日柱：${r.dayZhu.ganZhi}  ${r.dayZhu.wuXing}')
      ..writeln('时柱：${r.hourZhu.ganZhi}  ${r.hourZhu.wuXing}')
      ..writeln('━━━━━━━━━━━━━━')
      ..writeln('五行旺衰：')
      ..writeln(r.wuXingWangShuai.entries
          .map((e) => '${e.key}: ${e.value}')
          .join(' · '))
      ..writeln('━━━━━━━━━━━━━━');
    if (r.daYun.isNotEmpty) {
      sb.writeln(
          '大运：${r.daYun.map((d) => '${d.ganZhi}(${d.startAge}岁起)').join('，')}');
    }
    if (r.liuNian != null) {
      sb.writeln('流年：${r.liuNian}');
    }
    sb.writeln('—— 来自「落·乾坤」');

    // 复制到剪贴板
    final data = sb.toString();
    Clipboard.setData(ClipboardData(text: data));
    _log.info('八字排盘结果已复制到剪贴板');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('结果已复制到剪贴板'), duration: Duration(seconds: 2)),
    );
  }

  /// 区域标题
  Widget _sectionHeader(Color p, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 2),
      child: Text(title,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: p)),
    );
  }

  /// 标签
  Widget _tag(String text, Color p, Color t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: p.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: p.withAlpha(40)),
      ),
      child: Text(text,
          style: TextStyle(fontSize: 12, color: t.withAlpha(220))),
    );
  }

  /// Wrap 行
  Widget _rowWrap(List<Widget> children) {
    return Wrap(spacing: 6, runSpacing: 6, children: children);
  }

  /// 显示天干参考弹窗
  void _showGanRef(BuildContext ctx, String gan, Color t, Color p, bool dark) {
    TianGanInfo? temp;
    try {
      temp = tianGanList.firstWhere((g) => g.name == gan);
    } catch (_) {}
    if (temp == null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('暂无「$gan」的参考资料', style: const TextStyle(fontSize: 13))),
      );
      return;
    }
    final info = temp;
    showDialog(
      context: ctx,
      builder: (ctx2) => AlertDialog(
        backgroundColor: dark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F0EB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: p.withAlpha(25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(info.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: p)),
          ),
          const SizedBox(width: 8),
          Text('天干', style: TextStyle(fontSize: 14, color: t.withAlpha(120))),
        ]),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _refRow('五行', info.wuXing, t),
              _refRow('阴阳', info.yinYang, t),
              _refRow('方位', info.direction, t),
              if (info.body.isNotEmpty) _refRow('对应身体', info.body, t),
              if (info.image.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text('类象', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t)),
                const SizedBox(height: 2),
                Text(info.image, style: TextStyle(fontSize: 12, color: t.withAlpha(200))),
              ],
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('关闭'))],
      ),
    );
  }

  /// 显示地支参考弹窗
  void _showZhiRef(BuildContext ctx, String zhi, Color t, Color p, bool dark) {
    DiZhiInfo? temp;
    try {
      temp = diZhiList.firstWhere((z) => z.name == zhi);
    } catch (_) {}
    if (temp == null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('暂无「$zhi」的参考资料', style: const TextStyle(fontSize: 13))),
      );
      return;
    }
    final info = temp;
    showDialog(
      context: ctx,
      builder: (ctx2) => AlertDialog(
        backgroundColor: dark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F0EB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: p.withAlpha(25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(info.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: p)),
          ),
          const SizedBox(width: 8),
          Text('地支', style: TextStyle(fontSize: 14, color: t.withAlpha(120))),
        ]),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _refRow('五行', info.wuXing, t),
              _refRow('阴阳', info.yinYang, t),
              _refRow('方位', info.direction, t),
              _refRow('月份', info.month, t),
              _refRow('时辰', info.hourRange, t),
              _refRow('生肖', info.shengXiao, t),
              if (info.image.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text('类象', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t)),
                const SizedBox(height: 2),
                Text(info.image, style: TextStyle(fontSize: 12, color: t.withAlpha(200))),
              ],
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('关闭'))],
      ),
    );
  }

  /// 参考信息行
  Widget _refRow(String label, String value, Color t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text('$label：', style: TextStyle(fontSize: 12, color: t.withAlpha(150))),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 12, color: t)),
          ),
        ],
      ),
    );
  }
}
