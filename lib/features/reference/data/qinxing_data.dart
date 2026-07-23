/// 禽星关系数据
/// 二十八宿对应的禽兽及其冲合爱畏关系
library;

/// 星宿禽星信息
class QinXingInfo {
  final String name;        // 星宿名
  final String animal;      // 禽兽
  final String group;       // 四象分组：东/南/西/北
  final String element;     // 五行
  final int index;          // 序号 0~27
  final String? chong;      // 冲
  final String? he;         // 合
  final List<String> ai;    // 爱
  final List<String> wei;   // 畏

  const QinXingInfo({
    required this.name,
    required this.animal,
    required this.group,
    required this.element,
    required this.index,
    this.chong,
    this.he,
    this.ai = const [],
    this.wei = const [],
  });
}

/// 二十八宿禽星数据
final List<QinXingInfo> qinXingList = [
  // ── 东方青龙七宿 ──
  QinXingInfo(name: '角', animal: '蛟', group: '东', element: '木', index: 0,
    chong: '亢', he: '斗', ai: ['室', '壁'], wei: ['娄', '胃']),
  QinXingInfo(name: '亢', animal: '龙', group: '东', element: '金', index: 1,
    chong: '角', he: '牛', ai: ['女', '虚'], wei: ['娄', '胃']),
  QinXingInfo(name: '氐', animal: '貉', group: '东', element: '土', index: 2,
    chong: '心', he: '女', ai: ['危', '室'], wei: ['娄', '胃']),
  QinXingInfo(name: '房', animal: '兔', group: '东', element: '火', index: 3,
    chong: '尾', he: '虚', ai: ['壁', '奎'], wei: ['昴', '毕']),
  QinXingInfo(name: '心', animal: '狐', group: '东', element: '火', index: 4,
    chong: '氐', he: '危', ai: ['奎', '娄'], wei: ['昴', '毕']),
  QinXingInfo(name: '尾', animal: '虎', group: '东', element: '木', index: 5,
    chong: '房', he: '室', ai: ['胃', '昴'], wei: ['觜', '参']),
  QinXingInfo(name: '箕', animal: '豹', group: '东', element: '水', index: 6,
    chong: '斗', he: '壁', ai: ['毕', '觜'], wei: ['井', '鬼']),

  // ── 北方玄武七宿 ──
  QinXingInfo(name: '斗', animal: '獬', group: '北', element: '木', index: 7,
    chong: '箕', he: '角', ai: ['觜', '参'], wei: ['星', '张']),
  QinXingInfo(name: '牛', animal: '牛', group: '北', element: '金', index: 8,
    chong: '女', he: '亢', ai: ['参', '井'], wei: ['翼', '轸']),
  QinXingInfo(name: '女', animal: '蝠', group: '北', element: '土', index: 9,
    chong: '牛', he: '氐', ai: ['井', '鬼'], wei: ['轸', '角']),
  QinXingInfo(name: '虚', animal: '鼠', group: '北', element: '水', index: 10,
    chong: '危', he: '房', ai: ['鬼', '柳'], wei: ['角', '亢']),
  QinXingInfo(name: '危', animal: '燕', group: '北', element: '火', index: 11,
    chong: '虚', he: '心', ai: ['星', '张'], wei: ['亢', '氐']),
  QinXingInfo(name: '室', animal: '猪', group: '北', element: '火', index: 12,
    chong: '壁', he: '尾', ai: ['张', '翼'], wei: ['氐', '房']),
  QinXingInfo(name: '壁', animal: '貐', group: '北', element: '水', index: 13,
    chong: '室', he: '箕', ai: ['轸', '角'], wei: ['心', '尾']),

  // ── 西方白虎七宿 ──
  QinXingInfo(name: '奎', animal: '狼', group: '西', element: '木', index: 14,
    chong: '娄', he: '井', ai: ['亢', '氐'], wei: ['箕', '斗']),
  QinXingInfo(name: '娄', animal: '狗', group: '西', element: '金', index: 15,
    chong: '奎', he: '鬼', ai: ['房', '心'], wei: ['斗', '牛']),
  QinXingInfo(name: '胃', animal: '雉', group: '西', element: '土', index: 16,
    chong: '昴', he: '柳', ai: ['尾', '箕'], wei: ['女', '虚']),
  QinXingInfo(name: '昴', animal: '鸡', group: '西', element: '火', index: 17,
    chong: '胃', he: '星', ai: ['斗', '牛'], wei: ['危', '室']),
  QinXingInfo(name: '毕', animal: '乌', group: '西', element: '火', index: 18,
    chong: '觜', he: '张', ai: ['女', '虚'], wei: ['壁', '奎']),
  QinXingInfo(name: '觜', animal: '猴', group: '西', element: '木', index: 19,
    chong: '毕', he: '翼', ai: ['虚', '危'], wei: ['奎', '娄']),
  QinXingInfo(name: '参', animal: '猿', group: '西', element: '水', index: 20,
    chong: '井', he: '轸', ai: ['室', '壁'], wei: ['胃', '昴']),

  // ── 南方朱雀七宿 ──
  QinXingInfo(name: '井', animal: '犴', group: '南', element: '木', index: 21,
    chong: '参', he: '奎', ai: ['娄', '胃'], wei: ['尾', '箕']),
  QinXingInfo(name: '鬼', animal: '羊', group: '南', element: '金', index: 22,
    chong: '柳', he: '娄', ai: ['昴', '毕'], wei: ['箕', '斗']),
  QinXingInfo(name: '柳', animal: '獐', group: '南', element: '土', index: 23,
    chong: '鬼', he: '胃', ai: ['觜', '参'], wei: ['斗', '牛']),
  QinXingInfo(name: '星', animal: '马', group: '南', element: '火', index: 24,
    chong: '张', he: '昴', ai: ['井', '鬼'], wei: ['牛', '女']),
  QinXingInfo(name: '张', animal: '鹿', group: '南', element: '火', index: 25,
    chong: '星', he: '毕', ai: ['柳', '星'], wei: ['虚', '危']),
  QinXingInfo(name: '翼', animal: '蛇', group: '南', element: '水', index: 26,
    chong: '轸', he: '觜', ai: ['星', '张'], wei: ['危', '室']),
  QinXingInfo(name: '轸', animal: '蚓', group: '南', element: '水', index: 27,
    chong: '翼', he: '参', ai: ['翼', '轸'], wei: ['室', '壁']),
];