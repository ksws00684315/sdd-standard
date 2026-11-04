# 工作空间说明

本目录是微服务工作空间，也是团队的 SDD 规则仓库。各微服务是独立的 git 仓库，clone 在本目录下（清单见 `repos.txt`）；对某个服务做 git 操作时，在该服务目录内执行。

完整规范见 `docs/standard.md`。下面是每次工作都会用到的部分。

## 服务地图

> TODO：按实际情况填写。用它判断一个需求涉及哪些服务。

| 服务目录 | 职责 | 依赖的服务 | 负责人 |
|---|---|---|---|
| order-service | 订单创建、状态流转 | inventory-service | @xxx |
| inventory-service | 库存扣减、释放 | 无 | @xxx |

## spec 放在服务仓库里

- 变更 spec：`<服务>/docs/changes/<需求单号>-<英文短描述>/`；现状规格：`<服务>/docs/specs/`
- 跨服务需求：主服务放完整的 `spec.md` 和 `design.md`；每个涉及的服务放自己的 `tasks.md`
- 术语表：`<服务>/GLOSSARY.md`，索引见 `GLOSSARY-MAP.md`；跨服务决策：`docs/adr/`
- 命名、状态、归档等管理规则：`docs/spec-management.md`

## 分档

| 档位 | 场景 | 流程 |
|---|---|---|
| L0 | bug 修复、小调整、配置变更 | 直接修改，补测试；疑难 bug 用 `sdd-diagnose` |
| L1 | 单服务内的新功能或行为变化 | `/sdd-grill` → `/sdd-spec` → Draft MR → `/sdd-implement` |
| L2 | 跨服务需求、接口变更、表结构变更 | `/sdd-grill` → `/sdd-spec` → `/sdd-tasks` → Draft MR → 每个任务一次 `/sdd-implement` |

收到需求开发类的请求时，先判断档位并告诉用户；L1、L2 建议用户从 `/sdd-grill` 开始。拿不准时按高一档处理。

## 工作方式

- L1、L2 需求写代码前，先读该需求的 spec 和 tasks，实现范围以其中列出的内容为准。
- 实现必须偏离 spec 时，先停下告诉用户，更新 spec 后再继续。
- 每条验收条件都有对应的测试。
- 业务行为变化时（包括 L0），在同一个 MR 里更新对应能力已有的现状规格并追加变更记录；L1、L2 涉及的能力还没有规格时先补写。
- 分支用 `feature/<需求单号>-<描述>`（修复用 `fix/`，L0 没有需求单号时用 `fix/<描述>`），同一需求在各服务用相同分支名；commit 用 Conventional Commits，有需求单号时带上。
- 所用工具不支持 skill 时，直接按 `skills/<命令名>/SKILL.md` 里的步骤执行。
