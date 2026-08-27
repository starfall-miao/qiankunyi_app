/// 排盘结果截图模板 — 固定紧凑宽度 + 国风浅色（US-006）
///
/// 六爻 / 梅花 / 八字三个结果页的「保存图片」截图源。
/// - 宽度固定 400px，不随手机/桌面屏幕宽窄变化
/// - 背景固定浅色国风 #F5F0EB、文字深棕 #4A3728，不读取主题，
///   从根源避免「暗色主题下截图反色 / 白底黑字变黑底白字」
/// - 同一张图包含：排盘结果主图 + 每爻详解小卡片 + 整卦解释卡片
///
/// 用法：页面显示布局保持不变，另用 [ScreenshotSource] 挂一个截图专用
/// RepaintBoundary（屏幕外），把原截图 GlobalKey 移到其上：
/// ```dart
/// ScreenshotSource(
///   boundaryKey: _liuyaoScreenshotKey,
///   child: LiuyaoScreenshotTemplate(...),
/// )
/// ```
library;

import 'package:flutter/material.dart';

import '../../features/paipan/models/bazi_models.dart';
import '../../features/paipan/models/gua_model.dart';
import '../../features/paipan/models/yao_model.dart';
import '../../features/cases/models/case_models.dart';
import '../constants/yao_plain_desc.dart';

// ═══════════════════ 固定国风配色（不随主题变化，反色修复关键） ═══════════════════
const _sBg = Color(0xFFF5F0EB);
const _sText = Color(0xFF4A3728);
const _sSub = Color(0xFF9A8A78);
const _sGold = Color(0xFFD4A574);
const _sCard = Color(0xFFFFFBF7);
const _sBorder = Color(0xFFE8DDD2);

// 卦名中文映射统一使用 case_models.dart 中的 guaNameCN

const _sWuXingCN = <WuXing, String>{
  WuXing.jin: '金', WuXing.mu: '木', WuXing.shui: '水',
  WuXing.huo: '火', WuXing.tu: '土',
};

const _sTianGanCN = <TianGan, String>{
  TianGan.jia: '甲', TianGan.yi: '乙', TianGan.bing: '丙',
  TianGan.ding: '丁', TianGan.wu: '戊', TianGan.ji: '己',
  TianGan.geng: '庚', TianGan.xin: '辛', TianGan.ren: '壬', TianGan.gui: '癸',
};

const _sDiZhiCN = <DiZhi, String>{
  DiZhi.zi: '子', DiZhi.chou: '丑', DiZhi.yin: '寅', DiZhi.mao: '卯',
  DiZhi.chen: '辰', DiZhi.si: '巳', DiZhi.wu: '午', DiZhi.wei: '未',
  DiZhi.shen: '申', DiZhi.you: '酉', DiZhi.xu: '戌', DiZhi.hai: '亥',
};

const _sLiuQinCN = <LiuQin, String>{
  LiuQin.parent: '父母', LiuQin.brother: '兄弟', LiuQin.officer: '官鬼',
  LiuQin.wife: '妻财', LiuQin.child: '子孙', LiuQin.none: '',
};

const _sLiuShenCN = <LiuShen, String>{
  LiuShen.qingLong: '青龙', LiuShen.zhuQue: '朱雀',
  LiuShen.gouChen: '勾陈', LiuShen.tengShe: '螣蛇',
  LiuShen.baiHu: '白虎', LiuShen.xuanWu: '玄武',
};

const _sWangShuaiCN = <WangShuaiLevel, String>{
  WangShuaiLevel.wang: '旺', WangShuaiLevel.xiang: '相',
  WangShuaiLevel.xiu: '休', WangShuaiLevel.qiu: '囚',
  WangShuaiLevel.si: '死',
};

// 六神 / 旺衰 颜色 — 与主页面一致的传统国风配色
const _sLiuShenColor = <LiuShen, Color>{
  LiuShen.qingLong: Color(0xFF2E7D32),
  LiuShen.zhuQue: Color(0xFFC62828),
  LiuShen.gouChen: Color(0xFFEF6C00),
  LiuShen.tengShe: Color(0xFF7B1FA2),
  LiuShen.baiHu: Color(0xFF78909C),
  LiuShen.xuanWu: Color(0xFF37474F),
};

