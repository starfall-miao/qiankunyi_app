// 落·乾坤 - 百宝箱：易学入门教程
import 'package:flutter/material.dart';
import '../../reference/data/liuyao_reference_data.dart';

/// 入门教程页：周易 / 六爻 / 梅花 / 八字 + 速查卡片
class TutorialPage extends StatelessWidget {
  const TutorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('易学入门教程'),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: '周易'),
              Tab(text: '六爻'),
              Tab(text: '梅花'),
              Tab(text: '八字'),
              Tab(text: '速查卡'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ZhouYiTab(),
            _LiuYaoTab(),
            _MeiHuaTab(),
            _BaZiTab(),
            _QuickRefTab(),
          ],
        ),
      ),
    );
  }
}

// ═══════════════ 通用组件 ═══════════════

/// 大标题
class _H extends StatelessWidget {
  final String text;
  const _H(this.text);
  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(text,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: p)),
    );
  }
}

/// 小节标题
class _S extends StatelessWidget {
  final String text;
  const _S(this.text);
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Text(text,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t)),
    );
  }
}

/// 正文段落
class _P extends StatelessWidget {
  final String text;
  const _P(this.text);
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).colorScheme.onSurface.withAlpha(200);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: TextStyle(fontSize: 13, height: 1.7, color: t)),
    );
  }
}

/// 提示框（重要/示例）
class _Tip extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  const _Tip(this.text,
      {this.icon = Icons.lightbulb_outline,
      this.color = const Color(0xFFB08A3E)});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 12.5, height: 1.6, color: scheme.onSurface.withAlpha(200))),
          ),
        ],
      ),
    );
  }
}

/// 步骤条目
class _Step extends StatelessWidget {
  final int n;
  final String title;
  final String desc;
  const _Step(this.n, this.title, this.desc);
  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).colorScheme.primary;
    final t = Theme.of(context).colorScheme.onSurface.withAlpha(200);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22, height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: p, shape: BoxShape.circle),
            child: Text('$n',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(fontSize: 12.5, height: 1.6, color: t.withAlpha(160))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 通用 Tab 容器（可滚动、限宽）
class _ScrollBody extends StatelessWidget {
  final List<Widget> children;
  const _ScrollBody(this.children);
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, c) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
          ),
        ),
      );
    });
  }
}

/// 表格：两列键值
class _KVTable extends StatelessWidget {
  final Map<String, String> data;
  const _KVTable(this.data);
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).colorScheme.onSurface.withAlpha(200);
    final b = Theme.of(context).colorScheme.outlineVariant;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: b.withAlpha(80)),
      ),
      child: Column(
        children: data.entries.map((e) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: b.withAlpha(60), width: 0.5),
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 80, child: Text(e.key,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: t))),
              Expanded(child: Text(e.value,
                  style: TextStyle(fontSize: 12.5, color: t.withAlpha(160)))),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

/// 五行色卡片（速查用）
class _WxCard extends StatelessWidget {
  final String wx;
  final Color color;
  final String content;
  const _WxCard(this.wx, this.color, this.content);
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).colorScheme.onSurface.withAlpha(200);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(wx,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          ]),
          const SizedBox(height: 6),
          Text(content,
              style: TextStyle(fontSize: 12.5, height: 1.6, color: t)),
        ],
      ),
    );
  }
}

// ═══════════════ 周易 ═══════════════

class _ZhouYiTab extends StatelessWidget {
  const _ZhouYiTab();
  @override
  Widget build(BuildContext context) {
    return _ScrollBody([
      const _H('📜 周易是什么'),
      const _P('《周易》又称《易经》，是中国最古老的经典之一，被尊为"群经之首、大道之源"。'
          '它以阴阳八卦为基础，通过六十四卦的卦象与卦辞爻辞，阐释天地万物的变化规律，'
          '是中华哲学、文化、数术的总源头。'),
      const _S('历史源流'),
      const _P('• 伏羲氏仰观天文、俯察地理，始画八卦（先天八卦），是为《易经》之源。\n'
          '• 周文王被囚羑里时推演六十四卦，并作卦辞、爻辞，故名《周易》。\n'
          '• 孔子晚年读易，"韦编三绝"，作《十翼》（彖、象、系辞等十篇传文），'
          '使《易》由占筮之书升华为哲学经典。\n'
          '• 后世"象数派"与"义理派"并传，共同构成易学两大传统。'),
      const _S('核心思想'),
      const _P('• 阴阳：万物皆分阴阳，如天地、日月、男女、刚柔。\n'
          '• 变化：易有三义——变易（万事皆变）、简易（大道至简）、不易（规律不变）。\n'
          '• 象数理占：观象、取数、明理、占断四位一体。'),
      const _S('八卦生成示意'),
      const _P('"易有太极，是生两仪，两仪生四象，四象生八卦。"'),
      const _Tip('太极 ☯  →  两仪：☰阳 / ☷阴  →  四象：太阳、少阴、少阳、太阴  →  八卦：乾兑离震巽坎艮坤'),
      const _KVTable({
        '乾 ☰': '天，刚健，父，西北，金',
        '兑 ☱': '泽，喜悦，少女，西，金',
        '离 ☲': '火，光明，中女，南，火',
        '震 ☳': '雷，震动，长男，东，木',
        '巽 ☴': '风，入，长女，东南，木',
        '坎 ☵': '水，险陷，中男，北，水',
        '艮 ☶': '山，静止，少男，东北，土',
        '坤 ☷': '地，柔顺，母，西南，土',
      }),
      const _Tip('记住口诀：乾三连、坤六断、震仰盂、艮覆碗、离中虚、坎中满、兑上缺、巽下断。',
          icon: Icons.memory, color: Color(0xFF2E7D32)),
    ]);
  }
}

