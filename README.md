# agile-workflow

Claude Code 插件：契约先行、业务目标驱动的敏捷开发工作流。5 个子 Agent 覆盖总体规划、项目管理、前后端实现、代码审查和测试全流程。

## 特点

- **总体规划先行**：大型项目先讨论业务阶段、版本目标和里程碑，再拆成 Backlog 和多个 Sprint
- **逐层人工确认**：版本目标、非目标、里程碑、故事点、容量和 Sprint 划分由 Agent 提建议，用户逐层确认；最终确认前不写入业务规划
- **按业务闭环排期**：不按页面数量机械平均，使用可独立验收的业务条目和故事点规划每期范围
- **容量门禁**：每个 Sprint 记录总容量、缓冲、可承诺容量和已规划点数，超载时必须裁剪、顺延或重规划
- **里程碑驱动拆分**：业务里程碑落在 Sprint 中间时，可拆为 `Sprint 2A / 2B`，让里程碑成为正式收尾验收边界
- **契约先行**：涉及新接口时，前端先设计接口类型（`DRAFT → CONFIRMED`），后端照已确认契约实现
- **按需求维度审查**：把一个需求的前后端改动放在一起审查，重点检查接口字段、错误码和边界情况的一致性
- **Sprint 中途分诊**：开发中冒出的 bug/新需求先判断是否阻断，再结合缓冲和里程碑影响决定是否插入
- **自动初始化**：进入新项目自动补建 `docs/` 骨架，已有文件不覆盖；`setup-agile-workflow` 会先探索技术结构再请用户确认

## 包含的 Agent

| Agent | 职责 |
|---|---|
| `agile-pm` | 总体规划、版本/里程碑讨论、需求拆解、故事点与容量规划、Sprint 分期/拆分、紧急事项分诊和收尾 |
| `frontend-dev` | Vue 3 + TypeScript 实现，涉及新接口时先输出契约 |
| `backend-dev` | Node.js 实现，严格按照已确认契约开发接口 |
| `code-reviewer` | 全栈代码审查（只读），按需求维度检查前后端一致性、范围和里程碑证据 |
| `test-writer` | 前后端测试编写与运行，提供业务验收证据 |

外加：

- `setup-agile-workflow` Skill：探索并配置项目的目录、契约和测试框架约定
- `SessionStart` Hook：幂等检查并补建 `docs/` 骨架文件

## 安装

```text
/plugin marketplace add cinob/agile-workflow
/plugin install agile-workflow@agile-workflow
```

安装后重启或新开会话，`SessionStart` Hook 会逐项检查并补建缺失的规划文件和目录，不覆盖已有内容。

## 插件版本与项目配置

插件当前版本以 `.claude-plugin/plugin.json` 为唯一事实来源。每次 SessionStart 都会显示实际加载版本：

```text
[agile-workflow vX.Y.Z] 已就绪
```

`setup-agile-workflow` 经用户确认写入技术配置时，会在 `docs/agents/agile-config.md` 顶部记录该项目上次应用的工作流版本：

```yaml
---
agile-workflow-applied-version: "X.Y.Z"
---
```

SessionStart 会比较当前插件版本与项目应用版本：

- 一致：明确显示“项目配置版本一致”。
- 不一致：显示两个版本并建议按需重新运行 setup，但不会自动修改或迁移项目文件。
- 旧配置没有版本：提示尚未记录，不自动补写。
- 当前插件版本读取失败：显示 `v未知`，跳过比较，不影响骨架初始化。

只有重新运行 `setup-agile-workflow`、查看完整草稿并确认写入后，项目应用版本才会更新。也可以使用 `/plugin list` 查看 Claude Code 当前安装的插件版本。

仓库根目录的 `CHANGELOG.md` 是插件自身的发布日志；目标项目中的 `docs/CHANGELOG.md` 是各 Sprint 的业务交付记录，两者用途不同。

## 快速使用

不需要记命令，直接使用自然语言，Agent 会根据意图自动接手：

