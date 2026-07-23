/// 六爻卦象渲染组件
/// Material 3 风格，支持亮/暗主题
library;

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

const _liuShenBgColors = <LiuShen, Color>{
  LiuShen.qingLong: Color(0xFFE8F5E9), // 青绿
  LiuShen.zhuQue: Color(0xFFFFEBEE),   // 朱红
  LiuShen.gouChen: Color(0xFFFFF3E0),  // 橙黄
  LiuShen.tengShe: Color(0xFFF3E5F5),  // 紫
  LiuShen.baiHu: Color(0xFFECEFF1),    // 白灰
  LiuShen.xuanWu: Color(0xFFE0E0E0),   // 灰黑
};

/// 六爻卦象展示组件
class GuaWidget extends StatelessWidget {
  final GuaModel gua;
  final bool showFooter;

  const GuaWidget({super.key, required this.gua, this.showFooter = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 8),
            ...List.generate(6, (i) => _buildYaoRow(context, i, theme)),
            if (showFooter) ...[
              const SizedBox(height: 8),
              _buildFooter(theme),
            ],
          ],
        ),
      ),
    );
  }

  /// 头部：卦名 + 宫 + 五行
  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Text(
          _guaNameCN[gua.name] ?? '未知卦',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_guaGongCN[gua.gong] ?? ''}宫 ${_wuXingCN[gua.wuXing] ?? ''}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  /// 单行爻渲染（从上到下：上→五→四→三→二→初）
  Widget _buildYaoRow(BuildContext context, int displayIndex, ThemeData theme) {
    final yaoIdx = 5 - displayIndex; // 显示顺序反转
    final yao = gua.yaos[yaoIdx];
    final lineColor = _getYaoLineColor(yao, theme);

    return InkWell(
      onTap: () => _showDetail(context, yao, yaoIdx),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
        child: Row(
          children: [
            // 六神
            SizedBox(
              width: 28,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: yao.liuShen != null ? _liuShenBgColors[yao.liuShen] : null,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  yao.liuShen != null ? _liuShenCN[yao.liuShen]! : '',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 4),
            // 世应标记
            SizedBox(width: 18, child: _buildShiYingMark(yao, theme)),
            // 爻画
            SizedBox(width: 52, child: _buildYaoLine(yao, lineColor)),
            const SizedBox(width: 6),
            // 干支 + 六亲
            Expanded(
              child: Text(
                _yaoInfo(yao),
                style: theme.textTheme.bodyMedium,
              ),
            ),
            // 旺衰
            if (yao.wangShuai != null)
              Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: _wangShuaiColor(yao.wangShuai!).withAlpha(50),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _wangShuaiCN[yao.wangShuai]!,
                  style: TextStyle(fontSize: 11, color: _wangShuaiColor(yao.wangShuai!), fontWeight: FontWeight.bold),
                ),
              ),
            // 动爻标记
            if (yao.isMoving)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '动',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 旺衰颜色
  Color _wangShuaiColor(WangShuaiLevel level) {
    switch (level) {
      case WangShuaiLevel.wang: return Colors.green.shade700;
      case WangShuaiLevel.xiang: return Colors.blue.shade700;
      case WangShuaiLevel.xiu: return Colors.amber.shade700;
      case WangShuaiLevel.qiu: return Colors.orange.shade700;
      case WangShuaiLevel.si: return Colors.red.shade700;
    }
  }

  /// 世/应标记
  Widget? _buildShiYingMark(YaoModel yao, ThemeData theme) {
    if (yao.isShi) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          shape: BoxShape.circle,
        ),
        child: Text('世', style: TextStyle(fontSize: 10, color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
      );
    }
    if (yao.isYing) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          shape: BoxShape.circle,
        ),
        child: Text('应', style: TextStyle(fontSize: 10, color: Colors.green.shade800, fontWeight: FontWeight.bold)),
      );
    }
    return const SizedBox.shrink();
  }

  /// 绘制爻画
  Widget _buildYaoLine(YaoModel yao, Color color) {
    const lineH = 4.0;
    const totalH = 20.0;
    const yaoW = 44.0;

    return SizedBox(
      height: totalH,
      width: yaoW,
      child: Center(
        child: yao.yinYang == YaoYinYang.yang
            ? Container(height: lineH, width: yaoW, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: lineH, width: yaoW * 0.38, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 8),
                  Container(height: lineH, width: yaoW * 0.38, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                ],
              ),
      ),
    );
  }

  /// 爻线颜色（根据刑冲合害）
  Color _getYaoLineColor(YaoModel yao, ThemeData theme) {
    if (yao.isChong) return Colors.red.shade600;
    if (yao.isXing) return Colors.orange.shade600;
    if (yao.isHe) return Colors.green.shade600;
    if (yao.isHai) return Colors.grey.shade500;
    return theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87;
  }

  /// 爻的信息文字
  String _yaoInfo(YaoModel yao) {
    final gan = yao.tianGan != null ? _tianGanCN[yao.tianGan] ?? '' : '';
    final zhi = yao.diZhi != null ? _diZhiCN[yao.diZhi] ?? '' : '';
    final liuQin = _liuQinCN[yao.liuQin] ?? '';
    final parts = <String>[];
    if (gan.isNotEmpty) parts.add('$gan$zhi');
    if (liuQin.isNotEmpty) parts.add(liuQin);
    return parts.join('  ');
  }

  /// 底部：世应 + 刑冲合害说明
  Widget _buildFooter(ThemeData theme) {
    String shiPos = '';
    String yingPos = '';
    for (int i = 0; i < 6; i++) {
      if (gua.yaos[i].isShi) shiPos = _yaoPosCN[YaoPosition.values[i]] ?? '';
      if (gua.yaos[i].isYing) yingPos = _yaoPosCN[YaoPosition.values[i]] ?? '';
    }
    final hasXing = gua.yaos.any((y) => y.isXing);
    final hasChong = gua.yaos.any((y) => y.isChong);
    final hasHe = gua.yaos.any((y) => y.isHe);
    final hasHai = gua.yaos.any((y) => y.isHai);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (shiPos.isNotEmpty)
          Text('世在$shiPos爻  应在$yingPos爻', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: [
            if (hasChong) _chip('冲', Colors.red.shade100, Colors.red.shade800),
            if (hasHe) _chip('合', Colors.green.shade100, Colors.green.shade800),
            if (hasXing) _chip('刑', Colors.orange.shade100, Colors.orange.shade800),
            if (hasHai) _chip('害', Colors.grey.shade200, Colors.grey.shade700),
          ],
        ),
      ],
    );
  }

  Widget _chip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: TextStyle(fontSize: 11, color: fg)),
    );
  }

  /// 爻详情弹窗
  void _showDetail(BuildContext context, YaoModel yao, int index) {
    final pos = YaoPosition.values[index];
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${_yaoPosCN[pos] ?? ''}爻详情', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              _detailRow(theme, '阴阳', yao.yinYang == YaoYinYang.yang ? '阳爻 ———' : '阴爻 - -'),
              _detailRow(theme, '动爻', yao.isMoving ? '是 ○' : '否'),
              if (yao.tianGan != null) _detailRow(theme, '天干', _tianGanCN[yao.tianGan] ?? ''),
              if (yao.diZhi != null) _detailRow(theme, '地支', _diZhiCN[yao.diZhi] ?? ''),
              if (yao.liuShen != null) _detailRow(theme, '六神', _liuShenCN[yao.liuShen] ?? ''),
              if (yao.liuQin != LiuQin.none) _detailRow(theme, '六亲', _liuQinCN[yao.liuQin] ?? ''),
              if (yao.wangShuai != null) _detailRow(theme, '旺衰', _wangShuaiCN[yao.wangShuai] ?? ''),
              _detailRow(theme, '世爻', yao.isShi ? '是' : '否'),
              _detailRow(theme, '应爻', yao.isYing ? '是' : '否'),
              if (yao.isXing) _detailRow(theme, '刑', '是'),
              if (yao.isChong) _detailRow(theme, '冲', '是'),
              if (yao.isHe) _detailRow(theme, '合', '是'),
              if (yao.isHai) _detailRow(theme, '害', '是'),
              if (yao.sanHeJu.isNotEmpty) _detailRow(theme, '三合局', yao.sanHeJu.join(',')),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}