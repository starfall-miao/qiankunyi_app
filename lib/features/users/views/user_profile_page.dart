// 落·乾坤 - 用户画像设置页（多用户、密码、八字画像、AI参考）
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../calendar/views/calendar_picker_dialog.dart';
import '../providers/user_provider.dart';
import '../models/user_profile.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  UserProfile? get current => context.watch<UserProvider>().current;

  @override
  Widget build(BuildContext context) {
    final up = context.watch<UserProvider>();
    final u = up.current;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('用户画像')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 用户选择/切换 ──
          Text('我的用户', style: TextStyle(fontWeight: FontWeight.bold, color: scheme.onSurface.withAlpha(180))),
          const SizedBox(height: 8),
          if (up.users.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('还没有用户，点下方"添加用户"创建一个，画像数据完全本地保存',
                  style: TextStyle(fontSize: 13, color: scheme.onSurface.withAlpha(120))),
            )
          else
            ...up.users.map((usr) => Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: scheme.primaryContainer,
                  child: Text(usr.nickname.isEmpty ? '?' : usr.nickname.substring(0, 1),
                      style: TextStyle(fontSize: 14, color: scheme.onPrimaryContainer)),
                ),
                title: Text(usr.nickname, style: const TextStyle(fontSize: 14)),
                subtitle: Text(
                  usr.hasBazi ? '☯ 已提交八字' : '未填写八字',
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: up.current?.id == usr.id
                    ? Icon(Icons.check_circle, color: scheme.primary, size: 18)
                    : Icon(Icons.circle_outlined, color: scheme.outlineVariant, size: 18),
                onTap: () {
                  if (up.selectUser(usr.id)) {
                    setState(() {});
                  }
                },
              ),
            )),
          const SizedBox(height: 8),
          // 添加用户
          FilledButton.icon(
            onPressed: () => _addUserDialog(up),
            icon: const Icon(Icons.person_add),
            label: const Text('添加用户'),
          ),
          const SizedBox(height: 20),

          if (u != null) ...[
            _sectionTitle(scheme, '☯️ 八字画像'),
            Card(
              child: Column(children: [
                SwitchListTile(
                  dense: true,
                  title: const Text('提交八字并生成画像', style: TextStyle(fontSize: 13)),
                  value: u.hasBazi,
                  onChanged: (v) => _onToggleBazi(up, u, v),
                  secondary: const Icon(Icons.face, size: 18),
                ),
                if (u.hasBazi) ...[
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.cake, size: 18),
                    title: Text(
                      u.birth != null
                          ? '${u.birth!.year}年${u.birth!.month}月${u.birth!.day}日 ${u.isMale ? "男" : "女"}'
                          : '设置出生信息',
                      style: const TextStyle(fontSize: 13),
                    ),
                    trailing: const Icon(Icons.edit, size: 16),
                    onTap: () => _birthDialog(up, u),
                  ),
                  if (u.baziSummary.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: scheme.primary.withAlpha(12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(u.baziSummary,
                            style: const TextStyle(fontSize: 12, height: 1.5)),
                      ),
                    ),
                ],
              ]),
            ),
            const SizedBox(height: 20),

            _sectionTitle(scheme, '📝 画像备注（AI 参考）'),
            Card(
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.edit_note, size: 18),
                title: const Text('填写性格/近况/关注点', style: TextStyle(fontSize: 13)),
                subtitle: Text(u.notes.isEmpty ? '未填写' : u.notes,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: scheme.onSurface.withAlpha(120))),
                onTap: () => _notesDialog(up, u),
              ),
            ),
            const SizedBox(height: 20),

            _sectionTitle(scheme, '🤖 AI 解卦参考'),
            Card(
              child: SwitchListTile(
                dense: true,
                value: u.aiReferenceEnabled,
                title: const Text('解卦时参考我的画像', style: TextStyle(fontSize: 13)),
                subtitle: const Text('AI 会结合日主五行/备注信息分析',
                    style: TextStyle(fontSize: 11)),
                onChanged: (v) {
                  up.updateUser(u.copyWith(aiReferenceEnabled: v));
                },
              ),
            ),
            const SizedBox(height: 20),

            // 删除用户
            Center(
              child: TextButton.icon(
                onPressed: () => _deleteUserDialog(up, u),
                icon: Icon(Icons.delete_outline, size: 16, color: Colors.red.shade300),
                label: Text('删除用户 ${u.nickname}',
                    style: TextStyle(fontSize: 13, color: Colors.red.shade300)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(ColorScheme scheme, String s) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(s,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: scheme.primary)),
      );

  // ── 添加用户 ──
  void _addUserDialog(UserProvider up) {
    final name = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加用户'),
        content: TextField(controller: name,
            decoration: const InputDecoration(labelText: '昵称', isDense: true)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isEmpty) return;
              up.addUser(name.text.trim());
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  // ── 八字提交开关 ──
  void _onToggleBazi(UserProvider up, UserProfile u, bool v) {
    if (v) {
      _birthDialog(up, u);
    } else {
      up.updateUser(u.copyWith(hasBazi: false, baziSummary: '', birth: null));
    }
  }

  // ── 出生信息（选择日期 → 计算画像） ──
  Future<void> _birthDialog(UserProvider up, UserProfile u) async {
    // 使用与八字排盘页同款的日历选择器
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (_) => const CalendarPickerDialog(),
    );
    if (picked == null || !mounted) return;
    bool male = u.isMale;
    int hour = u.hourIndex ?? 6;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('${picked.year}年${picked.month}月${picked.day}日'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              const Text('性别：', style: TextStyle(fontSize: 13)),
              ChoiceChip(
                label: const Text('男', style: TextStyle(fontSize: 12)),
                selected: male,
                onSelected: (_) => setS(() => male = true),
              ),
              const SizedBox(width: 6),
              ChoiceChip(
                label: const Text('女', style: TextStyle(fontSize: 12)),
                selected: !male,
                onSelected: (_) => setS(() => male = false),
              ),
            ]),
            const SizedBox(height: 8),
            const Text('时辰：', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: List.generate(12, (i) {
                const hours = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
                const ranges = ['23-01', '01-03', '03-05', '05-07', '07-09', '09-11',
                                '11-13', '13-15', '15-17', '17-19', '19-21', '21-23'];
                final sel = hour == i;
                return ChoiceChip(
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(hours[i], style: TextStyle(fontSize: 11, color: sel ? Colors.white : null)),
                      Text(ranges[i], style: TextStyle(fontSize: 8, color: sel ? Colors.white70 : Colors.grey)),
                    ],
                  ),
                  selected: sel,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  onSelected: (_) => setS(() => hour = i),
                );
              }),
            ),
            const SizedBox(height: 12),
            const Text('提交后自动计算五行画像',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                final birth = DateTime(picked.year, picked.month, picked.day,
                    hour * 2, 0);
                up.updateBaziFromBirth(
                    birth: birth, isMale: male, hourIndex: hour, submit: true);
                setState(() {});
              },
              child: const Text('提交'),
            ),
          ],
        ),
      ),
    );
  }

  // ── 画像备注 ──
  void _notesDialog(UserProvider up, UserProfile u) {
    final ctl = TextEditingController(text: u.notes);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('画像备注'),
        content: TextField(
          controller: ctl,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: '例如：性格偏内向，近期关注事业和感情，属猪…',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              up.updateUser(u.copyWith(notes: ctl.text.trim()));
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  // ── 删除用户 ──
  void _deleteUserDialog(UserProvider up, UserProfile u) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('删除用户 ${u.nickname}？'),
        content: const Text('将永久删除该用户的画像数据（本地），此操作不可恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade300),
            onPressed: () {
              up.removeUser(u.id);
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}