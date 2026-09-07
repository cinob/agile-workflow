# agile-workflow

Claude Code 轻量敏捷编排插件：先确认什么最重要，再用独立子 Agent 自动完成实现、审查和测试。

它面向个人开发者和小团队，不复刻企业 Scrum 仪式。目标是让一个产品尽快形成可验证的核心闭环，而不是先生成大量 Roadmap、里程碑、故事点和容量表格。

## 核心思路

1. **先列功能模块**：从用户要解决的问题出发，不按页面数量拆计划。
2. **再定重要程度**：用户一次性把模块归入 Must / Should / Could（必要 / 次要 / 更次要）。
3. **优先最小闭环**：Must 尚未完成时不夹带附加功能，除非它是真实依赖。
4. **只确认一次执行范围**：开始一期时先看任务摘要，确认后不再逐阶段打断。
5. **真实调用子 Agent**：前后端在安全时并行，之后依次代码审查和测试。
6. **只保留两类文档**：Backlog + 当前/历史 Sprint 工作单。

## 一个衣橱小程序应该怎样排

插件会先识别产品核心，而不是把所有想法平均铺开：

| 级别 | 示例模块 | 判断依据 |
|---|---|---|
| Must | 衣物录入、持久化、衣橱浏览筛选、详情编辑删除 | 没有这些就不是可用的衣橱管理产品 |
| Should | 基础搭配管理、今日穿搭 | 提升核心体验，但不阻断衣橱管理闭环 |
| Could | 金币、商城、成就、场景装饰、AI 顾问、天气推荐 | 核心价值验证后再投入的附加能力 |

这只是 Agent 的建议，最终级别由用户决定。

## 安装

```text
/plugin marketplace add cinob/agile-workflow
/plugin install agile-workflow@agile-workflow
```

安装或更新后需要新开 Claude Code 会话。

## 快速使用

不需要记专用命令，直接说自然语言。

### 1. 规划功能

```text
帮我规划这个衣橱小程序的功能
```

`agile` Skill 会调用独立的 `agile-pm`，展示：

- 功能模块
- 用户可感知结果
- 真实依赖
- 建议的 Must / Should / Could
- 建议理由

用户可以一次性调整，也可以回复：

```text
按建议分级
```

随后插件给出完整 Backlog 草稿，并只请求一次最终写入确认：

```text
确认写入 Backlog
```

### 2. 开始一期

```text
开始一期
```

插件从未完成 Must 中选择一个最小可交付闭环，展示任务、角色、依赖、验收条件和允许修改范围。确认前不会创建工作单，也不会启动开发 Agent。

确认：

```text
确认执行 Sprint 1
```

确认后自动推进：

```text
主线程写入已确认的 Sprint 工作单
        │
        ├─ frontend-dev ─┐
        └─ backend-dev  ─┴─ 依赖满足且修改范围互斥时并行
                 │
                 ▼
          code-reviewer
                 │ PASS
                 ▼
           test-writer
                 │ PASS
                 ▼
        主线程同步结果
```

实现、审查和测试之间不会重复请求确认。只有产品范围变化、破坏性操作、权限被拒或自动返修两轮仍失败时才暂停询问。

### 3. 继续或结束一期

```text
继续一期
结束一期
```

“继续一期”只执行尚未完成的任务；“结束一期”核对实现、审查和测试证据，只有质量门禁通过时才把 Sprint 标记为已结束。

## 子 Agent 确实是独立上下文

插件包含 5 个 Agent：

| Agent | 职责 |
|---|---|
| `agile-pm` | 只读分析功能模块、优先级、依赖并生成 Backlog/Sprint 草稿 |
| `frontend-dev` | 项目实际技术栈下的客户端、页面与交互实现 |
| `backend-dev` | 项目实际技术栈下的服务端、数据层与接口实现 |
| `code-reviewer` | 只读整体审查：验收、跨端一致性、正确性、安全性和范围 |
| `test-writer` | 沿用现有或平台内置测试能力，补充并实际运行验证 |

每个子 Agent 都是新的独立上下文，只收到主线程传入的 Sprint 目标、任务、依赖、验收标准和文件范围。它们共享同一个工作目录，因此插件只会在修改范围明确互斥时并行写代码。

运行时会明确显示：

