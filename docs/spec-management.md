# 服务仓库 spec 管理规范

本文件规定治理仓和每个服务仓库里的 spec 文档怎么组织、命名、维护和追溯，是[团队 SDD 规范](standard.md)的组成部分。**接入研发云数字员工的服务仓（全部服务的目标形态）按平台布局执行（第 1～7 节）；尚未接入的仓在迁移前维持旧布局，见第 8 节。**

服务仓的文档分两类：

| 类型 | 回答的问题 | 位置（平台仓） | 生命周期 |
|---|---|---|---|
| **现状规格**（spec.md） | 系统现在是什么样 + 本次 item 要改什么 | `docs/specs/SPEC-<域>-<NNN>/spec.md` | 原地演进，随代码合并，描述它所在分支上的代码；即集团规范里的"模块 Spec" |
| **item 与 gate 报告** | 这次需求改了什么、各阶段检查证据 | `docs/sdd-state.yaml` + `docs/specs/<Spec ID>/items/<item_id>/reports/` | 随 item 产生，永久保留，不做归档清理 |

变更不再有独立的提案文件：需求以 **item**（UUID 身份，登记在 `docs/sdd-state.yaml`）为单位，直接修改 `spec.md`，评审对象是本次 item 对 spec.md 的 diff（阶段 MR），评审证据在 gate 报告。行为规则的唯一权威始终是 spec.md 的正文条目。

## 1. 目录结构

```
<服务>/
├── AGENTS.md / CLAUDE.md
├── GLOSSARY.md                          领域术语（核心域服务必须有，其他按需）
├── sdd/                                 治理仓的只读引用（git submodule）
└── docs/
    ├── prd-index.md                     需求追溯索引（source: workitem，平台维护）
    ├── sdd-state.yaml                   平台状态机（sdd-state.mjs 独占写，人工不编辑）
    └── specs/
        ├── README.md                    人读能力索引（单位级扩展，平台不消费）
        └── SPEC-ORDER-001/              一个 Spec 一个目录，原地演进
            ├── spec.md                  现状规格（骨架见 templates/service/spec-template.md）
            ├── design.md                设计（G2 产出，跨服务需求的放治理仓）
            ├── tasks.md                 任务清单（G3 产出）
            ├── adrs/                    本 Spec 相关的架构决策
            ├── api/                     本 Spec 的 OpenAPI 契约
            ├── ui/                      原型与视觉基线（涉及 UI 时）
            ├── verify/                  降级验证脚本（单位级扩展，手工 AC 核销载体）
            └── items/<item_id>/reports/ gate0～5 报告、unit-test-report.md
```

治理仓的结构见[团队 SDD 规范](standard.md)第 4.3 节和 `templates/governance/`。`docs/specs/` 顶层不再放扁平的能力文件和 `changes/`、`api/`、`adr/` 目录；服务原有的其他文档可以放在 `docs/` 的其他子目录。

## 2. 命名与编号

| 对象 | 规则 | 例子 |
|---|---|---|
| Spec ID | `SPEC-<域>-<NNN>`，三位序号，项目内唯一，由平台 init 分配或迁移时接续分配，终身不变 | `SPEC-ORDER-001` |
| Spec 目录 | Spec ID 即目录名 | `docs/specs/SPEC-ORDER-001/` |
| FR 编号 | `FR-<三位数字>`，一份 spec.md 内唯一，新增接续最大序号，既有条目不改号 | `FR-003` |
| FEAT 编号 | `FEAT-<三位数字>`，项目内唯一，`/sdd-grill` 建议分配 | `FEAT-012` |
| item_id | 平台生成的 UUID，一个需求或迭代一个，不可改 | — |
| 工作项 ID | 需求系统里的纯数字，commit 首行写作 `%<ID>`，也是平台分支名的组成部分 | `18544` |
| ADR | `NNNN-<英文短描述>.md`，编号在所在 `adrs/` 目录递增 | `0002-order-events-via-mq.md` |

- 文件名和目录名一律用英文；文件里的标题和正文用中文。
- 一个 Spec 对应一个业务能力或内聚的领域主题；新需求、迭代沿用 Spec ID 新建 item，不新建目录。
- FR 编号的唯一性范围是 spec.md；跨 Spec 引用写全限定 `[SPEC-ORDER-001/FR-003]`。

## 3. 变更管理

### 3.1 各文件放在哪个仓

