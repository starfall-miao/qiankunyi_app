// 落·乾坤 - 首次启动使用引导页
import 'package:flutter/material.dart';

/// 使用引导页（首次启动自动弹出，设置页可随时查看）
class OnboardingPage extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingPage({super.key, required this.onDone});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {

  /// 单页引导（内容足够一屏读完，不再分多页）
  static const _item = _OnboardItem(
    emoji: '☯️',
    title: '欢迎来到 落·乾坤',
    desc: '掌上易学工具：六爻 / 梅花 / 八字 / 小六壬 / 大六壬 排盘，'
        '万年历、二十四山罗盘、六十四卦等海量资料，全部离线可用。\n\n'
        '① 排盘：选术数与起卦方式 → 点「排盘」出盘，点任一爻可看详解\n'
        '② 卦例：保存的卦集会汇总在此，可编辑、导出、AI 解卦与追问\n'
        '③ 日历 / 参考 / 百宝箱：万年历宜忌、易学资料、设置与 AI 配置\n\n'
        '想看更细的操作演示？进入后在「百宝箱 → 使用引导」可再播放一次。',
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.primary.withAlpha(36),
              scheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Expanded(child: _item),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: widget.onDone,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('开始使用'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;
  const _OnboardItem({
    required this.emoji,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // emoji 大图标
          Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: scheme.primary.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 52)),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.7,
              color: scheme.onSurface.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }
}