```text
配置一下敏捷开发工作流
    → setup-agile-workflow 探索项目结构，确认后写入 docs/agents/agile-config.md

我要实现一个商城，包含商品、购物车、结算、支付、订单等 10 个页面，先做总体规划
    → agile-pm 逐层讨论版本目标、业务里程碑、故事点、容量和 Sprint 划分

用户登录功能，需要记住登录状态 7 天
    → agile-pm 拆解局部需求，写入 docs/backlog.md

开始 Sprint 2A
    → agile-pm 按 Roadmap 和容量门禁生成 docs/sprints/sprint-02a.md

实现登录接口的前端部分
    → frontend-dev 先定义契约；确认后可基于 mock 开发 UI

实现登录接口的后端部分
    → backend-dev 按 CONFIRMED 契约实现

审查一下这个需求
    → code-reviewer 按需求维度整体审查，只读不修改

补一下测试
    → test-writer 编写并实际运行测试

结束本期
    → agile-pm 核实产物、审查和测试，更新 Roadmap 与 CHANGELOG；业务里程碑仍需用户确认

发现一个 bug，登录接口偶尔返回 500
    → agile-pm 分诊并计算缓冲；不足时要求等量换出或重规划
```

也可以显式点名：

```text
用 code-reviewer 检查一下这次改动
```

## 工作流程

```text
setup-agile-workflow（一次性技术配置）
        │
        ▼
agile-pm 总体规划（大型项目）
        │
        ├─ 业务阶段 / 版本目标 / 非目标 ──→ 用户确认
        ├─ 业务里程碑 / 验收条件 ─────────→ 用户确认
        ├─ 业务切片 / 故事点 ─────────────→ 用户确认
        ├─ 容量 / 缓冲 / Sprint 划分 ─────→ 用户确认
        └─ 完整草稿最终确认 ──────────────→ docs/roadmap.md + docs/backlog.md
        │
        ▼
agile-pm 开工一期 ──→ docs/sprints/sprint-<id>.md
        │
        ├─ 新接口：frontend-dev 出契约（DRAFT）→ 人工确认（CONFIRMED）
        │
        ├─ backend-dev 按契约实现 ─┐
        ├─ frontend-dev 基于契约实现 UI ─┤ 可并行
        │                              │
        ▼                              ▼
code-reviewer 按需求整体审查（只读）
        │
        ▼
test-writer 编写并运行测试
        │
        ▼
agile-pm 收尾 ──→ Roadmap 状态 + docs/CHANGELOG.md
        │
        ├─ 若为里程碑边界：用户确认业务验收
        └─ 中途 bug/新需求：使用缓冲、等量换出或受控重规划
```

## 总体规划：从页面列表到业务版本

当用户提出“实现一个有 10 个页面的商城”时，`agile-pm` 不会简单地安排“每期 3 个页面”，而是先识别业务闭环，例如：

| 版本/阶段 | 业务目标 | 可能包含的页面与能力 |
|---|---|---|
| V1 商品浏览 | 用户能够发现并了解商品 | 首页、分类、商品列表、商品详情 |
| V2 购物决策 | 用户能够选择商品并准备结算 | 登录、购物车、收货地址、结算 |
| V3 交易闭环 | 用户能够付款并查看交易结果 | 支付、支付结果、订单列表/详情 |

具体版本名称、成功条件、非目标和里程碑都只是 Agent 的建议，必须由用户逐层确认。

确认顺序为：

```text
业务阶段和版本目标
    ↓ 用户确认
业务里程碑和验收条件
    ↓ 用户确认
可独立验收的业务条目和故事点
    ↓ 用户确认
容量、缓冲和 Sprint 划分
    ↓ 用户确认
完整 Roadmap 最终预览
    ↓ 用户明确确认
写入 Roadmap 和 Backlog
```

修改上游版本目标后，受影响的里程碑、估算和 Sprint 划分需要重新确认，不能只局部改一句话。

## 故事点与容量

故事点使用 Fibonacci 序列：

```text
1 / 2 / 3 / 5 / 8 / 13
```

故事点只计算可独立验收的父业务条目，不给 `[FE]`、`[BE]`、`[TEST]` 重复计点。大于 8 点的条目优先继续拆分。

每个 Sprint 记录：

```text
总容量
- 缓冲
= 可承诺容量
```

并强制满足：

```text
已规划点数 <= 可承诺容量
```

