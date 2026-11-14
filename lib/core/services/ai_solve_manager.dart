/// AI 解卦后台执行器
///
/// 目的：解卦请求不再绑定在「卦例详情弹窗」的生命周期上——
/// 用户关掉弹窗、切到别的 Tab 或让 App 进后台，请求继续跑，完成后把
/// 回复写回该卦例；卦例列表与详情页据此显示「解卦中」标识。
///
/// 设计要点：
/// - 单例 [AiSolveManager.instance]，按 caseId 维护运行中的任务
/// - 流式输出 + 超时重试（最多 [maxRetry] 次）+ 非流式回退（与原 UI 逻辑一致）
/// - 累积正式答案（content）与推理过程（reasoning，仅展示不落盘正文）
/// - 结束后统一 `CaseProvider.updateAiMessages` 落盘（即使 UI 已销毁）
/// - UI 通过 `addListener` 渲染 job 的实时内容
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/ai_service.dart';
import '../utils/logger.dart';
import '../../features/cases/models/case_models.dart';
import '../../features/cases/providers/case_provider.dart';

/// 单个解卦任务的状态
class AiSolveJob {
  final int caseId;

  /// 日志标签（AI解卦 / AI追问）
  final String logTag;

  /// 是否仍在进行
  bool running;

  /// 已累积的正式答案（不含推理过程）
  String content;

  /// 已累积的推理过程（DeepSeek 思考，仅展示）
  String thinking;

  /// 重试提示（如「连接中断，自动重试中…（第 2 次）」）
  String retryNote;

  /// 错误信息（失败时）
  String? error;

  /// 开始时间
  final DateTime startedAt;

  AiSolveJob({
    required this.caseId,
    required this.logTag,
    this.running = true,
    this.content = '',
    this.thinking = '',
    this.retryNote = '',
    this.error,
    DateTime? startedAt,
  }) : startedAt = startedAt ?? DateTime.now();
}

/// 后台解卦管理器
class AiSolveManager extends ChangeNotifier {
  AiSolveManager._();
  static final AiSolveManager instance = AiSolveManager._();

  /// 最多重试次数（后台运行时限次，避免用户离开后无限重试烧额度）
  static const int maxRetry = 6;
  static const int retryIntervalMs = 500;
  static const Duration streamTimeout = Duration(seconds: 180);

  final Map<int, AiSolveJob> _jobs = {};
  final Map<int, StreamSubscription<AiStreamPiece>> _subs = {};
  final Map<int, bool> _cancelRequested = {};
  CaseProvider? _cases;

  /// 由 main 启动时注入，用于落盘
  void attachCases(CaseProvider provider) => _cases = provider;

  bool isSolving(int? caseId) =>
      caseId != null && (_jobs[caseId]?.running ?? false);

  AiSolveJob? jobOf(int? caseId) => caseId == null ? null : _jobs[caseId];

  /// 正在解卦的卦例 id 集合（列表页标记用）
  Set<int> get solvingIds =>
      _jobs.entries.where((e) => e.value.running).map((e) => e.key).toSet();

  /// 启动解卦（后台可运行）
  ///
  /// [messages] 完整请求上下文（含 system）；[userContent] 若提供会先写入
  /// 卦例（以便弹窗关闭后也能看到用户问了什么）。
  Future<void> start({
    required int caseId,
    required List<Map<String, String>> messages,
    required String logTag,
    required String endpoint,
    required String apiKey,
    required String model,
    bool retryOn429 = true,
  }) async {
    if (isSolving(caseId)) {
      Logger.instance.warn('AI解卦', '该卦例已有解卦任务在跑，忽略重复启动（id=$caseId）');
      return;
    }
    final job = AiSolveJob(caseId: caseId, logTag: logTag);
    _jobs[caseId] = job;
    _cancelRequested[caseId] = false;
    notifyListeners();

    await _run(
      job: job,
      messages: messages,
      endpoint: endpoint,
      apiKey: apiKey,
      model: model,
      retryOn429: retryOn429,
    );
  }

  /// 用户停止
  void cancel(int caseId) {
    if (!(_jobs[caseId]?.running ?? false)) return;
    _cancelRequested[caseId] = true;
    _subs.remove(caseId)?.cancel();
    final job = _jobs[caseId];
    if (job != null) {
      job.running = false;
      job.retryNote = '已停止';
    }
    Logger.instance.info('AI解卦', '用户停止（后台任务，id=$caseId）');
    notifyListeners();
  }

