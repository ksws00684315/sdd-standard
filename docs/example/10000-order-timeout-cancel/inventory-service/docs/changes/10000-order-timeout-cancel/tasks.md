# 10000 inventory-service 任务

- 全局 spec：`governance:10000-order-timeout-cancel`（治理仓 `changes/10000-order-timeout-cancel/spec.md`，真实项目中可以再附 GitLab 文件链接）

## T1 库存释放接口，按订单号幂等

- 交付行为：调用 `POST /stock/release` 后，该订单锁定的库存全部释放，返回 `released=true`；同一订单重复调用时不再释放，返回 `released=false`
- 覆盖需求：FR-001、FR-002
- 被阻塞于：无
- [ ] 已完成

## 收尾

- [ ] 新建 `docs/specs/stock-lock.md`（SPEC-INVENTORY-001），FR-001、FR-002 落库，登记到索引和治理仓能力索引；FEAT 映射表已同步
- [ ] `docs/api/` 的 OpenAPI 已更新（新增 `POST /stock/release`），接口文档平台已同步
- [ ] 需求全部上线后移到 `docs/changes/archive/<年份>/`
