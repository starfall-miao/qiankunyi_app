/// 大六壬 / 小六壬 保存图片模板
///
/// 与六爻 `LiuyaoScreenshotTemplate` 同一设计口径：
/// - 宽度固定 400px、背景固定浅色国风（不随主题反色）
/// - 版式紧凑：小间距、小字号、表格化，尽量在一屏内给全信息
/// - 每块都带白话解释，不只有术语
///
/// 对应页面在屏幕外挂 [ScreenshotSource] + 本模板，截图 GlobalKey 移到模板上。
library;

import 'package:flutter/material.dart';

import '../../features/paipan/engines/daliuren_engine.dart';
import '../../features/paipan/engines/xiaoliuren_engine.dart';

// ───────── 固定国风配色（不随主题变化） ─────────
const _bg = Color(0xFFF5F0EB);
const _text = Color(0xFF4A3728);
const _sub = Color(0xFF9A8A78);
const _gold = Color(0xFFD4A574);
const _cardBg = Color(0xFFFFFBF7);
const _border = Color(0xFFE8DDD2);

const _zhiWx = {
  '子': '水', '丑': '土', '寅': '木', '卯': '木', '辰': '土', '巳': '火',
  '午': '火', '未': '土', '申': '金', '酉': '金', '戌': '土', '亥': '水',
};

const _jiangShort = {
  '贵人': '贵', '螣蛇': '蛇', '朱雀': '雀', '六合': '合', '勾陈': '勾',
  '青龙': '龙', '天空': '空', '白虎': '虎', '太常': '常', '玄武': '玄',
  '太阴': '阴', '天后': '后',
};

/// 模板外壳：标题 + 时间 + 信息标签 + 内容
Widget _shell({
  required String title,
  required String timeText,
  List<String> infoTags = const [],
  required List<Widget> children,
}) {
  return Container(
    width: 400,
    color: _bg,
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [
          Container(width: 3, height: 14, color: _gold),
          const SizedBox(width: 6),
          Text(title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: _text)),
          const Spacer(),
          Text(timeText, style: const TextStyle(fontSize: 9, color: _sub)),
        ]),
        if (infoTags.isNotEmpty) ...[
          const SizedBox(height: 4),
          Wrap(spacing: 8, runSpacing: 3, children: [
            for (final tag in infoTags)
              Text(tag, style: const TextStyle(fontSize: 9.5, color: _sub)),
          ]),
        ],
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 6),
        const Divider(height: 1, thickness: 0.5, color: _border),
        const SizedBox(height: 4),
        const Center(
          child: Text('—— 来自「落·乾坤」（仅供学习参考）——',
              style: TextStyle(fontSize: 8.5, color: _sub)),
        ),
      ],
    ),
  );
}

Widget _sectionTitle(String text, [String? desc]) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4, top: 2),
    child: Row(children: [
      Container(width: 2, height: 10, color: _gold),
      const SizedBox(width: 4),
      Text(text,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: _text)),
      if (desc != null) ...[
        const SizedBox(width: 6),
        Expanded(
          child: Text(desc,
              style: const TextStyle(fontSize: 8.5, color: _sub),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    ]),
  );
}

Widget _card({required List<Widget> children, EdgeInsets? padding}) {
  return Container(
    width: double.infinity,
    padding: padding ?? const EdgeInsets.all(7),
    decoration: BoxDecoration(
      color: _cardBg,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: _border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );
}

Widget _line(String label, String value, {double width = 46}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: width,
        child: Text(label, style: const TextStyle(fontSize: 9.5, color: _sub)),
      ),
      Expanded(
        child: Text(value,
            style: const TextStyle(fontSize: 9.5, height: 1.45, color: _text)),
      ),
    ]),
  );
}

// ═══════════════════ 大六壬模板 ═══════════════════

/// 大六壬紧凑截图：四柱 → 三传/四课表 → 天地盘 → 神煞 → 事态推演 → 断课要点
class DaLiuRenScreenshotTemplate extends StatelessWidget {
  final String timeText;
  final String lunarText;
  final DaLiuRenResult result;

  /// 断课要点（页面侧生成，模板只负责排版）
  final List<String> hints;

  const DaLiuRenScreenshotTemplate({
    super.key,
    required this.timeText,
    this.lunarText = '',
    required this.result,
    this.hints = const [],
  });

