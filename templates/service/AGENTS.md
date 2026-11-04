# <服务名>

<!-- 复制到服务仓库根目录。全局规则在规则仓库 `../sdd-standard/AGENTS.md`，这里只写本服务特有的内容。 -->

需求开发遵循团队 SDD 规范（规则仓库在工作空间里与本仓库并列，即 `../sdd-standard/`，规范正文见其中的 `docs/standard.md`）。L1、L2 需求从 `/sdd-grill` 开始。

## 职责

## 模块结构

<!-- 例如：xxx-api（对外 DTO）、xxx-service（业务实现）…… -->

## 本地运行与测试

```bash
mvn test
```

<!-- 测试基座：全量 / 部分 / 无。和规则仓库 AGENTS.md 服务地图里的取值保持一致。 -->
- 测试基座：
- 单独运行一个测试类：`mvn test -Dtest=<类名>`

## 编码约定

<!-- 本服务特有的约定，例如分层规则、异常处理、日志规范。 -->

## 规格文档

- `docs/specs/`：现状规格。改动业务行为时，在同一个 MR 里同步更新并追加变更记录，规则见规则仓库的 `docs/spec-management.md`。
- `docs/changes/`：变更 spec，按需求单号分目录。流程见 `../sdd-standard/AGENTS.md`。
- `GLOSSARY.md`：本服务的领域术语；`docs/adr/`：本服务内部的架构决策。两者都在第一次需要时创建。
