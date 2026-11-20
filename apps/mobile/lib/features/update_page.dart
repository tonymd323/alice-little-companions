import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../application/app_update.dart';
import '../application/controller.dart';
import '../domain/pin.dart';
import 'common.dart';
import 'garden.dart';
import 'parent_access.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key, required this.controller});

  final FamilyController controller;

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  static const _tokenKey = 'alice.github-updates-token';
  static const _installer = AndroidInstaller();
  final _github = GitHubUpdates();
  final _token = TextEditingController();

  String? _version, _status, _working;
  bool _hasToken = false, _editingToken = false;
  double? _progress;
  AndroidRelease? _release;
  File? _downloaded;

  FamilyController get controller => widget.controller;
  bool get _busy => _working != null;

  @override
  void initState() {
    super.initState();
    unawaited(
      _run('正在读取版本…', () async {
        final current = await _installer.installed();
        final configured =
            (await controller.device.secure.read(_tokenKey)) != null;
        if (mounted) {
          setState(() {
            _version = current.name;
            _hasToken = configured;
          });
        }
      }),
    );
  }

  @override
  void dispose() {
    _github.cancel();
    _token.dispose();
    super.dispose();
  }

  Future<void> _run(String label, Future<void> Function() action) async {
    if (!controller.parentUnlocked || _busy) return;
    setState(() {
      _working = label;
      _status = null;
    });
    try {
      await action();
    } on UserError catch (error) {
      if (mounted) setState(() => _status = error.message);
    } on PlatformException catch (error) {
      if (mounted) setState(() => _status = error.message ?? '暂时无法完成更新操作。');
    } catch (_) {
      if (mounted) setState(() => _status = '暂时无法完成更新操作，请重试。');
    } finally {
      if (mounted) setState(() => _working = null);
    }
  }

  Future<String> _credential() async {
    final token = await controller.device.secure.read(_tokenKey);
    if (token == null || token.isEmpty) {
      throw const UserError('请先设置 GitHub 仓库的只读令牌。');
    }
    return token;
  }

  Future<void> _storeToken({bool remove = false}) => _run('正在保存…', () async {
    final secure = controller.device.secure;
    if (remove) {
      await secure.delete(_tokenKey);
    } else {
      await secure.write(_tokenKey, GitHubUpdates.tokenValue(_token.text));
    }
    if (!mounted) return;
    _token.clear();
    setState(() {
      _hasToken = !remove;
      _editingToken = false;
      _release = null;
      _downloaded = null;
    });
  });

  Future<void> _check() async {
    if (!_hasToken) {
      setState(() => _editingToken = true);
      return;
    }
    await _run('正在检查更新…', () async {
      setState(() {
        _release = null;
        _downloaded = null;
      });
      final current = await _installer.installed();
      final latest = await _github.check(current.code, await _credential());
      if (mounted) {
        setState(() {
          _version = current.name;
          _release = latest;
          if (latest == null) _status = '已是最新版本。';
        });
      }
    });
  }

  Future<void> _download(AndroidRelease release) => _run('正在下载更新…', () async {
    _progress = 0;
    final file = await _github.download(
      release,
      await _installer.cache(),
      await _credential(),
      onProgress: (received, total) {
        final next = (100 * received ~/ total) / 100;
        if (mounted && next != _progress) setState(() => _progress = next);
      },
    );
    if (!mounted) return;
    setState(() => _downloaded = file);
    if (controller.parentUnlocked) await _openInstaller(release, file);
  });

  Future<void> _openInstaller(AndroidRelease release, File file) async {
    final result = await _installer.install(file, release.versionCode);
    if (!mounted) return;
    setState(
      () => _status = result == InstallHandoff.permission
          ? '允许此应用安装更新后，回到这里点「安装更新」。'
          : '请在系统安装界面确认更新。',
    );
  }

  @override
  Widget build(BuildContext context) {
    final release = _release;
    final downloaded = _downloaded;
    return ParentFrame(
      controller: controller,
      title: '应用更新',
      child: PageBody(
        maxWidth: 520,
        child: GardenCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_version case final String version) Text('当前版本 $version'),
              if (release != null) Text('可更新到 ${release.version}'),
              if (_status case final String status)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Semantics(liveRegion: true, child: Text(status)),
                ),
              const SizedBox(height: 12),
              if (_working case final String working) ...[
                Text(working),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: working == '正在下载更新…' ? _progress : null,
                ),
                if (working == '正在下载更新…')
                  TextButton(
                    onPressed: _github.cancel,
                    child: const Text('取消下载'),
                  ),
              ] else if (release != null && downloaded != null)
                ActionButton(
                  label: '安装更新',
                  action: () => _run(
                    '正在打开安装界面…',
                    () => _openInstaller(release, downloaded),
                  ),
                )
              else if (release != null)
                ActionButton(label: '下载并安装', action: () => _download(release))
              else
                ActionButton(label: '检查更新', action: _check),
              if (_editingToken && !_busy) ...[
                const SizedBox(height: 12),
                const Text('令牌需能读取此私有仓库，保存在本机。'),
                FormFieldLabel(
                  label: 'GitHub 只读令牌',
                  controller: _token,
                  secret: true,
                ),
                ActionButton(
                  label: '保存令牌',
                  action: _storeToken,
                  outlined: true,
                ),
              ],
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  if (!_editingToken)
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() => _editingToken = true),
                      child: Text(_hasToken ? '更换令牌' : '设置只读令牌'),
                    ),
                  if (_hasToken)
                    TextButton(
                      onPressed: _busy ? null : () => _storeToken(remove: true),
                      child: const Text('移除令牌'),
                    ),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => _run('正在打开 GitHub…', _installer.openDownloads),
                    child: const Text('在浏览器下载'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
