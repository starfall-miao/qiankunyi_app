// 落·乾坤 - 大六壬排盘页（基础版）
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../../calendar/views/calendar_picker_dialog.dart';
import '../../cases/providers/case_provider.dart';
import '../../settings/settings_provider.dart';
import '../../cases/models/case_models.dart';
import 'package:tyme/tyme.dart' as tyme;
import '../engines/liuyao_date_helper.dart';
import '../../../shared/widgets/save_image_dialog.dart';

import "../engines/daliuren_engine.dart";

// 兼容旧引用：引擎与常量已拆分到 engines/daliuren_engine.dart
export "../engines/daliuren_engine.dart"
    show daliurenZhi, daliurenYueJiang, daliurenGenerals,
        DaLiuRenEngine, DaLiuRenResult;

const daliurenZhiDetail = {
  '子': ('水', '北方', '聪明流动，藏癸水', '孩童、妇女、水性人；利智谋财帛', '利财智，防暗耗'),
  '丑': ('土', '东北', '晦暗之库，藏己癸辛', '田产、库房、老人；利守成置业', '稳中有滞，防郁结'),
  '寅': ('木', '东北', '刚毅阳木，藏甲丙戊', '公门、车马、壮年男；利开创官讼', '奋发，利开创'),
  '卯': ('木', '东方', '柔顺阴木，藏乙', '门庭、舟车、文士；利婚嫁文书', '顺遂，利合作'),
  '辰': ('土', '东南', '水库，藏戊乙癸', '龙潭、牢狱、渔人；利积蓄防争讼', '藏机，宜蓄势'),
  '巳': ('火', '东南', '驿马阳火，藏丙戊庚', '驿路、炉冶、远行客；利出行变动', '动变，利出行'),
  '午': ('火', '南方', '明丽阳火，藏丁己', '文书、殿堂、文秀；利名声升迁', '光明，防急躁'),
  '未': ('土', '西南', '木库，藏己丁乙', '园林、酒食、妇人；利宴乐积累', '平缓，利积累'),
  '申': ('金', '西南', '肃杀阳金，藏庚壬戊', '道路、兵戈、武人；利决断争胜', '果断，防锋芒'),
  '酉': ('金', '西方', '娇艳阴金，藏辛', '刀剑、珠玉、少女；利婚配修饰', '精致，防固执'),
  '戌': ('土', '西北', '火库，藏戊辛丁', '城墙、狱牢、僧道；利收敛防灾', '收敛，宜守成'),
  '亥': ('水', '西北', '汪洋阴水，藏壬甲', '江海、舟楫、谋士；利流通远谋', '润泽，利流动'),
};

class DaLiuRenPage extends StatefulWidget {
  const DaLiuRenPage({super.key});
  @override
  State<DaLiuRenPage> createState() => _DaLiuRenPageState();
}

class _DaLiuRenPageState extends State<DaLiuRenPage> {
  int _year = DateTime.now().year;
  int _month = DateTime.now().month;
  int _day = DateTime.now().day;
  int _hour = 0;
  int _dayGan = 0; // 甲
  int _dayZhi = 0; // 子
  /// 子时归属：true=晚子（23-24，日柱用次日），false=早子（0-1，当日）
  bool _lateZi = true;
  static const _ganCN = ['甲','乙','丙','丁','戊','己','庚','辛','壬','癸'];
  DaLiuRenResult? _result;
  final _shotKey = GlobalKey();

  static const _hours = ['子时', '丑时', '寅时', '卯时', '辰时', '巳时',
    '午时', '未时', '申时', '酉时', '戌时', '亥时'];

