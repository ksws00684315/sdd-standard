# 上手指南

读完这一页，你就能按团队 SDD 规范完成一个需求。规则的完整说明见[团队 SDD 规范](standard.md)。

## 1. 初始化（一次性）

在你平时放所有服务的那个工作空间目录里执行：

```bash
git clone <规则仓库地址> sdd-standard
git clone <治理仓地址> sdd-governance
./sdd-standard/scripts/bootstrap.sh
./sdd-standard/scripts/link-skills.sh
```

- 规则仓库的目录名必须是 `sdd-standard`，治理仓的目录名必须是 `sdd-governance`，skill 按这两个名字查找规则和全局 spec。
- `bootstrap.sh` 把 `repos.txt` 里的服务 clone 到与 `sdd-standard/` 并列的位置，已经存在的会跳过；然后在工作空间根目录生成 `AGENTS.md` 和 `CLAUDE.md` 两个指针文件。根目录已经有同名文件时不会覆盖，而是打印需要你手动加进去的内容。
- `link-skills.sh` 把 `skills/sdd-*` 软链到 `~/.claude/skills` 和 `~/.agents/skills`。以后在规则仓库里 `git pull`，skill 就会同步更新。如果这两个目录里已经有同名的真实目录，脚本会跳过并提示，不会删除。
- 服务仓库里的 `sdd/` 目录是治理仓的只读引用（git submodule）。clone 已有的服务仓库后，进服务目录执行 `git submodule update --init` 初始化它。
- 工作空间根目录本身不纳入版本控制，里面的其他项目不受 SDD 规则约束。

以后打开 AI 工具时，**打开工作空间根目录**，而不是单个服务目录。这样 AI 能同时看到服务地图、规则和所有服务。

## 2. 你的 AI 工具怎么接入

| 工具 | 规则 | skill |
|---|---|---|
| Claude Code | 自动读工作空间根目录的 `CLAUDE.md`，它引用了 `sdd-standard/AGENTS.md` | 链接后可以直接输入 `/sdd-grill` 等命令 |
| Codex 等支持 Agent Skills 的工具 | 读工作空间根目录的 `AGENTS.md`，再按其中的指针读 `sdd-standard/AGENTS.md` | 从 `~/.agents/skills` 加载 |
| Cursor、Copilot、国产工具等 | 大多会读 `AGENTS.md`；不读的话，在工具的规则文件里写一句"遵守 `sdd-standard/AGENTS.md` 的规则" | 支持情况以工具文档为准。不支持时，对 AI 说"按 `sdd-standard/skills/sdd-grill/SKILL.md` 的步骤执行" |

接入后可以这样检查：问 AI "这个工作空间有哪些服务？需求怎么分档？"，它应该能按 `sdd-standard/AGENTS.md` 回答出来。

## 3. 一个需求怎么走

> **平台仓（已接入研发云数字员工）**：L2～L4 需求在数字员工里按 G0–G5 执行——澄清仍用 `/sdd-grill`（含 FEAT 建议和治理仓登记），阶段产物、gate 报告、MR 和状态由平台 agent 生成，人工只做评审和阶段触发。本节描述的是未接入仓的人工流程和跨服务编排，平台映射见[团队 SDD 规范](standard.md)第 5.2 节。

以跨服务需求（L4）为例，完整的文档见[示例需求](example/10000-order-timeout-cancel/README.md)。

### 第一个会话：对齐需求、写文档

```
你：/sdd-grill 10000 目标版本 6.11.1，订单 30 分钟未支付自动取消并释放库存
AI：判断为 L4，涉及 order-service、inventory-service；
    需求点拆成 FEAT-001（自动取消）、FEAT-002（释放库存），已登记进治理仓 prd-index；
    治理仓和两个服务都从 develop-v6.11.1 拉出 feature 分支……
    （几轮提问，每个问题都带推荐答案，你逐一回答）
你：/sdd-spec
AI：建议的测试接缝如下；inventory-service 没有测试基座，库存释放接口用降级验证……
    （你确认后，AI 在治理仓写全局 spec 和 design，在各服务写本服务的 spec）
你：/sdd-tasks
AI：拆成 4 个任务，依赖关系如下……（你确认后，AI 写入两个服务的 tasks.md）
```

