// 落·乾坤 - 大六壬排盘页（基础版）
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../../cases/providers/case_provider.dart';
import '../../cases/models/case_models.dart';
import 'package:tyme/tyme.dart' as tyme;
import '../engines/liuyao_date_helper.dart';
import '../../../shared/widgets/save_image_dialog.dart';

/// 十二天将（贵人顺序：吉/凶 + 象义）
const daliurenGenerals = [
  ('贵人', '吉', '至尊之象，主贵人相助、尊贵吉祥'),
  ('螣蛇', '凶', '虚惊怪异，主惊扰、缠绕、怪异之事'),
  ('朱雀', '凶', '口舌文书，主言辞、信讯、是非'),
  ('六合', '吉', '和合喜庆，主婚姻、合作、顺利'),
  ('勾陈', '凶', '田土争讼，主纠缠、迟滞、争斗'),
  ('青龙', '吉', '喜庆财帛，主喜庆、得财、吉庆'),
  ('天空', '凶', '虚诈空亡，主欺骗、落空、虚伪'),
  ('白虎', '凶', '凶丧血光，主凶险、疾病、丧事'),
  ('太常', '吉', '酒食宴享，主宴乐、衣服、喜庆'),
  ('玄武', '凶', '盗贼暗昧，主失窃、暗中、暖昧'),
  ('太阴', '吉', '阴私妇人，主暗中相助、女贵'),
  ('天后', '吉', '恩泽庇佑，主恩泽、庇护、柔和'),
];

/// 地支详解（五行/类象/吉凶）
const daliurenZhiDetail = {
  '子': ('水', '北方，聪明流动，藏癸水', '利财智，防暗耗'),
  '丑': ('土', '东北，晦暗之库，藏己癸辛', '稳中有滞，防郁结'),
  '寅': ('木', '东北，刚毅阳木，藏甲丙戊', '奋发，利开创'),
  '卯': ('木', '东方，柔顺阴木，藏乙', '顺遂，利合作'),
  '辰': ('土', '东南，水库，藏戊乙癸', '藏机，宜蓄势'),
  '巳': ('火', '东南，驿马阳火，藏丙戊庚', '动变，利出行'),
  '午': ('火', '南方，明丽阳火，藏丁己', '光明，防急躁'),
  '未': ('土', '西南，木库，藏己丁乙', '平缓，利积累'),
  '申': ('金', '西南，肃杀阳金，藏庚壬戊', '果断，防锋芒'),
  '酉': ('金', '西方，娇艳阴金，藏辛', '精致，防固执'),
  '戌': ('土', '西北，火库，藏戊辛丁', '收敛，宜守成'),
  '亥': ('水', '西北，汪洋阴水，藏壬甲', '润泽，利流动'),
};

/// 十二地支（地盘/月将用）
const daliurenZhi = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];

/// 十二月将（正月起登明）
const daliurenYueJiang = ['登明', '河魁', '从魁', '传送', '小吉', '胜光',
  '太乙', '天罡', '太冲', '功曹', '大吉', '神后'];

/// 大六壬排盘结果（基础：四课三传）
class DaLiuRenResult {
  final int hourIndex;      // 时辰
  final int yueJiang;       // 月将索引(0-11)
  final List<String> shiYong; // 三传（初传/中传/末传）地支
  final String yueJiangZhi; // 月将所临地支
  final List<String> tianPan; // 天盘（月将加时后十二支）
  final List<String> siKe;    // 四课（日干上神/下神/日支上神/下神）
  final String guiRen;        // 贵人（所在天将）
  final List<String> tianJiang; // 十二天将按支排布
  final String chuChuan;    // 初传
  final String zhongChuan;  // 中传
  final String moChuan;     // 末传
  final String method;

  DaLiuRenResult({
    required this.hourIndex,
    required this.yueJiang,
    required this.shiYong,
    required this.yueJiangZhi,
    required this.tianPan,
    required this.siKe,
    required this.guiRen,
    required this.tianJiang,
    required this.chuChuan,
    required this.zhongChuan,
    required this.moChuan,
    required this.method,
  });

