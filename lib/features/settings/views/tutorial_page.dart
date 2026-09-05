// 落·乾坤 - 百宝箱：易学入门教程
import 'package:flutter/material.dart';
import '../../reference/data/liuyao_reference_data.dart';

/// 入门教程页：周易 / 六爻 / 梅花 / 八字 + 速查卡片
class TutorialPage extends StatelessWidget {
  const TutorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
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
              Tab(text: '小六壬'),
              Tab(text: '大六壬'),
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
            _XiaoLiuRenTab(),
            _DaLiuRenTab(),
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

/// 落落气泡（可爱俏皮口吻）
class _LuoLuoCard extends StatelessWidget {
  final String text;
  final String mood; // 表情
  const _LuoLuoCard(this.text, {this.mood = '🌸'});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primary.withAlpha(12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.primary.withAlpha(50), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Text(mood, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('落落说：',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: scheme.primary)),
                const SizedBox(height: 3),
                Text(text,
                    style: TextStyle(
                        fontSize: 12.5,
                        height: 1.7,
                        color: scheme.onSurface.withAlpha(210))),
              ],
            ),
          ),
        ],
      ),
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
      const _LuoLuoCard('欢迎来到周易小课堂呀～落落带你三分钟入门！✨\n咱们先记住一句话：周易就是讲"变化"的学问，阴阳一换、八卦一摆，天地万物的规律就藏在这六十四卦里啦。放轻松，跟着落落慢慢看～', mood: '📜'),
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
      // ── 思辨部分：周易对我们有什么意义 ──
      const _H('🤔 为什么学周易？它到底教我们什么'),
      const _P('很多人以为周易就是算卦，其实不然。落落觉得，周易最珍贵的地方，'
          '是它给了我们一套看待世界的"思维框架"——而且这套框架放到今天依然好用。'),
      const _S('1. 变化观：唯一不变的就是变化本身'),
      const _P('"穷则变，变则通，通则久。"周易教我们：没有什么状态是永恒的。'
          '得意时想想"亢龙有悔"，别飘；失意时想想"否极泰来"，别灰心。'
          '放到现代，这不就是"拥抱变化、保持弹性"吗？创业、职场、感情，'
          '哪一样不是起起落落？读懂了"变"，你就拥有了抗挫折的韧性。'),
      const _S('2. 阴阳观：对立统一，不走极端'),
      const _P('周易说"一阴一阳之谓道"——光明背后有阴影，优点背后有缺点，'
          '快慢、刚柔、进退都是相对的。现代心理学讲的"接纳不完美""整合人格"，'
          '和阴阳思维其实是相通的。遇事不必非黑即白，试着"阴阳平衡"，'
          '这就是一种成熟。'),
      const _S('3. 居安思危，与时偕行'),
      const _P('"君子安而不忘危，存而不忘亡。"周易时刻提醒我们：顺境时要为逆境做准备，'
          '做决定要顺应时机。这不就是现代人说的"风险管理""把握趋势"吗？'
          '学易，学的其实是做人的分寸与处世的智慧。'),
      const _H('🧐 周易、玄学、占卜、迷信：落落的立场'),
      const _P('这一点落落要认真地跟你聊聊。周易包含三部分：哲学（义理）、文化（象数）、'
          '数术（占卜应用）。它们层次不同，价值也不同。'),
      const _S('周易 ≠ 迷信'),
      const _P('迷信是"盲目的相信"，而周易恰恰鼓励"理性的思考"。它教你的不是"听天由命"，'
          '而是"知命而不认命"——了解趋势，把握自己能做到的部分。'
          '占卜只是周易的一个工具，就像计算器是数学的工具一样：工具没有好坏，'
          '关键看你怎么用。'),
      const _S('落落的三个原则'),
      const _P('① 把占卜当"思维练习"和"自我对话"，不当"判决书"。\n'
          '② 重大决定（医疗、法律、投资、人生选择）请交给专业与理性，'
          '占卜只能提供参考角度。\n'
          '③ 尊重传统、不迷信玄学：我们学的是古人观察世界的智慧，'
          '而不是把命运拱手交给未知。'),
      const _S('为什么要尊敬周易这样的传统文化？'),
      const _P('因为它是先民几千年的经验与智慧结晶，是理解中国人思维方式的钥匙。'
          '读周易，你会懂得"天行健，君子以自强不息"为什么能成为民族精神的一部分，'
          '也会明白"地势坤，君子以厚德载物"里的格局。'
          '这份遗产值得被认真对待——不是因为它"灵验"，而是因为它"深刻"。'),
      const _H('🌈 落落给你的小建议'),
      const _P('想真正学好周易，落落建议三步走：\n'
          '① 先读"理"：《系辞》《彖传》里的人生哲学，培养思辨；\n'
          '② 再学"象"：认识八卦、六十四卦的卦象与卦辞，培养直觉；\n'
          '③ 后习"术"：了解了原理再碰占卜，才不会被玄学带偏。\n'
          '把周易当成一面镜子，照见自己、理解世界——这才是它最大的价值。'),
      const _Tip('记住落落的话：易学是"观察世界的智慧"，不是"逃避现实的借口"。'
          '带着思辨去学，你会收获比"预测"多得多的东西。',
          icon: Icons.psychology_outlined, color: Color(0xFF6C3FAA)),
    ]);
  }
}

