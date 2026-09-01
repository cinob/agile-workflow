#!/bin/bash
# 会话开始时自动检查当前项目是否已有敏捷开发目录骨架
# 只做确定性的"文件存在与否"检查，不做任何项目结构相关的判断
# （目录结构/契约方式/测试框架的判断交给 setup-agile-workflow skill，因为那需要探索+确认，不适合在无交互的hook里做）

ROOT="$(pwd)"
CREATED=""

if [ ! -f "$ROOT/docs/backlog.md" ]; then
  mkdir -p "$ROOT/docs/sprints" "$ROOT/docs/contracts"
  cat > "$ROOT/docs/backlog.md" << 'BACKLOG_EOF'
# Backlog

任务标记说明：
- `[BE]` 后端任务　`[FE]` 前端任务　`[TEST]` 测试任务
- `[NEEDS-API]` 标注在需求标题上，表示该需求涉及新接口，需先由前端出契约
- 每条任务需标注"依赖: #编号"，无依赖写"依赖: 无"

## P0（核心功能）

（暂无任务）

## P1（次要功能）

## P2（增强功能）
BACKLOG_EOF
  cat > "$ROOT/docs/CHANGELOG.md" << 'CHANGELOG_EOF'
# Changelog

由 agile-pm 在每个 Sprint 结束时自动追加。
CHANGELOG_EOF
  CREATED="docs/backlog.md docs/sprints/ docs/contracts/ docs/CHANGELOG.md"
fi

if [ -n "$CREATED" ]; then
  echo "[agile-workflow] 已自动创建敏捷开发目录骨架：$CREATED" >&2
fi

if [ ! -f "$ROOT/docs/agents/agile-config.md" ]; then
  echo "[agile-workflow] 提示：尚未配置项目约定（目录结构/契约方式/测试框架），建议对 Claude 说\"配置敏捷开发工作流\"运行一次 setup-agile-workflow，会先探索项目再问你确认，不会瞎猜。" >&2
fi

exit 0
