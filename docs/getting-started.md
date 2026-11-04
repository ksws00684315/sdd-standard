# 上手指南

读完这一页，你就能按团队 SDD 规范完成一个需求。规则的完整说明见[团队 SDD 规范](standard.md)。

## 1. 初始化（一次性）

在你平时放所有服务的那个工作空间目录里执行：

```bash
git clone <规则仓库地址> sdd-standard
./sdd-standard/scripts/bootstrap.sh
./sdd-standard/scripts/link-skills.sh
```

- 规则仓库的目录名必须是 `sdd-standard`，skill 按这个名字查找规则。
- `bootstrap.sh` 把 `repos.txt` 里的服务 clone 到与 `sdd-standard/` 并列的位置，已经存在的会跳过；然后在工作空间根目录生成 `AGENTS.md` 和 `CLAUDE.md` 两个指针文件。根目录已经有同名文件时不会覆盖，而是打印需要你手动加进去的内容。
- `link-skills.sh` 把 `skills/sdd-*` 软链到 `~/.claude/skills` 和 `~/.agents/skills`。以后在规则仓库里 `git pull`，skill 就会同步更新。如果这两个目录里已经有同名的真实目录，脚本会跳过并提示，不会删除。
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

以跨服务需求（L2）为例，完整的文档见[示例需求](example/REQ-0000-order-timeout-cancel/README.md)。

### 第一个会话：对齐需求、写文档

```
你：/sdd-grill REQ-0000 目标版本 6.11.1，订单 30 分钟未支付自动取消并释放库存
AI：判断为 L2，涉及 order-service、inventory-service，建议主服务 order-service；
    两个服务都从 develop-v6.11.1 拉出 feature 分支……
    （几轮提问，每个问题都带推荐答案，你逐一回答）
你：/sdd-spec
AI：建议的测试接缝如下；inventory-service 没有测试基座，库存释放接口用降级验证……
    （你确认后，AI 写出 spec.md 和 design.md）
你：/sdd-tasks
AI：拆成 4 个任务，依赖关系如下……（你确认后，AI 写入两个服务的 tasks.md）
```

前两步必须在同一个会话里完成，中间不要清空上下文。拆任务也尽量在同一个会话里做；涉及的服务多、会话太长时，可以先运行 `/sdd-handoff`，再开新会话拆任务。

### 评审

1. 在两个服务的 `feature/REQ-0000-order-timeout-cancel` 分支上提交文档。
2. 各开一个 Draft MR，把主服务 spec 的状态改为"评审中"，请 reviewer 按 MR 模板里的"Spec 评审"检查项评审。两个 MR 都通过后，把状态改为"已确认"。
3. 评审意见可以在新会话里处理：让 AI 读 spec 并按意见修改，改了 spec 的地方要同步改 tasks。

### 实现：每个任务一个新会话

```
你：/sdd-implement inventory-service T1
AI：复述任务 → 按 spec 声明的方式先验证再实现 → 勾选任务 → 两轴自审 → 运行 check-spec.sh → 提交
```

按依赖顺序完成每个任务，每做完一个就开一个新会话。所有任务完成后，把 Draft MR 改为正式 MR，在 MR 里列出没有被验证覆盖的部分，按"代码自查"项自查，然后请人评审。提 MR 前也可以自己在服务目录下运行一次 `../sdd-standard/scripts/check-spec.sh`。

### 上线后

目标版本发布（`release-v<目标版本>` 上线）后，在下一个版本的开发周期内，在下一个版本的 `develop` 分支上把主服务 spec 的状态改为"已上线"，再用 `git mv` 把各服务的变更目录移到 `docs/changes/archive/<年份>/`。可以顺带放在该服务的下一个 MR 里。完整规则见 [spec 管理规范](spec-management.md)第 5 节。

### L1 和 L0

- **L1**：`/sdd-grill` → `/sdd-spec` → Draft MR 评审 → 新会话 `/sdd-implement`。
- **L0**：直接改代码并补测试，MR 模板里的 Spec 一栏填"无"。疑难 bug 让 AI 用 `sdd-diagnose` 排查：它会先建立能稳定复现的失败测试，再找原因。提 MR 前可以让 AI 运行 `sdd-review` 做一次 Standards 方向的审查。

## 4. 常见问题

**单独打开了某个服务仓库怎么办？**
skill 已经链接到个人目录，仍然可以使用；服务的 `AGENTS.md` 里也有指向团队规范的指针。但 AI 看不到服务地图和其他服务，所以跨服务需求一定要打开工作空间。

**实现到一半发现 spec 不对？**
AI 会停下来告诉你。确认修改方案后，先改 spec（必要时同步 tasks），在 spec 的"变更记录"里追加一行，请评审人重新确认这部分修改，然后再继续。spec 在主服务仓库里时，这次修改要提交到主服务的 feature 分支上。详见 [spec 管理规范](spec-management.md)第 3.4 节。

**AI 跳过了提问，直接开始写代码？**
提醒它"按 AGENTS.md 先判断档位"，或者直接输入 `/sdd-grill`。这类情况请记录下来，试点复盘时用来改进规则。

**需求拷问时，有问题需要产品或业务方来定？**
输入 `/sdd-questionnaire`，AI 会把问题整理成一份问卷，可以直接发出去或贴到飞书文档里。拿到答案后回到会话继续。

**要换 AI 工具，或者把做了一半的需求转交给同事？**
输入 `/sdd-handoff`，AI 会生成一份交接文档，引用 spec 和 tasks 的路径，写明进度和下一步。新会话读这份文档就能接着做。

**规范或 skill 有问题，想改？**
在规则仓库提 MR。见[团队 SDD 规范](standard.md)开头的修改方式。
