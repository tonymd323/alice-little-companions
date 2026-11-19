import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../application/family.dart';
import '../domain/pin.dart';
import '../domain/wind_progress.dart';
import '../illustration/wind_sound.dart';
import '../illustration/wind_stage.dart';
import 'garden.dart';

class WindChapter extends StatefulWidget {
  const WindChapter({
    super.key,
    required this.service,
    required this.initial,
    required this.initialMuted,
    required this.hasNotebook,
    required this.openNotebook,
  });

  final FamilyService service;
  final WindProgress initial;
  final bool initialMuted;
  final bool hasNotebook;
  final Future<void> Function(bool resume) openNotebook;

  @override
  State<WindChapter> createState() => _WindChapterState();
}

enum _ChapterOption { captions, notebook, challenge }

class _WindChapterState extends State<WindChapter> with WidgetsBindingObserver {
  late WindProgress progress = widget.initial;
  late WindPhase phase = progress.complete
      ? WindPhase.complete
      : progress.started
      ? WindPhase.playing
      : WindPhase.opening;
  late bool muted = widget.initialMuted;
  bool captions = true, holding = false, busy = false;
  String? line;
  String? problem;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(WindSound.prepare());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) unawaited(WindSound.stop());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(WindSound.stop());
    super.dispose();
  }

  void cue(String name) {
    final sound = WindCue.values.byName(name);
    if (!muted) unawaited(WindSound.play(sound));
    if (phase == WindPhase.opening && sound == WindCue.basket) {
      setState(() => line = '帮我扶住篮子！我们得把桥上的光接回来。');
    }
  }

  void failed(Object error) {
    if (!mounted) return;
    setState(() {
      problem = error is UserError ? error.message : '这次没能存好，再试一次。';
    });
  }

  Future<void> begin() async {
    if (busy || phase != WindPhase.opening) return;
    setState(() => busy = true);
    try {
      final state = await widget.service.beginWindStory();
      if (!mounted) return;
      setState(() {
        progress = state;
        phase = state.complete ? WindPhase.complete : WindPhase.playing;
        line = problem = null;
      });
    } catch (error) {
      failed(error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void takeLeaf() {
    if (phase != WindPhase.playing || busy) return;
    if (!holding) cue('takeLeaf');
    setState(() {
      holding = true;
      problem = null;
      line = '手里有一片了。看看哪一格还透着风？';
    });
  }

  Future<void> place(int pane) async {
    if (phase != WindPhase.playing || busy) return;
    final slot = pane - 7;
    if (slot < 0 || slot >= 5 || progress.hasLeaf(slot) || !holding) {
      setState(() {
        line = !holding ? '先点我的叶篮，拿一片金叶。' : '这一格已经嵌好了，试试旁边透亮的空格。';
      });
      return;
    }
    setState(() => busy = true);
    try {
      final before = progress;
      final state = await widget.service.placeWindLeaf(slot, run: before.run);
      if (!mounted) return;
      final middle = !before.middleLit && state.middleLit;
      final far = !before.farLit && state.farLit;
      setState(() {
        progress = state;
        holding = false;
        problem = null;
        if (state.complete) {
          phase = WindPhase.reunion;
          line = null;
        } else if (far && !state.middleLit) {
          line = '奶油看到那头的光了！脚下这段还暗着，它在等我们。';
        } else if (middle) {
          line = '看，它走到下一段桥了。再从篮里拿一片吧。';
        } else {
          line = '刚好嵌进去了。篮里还有 ${state.remaining} 片。';
        }
      });
      cue('seatLeaf');
      if (middle || far) cue('windowLight');
    } catch (error) {
      failed(error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> replay() async {
    if (busy || phase != WindPhase.complete) return;
    setState(() => busy = true);
    try {
      final next = await widget.service.replayWindStory(run: progress.run);
      if (!mounted) return;
      setState(() {
        progress = next;
        phase = WindPhase.opening;
        holding = false;
        line = problem = null;
      });
    } catch (error) {
      failed(error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void finishReunion() {
    if (mounted && phase == WindPhase.reunion) {
      setState(() => phase = WindPhase.complete);
    }
  }

  Future<void> option(_ChapterOption value) async {
    if (value == _ChapterOption.captions) {
      setState(() => captions = !captions);
      return;
    }
    await WindSound.stop();
    if (!mounted) return;
    await widget.openNotebook(value == _ChapterOption.notebook);
  }

  String get words =>
      line ??
      switch (phase) {
        WindPhase.opening => '听……风把叶片吹走了。奶油还在桥那头！',
        WindPhase.playing =>
          progress.mask == 0
              ? '每扇窗要四片。点我的叶篮，再点窗上的空格吧。'
              : '我们接着修吧。篮里还剩 ${progress.remaining} 片。',
        WindPhase.reunion => '路通了！听，是奶油的脚步。',
        WindPhase.complete => '你们把光接到家门口了，我一路都看得清！',
      };

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFBF4E7),
    appBar: AppBar(
      leading: IconButton(
        tooltip: '回到小家',
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('风过暖廊'),
      titleTextStyle: const TextStyle(
        fontFamily: 'serif',
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      actions: [
        IconButton(
          tooltip: muted ? '开启声音' : '静音',
          icon: Icon(
            muted ? Icons.volume_off_outlined : Icons.volume_up_outlined,
          ),
          onPressed: () {
            setState(() => muted = !muted);
            unawaited(WindSound.setMuted(muted));
          },
        ),
        PopupMenuButton<_ChapterOption>(
          tooltip: '章节选项',
          onSelected: option,
          itemBuilder: (_) => [
            PopupMenuItem(
              value: _ChapterOption.captions,
              child: Text(captions ? '收起对白' : '显示对白'),
            ),
            if (widget.hasNotebook)
              const PopupMenuItem(
                value: _ChapterOption.notebook,
                child: Text('继续原来的数学书签'),
              ),
            if (phase == WindPhase.complete)
              const PopupMenuItem(
                value: _ChapterOption.challenge,
                child: Text('章后挑战 · 十九片叶子'),
              ),
          ],
        ),
      ],
    ),
    body: SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, box) {
          final stage = WindStage(
            phase: phase,
            mask: progress.mask,
            holding: holding,
            onBasket: takeLeaf,
            onPane: place,
            onOpeningDone: begin,
            onReunionDone: finishReunion,
            onCue: cue,
          );
          final footer = Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (captions || problem != null) ...[
                  if (captions)
                    Text(
                      phase == WindPhase.complete ? '奶油' : '桃桃',
                      style: const TextStyle(
                        color: terracotta,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  const SizedBox(height: 3),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      problem ?? words,
                      style: const TextStyle(
                        fontSize: 17,
                        height: 1.35,
                        color: ink,
                      ),
                    ),
                  ),
                ],
                if (phase == WindPhase.opening || phase == WindPhase.reunion)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: busy
                          ? null
                          : phase == WindPhase.opening
                          ? begin
                          : finishReunion,
                      child: Text(
                        phase == WindPhase.opening ? '直接去窗边' : '看团聚结果',
                      ),
                    ),
                  ),
                if (phase == WindPhase.complete) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('回暖廊看窗光'),
                      ),
                      TextButton(
                        onPressed: busy ? null : replay,
                        child: const Text('再演一次'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
          if (box.maxWidth > box.maxHeight * 1.25) {
            return Row(
              children: [
                Expanded(flex: 3, child: stage),
                Flexible(flex: 2, child: SingleChildScrollView(child: footer)),
              ],
            );
          }
          // Keep the painted sockets under the same fingers while dialogue
          // wraps, captions are hidden, or the reunion controls appear.
          final stageHeight = (box.maxWidth * 4 / 3).clamp(
            0.0,
            box.maxHeight * .76,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: stageHeight, child: stage),
              Expanded(child: SingleChildScrollView(child: footer)),
            ],
          );
        },
      ),
    ),
  );
}