  /// 用当前时间起课：自动定月份、时辰与日干支
    /// 选择日期起课：自动定月份/时辰/日干支
  void _pickDate() async {
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (_) => const CalendarPickerDialog(),
    );
    if (picked == null || !mounted) return;
    final solar = tyme.SolarDay.fromYmd(picked.year, picked.month, picked.day);
    final gz = dayGanZhiFromTyme(solar);
    final g = gz.isNotEmpty ? gz[0] : '甲';
    final zhi = gz.length > 1 ? gz[1] : '子';
    setState(() {
      _year = picked.year;
      _month = picked.month;
      _day = picked.day;
      _dayGan = _ganCN.indexOf(g);
      if (_dayGan < 0) _dayGan = 0;
      _dayZhi = daliurenZhi.indexOf(zhi);
      if (_dayZhi < 0) _dayZhi = 0;
    });
  }

  void _useNow() {
    final now = DateTime.now();
    final hourIdx = (now.hour == 23 || now.hour == 0)
        ? 0
        : ((now.hour + 1) ~/ 2) % 12;
    // 晚子时换日：23:00 后日柱取次日（受设置开关控制）
    final lateZi = now.hour >= 23;
    final wanZiShi = context.read<SettingsProvider>().wanZiShi;
    var solar = tyme.SolarDay.fromYmd(now.year, now.month, now.day);
    if (hourIdx == 0 && lateZi && wanZiShi) solar = solar.next(1);
    final gz = dayGanZhiFromTyme(solar);
    final g = gz.isNotEmpty ? gz[0] : '甲';
    final zhi = gz.length > 1 ? gz[1] : '子';
    setState(() {
      _year = now.year;
      _month = now.month;
      _day = now.day;
      _hour = hourIdx;
      _lateZi = lateZi;
      _dayGan = _ganCN.indexOf(g);
      if (_dayGan < 0) _dayGan = 0;
      _dayZhi = daliurenZhi.indexOf(zhi);
      if (_dayZhi < 0) _dayZhi = 0;
    });
  }

  void _calc() {
    // 晚子时换日（设置项）：子时且选「晚子」时，日柱与月将按次日取
    final wanZiShi = context.read<SettingsProvider>().wanZiShi;
    final baseDate = DateTime(_year, _month, _day);
    final useNextDay = _hour == 0 && _lateZi && wanZiShi;
    final date = useNextDay ? baseDate.add(const Duration(days: 1)) : baseDate;
    // 月将按**中气**换将（雨水后登明…大寒后神后），取起课日最近一个中气
    final yueJiangIdx = DaLiuRenEngine.yueJiangOf(date);
    final solar = tyme.SolarDay.fromYmd(date.year, date.month, date.day);
    final monthGz = monthGanZhiFromTyme(solar);
    final monthZhi = monthGz.length > 1 ? monthGz[1] : '';
    final monthZhiIdx = daliurenZhi.indexOf(monthZhi);
    // 日干支：手动选日期时以所选日为准；晚子换日时用次日
    final daySolar =
        useNextDay ? tyme.SolarDay.fromYmd(_year, _month, _day).next(1)
                   : tyme.SolarDay.fromYmd(_year, _month, _day);
    final gz = dayGanZhiFromTyme(daySolar);
    final g = _ganCN.indexOf(gz.isNotEmpty ? gz[0] : '甲');
    final zh = daliurenZhi.indexOf(gz.length > 1 ? gz[1] : '子');
    setState(() {
      _dayGan = g >= 0 ? g : 0;
      _dayZhi = zh >= 0 ? zh : 0;
      _result = DaLiuRenEngine.byHour(
        _hour, date.month,
        dayGan: _ganCN[_dayGan],
        dayZhi: daliurenZhi[_dayZhi],
        monthZhiIdx: monthZhiIdx >= 0 ? monthZhiIdx : null,
        yueJiangIdx: yueJiangIdx,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).colorScheme.primary;
    final t = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2);
    final b = isDark ? const Color(0xFF444444) : const Color(0xFFE0D5C8);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('大六壬（入门版）', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('大六壬为三式之一，以月将加时、天地盘、四课三传断吉凶。'
            '已支持月将（按节气中气换将）、月将加时、四课、十二天将按贵人排布。\n'
            '⚠️ 三传为入门级简化取法（初传取日干上神，中末传顺行），'
            '未按贼克/比用/涉害/遥克/昴星等九宗门起课，仅供学习参考。',
            style: TextStyle(fontSize: 12, height: 1.6, color: t.withAlpha(160))),
        const SizedBox(height: 12),
        // 输入区 Card（与六爻梅花一致）
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
        // 使用当前时间（只填入数据，不自动排盘）
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _useNow,
            icon: const Icon(Icons.schedule, size: 16),
            label: const Text('使用当前时间', style: TextStyle(fontSize: 13)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // 日期选择（与小六壬一致的样式）
        InkWell(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: b.withAlpha(80)),
            ),
            child: Row(children: [
              Icon(Icons.calendar_today_outlined, size: 18, color: p),
              const SizedBox(width: 10),
              Text('$_year年$_month月$_day日',
                  style: TextStyle(fontSize: 15, color: t)),
              const Spacer(),
              Icon(Icons.arrow_drop_down, color: t.withAlpha(120)),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        // 日干支选择
        Text('日干支（定四课）', style: TextStyle(fontSize: 12, color: t.withAlpha(150))),
        const SizedBox(height: 6),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List.generate(10, (i) {
            final sel = _dayGan == i;
            return ChoiceChip(
              label: Text(_ganCN[i], style: TextStyle(fontSize: 11, color: sel ? p : t)),
              selected: sel,
              onSelected: (_) => setState(() => _dayGan = i),
              selectedColor: p.withAlpha(40),
              backgroundColor: bg,
              side: BorderSide(color: sel ? p : b, width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              visualDensity: VisualDensity.compact,
            );
          }),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List.generate(12, (i) {
            final sel = _dayZhi == i;
            return ChoiceChip(
              label: Text(daliurenZhi[i], style: TextStyle(fontSize: 11, color: sel ? p : t)),
              selected: sel,
              onSelected: (_) => setState(() => _dayZhi = i),
              selectedColor: p.withAlpha(40),
              backgroundColor: bg,
              side: BorderSide(color: sel ? p : b, width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              visualDensity: VisualDensity.compact,
            );
          }),
        ),
        const SizedBox(height: 10),
        // 月份选择（ChoiceChip）
        Text('月份（定月将）', style: TextStyle(fontSize: 12, color: t.withAlpha(150))),
        const SizedBox(height: 6),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List.generate(12, (i) {
            final sel = _month == i + 1;
            return ChoiceChip(
              label: Text('${i + 1}月', style: TextStyle(fontSize: 11, color: sel ? p : t)),
              selected: sel,
              onSelected: (_) => setState(() => _month = i + 1),
              selectedColor: p.withAlpha(40),
              backgroundColor: bg,
              side: BorderSide(color: sel ? p : b, width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              visualDensity: VisualDensity.compact,
            );
          }),
        ),
        const SizedBox(height: 10),
        Text('时辰', style: TextStyle(fontSize: 12, color: t.withAlpha(150))),
        const SizedBox(height: 6),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List.generate(12, (i) {
            final sel = _hour == i;
            // 时辰加 24 时标注（与其他排盘一致）
            const ranges = ['23-01', '01-03', '03-05', '05-07', '07-09', '09-11',
                            '11-13', '13-15', '15-17', '17-19', '19-21', '21-23'];
            return ChoiceChip(
              label: Text('${_hours[i].replaceAll('时', '')} ${ranges[i]}',
                  style: TextStyle(fontSize: 10.5, color: sel ? p : t)),
              selected: sel,
              onSelected: (_) => setState(() => _hour = i),
              selectedColor: p.withAlpha(40),
              backgroundColor: bg,
              side: BorderSide(color: sel ? p : b, width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              visualDensity: VisualDensity.compact,
            );
          }),
        ),
              // 子时归属（仅子时显示）：晚子（23-24，日柱用次日）/ 早子（0-1，当日）
              if (_hour == 0) ...[
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 4, children: [
                  ChoiceChip(
                    label: Text('晚子 23-24（日柱用次日）',
                        style: TextStyle(fontSize: 11, color: _lateZi ? p : t)),
                    selected: _lateZi,
                    onSelected: (_) => setState(() => _lateZi = true),
                    selectedColor: p.withAlpha(40),
                    backgroundColor: bg,
                    side: BorderSide(color: _lateZi ? p : b, width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    visualDensity: VisualDensity.compact,
                  ),
                  ChoiceChip(
                    label: Text('早子 0-1（用当日日柱）',
                        style: TextStyle(fontSize: 11, color: !_lateZi ? p : t)),
                    selected: !_lateZi,
                    onSelected: (_) => setState(() => _lateZi = false),
                    selectedColor: p.withAlpha(40),
                    backgroundColor: bg,
                    side: BorderSide(color: !_lateZi ? p : b, width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    visualDensity: VisualDensity.compact,
                  ),
                ]),
              ],

              ],  // Card 内 Column children
            ),  // Column
          ),  // Padding
        ),  // Card
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _calc,
          icon: const Icon(Icons.auto_awesome),
          label: const Text('排盘'),
          style: ElevatedButton.styleFrom(backgroundColor: p, foregroundColor: Colors.white),
        ),
        const SizedBox(height: 12),
        // 结果（淡入动画）
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOut,
          child: _result != null
              ? KeyedSubtree(
                  key: ValueKey(_result),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          RepaintBoundary(
            key: _shotKey,
            child: Card(
              child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // ── 标题 ──
                Row(children: [
                  Icon(Icons.auto_awesome, size: 16, color: p),
                  const SizedBox(width: 6),
                  Text('大六壬排盘',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: p)),
                  const Spacer(),
                  Text('${_ganCN[_dayGan]}${daliurenZhi[_dayZhi]}日 · ${_hours[_result!.hourIndex]}',
                      style: TextStyle(fontSize: 11, color: t.withAlpha(140))),
                ]),
                const SizedBox(height: 10),

                // ══ 一、起课 ══
                _sectionTitle('一、起课', '月将加时起课，先定月将、贵人、昼夜', p, t),
                _infoCard(bg, b, children: [
                  _infoLine('干支', '${_ganCN[_dayGan]}${daliurenZhi[_dayZhi]}日 · ${_hours[_result!.hourIndex]}（${_hourRange(_result!.hourIndex)}）', t),
                  _infoLine('月将', '${daliurenYueJiang[_result!.yueJiang]}（${_result!.yueJiangZhi}将）加于 ${daliurenZhi[_result!.hourIndex]}（${_result!.method}）', t),
                  _infoLine('昼夜贵人', '${_isDayHour(_result!.hourIndex) ? "昼占（卯-申）用阳贵" : "夜占（酉-寅）用阴贵"} → 贵人临 ${_result!.guiRen}', t),
                  _infoLine('天将布法', '贵人所临地盘 ${_result!.guiRenGong} 位为${_result!.guiRenGong == '子' || _isYangGong(_result!.guiRenGong) ? "阳位→顺布" : "阴位→逆布"}', t),
                  _infoLine('课体', '${_result!.chuanFa}｜四课关系：${[
                    for (var i = 0; i < _result!.keRelation.length; i++)
                      '${i + 1}课${_result!.keRelation[i]}'
                  ].join(' ')}', t),
                ]),
                const SizedBox(height: 12),

                // ══ 二、天地盘 ══
                _sectionTitle('二、天地盘（十二宫）', '下为地盘定位，上为天盘加临，右侧为所临天将', p, t),
                _tianPanBoard(_result!, p, t, bg, b),
                const SizedBox(height: 12),

                // ══ 三、四课 ══
                _sectionTitle('三、四课', '一课日阳 · 二课日阴 · 三课辰阳 · 四课辰阴（贼=下克上，克=上克下）', p, t),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var i = 0; i < 4; i++)
                      _ke(
                        ['一课·日阳', '二课·日阴', '三课·辰阳', '四课·辰阴'][i],
                        _result!.siKeShang[i],
                        p, t, bg, b,
                        info: [
                          '日干阳神：自身现状、主导',
                          '日干阴神：自身内在/同盟',
                          '日支阳神：所测之事与环境',
                          '日支阴神：事之内情/他人',
                        ][i],
                        subtitle: '下 ${_result!.siKeXia[i]}'
                            '${_result!.keRelation[i] != '—' ? ' · ${_result!.keRelation[i]}' : ''}'
                            ' · ${_result!.keLiuQin[i]}',
                        badge: DaLiuRenEngine.tianJiangOf(_result!, _result!.siKeShang[i]),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // ══ 四、三传 ══
                Row(children: [
                  Expanded(
                    child: _sectionTitle('四、三传',
                        '初传为事之始 · 中传为发展 · 末传为归宿', p, t, tight: true),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: p.withAlpha(20),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(_result!.chuanFa,
                        style: TextStyle(fontSize: 10.5, color: p)),
                  ),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  for (var i = 0; i < 3; i++) ...[
                    Expanded(
                      child: _chuan(
                        ['初传', '中传', '末传'][i],
                        _result!.shiYong[i],
                        p, t, bg, b,
                        info: ['事之始：起因、开端', '事之中：发展过程', '事之终：结果、归宿'][i],
                        general: _chuanTianJiang(
                            ['初', '中', '末'][i], _result!.shiYong[i], _result!),
                        liuQin: _result!.chuanLiuQin[i],
                      ),
                    ),
                    if (i < 2) const SizedBox(width: 8),
                  ],
                ]),
                if (_result!.quChuanNote.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: p.withAlpha(10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('取传：${_result!.quChuanNote}',
                        style: TextStyle(fontSize: 10.5, height: 1.6, color: t.withAlpha(170))),
                  ),
                ],
                const SizedBox(height: 12),

                // ══ 五、断课提示 ══
                _sectionTitle('五、断课提示', '以下为常见取象要点，仅供入门参考', p, t),
                _infoCard(bg, b, children: [
                  for (final hint in _duanKeHints(_result!))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('· ', style: TextStyle(fontSize: 11.5, color: p)),
                        Expanded(
                          child: Text(hint,
                              style: TextStyle(fontSize: 11, height: 1.6, color: t.withAlpha(190))),
                        ),
                      ]),
                    ),
                ]),
              ]),
            ),
          ),
        ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: _saveCase,
                  icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                  label: const Text('保存卦例'),
                  style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton.icon(
                  onPressed: _saveImage,
                  icon: const Icon(Icons.image_outlined, size: 16),
                  label: const Text('保存图片'),
                  style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton.icon(
                  onPressed: _share,
                  icon: const Icon(Icons.share_outlined, size: 16),
                  label: const Text('分享'),
                  style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => setState(() => _result = null),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('清空'),
                  style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
                ),
              ),
            ]),
                  ]),
                )
              : const SizedBox.shrink(),
        ),
      ]),
    );
  }

  /// 保存卦例到卦例库
  void _saveCase() {
    final r = _result;
    if (r == null) return;
    // 与六爻一致的保存弹窗：可填标题/占问对象/事件/备注
    final titleCtrl =
        TextEditingController(text: '大六壬 · ${r.chuChuan}传');
    final notesCtrl = TextEditingController();
    final askObjectCtrl = TextEditingController();
    final askEventCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('保存卦例'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: '标题', hintText: '为卦例取个名字'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: askObjectCtrl,
                decoration: const InputDecoration(labelText: '占问对象（可选）', hintText: '如：朋友 / 家人 / 工作 / 房贷'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: askEventCtrl,
                decoration: const InputDecoration(labelText: '占问事件（可选）', hintText: '如：是否应该换工作'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(labelText: '备注（可选）', hintText: '补充说明'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final cm = CaseModel(
                id: DateTime.now().millisecondsSinceEpoch,
                title: titleCtrl.text.trim().isEmpty
                    ? '大六壬 · ${r.chuChuan}传'
                    : titleCtrl.text.trim(),
                guaName: '大六壬',
                guaGong: r.chuChuan,
                method: '大六壬（${r.method}）',
                paipanData: '{"daLiuRen":${_jsonEncode(r)}}',
                askObject: askObjectCtrl.text.trim().isEmpty ? null : askObjectCtrl.text.trim(),
                askEvent: askEventCtrl.text.trim().isEmpty ? null : askEventCtrl.text.trim(),
                notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                caseType: CaseType.liuyao,
              );
              context.read<CaseProvider>().addCase(cm);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已保存到卦例库')),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 结果详解弹窗

  /// 分享结果到剪贴板
  Future<void> _share() async {
    final r = _result;
    if (r == null) return;
    final buf = StringBuffer()
      ..writeln('【落·乾坤】大六壬排盘结果')
      ..writeln('━━━━━━━━━━━━━━')
      ..writeln('月将：${daliurenYueJiang[r.yueJiang]}（临${r.yueJiangZhi} · ${r.method}）')
      ..writeln('三传：初传${r.chuChuan} → 中传${r.zhongChuan} → 末传${r.moChuan}')
      ..writeln('四课：${[
        for (var i = 0; i < 4; i++) '${i + 1}课 ${r.siKeShang[i]}/${r.siKeXia[i]}'
      ].join('  ')}')
      ..writeln('取传法：${r.chuanFa}')
      ..writeln('贵人：${r.guiRen}（临地盘${r.guiRenGong}位，天将${r.shunBu ? "顺布" : "逆布"}）')
      ..writeln('三传天将：${_chuanTianJiang('', r.chuChuan, r).trim()} / ${_chuanTianJiang('', r.zhongChuan, r).trim()} / ${_chuanTianJiang('', r.moChuan, r).trim()}')
      ..writeln('━━━━━━━━━━━━━━')
      ..writeln('—— 来自「落·乾坤」');
    await Clipboard.setData(ClipboardData(text: buf.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('排盘结果已复制到剪贴板'), duration: Duration(seconds: 2)),
      );
    }
  }

  String _jsonEncode(DaLiuRenResult r) {
    final m = r.toJson();
    return m.entries.map((e) => '"${e.key}":${jsonEncode(e.value)}').join(',');
  }

  /// 保存结果图片
  Future<void> _saveImage() async {
    try {
      final boundary =
          _shotKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();
      if (!mounted) return;
      final savedPath = await saveImageWithDialog(
        context: context,
        pngBytes: pngBytes,
        defaultFileName: buildImageFileName('大六壬_三传'),
      );
      if (savedPath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('图片已保存: $savedPath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存图片失败: $e')),
        );
      }
    }
  }

  /// 某传支所临天将（地支索引 → 天将）
  String _chuanTianJiang(String label, String zhi, DaLiuRenResult r) {
    final idx = daliurenZhi.indexOf(zhi);
    final gi = idx >= 0 ? idx : 0;
    return '$label $zhi·${r.tianJiang[gi]}';
  }

  /// 传统天地盘：12 个框填十二地支（地盘固定），再填天盘（月将加时）
  // ══════════ 盘面布局辅助 ══════════

  /// 小节标题（带序号）：主标题 + 灰字说明
  Widget _sectionTitle(String title, String desc, Color p, Color t,
      {bool tight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(width: 3, height: 13, color: p),
          const SizedBox(width: 6),
          Text(title,
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: t)),
        ]),
        if (!tight) ...[
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 9),
            child: Text(desc,
                style: TextStyle(fontSize: 10, height: 1.4, color: t.withAlpha(120))),
          ),
        ],
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _infoCard(Color bg, Color b, {required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: b.withAlpha(80)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _infoLine(String label, String value, Color t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 62,
          child: Text(label,
              style: TextStyle(fontSize: 11, color: t.withAlpha(130))),
        ),
        Expanded(
          child: Text(value,
              style: TextStyle(fontSize: 11.5, height: 1.5, color: t.withAlpha(210))),
        ),
      ]),
    );
  }

  /// 时辰对应的 24 小时区间
  String _hourRange(int h) {
    const ranges = ['23-01', '01-03', '03-05', '05-07', '07-09', '09-11',
      '11-13', '13-15', '15-17', '17-19', '19-21', '21-23'];
    return ranges[h];
  }

  /// 昼占：卯至申（索引 3-8）
  bool _isDayHour(int h) => h >= 3 && h <= 8;

  /// 地支阴阳（子丑寅卯辰巳为阳位）
  bool _isYangGong(String zhi) {
    final idx = daliurenZhi.indexOf(zhi);
    return idx >= 0 && idx % 2 == 0;
  }

  /// 天地盘十二宫（地盘 / 天盘 / 天将），标注时支宫与贵人宫
  Widget _tianPanBoard(DaLiuRenResult r, Color p, Color t, Color bg, Color b) {
    final hourIdx = r.hourIndex;
    final guiGong = daliurenZhi.indexOf(r.guiRenGong);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: b.withAlpha(80)),
      ),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final cols = constraints.maxWidth >= 520 ? 6 : 4;
          return Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (var i = 0; i < 12; i++)
                SizedBox(
                  width: (constraints.maxWidth - (cols - 1) * 4) / cols - 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == hourIdx
                          ? p.withAlpha(28)
                          : (i == guiGong ? const Color(0xFF6A1B9A).withAlpha(18) : Colors.transparent),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: i == hourIdx
                            ? p
                            : (i == guiGong
                                ? const Color(0xFF6A1B9A).withAlpha(120)
                                : b.withAlpha(60)),
                        width: i == hourIdx || i == guiGong ? 1.2 : 0.6,
                      ),
                    ),
                    child: Column(children: [
                      Text('地${daliurenZhi[i]}',
                          style: TextStyle(fontSize: 9, color: t.withAlpha(130))),
                      Text(r.tianPan[i],
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold, color: p)),
                      Text(r.tianJiang[i],
                          style: TextStyle(fontSize: 9.5, color: t.withAlpha(190))),
                      if (i == hourIdx)
                        Text('时',
                            style: TextStyle(fontSize: 8, color: p)),
                      if (i == guiGong)
                        const Text('贵',
                            style: TextStyle(fontSize: 8, color: Color(0xFF6A1B9A))),
                    ]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// 断课提示（规则化要点，非断语结论）
  List<String> _duanKeHints(DaLiuRenResult r) {
    final hints = <String>[];
    // 课体
    if (r.chuanFa.contains('伏吟')) {
      hints.add('伏吟课：天地盘重合，主静、主迟滞，事多原地不动或旧事重提，宜守不宜进。');
    } else if (r.chuanFa.contains('返吟')) {
      hints.add('返吟课：天地盘全冲，主动、主反复，事多变故、来回翻覆，宜静观其变。');
    } else if (r.chuanFa.contains('八专')) {
      hints.add('八专课：日干寄宫与日支同位，主私情、暧昧，事多牵连自身。');
    } else if (r.chuanFa.contains('别责')) {
      hints.add('别责课：四课不全，主事不顺、须借外力方成。');
    } else if (r.chuanFa.contains('昴星')) {
      hints.add('昴星课：无克无遥，主事由他动、被动应对，宜守。');
    } else if (r.chuanFa.contains('涉害')) {
      hints.add('涉害课：克多而取涉害深者为用，主事涉多方纠葛，须细辨主次。');
    } else if (r.chuanFa.contains('比用')) {
      hints.add('比用课：多课相克而取与日干比者为用，主事有同类相争，择其近者。');
    } else if (r.chuanFa.contains('贼克')) {
      hints.add('贼克课：以克取用，主事有约束冲击，忌硬碰、宜化解。');
    } else if (r.chuanFa.contains('遥克')) {
      hints.add('遥克课：无近克而取遥克，主事隔位相制，影响间接。');
    }
    // 三传天将吉凶统计
    var jiCount = 0;
    var xiongCount = 0;
    String generalOf(String chuan) {
      final diPos = daliurenZhi.indexOf(chuan);
      if (diPos < 0) return '';
      return r.tianJiang[diPos];
    }

    final generals = [generalOf(r.chuChuan), generalOf(r.zhongChuan), generalOf(r.moChuan)];
    for (final g in generals) {
      final info = daliurenGenerals.where((e) => e.$1 == g);
      if (info.isEmpty) continue;
      if (info.first.$2 == '吉') {
        jiCount++;
      } else {
        xiongCount++;
      }
    }
    hints.add('三传天将：${generals.join(' → ')}（吉 $jiCount / 凶 $xiongCount）'
        '${jiCount > xiongCount ? '，吉多凶少，事可为' : (xiongCount > jiCount ? '，凶多吉少，宜谨慎' : '，吉凶相当')}。');
    // 贵人
    hints.add('贵人临地盘 ${r.guiRenGong} 位（${r.guiRen}）：'
        '${_isYangGong(r.guiRenGong) ? '阳位顺布，贵人明助' : '阴位逆布，贵人暗助'}；'
        '所临之宫即为贵人所主之事类。');
    // 时支与月将
    hints.add('月将 ${r.yueJiangZhi} 加临 ${daliurenZhi[r.hourIndex]} 时：'
        '时支 ${daliurenZhi[r.hourIndex]} 为事之应期支，'
        '初传 ${r.chuChuan} 与末传 ${r.moChuan} 的生克可看事之始终。');
    return hints;
  }





  /// 地支详解弹窗（点击三传/四课触发）
  void _showZhiDetail(String label, String zhi,
      {String? info, String? general, String? liuQin}) {
    final d = daliurenZhiDetail[zhi];
    final r = _result;

    // ── 本次课中的信息 ──
    final ctxRows = <Widget>[];
    if (r != null) {
      final dayGan = _ganCN[_dayGan];
      final dayGanWx = const {
        '甲': '木', '乙': '木', '丙': '火', '丁': '火', '戊': '土',
        '己': '土', '庚': '金', '辛': '金', '壬': '水', '癸': '水',
      }[dayGan]!;
      final zhiWx = const {
        '子': '水', '丑': '土', '寅': '木', '卯': '木', '辰': '土', '巳': '火',
        '午': '火', '未': '土', '申': '金', '酉': '金', '戌': '土', '亥': '水',
      }[zhi]!;
      final qin = liuQin ?? DaLiuRenEngine.liuQinOf(dayGan, zhi);
      final jiang = (general != null && general.isNotEmpty)
          ? general
          : DaLiuRenEngine.tianJiangOf(r, zhi);
      final diPos = daliurenZhi.indexOf(zhi);
      final tianPos = r.tianPan.indexOf(zhi);

      // 与日干的生克
      const sheng = {'木': '火', '火': '土', '土': '金', '金': '水', '水': '木'};
      const ke = {'木': '土', '土': '水', '水': '火', '火': '金', '金': '木'};
      String rela;
      if (dayGanWx == zhiWx) {
        rela = '比和（同$zhiWx）';
      } else if (sheng[dayGanWx] == zhiWx) {
        rela = '日干$dayGanWx生$zhiWx（我生，泄气）';
      } else if (sheng[zhiWx] == dayGanWx) {
        rela = '$zhiWx生日干$dayGanWx（生我，受益）';
      } else if (ke[dayGanWx] == zhiWx) {
        rela = '日干$dayGanWx克$zhiWx（我克，所掌之事）';
      } else {
        rela = '$zhiWx克日干$dayGanWx（克我，受制）';
      }

      // 在本课中的角色
      final roles = <String>[];
      for (var i = 0; i < 4; i++) {
        if (r.siKeShang[i] == zhi) roles.add('${i + 1}课上神');
        if (r.siKeXia[i] == zhi) roles.add('${i + 1}课下神');
      }
      for (var i = 0; i < 3; i++) {
        if (r.shiYong[i] == zhi) roles.add(['初传', '中传', '末传'][i]);
      }
      if (r.guiRen == zhi) roles.add('贵人');

      // 与其他三传支的刑冲合
      const chong = {
        '子': '午', '午': '子', '丑': '未', '未': '丑', '寅': '申', '申': '寅',
        '卯': '酉', '酉': '卯', '辰': '戌', '戌': '辰', '巳': '亥', '亥': '巳',
      };
      const he = {
        '子': '丑', '丑': '子', '寅': '亥', '亥': '寅', '卯': '戌', '戌': '卯',
        '辰': '酉', '酉': '辰', '巳': '申', '申': '巳', '午': '未', '未': '午',
      };
      final relations = <String>[];
      for (final other in r.shiYong) {
        if (other == zhi) continue;
        if (chong[zhi] == other) relations.add('与$other相冲');
        if (he[zhi] == other) relations.add('与$other六合');
      }

      ctxRows.addAll([
        _kv('六亲', '$qin（以日干$dayGan${dayGanWx}为我）'),
        if (jiang.isNotEmpty) _kv('所临天将', jiang),
        _kv('与日干', rela),
        if (roles.isNotEmpty) _kv('本课角色', roles.join('、')),
        _kv('天地盘',
            '地盘${daliurenZhi[diPos]}位${tianPos >= 0 ? ' · 天盘临地盘${daliurenZhi[tianPos]}宫' : ''}'),
        if (relations.isNotEmpty) _kv('与他支', relations.join('、')),
      ]);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$label · $zhi'),
        content: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            if (info != null) ...[
              Text(info,
                  style: const TextStyle(
                      fontSize: 13, height: 1.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
            ],
            // 本次课中的具体信息
            if (ctxRows.isNotEmpty) ...[
              const Text('📌 本次课中',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...ctxRows,
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
            ],
            // 地支固有属性
            if (d == null)
              const Text('暂无详解')
            else ...[
              Text('五行：${d.$1} · 方位：${d.$2}',
                  style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 8),
              const Text('🪧 类象',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 3),
              Text(d.$3, style: const TextStyle(fontSize: 13, height: 1.6)),
              const SizedBox(height: 8),
              const Text('👥 人事',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 3),
              Text(d.$4, style: const TextStyle(fontSize: 13, height: 1.6)),
              const SizedBox(height: 8),
              const Text('⚖️ 吉凶',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 3),
              Text(d.$5, style: const TextStyle(fontSize: 13)),
            ],
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('关闭')),
        ],
      ),
    );
  }

  /// 详解弹窗内的一行「标签：值」
  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 62,
          child: Text(label,
              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 12.5, height: 1.5)),
        ),
      ]),
    );
  }



  Widget _ke(String label, String zhi, Color p, Color t, Color bg, Color b,
      {String? info, String? subtitle, String? badge}) {
    return GestureDetector(
      onTap: () => _showZhiDetail(label, zhi, info: info),
      child: Container(
        width: (360 - 32) / 2,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: b.withAlpha(80))),
        child: Column(children: [
          Text(label, style: TextStyle(fontSize: 10, color: t.withAlpha(130))),
          const SizedBox(height: 2),
          Text(zhi, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: p)),
          if (badge != null && badge.isNotEmpty) ...[
            const SizedBox(height: 1),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0.5),
              decoration: BoxDecoration(
                color: p.withAlpha(24),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(badge,
                  style: TextStyle(fontSize: 9, color: p)),
            ),
          ],
          if (subtitle != null) ...[
            const SizedBox(height: 1),
            Text(subtitle,
                style: TextStyle(fontSize: 9, color: t.withAlpha(120))),
          ],
          const SizedBox(height: 1),
          Icon(Icons.touch_app, size: 10, color: p.withAlpha(120)),
        ]),
      ),
    );
  }

  Widget _chuan(String label, String zhi, Color p, Color t, Color bg, Color b,
      {String? info, String? general, String? liuQin}) {
    return GestureDetector(
      onTap: () => _showZhiDetail(
        label,
        zhi,
        info: info,
        general: general,
        liuQin: liuQin,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: b.withAlpha(80))),
        child: Column(children: [
          Text(label, style: TextStyle(fontSize: 11, color: t.withAlpha(130))),
          const SizedBox(height: 2),
          Text(zhi,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: p)),
          if (general != null && general.isNotEmpty) ...[
            const SizedBox(height: 1),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0.5),
              decoration: BoxDecoration(
                color: p.withAlpha(24),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(general, style: TextStyle(fontSize: 9, color: p)),
            ),
          ],
          if (liuQin != null && liuQin.isNotEmpty)
            Text(liuQin,
                style: TextStyle(fontSize: 9, color: t.withAlpha(160))),
          Icon(Icons.touch_app, size: 11, color: p.withAlpha(120)),
        ]),
      ),
    );
  }

}