  @override
  Widget build(BuildContext context) {
    final r = result;
    return _shell(
      title: '大六壬 · ${r.keTi}课',
      timeText: timeText,
      infoTags: [
        if (lunarText.isNotEmpty) lunarText,
        '月将 ${daliurenYueJiang[r.yueJiang]}（${r.yueJiangZhi}）',
        '贵人 ${r.guiRen}',
        '旬空 ${r.xunKong.join(' ')}',
      ],
      children: [
        // ── 四柱 ──
        _card(children: [
          Row(children: [
            for (final e in [
              ('年', r.siZhu.isNotEmpty ? r.siZhu[0] : '—'),
              ('月', r.siZhu.length > 1 ? r.siZhu[1] : '—'),
              ('日', r.siZhu.length > 2 ? r.siZhu[2] : '—'),
              ('时', r.siZhu.length > 3 ? r.siZhu[3] : '—'),
            ])
              Expanded(
                child: Column(children: [
                  Text(e.$1,
                      style: const TextStyle(fontSize: 8.5, color: _sub)),
                  Text(e.$2,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _text)),
                ]),
              ),
          ]),
        ]),
        const SizedBox(height: 6),

        // ── 三传 / 四课 ──
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _chuanTable(r)),
          const SizedBox(width: 5),
          Expanded(child: _keTable(r)),
        ]),
        if (r.quChuanNote.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(r.quChuanNote,
              style: const TextStyle(
                  fontSize: 8.5, height: 1.4, color: _sub, fontStyle: FontStyle.italic)),
        ],
        const SizedBox(height: 6),

        // ── 天地盘 ──
        _sectionTitle('天地盘', '上格天将 / 中格天盘 / 下格地盘'),
        Center(child: _shiPan(r)),
        const SizedBox(height: 6),

        // ── 神煞 / 关系 ──
        _card(children: [
          if (r.shenSha.isNotEmpty) _line('神煞', r.shenSha.join('　')),
          if (r.chuanRelation.isNotEmpty)
            _line('传间', '初→中 ${r.chuanRelation[0]}　中→末 ${r.chuanRelation[1]}'),
          _line('天将', '贵人临地盘${r.guiRenGong}位，${r.shunBu ? '阳位顺布' : '阴位逆布'}'),
          _line('课体', '${r.keTi}（${r.chuanFa}）'),
        ]),
        const SizedBox(height: 6),

        // ── 事态推演 ──
        _sectionTitle('事态推演', '初=起因 · 中=过程 · 末=归宿'),
        Row(children: [
          for (var i = 0; i < 3; i++) ...[
            Expanded(child: _stage(i, r)),
            if (i < 2) const SizedBox(width: 4),
          ],
        ]),
        if (hints.isNotEmpty) ...[
          const SizedBox(height: 6),
          _sectionTitle('断课要点'),
          _card(children: [
            for (final h in hints)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('· ', style: TextStyle(fontSize: 9, color: _gold)),
                  Expanded(
                    child: Text(h,
                        style: const TextStyle(
                            fontSize: 9, height: 1.5, color: _text)),
                  ),
                ]),
              ),
          ]),
        ],
      ],
    );
  }

  Widget _cell(String text,
      {bool bold = false, Color? color, double size = 9.5}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 1),
      child: Center(
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color ?? _text.withAlpha(225),
            )),
      ),
    );
  }

  Widget _chuanTable(DaLiuRenResult r) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: _border),
      ),
      child: Table(
        border: TableBorder.all(color: _border, width: 0.5),
        columnWidths: const {
          0: FixedColumnWidth(16),
          1: FlexColumnWidth(1.1),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(0.8),
        },
        children: [
          TableRow(decoration: BoxDecoration(color: _gold.withAlpha(20)), children: [
            _cell('', size: 8),
            _cell('六亲', size: 8, color: _sub),
            _cell('三传', size: 8, color: _sub),
            _cell('天将', size: 8, color: _sub),
          ]),
          for (var i = 0; i < 3; i++)
            TableRow(children: [
              _cell(['初', '中', '末'][i], bold: true, size: 8.5),
              _cell(r.chuanLiuQin[i], size: 8.5),
              _cell(
                  '${r.shiYong[i]}'
                  '${r.chuanDunGan.isNotEmpty && r.chuanDunGan[i] != '空' ? '(${r.chuanDunGan[i]})' : ''}',
                  bold: true, size: 12),
              _cell(_jiangOf(r, r.shiYong[i]), size: 9),
            ]),
        ],
      ),
    );
  }

  Widget _keTable(DaLiuRenResult r) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: _border),
      ),
      child: Table(
        border: TableBorder.all(color: _border, width: 0.5),
        columnWidths: const {
          0: FixedColumnWidth(16),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(1),
          4: FlexColumnWidth(1),
        },
        children: [
          TableRow(decoration: BoxDecoration(color: _gold.withAlpha(20)), children: [
            _cell('', size: 8),
            _cell('四课', size: 8, color: _sub),
            _cell('三课', size: 8, color: _sub),
            _cell('二课', size: 8, color: _sub),
            _cell('一课', size: 8, color: _sub),
          ]),
          TableRow(children: [
            _cell('天将', size: 8, color: _sub),
            for (final i in [3, 2, 1, 0]) _cell(_jiangOf(r, r.siKeShang[i]), size: 8.5),
          ]),
          TableRow(children: [
            _cell('上神', size: 8, color: _sub),
            for (final i in [3, 2, 1, 0]) _cell(r.siKeShang[i], bold: true, size: 11),
          ]),
          TableRow(children: [
            _cell('下神', size: 8, color: _sub),
            for (final i in [3, 2, 1, 0]) _cell(r.siKeXia[i], size: 9.5),
          ]),
          TableRow(children: [
            _cell('克', size: 8, color: _sub),
            for (final i in [3, 2, 1, 0])
              _cell(
                r.keRelation[i] == '贼'
                    ? '↑贼'
                    : (r.keRelation[i] == '克' ? '↓克' : '-'),
                size: 8,
                color: r.keRelation[i] == '贼'
                    ? const Color(0xFF1565C0)
                    : (r.keRelation[i] == '克'
                        ? const Color(0xFFC62828)
                        : _sub),
              ),
          ]),
          TableRow(children: [
            _cell('六亲', size: 8, color: _sub),
            for (final i in [3, 2, 1, 0]) _cell(r.keLiuQin[i], size: 8.5),
          ]),
        ],
      ),
    );
  }

  Widget _shiPan(DaLiuRenResult r) {
    Widget cell(String di) {
      final pos = daliurenZhi.indexOf(di);
      return Container(
        width: 42,
        padding: const EdgeInsets.symmetric(vertical: 1.5),
        decoration: BoxDecoration(
          color: pos == r.hourIndex ? _gold.withAlpha(30) : Colors.transparent,
          border: Border.all(color: _border, width: 0.5),
        ),
        child: Column(children: [
          Text(_jiangShort[r.tianJiang[pos]] ?? '',
              style: const TextStyle(fontSize: 7, color: _gold)),
          Text(r.tianPan[pos],
              style: const TextStyle(
                  fontSize: 12, height: 1.0, fontWeight: FontWeight.bold, color: _text)),
          Text(di, style: const TextStyle(fontSize: 7, color: _sub)),
        ]),
      );
    }

    Widget center(String label, String value) => Container(
          width: 84,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: _gold.withAlpha(16),
            border: Border.all(color: _border, width: 0.5),
          ),
          child: Column(children: [
            Text(label, style: const TextStyle(fontSize: 7, color: _sub)),
            Text(value,
                style: const TextStyle(
                    fontSize: 13, height: 1.0, fontWeight: FontWeight.bold, color: _text)),
          ]),
        );

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(mainAxisSize: MainAxisSize.min,
          children: [for (final z in ['巳', '午', '未', '申']) cell(z)]),
      Row(mainAxisSize: MainAxisSize.min, children: [
        cell('辰'),
        center('日干支', r.siZhu.length > 2 ? r.siZhu[2] : ''),
        cell('酉'),
      ]),
      Row(mainAxisSize: MainAxisSize.min, children: [
        cell('卯'),
        center('时支', daliurenZhi[r.hourIndex]),
        cell('戌'),
      ]),
      Row(mainAxisSize: MainAxisSize.min,
          children: [for (final z in ['寅', '丑', '子', '亥']) cell(z)]),
    ]);
  }

  Widget _stage(int i, DaLiuRenResult r) {
    final zhi = r.shiYong[i];
    final dun = r.chuanDunGan.isNotEmpty ? r.chuanDunGan[i] : '';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: _border),
      ),
      child: Column(children: [
        Text(['初传', '中传', '末传'][i],
            style: const TextStyle(
                fontSize: 8.5, fontWeight: FontWeight.bold, color: _gold)),
        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(zhi,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: _text)),
          Text(_zhiWx[zhi] ?? '',
              style: const TextStyle(fontSize: 7.5, color: _sub)),
          if (dun.isNotEmpty && dun != '空')
            Text('$dun',
                style: const TextStyle(fontSize: 7.5, color: _sub)),
        ]),
        Text('${_jiangOf(r, zhi)}·${r.chuanLiuQin[i]}',
            style: const TextStyle(fontSize: 8, color: _text)),
      ]),
    );
  }

  String _jiangOf(DaLiuRenResult r, String tianPanZhi) {
    final pos = r.tianPan.indexOf(tianPanZhi);
    if (pos < 0) return '';
    return _jiangShort[r.tianJiang[pos]] ?? r.tianJiang[pos];
  }
}