const _sWangShuaiColor = <WangShuaiLevel, Color>{
  WangShuaiLevel.wang: Color(0xFF1B5E20),
  WangShuaiLevel.xiang: Color(0xFF2E7D32),
  WangShuaiLevel.xiu: Color(0xFF9E9D24),
  WangShuaiLevel.qiu: Color(0xFFE65100),
  WangShuaiLevel.si: Color(0xFFB71C1C),
};

/// 中文时间格式化（截图信息行共用）
String formatCnTime(DateTime dt) {
  return '${dt.year}年${dt.month}月${dt.day}日 '
      '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
}

/// 截图源容器：把截图专用 RepaintBoundary 放在屏幕外（Stack + Positioned）。
///
/// 为什么不用 Offstage：Offstage(offstage: true) 的 child 只布局不 paint，
/// RepaintBoundary 的 layer 树不完整，toImage 会空白/崩溃。本方案 child
/// 正常 paint（只是画在屏幕外并被父级 clip 裁掉），toImage 可正常捕获，
/// 且不占布局空间、不影响页面显示布局。
class ScreenshotSource extends StatelessWidget {
  final GlobalKey boundaryKey;
  final Widget child;

  const ScreenshotSource({
    super.key,
    required this.boundaryKey,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const SizedBox.shrink(),
        Positioned(
          left: -10000,
          top: -10000,
          child: RepaintBoundary(
            key: boundaryKey,
            child: child,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════ 六爻截图模板 ═══════════════════

/// 六爻纳甲紧凑截图：标题 + 信息行 + 本/变/互三卦 + 每爻详解 + 整卦解释
class LiuyaoScreenshotTemplate extends StatelessWidget {
  final String timeText;
  final List<String> infoTags;
  final GuaModel benGua;
  final GuaModel? bianGua;
  final GuaModel? huGua;
  final String? explanationTitle; // 卦名全名，如 '乾为天'
  final String? explanationCi; // 卦辞
  final String? explanationXiang; // 象辞
  final String? explanationJiXiong; // 吉凶

  const LiuyaoScreenshotTemplate({
    super.key,
    required this.timeText,
    this.infoTags = const [],
    required this.benGua,
    this.bianGua,
    this.huGua,
    this.explanationTitle,
    this.explanationCi,
    this.explanationXiang,
    this.explanationJiXiong,
  });

  @override
  Widget build(BuildContext context) {
    return _screenshotShell(
      title: '六爻纳甲 · 排盘结果',
      timeText: timeText,
      infoTags: infoTags,
      children: [
        _guaRow(benGua: benGua, bianGua: bianGua, huGua: huGua),
        const SizedBox(height: 12),
        _sectionTitle('每爻详解'),
        ...benGua.yaos.reversed.map((y) => _yaoDetailCard(y)),
        if (explanationTitle != null && explanationCi != null) ...[
          const SizedBox(height: 12),
          _sectionTitle('整卦解释'),
          _explanationCard(
            title: explanationTitle!,
            ci: explanationCi!,
            xiang: explanationXiang,
            jiXiong: explanationJiXiong,
          ),
        ],
      ],
    );
  }
}

// ═══════════════════ 梅花截图模板 ═══════════════════

/// 梅花易数紧凑截图：标题 + 信息行 + 三卦 + 体用生克 + 整卦解释
class MeihuaScreenshotTemplate extends StatelessWidget {
  final String timeText;
  final List<String> infoTags;
  final GuaModel benGua;
  final GuaModel? bianGua;
  final GuaModel? huGua;
  final String? tiYongText; // 体用生克描述（可为空）
  final String? explanationTitle;
  final String? explanationCi;
  final String? explanationXiang;
  final String? explanationJiXiong;

  const MeihuaScreenshotTemplate({
    super.key,
    required this.timeText,
    this.infoTags = const [],
    required this.benGua,
    this.bianGua,
    this.huGua,
    this.tiYongText,
    this.explanationTitle,
    this.explanationCi,
    this.explanationXiang,
    this.explanationJiXiong,
  });

  @override
  Widget build(BuildContext context) {
    return _screenshotShell(
      title: '梅花易数 · 排盘结果',
      timeText: timeText,
      infoTags: infoTags,
      children: [
        _guaRow(benGua: benGua, bianGua: bianGua, huGua: huGua),
        if (tiYongText != null && tiYongText!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _sectionTitle('体用生克'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _sCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _sGold.withAlpha(90)),
            ),
            child: Text(
              tiYongText!,
              style: const TextStyle(fontSize: 11, color: _sText, height: 1.5),
            ),
          ),
        ],
        if (explanationTitle != null && explanationCi != null) ...[
          const SizedBox(height: 12),
          _sectionTitle('整卦解释'),
          _explanationCard(
            title: explanationTitle!,
            ci: explanationCi!,
            xiang: explanationXiang,
            jiXiong: explanationJiXiong,
          ),
        ],
      ],
    );
  }
}

// ═══════════════════ 八字截图模板 ═══════════════════

/// 八字紧凑截图：标题 + 出生信息 + 四柱 + 五行旺衰 + 大运 + 流年
class BaziScreenshotTemplate extends StatelessWidget {
  final String birthText; // 出生信息，如 '1990年1月1日 午时 · 男'
  final BaziResult result;

  const BaziScreenshotTemplate({
    super.key,
    required this.birthText,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final r = result;
    return _screenshotShell(
      title: '八字排盘 · 结果',
      timeText: birthText,
      infoTags: const [],
      children: [
        // ── 四柱 ──
        Row(
          children: [
            _zhuCard('年柱', r.yearZhu),
            const SizedBox(width: 6),
            _zhuCard('月柱', r.monthZhu),
            const SizedBox(width: 6),
            _zhuCard('日柱', r.dayZhu, highlight: true),
            const SizedBox(width: 6),
            _zhuCard('时柱', r.hourZhu),
          ],
        ),
        // ── 五行旺衰 ──
        if (r.wuXingWangShuai.isNotEmpty) ...[
          const SizedBox(height: 12),
          _sectionTitle('五行旺衰'),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: r.wuXingWangShuai.entries.map((e) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _sCard,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _sBorder),
                ),
                child: Text(
                  '${e.key} ${e.value}',
                  style: const TextStyle(fontSize: 11, color: _sText),
                ),
              );
            }).toList(),
          ),
        ],
        // ── 五行统计 ──
        if (r.wuXingCounts.isNotEmpty) ...[
          const SizedBox(height: 12),
          _sectionTitle('五行统计'),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: r.wuXingCounts.entries.map((e) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _sCard,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _sBorder),
                ),
                child: Text(
                  '${e.key} ${e.value}',
                  style: const TextStyle(fontSize: 11, color: _sText),
                ),
              );
            }).toList(),
          ),
        ],
        // ── 空亡 ──
        if (r.kongWang.isNotEmpty) ...[
          const SizedBox(height: 12),
          _sectionTitle('空亡（旬空）'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _sCard,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _sBorder),
            ),
            child: Text(
              '空亡：${r.kongWang.join("、")}',
              style: const TextStyle(fontSize: 11, color: _sText),
            ),
          ),
        ],
        // ── 纳音（四柱） ──
        if (_hasNaYin(r)) ...[
          const SizedBox(height: 12),
          _sectionTitle('纳音'),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (r.yearZhu.naYin != null) _tag('年 ${r.yearZhu.naYin}'),
              if (r.monthZhu.naYin != null) _tag('月 ${r.monthZhu.naYin}'),
              if (r.dayZhu.naYin != null) _tag('日 ${r.dayZhu.naYin}'),
              if (r.hourZhu.naYin != null) _tag('时 ${r.hourZhu.naYin}'),
            ],
          ),
        ],
        // ── 十神 ──
        if (r.shiShenMap.isNotEmpty) ...[
          const SizedBox(height: 12),
          _sectionTitle('十神（以日干为基准）'),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: r.shiShenMap.entries
                .where((e) => e.key != '日主')
                .take(16)
                .map((e) {
              final label = e.key.contains(':')
                  ? '${e.key.split(':')[0]}:${e.key.split(':')[1]}'
                  : e.key;
              return _tag('$label → ${e.value}');
            }).toList(),
          ),
        ],
        // ── 藏干 ──
        if (r.yearZhu.cangGan.isNotEmpty ||
            r.monthZhu.cangGan.isNotEmpty) ...[
          const SizedBox(height: 12),
          _sectionTitle('藏干'),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cangRow('年', r.yearZhu.cangGan),
              _cangRow('月', r.monthZhu.cangGan),
              _cangRow('日', r.dayZhu.cangGan),
              _cangRow('时', r.hourZhu.cangGan),
            ],
          ),
        ],
        // ── 大运 ──
        if (r.daYun.isNotEmpty) ...[
          const SizedBox(height: 12),
          _sectionTitle('大运'),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: r.daYun.map((dy) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _sCard,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _sBorder),
                ),
                child: Text(
                  '${dy.startAge}岁 ${dy.ganZhi}',
                  style: const TextStyle(fontSize: 11, color: _sText),
                ),
              );
            }).toList(),
          ),
          // ── 大运五行走势（色块条） ──
          const SizedBox(height: 8),
          _daYunWxBar(r.daYun),
        ],
        // ── 流年 ──
        if (r.liuNian != null && r.liuNian!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _sectionTitle('当年流年'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _sCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _sGold.withAlpha(90)),
            ),
            child: Text(
              '流年：${r.liuNian}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _sText),
            ),
          ),
        ],
      ],
    );
  }
}

