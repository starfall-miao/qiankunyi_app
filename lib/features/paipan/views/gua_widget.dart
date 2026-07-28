// 六爻卦象渲染组件 — 国风紧凑版
// 配色参考 hexagram.qiankunyi.com.cn
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../settings/settings_provider.dart';
import '../models/yao_model.dart';
import '../models/gua_model.dart';

// ============ 中文映射表 ============

const _guaNameCN = <GuaName, String>{
  GuaName.qian: '乾为天', GuaName.kun: '坤为地', GuaName.zhun: '水雷屯',
  GuaName.meng: '山水蒙', GuaName.xu: '水天需', GuaName.song: '天水讼',
  GuaName.shi: '地水师', GuaName.bi: '水地比', GuaName.xiaoXu: '风天小畜',
  GuaName.lv: '天泽履', GuaName.tai: '地天泰', GuaName.pi: '天地否',
  GuaName.tongRen: '天火同人', GuaName.daYou: '火天大有', GuaName.qian2: '地山谦',
  GuaName.yu: '雷地豫', GuaName.sui: '泽雷随', GuaName.gu: '山风蛊',
  GuaName.lin: '地泽临', GuaName.guan: '风地观', GuaName.shiHe: '火雷噬嗑',
  GuaName.bi2: '山火贲', GuaName.bo: '山地剥', GuaName.fu: '地雷复',
  GuaName.wuWang: '天雷无妄', GuaName.daXu: '山天大畜', GuaName.yi: '山雷颐',
  GuaName.daGuo: '泽风大过', GuaName.kan: '坎为水', GuaName.li: '离为火',
  GuaName.xian: '泽山咸', GuaName.heng: '雷风恒', GuaName.dun: '天山遁',
  GuaName.daZhuang: '雷天大壮', GuaName.jin: '火地晋', GuaName.mingYi: '地火明夷',
  GuaName.jiaRen: '风火家人', GuaName.kui: '火泽睽', GuaName.jian: '水山蹇',
  GuaName.jie: '雷水解', GuaName.sun: '山泽损', GuaName.yi2: '风雷益',
  GuaName.guai: '泽天夬', GuaName.gou: '天风姤', GuaName.cui: '泽地萃',
  GuaName.sheng: '地风升', GuaName.kun2: '泽水困', GuaName.jing: '水风井',
  GuaName.ge: '泽火革', GuaName.ding: '火风鼎', GuaName.zhen: '震为雷',
  GuaName.gen: '艮为山', GuaName.jian2: '风山渐', GuaName.guiMei: '雷泽归妹',
  GuaName.feng: '雷火丰', GuaName.lv2: '火山旅', GuaName.xun: '巽为风',
  GuaName.dui: '兑为泽', GuaName.huan: '风水涣', GuaName.jie2: '水泽节',
  GuaName.zhongFu: '风泽中孚', GuaName.xiaoGuo: '雷山小过', GuaName.jiJi: '水火既济',
  GuaName.weiJi: '火水未济',
};

const _guaGongCN = <GuaGong, String>{
  GuaGong.qian: '乾', GuaGong.dui: '兑', GuaGong.li: '离',
  GuaGong.zhen: '震', GuaGong.xun: '巽', GuaGong.kan: '坎',
  GuaGong.gen: '艮', GuaGong.kun: '坤',
};

const _wuXingCN = <WuXing, String>{
  WuXing.jin: '金', WuXing.mu: '木', WuXing.shui: '水',
  WuXing.huo: '火', WuXing.tu: '土',
};

const _tianGanCN = <TianGan, String>{
  TianGan.jia: '甲', TianGan.yi: '乙', TianGan.bing: '丙',
  TianGan.ding: '丁', TianGan.wu: '戊', TianGan.ji: '己',
  TianGan.geng: '庚', TianGan.xin: '辛', TianGan.ren: '壬', TianGan.gui: '癸',
};

