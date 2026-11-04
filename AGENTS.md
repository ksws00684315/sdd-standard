# SDD 规则仓库

本仓库是团队的 SDD 规则仓库，放在工作空间里，和各微服务仓库并列（默认目录名 `sdd-standard/`，服务清单见 `repos.txt`）。工作空间根目录的 `AGENTS.md` 指向本文件。下文中的路径，除写明是服务目录的以外，都相对于本仓库。

对某个服务做 git 操作时，在该服务目录内执行。完整规范见 `docs/standard.md`。下面是每次工作都会用到的部分。

## 服务地图

> TODO：按实际情况填写。用它判断一个需求涉及哪些服务，以及实现时用哪一档测试方式。

| 服务目录 | 职责 | 依赖的服务 | 负责人 | 测试基座 |
|---|---|---|---|---|
| order-service | 订单创建、状态流转 | inventory-service | @xxx | 全量 |
| inventory-service | 库存扣减、释放 | 无 | @xxx | 无 |

测试基座的取值：**全量**（全量测试能跑通）、**部分**（能单独运行测试类，全量跑不通）、**无**（没有可运行的测试）。

## spec 放在服务仓库里

- 变更 spec：`<服务>/docs/changes/<需求单号>-<英文短描述>/`；现状规格：`<服务>/docs/specs/`
- 已经使用 OpenSpec 的服务，对应位置在 `openspec/` 下，见 `docs/spec-management.md` 第 8 节
- 跨服务需求：主服务放完整的 `spec.md` 和 `design.md`；每个涉及的服务放自己的 `tasks.md`
- 术语表：`<服务>/GLOSSARY.md`，索引见 `GLOSSARY-MAP.md`；跨服务决策：`docs/adr/`
- 命名、状态、归档等管理规则：`docs/spec-management.md`

## 版本分支

- 每个需求在 spec 里写明**目标版本**。feature 分支从 `develop-v<目标版本>` 拉出，MR 合并回这个分支。
- 现状规格描述它所在分支上的代码。
- 审查和校验的基准点：`git merge-base origin/develop-v<目标版本> HEAD`。

## 分档

| 档位 | 场景 | 流程 |
|---|---|---|
| L0 | bug 修复、小调整、配置变更 | 直接修改，补测试；疑难 bug 用 `sdd-diagnose` |
| L1 | 单服务内的新功能或行为变化，包括向后兼容的接口新增（新增可选字段、新增接口） | `/sdd-grill` → `/sdd-spec` → Draft MR → `/sdd-implement` |
| L2 | 跨服务需求、不兼容的接口变更、表结构变更、有上线顺序依赖的改动 | `/sdd-grill` → `/sdd-spec` → `/sdd-tasks` → Draft MR → 每个任务一次 `/sdd-implement` |

收到需求开发类的请求时，先判断档位并告诉用户；L1、L2 建议用户从 `/sdd-grill` 开始。拿不准时按高一档处理。

## 工作方式

- L1、L2 需求写代码前，先读该需求的 spec 和 tasks，实现范围以其中列出的内容为准。
- 实现必须偏离 spec 时，先停下告诉用户，更新 spec 后再继续。
- 每条验收条件都有对应的验证：服务有测试基座时用自动化测试；没有时，按 spec 里事先声明的降级方式验证。
- 业务行为变化时（包括 L0），在同一个 MR 里更新对应能力已有的现状规格并追加变更记录；L1、L2 涉及的能力还没有规格时先补写。
- 提 MR 前，在服务目录下运行 `../sdd-standard/scripts/check-spec.sh`。
- commit 沿用团队现有格式，带上需求单号和改动类型，说明可以用中文（详见 `docs/standard.md` 第 8 节）。
- 探索代码时，工作空间里有代码索引或代码图工具的，优先使用。
- 所用工具不支持 skill 时，直接按 `skills/<命令名>/SKILL.md` 里的步骤执行。
