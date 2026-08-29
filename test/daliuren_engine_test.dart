import 'package:flutter_test/flutter_test.dart';
import 'package:qiankunyi_app/features/paipan/views/daliuren_page.dart';

void main() {
  group('大六壬引擎', () {
    test('正月子时起课：四课/三传/天将排布有值', () {
      final r = DaLiuRenEngine.byHour(0, 1, dayGan: '甲', dayZhi: '子');
      expect(r.siKe.length, 4);
      expect(r.shiYong.length, 3);
      expect(r.tianPan.length, 12);
      expect(r.tianJiang.length, 12);
    });

    test('三传为十二地支之一', () {
      final r = DaLiuRenEngine.byHour(6, 3);
      for (final z in r.shiYong) {
        expect(daliurenZhi, contains(z));
      }
    });

    test('贵人按昼夜阴阳：子时昼用阳贵', () {
      // 甲日昼（子时=0 <6）阳贵 = 丑
      expect(DaLiuRenEngine.calcGuiRen('甲', 0), '丑');
      // 甲日夜（午时=6 >=6）阴贵 = 未
      expect(DaLiuRenEngine.calcGuiRen('甲', 6), '未');
    });

    test('四课含日干支寄宫', () {
      final r = DaLiuRenEngine.byHour(0, 1, dayGan: '甲', dayZhi: '子');
      // 甲寄寅(索引2)，二课（日干下神）= 寅
      expect(r.siKe[1], '寅');
      // 四课（日支下神）= 子
      expect(r.siKe[3], '子');
    });
  });
}
