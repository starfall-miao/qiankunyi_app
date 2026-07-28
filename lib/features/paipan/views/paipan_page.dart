// 排盘主页 — 全功能版
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/logger.dart';
import '../providers/paipan_provider.dart';
import '../../cases/providers/case_provider.dart';
import '../../cases/models/case_models.dart';
import '../engines/liuyao_engine.dart';
import '../engines/meihua_engine.dart';
import '../models/paipan_result.dart';
import '../models/gua_model.dart';
import '../models/yao_model.dart';
import 'gua_widget.dart';
import '../views/bazi_page.dart';

// ============ 中文卦名映射 ============
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

enum _YaoInput { shaoYin, shaoYang, laoYin, laoYang }

class PaipanPage extends StatefulWidget {
  const PaipanPage({super.key});
  @override
  State<PaipanPage> createState() => _PaipanPageState();
}

class _PaipanPageState extends State<PaipanPage> with SingleTickerProviderStateMixin {
  final _log = Logger.instance;
  int _tabIndex = 0;
  int _liuyaoMethod = 0;
  LiuyaoSchool _liuyaoSchool = LiuyaoSchool.jingFangJianBan;
  final _manualYaos = List<_YaoInput>.filled(6, _YaoInput.shaoYin);
  int _meihuaMethod = 0;
  final _numACtrl = TextEditingController();
  final _numBCtrl = TextEditingController();
  final _numCCtrl = TextEditingController();
  final DateTime _selectedTime = DateTime.now();
  bool _emptyInputWarn = false;
  bool _isLoading = false;
  bool _immersiveMode = false;
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400), value: 1.0);
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _numACtrl.dispose();
    _numBCtrl.dispose();
    _numCCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tp = context.watch<ThemeProvider>();
    final pr = context.watch<PaipanProvider>();
    final isDark = theme.brightness == Brightness.dark;
    final p = tp.colorSchemeType.primary;
    final t = isDark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    final b = isDark ? const Color(0xFF444444) : const Color(0xFFE0D5C8);
    final c = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F0EB),
      body: NestedScrollView(
        headerSliverBuilder: (ctx, innerScrolled) => [
          SliverAppBar(
            floating: true,
            snap: true,
            title: Text('排盘 · ${_tabIndex == 0 ? "六爻" : _tabIndex == 1 ? "梅花" : "八字"}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: Icon(tp.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                    color: const Color(0xFFD4A574)),
                onPressed: () => tp.toggleTheme(),
              ),
            ],
          ),
          // 渲染检测条（仅调试模式显示）
          if (tp.renderDebug && !_immersiveMode)
            SliverToBoxAdapter(
              child: Container(
                color: Colors.green.shade100,
                padding: const EdgeInsets.all(8),
                child: Row(children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
                  const SizedBox(width: 6),
                  Text('渲染检测：页面正常',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.green.shade800)),
                ]),
              ),
            ),
          // Tab 行
          if (!_immersiveMode)
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(color: c, border: Border(bottom: BorderSide(color: b))),
                child: Row(children: [
                  _tabBtn('六爻（铜钱）', 0, p, isDark),
                  _tabBtn('梅花易数', 1, p, isDark),
                  _tabBtn('八字', 2, p, isDark),
                ]),
              ),
            ),
        ],
        body: LayoutBuilder(
          builder: (ctx, constraints) {
            final horizontalPadding = constraints.maxWidth >= 600 ? 32.0 : 12.0;
            final content = _tabIndex == 0
                ? _liuyaoContent(context, pr, p, t, b, c, isDark)
                : _tabIndex == 1
                    ? _meihuaContent(context, pr, p, t, b, c, isDark)
                    : const BaziPage();
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
              child: content,
            );
          },
        ),
      ),
      // 沉浸式切换按钮（右下角）
      floatingActionButton: _immersiveMode
          ? FloatingActionButton.small(
              backgroundColor: p.withAlpha(200),
              onPressed: () => setState(() => _immersiveMode = false),
              child: const Icon(Icons.fullscreen_exit, color: Colors.white),
            )
          : FloatingActionButton.small(
              backgroundColor: p.withAlpha(150),
              onPressed: () => setState(() => _immersiveMode = true),
              child: const Icon(Icons.fullscreen, color: Colors.white),
            ),
    );
  }

  Widget _tabBtn(String label, int idx, Color p, bool dark) {
    final sel = _tabIndex == idx;
    final txtColor = dark ? const Color(0xFFE0D5C8) : const Color(0xFF4A3728);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _tabIndex = idx);
          _log.info('切换选项卡: ${idx == 0 ? "六爻" : "梅花"}');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: sel ? p.withAlpha(20) : Colors.transparent,
          child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: sel ? FontWeight.bold : FontWeight.normal,
              color: sel ? p : txtColor.withAlpha(160),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════ 六爻 ═══════════════════

  Widget _liuyaoContent(BuildContext context, PaipanProvider pr, Color p,
      Color t, Color b, Color c, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 方法选择
        Wrap(
          spacing: 8,
          children: List.generate(3, (i) {
            final cLabels = ['手工摇卦', '机器摇卦', '时间起卦'];
            final sel = _liuyaoMethod == i;
            return ChoiceChip(
              label: Text(cLabels[i], style: TextStyle(fontSize: 12, color: sel ? p : t)),
              selected: sel,
              onSelected: (v) => setState(() => _liuyaoMethod = i),
              selectedColor: p.withAlpha(40),
              backgroundColor: dark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2),
              side: BorderSide(color: sel ? p : b.withAlpha(80), width: sel ? 1.5 : 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              visualDensity: VisualDensity.compact,
            );
          }),
        ),
        const SizedBox(height: 8),

        // 流派选择
        Row(
          children: [
            Icon(Icons.school_outlined, size: 14, color: p.withAlpha(180)),
            const SizedBox(width: 4),
            Text('流派: ', style: TextStyle(fontSize: 12, color: t.withAlpha(200))),
            Expanded(
              child: ToggleButtons(
                isSelected: [
                  _liuyaoSchool == LiuyaoSchool.jingFangJianBan,
                  _liuyaoSchool == LiuyaoSchool.jingFangZhengZong,
                ],
                onPressed: (i) {
                  setState(() {
                    _liuyaoSchool = i == 0
                        ? LiuyaoSchool.jingFangJianBan
                        : LiuyaoSchool.jingFangZhengZong;
                  });
                },
                constraints: const BoxConstraints(minWidth: 80, minHeight: 28),
                textStyle: TextStyle(fontSize: 12, color: t),
                selectedColor: p,
                fillColor: p.withAlpha(20),
                color: t.withAlpha(150),
                borderRadius: BorderRadius.circular(6),
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('京房简版')),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('京房正宗')),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 手工摇——爻位选择面板（国风卦签风格）
        if (_liuyaoMethod == 0) ..._buildManualPanel(p, t, b, c, dark),

        // 起卦按钮
        SizedBox(
          height: 44,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _submitLiuyao(pr),
            icon: _isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.auto_awesome, size: 18),
            label: Text(_isLoading ? '起卦中…' : '起卦', style: const TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: p, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 排盘结果
        FadeTransition(
          opacity: _fadeAnim,
          child: pr.liuyaoResult != null ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          // ── 装饰标题 ──
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: p.withAlpha(60))),
            ),
            child: Row(
              children: [
                Text('☯ ', style: TextStyle(fontSize: 18, color: p)),
                Text('六爻纳甲 · 排盘结果',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t)),
              ],
            ),
          ),
          // ── 月令/日令/空亡/流派信息 ──
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: p.withAlpha(12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: p.withAlpha(30)),
            ),
            child: Row(
              children: [
                if (pr.liuyaoResult!.monthGanZhi != null) ...[
                  _dateTag('月', pr.liuyaoResult!.monthGanZhi!, p, t),
                  const SizedBox(width: 8),
                ],
                if (pr.liuyaoResult!.dayGanZhi != null) ...[
                  _dateTag('日', pr.liuyaoResult!.dayGanZhi!, p, t),
                  const SizedBox(width: 8),
                ],
                if (pr.liuyaoResult!.kongWang != null) ...[
                  _dateTag('空', '旬空: ${pr.liuyaoResult!.kongWang!.join(" ")}', p, t),
                  const SizedBox(width: 8),
                ],
                _dateTag(
                  '派',
                  pr.liuyaoResult!.school == LiuyaoSchool.jingFangJianBan ? '京房简版' : '京房正宗',
                  p, t,
                ),
              ],
            ),
          ),
          // ── 六爻三卦 ──
          LayoutBuilder(
            builder: (ctx2, constraints) {
              final isWide = constraints.maxWidth >= 340;
              final cards = <Widget>[
                _miniGuaCard('本卦', pr.liuyaoResult!.benGua, p, t, c, dark),
                if (pr.liuyaoResult!.bianGua != null)
                  _miniGuaCard('变卦', pr.liuyaoResult!.bianGua!, p, t, c, dark),
                if (pr.liuyaoResult!.huGua != null)
                  _miniGuaCard('互卦', pr.liuyaoResult!.huGua!, p, t, c, dark),
              ];
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cards.expand((w) => [Expanded(child: w), const SizedBox(width: 8)]).toList()..removeLast(),
                );
              }
              return Column(
                children: cards.expand((w) => [w, const SizedBox(height: 8)]).toList()..removeLast(),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => pr.clearLiuyao(),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('清空排盘'),
                style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () => _shareResult(context, pr.liuyaoResult!),
                icon: const Icon(Icons.copy_outlined, size: 16),
                label: const Text('复制结果'),
                style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () => _saveCurrentResult(context, pr, pr.liuyaoResult!),
                icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                label: const Text('保存卦例'),
                style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text('💡 保存为卦例后可在详情页使用 AI 解卦与人工断语',
                style: TextStyle(fontSize: 12, color: t.withAlpha(150))),
          ),
        ],
      )
    : _emptyHint(p, t),
    ),
  ],
);
  }

  void _submitLiuyao(PaipanProvider pr) {
    if (_isLoading) return; // 防止重复点击
    setState(() => _isLoading = true);
    _animCtrl.reset();

    try {
      PaipanResult r;
      if (_liuyaoMethod == 0) {
        final ys = <YaoModel>[];
        for (int i = 0; i < 6; i++) {
          final v = _manualYaos[i];
          ys.add(YaoModel(
            yinYang: (v == _YaoInput.shaoYang || v == _YaoInput.laoYang)
                ? YaoYinYang.yang : YaoYinYang.yin,
            position: YaoPosition.values[5 - i],
            isMoving: v == _YaoInput.laoYin || v == _YaoInput.laoYang,
          ));
        }
        r = LiuYaoEngine.fromYaos(ys, time: _selectedTime, school: _liuyaoSchool);
      } else if (_liuyaoMethod == 1) {
        r = LiuYaoEngine.manual(school: _liuyaoSchool);
      } else {
        r = LiuYaoEngine.byTime(_selectedTime, school: _liuyaoSchool);
      }

      // 模拟短加载延迟（增强仪式感）
      Future.delayed(const Duration(milliseconds: 300), () {
        pr.setLiuyaoResult(r);
        _animCtrl.forward();
        setState(() => _isLoading = false);
        final names = ['手工摇卦', '机器摇卦', '时间起卦'];
        _log.info('六爻起卦: ${names[_liuyaoMethod]}', '${r.benGua.name}');
      });
    } catch (e, st) {
      _log.error('六爻起卦失败', '$e\n$st');
      setState(() => _isLoading = false);
    }
  }

  // ═══════════════════ 手工摇面板（国风卦签样式） ═══════════════════

  List<Widget> _buildManualPanel(Color p, Color t, Color b, Color c, bool dark) {
    final pos = ['初爻', '二爻', '三爻', '四爻', '五爻', '上爻'];
    final opts = [_YaoInput.shaoYin, _YaoInput.shaoYang, _YaoInput.laoYin, _YaoInput.laoYang];
    final lbs = ['少阴', '少阳', '老阴', '老阳'];

    return [
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: b),
        ),
        child: Column(
          children: List.generate(6, (i) {
            final idx = 5 - i;
            final v = _manualYaos[idx];
            final mv = v == _YaoInput.laoYin || v == _YaoInput.laoYang;
            final yg = v == _YaoInput.shaoYang || v == _YaoInput.laoYang;
            final rowColor = i.isEven
                ? (dark ? Colors.white.withAlpha(8) : Colors.grey.shade50)
                : Colors.transparent;

            // 爻画颜色
            final yaoColor = mv
                ? (yg ? const Color(0xFFD4A574) : const Color(0xFF8B4513))
                : (yg ? const Color(0xFF3E2723) : const Color(0xFF8D6E63));

            return Container(
              decoration: BoxDecoration(color: rowColor),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  // 爻位名
                  SizedBox(width: 30,
                    child: Text(pos[i],
                        style: TextStyle(fontSize: 11, color: t, fontWeight: FontWeight.w500))),
                  const SizedBox(width: 6),
                  // 分隔线
                  Container(width: 1, height: 20, color: b.withAlpha(80)),
                  const SizedBox(width: 8),
                  // 爻画（粗线条风格，模拟 GuaWidget 的视觉）
                  Container(
                    width: 44, height: 14,
                    decoration: BoxDecoration(
                      color: yaoColor,
                      borderRadius: BorderRadius.circular(2),
                      border: mv ? Border.all(color: const Color(0xFFD4A574).withAlpha(120), width: 1) : null,
                    ),
                    alignment: Alignment.center,
                    child: mv
                        ? Text(v == _YaoInput.laoYang ? '⚊' : '⚋',
                            style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))
                        : null,
                  ),
                  const SizedBox(width: 8),
                  // 动爻标记
                  if (mv)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A574).withAlpha(30),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text('动', style: TextStyle(fontSize: 9, color: Color(0xFFD4A574), fontWeight: FontWeight.bold)),
                    )
                  else
                    const SizedBox(width: 18),
                  const Spacer(),
                  // 四型按钮组
                  ...List.generate(4, (j) {
                    final s = v == opts[j];
                    return GestureDetector(
                      onTap: () => setState(() => _manualYaos[idx] = opts[j]),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: s ? p.withAlpha(25) : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: s ? p : b.withAlpha(100),
                            width: s ? 1.5 : 1,
                          ),
                        ),
                        child: Text(lbs[j],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: s ? FontWeight.bold : FontWeight.normal,
                              color: s ? p : t.withAlpha(180),
                            )),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ),
      ),
      const SizedBox(height: 8),
    ];
  }

  // ═══════════════════ 梅花 ═══════════════════

  Widget _meihuaContent(BuildContext context, PaipanProvider pr, Color p,
      Color t, Color b, Color c, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          children: List.generate(2, (i) {
            final labels = ['三数起卦', '日期起卦'];
            final sel = _meihuaMethod == i;
            return ChoiceChip(
              label: Text(labels[i], style: TextStyle(fontSize: 12, color: sel ? p : t)),
              selected: sel,
              onSelected: (v) => setState(() {
                _meihuaMethod = i;
                _emptyInputWarn = false;
              }),
              selectedColor: p.withAlpha(40),
              backgroundColor: dark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F6F2),
              side: BorderSide(color: sel ? p : b.withAlpha(80), width: sel ? 1.5 : 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              visualDensity: VisualDensity.compact,
            );
          }),
        ),
        const SizedBox(height: 8),

        if (_meihuaMethod == 0) ...[
          Row(children: [
            _numField('A', _numACtrl, '数字1'),
            const SizedBox(width: 8),
            _numField('B', _numBCtrl, '数字2'),
            const SizedBox(width: 8),
            _numField('C', _numCCtrl, '数字3'),
          ]),
          if (_emptyInputWarn)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('⚠ 请填写数字后再起卦', style: TextStyle(fontSize: 11, color: Colors.red.shade700)),
            ),
        ],

        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _submitMeihua(pr),
            icon: _isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.auto_awesome, size: 18),
            label: Text(_isLoading ? '起卦中…' : '起卦', style: const TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: p, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 12),

        FadeTransition(
          opacity: _fadeAnim,
          child: pr.meihuaResult != null
              ? _meihuaResultSection(context, pr, pr.meihuaResult!, p, t, b, c, dark)
              : _emptyHint(p, t),
        ),
      ],
    );
  }

  void _submitMeihua(PaipanProvider pr) {
    if (_isLoading) return; // 防止重复点击
    setState(() => _isLoading = true);
    _animCtrl.reset();

    try {
      if (_meihuaMethod == 0) {
        final aText = _numACtrl.text.trim();
        final bText = _numBCtrl.text.trim();
        final cText = _numCCtrl.text.trim();
        if (aText.isEmpty || bText.isEmpty || cText.isEmpty) {
          setState(() {
            _isLoading = false;
            _emptyInputWarn = true;
          });
          return;
        }
        setState(() => _emptyInputWarn = false);
        final a = int.tryParse(aText) ?? 0;
        final b = int.tryParse(bText) ?? 0;
        final c = int.tryParse(cText) ?? 0;
        Future.delayed(const Duration(milliseconds: 300), () {
          pr.setMeihuaResult(MeihuaEngine.fromNumbers(a, b, c));
          _animCtrl.forward();
          setState(() => _isLoading = false);
          _log.info('梅花起卦: 三数($a,$b,$c)');
        });
      } else {
        Future.delayed(const Duration(milliseconds: 300), () {
          pr.setMeihuaResult(MeihuaEngine.fromDateTime(_selectedTime));
          _animCtrl.forward();
          setState(() => _isLoading = false);
          _log.info('梅花起卦: 日期${_selectedTime.year}${_selectedTime.month}${_selectedTime.day}');
        });
      }
    } catch (e, st) {
      _log.error('梅花起卦失败', '$e\n$st');
      setState(() => _isLoading = false);
    }
  }

  void _saveCurrentResult(BuildContext context, PaipanProvider pr, PaipanResult result) {
    final guaCN = <GuaName, String>{
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
    final guaNameCN = guaCN[result.benGua.name] ?? result.benGua.name.name;

    // Dialog 让用户输入标题
    final titleCtrl = TextEditingController(text: '$guaNameCN — ${methodToCN(result.method)}');
    final notesCtrl = TextEditingController();
    final duanYuCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('保存卦例'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: '标题', hintText: '为卦例取个名字'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(labelText: '备注（可选）', hintText: '记录占问事项'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: duanYuCtrl,
              decoration: const InputDecoration(labelText: '断语（可选）', hintText: '输入你的分析判断'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              final cm = CaseModel.fromPaipanResult(
                result: result,
                title: titleCtrl.text.trim(),
                notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                duanYu: duanYuCtrl.text.trim().isEmpty ? null : duanYuCtrl.text.trim(),
              );
              context.read<CaseProvider>().addCase(cm);
              _log.info('保存卦例: ${cm.title}');
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已保存到卦例库，可到卦例页查看详情和 AI 解卦'),
                    duration: Duration(seconds: 3)),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _shareResult(BuildContext ctx, PaipanResult result) {
    final gongCN = <GuaGong, String>{
      GuaGong.qian: '乾', GuaGong.dui: '兑', GuaGong.li: '离',
      GuaGong.zhen: '震', GuaGong.xun: '巽', GuaGong.kan: '坎',
      GuaGong.gen: '艮', GuaGong.kun: '坤',
    };
    final wxCN = <WuXing, String>{
      WuXing.jin: '金', WuXing.mu: '木', WuXing.shui: '水', WuXing.huo: '火', WuXing.tu: '土',
    };

    final bn = _guaNameCN[result.benGua.name] ?? result.benGua.name.name;
    final bg = gongCN[result.benGua.gong] ?? '';
    final bw = wxCN[result.benGua.wuXing] ?? '';
    final timeStr = '${result.paipanTime.year}/${result.paipanTime.month}/${result.paipanTime.day} ${result.paipanTime.hour}:${result.paipanTime.minute.toString().padLeft(2, '0')}';
    final yaosStr = result.benGua.yaos.map((y) =>
      '${y.positionName}爻 ${y.yinYang == YaoYinYang.yang ? '———' : '— —'}${y.isMoving ? ' ⚡动' : ''}'
    ).toList().reversed.join('\n');

    final buf = StringBuffer()
      ..writeln('【落·乾坤】排盘结果')
      ..writeln('━━━━━━━━━━━━━━')
      ..writeln('卦名：$bn')
      ..writeln('宫位：$bg宫 · 五行 $bw')
      ..writeln('方式：$result.method')
      ..writeln('时间：$timeStr')
      ..writeln('━━━━━━━━━━━━━━')
      ..writeln(yaosStr);
    if (result.bianGua != null) {
      final bn2 = _guaNameCN[result.bianGua!.name] ?? result.bianGua!.name.name;
      buf.writeln('━━━━━━━━━━━━━━');
      buf.writeln('▸ 变卦：$bn2');
    }
    if (result.huGua != null) {
      final bn3 = _guaNameCN[result.huGua!.name] ?? result.huGua!.name.name;
      buf.writeln('▸ 互卦：$bn3');
    }
    buf.writeln('━━━━━━━━━━━━━━');
    buf.writeln('—— 来自「落·乾坤」');

    Clipboard.setData(ClipboardData(text: buf.toString()));
    _log.info('排盘结果已复制到剪贴板: $bn');
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: const Text('排盘结果已复制到剪贴板'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _numField(String label, TextEditingController ctrl, String hint) {
    return Expanded(
      child: TextField(
        controller: ctrl, keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label, hintText: hint, isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  // ═══════════════════ 通用 ═══════════════════

  Widget _emptyHint(Color p, Color t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(children: [
        Icon(Icons.auto_awesome, size: 48, color: p.withAlpha(60)),
        const SizedBox(height: 12),
        Text('选择排盘方式后点「起卦」', style: TextStyle(fontSize: 14, color: t.withAlpha(180))),
      ]),
    );
  }

  /// 梅花易数结果区域 — 三卦并排 + 体用生克
  Widget _meihuaResultSection(BuildContext context, PaipanProvider pr,
      PaipanResult result, Color p, Color t, Color b, Color c, bool dark) {
    final gongCN = <GuaGong, String>{
      GuaGong.qian: '乾', GuaGong.dui: '兑', GuaGong.li: '离',
      GuaGong.zhen: '震', GuaGong.xun: '巽', GuaGong.kan: '坎',
      GuaGong.gen: '艮', GuaGong.kun: '坤',
    };
    final wxCN = <WuXing, String>{
      WuXing.jin: '金', WuXing.mu: '木', WuXing.shui: '水', WuXing.huo: '火', WuXing.tu: '土',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 装饰标题 ──
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: p.withAlpha(60))),
          ),
          child: Row(
            children: [
              Text('🔮 ', style: TextStyle(fontSize: 18, color: p)),
              Text('梅花易数 · 排盘结果',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t)),
            ],
          ),
        ),

        // ── 三卦：宽屏并排 / 窄屏竖排 ──
        LayoutBuilder(
          builder: (ctx2, constraints) {
            final isWide = constraints.maxWidth >= 340;
            final cards = <Widget>[
              _miniGuaCard('本卦', result.benGua, p, t, c, dark),
              if (result.bianGua != null) ...[
                const SizedBox(width: 8),
                _miniGuaCard('变卦', result.bianGua!, p, t, c, dark),
              ],
              if (result.huGua != null) ...[
                const SizedBox(width: 8),
                _miniGuaCard('互卦', result.huGua!, p, t, c, dark),
              ],
            ];

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: cards.map((w) => w is SizedBox ? w : Expanded(child: w)).toList(),
              );
            } else {
              // 窄屏：竖排，去掉 SizedBox 间的 width
              return Column(
                children: cards.where((w) => w is! SizedBox).map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: w,
                )).toList(),
              );
            }
          },
        ),

        const SizedBox(height: 14),

        // ── 体用生克 ──
        if (result.benGua.yaos.length >= 6) ...[
          _buildTiYongEnhanced(result, p, t, c, gongCN, wxCN),
          const SizedBox(height: 12),
        ],

        // ── 操作按钮 ──
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () => pr.clearMeihua(),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('清空排盘'),
              style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: () => _shareResult(context, result),
              icon: const Icon(Icons.copy_outlined, size: 16),
              label: const Text('复制结果'),
              style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: () => _saveCurrentResult(context, pr, result),
              icon: const Icon(Icons.bookmark_add_outlined, size: 16),
              label: const Text('保存卦例'),
              style: TextButton.styleFrom(foregroundColor: t.withAlpha(200)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Text('💡 保存为卦例后可在详情页使用 AI 解卦与人工断语',
              style: TextStyle(fontSize: 12, color: t.withAlpha(150))),
        ),
      ],
    );
  }

  /// 月令/日令/空亡 等日期标签
  Widget _dateTag(String icon, String text, Color p, Color t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: p.withAlpha(15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: p.withAlpha(30)),
      ),
      child: Text('$icon $text',
        style: TextStyle(fontSize: 11, color: t.withAlpha(220)),),
    );
  }

  /// 迷你卦卡 — 用于梅花三卦并排
  Widget _miniGuaCard(String label, GuaModel gua, Color p, Color t, Color c, bool dark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: p)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: p.withAlpha(60)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: GuaWidget(gua: gua, showFooter: false),
        ),
        const SizedBox(height: 4),
        Text(_guaNameCN[gua.name] ?? gua.name.name,
          style: TextStyle(fontSize: 11, color: t.withAlpha(200)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 增强版体用生克卡片
  Widget _buildTiYongEnhanced(PaipanResult result, Color p, Color t, Color c,
      Map<GuaGong, String> gongCN, Map<WuXing, String> wxCN) {
    final desc = MeihuaEngine.getTiYong(result);

    Color bgC;
    Color borderC;
    Color txtC;
    IconData icon;
    String relationLabel;

    if (desc.contains('比和')) {
      bgC = const Color(0xFFE8F5E9);
      borderC = const Color(0xFF2E7D32);
      txtC = const Color(0xFF2E7D32);
      icon = Icons.check_circle_outline;
      relationLabel = '体用比和 · 顺遂';
    } else if (desc.contains('用生体') || desc.contains('进益')) {
      bgC = const Color(0xFFE8F5E9);
      borderC = const Color(0xFF2E7D32);
      txtC = const Color(0xFF2E7D32);
      icon = Icons.trending_up;
      relationLabel = '用生体 · 进益之喜';
    } else if (desc.contains('用克体') || desc.contains('凶险')) {
      bgC = const Color(0xFFFFEBEE);
      borderC = const Color(0xFFD32F2F);
      txtC = const Color(0xFFD32F2F);
      icon = Icons.warning_amber_outlined;
      relationLabel = '用克体 · 凶险多阻';
    } else if (desc.contains('体克用')) {
      bgC = const Color(0xFFFFF3E0);
      borderC = const Color(0xFFEF6C00);
      txtC = const Color(0xFFEF6C00);
      icon = Icons.auto_fix_high;
      relationLabel = '体克用 · 费力可成';
    } else if (desc.contains('体生用')) {
      bgC = const Color(0xFFE3F2FD);
      borderC = const Color(0xFF1565C0);
      txtC = const Color(0xFF1565C0);
      icon = Icons.call_made;
      relationLabel = '体生用 · 有耗损';
    } else {
      bgC = const Color(0xFFF5F5F5);
      borderC = const Color(0xFFE0E0E0);
      txtC = const Color(0xFF4A3728);
      icon = Icons.info_outline;
      relationLabel = desc;
    }

    // 解析体用字符串
    String tiPart = '';
    String yongPart = '';
    final tiMatch = RegExp(r'体卦：(.+?)[）)]').firstMatch(desc);
    final yongMatch = RegExp(r'用卦：(.+?)[—]').firstMatch(desc);
    if (tiMatch != null) tiPart = tiMatch.group(1) ?? '';
    if (yongMatch != null) yongPart = yongMatch.group(1) ?? '';
    // fallback
    if (tiPart.isEmpty && desc.contains('体卦：')) {
      tiPart = desc.split('体卦：')[1].split(' ')[0];
    }
    if (yongPart.isEmpty && desc.contains('用卦：')) {
      yongPart = desc.split('用卦：')[1].split(' —')[0];
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgC,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderC.withAlpha(80), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: txtC, size: 20),
              const SizedBox(width: 8),
              Text('体用生克',
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: txtC)),
            ],
          ),
          const SizedBox(height: 10),
          // 体卦 / 用卦 标签
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    color: txtC.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(tiPart,
                    style: TextStyle(fontSize: 12, color: txtC, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.swap_horiz, color: txtC.withAlpha(120), size: 18),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    color: txtC.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(yongPart,
                    style: TextStyle(fontSize: 12, color: txtC, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(relationLabel,
              style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: txtC)),
          ),
        ],
      ),
    );
  }




