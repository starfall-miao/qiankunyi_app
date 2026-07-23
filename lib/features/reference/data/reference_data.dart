/// 神煞/纳音/星宿/八卦辅助信息数据
/// 纯 Dart 硬编码，离线可用
library;

import '../../paipan/models/gua_model.dart';

/// ========== 一、神煞系统 ==========

class ShenSha {
  final String name;
  final String description;
  const ShenSha(this.name, this.description);
}

List<ShenSha> getShenShaByYearGan(String tianGan) {
  switch (tianGan) {
    case '甲': return [const ShenSha('天乙贵人','丑未'),const ShenSha('文昌','巳'),const ShenSha('桃花','卯'),const ShenSha('禄神','寅')];
    case '乙': return [const ShenSha('天乙贵人','子申'),const ShenSha('文昌','午'),const ShenSha('桃花','辰'),const ShenSha('禄神','卯')];
    case '丙': return [const ShenSha('天乙贵人','亥酉'),const ShenSha('文昌','申'),const ShenSha('桃花','午'),const ShenSha('禄神','巳')];
    case '丁': return [const ShenSha('天乙贵人','亥酉'),const ShenSha('文昌','酉'),const ShenSha('桃花','未'),const ShenSha('禄神','午')];
    case '戊': return [const ShenSha('天乙贵人','丑未'),const ShenSha('文昌','申'),const ShenSha('桃花','午'),const ShenSha('禄神','巳')];
    case '己': return [const ShenSha('天乙贵人','子申'),const ShenSha('文昌','酉'),const ShenSha('桃花','未'),const ShenSha('禄神','午')];
    case '庚': return [const ShenSha('天乙贵人','丑未'),const ShenSha('文昌','亥'),const ShenSha('桃花','酉'),const ShenSha('禄神','申')];
    case '辛': return [const ShenSha('天乙贵人','午寅'),const ShenSha('文昌','子'),const ShenSha('桃花','戌'),const ShenSha('禄神','酉')];
    case '壬': return [const ShenSha('天乙贵人','卯巳'),const ShenSha('文昌','寅'),const ShenSha('桃花','子'),const ShenSha('禄神','亥')];
    case '癸': return [const ShenSha('天乙贵人','卯巳'),const ShenSha('文昌','卯'),const ShenSha('桃花','丑'),const ShenSha('禄神','子')];
    default: return [];
  }
}

List<ShenSha> getShenShaByYearZhi(String diZhi) {
  switch (diZhi) {
    case '子': return [const ShenSha('将星','子'),const ShenSha('驿马','寅'),const ShenSha('华盖','辰')];
    case '丑': return [const ShenSha('将星','酉'),const ShenSha('驿马','亥'),const ShenSha('华盖','丑')];
    case '寅': return [const ShenSha('将星','午'),const ShenSha('驿马','申'),const ShenSha('华盖','戌')];
    case '卯': return [const ShenSha('将星','卯'),const ShenSha('驿马','巳'),const ShenSha('华盖','未')];
    case '辰': return [const ShenSha('将星','子'),const ShenSha('驿马','寅'),const ShenSha('华盖','辰')];
    case '巳': return [const ShenSha('将星','酉'),const ShenSha('驿马','亥'),const ShenSha('华盖','丑')];
    case '午': return [const ShenSha('将星','午'),const ShenSha('驿马','申'),const ShenSha('华盖','戌')];
    case '未': return [const ShenSha('将星','卯'),const ShenSha('驿马','巳'),const ShenSha('华盖','未')];
    case '申': return [const ShenSha('将星','子'),const ShenSha('驿马','寅'),const ShenSha('华盖','辰')];
    case '酉': return [const ShenSha('将星','酉'),const ShenSha('驿马','亥'),const ShenSha('华盖','丑')];
    case '戌': return [const ShenSha('将星','午'),const ShenSha('驿马','申'),const ShenSha('华盖','戌')];
    case '亥': return [const ShenSha('将星','卯'),const ShenSha('驿马','巳'),const ShenSha('华盖','未')];
    default: return [];
  }
}

/// ========== 二、纳音表 ==========