// ═══════════════════ 小六壬模板 ═══════════════════

/// 小六壬紧凑截图：起课信息 → 三落位 → 落位详解 → 六掌诀速查 → 断语建议
class XiaoLiuRenScreenshotTemplate extends StatelessWidget {
  final String timeText;
  final String lunarText;
  final XiaoLiuRenResult result;

  const XiaoLiuRenScreenshotTemplate({
    super.key,
    required this.timeText,
    this.lunarText = '',
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final r = result;
    final palm = r.resultPalm;
    return _shell(
      title: '小六壬 · ${palm.name}',
      timeText: timeText,
      infoTags: [
        if (lunarText.isNotEmpty) lunarText,
        '起课 ${r.month}月${r.day}日 ${_zhiCN[r.hour]}时',
        '方式 ${r.method}',
      ],
      children: [
        // ── 三落位 ──
        Row(children: [
          Expanded(child: _StageCard(label: '月', palm: r.monthPalm)),
          const SizedBox(width: 4),
          Expanded(child: _StageCard(label: '日', palm: r.dayPalm)),
          const SizedBox(width: 4),
          Expanded(child: _StageCard(label: '终', palm: r.resultPalm, highlight: true)),
        ]),
        const SizedBox(height: 6),

        // ── 落位详解 ──
        _sectionTitle('落位详解（${palm.name}）'),
        _card(children: [
          _line('五行方位', '${palm.element} · ${palm.direction}'),
          _line('吉凶', '${palm.goodBad}　'
              '（${palm.goodBad == '吉' ? '主顺遂、可为' : '主阻滞、宜守'}）'),
          _line('象义', palm.meaning),
          _line('断语', palm.advice),
        ]),
        const SizedBox(height: 6),

        // ── 六掌诀速查 ──
        _sectionTitle('六掌诀速查', '大安→留连→速喜→赤口→小吉→空亡'),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: _border),
          ),
          child: Table(
            border: TableBorder.all(color: _border, width: 0.5),
            columnWidths: const {
              0: FixedColumnWidth(34),
              1: FixedColumnWidth(26),
              2: FixedColumnWidth(24),
              3: FlexColumnWidth(1),
            },
            children: [
              TableRow(decoration: BoxDecoration(color: _gold.withAlpha(20)), children: [
                _cell('掌诀', sub: true),
                _cell('五行', sub: true),
                _cell('吉凶', sub: true),
                _cell('象义概要', sub: true, align: TextAlign.left),
              ]),
              for (final p in xiaoliurenPalms)
                TableRow(
                  decoration: BoxDecoration(
                    color: p.index == r.resultPos ? _gold.withAlpha(26) : null,
                  ),
                  children: [
                    _cell(p.name, bold: p.index == r.resultPos),
                    _cell(p.element, sub: true),
                    _cell(p.goodBad,
                        color: p.goodBad == '吉'
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828)),
                    _cell(p.meaning.split('。').first, small: true,
                        align: TextAlign.left),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // ── 断课要点 ──
        _sectionTitle('断课要点'),
        _card(children: [
          _line('用神', '以最终落位「${palm.name}」为断，兼看月/日落位所指之事类', width: 34),
          _line('起课', '月落${r.monthPalm.name} → 日落${r.dayPalm.name} → '
              '时顺数落${palm.name}（${r.month}月${r.day}日 ${_zhiCN[r.hour]}时）', width: 34),
          _line('参考', '小六壬以农历月日起课，六掌诀循环；吉凶为倾向性提示，'
              '重大决定仍须理性判断', width: 34),
        ]),
      ],
    );
  }

  Widget _cell(String text,
      {bool bold = false, bool sub = false, bool small = false, Color? color,
      TextAlign? align}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      child: Text(text,
          textAlign: align ?? TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: small ? 7.5 : 8.5,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: color ?? (sub ? _sub : _text.withAlpha(225)),
          )),
    );
  }

  static const _zhiCN = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
}

/// 小六壬单个落位卡片
class _StageCard extends StatelessWidget {
  final String label;
  final XiaoLiuRenName palm;
  final bool highlight;

  const _StageCard({
    required this.label,
    required this.palm,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: highlight ? _gold.withAlpha(26) : _cardBg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: highlight ? _gold : _border),
      ),
      child: Column(children: [
        Text(label, style: const TextStyle(fontSize: 8.5, color: _sub)),
        Text(palm.name,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: _text)),
        Text(
          '${palm.element}·${palm.goodBad}',
          style: TextStyle(
            fontSize: 8.5,
            color: palm.goodBad == '吉'
                ? const Color(0xFF2E7D32)
                : const Color(0xFFC62828),
          ),
        ),
      ]),
    );
  }
}
