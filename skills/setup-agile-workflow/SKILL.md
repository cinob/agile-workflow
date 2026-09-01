---
name: setup-agile-workflow
description: 配置本仓库的敏捷开发工作流——探索项目结构、确认目录约定/契约存放方式/测试框架，写入 docs/agents/agile-config.md。当 agile-pm、frontend-dev、backend-dev 等发现该配置文件不存在时，或用户明确要求"初始化/配置敏捷开发工作流"时使用。
---

# 配置敏捷开发工作流

这是一个**探索式、非确定性**的 skill：先探索仓库现状，呈现发现，逐节请用户确认，最后才写文件。不要跳过探索、不要不问就按默认值生成——除非探索已经能确定答案（见下）。

## 1. 探索

实际去看，不要假设：

- `docs/backlog.md`、`docs/agents/agile-config.md` 是否已存在（存在则本次是"重新配置"而非"首次配置"，需向用户说明将如何处理已有排期）
- monorepo 信号：`pnpm-workspace.yaml`、`package.json` 的 `workspaces` 字段、顶层是否有 `frontend/`、`backend/`（或类似命名）目录
- 前端实际路径与框架：寻找 `vite.config.ts`、`package.json` 里的 `vue`/`vue-tsc` 依赖
- 后端实际路径与框架：`package.json` 里的 express/koa/nest/fastify 等依赖
- 现有测试框架：`package.json` devDependencies 里的 vitest/jest/`node:test` 等
- `docs/contracts/` 目录是否已存在类似约定的文件（说明团队已有自己的契约写法，不要覆盖既有习惯）

## 2. 呈现发现并确认（分节，一节一个问题，能确定的直接跳过不问）

每节**先给出根据探索得出的推荐答案**，让用户能一句话接受，而不是把所有选项平铺开来问。只有探索结果有歧义时才展开选项。

**A. 目录结构**
> 例如："检测到 frontend/、backend/ 两个顶层目录，判断为前后端分离的单仓库（非workspace monorepo），前端路径 frontend/src、后端路径 backend/src——确认吗？"

**B. 契约存放方式**
默认推荐：`docs/contracts/<feature>.ts`，前端先设计类型（DRAFT → CONFIRMED → IMPLEMENTED），后端照实现。
若探索发现项目已有 OpenAPI/Swagger 或其他接口文档习惯，如实呈现，询问是否改用该来源而非新建契约文件——不要替用户决定。

**C. 测试框架**
前端：探索结果通常能直接确定（如 vitest），无需问。
后端：若探索未发现任何测试依赖，询问用户想用什么（默认建议 `node:test`，无需引入新依赖），若已有则直接采用。

## 3. 确认草稿

写入前，向用户展示 `docs/agents/agile-config.md` 的完整内容草稿，给一次修改机会。

## 4. 写入

- `docs/agents/agile-config.md`（内容结构见下），已存在则原地更新，不重复创建
- 若 `docs/backlog.md` 不存在：创建空白骨架（`docs/backlog.md`、`docs/sprints/`、`docs/contracts/`、`docs/CHANGELOG.md`），已存在的一律不覆盖——这部分也是 hook 会做的事，若 hook 已经建过，这里跳过即可

`docs/agents/agile-config.md` 模板：

```markdown
# 敏捷工作流配置

> 由 setup-agile-workflow 生成，agile-pm / frontend-dev / backend-dev / code-reviewer / test-writer 均读取本文件。
> 只有目录结构/契约方式/测试框架改变时才需要重新运行本 skill。

## 目录结构
（monorepo / 前后端分离单仓库 / 单体，及各自实际路径）

## 契约存放方式
（docs/contracts/<feature>.ts，或团队既有的 OpenAPI/其他方式及其路径）

## 测试框架
- 前端：
- 后端：
```

## 5. 完成

告知用户配置已完成，5个agent之后会自动读取这份配置，不用每次重新说明项目结构。