  Future<void> _run({
    required AiSolveJob job,
    required List<Map<String, String>> messages,
    required String endpoint,
    required String apiKey,
    required String model,
    required bool retryOn429,
  }) async {
    var attempt = 0;
    while (attempt <= maxRetry) {
      if (_cancelRequested[job.caseId] == true) {
        _finish(job, cancelled: true);
        return;
      }
      attempt++;
      final done = await _streamOnce(
        job: job,
        messages: messages,
        endpoint: endpoint,
        apiKey: apiKey,
        model: model,
        retryOn429: retryOn429,
      );
      if (done) {
        _finish(job);
        return;
      }
      if (_cancelRequested[job.caseId] == true) {
        _finish(job, cancelled: true);
        return;
      }
      if (attempt > maxRetry) break;
      // 流式失败：重试
      job.retryNote = '连接中断，自动重试中…（第 $attempt 次）';
      notifyListeners();
      await Future<void>.delayed(const Duration(milliseconds: retryIntervalMs));
    }

    // 流式始终失败 → 回退非流式
    job.retryNote = '转为非流式请求…';
    notifyListeners();
    final ok = await _fallbackNonStreaming(
      job: job,
      messages: messages,
      endpoint: endpoint,
      apiKey: apiKey,
      model: model,
    );
    if (_cancelRequested[job.caseId] == true) {
      _finish(job, cancelled: true);
      return;
    }
    _finish(job, error: ok ? null : (job.error ?? 'AI 请求失败'));
  }

  /// 单次流式请求；返回 true 表示获得正式答案
  Future<bool> _streamOnce({
    required AiSolveJob job,
    required List<Map<String, String>> messages,
    required String endpoint,
    required String apiKey,
    required String model,
    required bool retryOn429,
  }) async {
    final completer = Completer<bool>();
    var gotContent = false;
    final stream = AiService()
        .chatStream(
          endpoint: endpoint,
          apiKey: apiKey,
          model: model,
          messages: messages,
          logTag: job.logTag,
        )
        .timeout(
          streamTimeout,
          onTimeout: (sink) =>
              sink.addError(AiStreamException('流式超时（180 秒无数据）')),
        );
    final sub = stream.listen(
      (piece) {
        if (_cancelRequested[job.caseId] == true) return;
        if (piece.isReasoning) {
          job.thinking += piece.text;
        } else {
          job.content += piece.text;
          gotContent = true;
        }
        notifyListeners();
      },
      onError: (Object e) {
        if (completer.isCompleted) return;
        job.error = e is AiStreamException ? e.message : '$e';
        final is429 = e is AiStreamException && e.statusCode == 429;
        if (is429 && !retryOn429) {
          completer.complete(false);
        } else {
          completer.complete(false);
        }
      },
      onDone: () {
        if (completer.isCompleted) return;
        completer.complete(gotContent);
      },
      cancelOnError: true,
    );
    _subs[job.caseId] = sub;

    final ok = await completer.future;
    // 取消订阅（防泄漏）
    final cur = _subs.remove(job.caseId);
    await cur?.cancel();
    if (!ok) {
      // 失败：清空本次残留增量，避免重试内容拼接
      job.content = '';
      job.thinking = '';
    }
    return ok;
  }

  /// 非流式回退（一次性返回）
  Future<bool> _fallbackNonStreaming({
    required AiSolveJob job,
    required List<Map<String, String>> messages,
    required String endpoint,
    required String apiKey,
    required String model,
  }) async {
    try {
      final res = await AiService().chat(
        endpoint: endpoint,
        apiKey: apiKey,
        model: model,
        messages: messages,
        logTag: job.logTag,
      );
      if (_cancelRequested[job.caseId] == true) return false;
      if (res.success) {
        job.content = res.content;
        notifyListeners();
        return true;
      }
      job.error = res.errorMessage;
      return false;
    } catch (e) {
      job.error = '$e';
      return false;
    }
  }

  /// 结束任务：落盘 + 通知
  void _finish(AiSolveJob job, {bool cancelled = false, String? error}) {
    job.running = false;
    job.error = error ?? job.error;
    _subs.remove(job.caseId)?.cancel();
    if (!cancelled && job.content.trim().isNotEmpty) {
      _persist(job);
    }
    Logger.instance.info('AI解卦',
        '后台任务结束（id=${job.caseId} · $job.logTag · 取消=$cancelled · 长度=${job.content.length}）');
    notifyListeners();
  }

  /// 把回复写回卦例（UI 已销毁也照常执行）
  void _persist(AiSolveJob job) {
    final cases = _cases;
    if (cases == null) {
      Logger.instance.error('AI解卦', 'CaseProvider 未注入，结果无法落盘');
      return;
    }
    final target = cases.allCases.where((c) => c.id == job.caseId);
    if (target.isEmpty) return;
    final c = target.first;
    final msgs = List<AiMessage>.from(c.aiMessages)
      ..add(AiMessage(role: 'assistant', content: job.content));
    cases.updateAiMessages(job.caseId, msgs);
  }

  /// 清理已结束的任务记录（列表标记用）
  void clearFinished(int caseId) {
    final job = _jobs[caseId];
    if (job != null && !job.running) {
      _jobs.remove(caseId);
      notifyListeners();
    }
  }
}
