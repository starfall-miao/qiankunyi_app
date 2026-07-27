/// 参考资料页面
/// 展示六十四卦（八宫分组）、纳音、星宿、象意、禽星、神煞、动变等参考信息
library;

import 'package:flutter/material.dart';
import '../data/reference_data.dart';
import '../data/xiangyi_data.dart';
import '../data/qinxing_data.dart';
import '../data/shensha_dictionary.dart';
import '../data/dongbian_dictionary.dart';
import '../data/yaoci_data.dart';
import '../data/meihua_data.dart';
import '../data/liuyao_reference_data.dart';
import '../data/bazi_reference_data.dart';
import '../../paipan/models/gua_model.dart';

class ReferencePage extends StatelessWidget {
  const ReferencePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 10,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('参考资料'),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: null,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(text: '六十四卦'),
              Tab(text: '纳音'),
              Tab(text: '二十八星宿'),
              Tab(text: '象意字典'),
              Tab(text: '禽星关系'),
              Tab(text: '神煞象义'),
              Tab(text: '动变含义'),
              Tab(text: '梅花易数'),
              Tab(text: '六爻纳甲'),
              Tab(text: '八字'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _GuaCiTab(),
            _NaYinTab(),
            _XingXiuTab(),
            _XiangYiTab(),
            _QinXingTab(),
            _ShenShaTab(),
            _DongBianTab(),
            _MeiHuaTab(),
            _LiuYaoRefTab(),
            _BaziRefTab(),
          ],
        ),
            _XiangYiTab(),
            _QinXingTab(),
            _ShenShaTab(),
            _DongBianTab(),
            _MeiHuaTab(),
            _LiuYaoRefTab(),
          ],
        ),
      ),
    );
  }
}

/// ──────────────── 六爻纳甲 ────────────────

class _LiuYaoRefTab extends StatelessWidget {
  const _LiuYaoRefTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = theme.colorScheme.primary;
    final t = theme.colorScheme.onSurface.withAlpha(200);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // ── 六神详解 ──
        _sectionHeader(p, '六神详解'),
        ...liuShenList.map((s) => Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: Color(int.parse(s.colorHex.replaceFirst('#', '0xFF'))),
              child: Text(s.name[0], style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${s.wuXing} · ${s.season}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => _showDetailDialog(context, s.name, s.meaning),
          ),
        )),
        const SizedBox(height: 12),

        // ── 世应规则 ──
        _sectionHeader(p, '世应规则（八宫）'),
        Card(
          child: Table(
            columnWidths: const {0: FlexColumnWidth(1.5), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
            children: [
              TableRow(
                decoration: BoxDecoration(color: p.withAlpha(15)),
                children: ['宫', '世爻', '应爻'].map((h) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text(h, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: p)),
                )).toList(),
              ),
              ...shiYingTable.map((row) => TableRow(
                children: [
                  _cell(row['宫']!, t),
                  _cell(row['世']!, t),
                  _cell(row['应']!, t),
                ],
              )),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── 旬空表 ──
        _sectionHeader(p, '旬空表'),
        Card(
          child: Table(
            columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
            children: [
              TableRow(
                decoration: BoxDecoration(color: p.withAlpha(15)),
                children: ['旬首', '空亡'].map((h) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text(h, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: p)),
                )).toList(),
              ),
              ...xunKongTable.map((row) => TableRow(
                children: [
                  _cell(row.jiaZi, t),
                  _cell(row.kongWang, t),
                ],
              )),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── 五行旺衰 ──
        _sectionHeader(p, '五行旺衰（月建）'),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              columnWidths: const {0: FlexColumnWidth(1.5), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1), 4: FlexColumnWidth(1), 5: FlexColumnWidth(1)},
              children: [
                TableRow(
                  decoration: BoxDecoration(color: p.withAlpha(15)),
                  children: ['月建', '旺', '相', '休', '囚', '死'].map((h) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Text(h, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: p)),
                  )).toList(),
                ),
                ...wangShuaiTable.map((row) => TableRow(
                  children: [
                    _cell(row['月建']!, t),
                    _cell(row['旺']!, t),
                    _cell(row['相']!, t),
                    _cell(row['休']!, t),
                    _cell(row['囚']!, t),
                    _cell(row['死']!, t),
                  ],
                )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ── 纳甲表 ──
        _sectionHeader(p, '纳甲表（内卦/外卦天干）'),
        Card(
          child: Table(
            columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1.5), 2: FlexColumnWidth(1.5)},
            children: [
              TableRow(
                decoration: BoxDecoration(color: p.withAlpha(15)),
                children: ['卦', '内卦天干', '外卦天干'].map((h) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text(h, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: p)),
                )).toList(),
              ),
              ...naJiaTable.map((row) => TableRow(
                children: [
                  _cell(row.gua, t),
                  _cell(row.innerGan, t),
                  _cell(row.outerGan, t),
                ],
              )),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── 五行生克 ──
        _sectionHeader(p, '五行生克（六亲基础）'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: wuXingRelation.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text('• $r', style: TextStyle(fontSize: 13, color: t)),
              )).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ── 六亲含义 ──
        _sectionHeader(p, '六亲含义'),
        Card(
          child: Table(
            columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(3)},
            children: [
              TableRow(
                decoration: BoxDecoration(color: p.withAlpha(15)),
                children: ['六亲', '含义'].map((h) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text(h, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: p)),
                )).toList(),
              ),
              ...liuQinMeanings.map((row) => TableRow(
                children: [
                  _cell(row['亲']!, t),
                  _cell(row['含义']!, t),
                ],
              )),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _cell(String text, Color c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: c)),
    );
  }

  void _showDetailDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('关闭'))],
      ),
    );
  }
}