  Map<String, dynamic> toJson() => {
        'hourIndex': hourIndex,
        'yueJiang': yueJiang,
        'yueJiangZhi': yueJiangZhi,
        'tianPan': tianPan,
        'siKe': siKe,
        'guiRen': guiRen,
        'tianJiang': tianJiang,
        'shiYong': shiYong,
        'chuChuan': chuChuan,
        'zhongChuan': zhongChuan,
        'moChuan': moChuan,
        'method': method,
      };
}

/// 大六壬引擎（基础简化版）
class DaLiuRenEngine {
  /// 简化起课：以月将加时定三传（不做完整天地盘，供入门展示）
  /// 十二天将顺序（贵人起）
  static const _tiJiangOrd = ['贵人','螣蛇','朱雀','六合','勾陈','青龙','天空','白虎','太常','玄武','太阴','天后'];

  /// 贵人口诀：甲戊庚牛羊、乙己鼠猴乡（阳贵/阴贵）
  static String calcGuiRen(String dayGan, int hourIndex) {
    final isDay = hourIndex < 6; // 子到巳为昼（阳贵），午到亥为夜（阴贵）
    const yang = {'甲':'丑','戊':'丑','庚':'丑','乙':'子','己':'子','丙':'亥','丁':'亥','壬':'卯','癸':'卯','辛':'午'};
    const yin = {'甲':'未','戊':'未','庚':'未','乙':'申','己':'申','丙':'酉','丁':'酉','壬':'巳','癸':'巳','辛':'寅'};
    return (isDay ? yang[dayGan] : yin[dayGan]) ?? '丑';
  }

  /// 日干寄宫（甲寅乙辰丙戊巳，丁己未，庚申辛戌，壬子癸丑）
  static const _ganJiGong = {
    '甲': 2, '乙': 4, '丙': 5, '丁': 7, '戊': 5,
    '己': 7, '庚': 8, '辛': 10, '壬': 0, '癸': 1,
  };

  static DaLiuRenResult byHour(int hourIndex, int month,
      {String dayGan = '甲', String dayZhi = '子'}) {
    final yueJiang = (month - 1) % 12; // 月将
    // 月将地支（登明=亥…神后=子）
    final yueJiangZhi = daliurenZhi[(11 - yueJiang) % 12];
    // 天盘：月将加时，月将落到时支上，其余顺排
    final tianPan = List.generate(12, (i) {
      final j = (i - hourIndex + 12) % 12;
      final diZhiIdx = (11 - yueJiang + j) % 12;
      return daliurenZhi[diZhiIdx];
    });
    // 三传简化推算：从月将顺数时辰取初传，再顺数得中传、末传
    // 贵人 + 十二天将排布（贵人支起顺布）
    final guiRen = calcGuiRen(dayGan, hourIndex);
    final guiIdx = daliurenZhi.indexOf(guiRen);
    final gi = guiIdx >= 0 ? guiIdx : 0;
    final tianJiang = List.generate(12, (i) => _tiJiangOrd[(i - gi + 12) % 12]);
    // 四课：日干上神/下神 + 日支上神/下神
    final ganJi = _ganJiGong[dayGan] ?? 2;
    final zhiIdx = daliurenZhi.indexOf(dayZhi);
    final ziIdx = zhiIdx >= 0 ? zhiIdx : 0;
    final siKe = [
      tianPan[ganJi],           // 日干上神
      daliurenZhi[ganJi],       // 日干下神（寄宫）
      tianPan[ziIdx],           // 日支上神
      dayZhi,                   // 日支下神
    ];
    // 三传推算（符合人工排盘）：初传取日干上神，中传/末传自初传位天盘顺行 2/4 位
    final chuIdx = daliurenZhi.indexOf(siKe[0]);
    final ci = chuIdx >= 0 ? chuIdx : 0;
    final chu = siKe[0];
    final zhong = tianPan[(ci + 2) % 12];
    final mo = tianPan[(ci + 4) % 12];
    return DaLiuRenResult(
      hourIndex: hourIndex,
      yueJiang: yueJiang,
      yueJiangZhi: yueJiangZhi,
      tianPan: tianPan,
      shiYong: [chu, zhong, mo],
      siKe: siKe,
      guiRen: guiRen,
      tianJiang: tianJiang,
      chuChuan: chu,
      zhongChuan: zhong,
      moChuan: mo,
      method: '月将加时（简化）',
    );
  }
}

