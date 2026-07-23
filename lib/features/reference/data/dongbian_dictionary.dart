/// 动变含义词典
/// 解释六爻中各种动变关系的含义与象征
library;

/// 动变含义条目
class DongBianInfo {
  final String name;
  final String category;
  final String description;
  final List<String> details;

  const DongBianInfo({
    required this.name,
    required this.category,
    required this.description,
    this.details = const [],
  });
}

final List<DongBianInfo> dongBianDictionary = [
  // ── 动变基本含义 ──
  DongBianInfo(
    name: '动爻',
    category: '基础',
    description: '动爻是卦中变化的爻，代表事情的关键点',
    details: ['动爻是断卦的核心，优先分析动爻所代表的六亲、五行',
      '动爻代表事态的变化、发展的关键因素',
      '动爻数量越多，事情越复杂多变',
      '独动（仅一爻动）最为关键，吉凶易断',
      '静卦（无动爻）主事情发展缓慢，宜守不宜攻'],
  ),
  DongBianInfo(
    name: '变爻',
    category: '基础',
    description: '动爻变化后的爻，代表事态发展的结果',
    details: ['动爻变阳为阴或阴为阳，形成变爻',
      '变爻代表动爻变化后的状态和结果',
      '变爻与动爻的五行生克关系决定了吉凶',
      '变回头生（变爻生原爻）为吉，变回头克为凶',
      '变爻与动爻构成新的组合意义'],
  ),
  DongBianInfo(
    name: '回头生',
    category: '动变关系',
    description: '变爻生原动爻，吉兆',
    details: ['变爻五行生原动爻五行，为回头生',
      '主此事有转机，结果有利',
      '动爻为用神时回头生大吉',
      '动爻为忌神时回头生则凶上加凶',
      '如申金动变子水，金生水为泄气；子水动变寅木，水生木亦为泄气',
      '回头生是动变中最吉的关系之一'],
  ),
  DongBianInfo(
    name: '回头克',
    category: '动变关系',
    description: '变爻克原动爻，凶兆',
    details: ['变爻五行克原动爻五行，为回头克',
      '主事情受阻，结果不利',
      '动爻为用神时回头克大凶',
      '动爻为忌神时回头克反为吉',
      '如申金动变午火，火克金为回头克',
      '回头克是动变中最凶的关系之一'],
  ),
  DongBianInfo(
    name: '化进神',
    category: '动变趋势',
    description: '动爻化进，力量增强，事情推进',
    details: ['地支顺行相化，如寅化卯、巳化午、申化酉、亥化子',
      '主事情渐入佳境，力量不断增强',
      '用神化进神大吉，忌神化进神大凶',
      '测事业见化进神主步步高升',
      '测求财见化进神主财源滚滚'],
  ),
  DongBianInfo(
    name: '化退神',
    category: '动变趋势',
    description: '动爻化退，力量减弱，事情衰退',
    details: ['地支逆行相化，如卯化寅、午化巳、酉化申、子化亥',
      '主事情由盛转衰，力量不断减弱',
      '用神化退神凶，忌神化退神吉',
      '测事业见化退神主退步降职',
      '测感情见化退神主感情变淡'],
  ),
  DongBianInfo(
    name: '化绝',
    category: '动变趋势',
    description: '动爻化入绝地，事情终结',
    details: ['爻变入绝地，主此事终结、断绝',
      '用神化绝主所求之事无希望',
      '测健康化绝需防病情恶化',
      '绝地因五行而異：木绝于申、火绝于亥、金绝于寅、水土绝于巳'],
  ),
  DongBianInfo(
    name: '化墓',
    category: '动变趋势',
    description: '动爻入墓库，事情停滞',
    details: ['爻入墓库，主事情停顿、受阻、消失',
      '用神化墓主被埋没、无进展',
      '财爻化墓主钱财被套住难取出',
      '墓库因五行而異：木墓在未、火墓在戌、金墓在丑、水土墓在辰'],
  ),
  DongBianInfo(
    name: '化空',
    category: '动变趋势',
    description: '动爻化入旬空，事情虚而不实',
    details: ['动爻化为空亡之地，主事情不实、空忙一场',
      '用神化空主所求无果',
      '测出行化空主难成行',
      '动爻化空出空填实后方应验'],
  ),

  // ── 特殊动变 ──
  DongBianInfo(
    name: '暗动',
    category: '特殊',
    description: '静爻受日冲而动，暗中变化',
    details: ['静爻被日辰所冲，为暗动',
      '暗动主暗中变化、不知不觉中发生',
      '暗动之爻力量不及明动，但仍有影响',
      '暗动主事态在暗中酝酿，时机成熟时爆发'],
  ),
  DongBianInfo(
    name: '日破',
    category: '特殊',
    description: '动爻被日辰克制冲破',
    details: ['动爻被日辰冲破，为日破',
      '日破主被外力破坏、计划受阻',
      '日破之爻虽有动意但被压制',
      '日破应期多在冲去日破之日应验',
      '日破暗动规则有三种学说：以旺衰论、以有情论、皆动论'],
  ),
  DongBianInfo(
    name: '独发',
    category: '特殊',
    description: '卦中只有一爻发动，事态明确',
    details: ['六爻中仅有一爻发动，为独发',
      '独发之爻即为事情的关键所在',
      '独发卦吉凶易断，信息集中',
      '应重点分析独发之爻的六亲、五行、世应关系',
      '独发之爻与世爻的关系决定最终吉凶'],
  ),
  DongBianInfo(
    name: '两现',
    category: '特殊',
    description: '卦中同一六亲出现两次',
    details: ['卦中某六亲出现两次（内卦外卦各一），称两现',
      '两现时取旺相者为用神',
      '若两爻一静一动，取动爻为用神',
      '若两爻一空一实，取不空者为用神',
      '若两爻皆动，取逢合逢冲的爻'],
  ),
  DongBianInfo(
    name: '伏吟',
    category: '特殊',
    description: '内卦外卦相同，反反复复',
    details: ['内卦与外卦相同，称伏吟',
      '主事情反反复复，原地踏步',
      '测出行伏吟主困在原地无法前行',
      '测事业伏吟主停滞不前、没有进展',
      '伏吟宜守不宜攻'],
  ),
  DongBianInfo(
    name: '反吟',
    category: '特殊',
    description: '内卦外卦相冲，矛盾冲突',
    details: ['内卦与外卦五行相冲，称反吟',
      '主事情矛盾冲突、反复无常',
      '测合作反吟主意见不合、合作困难',
      '测出行反吟主去了又回，不能安定',
      '反吟需看用神旺衰定吉凶'],
  ),
];