class NaYin {
  final String naYin;
  final String wuXing;
  const NaYin(this.naYin, this.wuXing);
}

/// 六十甲子纳音表，按甲子~癸亥顺序排列
const naYinTable = <NaYin>[
  NaYin('海中金','金'), NaYin('炉中火','火'), NaYin('大林木','木'),
  NaYin('路旁土','土'), NaYin('剑锋金','金'), NaYin('山头火','火'),
  NaYin('涧下水','水'), NaYin('城头土','土'), NaYin('白蜡金','金'),
  NaYin('杨柳木','木'), NaYin('泉中水','水'), NaYin('屋上土','土'),
  NaYin('霹雳火','火'), NaYin('松柏木','木'), NaYin('长流水','水'),
  NaYin('砂石金','金'), NaYin('山下火','火'), NaYin('平地木','木'),
  NaYin('壁上土','土'), NaYin('金箔金','金'), NaYin('覆灯火','火'),
  NaYin('天河水','水'), NaYin('大驿土','土'), NaYin('钗钏金','金'),
  NaYin('桑柘木','木'), NaYin('大溪水','水'), NaYin('沙中土','土'),
  NaYin('天上火','火'), NaYin('石榴木','木'), NaYin('大海水','水'),
];

/// 根据干支获取纳音（60甲子索引）
NaYin? getNaYin(int tianGanIndex, int diZhiIndex) {
  if (tianGanIndex < 0 || tianGanIndex > 9 || diZhiIndex < 0 || diZhiIndex > 11) return null;
  final idx = (tianGanIndex % 10) ~/ 2 * 6 + (diZhiIndex % 12) ~/ 2;
  if (idx < 0 || idx >= naYinTable.length) return null;
  return naYinTable[idx];
}

/// ========== 三、六十四卦辞及辅助意象 ==========

class GuaCi {
  final GuaName name;
  final String title;       // 卦名（中文）
  final String ci;          // 卦辞
  final String xiang;       // 象辞
  final String yiXiang;     // 意象（如"天行健，君子以自强不息"）
  final String wuXing;      // 五行属性
  final String fangWei;     // 方位
  final String shuZi;       // 数字
  final String ziRan;       // 自然象征
  final String renWu;       // 人物象征
  final String jiXiong;     // 吉凶判断

  const GuaCi({
    required this.name,
    required this.title,
    required this.ci,
    required this.xiang,
    this.yiXiang = '',
    this.wuXing = '',
    this.fangWei = '',
    this.shuZi = '',
    this.ziRan = '',
    this.renWu = '',
    this.jiXiong = '',
  });
}