/// 大六壬排盘页
class DaLiuRenPage extends StatefulWidget {
  const DaLiuRenPage({super.key});
  @override
  State<DaLiuRenPage> createState() => _DaLiuRenPageState();
}

class _DaLiuRenPageState extends State<DaLiuRenPage> {
  int _month = 1;
  int _hour = 0;
  int _dayGan = 0; // 甲
  int _dayZhi = 0; // 子
  static const _ganCN = ['甲','乙','丙','丁','戊','己','庚','辛','壬','癸'];
  DaLiuRenResult? _result;
  final _shotKey = GlobalKey();

  static const _hours = ['子时', '丑时', '寅时', '卯时', '辰时', '巳时',
    '午时', '未时', '申时', '酉时', '戌时', '亥时'];

  /// 用当前时间起课：自动定月份、时辰与日干支
  void _useNow() {
    final now = DateTime.now();
    final hourIdx = (now.hour == 23 || now.hour == 0)
        ? 0
        : ((now.hour + 1) ~/ 2) % 12;
    final solar = tyme.SolarDay.fromYmd(now.year, now.month, now.day);
    final gz = dayGanZhiFromTyme(solar);
    final g = gz.isNotEmpty ? gz[0] : '甲';
    final zhi = gz.length > 1 ? gz[1] : '子';
    setState(() {
      _month = now.month;
      _hour = hourIdx;
      _dayGan = _ganCN.indexOf(g);
      if (_dayGan < 0) _dayGan = 0;
      _dayZhi = daliurenZhi.indexOf(zhi);
      if (_dayZhi < 0) _dayZhi = 0;
    });
    _calc();
  }