/// 四柱是否含纳音
bool _hasNaYin(BaziResult r) =>
    r.yearZhu.naYin != null ||
    r.monthZhu.naYin != null ||
    r.dayZhu.naYin != null ||
    r.hourZhu.naYin != null;

/// 截图小标签
Widget _tag(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: _sCard,
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: _sBorder),
    ),
    child: Text(text, style: const TextStyle(fontSize: 10, color: _sText)),
  );
}

/// 藏干行：'年柱地支 藏干'（cangGan: 本气/中气/余气 → 干）
Widget _cangRow(String label, Map<String, String> cang) {
  final parts = cang.values.where((v) => v.isNotEmpty).toList();
  return Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: Text(
      '$label：${parts.isEmpty ? "—" : parts.join("、")}',
      style: const TextStyle(fontSize: 10.5, color: _sText),
    ),
  );
}

/// 天干→五行
const _ganWxMap = {
  '甲': '木', '乙': '木', '丙': '火', '丁': '火', '戊': '土',
  '己': '土', '庚': '金', '辛': '金', '壬': '水', '癸': '水',
};

/// 五行→色
const _wxColorMap = {
  '木': Color(0xFF2E7D32),
  '火': Color(0xFFD32F2F),
  '土': Color(0xFFEF6C00),
  '金': Color(0xFFF9A825),
  '水': Color(0xFF1565C0),
};