初次没有历史速度时，Agent 会根据团队人数、可用时间和并行限制提出临时容量建议，用户确认后标记为 `PROVISIONAL`。缓冲可以建议为总容量的 15%–20%，但不会自动替用户决定。

## 业务里程碑落在 Sprint 中间

如果原计划有 5 个 Sprint，但关键业务验收节点落在 Sprint 2 的中间，工作流不会使用模糊的 “Sprint 1.5”，而是建议：

```text
Sprint 1
    ↓
Sprint 2A —— 完成业务里程碑 M1，并正式收尾验收
    ↓
Sprint 2B —— 继续里程碑后的工作
    ↓
Sprint 3 ...
```

对应文件为：

```text
docs/sprints/sprint-02a.md
docs/sprints/sprint-02b.md
```

拆分前必须先拆开跨边界的大任务，再重新确认 2A/2B 的容量和缓冲。原工作单若已经存在会保留并标记 `SPLIT` 或 `SUPERSEDED`，不会删除历史。

## 契约先行

涉及新接口的父业务条目标记 `[NEEDS-API]`：

1. `frontend-dev` 根据验收标准定义 endpoint、method、request/response 类型和错误码。
2. 写入契约，状态为 `DRAFT`，并停下等待确认。
3. 用户或主线程确认后改为 `CONFIRMED`。
4. `backend-dev` 只在契约为 `CONFIRMED` 时开始实现，不能私自修改契约。
5. 前端可基于已确认契约使用 mock 数据继续 UI，实现不必等待后端。
6. 联调发现偏差时标记 `MISMATCH`，不能静默兼容。

## Sprint 中途分诊

- **阻断当前任务的 bug**：视为当前任务的一部分，先消耗缓冲；若影响里程碑则进入重规划。
- **非阻断普通 bug**：默认写入 Backlog，不触碰当前 Sprint。
- **新需求**：默认进入后续规划，不自动扩大当前版本或 Sprint。
- **明确要求紧急插入**：记录点数，先用缓冲；缓冲不足时移出等量未开始工作，或将 Roadmap 标记为 `NEEDS_REPLAN` 后重新确认。

## 目录结构（安装后在目标项目生成）

```text
docs/
  roadmap.md              总体规划：版本、业务里程碑、Sprint 映射和容量
  backlog.md              具体业务条目：优先级、依赖、故事点和规划映射
  sprints/
    sprint-01.md          普通 Sprint 工作单
    sprint-02a.md         里程碑驱动的子 Sprint 工作单
  contracts/<feature>.ts  接口契约（DRAFT → CONFIRMED → IMPLEMENTED / MISMATCH）
  agents/agile-config.md  项目技术约定，由 setup-agile-workflow 生成
  CHANGELOG.md            每期实际交付、延期、容量和里程碑结果
```

核心状态：

```text
Roadmap：UNINITIALIZED → CONFIRMED → ACTIVE → COMPLETED
                              ↘ NEEDS_REPLAN

里程碑：PLANNED → ACTIVE → ACCEPTED
                         ↘ AT_RISK / DEFERRED

Sprint：PLANNED → ACTIVE → CLOSED
                      ↘ SPLIT / SUPERSEDED
```

## 向后兼容

- 没有 Roadmap 的旧项目仍可继续处理小需求和纯数字 Sprint。
- 已有 `sprint-1.md` 不要求重命名。
- 新工作单统一推荐补零，并支持字母后缀。
- 已完成的 Backlog 和 Changelog 历史不会因引入 Roadmap 被重写。
- 信息不足的旧任务标记为“待映射/待估算”，不会由 Agent 静默猜测。

## 关键设计约束

- `agile-pm` 只负责业务规划和状态管理，不写实现代码，也不替用户决定版本目标或业务验收结果。
- 最终确认前，不写入版本、里程碑、故事点和 Sprint 映射。
- 契约结构变更必须走“提出建议 → 确认 → 修改”，`backend-dev` 不能私自改契约。
- `code-reviewer` 只读；发现范围外问题只报告，不修改。
- `test-writer` 不修改业务代码；在 Sprint 文件中只能勾选测试通过项。
- 测试通过只是业务验收证据，不等于里程碑自动 `ACCEPTED`。
- 新需求默认不插入当前 Sprint；紧急插入必须量化容量和里程碑影响。

## License

MIT
