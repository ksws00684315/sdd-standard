# 术语表索引

各服务的术语表放在服务仓库里，这里只登记位置和服务之间的术语对应关系。维护规则见 `skills/sdd-domain/SKILL.md`。

## 服务

| 服务 | 术语表 | 说明 |
|---|---|---|
| smartmanage-device | `smartmanage-device/GLOSSARY.md` | 设备域核心服务：绑定、状态/详情聚合、共享、AI 能力 |
| smartmanage-device-common | `smartmanage-device-common/GLOSSARY.md` | 设备域公共库：类型中心、设备分类规则 |
| smartmanage-ds-home | `smartmanage-ds-home/GLOSSARY.md` | 首页数据服务：设备列表编排、核心设备、过滤标签 |
| smartmanage-third | `smartmanage-third/GLOSSARY.md` | 统一外部 HTTP 出口：外部服务门面与外部平台清单 |

## 服务关系

<!-- 同一个概念在不同服务里叫法不同，或者同一个词在不同服务里含义不同时，记在这里。 -->

- device 的**设备（Device）**是归属与状态层面的概念；ds-home 的**核心设备（Core Device）**是首页呈现层面的子集概念，由提取策略从设备集合中选出。
- device 的**绑定/共享**描述设备与用户的归属授权；ds-home 的**首页设备用户关系**只服务首页展示语境，两者是不同的数据，不要混用。
- device 的**品类（Category）**由 device-common 的**类型中心（Type Center）**提供判定能力；分类规则冲突时以类型中心为准。
- third 不定义业务语义：外部平台的设备、场景等概念（如 AIoT 平台返回的数据）必须在业务侧（device、ds-home 等）转换为本项目术语后才可使用。