/// 大运五行走势色块条：每步大运一个五行色竖条 + 下方标注干支
Widget _daYunWxBar(List<DaYun> daYun) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: daYun.map((dy) {
      final wx = _ganWxMap[dy.tianGan] ?? '土';
      final color = _wxColorMap[wx] ?? _sSub;
      return Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 36,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: color.withAlpha(200),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
            const SizedBox(height: 2),
            Text(dy.ganZhi,
                style: const TextStyle(fontSize: 8, color: _sText),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      );
    }).toList(),
  );
}

// ═══════════════════ 公共私有组件 ═══════════════════

/// 截图外壳：固定 400 宽 + 浅色国风背景 + 标题/信息行/水印
Widget _screenshotShell({
  required String title,
  required String timeText,
  required List<String> infoTags,
  required List<Widget> children,
}) {
  final infoChips = <Widget>[
    if (timeText.isNotEmpty) _infoTag(timeText),
    ...infoTags.map((e) => _infoTag(e)),
  ];
  return Container(
    width: 400,
    color: _sBg,
    padding: const EdgeInsets.all(14),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 装饰标题 ──
        Row(
          children: [
            const Text('☯ ', style: TextStyle(fontSize: 16, color: _sGold)),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _sText),
            ),
            const Spacer(),
            Container(
              width: 36,
              height: 2,
              decoration: BoxDecoration(
                color: _sGold,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // ── 信息行（时间 / 月令 / 日令 / 空亡 / 流派）──
        if (infoChips.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: _sGold.withAlpha(16),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _sGold.withAlpha(60)),
            ),
            child: Wrap(spacing: 8, runSpacing: 4, children: infoChips),
          ),
          const SizedBox(height: 12),
        ],
        ...children,
        const SizedBox(height: 10),
        // ── 水印 ──
        Center(
          child: Text(
            '— 来自「落·乾坤」',
            style: TextStyle(fontSize: 10, color: _sSub),
          ),
        ),
      ],
    ),
  );
}

