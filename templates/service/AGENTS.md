# <服务名>

<!-- 复制到服务仓库根目录。全局规则在规则仓库 `../sdd-standard/AGENTS.md`，这里只写本服务特有的内容，禁止复制通用规则。 -->
<!-- 前三章（版本信息 / 核心原则 / AI 安全约束）是集团规范 E-01 要求的必备结构，禁止删减；后面各节按本服务实际情况填写。 -->

## 1. 版本信息

- 版本号：0.1.0
- 生效日期：<YYYY-MM-DD>
- 修订权限：本服务负责人；修改走 MR

## 2. 核心原则

<!-- 项目级不可协商的约束，逐条列出。 -->

- Test-First：行为变更先写失败的测试，再写实现
- Security-By-Default：鉴权、加密、幂等在设计阶段确认，不留到实现阶段补定
- Interface Contract：对外接口以 `docs/api/` 的 OpenAPI 契约为准，接口文档平台为展示层
- Code Quality：以《阿里巴巴 Java 开发手册》（黄山版）为基线，详见规则仓库 `docs/coding-standards.md`

## 3. AI 安全约束

<!-- 红线，禁止降级、禁止删除。 -->

- 禁止生成 SQL 注入、XSS、命令注入等漏洞代码；MyBatis 拼接用户输入用 `#{}`，不用 `${}`
- 禁止硬编码密钥、凭证
- 敏感数据必须加密处理，不得写入日志
- AI 禁止绕过认证授权逻辑

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

- 本服务已接入研发云 SDD 数字员工：L2～L4 需求由它按 G0–G5 执行（规则见规则仓库 `docs/standard.md` 第 5 章），sdd-* skills 只负责需求澄清、治理仓登记和跨服务编排。
- `docs/specs/SPEC-<域>-<NNN>/`：现状规格（spec.md，即集团的模块 Spec，条目带 FR 编号）+ design + tasks + api + adrs + verify/。业务行为变化时，spec.md 在同一 MR 里更新（平台门禁强制），规则见规则仓库的 `docs/spec-management.md`。
- `docs/prd-index.md`、`docs/sdd-state.yaml`：平台维护，人工不编辑 `sdd-state.yaml`。
- `sdd/`：治理仓的只读引用，禁止改动（包括 agent 的提交）。
- `GLOSSARY.md`：本服务的领域术语，第一次需要时创建。
