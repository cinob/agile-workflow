---
name: setup-agile-workflow
description: 配置本仓库的敏捷开发技术约定——探索项目结构、确认目录/契约/测试框架，写入 docs/agents/agile-config.md。当配置文件不存在、工作流应用版本不一致，或用户明确要求初始化/重新配置敏捷开发工作流时使用；业务 Roadmap、版本和里程碑由 agile-pm 另行与用户制定。
---

# 配置敏捷开发工作流

这是一个**探索式、非确定性**的 Skill：先探索仓库现状，呈现发现，逐节请用户确认，最后才写文件。不要跳过探索、不要不问就按默认值生成——除非探索已经能确定答案。

本 Skill 只配置技术协作约定，不制定业务版本、里程碑、故事点、Sprint 容量或发布时间。这些内容由 `agile-pm` 在总体规划中与用户逐层确认，避免出现两个规划来源。

## 0. 读取工作流版本

开始探索前，读取 `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json` 的顶层 `version`，它是当前插件版本的唯一事实来源；不要从 README、Git、Marketplace 或目录名推断版本。

同时读取现有 `docs/agents/agile-config.md` 文件开头第一个 frontmatter 中的：

```yaml
agile-workflow-applied-version: "<version>"
```

该字段表示“这个项目上次经用户确认应用技术配置时使用的工作流版本”，不是项目的业务版本，也不是当前插件版本源。

- 当前插件版本和项目应用版本一致：正常继续探索。
- 不一致：先说明旧记录和当前版本，但不要把“不一致”等同于必须迁移；仍需完成探索、展示草稿并等待确认。
- 旧配置没有该字段：说明这是未记录应用版本的旧配置，不自动插入字段。
- 当前插件版本读取失败：可以继续配置，但不要写入 `unknown`、`未知` 或空版本；新文件省略该字段，旧文件保留原字段，并在完成时提示本次无法更新应用版本。

只有“完整草稿已展示 → 用户明确确认 → 实际写入 agile-config”这一流程可以更新项目应用版本。SessionStart、插件安装/更新和普通 Agent 读取都不能更新它。

## 1. 探索

实际检查，不要假设：

- `docs/backlog.md`、`docs/roadmap.md`、`docs/agents/agile-config.md` 是否存在。
  - `agile-config.md` 已存在：本次是重新配置，需说明只更新用户确认过的技术约定，不覆盖规划文档。
  - 读取现有配置的完整内容，保留模板之外的用户自定义章节；除非完整草稿明确展示删除且用户确认，否则不得丢弃。
  - `roadmap.md` 为 `UNINITIALIZED`：只表示空骨架，不代表已有总体规划。
  - Roadmap 已确认或存在未关闭 Sprint：只读取用于识别现状，不修改其中的业务内容。
- 现有 Sprint 文件如何命名：兼容 `sprint-1.md`、`sprint-01.md`、`sprint-02a.md` 等，不强制重命名历史文件。
- Monorepo 信号：`pnpm-workspace.yaml`、`package.json` 的 `workspaces`、顶层是否有 `frontend/`、`backend/` 或类似目录。
- 前端实际路径与框架：寻找 `vite.config.ts`、`package.json` 里的 `vue` / `vue-tsc` 等依赖。
- 后端实际路径与框架：检查 Express、Koa、Nest、Fastify 等依赖和入口。
- 现有测试框架：检查 Vitest、Jest、`node:test` 等依赖或测试文件。
- 契约现状：`docs/contracts/`、OpenAPI/Swagger 或团队已有的其他接口约定；发现既有方式时不要覆盖习惯。

## 2. 呈现发现并逐节确认

每节先给出基于探索的推荐答案和理由，让用户可以直接接受；只有结果有歧义时才展开选项。每节一次只确认一个主题。

### A. 目录结构

说明仓库类型和前后端实际路径，例如：

> 检测到 `frontend/`、`backend/` 两个顶层目录，判断为前后端分离的单仓库，前端路径为 `frontend/src`，后端路径为 `backend/src`——确认吗？