// ═══════════════ 六爻 ═══════════════

class _LiuYaoTab extends StatelessWidget {
  const _LiuYaoTab();
  @override
  Widget build(BuildContext context) {
    return _ScrollBody([
      const _H('🪙 六爻占卜教程'),
      const _P('六爻（六爻纳甲）以三枚铜钱摇动成卦，通过"装卦"（安世应、配六亲、纳甲、装六神）'
          '对卦象进行解读。是民间最流行的占卜法之一。'),
      const _S('术数原理'),
      const _P('每摇一次得一个爻，三枚铜钱有四种组合：三个正面为老阳（动爻○）、'
          '三个反面为老阴（动爻×）、两正一反为少阳（—）、一正两反为少阴（--）。'
          '自下而上摇六次，即得本卦六爻。'),
      const _S('手动排盘步骤'),
      const _Step(1, '摇卦', '净手端坐，默念所问之事，将三枚铜钱握于掌心摇动后掷出，'
          '记录一次结果。共摇六次，自下而上记为初爻至六爻。'),
      const _Step(2, '记爻成卦', '老阳记○（阳动）、老阴记×（阴动）、少阳记—、少阴记--。'
          '本卦即六爻所成之卦；有动爻则变化为变卦（老阳变阴、老阴变阳）。'),
      const _Step(3, '装卦', '按八宫世应表定世爻、应爻；按卦配六亲（父母、兄弟、子孙、妻财、官鬼）；'
          '纳甲装干支；按日建配六神（青龙、朱雀、勾陈、螣蛇、白虎、玄武）。'),
      const _Step(4, '断卦', '以用神为核心，看其旺衰（月令、日辰）、动静生克，结合世应、六亲、六神综合判断。'),
      const _S('六亲速记（以卦中五行 vs 日干五行）'),
      const _KVTable({
        '生我者': '父母',
        '我生者': '子孙',
        '克我者': '官鬼',
        '我克者': '妻财',
        '同我者': '兄弟',
      }),
      const _Tip('占财看妻财，占官看官鬼，占父母看父母，占子孙看子孙，占竞争看兄弟——先定用神再断旺衰。',
          icon: Icons.tips_and_updates_outlined, color: Color(0xFFB08A3E)),
      const _S('纳甲装卦（乾宫）示例'),
      const _P('乾为天：内卦（初二三爻）纳 甲子、甲寅、甲辰；外卦（四五上爻）纳 壬午、壬申、壬戌。'
          '其余各宫依八宫纳甲规律类推。'),
      // ── 六神详解（合并自参考资料） ──
      const _H('🐉 六神详解'),
      ...liuShenList.map((s) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(int.parse(s.colorHex.replaceFirst('#', '0xFF'))).withAlpha(14),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: Color(int.parse(s.colorHex.replaceFirst('#', '0xFF'))).withAlpha(60)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(s.name,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(int.parse(s.colorHex.replaceFirst('#', '0xFF'))))),
            const SizedBox(width: 8),
            Text('${s.wuXing} · ${s.season}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ]),
          const SizedBox(height: 3),
          Text(s.meaning, style: const TextStyle(fontSize: 12, height: 1.5)),
        ]),
      )),
    ]);
  }
}

// ═══════════════ 梅花 ═══════════════