/// 信息小标签
Widget _infoTag(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: _sCard,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: _sGold.withAlpha(70)),
    ),
    child: Text(text, style: const TextStyle(fontSize: 10.5, color: _sText)),
  );
}

/// 节标题
Widget _sectionTitle(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _sText),
    ),
  );
}

/// 三卦横排（固定宽度内 Expanded 不溢出）
Widget _guaRow({required GuaModel benGua, GuaModel? bianGua, GuaModel? huGua}) {
  final cards = <Widget>[
    Expanded(child: _guaCard('本卦', benGua)),
  ];
  if (bianGua != null) {
    cards.add(const SizedBox(width: 8));
    cards.add(Expanded(child: _guaCard('变卦', bianGua)));
  }
  if (huGua != null) {
    cards.add(const SizedBox(width: 8));
    cards.add(Expanded(child: _guaCard('互卦', huGua)));
  }
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: cards,
  );
}

/// 单卦小卡：标签 + 卦名 + 六爻线
Widget _guaCard(String label, GuaModel gua) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _sGold),
      ),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: _sCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _sGold.withAlpha(80)),
        ),
        child: Column(
          children: [
            Text(
              guaNameCN[gua.name] ?? gua.name.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _sText),
            ),
            const SizedBox(height: 6),
            ...gua.yaos.reversed.map((y) => _guaLine(y)),
          ],
        ),
      ),
    ],
  );
}

/// 单根爻线（阳爻实线 / 阴爻两段，动爻金色 + 闪电标记，与排盘页 GuaWidget 一致）
Widget _guaLine(YaoModel yao) {
  final color = yao.isMoving ? _sGold : _sText;
  Widget segment() => Container(
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      );
  final Widget line;
  if (yao.yinYang == YaoYinYang.yang) {
    line = segment();
  } else {
    line = Row(
      children: [
        Expanded(child: segment()),
        const SizedBox(width: 8),
        Expanded(child: segment()),
      ],
    );
  }
  if (!yao.isMoving) return line;
  // 动爻：爻线变金色，右端加闪电符号（与排盘页 Icons.bolt 动爻标记一致）
  return SizedBox(
    height: 14,
    child: Stack(
      children: [
        Align(alignment: Alignment.center, child: line),
        Align(
          alignment: Alignment.centerRight,
          child: Icon(Icons.bolt, size: 12, color: _sGold),
        ),
      ],
    ),
  );
}

/// 详解小卡片内的小爻画（40 宽列，与排盘页 GuaWidget 爻画列一致；动爻金色）
Widget _miniYaoLine(YaoModel yao) {
  final color = yao.isMoving ? _sGold : _sText;
  Widget segment() => Container(
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      );
  if (yao.yinYang == YaoYinYang.yang) {
    return segment();
  }
  return Row(
    children: [
      Expanded(child: segment()),
      const SizedBox(width: 6),
      Expanded(child: segment()),
    ],
  );
}