前两步必须在同一个会话里完成，中间不要清空上下文。拆任务也尽量在同一个会话里做；涉及的服务多、会话太长时，可以先运行 `/sdd-handoff`，再开新会话拆任务。

### 评审

1. 在治理仓和两个服务的 `feature/10000-order-timeout-cancel` 分支上提交文档。
2. 各开一个 Draft MR，把治理仓全局 spec 的状态改为"评审中"。治理仓的 MR 评审全局 spec、design 和契约变更；服务仓的 MR 评审各自的 spec 和 tasks，reviewer 按 MR 模板里的"Spec 评审"检查项评审。所有 MR 都通过后，把状态改为"已确认"。
3. 评审意见可以在新会话里处理：让 AI 读 spec 并按意见修改，改了 spec 的地方要同步改 tasks。

### 实现：每个任务一个新会话

```
你：/sdd-implement inventory-service T1
AI：复述任务 → 按 spec 声明的方式先验证再实现（测试标注 [FR-xxx]）→ 勾选任务 → 两轴自审 → 运行 check-spec.sh → 提交
```

按依赖顺序完成每个任务，每做完一个就开一个新会话。所有任务完成后，把 Draft MR 改为正式 MR，在 MR 里按"AC 验证清单"逐条填写验证方式和结果，列出没有被验证覆盖的部分，按"代码自查"项自查，然后请人评审。有上线顺序依赖的服务，后上线方的 MR 合并前确认先上线方已合并。提 MR 前也可以自己在服务目录下运行一次 `../sdd-standard/scripts/check-spec.sh`。

### 上线后

**平台仓不做归档**：历史由 `items/<item_id>/reports/`、spec.md 的变更历史和 git 历史承载，版本发布不需要任何回写动作。治理仓的变更目录仍按旧节奏归档：目标版本发布后在下一个版本的开发周期内，把状态改为"已上线"并用 `git mv` 移到 `changes/archive/<年份>/`。未接入仓维持 `docs/changes/archive/<年份>/` 的旧归档。完整规则见 [spec 管理规范](spec-management.md)第 5 节。

### 小需求

- **L2 轻量**：`/sdd-grill` → `/sdd-spec` → Draft MR 评审 → 新会话 `/sdd-implement`，任务少时一次做完。
- **L1 微调**：直接改代码并补回归测试，MR 模板里的 Spec 一栏填"无"。修复中发现 spec 缺失或错误时，先停下改 spec 再修。疑难 bug 让 AI 用 `sdd-diagnose` 排查：它会先建立能稳定复现的失败测试，再找原因。提 MR 前可以让 AI 运行 `sdd-review` 做一次 Standards 方向的审查。

## 4. 常见问题

**单独打开了某个服务仓库怎么办？**
skill 已经链接到个人目录，仍然可以使用；服务的 `AGENTS.md` 里也有指向团队规范的指针。但 AI 看不到服务地图和其他服务，所以跨服务需求一定要打开工作空间。

**实现到一半发现 spec 不对？**
AI 会停下来告诉你。确认修改方案后，先改 spec（必要时同步 tasks），在 spec 的"变更记录"里追加一行，请评审人重新确认这部分修改，然后再继续。全局 spec 在治理仓里时（跨服务需求），这次修改要提交到治理仓的 feature 分支上。详见 [spec 管理规范](spec-management.md)第 3.4 节。

**AI 跳过了提问，直接开始写代码？**
提醒它"按 AGENTS.md 先判断档位"，或者直接输入 `/sdd-grill`。这类情况请记录下来，试点复盘时用来改进规则。

**需求拷问时，有问题需要产品或业务方来定？**
输入 `/sdd-questionnaire`，AI 会把问题整理成一份问卷，可以直接发出去或贴到飞书文档里。拿到答案后回到会话继续。

**要换 AI 工具，或者把做了一半的需求转交给同事？**
输入 `/sdd-handoff`，AI 会生成一份交接文档，引用 spec 和 tasks 的路径，写明进度和下一步。新会话读这份文档就能接着做。

**规范或 skill 有问题，想改？**
在规则仓库提 MR。见[团队 SDD 规范](standard.md)开头的修改方式。
