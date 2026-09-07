# Changelog

本文件记录 `agile-workflow` 插件自身的版本变化。

## [2.0.0] - Unreleased

### Changed

- 将工作流重构为轻量 MVP 编排：先列功能模块，再由用户按 Must / Should / Could 确定优先级。
- 目标项目只维护 `docs/backlog.md` 和 `docs/sprints/sprint-N.md` 两类工作流文档。
- “开始一期”改为先展示一次执行摘要；用户确认后自动调度实现、代码审查和测试。
- 前后端 Agent 改为技术栈无关，并仅在依赖满足、修改范围互斥时并行。
- 代码审查和测试改为强制串在实现之后，并支持有限次数的自动返修。
- 所有子 Agent 使用结构化结果回报，主线程明确显示启动、并行、完成和阻塞状态。

### Removed

- 移除 Roadmap、业务版本、里程碑、故事点、容量、缓冲、Velocity 和 Sprint 2A/2B 机制。
- 移除 `DRAFT → CONFIRMED → IMPLEMENTED/MISMATCH` 契约文档状态机。
- 移除 SessionStart 自动建目录、建文档和版本比较 Hook。
- 移除 `setup-agile-workflow` 及 `docs/agents/agile-config.md` 项目应用版本追踪。
- 移除前端 Vue 3 / TypeScript 和后端 Node.js 的硬编码限制。

### Migration

- 2.0.0 不会自动删除或重写旧项目中的 Roadmap、Changelog、契约和配置文档。
- 重新规划功能时会展示精简 Backlog 草稿，只有用户确认后才迁移 `docs/backlog.md`。
- 更新插件后需要启用并重启 Claude Code 会话，才能加载新的 Skill 和 Agent。

## [1.2.0] - 2026-09-07

### Added

- 增加总体 Roadmap、业务版本和里程碑的逐层确认流程。
- 增加 Fibonacci 故事点、Sprint 容量、缓冲和超载门禁。
- 支持按业务里程碑将 Sprint 拆分为 `2A` / `2B` 等正式验收边界。
- SessionStart 显示插件版本并比较项目应用版本。
