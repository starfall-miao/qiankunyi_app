/// 神煞/纳音/星宿辅助信息数据
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

/// ========== 二、纳音五行 ==========

const naYinTable = <String, String>{
  '甲子乙丑':'海中金','丙寅丁卯':'炉中火','戊辰己巳':'大林木','庚午辛未':'路旁土','壬申癸酉':'剑锋金',
  '甲戌乙亥':'山头火','丙子丁丑':'涧下水','戊寅己卯':'城头土','庚辰辛巳':'白蜡金','壬午癸未':'杨柳木',
  '甲申乙酉':'泉中水','丙戌丁亥':'屋上土','戊子己丑':'霹雳火','庚寅辛卯':'松柏木','壬辰癸巳':'长流水',
  '甲午乙未':'砂石金','丙申丁酉':'山下火','戊戌己亥':'平地木','庚子辛丑':'壁上土','壬寅癸卯':'金箔金',
  '甲辰乙巳':'覆灯火','丙午丁未':'天河水','戊申己酉':'大驿土','庚戌辛亥':'钗钏金','壬子癸丑':'桑柘木',
  '甲寅乙卯':'大溪水','丙辰丁巳':'砂中土','戊午己未':'天上火','庚申辛酉':'石榴木','壬戌癸亥':'大海水',
};

String? getNaYin(String tianGan, String diZhi) {
  // 查找六十甲子纳音
  for (final entry in naYinTable.entries) {
    if (entry.key.contains(tianGan) && entry.key.contains(diZhi)) {
      // 检查是否一对
      final parts = entry.key;
      if (parts.startsWith(tianGan) || parts.endsWith(tianGan)) {
        return entry.value;
      }
    }
  }
  return null;
}

/// ========== 三、六十四卦辞 ==========

class GuaCi {
  final GuaName name;
  final String title;
  final String ci;
  final String xiang;
  const GuaCi(this.name, this.title, this.ci, this.xiang);
}

