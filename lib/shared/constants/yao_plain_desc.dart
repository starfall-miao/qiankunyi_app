/// 六爻术语白话解释 — 共享文本（US-006）
///
/// 排盘页 GuaWidget 点击爻位弹窗（_showYaoRef）与六爻截图模板
/// 每爻详解卡片（gua_screenshot_template.dart）共同引用，保证两处
/// 白话详解内容一致（同源）。
///
/// 文本内容与原先 GuaWidget 私有方法/内联字符串完全一致，仅做位置迁移：
/// 排盘页行为不变。
library;

import '../../features/paipan/models/yao_model.dart';

/// 六亲白话解释（'父母爻代表长辈…'，含术语在文首）
String liuQinDesc(LiuQin lq) {
  switch (lq) {
    case LiuQin.parent: return '父母爻代表长辈、文书、房屋、保护。占事业看父母爻旺衰';
    case LiuQin.brother: return '兄弟爻代表同辈、朋友、竞争者。占财见兄弟爻多不吉';
    case LiuQin.officer: return '官鬼爻代表官职、压力、祸患。占官运喜官鬼旺，占病忌官鬼';
    case LiuQin.wife: return '妻财爻代表财富、妻子、资产。占财运喜妻财爻旺';
    case LiuQin.child: return '子孙爻代表晚辈、下属、福神。占事见子孙爻主无忧';
    case LiuQin.none: return '';
  }
}

/// 六神白话解释
String liuShenDesc(LiuShen ls) {
  switch (ls) {
    case LiuShen.qingLong: return '青龙代表喜庆、贵人、文采。青龙临爻主好事将临';
    case LiuShen.zhuQue: return '朱雀代表口舌、文书、消息。朱雀临爻主有口舌是非或消息传来';
    case LiuShen.gouChen: return '勾陈代表拖延、老熟人、田产。勾陈临爻主事情进展缓慢';
    case LiuShen.tengShe: return '螣蛇代表虚惊、怪异、纠缠。螣蛇临爻主有令人不安之事';
    case LiuShen.baiHu: return '白虎代表凶事、争吵、血光。白虎临爻需防意外伤害';
    case LiuShen.xuanWu: return '玄武代表暗昧、隐晦、偷盗。玄武临爻需防小人或隐私泄露';
  }
}

/// 旺衰白话解释（文本内已含'术语 — 白话'，如 '旺 — 力量最旺盛…'）
String wangShuaiDesc(WangShuaiLevel level) {
  switch (level) {
    case WangShuaiLevel.wang: return '旺 — 力量最旺盛，如日中天。此爻能量最强，作用力大';
    case WangShuaiLevel.xiang: return '相 — 力量次旺，正在上升趋势。能量较强';
    case WangShuaiLevel.xiu: return '休 — 力量消退，处于休息状态。暂时无力';
    case WangShuaiLevel.qiu: return '囚 — 力量被囚禁，受制于人。能量低，难以发挥作用';
    case WangShuaiLevel.si: return '死 — 力量衰竭，毫无生气。最弱状态，无力回天';
  }
}

/// 世爻白话解释
const shiYaoDesc = '世爻代表自己、占卜者本身，是卦的核心';

/// 应爻白话解释
const yingYaoDesc = '应爻代表对方、所问之事或环境';

/// 旬空（空亡）白话解释
const kongWangDesc = '旬空表示该爻暂时"不在位"，力量空虚，事情可能落空或延迟';

/// 相刑白话解释
const xingDesc = '相刑代表矛盾、纠纷、互相伤害';

/// 相冲白话解释
const chongDesc = '相冲代表冲突、变动、对立，事情可能有突破或破裂';

/// 相合白话解释
const heDesc = '相合代表合作、和合、阻碍，事情可能被绊住';

/// 相害白话解释
const haiDesc = '相害代表损害、暗中伤害，需防小人';

/// 三合白话解释
const sanHeDesc = '三合代表三方合作、汇聚力量，大吉之象';

/// 月破：月建冲克该爻（力量受损，多为不利之象）
const yuePoDesc = '月破表示该爻被月建冲破，力量大损，主伤病、离散、事难成；'
    '若得日辰生扶或动爻来生，仍有转机';

/// 日破：日辰冲休囚之爻
const riPoDesc = '日破表示该爻被日辰冲破（本身已休囚无力），主破败、散失、难成';

/// 暗动：日辰冲旺相之静爻
const anDongDesc = '暗动表示静爻被日辰冲动（本身旺相有力），暗中发动，主有隐情或有外力推动';

/// 纳音说明（六十甲子纳音）
const naYinDesc = '纳音是把干支组合归入五行的一种配属（共六十甲子纳音），'
    '如「甲子」为海中金。古籍多以纳音看年命与性情，六爻断卦中仅作参考';

/// 神煞说明：按名称返回白话解释
String shenShaDesc(String name) {
  switch (name) {
    case '天乙贵人':
      return '最吉之神，主贵人相助、逢凶化吉；临世应或用神多有贵人扶持';
    case '文昌':
      return '主聪明文采、文书考试顺利；临子孙、父母爻多利学业文书';
    case '羊刃':
      return '主刚烈、血光、刑伤；临动爻或用神须防冲动、刀伤手术';
    case '禄神':
      return '主衣食俸禄、身体康健；临世爻多主自身有依靠、收入稳定';
    case '驿马':
      return '主变动、出行、迁移；临动爻多主奔波、调动、外出，应期常在冲动之时';
    case '桃花':
      return '主情感、人缘、风流；临妻财/官鬼多主男女之事，须防情色纠纷';
    case '华盖':
      return '主孤高、宗教、艺术；临父母/兄弟多主清高孤僻、喜玄学';
    case '将星':
      return '主统领、权柄、担当；临官鬼/世爻多主掌权任事、有威信';
    case '劫煞':
      return '主意外、夺取、阻难；临动爻须防突发变故与小人争夺';
    case '亡神':
      return '主暗昧、遗失、思虑；临兄弟/子孙多主心中不安、暗中损耗';
    default:
      return '神煞为辅助取象，须结合用神旺衰与生克合参，不可单断';
  }
}
