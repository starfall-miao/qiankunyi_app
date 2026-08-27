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
  final _ctrl = PageController();
  int _page = 0;
  static const _total = 4;

  static const _pages = [
    _OnboardItem(
      emoji: '☯️',
      title: '欢迎来到 落·乾坤',
      desc: '你的掌上易学工具：六爻、梅花易数、八字命理一站式排盘，'
          '还有万年历、罗盘与海量易学资料，随取随用～',
    ),
    _OnboardItem(
      emoji: '🔮',
      title: '三种排盘，随心起卦',
      desc: '六爻支持手工摇卦 / 机器摇卦 / 时间起卦 / 数字起卦；'
          '梅花易数支持三数、日期、物象起卦；八字一键排出四柱、十神、大运流年。',
    ),
    _OnboardItem(
      emoji: '🤖',
      title: 'AI 解卦小助手',
      desc: '保存卦例后，AI 会结合卦象、占问对象与事件，'
          '先解析原卦再给出针对性分析与建议，还可以连续追问哦～',
    ),
    _OnboardItem(
      emoji: '📚',
      title: '开始你的易学之旅',
      desc: '参考资料页内置六十四卦、纳音、星宿、象意字典等；'
          '若需帮助，可在设置页再次查看本引导。祝你好运常在！',
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

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
              Expanded(
                child: PageView.builder(
                  controller: _ctrl,
                  itemCount: _total,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) => _pages[i],
                ),
              ),
              // 指示器
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_total, (i) {
                  final sel = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: sel ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: sel ? scheme.primary : scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              // 按钮
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    if (_page > 0)
                      TextButton(
                        onPressed: () => _ctrl.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        ),
                        child: const Text('上一步'),
                      )
                    else
                      const SizedBox(width: 64),
                    const Spacer(),
                    if (_page < _total - 1)
                      FilledButton(
                        onPressed: () => _ctrl.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        ),
                        child: const Text('下一步'),
                      )
                    else
                      FilledButton.icon(
                        onPressed: widget.onDone,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('开始使用'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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