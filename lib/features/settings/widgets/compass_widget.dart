/// 完整二十四山罗盘 — CustomPainter 绘制，支持点击查看详细信息
/// 支持手机指南针传感器（flutter_device_compass）：有方位角时盘面随真实方位旋转，
/// 无传感器/未授权时降级为手动点击模式。
library;
import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_device_compass/flutter_device_compass.dart';

import '../../../core/utils/logger.dart';

// ============ 二十四山方位数据（含内盘） ============
const List<Map<String, dynamic>> kTwentyFourMountains = [
  {'name': '壬', 'wx': '水', 'gua': '坎', 'angle': '345', 'dir': '正北', 'sx': '鼠'},
  {'name': '子', 'wx': '水', 'gua': '坎', 'angle': '0', 'dir': '正北', 'sx': '鼠'},
  {'name': '癸', 'wx': '水', 'gua': '坎', 'angle': '15', 'dir': '正北', 'sx': '鼠'},
  {'name': '丑', 'wx': '土', 'gua': '艮', 'angle': '30', 'dir': '东北', 'sx': '牛'},
  {'name': '艮', 'wx': '土', 'gua': '艮', 'angle': '45', 'dir': '东北', 'sx': '牛'},
  {'name': '寅', 'wx': '木', 'gua': '艮', 'angle': '60', 'dir': '东北', 'sx': '虎'},
  {'name': '甲', 'wx': '木', 'gua': '震', 'angle': '75', 'dir': '东北', 'sx': '虎'},
  {'name': '卯', 'wx': '木', 'gua': '震', 'angle': '90', 'dir': '正东', 'sx': '兔'},
  {'name': '乙', 'wx': '木', 'gua': '震', 'angle': '105', 'dir': '正东', 'sx': '兔'},
  {'name': '辰', 'wx': '土', 'gua': '巽', 'angle': '120', 'dir': '东南', 'sx': '龙'},
  {'name': '巽', 'wx': '木', 'gua': '巽', 'angle': '135', 'dir': '东南', 'sx': '龙'},
  {'name': '巳', 'wx': '火', 'gua': '巽', 'angle': '150', 'dir': '东南', 'sx': '蛇'},
  {'name': '丙', 'wx': '火', 'gua': '离', 'angle': '165', 'dir': '正南', 'sx': '马'},
  {'name': '午', 'wx': '火', 'gua': '离', 'angle': '180', 'dir': '正南', 'sx': '马'},
  {'name': '丁', 'wx': '火', 'gua': '离', 'angle': '195', 'dir': '正南', 'sx': '马'},
  {'name': '未', 'wx': '土', 'gua': '坤', 'angle': '210', 'dir': '西南', 'sx': '羊'},
  {'name': '坤', 'wx': '土', 'gua': '坤', 'angle': '225', 'dir': '西南', 'sx': '羊'},
  {'name': '申', 'wx': '金', 'gua': '坤', 'angle': '240', 'dir': '西南', 'sx': '猴'},
  {'name': '庚', 'wx': '金', 'gua': '兑', 'angle': '255', 'dir': '西南', 'sx': '猴'},
  {'name': '酉', 'wx': '金', 'gua': '兑', 'angle': '270', 'dir': '正西', 'sx': '鸡'},
  {'name': '辛', 'wx': '金', 'gua': '兑', 'angle': '285', 'dir': '正西', 'sx': '鸡'},
  {'name': '戌', 'wx': '土', 'gua': '乾', 'angle': '300', 'dir': '西北', 'sx': '狗'},
  {'name': '乾', 'wx': '金', 'gua': '乾', 'angle': '315', 'dir': '西北', 'sx': '狗'},
  {'name': '亥', 'wx': '水', 'gua': '乾', 'angle': '330', 'dir': '西北', 'sx': '猪'},
];

