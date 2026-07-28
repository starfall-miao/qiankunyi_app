/// 八字排盘页面
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bazi_provider.dart';
import '../models/bazi_models.dart';

class BaziPage extends StatefulWidget {
  const BaziPage({super.key});

  @override
  State<BaziPage> createState() => _BaziPageState();
}

class _BaziPageState extends State<BaziPage> {
  DateTime? _birth;
  bool _isMale = true;
  int _hourIndex = 12; // 默认午时

  final _hourOptions = const [
    '子时(23-1)', '丑时(1-3)', '寅时(3-5)', '卯时(5-7)',
    '辰时(7-9)', '巳时(9-11)', '午时(11-13)', '未时(13-15)',
    '申时(15-17)', '酉时(17-19)', '戌时(19-21)', '亥时(21-23)',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = theme.colorScheme.onSurface;
    final p = theme.colorScheme.primary;
    final bp = context.watch<BaziProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 输入区域
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('出生信息', style: TextStyle(fontSize: 16,
                        fontWeight: FontWeight.bold, color: p)),
                    const SizedBox(height: 12),
                    // 日期选择
                    InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _birth ?? DateTime(1990, 1, 1),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) setState(() => _birth = d);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: t.withAlpha(40)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(children: [
                          Icon(Icons.calendar_today_outlined, size: 20, color: p),
                          const SizedBox(width: 12),
                          Text(_birth != null
                              ? '${_birth!.year}/${_birth!.month}/${_birth!.day}'
                              : '请选择出生日期',
                              style: TextStyle(fontSize: 15, color: t)),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 时辰
                    Text('选择时辰', style: TextStyle(fontSize: 14, color: t.withAlpha(180))),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: List.generate(12, (i) {
                        final sel = _hourIndex == i;
                        return ChoiceChip(
                          label: Text(_hourOptions[i].split('(')[0],
                              style: TextStyle(fontSize: 12, color: sel ? p : t)),
                          selected: sel,
                          onSelected: (v) => setState(() => _hourIndex = i),
                          selectedColor: p.withAlpha(30),
                          backgroundColor: t.withAlpha(15),
                          side: BorderSide(color: sel ? p.withAlpha(120) : t.withAlpha(30)),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    // 性别
                    Row(children: [
                      Text('性别：', style: TextStyle(fontSize: 14, color: t)),
                      Expanded(child: Row(children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('男'),
                            selected: _isMale,
                            onSelected: (v) => setState(() => _isMale = true),
                            selectedColor: p.withAlpha(30),
                            backgroundColor: t.withAlpha(15),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('女'),
                            selected: !_isMale,
                            onSelected: (v) => setState(() => _isMale = false),
                            selectedColor: p.withAlpha(30),
                            backgroundColor: t.withAlpha(15),
                          ),
                        ),
                      ])),
                    ]),
                    const SizedBox(height: 16),
                    // 起卦按钮
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: _birth == null || bp.isCalculating
                            ? null
                            : () => bp.calc(birth: _birth!, isMale: _isMale, hourIndex: _hourIndex),
                        icon: bp.isCalculating
                            ? const SizedBox(width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.auto_awesome, size: 18),
                        label: Text(bp.isCalculating ? '排盘中…' : '开始排盘',
                            style: const TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: p, foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 排盘结果
            if (bp.hasResult) _buildResult(bp.result!, t, p),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(BaziResult r, Color t, Color p) {
    final zhuList = [r.yearZhu, r.monthZhu, r.dayZhu, r.hourZhu];
    final labels = ['年柱', '月柱', '日柱', '时柱'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 标题
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.withAlpha(60)))),
          child: Row(children: [
            Text('✦ ', style: TextStyle(fontSize: 18, color: p)),
            Text('八字排盘 · 命理分析',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t)),
          ]),
        ),
        const SizedBox(height: 12),

        // 四柱
        Row(
          children: List.generate(4, (i) {
            final z = zhuList[i];
            return Expanded(
              child: Card(
                margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  child: Column(children: [
                    Text(labels[i], style: TextStyle(fontSize: 12, color: t.withAlpha(120))),
                    const SizedBox(height: 4),
                    Text(z.ganZhi, style: TextStyle(fontSize: 20,
                        fontWeight: FontWeight.bold, color: p)),
                    Text(z.tianGanCN, style: TextStyle(fontSize: 13, color: t)),
                  ]),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),

        // 大运
        if (r.daYun.isNotEmpty) ...[
          Text('大运', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: p)),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: r.daYun.map((dy) {
                return Container(
                  width: 70,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: t.withAlpha(10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: t.withAlpha(20)),
                  ),
                  child: Column(children: [
                    Text('${dy.startAge}岁起', style: TextStyle(fontSize: 11, color: t.withAlpha(120))),
                    const SizedBox(height: 2),
                    Text(dy.ganZhi, style: TextStyle(fontSize: 16,
                        fontWeight: FontWeight.bold, color: t)),
                  ]),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // 流年
        if (r.liuNian != null) ...[
          Text('当年流年', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: p)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: t.withAlpha(10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: t.withAlpha(20)),
            ),
            child: Row(children: [
              const Icon(Icons.calendar_month_outlined, size: 18, color: Colors.deepOrange),
              const SizedBox(width: 8),
              if (r.liuNian != null) ...[
                Text('当年流年：', style: TextStyle(fontSize: 13, color: t)),
                Text(r.liuNian!, style: TextStyle(fontSize: 16,
                    fontWeight: FontWeight.bold, color: Colors.deepOrange)),
              ] else
                Text('当年流年', style: TextStyle(fontSize: 14, color: t)),
            ]),
          ),
        ],
      ],
    );
  }
}