/// ──────────────── 八字参考 Tab ────────────────

class _BaziRefTab extends StatelessWidget {
  const _BaziRefTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = theme.colorScheme.primary;
    final t = theme.colorScheme.onSurface.withAlpha(200);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _sectionHeader(p, '八字基础'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text('八字命理，又称四柱预测，是以人出生的年、月、日、时四柱（每柱天干地支，共八个字）推算命运。日柱天干代表"日元"，是命局的核心。',
                style: TextStyle(fontSize: 13, color: t.withAlpha(180))),
          ),
        ),
        const SizedBox(height: 12),

        _sectionHeader(p, '十天干'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Table(
              columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
              children: [
                TableRow(decoration: BoxDecoration(color: p.withAlpha(20)),
                  children: ['天干', '五行', '阴阳'].map((h) => _cell(h, p)).toList()),
                ...tianGanTable.map((row) => TableRow(
                  children: ['天干', '五行', '阴阳'].map((k) => _cell(row[k] ?? '', t)).toList(),
                )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        _sectionHeader(p, '十二地支'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Table(
              columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1)},
              children: [
                TableRow(decoration: BoxDecoration(color: p.withAlpha(20)),
                  children: ['地支', '生肖', '五行', '月份'].map((h) => _cell(h, p)).toList()),
                ...diZhiTable.map((row) => TableRow(
                  children: ['地支', '生肖', '五行', '月份'].map((k) => _cell(row[k] ?? '', t)).toList(),
                )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        _sectionHeader(p, '十神表（以日干为基准）'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Table(
              columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
              children: [
                TableRow(decoration: BoxDecoration(color: p.withAlpha(20)),
                  children: ['同我', '生我', '我生'].map((h) => _cell(h, p)).toList()),
                TableRow(children: [
                  _cell('比肩', t),
                  _cell('偏印', t),
                  _cell('食神', t),
                ]),
                TableRow(children: [
                  _cell('劫财', t),
                  _cell('正印', t),
                  _cell('伤官', t),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        _sectionHeader(p, '藏干表'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Table(
              columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1)},
              children: [
                TableRow(decoration: BoxDecoration(color: p.withAlpha(20)),
                  children: ['地支', '本气', '中气', '余气'].map((h) => _cell(h, p)).toList()),
                ...cangGanTable.map((row) => TableRow(
                  children: ['地支', '本气', '中气', '余气'].map((k) => _cell(row[k] ?? '', t)).toList(),
                )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