```text
[启动] frontend-dev — T2 — src/pages/wardrobe/**
[启动] backend-dev — T1 — server/garments/**
[并行] 两个 Agent 的依赖已满足，修改范围互不重叠
[完成] backend-dev — 局部检查通过
[完成] frontend-dev — 类型检查通过
[启动] code-reviewer — 整体审查 Sprint 1
```

如果没有看到 Agent 启动卡片或这些状态，先检查插件是否启用。

## 并行规则

frontend-dev 与 backend-dev 只有同时满足以下条件才并行：

- 没有未满足的任务依赖。
- 允许修改路径没有交集。
- 不会同时修改共享 schema、OpenAPI、接口类型、数据库迁移、路由总表、包清单、锁文件或根级配置。
- 新接口已经有稳定的项目原生边界。
- 用户现有未提交改动不与任务范围冲突。

无法证明安全时默认串行。并行的目标是缩短等待，不是制造文件冲突。

## 接口边界

插件优先沿用项目已有的 OpenAPI、schema、共享类型或接口约定。

项目还没有稳定接口边界时，会先指定一个 Agent 作为唯一写入者建立最小边界，再启动另一端。不会额外创建 `docs/contracts/`，也没有 `DRAFT → CONFIRMED → IMPLEMENTED/MISMATCH` 状态机。

## 目标项目只生成两类文档

```text
docs/
  backlog.md
  sprints/
    sprint-1.md
    sprint-2.md
```

### Backlog

Backlog 只记录产品结果：

```markdown
## Must

- [ ] B001 衣物录入
  - 用户结果：用户可以创建并保存一件真实衣物。
  - 依赖：无
  - 验收：重新进入应用后仍能看到该衣物。
```

章节表示优先级，条目顺序表示排期。不会记录故事点、容量、版本、里程碑或技术子任务。

### Sprint

Sprint 只记录执行所需信息：

```markdown
- [ ] T1 [BE] 建立衣物保存与读取能力
  - 顺序：1
  - 依赖：无
  - 完成条件：满足 B001 的持久化验收。
  - 允许修改：server/garments/**
```

另有 Review/Test 两个质量门禁和简短结果。不会复制完整日志或在多个文件重复业务说明。

## 插件未生效时

以下命令在系统终端中执行。查看状态：

```bash
claude plugin list
```

如果显示 `disabled`：

```bash
claude plugin enable agile-workflow@agile-workflow
```

更新本地安装副本：

```bash
claude plugin update agile-workflow@agile-workflow
```

然后退出并新开 Claude Code 会话。插件组件只在会话启动时加载，旧会话不会自动获得新 Skill/Agent。

如果自然语言没有触发编排，可使用排障入口：

```text
/agile-workflow:agile 开始一期
```

正常使用不要求记这个命令。

## 从 1.2.0 升级

2.0.0 是破坏性精简：

- 不再读取或更新 Roadmap、业务版本、里程碑、故事点、容量、缓冲和字母子 Sprint。
- 不再运行 SessionStart Hook 自动创建文档。
- 不再使用 `docs/agents/agile-config.md` 追踪项目应用版本。
- 不会自动删除旧项目中的任何文件。
- 旧版 P0/P1/P2 Backlog 不会被静默映射；“开始一期”前会重新确认 Must/Should/Could。
- 旧版 `ACTIVE`、`sprint-01.md` 和字母后缀工作单会被识别，避免产生第二份冲突的活跃 Sprint。
- 重新规划时会先展示精简 Backlog 草稿，只有用户确认后才写入。

`/grill-with-docs` 是另一套会主动创建 ADR 和术语表的访谈 Skill；这些文件不属于 agile-workflow 的最小产物。组合使用时，文档数量会相应增加。

## 设计约束

- 用户决定产品优先级，Agent 只给建议。
- 确认前不写 Backlog，不创建 Sprint，不启动开发 Agent。
- 确认执行后自动完成实现 → 审查 → 测试，不重复确认。
- 只有主线程串行修改 Backlog 和 Sprint；所有子 Agent 都不得改工作流文档。
- 审查未通过时不启动测试。
- 测试暴露生产问题后必须重新审查再重跑。
- 不硬编码 Vue、Node.js 或测试框架，始终沿用项目实际技术栈。
- 不为了“敏捷形式”牺牲产品核心价值。

## License

MIT