const _diZhiCN = <DiZhi, String>{
  DiZhi.zi: '子', DiZhi.chou: '丑', DiZhi.yin: '寅', DiZhi.mao: '卯',
  DiZhi.chen: '辰', DiZhi.si: '巳', DiZhi.wu: '午', DiZhi.wei: '未',
  DiZhi.shen: '申', DiZhi.you: '酉', DiZhi.xu: '戌', DiZhi.hai: '亥',
};

const _liuQinCN = <LiuQin, String>{
  LiuQin.parent: '父母', LiuQin.brother: '兄弟', LiuQin.officer: '官鬼',
  LiuQin.wife: '妻财', LiuQin.child: '子孙', LiuQin.none: '',
};

const _liuShenCN = <LiuShen, String>{
  LiuShen.qingLong: '青龙', LiuShen.zhuQue: '朱雀',
  LiuShen.gouChen: '勾陈', LiuShen.tengShe: '螣蛇',
  LiuShen.baiHu: '白虎', LiuShen.xuanWu: '玄武',
};

const _wangShuaiCN = <WangShuaiLevel, String>{
  WangShuaiLevel.wang: '旺', WangShuaiLevel.xiang: '相',
  WangShuaiLevel.xiu: '休', WangShuaiLevel.qiu: '囚',
  WangShuaiLevel.si: '死',
};

const _yaoPosCN = <YaoPosition, String>{
  YaoPosition.chu: '初', YaoPosition.er: '二', YaoPosition.san: '三',
  YaoPosition.si: '四', YaoPosition.wu: '五', YaoPosition.shang: '上',
};

// 六神背景色 — 传统国风配色
const _liuShenColors = <LiuShen, Color>{
  LiuShen.qingLong: Color(0xFF2E7D32), // 青绿
  LiuShen.zhuQue: Color(0xFFC62828),   // 朱红
  LiuShen.gouChen: Color(0xFFEF6C00),  // 橙黄
  LiuShen.tengShe: Color(0xFF7B1FA2),  // 紫
  LiuShen.baiHu: Color(0xFF78909C),    // 白灰
  LiuShen.xuanWu: Color(0xFF37474F),   // 灰黑
};

const _wangShuaiColors = <WangShuaiLevel, Color>{
  WangShuaiLevel.wang: Color(0xFF1B5E20), // 旺-深绿
  WangShuaiLevel.xiang: Color(0xFF2E7D32), // 相-绿
  WangShuaiLevel.xiu: Color(0xFF9E9D24),  // 休-黄绿
  WangShuaiLevel.qiu: Color(0xFFE65100),  // 囚-橙
  WangShuaiLevel.si: Color(0xFFB71C1C),   // 死-红
};

/// 六爻卦象展示组件 — 传统国风紧凑版
class GuaWidget extends StatelessWidget {
  final GuaModel gua;
  final bool showFooter;