// ============ 天干数据 ============
const List<Map<String, String>> kHeavenlyStems = [
  {'name': '甲', 'wx': '木', 'angle': '0', 'dir': '正东'},
  {'name': '乙', 'wx': '木', 'angle': '30', 'dir': '东南'},
  {'name': '丙', 'wx': '火', 'angle': '60', 'dir': '东南'},
  {'name': '丁', 'wx': '火', 'angle': '90', 'dir': '正南'},
  {'name': '戊', 'wx': '土', 'angle': '120', 'dir': '西南'},
  {'name': '己', 'wx': '土', 'angle': '150', 'dir': '西南'},
  {'name': '庚', 'wx': '金', 'angle': '180', 'dir': '正西'},
  {'name': '辛', 'wx': '金', 'angle': '210', 'dir': '西北'},
  {'name': '壬', 'wx': '水', 'angle': '240', 'dir': '西北'},
  {'name': '癸', 'wx': '水', 'angle': '270', 'dir': '正北'},
];

// ============ 地支数据 ============
const List<Map<String, String>> kEarthlyBranches = [
  {'name': '子', 'wx': '水', 'angle': '330', 'dir': '正北', 'sx': '鼠'},
  {'name': '丑', 'wx': '土', 'angle': '0', 'dir': '正北', 'sx': '牛'},
  {'name': '寅', 'wx': '木', 'angle': '30', 'dir': '东北', 'sx': '虎'},
  {'name': '卯', 'wx': '木', 'angle': '60', 'dir': '东北', 'sx': '兔'},
  {'name': '辰', 'wx': '土', 'angle': '90', 'dir': '正东', 'sx': '龙'},
  {'name': '巳', 'wx': '火', 'angle': '120', 'dir': '东南', 'sx': '蛇'},
  {'name': '午', 'wx': '火', 'angle': '150', 'dir': '东南', 'sx': '马'},
  {'name': '未', 'wx': '土', 'angle': '180', 'dir': '正南', 'sx': '羊'},
  {'name': '申', 'wx': '金', 'angle': '210', 'dir': '西南', 'sx': '猴'},
  {'name': '酉', 'wx': '金', 'angle': '240', 'dir': '西南', 'sx': '鸡'},
  {'name': '戌', 'wx': '土', 'angle': '270', 'dir': '正西', 'sx': '狗'},
  {'name': '亥', 'wx': '水', 'angle': '300', 'dir': '西北', 'sx': '猪'},
];

// ============ 十二长生数据 ============
const List<Map<String, String>> kShiErChangSheng = [
  {'name': '长生', 'wx': '水', 'angle': '30'},
  {'name': '沐浴', 'wx': '水', 'angle': '60'},
  {'name': '冠带', 'wx': '土', 'angle': '90'},
  {'name': '临官', 'wx': '土', 'angle': '120'},
  {'name': '帝旺', 'wx': '土', 'angle': '150'},
  {'name': '衰', 'wx': '土', 'angle': '180'},
  {'name': '病', 'wx': '火', 'angle': '210'},
  {'name': '死', 'wx': '火', 'angle': '240'},
  {'name': '墓', 'wx': '火', 'angle': '270'},
  {'name': '绝', 'wx': '金', 'angle': '300'},
  {'name': '胎', 'wx': '金', 'angle': '330'},
  {'name': '养', 'wx': '金', 'angle': '0'},
];

// ============ 先天八卦 ============
const List<Map<String, dynamic>> kXianTianBagua = [
  {'name': '离', 'wx': '火', 'angle': '0', 'dir': '正南', 'symbol': '☲'},
  {'name': '坤', 'wx': '土', 'angle': '45', 'dir': '西南', 'symbol': '☷'},
  {'name': '兑', 'wx': '金', 'angle': '90', 'dir': '正西', 'symbol': '☱'},
  {'name': '乾', 'wx': '金', 'angle': '135', 'dir': '西北', 'symbol': '☰'},
  {'name': '坎', 'wx': '水', 'angle': '180', 'dir': '正北', 'symbol': '☵'},
  {'name': '艮', 'wx': '土', 'angle': '225', 'dir': '东北', 'symbol': '☶'},
  {'name': '震', 'wx': '木', 'angle': '270', 'dir': '正东', 'symbol': '☳'},
  {'name': '巽', 'wx': '木', 'angle': '315', 'dir': '东南', 'symbol': '☴'},
];