  void _calc() {
    setState(() => _result = DaLiuRenEngine.byHour(
      _hour, _month,
      dayGan: _ganCN[_dayGan],
      dayZhi: daliurenZhi[_dayZhi],
    ));
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
            '已支持月将加时、四课、三传、十二天将按贵人排布。',
            style: TextStyle(fontSize: 12, height: 1.6, color: t.withAlpha(160))),
        const SizedBox(height: 12),
        // 输入区 Card（与六爻梅花一致）
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
        // 当前时间起课
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _useNow,
            icon: const Icon(Icons.schedule, size: 16),
            label: const Text('使用当前时间起课', style: TextStyle(fontSize: 13)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        const SizedBox(height: 4),
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
            return ChoiceChip(
              label: Text(_hours[i], style: TextStyle(fontSize: 11, color: sel ? p : t)),
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
              child: InkWell(
                onTap: () => _showDetail(),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('月将：${daliurenYueJiang[_result!.yueJiang]}（临${_result!.yueJiangZhi} · ${_result!.method}）',
                    style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                // 天地盘：月将加时，天盘十二支
                Text('天地盘（月将加时）', style: TextStyle(fontSize: 13, color: t.withAlpha(150))),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: b.withAlpha(80)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('月将 ${daliurenYueJiang[_result!.yueJiang]}（${_result!.yueJiangZhi}）加于 ${_hours[_result!.hourIndex]}',
                        style: const TextStyle(fontSize: 11.5)),
                    const SizedBox(height: 8),
                    // 地盘/天盘对照网格
                    _tianPanGrid(_result!.tianPan, _result!.yueJiangZhi, p, t, b),
                    const SizedBox(height: 6),
                    // 天地盘信息解释
                    Text('🛰 天地盘说明：地盘固定十二支（子北午南），天盘由月将顺加而成。'
                        '月将 ${_result!.yueJiangZhi} 落于时支 ${daliurenZhi[_result!.hourIndex]}，'
                        '天盘随十二支顺布。断课以天盘神将临地盘支位定吉凶。',
                        style: TextStyle(fontSize: 10.5, height: 1.6, color: t.withAlpha(150))),
                  ]),
                ),
                const SizedBox(height: 8),
                // 贵人与十二天将排布
                Text('贵人与天将', style: TextStyle(fontSize: 13, color: t.withAlpha(150))),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: b.withAlpha(80)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('贵人临 ${_result!.guiRen}（${_hours[_result!.hourIndex]} ${
                        _result!.hourIndex < 6 ? "昼·阳贵" : "夜·阴贵"}）',
                        style: const TextStyle(fontSize: 11.5)),
                    const SizedBox(height: 6),
                    // 只展示三传对应天将（不凑数）
                    Text('三传天将：${_chuanTianJiang('初传', _result!.chuChuan, _result!)}　'
                        '${_chuanTianJiang('中传', _result!.zhongChuan, _result!)}　'
                        '${_chuanTianJiang('末传', _result!.moChuan, _result!)}',
                        style: const TextStyle(fontSize: 11.5, height: 1.5)),
                    const SizedBox(height: 4),
                    Text('（天将随贵人支顺布，此处仅列三传所临天将，详见详解）',
                        style: TextStyle(fontSize: 10, color: t.withAlpha(110))),
                  ]),
                ),
                const SizedBox(height: 8),
                Text('四课', style: TextStyle(fontSize: 13, color: t.withAlpha(150))),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _ke('一课·日干上神', _result!.siKe[0], p, t, bg, b),
                    _ke('二课·日干下神', _result!.siKe[1], p, t, bg, b),
                    _ke('三课·日支上神', _result!.siKe[2], p, t, bg, b),
                    _ke('四课·日支下神', _result!.siKe[3], p, t, bg, b),
                  ],
                ),
                const SizedBox(height: 8),
                Text('三传', style: TextStyle(fontSize: 13, color: t.withAlpha(150))),
                const SizedBox(height: 6),
                Row(children: [
                  _chuan('初传', _result!.chuChuan, p, t, bg, b),
                  const SizedBox(width: 8),
                  _chuan('中传', _result!.zhongChuan, p, t, bg, b),
                  const SizedBox(width: 8),
                  _chuan('末传', _result!.moChuan, p, t, bg, b),
                ]),
                const SizedBox(height: 8),
                Text('十二天将详解', style: TextStyle(fontSize: 13, color: t.withAlpha(150))),
                const SizedBox(height: 6),
                // 天将网格（名称+吉凶+含义）
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: daliurenGenerals.map((g) {
                    final isGood = g.$2 == '吉';
                    final gc = isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
                    return Container(
                      width: (340 - 24) / 2,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: gc.withAlpha(12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: gc.withAlpha(40)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text(g.$1, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: gc)),
                          const SizedBox(width: 6),
                          Text(g.$2, style: TextStyle(fontSize: 10, color: gc)),
                        ]),
                        const SizedBox(height: 2),
                        Text(g.$3, style: TextStyle(fontSize: 10, height: 1.4, color: t.withAlpha(160))),
                      ]),
                    );
                  }).toList(),
                ),
              ]),
            ),
          ),
          ),
        ),
            const SizedBox(height: 8),
            Row(children: [
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
                  onPressed: _saveCase,
                  icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                  label: const Text('保存卦例'),
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
    final cm = CaseModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: '大六壬 · ${r.chuChuan}传',
      guaName: '大六壬',
      guaGong: r.chuChuan,
      method: '大六壬（${r.method}）',
      paipanData: '{"daLiuRen":${_jsonEncode(r)}}',
      caseType: CaseType.liuyao,
    );
    context.read<CaseProvider>().addCase(cm);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已保存到卦例库')),
    );
  }

  /// 结果详解弹窗
  void _showDetail() {
    final r = _result;
    if (r == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('大六壬 结果详解'),
        content: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('月将：${daliurenYueJiang[r.yueJiang]}（${r.method}）',
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            Text('三传：初传${r.chuChuan} → 中传${r.zhongChuan} → 末传${r.moChuan}',
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 10),
            const Text('十二天将', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            for (final g in daliurenGenerals)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('${g.$1}（${g.$2}）：${g.$3}',
                    style: const TextStyle(fontSize: 12, height: 1.5)),
              ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('关闭')),
        ],
      ),
    );
  }

  /// 分享结果到剪贴板
  Future<void> _share() async {
    final r = _result;
    if (r == null) return;
    final buf = StringBuffer()
      ..writeln('【落·乾坤】大六壬排盘结果')
      ..writeln('━━━━━━━━━━━━━━')
      ..writeln('月将：${daliurenYueJiang[r.yueJiang]}（临${r.yueJiangZhi} · ${r.method}）')
      ..writeln('三传：初传${r.chuChuan} → 中传${r.zhongChuan} → 末传${r.moChuan}')
      ..writeln('四课：${r.siKe.join(' / ')}')
      ..writeln('贵人临${r.guiRen} · 三传天将：${_chuanTianJiang('', r.chuChuan, r).trim()} / ${_chuanTianJiang('', r.zhongChuan, r).trim()} / ${_chuanTianJiang('', r.moChuan, r).trim()}')
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

  /// 天地盘对照网格（上：天盘，下：地盘）
  Widget _tianPanGrid(List<String> tianPan, String yueJiangZhi,
      Color p, Color t, Color b) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('天盘', style: TextStyle(fontSize: 10, color: p.withAlpha(170))),
      const SizedBox(height: 4),
      Row(
        children: List.generate(12, (i) {
          final isYueJiang = tianPan[i] == yueJiangZhi;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isYueJiang ? p.withAlpha(30) : t.withAlpha(6),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color: isYueJiang ? p : b.withAlpha(40),
                    width: isYueJiang ? 1.5 : 1),
              ),
              child: Text(tianPan[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: isYueJiang ? FontWeight.bold : FontWeight.normal,
                      color: isYueJiang ? p : t.withAlpha(180))),
            ),
          );
        }),
      ),
      const SizedBox(height: 6),
      Text('地盘', style: TextStyle(fontSize: 10, color: t.withAlpha(120))),
      const SizedBox(height: 4),
      Row(
        children: List.generate(12, (i) {
          final isHour = i == (_result?.hourIndex ?? 0);
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isHour ? t.withAlpha(14) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(daliurenZhi[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: isHour ? FontWeight.bold : FontWeight.normal,
                      color: t.withAlpha(isHour ? 210 : 150))),
            ),
          );
        }),
      ),
    ]);
  }

  /// 地支详解弹窗（点击三传/四课触发）
  void _showZhiDetail(String label, String zhi) {
    final d = daliurenZhiDetail[zhi];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$label · $zhi'),
        content: d == null
            ? Text('暂无 $zhi 详解')
            : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('五行：${d.$1}', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 6),
                Text('类象：${d.$2}', style: const TextStyle(fontSize: 13, height: 1.6)),
                const SizedBox(height: 6),
                Text('吉凶：${d.$3}', style: const TextStyle(fontSize: 13)),
              ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('关闭')),
        ],
      ),
    );
  }

  Widget _ke(String label, String zhi, Color p, Color t, Color bg, Color b) {
    return GestureDetector(
      onTap: () => _showZhiDetail(label, zhi),
      child: Container(
        width: (360 - 32) / 2,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: b.withAlpha(80))),
        child: Column(children: [
          Text(label, style: TextStyle(fontSize: 10, color: t.withAlpha(130))),
          const SizedBox(height: 2),
          Text(zhi, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: p)),
          const SizedBox(height: 1),
          Icon(Icons.touch_app, size: 10, color: p.withAlpha(120)),
        ]),
      ),
    );
  }

  Widget _chuan(String label, String zhi, Color p, Color t, Color bg, Color b) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _showZhiDetail(label, zhi),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: b.withAlpha(80))),
          child: Column(children: [
            Text(label, style: TextStyle(fontSize: 11, color: t.withAlpha(130))),
            const SizedBox(height: 2),
            Text(zhi, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: p)),
            Icon(Icons.touch_app, size: 11, color: p.withAlpha(120)),
          ]),
        ),
      ),
    );
  }

}
