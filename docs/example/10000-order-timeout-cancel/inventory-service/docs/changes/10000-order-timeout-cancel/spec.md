# 10000 订单超时未支付自动取消（inventory-service）

- 需求单：<示例，无链接>
- 档位：L4
- 目标版本：6.11.1
- FEAT：FEAT-002（取消后释放锁定的库存）
- 涉及服务：order-service、inventory-service；全局 spec 见 `governance:10000-order-timeout-cancel`
- 需求负责人：@zhangsan
- 状态：已确认（记录在治理仓全局 spec）

## 背景

订单因超时被取消后需要释放锁定的库存，本服务提供按订单号幂等的释放接口。

## 范围

- 新增 `POST /stock/release` 接口，释放指定订单锁定的全部库存。

## 不做

- 不改变现有的库存锁定和用户主动取消时的释放逻辑。

## 需求与验收条件

<!-- 本需求首次触达"库存锁定与释放"能力，新建现状规格 SPEC-INVENTORY-001，条目从 FR-001 起编。 -->

- **FR-001**（FEAT-002）WHEN 收到订单取消发起的库存释放请求，THE SYSTEM SHALL 释放该订单锁定的全部库存，并返回 `released=true`。
- **FR-002**（FEAT-002）IF 同一订单的库存释放请求重复到达，THE SYSTEM SHALL 只释放一次，返回 `released=false`，HTTP 状态仍为 200。

## 非功能要求

- 释放接口幂等，重复调用无副作用。

## 测试接缝

| 接缝 | 覆盖的 FR | 验证方式 | 能发现 | 发现不了 |
|---|---|---|---|---|
| inventory-service 的库存释放接口 | FR-001、FR-002 | 降级验证：inventory-service 没有可运行的测试，用 `verify/stock-release.sh` 对本地启动的服务发请求并断言 | 释放的数量、重复请求只释放一次 | 订单服务是否真的发起了调用；并发重复请求 |

## 待确认问题

无。

## 变更记录

| 日期 | 改了什么 | 原因 | 确认人 |
|---|---|---|---|
