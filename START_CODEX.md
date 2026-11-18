# 发给 Codex 的启动指令

在解压后的 Alice-Start 项目根目录开启 Codex 会话，发送下面这一段。

> 按本仓库 AGENTS.md、README.md 和 docs/PLAN.md 开始正式开发。先执行 python3 tools/validate_devpack.py 和 python3 tools/preflight.py，核查 docs/ENVIRONMENT.md，建立独立 Git 基线并创建 apps/mobile Flutter 工程。沿用已确认的 C 版银杏家园及三宠六阶段，结构与素材见 docs/DESIGN_SPEC.md。先做一条可装机的离线闭环：建家选宠、家长自定义小事、孩子申报、家长确认、积分入账、重启恢复。截图对照 Demo，验证预览零入账。继续按计划完成正式扣分与纠错、成果兑换、场景布置、加密备份及双端迁移。每个阶段保存可运行版本和证据；自行测试、修复，检查通过后直接继续。我负责最终成品验收。默认在云电脑工作；进入我个人 Mac 或需要我的 Apple 账号、付费及实际设备操作时说明需要什么，同时推进其余工作。最终提供可安装的双端版本、备份迁移说明、源码和可核验的测试结果。

已有 Git 仓库时直接检查当前分支和工作区；空目录的本地基线可由 Codex 建立。源码交接用私有仓库或可校验的本地提交，不把家庭数据库、真实备份和签名密钥提交到 Git。