class _MeiHuaTab extends StatelessWidget {
  const _MeiHuaTab();
  @override
  Widget build(BuildContext context) {
    return _ScrollBody([
      const _H('🌸 梅花易数教程'),
      const _P('梅花易数相传为北宋邵雍（康节）所创。其法"以数起卦、以象断事"，'
          '简便灵活，随时随地可起卦，是初学者最易入门的占卜法。'),
      const _S('术数原理：先天八卦数'),
      const _KVTable({
        '乾': '1', '兑': '2', '离': '3', '震': '4',
        '巽': '5', '坎': '6', '艮': '7', '坤': '8',
      }),
      const _S('时间起卦（最常用）'),
      const _Step(1, '取数', '以农历年月日取数：年（地支序数）、月（1-12）、日（1-30）、'
          '再加上时辰序数（子1丑2…亥12）。'),
      const _Step(2, '定上下卦', '上卦 =（年+月+日）÷ 8 的余数，余0取8（坤）。'
          '下卦 =（年+月+日+时）÷ 8 的余数，余0取8。'),
      const _Step(3, '定动爻', '动爻 =（年+月+日+时）÷ 6 的余数，余0取6（上爻）。'),
      const _Step(4, '体用断事', '不含动爻的卦为体卦（代表自己），动爻所在卦为用卦（代表所问之事）。'
          '体克用吉、用生体吉；体生用泄气、用克体凶；比和（同五行）为吉。'),
      const _Tip('示例：某日午时起卦。上卦（年+月+日）取8，下卦加时辰取数，动爻取6。'
          '结合先天数与万物类象即可断事。', icon: Icons.tips_and_updates_outlined, color: Color(0xFF2E7D32)),
      const _S('体用生克速查'),
      const _KVTable({
        '体克用': '吉，主动，事情利于我',
        '用生体': '吉，得助，事情有进展',
        '体生用': '凶（泄气），付出多收获少',
        '用克体': '凶，受制，事情不利',
        '比和': '吉，同气相求，顺利',
      }),
      // ── 梅花外应补充（合并自参考资料） ──
      const _H('🌸 梅花外应与取象'),
      const _P('梅花易数重"观物取象"：听到、看到、想到的人事物都可为外应。'
          '如见红色主火（离）、见水主坎、见东方主木（震巽）。'
          '断卦时把外应纳入体用，往往能直指要害。'),
      const _Tip('取象口诀：观其象、察其数、辨其色、听其声、感其气。'
          '象数理占融为一体，方为梅花真谛。',
          icon: Icons.tips_and_updates_outlined, color: Color(0xFF2E7D32)),
    ]);
  }
}

// ═══════════════ 八字 ═══════════════

class _BaZiTab extends StatelessWidget {
  const _BaZiTab();
  @override
  Widget build(BuildContext context) {
    return _ScrollBody([
      const _H('📜 八字命理教程'),
      const _P('八字（四柱）以人出生的年、月、日、时四柱干支推算命运。'
          '日柱天干为"日主"（代表自己），是论命的核心。'),
      const _S('术数原理'),
      const _P('十天干：甲乙丙丁戊己庚辛壬癸；十二地支：子丑寅卯辰巳午未申酉戌亥。'
          '干支相配六十甲子循环。年柱看祖上与外界，月柱看父母兄弟，日柱看自身与配偶，时柱看子女与晚年。'),
      const _S('手动排盘步骤'),
      const _Step(1, '排四柱', '年柱以立春为界；月柱以节气（十二节）分月；日柱查万年历；'
          '时柱由日干按"五鼠遁"定天干。'),
      const _Step(2, '定十神', '以日主为基准：生我者印、我生者食伤、克我者官杀、我克者财、同我者比劫。'
          '阴阳相同为偏（偏印、伤官、七杀、偏财、劫财），不同为正。'),
      const _Step(3, '看旺衰喜忌', '看日主在月令的旺衰（得令、得地、得势），五行缺旺补衰，'
          '定出喜用神与忌神。'),
      const _Step(4, '大运流年', '大运十年一运，从起运岁数起顺逆排；流年逐年更替，'
          '结合大运与日主生克判断吉凶。'),
      const _S('十天干五行'),
      const _KVTable({
        '甲乙': '木', '丙丁': '火', '戊己': '土',
        '庚辛': '金', '壬癸': '水',
      }),
      const _S('五行相生相克'),
      const _P('相生：木→火→土→金→水→木（循环相生）。\n'
          '相克：木→土→水→火→金→木（循环相克）。'),
      // ── 八字基础补充（合并自参考资料） ──
      const _H('📖 八字基础'),
      const _P('• 年柱以立春为界，月柱以十二节气分月，日柱查万年历，时柱由日干按五鼠遁定。\n'
          '• 看旺衰：日主得令（月令同气）、得地（地支通根）、得势（同党多）则旺，反之弱。\n'
          '• 十神以日干为基准，阴阳同为正神、异为偏神，是论命的重要框架。'),
      const _S('十二地支五行'),
      const _KVTable({
        '子亥': '水', '寅卯': '木', '巳午': '火',
        '申酉': '金', '辰戌丑未': '土',
      }),
      const _S('十神生克'),
      const _P('印生身（比劫），比劫生食伤，食伤生财，财生官杀，官杀克身；'
          '同者相帮，异者相耗。顺逆流转，环环相扣。'),
    ]);
  }
}