| 文件 | 单服务需求（L2/L3/L4） | 跨服务需求（L3/L4）治理仓 | 跨服务需求（L3/L4）各服务仓 |
|---|---|---|---|
| 全局 `spec.md`（FEAT 分配、范围、契约变更） | 无 | 有 | 无 |
| `design.md` | 平台仓：G2 写入本 Spec 目录；L4 单服务必备 | 有 | 无 |
| 本服务条目 | 写入本 Spec 的 `spec.md`（当前 item 段 + 正文条目） | 无 | 同左 |
| `tasks.md` | 平台仓：G3 写入本 Spec 目录 | 无 | 同左 |
| gate 报告 | `items/<item_id>/reports/`（平台生成） | 无 | 同左 |
| `verify/` 降级脚本 | 声明了降级验证时 | 无 | 同左 |

### 3.2 item 与节点状态

状态由平台的 `sdd-state.yaml` 承载，人工不直接编辑（只经 `sdd-state.mjs` 读写）：

- **节点状态**：`pending / in_progress / waiting / passed / blocked`；等待原因 `waiting` 分 `user_input / user_confirmation / review / platform`。
- **阶段推进**：每阶段一个 MR，人工评审通过后节点置 `passed`，由人工触发下一阶段；"继续"不等于批准。
- **完成**：全部节点 passed 后 `finalize`，记录 `spec_commit`；没有"已上线"之类的终态字段，版本发布不需要回写状态。
- 旧制（未接入仓）的状态字段（草稿/评审中/已确认/已上线/已中止）在迁移完成后废止。

### 3.3 职责

- **需求负责人**：治理仓登记（FEAT、prd-index、全局 spec）、跨服务协调、触发平台各阶段、核对 agent 的产出。
- **数字员工**：阶段产物生成、逐项 gate 检查与报告、commit/MR 操作、状态写入；不自动批准、不越过人工门禁。
- **评审人**：各阶段 MR 的人工评审（研发云代码中心）、G0 确认、G5 终验、返工裁决。
- 未接入仓维持旧职责（见第 8 节迁移前的对应说明）。

### 3.4 评审通过后，需求有变化

走平台的**返工入口**：修改请求到达时，agent 按 `sdd-dev-engineer.md` 的规则定位责任节点（需求→G0、规格→G1、设计→G2、任务→G3、代码→G4、验收→G5），登记 `temp_node_id`，置下游受影响节点为 `blocked`，修改产物后按依赖顺序重跑受影响门禁，全部通过并重新取得 MR 批准后才清除返工标记。旧的"变更记录追加一行"做法保留在 spec.md 的变更历史里作为人读摘要。

### 3.5 需求中止

- 还没有代码合并：让 agent 将当前 item 置 `blocked` 并说明原因，治理仓对应需求标记中止；spec.md 里本次 item 的草拟条目回退。
- 已有服务合并了部分代码：按返工入口处理，已合并代码的处置（回滚、开关、保留）由技术负责人决定，治理仓登记结论。

### 3.6 跨服务引用

跨服务需求里，服务仓与治理仓互相引用的锚改为 **`work_item_id + spec_id`**（两者在平台状态和治理仓 prd-index 里都全局唯一）：

```
服务仓 spec 头部：work_item_id: 10000, spec_id: SPEC-ORDER-001
治理仓引用：<服务名>:SPEC-ORDER-001（work_item 10000）
治理仓全局 spec 引用：governance:10000（work_item_id）
```

迁移期存量需求仍按旧模式引用（`<主服务名>:<需求目录名>`、`governance:<需求目录名>`），随需求收尾自然消亡。

### 3.7 涉及的服务不在同一个版本上

跨服务需求涉及的某个服务没有 `develop-v<目标版本>` 分支时，需求负责人和该服务负责人确认目标分支，写进治理仓 `design.md` 服务影响矩阵；该服务在平台 `item.git.target_branch` 登记这个目标分支，agent 的 MR 一律指向它。

## 4. 现状规格（spec.md）写什么

### 4.1 按业务能力组织 Spec

- 一个业务能力（或内聚领域主题）一个 Spec 目录。判断标准与旧制一致：从业务角度能说清楚的一块功能，而不是一个 Controller 或一张表。
- 一个 spec.md 超过大约 300 行，或明显包含两块可独立理解的功能时，拆成新 Spec（新 Spec ID），互相用全限定号引用。
- `docs/specs/README.md` 是人读索引（单位级扩展）：每个 Spec 一行（Spec ID、能力、目录、一句话）。

### 4.2 spec.md 的内容

骨架见 `templates/service/spec-template.md`：

| 写 | 不写 |
|---|---|
| 头部元数据：Spec ID、域、负责人、关联服务 | 完整的请求、响应字段（链接到 `api/`） |
| 业务规则，EARS 句式 + FR 编号 | 规则的演变史（看变更历史和 items 报告） |
| 当前 item 段：本次范围、不做、待确认问题、降级验证声明（评审后转入变更历史） | 类名、方法名、文件路径 |
| 对外接口：接口 + 用途 + `api/` 内契约路径 | 还没合并到本分支的规则（放在当前 item 段） |
| 相关数据：主要表和关键字段的业务含义 | |
| 变更历史：哪些 item 改过这个 Spec | |

