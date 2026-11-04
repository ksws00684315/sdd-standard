# 团队 SDD 规则仓库

SDD（Spec-Driven Development，规格驱动开发）：先把"要做什么"写成 spec 并评审，再让人或 AI 按 spec 实现。

这个仓库就是大家平时打开的 AI 编码工作空间。它只管理规范、AI 规则、skill、模板和脚本，不存放真实需求的 spec（`docs/example/` 只用于演示）。各微服务仍然是独立的 git 仓库，clone 在本目录下，被 `.gitignore` 忽略；所有 spec 都放在对应的服务仓库里。

## 快速开始

```bash
git clone <本仓库地址> workspace
cd workspace
./scripts/bootstrap.sh     # 按 repos.txt clone 所有服务
./scripts/link-skills.sh   # 把 sdd skill 链接到个人目录
```

然后阅读[上手指南](docs/getting-started.md)。

## 文档导航

| 文档 | 给谁看 | 内容 |
|---|---|---|
| [团队 SDD 规范](docs/standard.md) | 所有人 | 规范正文：spec 放哪、怎么分档、每个阶段做什么、怎么评审 |
| [服务仓库 spec 管理规范](docs/spec-management.md) | 所有人 | 服务仓库里 spec 的目录、命名、状态、职责、更新和归档规则 |
| [上手指南](docs/getting-started.md) | 新成员 | 初始化、各 AI 工具怎么接入、一个需求从头到尾怎么走 |
| [完整示例](docs/example/REQ-0000-order-timeout-cancel/README.md) | 所有人 | 一个跨服务需求的全部文档 |
| [服务接入清单](docs/service-onboarding.md) | 服务负责人 | 一个已有服务接入规范要做的事 |
| [编码规范](docs/coding-standards.md) | 所有人 | 两轴审查中 Standards 方向的依据 |
| [试点与推广计划](docs/rollout-plan.md) | 负责人、架构师 | 试点范围、评估指标、推广节奏 |
| [跨服务决策（ADR）](docs/adr/) | 所有人 | 难以撤销、经过取舍的架构决策 |

## 目录

| 路径 | 内容 |
|---|---|
| `AGENTS.md` / `CLAUDE.md` | AI 工具每次会话都会读的规则入口 |
| `GLOSSARY-MAP.md` | 各服务术语表的索引 |
| `docs/` | 规范、指南、示例、ADR |
| `skills/` | 12 个 `sdd-*` skill：4 个阶段、5 个方法、3 个工具，分类见[规范第 9 节](docs/standard.md#9-ai-工具) |
| `templates/service/` | 复制到服务仓库的模板 |
| `scripts/` | `bootstrap.sh`（clone 服务）、`link-skills.sh`（链接 skill） |

## 致谢

`skills/` 中的大部分 skill 精简、本地化改写自 [mattpocock/skills](https://github.com/mattpocock/skills)（MIT 许可，见 `skills/LICENSE-mattpocock-skills`）：

| 本仓库 | 来源 |
|---|---|
| `sdd-interview` | grilling |
| `sdd-domain` | domain-modeling |
| `sdd-spec` | to-spec |
| `sdd-tasks` | to-tickets |
| `sdd-implement` | implement |
| `sdd-tdd` | tdd |
| `sdd-review` | code-review |
| `sdd-diagnose` | diagnosing-bugs |
| `sdd-questionnaire` | to-questionnaire |
| `sdd-handoff` | handoff |
| `sdd-retro` | retro |

改写后的内容完全保存在本仓库里，不依赖原仓库，也不会随原仓库的更新而变化。