/// 八宫六十四卦
const baguaGong = <String, List<GuaCi>>{
  '乾宫': [
    GuaCi(name: GuaName.qian, title: '乾', ci: '元亨利贞。', xiang: '天行健，君子以自强不息。',
        yiXiang: '天行健，君子以自强不息', wuXing: '金', fangWei: '西北', shuZi: '1,9',
        ziRan: '天', renWu: '君父', jiXiong: '大吉'),
    GuaCi(name: GuaName.gou, title: '姤', ci: '女壮，勿用取女。', xiang: '天下有风，姤。后以施命诰四方。',
        yiXiang: '天下有风，姤。君子以施命诰四方', wuXing: '金', fangWei: '西北', shuZi: '5,10',
        ziRan: '风', renWu: '邂逅', jiXiong: '中平'),
    GuaCi(name: GuaName.dun, title: '遁', ci: '亨。小利贞。', xiang: '天下有山，遁。君子以远小人，不恶而严。',
        yiXiang: '天下有山，遁。君子以远小人', wuXing: '金', fangWei: '西北', shuZi: '3,8',
        ziRan: '山', renWu: '隐士', jiXiong: '中吉'),
    GuaCi(name: GuaName.pi, title: '否', ci: '否之匪人，不利君子贞。', xiang: '天地不交，否。君子以俭德辟难。',
        yiXiang: '天地不交，否。君子以俭德辟难', wuXing: '金', fangWei: '西北', shuZi: '2,6',
        ziRan: '天地', renWu: '闭塞', jiXiong: '凶'),
    GuaCi(name: GuaName.guan, title: '观', ci: '盥而不荐，有孚颙若。', xiang: '风行地上，观。先王以省方观民设教。',
        yiXiang: '风行地上，观。先王以省方观民设教', wuXing: '金', fangWei: '西北', shuZi: '4,9',
        ziRan: '风', renWu: '观察', jiXiong: '中平'),
    GuaCi(name: GuaName.bo, title: '剥', ci: '不利有攸往。', xiang: '山附于地，剥。上以厚下安宅。',
        yiXiang: '山附于地，剥。上以厚下安宅', wuXing: '金', fangWei: '西北', shuZi: '5,6',
        ziRan: '山', renWu: '剥落', jiXiong: '凶'),
    GuaCi(name: GuaName.jin, title: '晋', ci: '康侯用锡马蕃庶，昼日三接。', xiang: '明出地上，晋。君子以自昭明德。',
        yiXiang: '明出地上，晋。君子以自昭明德', wuXing: '金', fangWei: '西北', shuZi: '3,7',
        ziRan: '日', renWu: '上升', jiXiong: '大吉'),
    GuaCi(name: GuaName.daYou, title: '大有', ci: '元亨。', xiang: '火在天上，大有。君子以遏恶扬善，顺天休命。',
        yiXiang: '火在天上，大有。君子以遏恶扬善', wuXing: '金', fangWei: '西北', shuZi: '5,9',
        ziRan: '天', renWu: '丰盛', jiXiong: '大吉'),
  ],
  '兑宫': [
    GuaCi(name: GuaName.dui, title: '兑', ci: '亨，利贞。', xiang: '丽泽，兑。君子以朋友讲习。',
        yiXiang: '丽泽，兑。君子以朋友讲习', wuXing: '金', fangWei: '西', shuZi: '2,7',
        ziRan: '泽', renWu: '少女', jiXiong: '大吉'),
    GuaCi(name: GuaName.kun2, title: '困', ci: '亨。贞大人吉，无咎。', xiang: '泽无水，困。君子以致命遂志。',
        yiXiang: '泽无水，困。君子以致命遂志', wuXing: '金', fangWei: '西', shuZi: '4,9',
        ziRan: '泽', renWu: '困境', jiXiong: '凶'),
    GuaCi(name: GuaName.cui, title: '萃', ci: '亨。王假有庙。', xiang: '泽上于地，萃。君子以除戎器，戒不虞。',
        yiXiang: '泽上于地，萃。君子以除戎器戒不虞', wuXing: '金', fangWei: '西', shuZi: '5,6',
        ziRan: '泽', renWu: '聚集', jiXiong: '中吉'),
    GuaCi(name: GuaName.xian, title: '咸', ci: '亨，利贞。取女吉。', xiang: '山上有泽，咸。君子以虚受人。',
        yiXiang: '山上有泽，咸。君子以虚受人', wuXing: '金', fangWei: '西', shuZi: '3,8',
        ziRan: '山', renWu: '感应', jiXiong: '中吉'),
    GuaCi(name: GuaName.jian, title: '蹇', ci: '利西南，不利东北。', xiang: '山上有水，蹇。君子以反身修德。',
        yiXiang: '山上有水，蹇。君子以反身修德', wuXing: '金', fangWei: '西', shuZi: '6,9',
        ziRan: '山', renWu: '艰难', jiXiong: '小凶'),
    GuaCi(name: GuaName.qian2, title: '谦', ci: '亨。君子有终。', xiang: '地中有山，谦。君子以裒多益寡，称物平施。',
        yiXiang: '地中有山，谦。君子以裒多益寡', wuXing: '金', fangWei: '西', shuZi: '5,6',
        ziRan: '山', renWu: '谦逊', jiXiong: '大吉'),
    GuaCi(name: GuaName.xiaoGuo, title: '小过', ci: '亨，利贞。可小事，不可大事。', xiang: '山上有雷，小过。君子以行过乎恭，丧过乎哀，用过乎俭。',
        yiXiang: '山上有雷，小过。君子以行过乎恭', wuXing: '金', fangWei: '西', shuZi: '4,8',
        ziRan: '雷', renWu: '小过', jiXiong: '小凶'),
    GuaCi(name: GuaName.guiMei, title: '归妹', ci: '征凶，无攸利。', xiang: '泽上有雷，归妹。君子以永终知敝。',
        yiXiang: '泽上有雷，归妹。君子以永终知敝', wuXing: '金', fangWei: '西', shuZi: '3,8',
        ziRan: '泽', renWu: '婚姻', jiXiong: '中平'),
  ],
  '离宫': [
    GuaCi(name: GuaName.li, title: '离', ci: '利贞，亨。', xiang: '明两作，离。大人以继明照于四方。',
        yiXiang: '明两作，离。大人以继明照于四方', wuXing: '火', fangWei: '南', shuZi: '3,9',
        ziRan: '火', renWu: '中女', jiXiong: '中吉'),
    GuaCi(name: GuaName.lv2, title: '旅', ci: '小亨。旅贞吉。', xiang: '山上有火，旅。君子以明慎用刑。',
        yiXiang: '山上有火，旅。君子以明慎用刑', wuXing: '火', fangWei: '南', shuZi: '5,6',
        ziRan: '山', renWu: '旅人', jiXiong: '小凶'),
    GuaCi(name: GuaName.ding, title: '鼎', ci: '元吉，亨。', xiang: '木上有火，鼎。君子以正位凝命。',
        yiXiang: '木上有火，鼎。君子以正位凝命', wuXing: '火', fangWei: '南', shuZi: '4,9',
        ziRan: '鼎', renWu: '革新', jiXiong: '大吉'),
    GuaCi(name: GuaName.weiJi, title: '未济', ci: '亨。小狐汔济，濡其尾，无攸利。', xiang: '火在水上，未济。君子以慎辨物居方。',
        yiXiang: '火在水上，未济。君子以慎辨物居方', wuXing: '火', fangWei: '南', shuZi: '3,7',
        ziRan: '火', renWu: '未成', jiXiong: '中平'),
    GuaCi(name: GuaName.meng, title: '蒙', ci: '亨。匪我求童蒙，童蒙求我。', xiang: '山下有泉，蒙。君子以果行育德。',
        yiXiang: '山下有泉，蒙。君子以果行育德', wuXing: '火', fangWei: '南', shuZi: '2,6',
        ziRan: '泉', renWu: '启蒙', jiXiong: '中平'),
    GuaCi(name: GuaName.huan, title: '涣', ci: '亨。王假有庙，利涉大川。', xiang: '风行水上，涣。先王以享于帝立庙。',
        yiXiang: '风行水上，涣。先王以享于帝立庙', wuXing: '火', fangWei: '南', shuZi: '5,8',
        ziRan: '水', renWu: '涣散', jiXiong: '中平'),
    GuaCi(name: GuaName.song, title: '讼', ci: '有孚窒惕，中吉。', xiang: '天与水违行，讼。君子以作事谋始。',
        yiXiang: '天与水违行，讼。君子以作事谋始', wuXing: '火', fangWei: '南', shuZi: '3,6',
        ziRan: '天', renWu: '争讼', jiXiong: '凶'),
    GuaCi(name: GuaName.tongRen, title: '同人', ci: '同人于野，亨。', xiang: '天与火，同人。君子以类族辨物。',
        yiXiang: '天与火，同人。君子以类族辨物', wuXing: '火', fangWei: '南', shuZi: '2,7',
        ziRan: '天', renWu: '大同', jiXiong: '大吉'),
  ],
  '震宫': [
    GuaCi(name: GuaName.zhen, title: '震', ci: '亨。震来虩虩，笑言哑哑。', xiang: '洊雷，震。君子以恐惧修省。',
        yiXiang: '洊雷，震。君子以恐惧修省', wuXing: '木', fangWei: '东', shuZi: '4,8',
        ziRan: '雷', renWu: '长子', jiXiong: '中吉'),
    GuaCi(name: GuaName.yu, title: '豫', ci: '利建侯行师。', xiang: '雷出地奋，豫。先王以作乐崇德。',
        yiXiang: '雷出地奋，豫。先王以作乐崇德', wuXing: '木', fangWei: '东', shuZi: '3,7',
        ziRan: '雷', renWu: '豫乐', jiXiong: '中吉'),
    GuaCi(name: GuaName.jie, title: '解', ci: '利西南。无所往，其来复吉。', xiang: '雷雨作，解。君子以赦过宥罪。',
        yiXiang: '雷雨作，解。君子以赦过宥罪', wuXing: '木', fangWei: '东', shuZi: '2,6',
        ziRan: '雷', renWu: '解脱', jiXiong: '中吉'),
    GuaCi(name: GuaName.heng, title: '恒', ci: '亨，无咎。利贞。', xiang: '雷风，恒。君子以立不易方。',
        yiXiang: '雷风，恒。君子以立不易方', wuXing: '木', fangWei: '东', shuZi: '4,7',
        ziRan: '雷', renWu: '恒久', jiXiong: '中吉'),
    GuaCi(name: GuaName.sheng, title: '升', ci: '元亨。用见大人。', xiang: '地中生木，升。君子以顺德，积小以高大。',
        yiXiang: '地中生木，升。君子以顺德积小高大', wuXing: '木', fangWei: '东', shuZi: '5,6',
        ziRan: '地', renWu: '上升', jiXiong: '大吉'),
    GuaCi(name: GuaName.jing, title: '井', ci: '改邑不改井，无丧无得。', xiang: '木上有水，井。君子以劳民劝相。',
        yiXiang: '木上有水，井。君子以劳民劝相', wuXing: '木', fangWei: '东', shuZi: '3,6',
        ziRan: '井', renWu: '养人', jiXiong: '中平'),
    GuaCi(name: GuaName.daGuo, title: '大过', ci: '栋桡。利有攸往，亨。', xiang: '泽灭木，大过。君子以独立不惧，遁世无闷。',
        yiXiang: '泽灭木，大过。君子以独立不惧', wuXing: '木', fangWei: '东', shuZi: '4,9',
        ziRan: '泽', renWu: '过甚', jiXiong: '凶'),
    GuaCi(name: GuaName.sui, title: '随', ci: '元亨利贞，无咎。', xiang: '泽中有雷，随。君子以向晦入宴息。',
        yiXiang: '泽中有雷，随。君子以向晦入宴息', wuXing: '木', fangWei: '东', shuZi: '2,7',
        ziRan: '泽', renWu: '随从', jiXiong: '中吉'),
  ],
  '巽宫': [
    GuaCi(name: GuaName.xun, title: '巽', ci: '小亨。利有攸往，利见大人。', xiang: '随风，巽。君子以申命行事。',
        yiXiang: '随风，巽。君子以申命行事', wuXing: '木', fangWei: '东南', shuZi: '5,8',
        ziRan: '风', renWu: '长女', jiXiong: '中吉'),
    GuaCi(name: GuaName.xiaoXu, title: '小畜', ci: '亨。密云不雨，自我西郊。', xiang: '风行天上，小畜。君子以懿文德。',
        yiXiang: '风行天上，小畜。君子以懿文德', wuXing: '木', fangWei: '东南', shuZi: '3,8',
        ziRan: '风', renWu: '小蓄', jiXiong: '中平'),
    GuaCi(name: GuaName.jiaRen, title: '家人', ci: '利女贞。', xiang: '风自火出，家人。君子以言有物而行有恒。',
        yiXiang: '风自火出，家人。君子以言有物而行有恒', wuXing: '木', fangWei: '东南', shuZi: '2,7',
        ziRan: '风', renWu: '家庭', jiXiong: '大吉'),
    GuaCi(name: GuaName.yi2, title: '益', ci: '利有攸往，利涉大川。', xiang: '风雷，益。君子以见善则迁，有过则改。',
        yiXiang: '风雷，益。君子以见善则迁', wuXing: '木', fangWei: '东南', shuZi: '4,9',
        ziRan: '风', renWu: '增益', jiXiong: '大吉'),
    GuaCi(name: GuaName.wuWang, title: '无妄', ci: '元亨利贞。其匪正有眚。', xiang: '天下雷行，物与无妄。先王以茂对时育万物。',
        yiXiang: '天下雷行，无妄。先王以茂对时育万物', wuXing: '木', fangWei: '东南', shuZi: '3,6',
        ziRan: '天', renWu: '无妄', jiXiong: '中吉'),
    GuaCi(name: GuaName.shiHe, title: '噬嗑', ci: '亨。利用狱。', xiang: '雷电，噬嗑。先王以明罚敕法。',
        yiXiang: '雷电，噬嗑。先王以明罚敕法', wuXing: '木', fangWei: '东南', shuZi: '5,8',
        ziRan: '雷电', renWu: '刑罚', jiXiong: '中平'),
    GuaCi(name: GuaName.yi, title: '颐', ci: '贞吉。观颐，自求口实。', xiang: '山下有雷，颐。君子以慎言语，节饮食。',
        yiXiang: '山下有雷，颐。君子以慎言语节饮食', wuXing: '木', fangWei: '东南', shuZi: '2,4',
        ziRan: '山', renWu: '颐养', jiXiong: '中吉'),
    GuaCi(name: GuaName.gu, title: '蛊', ci: '元亨。利涉大川。先甲三日，后甲三日。', xiang: '山下有风，蛊。君子以振民育德。',
        yiXiang: '山下有风，蛊。君子以振民育德', wuXing: '木', fangWei: '东南', shuZi: '3,7',
        ziRan: '山', renWu: '败事', jiXiong: '小凶'),
  ],
  '坎宫': [
    GuaCi(name: GuaName.kan, title: '坎', ci: '习坎，有孚维心亨。', xiang: '水洊至，习坎。君子以常德行，习教事。',
        yiXiang: '水洊至，习坎。君子以常德行习教事', wuXing: '水', fangWei: '北', shuZi: '1,6',
        ziRan: '水', renWu: '中男', jiXiong: '中平'),
    GuaCi(name: GuaName.jie2, title: '节', ci: '亨。苦节不可贞。', xiang: '泽上有水，节。君子以制数度，议德行。',
        yiXiang: '泽上有水，节。君子以制数度议德行', wuXing: '水', fangWei: '北', shuZi: '5,8',
        ziRan: '泽', renWu: '节制', jiXiong: '中吉'),
    GuaCi(name: GuaName.zhun, title: '屯', ci: '元亨利贞。勿用有攸往。', xiang: '云雷，屯。君子以经纶。',
        yiXiang: '云雷屯，君子以经纶', wuXing: '水', fangWei: '北', shuZi: '4,8',
        ziRan: '云雷', renWu: '创始', jiXiong: '小凶'),
    GuaCi(name: GuaName.jiJi, title: '既济', ci: '亨小，利贞。初吉终乱。', xiang: '水在火上，既济。君子以思患而豫防之。',
        yiXiang: '水在火上，既济。君子以思患而豫防之', wuXing: '水', fangWei: '北', shuZi: '3,7',
        ziRan: '水', renWu: '已成', jiXiong: '大吉'),
    GuaCi(name: GuaName.ge, title: '革', ci: '已日乃孚。元亨利贞，悔亡。', xiang: '泽中有火，革。君子以治历明时。',
        yiXiang: '泽中有火，革。君子以治历明时', wuXing: '水', fangWei: '北', shuZi: '4,9',
        ziRan: '泽', renWu: '变革', jiXiong: '中吉'),
    GuaCi(name: GuaName.feng, title: '丰', ci: '亨。王假之，勿忧。', xiang: '雷电皆至，丰。君子以折狱致刑。',
        yiXiang: '雷电皆至，丰。君子以折狱致刑', wuXing: '水', fangWei: '北', shuZi: '2,6',
        ziRan: '雷', renWu: '丰盛', jiXiong: '大吉'),
    GuaCi(name: GuaName.mingYi, title: '明夷', ci: '利艰贞。', xiang: '明入地中，明夷。君子以莅众，用晦而明。',
        yiXiang: '明入地中，明夷。君子以莅众', wuXing: '水', fangWei: '北', shuZi: '3,8',
        ziRan: '日', renWu: '晦暗', jiXiong: '小凶'),
    GuaCi(name: GuaName.shi, title: '师', ci: '贞丈人吉，无咎。', xiang: '地中有水，师。君子以容民畜众。',
        yiXiang: '地中有水，师。君子以容民畜众', wuXing: '水', fangWei: '北', shuZi: '2,7',
        ziRan: '地', renWu: '统率', jiXiong: '中平'),
  ],
  '艮宫': [
    GuaCi(name: GuaName.gen, title: '艮', ci: '艮其背，不获其身。', xiang: '兼山，艮。君子以思不出其位。',
        yiXiang: '兼山，艮。君子以思不出其位', wuXing: '土', fangWei: '东北', shuZi: '5,7',
        ziRan: '山', renWu: '少男', jiXiong: '中吉'),
    GuaCi(name: GuaName.bi2, title: '贲', ci: '亨。小利有攸往。', xiang: '山下有火，贲。君子以明庶政，无敢折狱。',
        yiXiang: '山下有火，贲。君子以明庶政', wuXing: '土', fangWei: '东北', shuZi: '3,8',
        ziRan: '山', renWu: '装饰', jiXiong: '中平'),
    GuaCi(name: GuaName.daXu, title: '大畜', ci: '利贞。不家食吉。', xiang: '天在山中，大畜。君子以多识前言往行，以畜其德。',
        yiXiang: '天在山中，大畜。君子以多识前言往行', wuXing: '土', fangWei: '东北', shuZi: '4,9',
        ziRan: '天', renWu: '积蓄', jiXiong: '大吉'),
    GuaCi(name: GuaName.sun, title: '损', ci: '有孚，元吉，无咎。', xiang: '山下有泽，损。君子以惩忿窒欲。',
        yiXiang: '山下有泽，损。君子以惩忿窒欲', wuXing: '土', fangWei: '东北', shuZi: '2,6',
        ziRan: '山', renWu: '减损', jiXiong: '小凶'),
    GuaCi(name: GuaName.kui, title: '睽', ci: '小事吉。', xiang: '上火下泽，睽。君子以同而异。',
        yiXiang: '上火下泽，睽。君子以同而异', wuXing: '土', fangWei: '东北', shuZi: '4,8',
        ziRan: '火', renWu: '乖离', jiXiong: '小凶'),
    GuaCi(name: GuaName.lv, title: '履', ci: '履虎尾，不咥人。亨。', xiang: '上天下泽，履。君子以辨上下，定民志。',
        yiXiang: '上天下泽，履。君子以辨上下定民志', wuXing: '土', fangWei: '东北', shuZi: '5,8',
        ziRan: '天', renWu: '履行', jiXiong: '中吉'),
    GuaCi(name: GuaName.zhongFu, title: '中孚', ci: '豚鱼吉。利涉大川。', xiang: '泽上有风，中孚。君子以议狱缓死。',
        yiXiang: '泽上有风，中孚。君子以议狱缓死', wuXing: '土', fangWei: '东北', shuZi: '3,7',
        ziRan: '泽', renWu: '诚信', jiXiong: '大吉'),
    GuaCi(name: GuaName.jian2, title: '渐', ci: '女归吉，利贞。', xiang: '山上有木，渐。君子以居贤德善俗。',
        yiXiang: '山上有木，渐。君子以居贤德善俗', wuXing: '土', fangWei: '东北', shuZi: '1,6',
        ziRan: '山', renWu: '渐进', jiXiong: '中吉'),
  ],
  '坤宫': [
    GuaCi(name: GuaName.kun, title: '坤', ci: '元亨，利牝马之贞。', xiang: '地势坤，君子以厚德载物。',
        yiXiang: '地势坤，君子以厚德载物', wuXing: '土', fangWei: '西南', shuZi: '2,8',
        ziRan: '地', renWu: '母后', jiXiong: '大吉'),
    GuaCi(name: GuaName.fu, title: '复', ci: '亨。出入无疾。', xiang: '雷在地中，复。先王以至日闭关。',
        yiXiang: '雷在地中，复。先王以至日闭关', wuXing: '土', fangWei: '西南', shuZi: '4,6',
        ziRan: '雷', renWu: '回复', jiXiong: '大吉'),
    GuaCi(name: GuaName.lin, title: '临', ci: '元亨利贞。至于八月有凶。', xiang: '泽上有地，临。君子以教思无穷，容保民无疆。',
        yiXiang: '泽上有地，临。君子以教思无穷', wuXing: '土', fangWei: '西南', shuZi: '3,7',
        ziRan: '泽', renWu: '临下', jiXiong: '中吉'),
    GuaCi(name: GuaName.tai, title: '泰', ci: '小往大来，吉亨。', xiang: '天地交，泰。后以财成天地之道，辅相天地之宜。',
        yiXiang: '天地交，泰。后以财成天地之道', wuXing: '土', fangWei: '西南', shuZi: '1,8',
        ziRan: '天地', renWu: '安泰', jiXiong: '大吉'),
    GuaCi(name: GuaName.daZhuang, title: '大壮', ci: '利贞。', xiang: '雷在天上，大壮。君子以非礼弗履。',
        yiXiang: '雷在天上，大壮。君子以非礼弗履', wuXing: '土', fangWei: '西南', shuZi: '4,7',
        ziRan: '雷', renWu: '强壮', jiXiong: '中吉'),
    GuaCi(name: GuaName.guai, title: '夬', ci: '扬于王庭，孚号有厉。', xiang: '泽上于天，夬。君子以施禄及下，居德则忌。',
        yiXiang: '泽上于天，夬。君子以施禄及下', wuXing: '土', fangWei: '西南', shuZi: '5,6',
        ziRan: '泽', renWu: '决断', jiXiong: '中平'),
    GuaCi(name: GuaName.xu, title: '需', ci: '有孚，光亨，贞吉。', xiang: '云上于天，需。君子以饮食宴乐。',
        yiXiang: '云上于天，需。君子以饮食宴乐', wuXing: '土', fangWei: '西南', shuZi: '2,6',
        ziRan: '云', renWu: '等待', jiXiong: '中平'),
    GuaCi(name: GuaName.bi, title: '比', ci: '吉。原筮，元永贞。', xiang: '地上有水，比。先王以建万国，亲诸侯。',
        yiXiang: '地上有水，比。先王以建万国亲诸侯', wuXing: '土', fangWei: '西南', shuZi: '5,8',
        ziRan: '地', renWu: '亲附', jiXiong: '大吉'),
  ],
};

