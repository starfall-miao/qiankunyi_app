/// 六爻卦象渲染组件 — 国风紧凑版
/// 配色参考 hexagram.qiankunyi.com.cn
import 'package:flutter/material.dart';
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
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2C2C2C)
            : const Color(0xFFF5F0EB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF444444)
              : const Color(0xFFE0D5C8),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          const Divider(height: 1, thickness: 1),
          ...List.generate(6, (i) => _buildYaoRow(context, i, theme)),
          if (showFooter) ...[
            const Divider(height: 1, thickness: 1),
            _buildFooter(theme),
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
            style: TextStyle(fontSize: 12, color: textColor.withAlpha(150)),
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
  Widget _buildYaoRow(BuildContext context, int displayIndex, ThemeData theme) {
    final yaoIdx = 5 - displayIndex;
    final yao = gua.yaos[yaoIdx];
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    final rowBg = displayIndex.isEven
        ? (isDark ? Colors.white.withAlpha(8) : Colors.white.withAlpha(120))
        : Colors.transparent;

    return Container(
      decoration: BoxDecoration(color: rowBg),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // 六神（窄竖条）
          _buildLiuShenTag(yao, theme),
          const SizedBox(width: 4),
          // 世应标记
          SizedBox(width: 18, child: _buildShiYingMark(yao, theme)),
          // 爻画
          SizedBox(width: 40, child: _buildYaoLine(yao, theme)),
          const SizedBox(width: 6),
          // 天干地支
          Text(
            _tianGanCN[yao.tianGan] ?? '',
            style: TextStyle(fontSize: 13, color: textColor.withAlpha(200)),
          ),
          const SizedBox(width: 2),
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
          if (yao.wangShuai != null) ...[
            const SizedBox(width: 4),
            _wangShuaiBadge(yao.wangShuai!, theme),
          ],
          const Spacer(),
          // 刑冲合害标记
          _buildSpecialMarks(yao, theme),
          // 动爻标记
          if (yao.isMoving)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(Icons.bolt, size: 14, color: Colors.orange.shade700),
            ),
        ],
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
  Widget _buildFooter(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    final shiStr = _shiYingStr(gua);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        shiStr,
        style: TextStyle(fontSize: 11, color: textColor.withAlpha(150)),
      ),
    );
  }

  /// 世应文本
  String _shiYingStr(GuaModel gua) {
    final shiCN = _yaoPosCN[gua.yaos[gua.shiYaoIndex].position] ?? '';
    final yingCN = _yaoPosCN[gua.yaos[gua.yingYaoIndex].position] ?? '';
    return '世在${shiCN}爻 · 应在${yingCN}爻';
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