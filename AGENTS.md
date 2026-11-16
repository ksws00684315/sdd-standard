# SDD 规则仓库

本仓库是团队的 SDD 规则仓库，放在工作空间里，和治理仓、各微服务仓库并列（默认目录名 `sdd-standard/`，治理仓为 `sdd-governance/`，服务清单见治理仓的 `repos.yaml`）。工作空间根目录的 `AGENTS.md` 指向本文件。下文中的路径，除写明是服务目录的以外，都相对于本仓库。

本规范是集团《SDD开发规范》《SDD分级评估标准》《SDD模板》（v1.0）的单位级扩展与落地实施细则；冲突时以集团规范为准。**接入研发云数字员工的服务仓，L2～L4 需求由平台 agent 按 G0–G5 执行（`docs/standard.md` 第 5 章），sdd-* skills 负责需求澄清、治理仓登记与跨服务编排；未接入的仓按第 7～8 章人工流程。**对某个服务做 git 操作时，在该服务目录内执行；对治理仓做 git 操作时，在治理仓目录内执行。完整规范见 `docs/standard.md`。下面是每次工作都会用到的部分。

## 服务地图

> TODO：按实际情况填写。用它判断一个需求涉及哪些服务，以及实现时用哪一档测试方式。

| 服务目录 | 域 | 职责 | 依赖的服务 | 负责人 | 测试基座 |
|---|---|---|---|---|---|
| order-service | ORDER | 订单创建、状态流转 | inventory-service | @xxx | 全量 |
| inventory-service | INVENTORY | 库存扣减、释放 | 无 | @xxx | 无 |

测试基座的取值：**全量**（全量测试能跑通）、**部分**（能单独运行测试类，全量跑不通）、**无**（没有可运行的测试）。

## spec 放在哪

- **平台仓**（已接入数字员工）：`docs/specs/SPEC-<域>-<NNN>/`（spec.md 现状规格 + design.md + tasks.md + api/ + adrs/ + verify/ + items/ 报告）、`docs/prd-index.md`、`docs/sdd-state.yaml`；布局与规则见 `docs/spec-management.md` 第 1～7 节
- **未接入仓**（迁移前临时）：现状规格 `docs/specs/<能力>.md`，变更 spec `docs/changes/<需求单号>-<英文短描述>/`
- 治理仓 `sdd-governance/`：`prd-index.md`（需求追溯索引）、主 `spec.md`（FEAT 映射表）、`spec-contract-<主题>.md`（跨服务契约）、`changes/<需求目录>/`（跨服务需求的全局 spec 和 design）
- 服务仓的 `sdd/` 目录是治理仓的只读引用，禁止在里面改动（包括平台 agent 的提交）；治理仓的修改回治理仓走 MR
- 跨服务需求：治理仓放全局 spec 和 design；每个涉及的服务仓由平台 agent 或人工写本服务部分，引用锚为 `work_item_id + spec_id`
- 已经使用 OpenSpec 的服务，按 `docs/spec-management.md` 第 8.2 节直接迁到平台布局
- 术语表：`<服务>/GLOSSARY.md`，索引见 `GLOSSARY-MAP.md`；跨服务决策：治理仓 `docs/adr/`，Spec 内决策进各 Spec 的 `adrs/`
- 命名、编号、状态、迁移等管理规则：`docs/spec-management.md`

## 版本分支

- 每个需求在 spec 里写明**目标版本**。feature 分支从 `develop-v<目标版本>` 拉出，MR 合并回这个分支，治理仓和各服务用相同分支名。
- 现状规格描述它所在分支上的代码。
- 审查和校验的基准点：`git merge-base origin/develop-v<目标版本> HEAD`。

## 分档

分档用集团变更四级，从高定级，拿不准时按高一档处理：

| 档位 | 场景 | 流程 |
|---|---|---|
| L1 微调 | bug 修复（代码违反 spec）、文案格式、不改行为的配置、纯重构、文档纠错 | 直接修改，补回归测试；疑难 bug 用 `sdd-diagnose` |
| L2 轻量 | 单服务纯新增小需求：新增 FR≤2 且 AC≤5、≤2 人日、不改既有 FR/AC、不新增对外接口 | `/sdd-grill` → `/sdd-spec` → Draft MR → `/sdd-implement` |
| L3 增量 | 新增对外接口或可选字段、新增 FR≥3 或 AC>5、跨服务的纯新增 | `/sdd-grill` → `/sdd-spec` → `/sdd-tasks` → Draft MR → 每个任务一次 `/sdd-implement` |
| L4 重大 | 改既有行为语义、不兼容接口变更、表结构变更、跨服务契约变更、上线顺序依赖 | 同 L3，`design.md` 必备；跨服务走治理仓，按上线顺序做批次核对 |

修复中发现 spec 缺失或错误时，先停下改 spec（重新定档），再修代码。改变业务行为的配置变更不走 L1。

收到需求开发类的请求时，先判断档位并告诉用户；L2～L4 建议用户从 `/sdd-grill` 开始。

## 工作方式

- 先分清载体：接入数字员工的服务仓，L2～L4 由平台 agent 按 G0–G5 执行，你不生成阶段产物、不代写 gate 报告，只做澄清、治理仓登记和跨服务编排（见 `docs/standard.md` 第 5 章）；未接入的仓按下面的人工流程。
- L2～L4 需求写代码前，先读该需求的 spec 和 tasks，实现范围以其中列出的内容为准；跨服务需求同时读治理仓的全局 spec 和 design。
- 实现必须偏离 spec 时，先停下告诉用户，更新 spec 后再继续。
- 每条验收条件都有对应的验证：服务有测试基座时用自动化测试并标注 `[FR-xxx]`；没有时，按 spec 里事先声明的降级方式验证（脚本放 Spec 目录的 `verify/`）。
- 业务行为变化时（包括 L1），在同一个 MR 里更新对应能力的现状规格并追加变更记录；还没有现状规格时先补写。
- 提 MR 前，在服务目录下运行 `../sdd-standard/scripts/check-spec.sh`（平台仓自动切平台模式）。
- commit 第一行为 `%<需求单号> <type>(<scope>): <说明>`，半角冒号，说明可以用中文；平台仓由 hooks 强制补 `Spec-Id:`/`Task-Id:` trailer（详见 `docs/standard.md` 第 10 节）。
- 探索代码时，工作空间里有代码索引或代码图工具的，优先使用。
- 所用工具不支持 skill 时，直接按 `skills/<命令名>/SKILL.md` 里的步骤执行。