### B. 契约存放方式

默认推荐：`docs/contracts/<feature>.ts`，前端先设计类型，状态按 `DRAFT → CONFIRMED → IMPLEMENTED` 流转。

若发现项目已有 OpenAPI、Swagger 或其他接口文档方式，如实呈现，询问是否沿用该来源，不替用户决定，也不另建并行契约体系。

### C. 测试框架

- 前端：探索结果能确定时直接采用，例如 Vitest。
- 后端：已有框架则沿用；未发现时询问用户，默认建议 `node:test`，避免无必要地引入依赖。

## 3. 确认完整草稿

写入前展示 `docs/agents/agile-config.md` 的完整草稿，给用户一次整体修改机会。草稿只包含技术约定，不包含 Roadmap、业务目标或容量。

当前插件版本读取成功时，草稿顶部必须包含：

```markdown
---
agile-workflow-applied-version: "<当前 plugin.json 版本>"
---
```

并明确说明：用户确认并写入后，该字段会更新为本次应用的插件版本。若旧配置版本与当前版本不同，同时展示旧值和即将写入的新值。

当前插件版本读取失败时：

- 新建配置草稿不包含该字段。
- 更新旧配置时原样保留已有版本元数据。
- 不使用占位值冒充版本。

## 4. 写入技术配置和缺失骨架

用户确认完整草稿后：

1. 确保 `docs/agents/` 目录存在，写入或原地更新 `docs/agents/agile-config.md`。
2. 当前插件版本读取成功时，写入/更新 `agile-workflow-applied-version` 为当前版本；这一步与用户确认的完整草稿同时发生。
3. 保留未被本次确认修改的用户自定义章节和字段。
4. 逐项检查并只补建缺失的骨架：
   - `docs/backlog.md`
   - `docs/roadmap.md`，仅写 `UNINITIALIZED` 空骨架
   - `docs/CHANGELOG.md`
   - `docs/sprints/`
   - `docs/contracts/`
5. 已存在的 Backlog、Roadmap、Sprint、契约和 Changelog 一律不覆盖、不重排、不迁移。
6. 若 Hook 已经创建过骨架，直接跳过。
7. 不把旧 Sprint 强制改名为补零或字母后缀；Roadmap 后续通过精确路径引用现有文件。

`docs/agents/agile-config.md` 模板：

```markdown
---
agile-workflow-applied-version: "<当前 plugin.json 版本>"
---

# 敏捷工作流配置

> 由 setup-agile-workflow 生成，agile-pm / frontend-dev / backend-dev / code-reviewer / test-writer 均读取本文件。
> 只有目录结构、契约方式或测试框架改变时才需要重新运行本 Skill。
> 业务 Roadmap、版本、里程碑和 Sprint 容量不在此文件维护。

## 目录结构

（Monorepo / 前后端分离单仓库 / 单体，以及各自实际路径）

## 契约存放方式

（`docs/contracts/<feature>.ts`，或团队既有 OpenAPI/其他方式及其路径）

## 测试框架

- 前端：
- 后端：
```

Roadmap 空骨架只能表达：

```markdown
# Roadmap

> 状态：UNINITIALIZED
> 版本目标、业务里程碑、故事点、Sprint 和容量必须由 agile-pm 与用户逐层确认后写入。
```

不要在初始化阶段替用户填充版本或里程碑。

## 5. 完成

告知用户：

- 技术配置已完成，五个 Agent 之后会自动读取，不必重复说明项目结构。
- 当前插件版本和写入的项目应用版本；若版本读取失败，明确说明本次未更新应用版本记录。
- 之后 SessionStart 会比较当前插件版本和该项目上次应用版本；不一致时只提示，不自动迁移。
- 小型需求可以直接进入 Backlog。
- 大型、跨多个业务阶段或 Sprint 的项目，建议下一步对 Claude 说“为这个项目制定总体规划”，由 `agile-pm` 逐层讨论版本目标、业务里程碑、故事点、容量和 Sprint 划分。
