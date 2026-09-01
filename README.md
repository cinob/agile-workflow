# agile-workflow

Claude Code 插件：契约先行的敏捷开发工作流，5个子agent覆盖项目管理、前后端实现、代码审查、测试全流程。

## 特点

- **契约先行**：涉及新接口的需求，前端先设计接口类型（`DRAFT → CONFIRMED`），后端照实现，避免前后端互相等待或返工
- **按需求维度审查**：不是分别审查前端/后端代码，而是把一个需求的前后端改动放在一起看，专门检查接口字段、错误码、边界情况的一致性
- **Sprint中途分诊**：开发过程中冒出的bug/新需求，自动判断是否阻断当前Sprint、要不要打断插入，不会让Sprint范围悄悄膨胀
- **自动初始化**：进入新项目自动检查/创建 `docs/` 目录骨架，`setup-agile-workflow` skill 会先探索项目结构（monorepo/契约方式/测试框架）再问你确认，不会瞎猜

## 包含的 Agent

| Agent | 职责 |
|---|---|
| `agile-pm` | 需求拆解、优先级排序、Sprint 分期与收尾、Sprint中途的bug/新需求分诊 |
| `frontend-dev` | Vue3 + TypeScript 实现，涉及新接口先输出契约 |
| `backend-dev` | Node.js 实现，严格按已确认的契约实现接口 |
| `code-reviewer` | 全栈代码审查（只读），按需求维度整体检查前后端一致性 |
| `test-writer` | 前后端测试编写与运行 |

外加一个 `setup-agile-workflow` skill（探索式初始化项目约定）和一个 `SessionStart` hook（自动检查/创建 `docs/` 骨架文件）。

## 安装

```
/plugin marketplace add cinob/agile-workflow
/plugin install agile-workflow@agile-workflow
```

安装后重启或新开一个会话，`SessionStart` hook 会自动检查当前项目是否已有 `docs/backlog.md` 等骨架文件，没有会自动创建。

## 使用

不需要记命令，直接用自然语言，5个agent会根据你说的话自动被委派：

```
配置一下敏捷开发工作流
    → setup-agile-workflow 探索项目结构，确认后写入 docs/agents/agile-config.md

用户登录功能，需要记住登录状态7天
    → agile-pm 拆解需求，写入 docs/backlog.md

开始 Sprint 1
    → agile-pm 生成 docs/sprints/sprint-01.md

实现登录接口的前端部分
    → frontend-dev（涉及新接口会先出契约，等确认后再实现UI）

实现登录接口的后端部分
    → backend-dev（照 CONFIRMED 的契约实现）

审查一下这个需求
    → code-reviewer（按需求维度整体审查，只读）

补一下测试
    → test-writer

结束本期
    → agile-pm 核实完成情况，写入 CHANGELOG

发现一个bug，登录接口偶尔返回500
    → agile-pm 分诊：阻断当前Sprint就直接处理，不阻断就记入backlog

也可以显式点名：
用 code-reviewer 检查一下这次改动
```

## 工作流程

```
setup-agile-workflow（一次性）
        │
        ▼
   agile-pm 拆解需求 ──→ docs/backlog.md
        │
        ▼
   agile-pm 开工一期 ──→ docs/sprints/sprint-N.md
        │
        ├─ 需求涉及新接口：frontend-dev 先出契约（DRAFT）→ 人工确认（CONFIRMED）
        │
        ├─ backend-dev 照契约实现 ─┐
        ├─ frontend-dev 实现UI ────┤  可并行
        │                          │
        ▼                          ▼
   code-reviewer 按需求整体审查（只读）
        │
        ▼
   test-writer 编写并运行测试
        │
        ▼
   agile-pm 收尾一期 ──→ docs/CHANGELOG.md
        │
        └─ Sprint中途冒出bug/新需求 → agile-pm 分诊，决定是否插入当前Sprint
```

## 目录结构（安装后在你项目里生成）

```
docs/
  backlog.md              全部需求，按优先级/依赖排期
  sprints/sprint-N.md     当前迭代工作单
  contracts/<feature>.ts  接口契约（DRAFT → CONFIRMED → IMPLEMENTED）
  agents/agile-config.md  项目约定（目录结构/契约方式/测试框架），由 setup-agile-workflow 生成
  CHANGELOG.md            每期收尾总结
```

## 关键设计约束

- `agile-pm` 只负责计划与状态管理，不写代码
- 契约文件的结构变更必须走"提出建议 → 确认 → 修改"，`backend-dev` 不能私自改契约
- `code-reviewer` 只读；若审查中发现范围外的bug，只报告不修改
- `test-writer` 不修改被测试的业务代码；在 sprint 文件里只能做"打勾"这一项修改
- 新需求默认不自动插入当前Sprint，避免范围蔓延；紧急情况需用户明确确认插入

## License

MIT
