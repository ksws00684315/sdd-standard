# 10000 订单超时未支付自动取消（全局 spec）

- 需求单：<示例，无链接>
- 档位：L4
- 目标版本：6.11.1
- 涉及服务：order-service、inventory-service
- 需求负责人：@zhangsan
- 状态：已确认

## FEAT 分配

| FEAT | 需求点（一句话） | 归属服务 |
|---|---|---|
| FEAT-001 | 订单超时未支付自动取消 | order-service |
| FEAT-002 | 取消后释放锁定的库存，失败重试 | order-service（调用侧）、inventory-service（释放接口） |

## 背景

用户下单时会锁定库存，但部分订单一直不支付，锁定的库存不能卖给其他用户，热门商品经常被误显示为缺货。

## 范围

- 订单创建后超过超时时长（默认 30 分钟）仍未支付的，自动取消。
- 订单因超时被取消后，释放它锁定的库存。

## 不做

- 不给用户发送订单取消通知（另提需求）。
- 不改变用户主动取消订单的现有流程。
- 不处理"已发起支付、未收到回调"的订单，这类订单由现有的支付对账任务处理。
- 不支持按商品或按用户单独设置超时时长。

## 跨服务契约变更

- 新增 inventory-service 的 `POST /stock/release`（按订单号幂等释放），调用方 order-service。要点和兼容性见 `design.md` 的"接口变更"，完整契约落在 `inventory-service/docs/api/api-inventory-service.yaml`。
- 订单侧的条目见 [order-service 的 spec](../../../order-service/docs/changes/10000-order-timeout-cancel/spec.md)，库存侧见 [inventory-service 的 spec](../../../inventory-service/docs/changes/10000-order-timeout-cancel/spec.md)，这里不重复。

## 待确认问题

无。

## 变更记录

| 日期 | 改了什么 | 原因 | 确认人 |
|---|---|---|---|