/// 每爻详解小卡片：爻位 + 六神 + 干支 + 五行 + 六亲 + 旺衰 + 世应 + 特殊标记 + 白话解释
Widget _yaoDetailCard(YaoModel yao) {
  final liuShen = yao.liuShen;
  final lsColor = liuShen != null ? _sLiuShenColor[liuShen]! : _sSub;
  final marks = <String>[
    if (yao.isKongWang) '空',
    if (yao.isXing) '刑',
    if (yao.isChong) '冲',
    if (yao.isHe) '合',
    if (yao.isHai) '害',
    if (yao.sanHeJu.isNotEmpty) '三合',
  ];
  final plainDescs = _yaoPlainDescs(yao);
  return Container(
    margin: const EdgeInsets.only(bottom: 4),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: _sCard,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: _sBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // 六神窄条（28 宽，与排盘页 GuaWidget 六神列对齐）
            Container(
              width: 28,
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: lsColor.withAlpha(24),
                borderRadius: BorderRadius.circular(3),
                border: Border(left: BorderSide(color: lsColor, width: 2)),
              ),
              alignment: Alignment.center,
              child: Text(
                liuShen != null ? _sLiuShenCN[liuShen]!.substring(0, 1) : '—',
                style: TextStyle(
                  fontSize: 10,
                  color: lsColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 6),
            // 爻画列（40 宽，与排盘页 GuaWidget 爻画列对齐；动爻金色）
            SizedBox(
              width: 40,
              child: _miniYaoLine(yao),
            ),
            const SizedBox(width: 6),
            // 爻位名（初九/六二/九三…）
            SizedBox(
              width: 30,
              child: Text(
                _yaoPosFullName(yao),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _sText),
              ),
            ),
            // 阴阳 + 动静
            Text(
              yao.yinYang == YaoYinYang.yang ? '阳' : '阴',
              style: const TextStyle(fontSize: 10, color: _sSub),
            ),
            if (yao.isMoving) ...[
              const SizedBox(width: 2),
              Text(
                '动',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _sGold),
              ),
            ],
            const SizedBox(width: 6),
            // 干支
            Text(
              _ganZhiText(yao),
              style: const TextStyle(fontSize: 11, color: _sText),
            ),
            // 五行
            if (yao.diZhi != null) ...[
              const SizedBox(width: 6),
              Text(
                _sWuXingCN[_diZhiWuXing(yao.diZhi!)] ?? '',
                style: TextStyle(fontSize: 10, color: _sWuXingColor(_diZhiWuXing(yao.diZhi!))),
              ),
            ],
            // 六亲
            if (yao.liuQin != LiuQin.none) ...[
              const SizedBox(width: 6),
              Text(
                _sLiuQinCN[yao.liuQin] ?? '',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _sText),
              ),
            ],
            // 旺衰
            if (yao.wangShuai != null) ...[
              const SizedBox(width: 6),
              Text(
                _sWangShuaiCN[yao.wangShuai] ?? '',
                style: TextStyle(fontSize: 10, color: _sWangShuaiColor[yao.wangShuai]),
              ),
            ],
            // 世应
            if (yao.isShi)
              _shiYingBadge('世', const Color(0xFFD32F2F))
            else if (yao.isYing)
              _shiYingBadge('应', const Color(0xFF1976D2)),
            // 特殊标记（空/刑/冲/合/害/三合）：Expanded+Wrap 防止字段全显时溢出
            if (marks.isNotEmpty)
              Expanded(
                child: Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  children: marks.map((m) => _markBadge(m)).toList(),
                ),
              ),
          ],
        ),
        // 白话解释（与点击爻位弹窗 _showYaoRef 同源共享文本，'术语 — 白话'）
        if (plainDescs.isNotEmpty) ...[
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Text(
              plainDescs.join(' ｜ '),
              style: const TextStyle(fontSize: 9.5, color: _sSub, height: 1.35),
            ),
          ),
        ],
      ],
    ),
  );
}

/// 每爻白话解释条目（与点击爻位弹窗 _showYaoRef 同源共享文本）
///
/// 每条为「字段标签：术语 — 白话」，如 '旺衰：旺 — 力量最旺盛，如日中天。此爻能量最强，作用力大'。
List<String> _yaoPlainDescs(YaoModel yao) {
  return <String>[
    if (yao.liuQin != LiuQin.none)
      '六亲：${_sLiuQinCN[yao.liuQin]} — ${liuQinDesc(yao.liuQin)}',
    if (yao.liuShen != null)
      '六神：${_sLiuShenCN[yao.liuShen]} — ${liuShenDesc(yao.liuShen!)}',
    if (yao.wangShuai != null) '旺衰：${wangShuaiDesc(yao.wangShuai!)}',
    if (yao.isShi) '世爻：$shiYaoDesc',
    if (yao.isYing) '应爻：$yingYaoDesc',
    if (yao.isKongWang) '旬空：$kongWangDesc',
    if (yao.isXing) '刑：$xingDesc',
    if (yao.isChong) '冲：$chongDesc',
    if (yao.isHe) '合：$heDesc',
    if (yao.isHai) '害：$haiDesc',
    if (yao.sanHeJu.isNotEmpty) '三合（${yao.sanHeJu.join('、')}）：$sanHeDesc',
  ];
}

