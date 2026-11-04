# 服务接入清单

一个已有的服务接入团队 SDD 规范需要做的事。由服务负责人完成，提一个 MR 即可。

不需要一次性补齐所有现状规格：先接入，之后哪块业务被需求改到了，再补哪块的现状规格。

## 在规则仓库

- [ ] `repos.txt` 加一行：`<服务目录名> <git 地址>`
- [ ] `AGENTS.md` 的服务地图加一行：职责、依赖的服务、负责人
- [ ] `GLOSSARY-MAP.md` 的服务表加一行

## 在服务仓库

- [ ] 复制 `templates/service/AGENTS.md` 到仓库根目录，填写职责、模块结构、本地运行与测试命令、编码约定
- [ ] 复制 `templates/service/CLAUDE.md` 到仓库根目录，不用改
- [ ] 复制 `templates/service/merge_request.md` 到 `.gitlab/merge_request_templates/Default.md`
- [ ] 复制 `templates/service/specs-index.md` 到 `docs/specs/README.md`，作为现状规格的索引，暂时可以没有条目
- [ ] 创建 `docs/changes/archive/` 目录（可以放一个 `.gitkeep`）；按年份的子目录在第一次归档时再创建
- [ ] 确认 `docs/` 下原有的目录没有和 `specs`、`changes`、`adr` 重名
- [ ] 确认本地能跑通全量测试，并把测试命令写进服务的 `AGENTS.md`。测试跑不通时，AI 的测试先行和两轴审查都无法正常工作

## 按需补充（不阻塞接入）

- [ ] **现状规格**：第一个需求改到某块业务时，按 `templates/service/capability-spec.md` 在 `docs/specs/` 下补这块业务的现状规格，并登记到索引。可以让 AI 先读代码起草，再由人校对；旧的需求、设计文档不迁移，链接写进"参考资料"。规则见 [spec 管理规范](spec-management.md)第 4、6 节
- [ ] **术语表**：第一次在需求拷问中确定术语时，由 AI 创建 `GLOSSARY.md`，同时在规则仓库的 `GLOSSARY-MAP.md` 登记
- [ ] **ADR**：第一次出现满足三个门槛的决策时，创建 `docs/adr/`

## 检查

在工作空间打开 AI 工具，问："`<服务名>` 负责什么？怎么运行它的测试？"AI 应该能根据服务的 `AGENTS.md` 回答。
