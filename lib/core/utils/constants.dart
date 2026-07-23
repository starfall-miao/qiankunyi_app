/// 乾坤易 - 应用常量定义
class AppConstants {
  AppConstants._();

  /// 应用名称
  static const String appName = '乾坤易';

  /// 应用描述
  static const String appDescription = '玄学排盘与案例管理工具';

  /// 版本号
  static const String appVersion = '1.0.0';

  /// 数据库名称
  static const String databaseName = 'qiankunyi.db';

  /// 数据库版本
  static const int databaseVersion = 1;

  /// 主题存储 key
  static const String themeModeKey = 'theme_mode';

  /// 是否首次启动
  static const String isFirstLaunchKey = 'is_first_launch';

  // ─── 排盘相关常量 ───

  /// 天干列表
  static const List<String> heavenlyStems = [
    '甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸',
  ];

  /// 地支列表
  static const List<String> earthlyBranches = [
    '子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥',
  ];

  /// 五行列表
  static const List<String> fiveElements = [
    '金', '木', '水', '火', '土',
  ];
}