// ============ 后天八卦 ============
const List<Map<String, dynamic>> kHouTianBagua = [
  {'name': '坎', 'wx': '水', 'angle': '0', 'dir': '正北', 'symbol': '☵'},
  {'name': '坤', 'wx': '土', 'angle': '45', 'dir': '西南', 'symbol': '☷'},
  {'name': '震', 'wx': '木', 'angle': '90', 'dir': '正东', 'symbol': '☳'},
  {'name': '巽', 'wx': '木', 'angle': '135', 'dir': '东南', 'symbol': '☴'},
  {'name': '离', 'wx': '火', 'angle': '180', 'dir': '正南', 'symbol': '☲'},
  {'name': '乾', 'wx': '金', 'angle': '225', 'dir': '西北', 'symbol': '☰'},
  {'name': '兑', 'wx': '金', 'angle': '270', 'dir': '正西', 'symbol': '☱'},
  {'name': '艮', 'wx': '土', 'angle': '315', 'dir': '东北', 'symbol': '☶'},
];

class CompassWidget extends StatefulWidget {
  const CompassWidget({super.key});

  @override
  State<CompassWidget> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget> {
  int? _selectedIndex;

  // ===== 指南针传感器状态 =====
  StreamSubscription<CompassEvent>? _compassSub;
  double? _heading; // 当前方位角（0-360°，0=北），null 表示无传感器/未生效

  @override
  void initState() {
    super.initState();
    _initCompass();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  /// 订阅指南针传感器流；仅移动端尝试订阅：
  /// - 桌面/网页没有原生实现，FlutterCompass.events 虽返回非 null Stream，
  ///   但 listen 时 EventChannel 异步抛 MissingPluginException 且无法被
  ///   onError 捕获（会冒泡到全局 ErrorWidget → "渲染异常" ERROR 日志），
  ///   因此非移动端直接降级为手动点击模式。
  /// - 移动端判定包含鸿蒙（HarmonyOS/OpenHarmony：Flutter 在鸿蒙 NEXT 上
  ///   Platform.isAndroid=false，此前被误判为非移动端导致罗盘不转）
  /// - 移动端无磁力计/未授权时 heading 为 null/-1，同样自动降级。
  bool _isMobilePlatform() {
    if (kIsWeb) return false;
    final os = Platform.operatingSystem.toLowerCase();
    return os == 'android' || os == 'ios' || os == 'harmony' ||
        os == 'ohos' || os == 'fuchsia';
  }

  void _initCompass() {
    if (!_isMobilePlatform()) {
      Logger.instance.info('罗盘指南针', '非移动端，降级为点击模式');
      return;
    }
    try {
      final events = FlutterCompass.events;
      if (events == null) {
        Logger.instance.info('罗盘指南针', '设备不支持指南针传感器，降级为点击模式');
        return;
      }
      _compassSub = events.listen(
        (event) {
          final h = event.heading;
          if (!mounted) return;
          if (h == null || h < 0) {
            // 无效方位角（Android 无磁力计返回 null，部分设备返回 -1）：
            // 回到点击模式
            if (_heading != null) {
              setState(() => _heading = null);
            }
            return;
          }
          final norm = h % 360;
          // 阈值 0.2°：避免传感器高频抖动造成无谓重建
          if ((norm - (_heading ?? 0)).abs() > 0.2) {
            setState(() => _heading = norm);
          }
        },
        onError: (Object e) {
          Logger.instance.error('罗盘指南针', '传感器流错误: $e');
          if (mounted && _heading != null) {
            setState(() => _heading = null);
          }
        },
      );
      Logger.instance.info('罗盘指南针', '已订阅指南针传感器流');
    } catch (e) {
      Logger.instance.error('罗盘指南针', '初始化失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    final gold = const Color(0xFFD4A574);

    return LayoutBuilder(
      builder: (ctx, constraints) {
        // 基于可用宽/高自适应：size = min(可用宽, 可用高-状态行, 480)。
        // 桌面宽屏可放大至 480，手机竖屏约 320~360，横屏/小窗取较小者防溢出。
        final double size = math.max(
          math.min(
            math.min(constraints.maxWidth, constraints.maxHeight - 26),
            480.0,
          ),
          60.0,
        );
        final heading = _heading;
        // 盘面旋转 -heading：使盘面「子」(0°/北) 对准真实北方，
        // 设备正前方（屏幕顶部）指示的盘面刻度即当前方位。
        final angle = heading != null ? -heading * math.pi / 180 : 0.0;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                GestureDetector(
                  onTapDown: (details) =>
                      _onTapDown(ctx, details, size, isDark, t, gold),
                  child: Transform.rotate(
                    angle: angle,
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: CustomPaint(
                        painter: CompassPainter(
                          selectedIndex: _selectedIndex,
                          isDark: isDark,
                          textColor: t,
                          gold: gold,
                        ),
                      ),
                    ),
                  ),
                ),
                // 固定前方指示针（不随盘面旋转）：指向屏幕顶部 = 设备正前方，
                // 指针所指的盘面刻度即手机朝向的方位。
                if (heading != null) ...[
                  Positioned(
                    top: -6,
                    child: CustomPaint(
                      size: const Size(34, 40),
                      painter: _CompassPointerPainter(
                        color: const Color(0xFFC0392B),
                        gold: gold,
                      ),
                    ),
                  ),
                  // 底部小指针（设备后方，金色，弱化显示）
                  Positioned(
                    bottom: -4,
                    child: CustomPaint(
                      size: const Size(22, 22),
                      painter: _CompassPointerPainter(
                        color: gold.withAlpha(200),
                        gold: gold.withAlpha(120),
                        isRear: true,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            // 状态行：有方位角显示当前朝向，无则提示点击
            SizedBox(
              height: 22,
              child: Text(
                heading != null
                    ? '方位角 ${heading.toStringAsFixed(1)}° · 面向「${_headingMountainName(heading)}」'
                    : '点击方位查看详细信息',
                style: TextStyle(fontSize: 12, color: t.withAlpha(180)),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 点击选方位：命中环带内计算点击角度（有方位角时需加回盘面旋转量），
  /// 匹配最近的二十四山。
  void _onTapDown(
      BuildContext ctx, TapDownDetails details, double size, bool isDark,
      Color t, Color gold) {
    final center = size / 2;
    final dx = details.localPosition.dx - center;
    final dy = details.localPosition.dy - center;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist > size * 0.15 && dist < size * 0.48) {
      double deg = math.atan2(dx, -dy) * 180 / math.pi;
      if (deg < 0) deg += 360;
      final heading = _heading;
      if (heading != null) {
        // 盘面已逆时针旋转 heading，点击处对应的盘面角度 = 屏幕角度 + heading
        deg = (deg + heading) % 360;
      }
      final best = _nearestMountain(deg);
      setState(() => _selectedIndex = best);
      final tapped = kTwentyFourMountains[best];
      Logger.instance.info('罗盘点击', '选中: ${tapped['name']} 角度${tapped['angle']}°');
      _showInfo(ctx, best, isDark, t, gold);
    }
  }

  /// 查找与角度最接近的二十四山索引（0-23）
  int _nearestMountain(double deg) {
    int best = 0;
    double bestDiff = 360;
    for (int i = 0; i < kTwentyFourMountains.length; i++) {
      final a = double.parse(kTwentyFourMountains[i]['angle']!);
      double diff = (deg - a).abs();
      if (diff > 180) diff = 360 - diff;
      if (diff < bestDiff) {
        bestDiff = diff;
        best = i;
      }
    }
    return best;
  }

  /// 方位角对应的二十四山名称
  String _headingMountainName(double heading) {
    return kTwentyFourMountains[_nearestMountain(heading % 360)]['name']!;
  }

  void _showInfo(BuildContext ctx, int index, bool dark, Color t, Color gold) {
    final m = kTwentyFourMountains[index];
    showDialog(
      context: ctx,
      builder: (ctx2) => AlertDialog(
        backgroundColor: dark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F0EB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: gold.withAlpha(25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(m['name']!, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: gold)),
          ),
          const SizedBox(width: 8),
          Text('二十四山', style: TextStyle(fontSize: 14, color: t.withAlpha(150))),
        ]),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow('五行', m['wx'] ?? '—', t),
              _infoRow('卦象', m['gua'] ?? '—', t),
              if ((m['sx'] ?? '').isNotEmpty) _infoRow('生肖', m['sx']!, t),
              if ((m['dir'] ?? '').isNotEmpty) _infoRow('方位', m['dir']!, t),
              _infoRow('角度', '${m['angle']}°', t),
              const Divider(height: 24),
              _infoRow('天干', kHeavenlyStems.firstWhere((s) => s['angle'] == m['angle'], orElse: () => {'name': '—'})['name'] ?? '—', t),
              _infoRow('地支', kEarthlyBranches.firstWhere((s) => s['angle'] == m['angle'], orElse: () => {'name': '—'})['name'] ?? '—', t),
              _infoRow('十二长生', kShiErChangSheng.firstWhere((s) => s['angle'] == m['angle'], orElse: () => {'name': '—'})['name'] ?? '—', t),
              _infoRow('先天八卦', kXianTianBagua.firstWhere((s) => s['angle'] == m['angle'], orElse: () => {'name': '—'})['name'] ?? '—', t),
              _infoRow('后天八卦', kHouTianBagua.firstWhere((s) => s['angle'] == m['angle'], orElse: () => {'name': '—'})['name'] ?? '—', t),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx2), child: Text('关闭', style: TextStyle(color: t)))],
      ),
    );
  }

  Widget _infoRow(String label, String value, Color t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        SizedBox(width: 48, child: Text('$label：', style: TextStyle(fontSize: 13, color: t.withAlpha(150)))),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: t)),
      ]),
    );
  }
}