/// 平铺列表（通过 baguaGong 生成）
List<GuaCi> get guaCiList => baguaGong.values.expand((x) => x).toList();

GuaCi? getGuaCi(GuaName name) {
  for (final gc in guaCiList) {
    if (gc.name == name) return gc;
  }
  return null;
}

/// ========== 四、二十八星宿 ==========

class XingXiu {
  final String name;
  final String animal;
  final String element;
  final String direction;
  const XingXiu(this.name, this.animal, this.element, this.direction);
}

const erShiBaXingXiu = <XingXiu>[
  XingXiu('角','木蛟','木','东'), XingXiu('亢','金龙','金','东'),
  XingXiu('氐','土貉','土','东'), XingXiu('房','日兔','火','东'),
  XingXiu('心','月狐','火','东'), XingXiu('尾','火虎','火','东'),
  XingXiu('箕','水豹','水','东'), XingXiu('斗','木獬','木','北'),
  XingXiu('牛','金牛','金','北'), XingXiu('女','土蝠','土','北'),
  XingXiu('虚','日鼠','火','北'), XingXiu('危','月燕','火','北'),
  XingXiu('室','火猪','火','北'), XingXiu('壁','水俞','水','北'),
  XingXiu('奎','木狼','木','西'), XingXiu('娄','金狗','金','西'),
  XingXiu('胃','土雉','土','西'), XingXiu('昴','日鸡','火','西'),
  XingXiu('毕','月乌','火','西'), XingXiu('觜','火猴','火','西'),
  XingXiu('参','水猿','水','西'), XingXiu('井','木犴','木','南'),
  XingXiu('鬼','金羊','金','南'), XingXiu('柳','土獐','土','南'),
  XingXiu('星','日马','火','南'), XingXiu('张','月鹿','火','南'),
  XingXiu('翼','火蛇','火','南'), XingXiu('轸','水蚓','水','南'),
];