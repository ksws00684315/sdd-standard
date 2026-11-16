# 示例：10000 订单超时未支付自动取消

这是一个虚构的 L4 跨服务需求，展示规范要求的全部文档写出来是什么样。目录结构和真实情况一致：全局文档放在治理仓，各服务的文档放在各自的服务仓库里，这里只是把它们放在一起方便阅读。

## 需求

订单创建 30 分钟后仍未支付的，自动取消并释放锁定的库存。涉及 order-service 和 inventory-service。需求点拆成两个 FEAT：FEAT-001（超时自动取消，order-service）、FEAT-002（取消后释放库存，两个服务），登记在治理仓的 `prd-index.md`。

## 文档清单

| 文件 | 由哪个命令产出 | 阶段 |
|---|---|---|
| [sdd-governance/.../spec.md](sdd-governance/changes/10000-order-timeout-cancel/spec.md) | `/sdd-spec`（全局 spec） | ② 写 spec |
| [sdd-governance/.../design.md](sdd-governance/changes/10000-order-timeout-cancel/design.md) | `/sdd-spec` | ② 写 spec |
| [order-service/.../spec.md](order-service/docs/changes/10000-order-timeout-cancel/spec.md) | `/sdd-spec`（本服务条目） | ② 写 spec |
| [order-service/.../tasks.md](order-service/docs/changes/10000-order-timeout-cancel/tasks.md) | `/sdd-tasks` | ③ 拆任务 |
| [inventory-service/.../spec.md](inventory-service/docs/changes/10000-order-timeout-cancel/spec.md) | `/sdd-spec`（本服务条目） | ② 写 spec |
| [inventory-service/.../tasks.md](inventory-service/docs/changes/10000-order-timeout-cancel/tasks.md) | `/sdd-tasks` | ③ 拆任务 |
| [inventory-service/.../verify/stock-release.sh](inventory-service/docs/changes/10000-order-timeout-cancel/verify/stock-release.sh) | `/sdd-implement`，T1 的降级验证脚本 | ⑤ 实现 |
| [order-service/docs/specs/README.md](order-service/docs/specs/README.md) | 服务接入时创建，之后按需更新 | 长期维护 |
| [order-service/docs/specs/order-lifecycle.md](order-service/docs/specs/order-lifecycle.md) | `/sdd-implement`，随 T3、T4 的代码一起更新 | ⑤ 实现 |

`order-lifecycle.md` 展示的是 T3、T4 合并之后的样子：现状规格只在代码合并时才更新，所以在 feature 分支上，它和变更 spec 是同时修改的。

这个示例里的 spec 状态是"已确认"（记录在治理仓全局 spec），并且 order-service 的 spec 里有一条变更记录，演示评审通过之后需求发生变化时怎么记录。目标版本 6.11.1 发布后，治理仓和两个服务的 `10000-order-timeout-cancel/` 目录会在下一个版本的 `develop` 分支上各自移到归档目录。

## `/sdd-grill` 第一轮提问节选

需求拷问不产出文件，它的结论直接写进 spec。下面是第一轮里的三个问题，展示提问的格式：

> ❓ **Q1 - 超时时长**：超时时长固定为 30 分钟，还是要做成可配置？
>
> ➡️ 推荐：做成配置项，默认 30 分钟，这次不提供按商品单独配置的能力。
>
> ---
>
> ❓ **Q2 - 支付中的订单**：用户已经发起支付、但还没收到支付回调的订单，超时后要不要取消？
>
> ➡️ 推荐：不取消，记录告警，交给现有的支付对账任务处理。取消一个可能已经扣款的订单，后果比多锁一会儿库存严重。
>
> ---
>
> ❓ **Q3 - FEAT 拆分**：这个需求拆成 FEAT-001（超时自动取消）和 FEAT-002（取消后释放库存），分别归属 order-service 和两个服务，是否同意？
>
> ➡️ 推荐：同意。

"库存释放失败怎么办"依赖 Q2 的答案（哪些订单会被取消），所以留到第二轮才问。

## 值得注意的地方

- **全局与各服务分工**：治理仓的全局 spec 只写 FEAT 分配、范围和跨服务契约变更；各服务的 FR 条目写在各自仓库的 spec 里，两边不互相复制。
- **FR 编号**：order-service 的新增条目接续现状规格 SPEC-ORDER-001 的既有编号（FR-005 起）；inventory-service 首次触达"库存锁定与释放"能力，新建 SPEC-INVENTORY-001 从 FR-001 起编。测试代码用 `[FR-xxx]` 标注关联。
- **布局说明**：示例的服务仓按未接入布局（扁平 specs/ + changes/）演示人工流程和跨服务编排；接入研发云数字员工后，服务仓布局切换为 `docs/specs/SPEC-<域>-<NNN>/` 三件套（见[团队 SDD 规范](../../../standard.md)第 5 章），治理仓部分不变。
- **"不做"一节**：明确排除了取消通知和支付对账，防止 AI 顺手实现。
- **测试接缝**：两个服务的接缝各自写明了验证方式、能发现和发现不了什么，reviewer 能判断覆盖是否够用。
- **降级验证**：inventory-service 没有可运行的测试，spec 里事先声明了库存释放接口用 `verify/stock-release.sh` 验证，并写明了它发现不了"并发重复请求"。
- **目标版本**：spec 头部写明 6.11.1，design.md 的服务影响矩阵写明两个服务的目标分支都是 `develop-v6.11.1`。
- **任务按行为切分**：每个任务交付一段可以单独验证的行为，而不是"先写 DAO 再写 Service"。
- **跨服务依赖**：order-service 的 T4 被 inventory-service 的 T1 阻塞，和 design.md 里"先发库存服务"的上线顺序一致；合并时按上线顺序做批次核对。
- **预重构排在最前**：T2 先把订单状态变更收拢到一处，后面的 T3 才好实现。
- **关键决策写了理由**：为什么用本地待办表重试，而不是引入 MQ。