被开关关闭的已合并规则也要写，注明"受开关 <名称> 控制"。**现状规格以所在分支为准**，规则随代码合并写入，不等发布。

### 4.3 什么时候必须更新

- 任何改变业务行为的 MR 都要在同一 MR 里更新对应 Spec 的 spec.md（平台 G1/G4 门禁强制：Spec-Code 同 MR），包括 L1。
- 条目落 FR 编号（新增分配新号、修改沿用原号、下线保留编号并在变更历史注明），FR 增删同 MR 同步治理仓主 spec 的 FEAT 映射表。
- 当前 item 段在 G0/G1 填写，评审通过后把"范围/不做/待确认"的结论转入变更历史，段落清空待下一个 item。

### 4.4 职责

- **服务负责人**对本服务各 Spec 的准确性负责，定期抽查。
- **MR 作者 / 数字员工**负责在 MR 里同步 spec.md；评审人按 gate 报告与 MR 描述核对。

## 5. 历史与追溯

平台仓不做归档：历史由三层承载——spec.md 的变更历史（人读摘要）、`items/<item_id>/reports/`（逐项检查证据，永久保留）、git 历史（diff/blame）。旧制的"发布后 git mv 到 archive/<年份>/"废止；已发布的版本分支上什么都不用动。

## 6. 存量

- 已有的需求文档、设计文档（飞书、Confluence 等）**不迁移**，保持原样。
- 迁移平台布局时按第 8.3 节执行；未迁移前，第一次改到某能力时先按旧制补写扁平能力文件，迁移时一并重组。

## 7. 检查清单

平台仓的机械检查由平台 hooks 和 gate 报告承担；`check-spec.sh` 在检测到平台布局后自动切换平台模式，只查平台不覆盖的项：

- [ ] （脚本，平台模式）`docs/specs/` 顶层无遗留的未登记扁平文件
- [ ] （脚本，平台模式）`sdd/` submodule 指针未过期（提醒）
- [ ] `docs/specs/README.md` 索引与实际 Spec 目录一致
- [ ] 当前 item 的"不做、待确认、降级声明"已填写，评审后已转入变更历史
- [ ] FR 增删已同步治理仓 FEAT 映射表
- [ ] `verify/` 脚本可重复执行，先验证过它能暴露问题

## 8. 未接入仓与迁移指南

### 8.1 未接入仓的旧布局（迁移前临时有效）

```
docs/
├── api/                     OpenAPI（api-<服务名>.yaml）
├── specs/                   扁平能力文件（<能力英文名>.md，头部 Spec ID）
├── changes/<需求单号>-<英文短描述>/   变更 spec（spec.md/design.md/tasks.md/verify/）
│   └── archive/<年份>/
└── adr/
```

旧制下的状态字段（草稿/评审中/已确认/已上线/已中止）、归档流程、跨服务引用格式按本文件 v0.3 版执行；OpenSpec 服务在迁移前也按 v0.3 的存量对应关系执行。

### 8.2 OpenSpec 服务：直接迁移到平台布局

OpenSpec 服务不再迁往中间形态，直接并入第 8.3 节的迁移 MR：

| OpenSpec 位置 | 迁移到 |
|---|---|
| `openspec/specs/<能力>/spec.md` | `docs/specs/SPEC-<域>-<NNN>/spec.md`（分配 Spec ID、FR 编号） |
| `openspec/changes/<需求目录>/`（进行中） | 走完旧流程自然收尾，不迁移；收尾后其结论按第 4.2 节落进对应 spec.md |
| `openspec/changes/archive/` | 不迁移（git 历史即归档）；有需要时将关键结论摘录进对应 spec.md 的变更历史 |

迁移后 `openspec` CLI 停用，`openspec validate` 的职能由平台 hooks 与 `check-spec.sh` 承接。

### 8.3 任意服务仓的迁移步骤（每仓一次）

1. 进行中的 `docs/changes/` 需求走完旧流程；不再开新需求进旧流程。
2. 迁移 MR（一次性）：`docs/specs/<能力>.md` 逐个重组为 `docs/specs/SPEC-<域>-<NNN>/spec.md`（`git mv`，Spec ID 提为目录名，序号补三位）；`docs/api/` 移入对应 Spec 的 `api/`；`docs/adr/` 移入相关 Spec 的 `adrs/`；更新 README 索引；删除空目录。
3. 在研发云接入数字员工包：init 生成 `docs/sdd-state.yaml`、安装 hooks、登记仓库与项目绑定、生成/修订服务 `AGENTS.md`。
4. 运行 `../sdd-standard/scripts/check-spec.sh`（自动进入平台模式）确认无报错；此后新需求一律走平台流程。