  const GuaWidget({super.key, required this.gua, this.showFooter = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ds = context.watch<SettingsProvider>().display;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F0EB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF444444) : const Color(0xFFE0D5C8),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          const Divider(height: 1, thickness: 1),
          ...List.generate(6, (i) => _buildYaoRow(context, i, theme, ds)),
          if (showFooter) ...[
            const Divider(height: 1, thickness: 1),
            _buildFooter(theme, ds),
          ],
        ],
      ),
    );
  }

  /// 头部：卦名 + 宫五行 + 六冲六合标记
  Widget _buildHeader(ThemeData theme) {
    final textColor = theme.brightness == Brightness.dark
        ? const Color(0xFFE0D5C8)
        : const Color(0xFF4A3728);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text(
            _guaNameCN[gua.name] ?? '未知卦',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(width: 10),
          _wuXingBadge(theme),
          const Spacer(),
          // 六冲/六合简短标记
          Text(
            '${_guaGongCN[gua.gong] ?? ''}宫',
            style: TextStyle(fontSize: 12, color: textColor.withAlpha(220), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// 五行标签
  Widget _wuXingBadge(ThemeData theme) {
    final wx = gua.wuXing;
    final color = _wuXingColor(wx);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        _wuXingCN[wx] ?? '',
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// 单行爻渲染（上→五→四→三→二→初）
  Widget _buildYaoRow(BuildContext context, int displayIndex, ThemeData theme, DisplaySettings ds) {
    final yaoIdx = 5 - displayIndex;
    final yao = gua.yaos[yaoIdx];
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    final rowBg = displayIndex.isEven
        ? (isDark ? Colors.white.withAlpha(8) : Colors.white.withAlpha(120))
        : Colors.transparent;

    return InkWell(
      onTap: () => _showYaoRef(context, yao, theme),
      child: Container(
        decoration: BoxDecoration(color: rowBg),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            // 六神（窄竖条）
            if (ds.showLiuShen) _buildLiuShenTag(yao, theme),
            if (ds.showLiuShen) const SizedBox(width: 4),
            // 世应标记
            if (ds.showShiYing) _buildShiYingMark(yao, theme),
            // 爻画
            SizedBox(width: 40, child: _buildYaoLine(yao, theme)),
            const SizedBox(width: 6),
            // 天干
            if (ds.showTianGan) Text(
              _tianGanCN[yao.tianGan] ?? '',
              style: TextStyle(fontSize: 13, color: textColor.withAlpha(220)),
            ),
            if (ds.showTianGan) const SizedBox(width: 2),
            // 地支
            Text(
              _diZhiCN[yao.diZhi] ?? '',
              style: TextStyle(fontSize: 13, color: textColor),
            ),
            const SizedBox(width: 2),
            // 五行小标记
            if (yao.diZhi != null)
              _diZhiWuXingBadge(yao.diZhi!, theme),
            const SizedBox(width: 4),
            // 六亲
            if (yao.liuQin != LiuQin.none)
              _liuQinBadge(yao, theme),
            // 旺衰
            if (ds.showWangShuai && yao.wangShuai != null) ...[
              const SizedBox(width: 4),
              _wangShuaiBadge(yao.wangShuai!, theme),
            ],
            const Spacer(),
            // 刑冲合害标记
            if (ds.showXingChong) _buildSpecialMarks(yao, theme),
            // 动爻标记
            if (yao.isMoving)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(Icons.bolt, size: 14, color: Colors.orange.shade700),
              ),
          ],
        ),
      ),
    );
  }

  /// 六神标签 — 窄色条
  Widget _buildLiuShenTag(YaoModel yao, ThemeData theme) {
    if (yao.liuShen == null) return const SizedBox(width: 28);
    final color = _liuShenColors[yao.liuShen]!;
    return Container(
      width: 28,
      padding: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(3),
        border: Border(left: BorderSide(color: color, width: 2)),
      ),
      alignment: Alignment.center,
      child: Text(
        _liuShenCN[yao.liuShen]!.substring(0, 1),
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// 世应标记
  Widget _buildShiYingMark(YaoModel yao, ThemeData theme) {
    if (yao.isShi) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        decoration: BoxDecoration(
          color: const Color(0xFFD32F2F).withAlpha(30),
          borderRadius: BorderRadius.circular(3),
        ),
        child: const Text('世', style: TextStyle(fontSize: 11, color: Color(0xFFD32F2F), fontWeight: FontWeight.bold)),
      );
    }
    if (yao.isYing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        decoration: BoxDecoration(
          color: const Color(0xFF1976D2).withAlpha(30),
          borderRadius: BorderRadius.circular(3),
        ),
        child: const Text('应', style: TextStyle(fontSize: 11, color: Color(0xFF1976D2), fontWeight: FontWeight.bold)),
      );
    }
    return const SizedBox.shrink();
  }

  /// 爻画 — 阴阳爻
  Widget _buildYaoLine(YaoModel yao, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final lineColor = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    final movingColor = Colors.orange.shade700;

    if (yao.yinYang == YaoYinYang.yang) {
      // 阳爻 ————
      final color = yao.isMoving ? movingColor : lineColor;
      return Container(
        height: 4,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
      );
    } else {
      // 阴爻 — —
      final color = yao.isMoving ? movingColor : lineColor;
      return Row(
        children: [
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
              margin: const EdgeInsets.symmetric(vertical: 6),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
              margin: const EdgeInsets.symmetric(vertical: 6),
            ),
          ),
        ],
      );
    }
  }

  /// 地支五行小标记
  Widget _diZhiWuXingBadge(DiZhi dz, ThemeData theme) {
    final wx = _diZhiWuXing(dz);
    final color = _wuXingColor(wx);
    return Text(
      _wuXingCN[wx] ?? '',
      style: TextStyle(fontSize: 10, color: color.withAlpha(180)),
    );
  }

  /// 六亲标签
  Widget _liuQinBadge(YaoModel yao, ThemeData theme) {
    final color = _liuQinTextColor(yao.liuQin);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        _liuQinCN[yao.liuQin] ?? '',
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  /// 旺衰徽章
  Widget _wangShuaiBadge(WangShuaiLevel level, ThemeData theme) {
    final color = _wangShuaiColors[level]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        _wangShuaiCN[level] ?? '',
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// 刑冲合害特殊标记
  Widget _buildSpecialMarks(YaoModel yao, ThemeData theme) {
    final marks = <String, Color>{};
    final isDark = theme.brightness == Brightness.dark;

    if (yao.isXing) marks['刑'] = const Color(0xFF7B1FA2);
    if (yao.isChong) marks['冲'] = const Color(0xFFD32F2F);
    if (yao.isHe) marks['合'] = const Color(0xFF2E7D32);
    if (yao.isHai) marks['害'] = const Color(0xFFE65100);
    if (yao.sanHeJu.isNotEmpty) marks['三合'] = const Color(0xFF1565C0);

    if (marks.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: marks.entries.map((e) {
        return Container(
          margin: const EdgeInsets.only(left: 2),
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
          decoration: BoxDecoration(
            color: e.value.withAlpha(isDark ? 60 : 30),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            e.key,
            style: TextStyle(fontSize: 10, color: e.value, fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }

  /// 底部信息
  Widget _buildFooter(ThemeData theme, DisplaySettings ds) {
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    final shiStr = _shiYingStr(gua);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        shiStr,
        style: TextStyle(fontSize: 11, color: textColor.withAlpha(200), fontWeight: FontWeight.w500),
      ),
    );
  }

  /// 世应文本
  String _shiYingStr(GuaModel gua) {
    final shiCN = _yaoPosCN[gua.yaos[gua.shiYaoIndex].position] ?? '';
    final yingCN = _yaoPosCN[gua.yaos[gua.yingYaoIndex].position] ?? '';
    return '世在$shiCN爻 · 应在$yingCN爻';
  }

  /// 爻位参考资料弹窗 — 小白友好版
  void _showYaoRef(BuildContext context, YaoModel yao, ThemeData theme) {
    final pos = _yaoPosCN[yao.position] ?? yao.positionName;
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F0EB);
    final textColor = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    final cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (ctx2, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 标题 ──
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: textColor.withAlpha(60),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('📖 爻位详解 · $pos爻',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              const SizedBox(height: 4),
              Text('点击任意处可关闭', style: TextStyle(fontSize: 12, color: textColor.withAlpha(100))),
              const SizedBox(height: 16),

              // ── 1. 基本信息 ──
              _refSection('基本信息', [
                _refRow('爻位', '$pos爻（从下往上第${yao.position.index + 1}爻）',
                    '六爻从下往上数，依次为初爻、二爻……上爻'),
                _refRow('阴阳', yao.yinYang == YaoYinYang.yang ? '阳爻（———）' : '阴爻（— —）',
                    '阳爻代表刚健、主动；阴爻代表柔顺、被动'),
                _refRow('动静', yao.isMoving ? '动爻 ⚡（有变化）' : '静爻（无变化）',
                    yao.isMoving ? '动爻表示该爻发生变化，会生出一个变爻' : '静爻表示该爻没有变化'),
              ], cardColor, textColor, theme.colorScheme.primary),

              // ── 2. 天干地支 ──
              if (yao.tianGan != null && yao.diZhi != null) ...[
                const SizedBox(height: 12),
                _refSection('天干地支', [
                  _refRow('天干', '${_tianGanCN[yao.tianGan!]}', '天干代表天时、外在环境的影响'),
                  _refRow('地支', '${_diZhiCN[yao.diZhi!]}', '地支代表地利、内在品质'),
                  _refRow('五行', '${_wuXingCN[_diZhiWuXing(yao.diZhi!)]}',
                      '五行决定生克关系：金木水火土相生相克'),
                ], cardColor, textColor, theme.colorScheme.primary),
              ],

              // ── 3. 六亲 ──
              if (yao.liuQin != LiuQin.none) ...[
                const SizedBox(height: 12),
                _refSection('六亲（核心关系）', [
                  _refRow('六亲', '${_liuQinCN[yao.liuQin]}',
                      _liuQinDesc(yao.liuQin)),
                ], cardColor, textColor, theme.colorScheme.primary),
              ],

              // ── 4. 六神 ──
              if (yao.liuShen != null) ...[
                const SizedBox(height: 12),
                _refSection('六神（辅助信息）', [
                  _refRow('六神', '${_liuShenCN[yao.liuShen]}',
                      _liuShenDesc(yao.liuShen!)),
                ], cardColor, textColor, theme.colorScheme.primary),
              ],

              // ── 5. 世应 ──
              if (yao.isShi || yao.isYing) ...[
                const SizedBox(height: 12),
                _refSection('世应（主客定位）', [
                  if (yao.isShi)
                    _refRow('世爻', '✅ 此爻为世爻',
                        '世爻代表自己、占卜者本身，是卦的核心'),
                  if (yao.isYing)
                    _refRow('应爻', '✅ 此爻为应爻',
                        '应爻代表对方、所问之事或环境'),
                ], cardColor, textColor, theme.colorScheme.primary),
              ],

              // ── 6. 旺衰 ──
              if (yao.wangShuai != null) ...[
                const SizedBox(height: 12),
                _refSection('旺衰（力量强弱）', [
                  _refRow('旺衰', '${_wangShuaiCN[yao.wangShuai]}',
                      _wangShuaiDesc(yao.wangShuai!)),
                ], cardColor, textColor, theme.colorScheme.primary),
              ],

              // ── 7. 旬空 ──
              if (yao.isKongWang) ...[
                const SizedBox(height: 12),
                _refSection('旬空（空亡）', [
                  _refRow('旬空', '✅ 此爻逢空',
                      '旬空表示该爻暂时"不在位"，力量空虚，事情可能落空或延迟'),
                ], cardColor, textColor, theme.colorScheme.primary),
              ],

              // ── 8. 刑冲合害 ──
              if (yao.isXing || yao.isChong || yao.isHe || yao.isHai || yao.sanHeJu.isNotEmpty) ...[
                const SizedBox(height: 12),
                _refSection('刑冲合害（特殊关系）', [
                  if (yao.isXing) _refRow('刑', '✅ 相刑', '相刑代表矛盾、纠纷、互相伤害'),
                  if (yao.isChong) _refRow('冲', '✅ 相冲', '相冲代表冲突、变动、对立，事情可能有突破或破裂'),
                  if (yao.isHe) _refRow('合', '✅ 相合', '相合代表合作、和合、阻碍，事情可能被绊住'),
                  if (yao.isHai) _refRow('害', '✅ 相害', '相害代表损害、暗中伤害，需防小人'),
                  if (yao.sanHeJu.isNotEmpty)
                    _refRow('三合', '${yao.sanHeJu.join("、")}',
                        '三合代表三方合作、汇聚力量，大吉之象'),
                ], cardColor, textColor, theme.colorScheme.primary),
              ],

              // ── 关闭按钮 ──
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('关闭'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// 分区卡片标题
  Widget _refSection(String title, List<Widget> rows, Color cardColor, Color textColor, Color primary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: textColor.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primary)),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }

  /// 一行：名称 + 值 + 解释
  Widget _refRow(String label, String value, String desc) {
    final tc = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 56,
                child: Text(label,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: tc.withAlpha(180))),
              ),
              Expanded(
                child: Text(value,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: tc)),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 56, top: 1),
            child: Text(desc,
                style: TextStyle(fontSize: 12, color: tc.withAlpha(120))),
          ),
        ],
      ),
    );
  }

  /// 六亲含义查询
  String _liuQinDesc(LiuQin lq) {
    switch (lq) {
      case LiuQin.parent: return '父母爻代表长辈、文书、房屋、保护。占事业看父母爻旺衰';
      case LiuQin.brother: return '兄弟爻代表同辈、朋友、竞争者。占财见兄弟爻多不吉';
      case LiuQin.officer: return '官鬼爻代表官职、压力、祸患。占官运喜官鬼旺，占病忌官鬼';
      case LiuQin.wife: return '妻财爻代表财富、妻子、资产。占财运喜妻财爻旺';
      case LiuQin.child: return '子孙爻代表晚辈、下属、福神。占事见子孙爻主无忧';
      case LiuQin.none: return '';
    }
  }

  /// 六神含义查询
  String _liuShenDesc(LiuShen ls) {
    switch (ls) {
      case LiuShen.qingLong: return '青龙代表喜庆、贵人、文采。青龙临爻主好事将临';
      case LiuShen.zhuQue: return '朱雀代表口舌、文书、消息。朱雀临爻主有口舌是非或消息传来';
      case LiuShen.gouChen: return '勾陈代表拖延、老熟人、田产。勾陈临爻主事情进展缓慢';
      case LiuShen.tengShe: return '螣蛇代表虚惊、怪异、纠缠。螣蛇临爻主有令人不安之事';
      case LiuShen.baiHu: return '白虎代表凶事、争吵、血光。白虎临爻需防意外伤害';
      case LiuShen.xuanWu: return '玄武代表暗昧、隐晦、偷盗。玄武临爻需防小人或隐私泄露';
    }
  }

  /// 旺衰含义查询
  String _wangShuaiDesc(WangShuaiLevel level) {
    switch (level) {
      case WangShuaiLevel.wang: return '旺 — 力量最旺盛，如日中天。此爻能量最强，作用力大';
      case WangShuaiLevel.xiang: return '相 — 力量次旺，正在上升趋势。能量较强';
      case WangShuaiLevel.xiu: return '休 — 力量消退，处于休息状态。暂时无力';
      case WangShuaiLevel.qiu: return '囚 — 力量被囚禁，受制于人。能量低，难以发挥作用';
      case WangShuaiLevel.si: return '死 — 力量衰竭，毫无生气。最弱状态，无力回天';
    }
  }

  // ============ 辅助函数 ============

  Color _wuXingColor(WuXing wx) {
    switch (wx) {
      case WuXing.jin: return const Color(0xFFF9A825);
      case WuXing.mu: return const Color(0xFF2E7D32);
      case WuXing.shui: return const Color(0xFF1565C0);
      case WuXing.huo: return const Color(0xFFD32F2F);
      case WuXing.tu: return const Color(0xFF8D6E63);
    }
  }

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

  Color _liuQinTextColor(LiuQin lq) {
    switch (lq) {
      case LiuQin.parent: return const Color(0xFF1565C0);
      case LiuQin.brother: return const Color(0xFF2E7D32);
      case LiuQin.officer: return const Color(0xFFD32F2F);
      case LiuQin.wife: return const Color(0xFFE65100);
      case LiuQin.child: return const Color(0xFFF9A825);
      case LiuQin.none: return Colors.transparent;
    }
  }
}