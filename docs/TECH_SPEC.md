# 技术与交付方案

开工基线 v1.1 · 2026-11-18。采用 Flutter 与本地 SQLite，实现完整离线、本地加密备份和跨平台迁移。工具链、设备和签名能力在 M0 实测。

家庭版 0.14.1 之后的角色、场景和剧情接入以本文的[小家动画与主线接入](#小家动画与主线接入)为准。下文保留原生工程和存档的设计依据。

## 1. 选型

| 层 | 选择 | 作用 |
|---|---|---|
| 应用 | Flutter稳定通道，Dart | 一份应用覆盖iOS/iPadOS与Android，支持设备文件操作 |
| 界面组织 | View / ViewModel / Application Service / Repository | UI不直接写数据库，规则可在无界面测试中验证 |
| 状态 | Flutter内置ChangeNotifier/ValueNotifier及数据库观察流 | 首版不引入复杂状态框架 |
| 数据库 | Drift + sqlite3，NativeDatabase后台isolate | 本地事务、结构化迁移，避免阻塞UI |
| 文件 | path_provider + 维护中的系统文件选择/保存插件 | App私有文件与用户明确导出的外部文件分开 |
| 加密 | cryptography + cryptography_flutter | 标准AES-GCM、PBKDF2与SHA-256，具体格式见BACKUP_FORMAT |
| 设备凭据 | flutter_secure_storage或同等平台Keychain/Keystore封装 | 存PIN校验材料、恢复密钥摘要、内部恢复点密钥；不进入迁移包 |
| 资源 | 本地WebP/PNG、简单SVG、原生Flutter文字与布局 | 所有正式素材随安装包携带，首次断网也能显示 |
| 测试 | flutter_test、integration_test、真实SQLite临时库 | 业务、事务、恢复、界面与实际设备流程 |

不建设FastAPI/PostgreSQL/云登录；不引入MQTT、微服务、实时协作或游戏服务器。SQLite是当前设备的权威数据，不是云端缓存。

M0核对维护中的依赖版本与平台要求，锁定Flutter/Dart及pubspec.lock，在docs/ENVIRONMENT.md记录实际版本。文档没有声称任何工具已安装。先按iOS/iPadOS16+、Android8+规划，实际用户设备信息优先；若插件提高门槛，先更换兼容依赖或提出明确冲突。

## 2. 计划目录

| 路径 | 内容 |
|---|---|
| apps/mobile/lib/features/ | 家庭、任务、积分、目录、宠物、空间、记录、备份界面 |
| apps/mobile/lib/domain/ | 不依赖Flutter控件的规则、值对象与权限检查 |
| apps/mobile/lib/application/ | 可测试的写命令、事务、备份恢复编排 |
| apps/mobile/lib/data/ | Drift表、迁移、仓储、设备凭据适配 |
| apps/mobile/assets/ | 正式离线素材，带版本清单 |
| apps/mobile/test/ | 规则、仓储、命令、widget与迁移测试 |
| apps/mobile/integration_test/ | 设备完整流程、离线和文件导入导出 |
| config/ | 本包提供的规则、商品配置，构建时校验并打包 |
| design/ | token、素材清单、方向参考，不是运行时代码 |
| docs/evidence/ | 实测日志、截图、录屏索引，禁止真实秘密 |

以上应用目录由Codex在M0创建；本包包含开工文档、配置、验证材料和 Demo 美术候选资源，不能把计划中的命令当成已执行结果。

## 3. 数据模型

业务记录和物品实例使用稳定 UUID；伙伴、商品、空间种类和素材使用目录中定义的稳定字符串 ID；金额为整数积分，时间为UTC毫秒并保存必要家庭日期。所有关联启用外键。每个数据代包含一份家庭；仍保存family_id便于校验身份。

| 表 | 关键字段与约束 |
|---|---|
| households | id、child_id、display_name、timezone、lineage_id、rules_version、catalog_version、domain_revision；当前代仅一行 |
| child_profiles | id、household_id、nickname、active_pet_id（fox/rabbit/cat） |
| task_templates | id、family_id、mode、current_version、paused；历史版本不覆盖 |
| task_versions | id、template_id、version、title、content、criteria、task_type、reward、schedule_json；唯一(template_id,version) |
| project_stages | id、task_version_id、sequence、title、criteria、type、reward；唯一(version,sequence) |
| task_instances | id、template_id、version_id、project_instance_id可空、stage_id可空、period_key、slot、due_at、state、actual_date、approved_at；唯一instance_key按R-04生成，不用可变模板版本区分相同计划槽位 |
| submissions | id、instance_id、note、created_at；保留退回与重交历史 |
| completions | id、instance_id唯一、actual_date、feedback、is_valid、approval_command_id |
| accounts | id、child_id唯一、balance整数且CHECK(balance>=0)、revision |
| ledger_entries | id、account_id、delta、kind、source_key、reversal_of可空、actual_date、posted_day、created_at；source_key唯一，reversal_of非空时唯一 |
| penalty_rules / penalty_events | 规则快照、事件UUID、planned_delta、actual_delta、posted_day、description；事件UUID唯一 |
| penalty_day_usage | account_id、posted_day、used；唯一(account_id,posted_day)，用于实扣日上限 |
| purchases | id、catalog_item_id、price_paid、created_at、refunded_at、command_id唯一 |
| entitlements | id、purchase_id可空、catalog_item_id、asset_id、status、metadata_snapshot；活跃拥有关系唯一 |
| spaces / placements | 空间实例UUID、scene_id（含免费 base_room）、name、layout_version；物品实例ID、归一化x/y、rotation、flipped、z、使用挂点时的mount_id；同一活跃物品最多一个摆放位置 |
| pet_state / growth_awards | pet_state以(child_id,pet_id)保存各自已穿戴槽位和可选宠物昵称；growth_awards唯一(child_id,threshold)，三只伙伴共享家庭孩子阶段 |
| wishes | child_id唯一、catalog_item_id、selected_price、selected_at |
| processed_commands | command_id唯一、payload_hash、result_json、created_at；幂等回放 |
| correction_records | 原记录、应收回、实收回、家长接受差额、说明 |
| local_events | 本地审计/导入导出记录；不包含口令/PIN明文 |

设备ID、家长会话、PIN校验材料、恢复密钥摘要、迁移冻结标记及内部备份密钥在设备凭据/控制层，不能随家庭数据库复制到新设备。

SQLite设置：foreign_keys=ON、WAL、synchronous=FULL。使用一个数据库后台isolate与序列化写命令；Drift事务内执行全部相关修改，不自行嵌套冲突的BEGIN语句。每次成功领域写入增加households.domain_revision，备份snapshot_revision使用该值；只读操作不增加。所有数据库升级必须有schema导出和旧版fixture迁移测试。

## 4. 领域命令契约

不是HTTP接口。每个写命令有command_id、family_id、role_session和预期版本（涉及编辑时）；先校验角色与迁移冻结状态，再进入事务。相同ID不同payload拒绝，相同ID同payload返回已保存结果。

| 命令 | 输入重点 | 原子结果 |
|---|---|---|
| PublishTask | 家长内容、类型、执行方式、标准 | 写模板版本与计划实例 |
| SubmitTask | instance_id、可选备注 | 写申报并进入SUBMITTED，无积分 |
| ApproveTask | instance_id、actual_date、feedback | 状态+完成+奖励+余额+成长一次完成 |
| ReturnTask / ReopenTask | instance_id、说明 | 退回继续或原实例重开，无新增奖励 |
| BackfillTask | 内容、标准、类型、actual_date | 建立可追溯补录与确认，不支持无来源赠分 |
| ApplyPenalty / ReversePenalty | 规则/事件ID、事实；原扣分ID | 实扣或原实扣冲回，日额度一致 |
| PurchaseItem / RefundPurchase | item_id；purchase_id | 余额、流水、购买、所有权/容器摆放一致 |
| SelectCompanion | 免费伙伴ID、expected_version | 写入child_profiles.active_pet_id；保留所有搭配、账本和已授予阶段；预览只持有界面状态 |
| SaveOutfit / SaveLayout | 槽位/完整布局、expected_version | 校验所有权和坐标后保存新版本 |
| CorrectAward | 原奖励、处理方式、明确差额接受 | 记录更正、实际回收、任务CORRECTED |
| ExportBackup / ImportBackup | 方式、系统文件目标、口令、覆盖确认 | 文件编排按BACKUP_FORMAT，不把导入当作发奖 |

购买事务示例：验证活跃角色与非迁移冻结→查processed_commands→读余额与商品固定价→检查已拥有→扣余额→写负流水→写购买与所有权→保存命令结果→提交。双击、崩溃重试都不能透支或重复发货。

恢复替换与普通写事务不同：必须通过临时数据代、完整校验和原子切换，不在活动数据库上逐表覆盖。

## 5. 家长凭据

首次设置6位PIN；存随机salt与PBKDF2-HMAC-SHA256校验材料于平台安全存储，迭代参数采用config。普通家长会话最多10分钟，进入后台立即失效。

连续5次错误后等待60秒；后续失败增加等待，上限15分钟；不因重启清零次数。恢复密钥由安全随机数生成128位，展示为可抄写的编码，只保留摘要，不上传。恢复密钥成功使用后必须重新生成。

新设备从能解密且完整验证的备份恢复后，重新建立PIN和恢复密钥，不迁移旧Keychain/Keystore材料。PIN用于防止儿童误操作和常规越权，不声称能抵御被完全控制的操作系统。

## 6. 快照与恢复

正常写入全部走单个队列。导出时短暂暂停新的领域写入，完成在途事务，在非活动事务上下文对唯一临时路径执行VACUUM INTO，得到一致性SQLite快照；普通备份完成本地容器回读校验后恢复写入，迁移模式则继续冻结。

不能仅复制正在使用的.sqlite主文件而漏掉WAL。快照完成后检查integrity_check、foreign_key_check、余额与流水和、物品/布局关联以及必需规则版本，再按BACKUP_FORMAT打包加密。

数据目录使用generations/<generation_id>/database.sqlite和一个原子替换的active.json指针。导入写到新代，校验、迁移、建立新凭据后才切指针。保留原有效代和恢复日志；崩溃重启只能打开上一完整代或新完整代，不能混合两者。凭据先按新代ID持久化，指针切换后才启用；失败清理待用凭据。

内部恢复点独立使用设备随机密钥加密，保留最近5份，格式与外部口令备份明确区分。卸载后这些副本可能无法访问，不能当作可携带备份。

迁移控制状态需持久化为IDLE、EXPORTING、AWAITING_FILE_VERIFICATION、MIGRATION_PENDING。启动先读取该状态再开放写命令；进程退出不能解除迁移冻结。若系统可能已经保存文件但回执未知，保留只读并让家长回读验证或明确取消，不能把未知直接当作失败自动解除冻结。确定未导出成功才恢复原可写状态。

## 7. 离线、迁移与更新

无请求服务器的正常路径，不使用远程字体、远程图片、在线时钟、在线认证或必须联网的许可证检查。发布包内验证素材清单hash和路径存在。任务实例在App启动/日期变化时本地生成，不依赖后台调度服务。

首版默认不启用平台自动云备份：核查Android备份/数据提取规则和iOS私有业务文件排除备份设置，设备凭据不启用跨设备同步。用户主动选择系统文件提供方导出仍属于其明确操作。M0须按当前平台文档验证实际配置，不能只写界面文案。

备份包含目录与规则版本、已拥有条目的必要快照，目标安装包必须具有所有已引用素材。未来版本需兼容旧ID，不能删除仍可能被备份引用的资产。不可兼容时阻止导入并保留当前数据，不允许静默丢物品。

应用升级先建立内部恢复点，按版本迁移本地数据库，再核对所有积分与所有权。更新不能清空家庭或让初始种子数据再次发放。

## 8. 构建与实际安装

Android交付签名release APK供家庭安装；保留签名密钥以使后续更新保持同一应用身份。iOS/iPadOS构建需要Mac/Xcode及相应签名条件；家庭试装优先验证现有签名方式，再按实际使用周期选定可持续分发途径并记录维护要求。TestFlight可用于测试，但其构建有有效期，不能当作永久无需维护的分发。

不得假设用户已具有Apple开发者资格、Mac或签名证书。M0集中核查，未具备时记录阻塞；代码与安卓验证仍可继续。签名材料由用户在适当环境中配置，不放入文档、聊天或Git。签名有效期、更新步骤和安装所需操作必须写入最终使用说明。

计划的验证入口：flutter analyze、flutter test、flutter test integration_test -d <实际设备ID>、flutter build apk --release；iOS在macOS运行flutter build ipa --release并按已选分发方式导出。具体工作目录为apps/mobile；依赖代码生成与构建命令由M0按实际版本补齐，所有结果实际运行后才记录。

参考资料及版本核查日期见references/SOURCES.md。

## 小家动画与主线接入

**技术选型。** 沿用家庭版 Flutter、Dart 和 `CustomPainter`。团团和奶油的第一阶段用分层腿部补间维持接触，肩颈和尾巴随姿态运动。`GardenScene` 的点地、呼唤、自主走动共用接触计划。团团的横向、纵深周期为 132 和 90 原画像素，奶油为 144 和 96 像素，两者按各自朝向插值。Live2D/Cubism 保留为后续可选方案。[当前小家](../apps/mobile/lib/illustration/living_scene.dart) · [接触计划](../apps/mobile/lib/illustration/companion_walk.dart) · [团团实测](evidence/cat-walk/README.md)

### 原画与运行素材

| 交接物 | 工程需要的内容 |
|---|---|
| 幼猫分层原稿 | 以第一阶段团团的脸、毛色和比例定稿。使用同画布、同地平线的可编辑 ORA，身体、近远前后腿、尾、前景毛缘和衣饰有各自的遮挡顺序。画坐姿起身站稳、近后→近前→远后→远前的四拍循环，每拍有接触与经过两张关键姿，再画换向和减速坐回。斜走、朝画面深处及向镜头走时须能读出方向。 |
| 离线图与动作清单 | 透明 WebP 或 PNG 图集随 App 打包。清单以物种、阶段、动作、朝向和穿戴定位资源，记录原画尺寸、裁切偏移、身体基准点、各帧的步相、四个爪垫与关节位置、每只爪着地和离地的时点、一整周期步长及其单位。按画布坐标还原每帧，紧裁图片切换时耳尖、身高和落脚线保持连续。 |
| 穿戴 | 原装、外套、围裙共用身体基准及接触数据。帽或蝴蝶结、眼镜、围巾按姿态画在同一角色画布上，保留耳根、镜腿、下颌压住布料的前景毛层。按当前搭配合成并缓存，衣橱试穿和小家用同一幅输出。发布检查列出该步态支持的每个既有槽位，旧档穿戴有对应画稿。 |

暖廊已有可编辑分层、姿态导出和接触点，可复用其制作方法。剧情里奶油的四张跑步图属于狐狸；团团现有 `leap-cat-1` 系列服务于技能腾跃。客户端按正在使用的伙伴、阶段和搭配预解码下一动作，切换时释放不用的图集，记录实测包体、解码内存与掉帧。[角色源稿与导出示例](../design/production/wind/actors/README.md) · [现有衣饰合成](../apps/mobile/lib/illustration/tailoring.dart)

### 路径、步相与落脚

1. **一个位置来源。** 点地、「过来」和自主走动向同一移动逻辑提交庭院目标。沿用可走区域与 `SceneProjection` 的逆映射，在 1536 × 1024 庭院原画坐标中计算实际路程。一步的输出包含身体位置、朝向、姿态、四爪的接触状态；角色、阴影、遮挡深度和点击区域都读取这次输出。拖动画面、屏幕裁切和设备像素比只影响投影。
2. **步相跟随路程。** 起身站稳后才迈步。行进时，步相的增量等于这一帧实际走过的距离除以标定的一周期步长。美术标定侧行、斜行和向纵深走的步长，按角色在该处绘制的大小换算到同一庭院尺度。行进中的加速和减速都按实际位移推进步相，短路程允许迈小步就收脚。关键姿之间分别插补躯干和各条腿，使身体连续越过承重爪。
3. **落地到抬爪。** 每只爪在落地帧记下庭院坐标，承重期间用腿段关节及局部补间把掌垫维持在该点，离地时释放。多爪同时支撑时分别约束；若身体前进量超出可画出的伸展范围，缩短这一步、提前计划换脚，或补过渡姿。脚底的位置还要与图上真实掌缘吻合。阴影接在同一地面。
4. **改向与打断。** 中途重复点地从当前姿势改目标；反向先移重心、卸重再转身，纵向行走采用对应视角。抚摸或技能在当前接触姿势衔接到自己的起始姿，结束后回站姿或坐姿。进后台暂停，切场景重新落位；减少动态效果时直接呈现到达与回应。步相、时钟和爪锁点属于内存状态，重启由已保存的伙伴、阶段、穿戴和场景重建。

### 场景、剧情与存档

- **场景和界面。** 树屋、木梯、桥栏、窗框和地板采用固定几何。新环境动画只驱动指定的叶簇、帘边和水面，使用独立透明层或受限网格，并把相邻三角形的影响范围也算入边界。兑换家具用所属房间同透视的固定画位或整景成画，窗花嵌进窗框，接触阴影、地板投影和前景遮挡随对应状态绘制。视口变化统一通过场景投影转换，旧摆放数据继续保留其归属。儿童控件靠画幅边缘，操作提示不遮住伙伴或数学线索。[庭院风区](../apps/mobile/lib/illustration/animated_backdrop.dart) · [房间成画](../apps/mobile/lib/illustration/room_painting.dart) · [窗光分层](../design/production/wind/room/README.md)
- **互动与主线。** 抚摸、技能、进化分别有可辨认的准备、动作和收势。特效与离线拟音跟随接触、腾跃或落地时点，静音及跳过表演仍看得到结果。剧情由已确认的数学操作推进，渲染层从已提交的章节状态选择伙伴动作、窗光和回家路径。例如先补远窗，奶油能望见亮光，桥上缺口补齐后才动身。沿用原主线入口、章节书签与首次通关标记；重复点击、重演和中断恢复核对同一结果。[章节入口](../apps/mobile/lib/features/wind_chapter.dart) · [修窗状态](../apps/mobile/lib/domain/wind_progress.dart) · [进化表现](../apps/mobile/lib/illustration/evolution.dart)
- **家庭数据。** 首轮步态沿用 SQLite 结构 6 和 `.alicebackup`。渲染和试穿读取当前状态，持久换装、兑换、家长确认等仍走原应用服务和事务。剧情可以保存书签和场景变化，积分与共享经验仍由家庭规则结算。日后若为新章或伙伴回忆增加持久字段，同时设计旧档默认值、迁移、快照摘要及中断恢复，再接入界面。[家庭服务](../apps/mobile/lib/application/family.dart) · [备份格式](BACKUP_FORMAT.md)