const guaCiList = <GuaCi>[
  GuaCi(GuaName.qian, '乾', '元亨利贞', '天行健，君子以自强不息。'),
  GuaCi(GuaName.kun, '坤', '元亨，利牝马之贞', '地势坤，君子以厚德载物。'),
  GuaCi(GuaName.zhun, '屯', '元亨利贞。勿用有攸往，利建侯。', '云雷，屯。君子以经纶。'),
  GuaCi(GuaName.meng, '蒙', '亨。匪我求童蒙，童蒙求我。', '山下出泉，蒙。君子以果行育德。'),
  GuaCi(GuaName.xu, '需', '有孚，光亨，贞吉。利涉大川。', '云上于天，需。君子以饮食宴乐。'),
  GuaCi(GuaName.song, '讼', '有孚窒惕，中吉，终凶。', '天与水违行，讼。君子以作事谋始。'),
  GuaCi(GuaName.shi, '师', '贞，丈人吉，无咎。', '地中有水，师。君子以容民畜众。'),
  GuaCi(GuaName.bi, '比', '吉。原筮元永贞，无咎。', '地上有水，比。先王以建万国，亲诸侯。'),
  GuaCi(GuaName.xiaoXu, '小畜', '亨。密云不雨，自我西郊。', '风行天上，小畜。君子以懿文德。'),
  GuaCi(GuaName.lv, '履', '履虎尾，不咥人，亨。', '上天下泽，履。君子以辨上下，定民志。'),
  GuaCi(GuaName.tai, '泰', '小往大来，吉亨。', '天地交，泰。后以财成天地之道。'),
  GuaCi(GuaName.pi, '否', '否之匪人，不利君子贞。', '天地不交，否。君子以俭德辟难。'),
  GuaCi(GuaName.tongRen, '同人', '同人于野，亨。利涉大川。', '天与火，同人。君子以类族辨物。'),
  GuaCi(GuaName.daYou, '大有', '元亨。', '火在天上，大有。君子以遏恶扬善。'),
  GuaCi(GuaName.qian2, '谦', '亨，君子有终。', '地中有山，谦。君子以裒多益寡。'),
  GuaCi(GuaName.yu, '豫', '利建侯行师。', '雷出地奋，豫。先王以作乐崇德。'),
  GuaCi(GuaName.sui, '随', '元亨利贞，无咎。', '泽中有雷，随。君子以向晦入宴息。'),
  GuaCi(GuaName.gu, '蛊', '元亨。利涉大川。', '山下有风，蛊。君子以振民育德。'),
  GuaCi(GuaName.lin, '临', '元亨利贞。至于八月有凶。', '泽上有地，临。君子以教思无穷。'),
  GuaCi(GuaName.guan, '观', '盥而不荐，有孚颙若。', '风行地上，观。先王以省方观民设教。'),
  GuaCi(GuaName.shiHe, '噬嗑', '亨。利用狱。', '雷电，噬嗑。先王以明罚敕法。'),
  GuaCi(GuaName.bi2, '贲', '亨。小利有攸往。', '山下有火，贲。君子以明庶政。'),
  GuaCi(GuaName.bo, '剥', '不利有攸往。', '山附于地，剥。上以厚下安宅。'),
  GuaCi(GuaName.fu, '复', '亨。出入无疾，朋来无咎。', '雷在地中，复。先王以至日闭关。'),
  GuaCi(GuaName.wuWang, '无妄', '元亨利贞。其匪正有眚。', '天下雷行，物与无妄。'),
  GuaCi(GuaName.daXu, '大畜', '利贞。不家食吉。', '天在山中，大畜。君子以多识前言往行。'),
  GuaCi(GuaName.yi, '颐', '贞吉。观颐，自求口实。', '山下有雷，颐。君子以慎言语，节饮食。'),
  GuaCi(GuaName.daGuo, '大过', '栋桡。利有攸往，亨。', '泽灭木，大过。君子以独立不惧。'),
  GuaCi(GuaName.kan, '坎', '习坎，有孚维心亨。', '水洊至，习坎。君子以常德行。'),
  GuaCi(GuaName.li, '离', '利贞亨。畜牝牛，吉。', '明两作，离。大人以继明照于四方。'),
  GuaCi(GuaName.xian, '咸', '亨，利贞。取女吉。', '山上有泽，咸。君子以虚受人。'),
  GuaCi(GuaName.heng, '恒', '亨，无咎，利贞。', '雷风，恒。君子以立不易方。'),
  GuaCi(GuaName.dun, '遁', '亨，小利贞。', '天下有山，遁。君子以远小人。'),
  GuaCi(GuaName.daZhuang, '大壮', '利贞。', '雷在天上，大壮。君子以非礼弗履。'),
  GuaCi(GuaName.jin, '晋', '康侯用锡马蕃庶。', '明出地上，晋。君子以自昭明德。'),
  GuaCi(GuaName.mingYi, '明夷', '利艰贞。', '明入地中，明夷。君子以莅众。'),
  GuaCi(GuaName.jiaRen, '家人', '利女贞。', '风自火出，家人。君子以言有物而行有恒。'),
  GuaCi(GuaName.kui, '睽', '小事吉。', '上火下泽，睽。君子以同而异。'),
  GuaCi(GuaName.jian, '蹇', '利西南，不利东北。', '山上有水，蹇。君子以反身修德。'),
  GuaCi(GuaName.jie, '解', '利西南。无所往，其来复吉。', '雷雨作，解。君子以赦过宥罪。'),
  GuaCi(GuaName.sun, '损', '有孚，元吉，无咎。', '山下有泽，损。君子以惩忿窒欲。'),
  GuaCi(GuaName.yi2, '益', '利有攸往，利涉大川。', '风雷，益。君子以见善则迁。'),
  GuaCi(GuaName.guai, '夬', '扬于王庭，孚号有厉。', '泽上于天，夬。君子以施禄及下。'),
  GuaCi(GuaName.gou, '姤', '女壮，勿用取女。', '天下有风，姤。后以施命诰四方。'),
  GuaCi(GuaName.cui, '萃', '亨。王假有庙。', '泽上于地，萃。君子以除戎器。'),
  GuaCi(GuaName.sheng, '升', '元亨。用见大人。', '地中生木，升。君子以顺德。'),
  GuaCi(GuaName.kun2, '困', '亨。贞，大人吉。', '泽无水，困。君子以致命遂志。'),
  GuaCi(GuaName.jing, '井', '改邑不改井，无丧无得。', '木上有水，井。君子以劳民劝相。'),
  GuaCi(GuaName.ge, '革', '已日乃孚。元亨利贞。', '泽中有火，革。君子以治历明时。'),
  GuaCi(GuaName.ding, '鼎', '元吉，亨。', '木上有火，鼎。君子以正位凝命。'),
  GuaCi(GuaName.zhen, '震', '亨。震来虩虩，笑言哑哑。', '洊雷，震。君子以恐惧修省。'),
  GuaCi(GuaName.gen, '艮', '艮其背，不获其身。', '兼山，艮。君子以思不出其位。'),
  GuaCi(GuaName.jian2, '渐', '女归吉，利贞。', '山上有木，渐。君子以居贤德善俗。'),
  GuaCi(GuaName.guiMei, '归妹', '征凶，无攸利。', '泽上有雷，归妹。君子以永终知敝。'),
  GuaCi(GuaName.feng, '丰', '亨。王假之，勿忧。', '雷电皆至，丰。君子以折狱致刑。'),
  GuaCi(GuaName.lv2, '旅', '小亨。旅贞吉。', '山上有火，旅。君子以明慎用刑。'),
  GuaCi(GuaName.xun, '巽', '小亨。利有攸往。', '随风，巽。君子以申命行事。'),
  GuaCi(GuaName.dui, '兑', '亨，利贞。', '丽泽，兑。君子以朋友讲习。'),
  GuaCi(GuaName.huan, '涣', '亨。王假有庙。', '风行水上，涣。先王以享于帝。'),
  GuaCi(GuaName.jie2, '节', '亨。苦节不可贞。', '泽上有水，节。君子以制数度。'),
  GuaCi(GuaName.zhongFu, '中孚', '豚鱼吉。利涉大川。', '泽上有风，中孚。君子以议狱缓死。'),
  GuaCi(GuaName.xiaoGuo, '小过', '亨，利贞。可小事。', '山上有雷，小过。君子以行过乎恭。'),
  GuaCi(GuaName.jiJi, '既济', '亨小，利贞。初吉终乱。', '水在火上，既济。君子以思患而豫防之。'),
  GuaCi(GuaName.weiJi, '未济', '亨。小狐汔济，濡其尾。', '火在水上，未济。君子以慎辨物居方。'),
];

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
