# 服务接入清单

一个已有的服务接入团队 SDD 规范需要做的事。由服务负责人完成，提一个 MR 即可。

不需要一次性补齐所有现状规格：先接入，之后哪块业务被需求改到了，再补哪块的现状规格。

## 阻塞项：测试基座

接入前必须先确认服务的测试基座，并做到**至少能编译、并能单独运行一个测试类**。做不到这一点，AI 的测试先行和两轴自审都没法工作。

1. 确认 `mvn compile` 能通过。
2. 检查 `maven-surefire-plugin` 有没有配置 `<skip>true</skip>`。有的话去掉，或改成 `<skip>${skipTests}</skip>` 这类能被命令行覆盖的形式——写死在插件配置里的 `<skip>true</skip>` 无法用 `-Dtest` 或 `-DskipTests=false` 打开。
3. 确认 `mvn test -Dtest=<任意一个测试类>` 能运行。服务里一个测试类都没有的，跳过这一步。
4. 按结果确定测试基座，写进规则仓库 `AGENTS.md` 的服务地图和服务自己的 `AGENTS.md`：

   | 测试基座 | 判断标准 | 实现时的验证方式 |
   |---|---|---|
   | 全量 | `mvn test` 全量能跑通 | 自动化测试，全量测试通过 |
   | 部分 | 能单独运行测试类，全量跑不通 | 自动化测试，单独运行相关测试类 |
   | 无 | 没有可运行的测试 | spec 里声明降级验证，用脚本代替（见 `skills/sdd-tdd/SKILL.md`） |

测试基座为"部分"或"无"不影响接入，只决定实现时用哪种验证方式。后续恢复或补齐测试时，更新这两处的取值。

## 在规则仓库和治理仓

- [ ] `repos.txt` 加一行：`<服务目录名> <git 地址>`（供 bootstrap.sh clone 用；权威清单在治理仓 `repos.yaml`，两处同步维护）
- [ ] 治理仓 `repos.yaml` 加一行：服务名、git 地址、域
- [ ] 治理仓 `domains.yaml` 登记域：`<域名> owner_repo: <服务目录名>`，域名取服务名去 `service` 后缀的大写
- [ ] `AGENTS.md` 的服务地图加一行：域、职责、依赖的服务、负责人、测试基座
- [ ] `GLOSSARY-MAP.md` 的服务表加一行

## 在服务仓库

- [ ] 复制 `templates/service/AGENTS.md` 到仓库根目录，填写职责、模块结构、本地运行与测试命令、测试基座、编码约定。前三章（版本信息 / 核心原则 / AI 安全约束）是集团规范 E-01 的必备结构，禁止删减。仓库已有 `AGENTS.md` 的，把模板里的内容合并进去，不要覆盖原有约定；已有代码图或索引工具生成的托管块（如 `<!-- graft:start -->`）原样保留，否则工具重新生成时会冲掉手写内容
- [ ] 复制 `templates/service/CLAUDE.md` 到仓库根目录；已有 `CLAUDE.md` 的，确认它引用了 `AGENTS.md`
- [ ] 配置治理仓只读引用：`git submodule add <治理仓地址> sdd`（对应集团多仓模式的跨仓引用：只读、版本锁定）
- [ ] 复制 `templates/service/merge_request.md` 到 `.gitlab/merge_request_templates/Default.md`
- [ ] 复制 `templates/service/specs-index.md` 到 `docs/specs/README.md`，作为现状规格的索引，暂时可以没有条目
- [ ] 创建 `docs/api/`（对外接口的 OpenAPI 契约，没有对外接口可以后补）和 `docs/changes/archive/` 目录（可以放一个 `.gitkeep`）；按年份的子目录在第一次归档时再创建
- [ ] 确认 `docs/` 下原有的目录没有和 `specs`、`changes`、`adr`、`api` 重名
- [ ] 已经使用 OpenSpec 的服务，跳过 `docs/specs/` 和 `docs/changes/` 两项，按 [spec 管理规范](spec-management.md)第 8.2 节在迁移 MR 里直接迁到平台布局
- [ ] **平台接入**（目标形态）：在研发云接入 SDD 数字员工包，运行 init 生成 `docs/sdd-state.yaml`、安装 hooks、登记仓库与项目绑定；随后按 [spec 管理规范](spec-management.md)第 8.3 节把 `docs/specs/` 重组为 `SPEC-<域>-<NNN>/` 目录、`docs/api/` 并入各 Spec。接入后 `check-spec.sh` 自动切平台模式
- [ ] 在服务目录下运行 `../sdd-standard/scripts/check-spec.sh`，确认能正常输出结果。已有 `docs/changes/` 或 `openspec/changes/` 存量目录的不受影响：命名检查只看本次分支新增的目录

## 按需补充（不阻塞接入）

- [ ] **现状规格**：第一个需求改到某块业务时，按 `templates/service/spec-template.md` 补这块业务的现状规格（分配 Spec ID、条目标 FR 编号）；平台仓放 `docs/specs/SPEC-<域>-<NNN>/spec.md`，未接入仓放扁平文件并在迁移时重组。登记到索引和治理仓主 spec 的能力索引。可以让 AI 先读代码起草，再由人校对；旧的需求、设计文档不迁移，链接写进"参考资料"。规则见 [spec 管理规范](spec-management.md)第 4、6 节
- [ ] **术语表**：核心域服务（设备、家庭、分享、用户、外部集成相关）在第一个需求时创建 `GLOSSARY.md`；其他服务在第一次确定术语时再创建。新建时同时在规则仓库的 `GLOSSARY-MAP.md` 登记
- [ ] **ADR**：第一次出现满足三个门槛的决策时，创建 `docs/adr/`

## 检查

在工作空间打开 AI 工具，问："`<服务名>` 负责什么？测试基座是什么？怎么运行它的测试？"AI 应该能根据服务的 `AGENTS.md` 回答。
