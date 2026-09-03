# Changelog

本文件记录 `agile-workflow` 插件自身的版本变化。目标项目每个 Sprint 的交付记录保存在其 `docs/CHANGELOG.md`，两者互不替代。

## [1.2.0] - Unreleased

### Added

- 增加总体 Roadmap、业务版本和里程碑的逐层确认流程。
- 增加 Fibonacci 故事点、Sprint 容量、缓冲和超载门禁。
- 支持按业务里程碑将 Sprint 拆分为 `2A` / `2B` 等正式验收边界。
- SessionStart 每次显示从 `plugin.json` 读取的当前插件版本。
- `docs/agents/agile-config.md` 记录项目上次经确认应用的工作流版本。
- SessionStart 检测当前插件版本与项目应用版本是否一致；差异只提示，不自动迁移。

### Changed

- 初始化 Hook 改为逐项、幂等地补建 Roadmap、Backlog、Sprint、契约和配置目录骨架。
- 需求拆解、Sprint 开工、紧急插入和收尾流程与 Roadmap、里程碑及容量联动。
- 前端、后端、审查和测试 Agent 支持 `Sprint 2A/2B` 及 Roadmap 精确工作单路径。
- `setup-agile-workflow` 在完整草稿经用户确认后才更新项目应用版本。
