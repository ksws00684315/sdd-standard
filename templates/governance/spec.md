# 主 spec

<!-- 治理仓的系统主 spec：只存 FEAT 映射表和能力索引，不写功能需求正文（集团《SDD开发规范》§7.1）。 -->
<!-- FR 的新增、修改、删除随服务仓的 MR 同步更新本表；能力文件的新建、拆分同步更新能力索引。 -->

## FEAT 映射表

<!-- 粒度到 FR；跨服务引用写全限定号 [SPEC-<域>-NN/FR-xxx]。 -->

| FEAT | 需求单号 | Spec / FR | 服务 |
|---|---|---|---|
| FEAT-001 | 10000 | [SPEC-ORDER-001/FR-001] | order-service |
| FEAT-002 | 10000 | [SPEC-INVENTORY-001/FR-001] | inventory-service |

## 能力索引

<!-- 各服务的现状规格清单，服务接入或新建能力文件时同步。 -->

| Spec ID | 能力 | 服务 | 文件 |
|---|---|---|---|
| SPEC-ORDER-001 | 订单状态流转 | order-service | `order-service/docs/specs/SPEC-ORDER-001/spec.md` |
| SPEC-INVENTORY-001 | 库存锁定与释放 | inventory-service | `inventory-service/docs/specs/SPEC-INVENTORY-001/spec.md` |