/// 世/应 徽章
Widget _shiYingBadge(String text, Color color) {
  return Container(
    margin: const EdgeInsets.only(left: 6),
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
    decoration: BoxDecoration(
      color: color.withAlpha(24),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
    ),
  );
}

/// 特殊关系小标记
Widget _markBadge(String text) {
  return Container(
    margin: const EdgeInsets.only(left: 4),
    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
    decoration: BoxDecoration(
      color: _sGold.withAlpha(22),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 10, color: _sSub),
    ),
  );
}

/// 整卦解释卡片
Widget _explanationCard({
  required String title,
  required String ci,
  String? xiang,
  String? jiXiong,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: _sCard,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _sGold.withAlpha(90)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '【$title】',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _sText),
            ),
            if (jiXiong != null && jiXiong.isNotEmpty) ...[
              const SizedBox(width: 8),
              _jiXiongBadge(jiXiong),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '卦辞：$ci',
          style: const TextStyle(fontSize: 11, color: _sText, height: 1.5),
        ),
        if (xiang != null && xiang.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            '象曰：$xiang',
            style: const TextStyle(fontSize: 11, color: _sSub, height: 1.5),
          ),
        ],
      ],
    ),
  );
}

/// 吉凶徽章
Widget _jiXiongBadge(String jiXiong) {
  final Color color;
  if (jiXiong.contains('吉')) {
    color = const Color(0xFF2E7D32);
  } else if (jiXiong.contains('凶')) {
    color = const Color(0xFFC62828);
  } else {
    color = const Color(0xFFEF6C00);
  }
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
    decoration: BoxDecoration(
      color: color.withAlpha(18),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withAlpha(70)),
    ),
    child: Text(
      jiXiong,
      style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
    ),
  );
}

/// 八字单柱卡
Widget _zhuCard(String label, SiZhu zhu, {bool highlight = false}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: highlight ? _sGold.withAlpha(22) : _sCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlight ? _sGold : _sBorder,
          width: highlight ? 1.2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: _sSub)),
          const SizedBox(height: 4),
          Text(
            zhu.ganZhi,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _sText),
          ),
          const SizedBox(height: 2),
          Text(
            zhu.wuXing,
            style: const TextStyle(fontSize: 10, color: _sGold),
          ),
        ],
      ),
    ),
  );
}

// ═══════════════════ 辅助函数 ═══════════════════

/// 爻位全名：初九 / 六二 / 九三 / 六四 / 九五 / 上六
String _yaoPosFullName(YaoModel yao) {
  final pos = yao.positionName;
  final g = yao.yinYang == YaoYinYang.yang ? '九' : '六';
  if (pos == '初') return '初$g';
  if (pos == '上') return '上$g';
  return '$g$pos';
}

/// 天干地支文本，如 '甲子'
String _ganZhiText(YaoModel yao) {
  final tg = yao.tianGan != null ? _sTianGanCN[yao.tianGan] : '';
  final dz = yao.diZhi != null ? _sDiZhiCN[yao.diZhi] : '';
  return '$tg$dz';
}

/// 地支五行
WuXing _diZhiWuXing(DiZhi dz) {
  switch (dz) {
    case DiZhi.zi: return WuXing.shui;
    case DiZhi.chou: return WuXing.tu;
    case DiZhi.yin: return WuXing.mu;
    case DiZhi.mao: return WuXing.mu;
    case DiZhi.chen: return WuXing.tu;
    case DiZhi.si: return WuXing.huo;
    case DiZhi.wu: return WuXing.huo;
    case DiZhi.wei: return WuXing.tu;
    case DiZhi.shen: return WuXing.jin;
    case DiZhi.you: return WuXing.jin;
    case DiZhi.xu: return WuXing.tu;
    case DiZhi.hai: return WuXing.shui;
  }
}

/// 五行颜色
Color _sWuXingColor(WuXing wx) {
  switch (wx) {
    case WuXing.jin: return const Color(0xFFF9A825);
    case WuXing.mu: return const Color(0xFF2E7D32);
    case WuXing.shui: return const Color(0xFF1565C0);
    case WuXing.huo: return const Color(0xFFD32F2F);
    case WuXing.tu: return const Color(0xFF8D6E63);
  }
}