// ═══════════════ 速查卡 ═══════════════

class _QuickRefTab extends StatelessWidget {
  const _QuickRefTab();
  @override
  Widget build(BuildContext context) {
    const wxColors = {
      '木': Color(0xFF2E7D32),
      '火': Color(0xFFD32F2F),
      '土': Color(0xFFEF6C00),
      '金': Color(0xFFF9A825),
      '水': Color(0xFF1565C0),
    };
    return _ScrollBody([
      const _H('⚡ 五行速查卡'),
      _WxCard('木', wxColors['木']!, '天干：甲乙；地支：寅卯；方位：东；季节：春。'
          '性情：仁、直、生长。旺相时曲直向上，休囚则弯曲。'),
      _WxCard('火', wxColors['火']!, '天干：丙丁；地支：巳午；方位：南；季节：夏。'
          '性情：礼、明、热烈。旺相时炎上明亮，休囚则灰暗。'),
      _WxCard('土', wxColors['土']!, '天干：戊己；地支：辰戌丑未；方位：中；季节：四季末。'
          '性情：信、厚、承载。旺相时生育万物，休囚则板滞。'),
      _WxCard('金', wxColors['金']!, '天干：庚辛；地支：申酉；方位：西；季节：秋。'
          '性情：义、刚、果断。旺相时肃杀锋利，休囚则脆折。'),
      _WxCard('水', wxColors['水']!, '天干：壬癸；地支：亥子；方位：北；季节：冬。'
          '性情：智、润下、流动。旺相时滋润万物，休囚则泛滥。'),
      const _H('📇 十二地支速查'),
      const _KVTable({
        '子': '水，23-01时，鼠，北方',
        '丑': '土，01-03时，牛，东北',
        '寅': '木，03-05时，虎，东北',
        '卯': '木，05-07时，兔，东方',
        '辰': '土，07-09时，龙，东南',
        '巳': '火，09-11时，蛇，东南',
        '午': '火，11-13时，马，南方',
        '未': '土，13-15时，羊，西南',
        '申': '金，15-17时，猴，西南',
        '酉': '金，17-19时，鸡，西方',
        '戌': '土，19-21时，狗，西北',
        '亥': '水，21-23时，猪，西北',
      }),
      const _H('🔗 六亲速查（以日干为基准）'),
      const _KVTable({
        '生我（印）': '正印 / 偏印',
        '我生（食伤）': '食神 / 伤官',
        '克我（官杀）': '正官 / 七杀',
        '我克（财）': '正财 / 偏财',
        '同我（比劫）': '比肩 / 劫财',
      }),
      const _H('🧮 纳甲装卦（八宫首卦）'),
      const _KVTable({
        '乾宫': '内甲子甲寅甲辰 / 外壬午壬申壬戌',
        '兑宫': '内丁巳丁卯丁丑 / 外丁亥丁酉丁未',
        '离宫': '内己卯己丑己亥 / 外己酉己未己巳',
        '震宫': '内庚子庚寅庚辰 / 外庚午庚申庚戌',
        '巽宫': '内辛丑辛亥辛酉 / 外辛未辛巳辛卯',
        '坎宫': '内戊寅戊辰戊午 / 外戊申戊戌戊子',
        '艮宫': '内丙辰丙午丙申 / 外丙戌丙子丙寅',
        '坤宫': '内乙未乙巳乙卯 / 外癸丑癸亥癸酉',
      }),
      const _Tip('小卡片速查：看天干地支的五行、排六亲、纳甲装卦，一键即得。',
          icon: Icons.auto_awesome, color: Color(0xFFB08A3E)),
      // ── 纳音速查（合并自参考资料） ──
      const _H('🎵 六十甲子纳音速查'),
      const _P('纳音以六十甲子每两柱一组，共 30 组。前 12 组：'),
      const _KVTable({
        '甲子乙丑': '海中金', '丙寅丁卯': '炉中火', '戊辰己巳': '大林木',
        '庚午辛未': '路旁土', '壬申癸酉': '剑锋金', '甲戌乙亥': '山头火',
        '丙子丁丑': '涧下水', '戊寅己卯': '城头土', '庚辰辛巳': '白蜡金',
        '壬午癸未': '杨柳木', '甲申乙酉': '泉中水', '丙戌丁亥': '屋上土',
      }),
      const _Tip('完整 30 组纳音与命理解读详见"参考资料 → 纳音"页。',
          icon: Icons.menu_book_outlined, color: Color(0xFF1565C0)),
    ]);
  }
}