// ═══════════════ 六爻 ═══════════════

class _LiuYaoTab extends StatelessWidget {
  const _LiuYaoTab();
  @override
  Widget build(BuildContext context) {
    return _ScrollBody([
      const _LuoLuoCard('排六爻一点也不难哦！落落手把手教你：\n① 摇卦前先在心里默念你想问的事（比如"我这工作能不能成呀"）\n② 摇六次铜钱，从下往上记，动爻最特殊！\n③ 排出来之后看世应、六亲、空亡，再点开卦象看详解～\n跟着步骤走，包你第一次就排得像模像样！🎉', mood: '🔮'),
      const _H('🪙 六爻占卜教程'),
      const _P('六爻（六爻纳甲）以三枚铜钱摇动成卦，通过"装卦"（安世应、配六亲、纳甲、装六神）'
          '对卦象进行解读。是民间最流行的占卜法之一。'),
      const _S('术数原理'),
      const _P('每摇一次得一个爻，三枚铜钱有四种组合：三个正面为老阳（动爻○）、'
          '三个反面为老阴（动爻×）、两正一反为少阳（—）、一正两反为少阴（--）。'
          '自下而上摇六次，即得本卦六爻。'),
      const _S('🪙 记爻成卦：硬币正反与爻位（手把手）'),
      const _P('用三枚"乾隆通宝"（或其他硬币）摇卦。先分清正反面：'
          '有"乾隆通宝"四个汉字的一面为【字面】（记作 反），'
          '无字、只有满文/花纹的一面为【背面】（记作 正）。'),
      const _KVTable({
        '三个背面（三正）': '老阳 ○（动爻，变阴）',
        '三个字面（三反）': '老阴 ×（动爻，变阳）',
        '两背一字': '少阳 —（静爻）',
        '一背两字': '少阴 --（静爻）',
      }),
      const _Tip('记忆口诀："背面多则阳"——三背老阳（动）、两背少阳、一背少阴、三字老阴（动）。'
          '动爻会变：老阳变阴、老阴变阳，本卦变出变卦。',
          icon: Icons.tips_and_updates_outlined, color: Color(0xFF2E7D32)),
      const _P('摇卦操作：净手静心，心中默念所问之事（越具体越好），'
          '把三枚铜钱合于掌心摇动，掷于桌面，看正反面记录一次结果。'
          '如此共摇六次，从下往上依次记为初爻、二爻、三爻、四爻、五爻、上爻。'
          '（注意：是从下往上排！第一爻在卦的最下面。）'),
      const _S('手动排盘步骤'),
      const _Step(1, '摇卦', '净手端坐，默念所问之事，将三枚铜钱握于掌心摇动后掷出，'
          '记录一次结果。共摇六次，自下而上记为初爻至六爻。'),
      const _Step(2, '记爻成卦', '老阳记○（阳动）、老阴记×（阴动）、少阳记—、少阴记--。'
          '本卦即六爻所成之卦；有动爻则变化为变卦（老阳变阴、老阴变阳）。'),
      const _S('🧰 装卦五步（保姆级）'),
      const _Step(1, '定世应', '按八宫世应口诀定位世爻（代表自己）与应爻（代表对方/所测之事）。'
          '口诀："八卦之首世六当，以下初爻轮上扬；游魂八宫四爻位，归魂八宫三爻详。"'
          '（首卦世在六爻，二卦世在初爻，三卦在二爻…八宫各卦依次）'),
      const _KVTable({
        '乾兑离震巽坎艮坤 八纯卦': '世在上爻（六爻），应在三爻',
        '第二卦（一世）': '世在初爻，应在四爻',
        '第三卦（二世）': '世在二爻，应在五爻',
        '第四卦（三世）': '世在三爻，应在六爻',
        '第五卦（四世）': '世在四爻，应在初爻',
        '第六卦（五世）': '世在五爻，应在二爻',
        '游魂卦': '世在四爻，应在初爻',
        '归魂卦': '世在三爻，应在六爻',
      }),
      const _Step(2, '纳甲（装干支）', '给六个爻配上干支（纳甲）。按八宫各卦内卦/外卦分别纳甲：'
          '乾内卦纳甲子甲寅甲辰、外卦纳壬午壬申壬戌；'
          '兑内丁巳丁卯丁丑、外丁亥丁酉丁未；离内己卯己丑己亥、外己酉己未己巳；'
          '震内庚子庚寅庚辰、外庚午庚申庚戌；'
          '巽内辛丑辛亥辛酉、外辛未辛巳辛卯；'
          '坎内戊寅戊辰戊午、外戊申戊戌戊子；'
          '艮内丙辰丙午丙申、外丙戌丙子丙寅；'
          '坤内乙未乙巳乙卯、外癸丑癸亥癸酉。'),
      const _Tip('纳甲不必死记！排盘时 App 自动纳甲。想手排时记住规律：'
          '阳卦（乾坎艮震）纳阳干，阴卦（坤离兑巽）纳阴干；'
          '每卦内卦三爻配地支从初爻起依次顺推。',
          icon: Icons.memory, color: Color(0xFFB08A3E)),
      const _Step(3, '填五行', '按地支查五行：寅卯=木、巳午=火、申酉=金、亥子=水、辰戌丑未=土。'
          '每个爻的地支确定后，其五行随之确定。'),
      const _KVTable({
        '寅卯': '木', '巳午': '火', '申酉': '金', '亥子': '水', '辰戌丑未': '土',
      }),
      const _Step(4, '配六亲', '以本宫（八纯卦）五行为"我"，看各爻地支五行与我的生克关系：'
          '生我者父母、我生者子孙、克我者官鬼、我克者妻财、同我者兄弟。'
          '（注意：六亲以"宫"五行为基准，不是日干！）'),
      const _KVTable({
        '生我者': '父母（如宫属木、水爻生木）',
        '我生者': '子孙（如宫属木、火爻泄木）',
        '克我者': '官鬼（如宫属木、金爻克木）',
        '我克者': '妻财（如宫属木、土爻受木克）',
        '同我者': '兄弟（如宫属木、木爻比和）',
      }),
      const _Step(5, '配六神（六兽）', '按日柱天干起青龙：甲乙日初爻起青龙，丙丁日起朱雀，'
          '戊日起勾陈，己日起螣蛇，庚辛日起白虎，壬癸日起玄武。'
          '从初爻到上爻依次排列。'),
      const _KVTable({
        '甲乙日': '青龙起（初爻青龙、二爻朱雀…）',
        '丙丁日': '朱雀起',
        '戊日': '勾陈起',
        '己日': '螣蛇起',
        '庚辛日': '白虎起',
        '壬癸日': '玄武起',
      }),
      const _S('🔍 断卦：按问事分类给步骤'),
      const _P('断卦第一步永远是【定用神】：你要问的事对应哪个六亲，它就是你断卦的主线。'
          '用神旺相有气则事易成，休囚无气则事难成；再看动变、生克、空亡。'),
      const _KVTable({
        '问财运/求财': '用神妻财。财爻旺相、不空、不受克 → 得财；财空财破 → 破财。',
        '问事业/官运': '用神官鬼。官爻旺相、临青龙/贵人 → 升迁；官鬼休囚 → 事业不顺。',
        '问婚姻/感情': '用神妻财（男）/官鬼（女）+ 世应相生。世应相合 → 感情和顺。',
        '问考试/文书': '用神父母（文书）。父母旺相 → 考运佳；父母空亡 → 不利。',
        '问子女/平安': '用神子孙。子孙旺相 → 平安健康；子孙受克 → 需注意。',
        '问疾病': '用神官鬼为病、子孙为医药。子孙旺 → 药到病除。',
      }),
      const _S('落落的经验之谈'),
      const _P('① 先看世应：世代表自己，应代表对方/事体，世应相生相合为吉，相克相冲为凶。\\n'
          '② 再看用神：用神是主线，一切判断围绕它展开。\\n'
          '③ 后看动爻：动爻主"变化"，动爻生合用神为吉，克冲用神为凶。\\n'
          '④ 空亡：用神旬空，谋事落空（出空填实后可成）。\\n'
          '⑤ 综合六神：青龙主喜、朱雀主口舌、白虎主凶灾、玄武主暧昧暗昧，辅助判断性质。'),
      const _Tip('新手断卦公式：定用神 → 看旺衰（月令日辰）→ 看动变 → 看生克合冲 → 综合六神。'
          '先别贪多，把用神和旺衰抓准，你已经赢过一半人了。',
          icon: Icons.tips_and_updates_outlined, color: Color(0xFF2E7D32)),
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
      const _LuoLuoCard('梅花易数是落落最喜欢的玩法啦，因为它超级方便！💮\n随手报几个数字、看一眼时间，甚至听到鸟叫都能起卦，"以数起卦、以象断事"，特别适合生活里的小问题～\n不会也没关系，跟着下面的步骤，三个数字就能起卦！', mood: '🌸'),
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
      const _LuoLuoCard('想知道自己的命盘长啥样吗？落落来帮你！🌟\n八字嘛，就是"出生时间+天干地支"的组合，年柱、月柱、日柱、时柱四柱凑齐。填好出生信息点排盘，五行旺衰、十神关系全都有～\n先看日主（日柱天干）是什么，再看它旺不旺，这是入门第一步哦！', mood: '🐣'),
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

// ═══════════════ 小六壬 ═══════════════

class _XiaoLiuRenTab extends StatelessWidget {
  const _XiaoLiuRenTab();
  @override
  Widget build(BuildContext context) {
    return _ScrollBody([
      const _LuoLuoCard('小六壬是落落超爱的小巧占法！🖐️ 六个掌诀六个位置，'
          '报个月日时就能断事，出门在外随手可用。跟落落把六掌诀记牢，'
          '你就是行走的"小神算"啦～', mood: '🖐️'),
      const _H('🖐️ 小六壬教程'),
      const _P('小六壬也叫"六掌诀"，仅用左手六个指节位置，配月、日、时起课，'
          '快速断吉凶。简单易学、随时随地可用，是民间流传极广的小占法。'),
      const _S('六掌诀位置（左手）'),
      const _KVTable({
        '大安': '食指根部，吉，主安定平稳',
        '留连': '食指指尖，凶，主拖延纠缠',
        '速喜': '中指指尖，吉，主喜事速至',
        '赤口': '无名指指尖，凶，主口舌是非',
        '小吉': '无名指根部，吉，主小吉顺遂',
        '空亡': '中指根部，凶，主谋事落空',
      }),
      const _Tip('记忆：大安→留连→速喜→赤口→小吉→空亡，绕指节一圈'
          '（食指根→食指尖→中指尖→无名指尖→无名指根→中指根）。',
          icon: Icons.tips_and_updates_outlined, color: Color(0xFF2E7D32)),
      const _S('起课方法（月日时起课）'),
      const _P('① 定月份：从"大安"起正月，顺数至所求之月（一月大安、二月留连…）\n'
          '② 定日期：从月份落位起，顺数至所求之日（初一、初二…）\n'
          '③ 定时辰：从日期落位起，顺数至所求之时辰（子丑寅卯…）\n'
          '最终落位即断卦结果。'),
      const _Tip('例子：正月十五辰时占事——正月从大安起，落大安(0)；'
          '十五日从大安顺数15步，落小吉；辰时从落位顺数5步，得结果。'
          '（App 里选日期时辰会自动算好，不必手数）',
          icon: Icons.auto_awesome, color: Color(0xFFB08A3E)),
      const _S('断卦要诀'),
      const _P('大安：诸事安定，宜守成，出行顺利。\n'
          '留连：事有拖延，急事难成，宜等待。\n'
          '速喜：喜事临近，求财求事皆速成，宜主动。\n'
          '赤口：口舌是非，官非防小人，宜谨慎。\n'
          '小吉：诸事小吉，谋事有成，宜把握。\n'
          '空亡：谋事落空，劳而无功，宜止损。'),
      const _Tip('小六壬吉凶分明（三吉三凶），上手极快。'
          '多用于日常小事参考，重大决策还是要理性判断哦。',
          icon: Icons.psychology_outlined, color: Color(0xFF6C3FAA)),
    ]);
  }
}

// ═══════════════ 大六壬 ═══════════════

class _DaLiuRenTab extends StatelessWidget {
  const _DaLiuRenTab();
  @override
  Widget build(BuildContext context) {
    return _ScrollBody([
      const _LuoLuoCard('大六壬是"三式"之一，被誉为最高深的占法之一！🏛️ '
          '虽然名字带"大"，但别怕，落落带你一步步拆解：月将→天地盘→四课→三传，'
          '懂了骨架，剩下的就是查资料填血肉啦。', mood: '🏛️'),
      const _H('🏛️ 大六壬教程'),
      const _P('大六壬与奇门遁甲、太乙神数并称"三式"，以月将加时起天地盘，'
          '经四课、三传推演事物发展。体系庞大但逻辑严谨，被誉为"占法之王"。'),
      const _S('核心结构：五步走'),
      const _Step(1, '定月将', '月将即太阳所在之宫（正月登明亥、二月河魁戌…十二月神后子）。'
          '每月换一个，用公历月份近似对应即可（App 自动算）。'),
      const _Step(2, '月将加时（起天地盘）', '地盘固定十二支（子北午南），'
          '把月将加到"时辰"所在的宫位上，其余天盘支顺排，即得天盘。'
          '例：正月（登明=亥）午时起课，天盘亥落在午位，其余顺排。'),
      const _Step(3, '立四课', '以日干、日支为本，取其上下神得四课：'
          '一课（日干上神）代表自身、二课（日干下神）代表内在，'
          '三课（日支上神）代表所测之事、四课（日支下神）代表事之内情。'),
      const _Step(4, '推三传', '由四课推三传：初传为事之始、中传为事之中、末传为事之终。'
          '（标准用"九宗门"取用：贼克、比用、涉害、遥克、昴星、别责、八专、伏吟、返吟）'),
      const _Step(5, '配天将断课', '按贵人口诀定贵人："甲戊庚牛羊，乙己鼠猴乡，'
          '丙丁猪鸡位，壬癸兔蛇藏，六辛逢马虎。"'
          '贵人起布十二天将（贵螣朱六勾青空白常玄阴后），'
          '结合四课三传断吉凶。'),
      const _S('十二天将吉凶速记'),
      const _KVTable({
        '贵人': '吉，得助、逢贵人',
        '青龙': '吉，喜庆、进财',
        '六合': '吉，和合、婚缘',
        '太常': '吉，衣禄、宴会',
        '太阴': '中，阴私、暗助',
        '天后': '中，庇护、恩泽',
        '螣蛇': '凶，虚惊、缠绕',
        '朱雀': '凶，口舌、文书',
        '勾陈': '凶，争斗、拖延',
        '白虎': '凶，凶灾、病伤',
        '玄武': '凶，盗失、暗昧',
        '天空': '凶，虚诈、落空',
      }),
      const _S('断课思路（落落版）'),
      const _P('① 先看课体吉凶：四课是否伏吟/返吟等特殊格局。\n'
          '② 看三传：初传起因、中传过程、末传结果，传生为吉、传克为凶。\n'
          '③ 看天将：三传所临天将吉凶（贵人青龙吉、白虎玄武凶）。\n'
          '④ 看年命：问事人的年命上神与三传关系（专业进阶）。\n'
          '⑤ 综合断语：结合问事类型（财/官/婚/病）给出结论。'),
      const _Tip('大六壬信息量大，新手先抓"三传+天将"两条线，'
          '再逐步扩展到四课、年命、神煞。App 的排盘和详解会帮你省去大量查表功夫。',
          icon: Icons.tips_and_updates_outlined, color: Color(0xFF2E7D32)),
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
      const _LuoLuoCard('速查卡是落落的小宝库！🧮\n天干地支的五行、六亲、纳甲装卦……排盘时突然忘了哪个，来这里一翻就有，比翻书快多啦！建议收藏慢慢看～', mood: '🗂️'),
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
      // ── 八卦象意（合并自参考资料） ──
      const _H('🌿 八卦象意简表'),
      const _KVTable({
        '乾 ☰': '天·刚健，父，西北，金，君/大人/马',
        '兑 ☱': '泽·喜悦，少女，西，金，口舌/巫/羊',
        '离 ☲': '火·光明，中女，南，火，目/文/雉',
        '震 ☳': '雷·震动，长男，东，木，足/龙/稼',
        '巽 ☴': '风·入，长女，东南，木，股/鸡/草木',
        '坎 ☵': '水·险陷，中男，北，水，耳/猪/轮',
        '艮 ☶': '山·静止，少男，东北，土，手/狗/路',
        '坤 ☷': '地·柔顺，母，西南，土，腹/牛/布',
      }),
      // ── 神煞速查（合并自参考资料） ──
      const _H('✨ 常用神煞速查'),
      const _KVTable({
        '天乙贵人': '吉，遇难有贵人相助（甲戊庚牛羊…）',
        '文昌贵人': '吉，利学业文采（甲巳乙午…）',
        '桃花': '情缘人缘（申子辰见酉…）',
        '驿马': '动迁出行（申子辰马在寅…）',
        '华盖': '艺术孤高（寅午戌见戌…）',
        '羊刃': '刚烈强势，宜慎',
        '空亡': '旬空，谋事落虚',
      }),
      const _Tip('完整神煞象义详见"参考资料 → 神煞"页。',
          icon: Icons.menu_book_outlined, color: Color(0xFF6C3FAA)),
    ]);
  }
}