class CompassPainter extends CustomPainter {
  final int? selectedIndex;
  final bool isDark;
  final Color textColor, gold;

  CompassPainter({required this.selectedIndex, required this.isDark, required this.textColor, required this.gold});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // ========== 盘面底色：径向渐变（中心米白 → 边缘浅金），玉质层次感 ==========
    // 注意：colors 数量 >2 时必须显式提供 colorStops，否则运行时报错
    // "colors must have length 2 if colorStops is omitted"（罗盘直接不显示）
    final bgPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        isDark
            ? const [Color(0xFF2A2622), Color(0xFF3B332C), Color(0xFF241F1A)]
            : const [Color(0xFFFEFCF8), Color(0xFFF6EFE2), Color(0xFFEDE1CC)],
        // dart:ui Gradient.radial 的 colorStops 是位置参数（不是命名参数）
        const [0.0, 0.55, 1.0],
      );
    canvas.drawCircle(center, radius, bgPaint);

    // ========== 外圈双线金框 ==========
    final goldStrong = Paint()
      ..color = gold.withAlpha(160)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawCircle(center, radius - 2, goldStrong);
    final goldWeak = Paint()
      ..color = gold.withAlpha(70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius - 8, goldWeak);

    // ========== 精细刻度环（360° 四级刻度：45°/15°/5°/1°） ==========
    for (int i = 0; i < 360; i++) {
      final ang = i * math.pi / 180;
      final dir = Offset(math.sin(ang), -math.cos(ang));
      final p = Paint()..strokeWidth = 0.8;
      if (i % 45 == 0) {
        p.color = gold; p.strokeWidth = 2.2;
        canvas.drawLine(center + dir * (radius - 9), center + dir * (radius - 19), p);
      } else if (i % 15 == 0) {
        p.color = gold.withAlpha(150); p.strokeWidth = 1.4;
        canvas.drawLine(center + dir * (radius - 9), center + dir * (radius - 15), p);
      } else if (i % 5 == 0) {
        p.color = gold.withAlpha(90); p.strokeWidth = 1.0;
        canvas.drawLine(center + dir * (radius - 9), center + dir * (radius - 12.5), p);
      } else {
        p.color = textColor.withAlpha(45); p.strokeWidth = 0.7;
        canvas.drawLine(center + dir * (radius - 9), center + dir * (radius - 10.8), p);
      }
    }

    // 细刻度内圈沿（视觉收边）
    final tickInner = Paint()
      ..color = gold.withAlpha(50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(center, radius - 19, tickInner);

    // ========== 二十四山（外盘大字，0.70R） ==========
    for (int i = 0; i < kTwentyFourMountains.length; i++) {
      final m = kTwentyFourMountains[i];
      final isSelected = i == selectedIndex;
      final angle = double.parse(m['angle']!) * math.pi / 180;
      final textR = radius * 0.70;
      // 选中时先画浅金圆形底
      if (isSelected) {
        final selPaint = Paint()..color = gold.withAlpha(60);
        canvas.drawCircle(center + Offset(textR * math.sin(angle), -textR * math.cos(angle)), radius * 0.085, selPaint);
      }
      final tp = TextPainter(
        text: TextSpan(
          text: m['name']!,
          style: TextStyle(
            color: isSelected ? gold : textColor.withAlpha(230),
            fontSize: isSelected ? 15 : 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          center.dx + textR * math.sin(angle) - tp.width / 2,
          center.dy - textR * math.cos(angle) - tp.height / 2,
        ),
      );
    }

    // ========== 环带分隔线 ==========
    final sep = Paint()
      ..color = gold.withAlpha(80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.62, sep);
    canvas.drawCircle(center, radius * 0.465, sep);
    canvas.drawCircle(center, radius * 0.30, sep);

    // ========== 先天八卦符号（0.54R，金色） ==========
    for (int i = 0; i < kXianTianBagua.length; i++) {
      final b = kXianTianBagua[i];
      final angle = double.parse(b['angle']!) * math.pi / 180;
      final textR = radius * 0.54;
      final tp = TextPainter(
        text: TextSpan(
          text: b['symbol']!,
          style: TextStyle(
            color: gold,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          center.dx + textR * math.sin(angle) - tp.width / 2,
          center.dy - textR * math.cos(angle) - tp.height / 2,
        ),
      );
    }

    // ========== 地支（0.42R） ==========
    for (int i = 0; i < kEarthlyBranches.length; i++) {
      final b = kEarthlyBranches[i];
      final angle = double.parse(b['angle']!) * math.pi / 180;
      final textR = radius * 0.42;
      final tp = TextPainter(
        text: TextSpan(
          text: b['name']!,
          style: TextStyle(
            color: textColor.withAlpha(215),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          center.dx + textR * math.sin(angle) - tp.width / 2,
          center.dy - textR * math.cos(angle) - tp.height / 2,
        ),
      );
    }

    // ========== 天干（0.24R） ==========
    for (int i = 0; i < kHeavenlyStems.length; i++) {
      final s = kHeavenlyStems[i];
      final angle = double.parse(s['angle']!) * math.pi / 180;
      final textR = radius * 0.24;
      final tp = TextPainter(
        text: TextSpan(
          text: s['name']!,
          style: TextStyle(
            color: textColor.withAlpha(200),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          center.dx + textR * math.sin(angle) - tp.width / 2,
          center.dy - textR * math.cos(angle) - tp.height / 2,
        ),
      );
    }

    // ========== 中心太极（带金色外环） ==========
    final poolRing = Paint()
      ..color = gold.withAlpha(150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, radius * 0.155, poolRing);

    // 白鱼（阳）
    final yangPaint = Paint()
      ..color = isDark ? const Color(0xFFF5F0EB) : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.14),
      math.pi,
      math.pi,
      true,
      yangPaint,
    );

    // 黑鱼（阴）
    final yinPaint = Paint()
      ..color = isDark ? const Color(0xFF1A1714) : const Color(0xFF3A322C)
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.14),
      0,
      math.pi,
      false,
      yinPaint,
    );

    // 阴阳鱼中心点
    final centerDotPaint = Paint()
      ..color = gold
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.045, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant CompassPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex || oldDelegate.isDark != isDark;
  }
}

/// 罗盘固定指针（菱形），不随盘面旋转
class _CompassPointerPainter extends CustomPainter {
  final Color color, gold;
  final bool isRear;

  _CompassPointerPainter({required this.color, required this.gold, this.isRear = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w, h * 0.42)
      ..lineTo(w / 2, h)
      ..lineTo(0, h * 0.42)
      ..close();
    final fill = Paint()..color = color;
    canvas.drawPath(path, fill);
    final stroke = Paint()
      ..color = gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(path, stroke);
    // 中轴线（提升精致感）
    final line = Paint()
      ..color = Colors.white.withAlpha(200)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(w / 2, h * 0.18), Offset(w / 2, h * 0.82), line);
  }

  @override
  bool shouldRepaint(covariant _CompassPointerPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.gold != gold;
  }
}
