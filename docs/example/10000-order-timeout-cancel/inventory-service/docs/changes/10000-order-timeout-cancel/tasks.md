# 10000 inventory-service 任务

- 主 spec：`order-service:10000-order-timeout-cancel`（真实项目中可以再附 GitLab 文件链接）

## T1 库存释放接口，按订单号幂等

- 交付行为：调用 `POST /stock/release` 后，该订单锁定的库存全部释放，返回 `released=true`；同一订单重复调用时不再释放，返回 `released=false`
- 覆盖需求：R2、R4
- 被阻塞于：无
- [ ] 已完成

## 收尾

- [ ] `docs/specs/` 已更新，并追加了变更记录（`stock-lock.md`：新增按订单释放的规则）
- [ ] 接口文档平台已同步（新增 `POST /stock/release`）
- [ ] 需求全部上线后移到 `docs/changes/archive/<年份>/`
