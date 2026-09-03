#!/bin/bash
# 会话开始时自动检查当前项目是否已有敏捷开发目录骨架，并报告插件/项目配置版本
# 只做确定性的文件/目录存在性和版本比较，不做项目结构、业务规划或自动迁移判断
# （技术约定交给 setup-agile-workflow，版本目标和里程碑交给 agile-pm 与用户逐层确认）

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd -- "$SCRIPT_DIR/../.." && pwd)}"
ROOT="$(pwd)"
CREATED=""
PLUGIN_VERSION=""
PREFIX="[agile-workflow v未知]"
SEMVER_RE='^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$'

read_plugin_version() {
  local manifest="$PLUGIN_ROOT/.claude-plugin/plugin.json"
  local version_line_re='^[[:space:]]*"version"[[:space:]]*:[[:space:]]*"([^"]+)"'
  local line candidate="" count=0

  [ -r "$manifest" ] || return

  while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ $version_line_re ]]; then
      candidate="${BASH_REMATCH[1]}"
      count=$((count + 1))
    fi
  done < "$manifest"

  if [ "$count" -eq 1 ] && [[ "$candidate" =~ $SEMVER_RE ]]; then
    PLUGIN_VERSION="$candidate"
    PREFIX="[agile-workflow v$PLUGIN_VERSION]"
  fi
}

record_created() {
  if [ -z "$CREATED" ]; then
    CREATED="$1"
  else
    CREATED="$CREATED $1"
  fi
}

warn_path() {
  printf '%s 警告：%s\n' "$PREFIX" "$1" >&2
}

path_exists() {
  [ -e "$1" ] || [ -L "$1" ]
}

ensure_directory() {
  local relative_path="$1"
  local absolute_path="$ROOT/$relative_path"

  if path_exists "$absolute_path"; then
    if [ ! -d "$absolute_path" ]; then
      warn_path "$relative_path 已存在但不是目录，已跳过且不会覆盖。"
    fi
    return
  fi

  if mkdir -p -- "$absolute_path"; then
    record_created "$relative_path/"
  else
    warn_path "无法创建 $relative_path，已继续检查其他骨架项。"
  fi
}

can_create_file() {
  local relative_path="$1"
  local absolute_path="$ROOT/$relative_path"
  local parent_path
  parent_path="$(dirname "$absolute_path")"

  if path_exists "$absolute_path"; then
    if [ ! -f "$absolute_path" ]; then
      warn_path "$relative_path 已存在但不是普通文件，已跳过且不会覆盖。"
    fi
    return 1
  fi

  if [ ! -d "$parent_path" ]; then
    warn_path "$relative_path 的父目录不可用，已跳过。"
    return 1
  fi

  return 0
}

# 只读取 agile-config 文件开头第一个 frontmatter 中的精确字段。
# APPLIED_VERSION_STATE: valid / missing / invalid
read_applied_version() {
  local config="$1"
  local key_re='^[[:space:]]*agile-workflow-applied-version[[:space:]]*:'
  local value_re='^[[:space:]]*agile-workflow-applied-version[[:space:]]*:[[:space:]]*"([^"]*)"[[:space:]]*$'
  local line line_number=0 count=0 candidate="" value_valid=1 frontmatter_closed=0

  APPLIED_VERSION=""
  APPLIED_VERSION_STATE="missing"

  while IFS= read -r line || [ -n "$line" ]; do
    line_number=$((line_number + 1))
    line="${line%$'\r'}"

    if [ "$line_number" -eq 1 ]; then
      [ "$line" = "---" ] || return
      continue
    fi

    if [ "$line" = "---" ]; then
      frontmatter_closed=1
      break
    fi

    if [[ "$line" =~ $key_re ]]; then
      count=$((count + 1))
      if [[ "$line" =~ $value_re ]]; then
        candidate="${BASH_REMATCH[1]}"
      else
        value_valid=0
      fi
    fi
  done < "$config"

  if [ "$frontmatter_closed" -ne 1 ]; then
    APPLIED_VERSION_STATE="invalid"
    return
  fi

  if [ "$count" -eq 0 ]; then
    return
  fi

  if [ "$count" -eq 1 ] && [ "$value_valid" -eq 1 ] && [[ "$candidate" =~ $SEMVER_RE ]]; then
    APPLIED_VERSION="$candidate"
    APPLIED_VERSION_STATE="valid"
  else
    APPLIED_VERSION_STATE="invalid"
  fi
}

read_plugin_version

ensure_directory "docs"
ensure_directory "docs/sprints"
ensure_directory "docs/contracts"
ensure_directory "docs/agents"

if can_create_file "docs/backlog.md"; then
  cat > "$ROOT/docs/backlog.md" << 'BACKLOG_EOF'
# Backlog

任务标记说明：
- `[BE]` 后端任务　`[FE]` 前端任务　`[TEST]` 测试任务
- `[NEEDS-API]` 表示涉及新接口，需先由前端出契约
- `[BUG]` 表示缺陷，可与 `[BE]` / `[FE]` 组合
- 每个父业务条目记录：版本、里程碑、计划 Sprint、故事点、依赖、验收标准
- 故事点使用 `1 / 2 / 3 / 5 / 8 / 13`，只统计可独立验收的父业务条目，不重复统计技术子任务
- 每条依赖使用“依赖: #编号”，无依赖写“依赖: 无”

## P0（核心功能）

（暂无任务）

## P1（重要但非阻塞）

## P2（增强/优化）
BACKLOG_EOF
  record_created "docs/backlog.md"
fi

if can_create_file "docs/roadmap.md"; then
  cat > "$ROOT/docs/roadmap.md" << 'ROADMAP_EOF'
# Roadmap

> 状态：UNINITIALIZED
> 本文件仅为初始化骨架。版本目标、业务里程碑、故事点、Sprint 和容量必须由 agile-pm 与用户逐层确认后写入。

尚未进行总体规划。对于跨多个业务阶段或 Sprint 的项目，可以对 Claude 说“为这个项目制定总体规划”。
ROADMAP_EOF
  record_created "docs/roadmap.md"
fi

if can_create_file "docs/CHANGELOG.md"; then
  cat > "$ROOT/docs/CHANGELOG.md" << 'CHANGELOG_EOF'
# Changelog

由 agile-pm 在每个 Sprint 结束时追加实际交付、延期、点数、缓冲、紧急插入和里程碑验收结果。
CHANGELOG_EOF
  record_created "docs/CHANGELOG.md"
fi

if [ -n "$CREATED" ]; then
  printf '%s 已自动创建敏捷开发目录骨架：%s\n' "$PREFIX" "$CREATED" >&2
fi

CONFIG_PATH="$ROOT/docs/agents/agile-config.md"

if [ -z "$PLUGIN_VERSION" ]; then
  if [ -f "$CONFIG_PATH" ]; then
    printf '%s 已就绪；警告：无法从 plugin.json 读取当前插件版本，已跳过项目版本比较。\n' "$PREFIX" >&2
  else
    printf '%s 已就绪；警告：无法从 plugin.json 读取当前插件版本，已跳过项目版本比较；尚未配置项目技术约定，建议运行 setup-agile-workflow。\n' "$PREFIX" >&2
  fi
elif [ ! -f "$CONFIG_PATH" ]; then
  printf '%s 已就绪；尚未配置项目技术约定，建议运行 setup-agile-workflow，确认后将记录项目应用版本。\n' "$PREFIX" >&2
else
  read_applied_version "$CONFIG_PATH"

  case "$APPLIED_VERSION_STATE" in
    valid)
      if [ "$APPLIED_VERSION" = "$PLUGIN_VERSION" ]; then
        printf '%s 已就绪；项目配置版本一致。\n' "$PREFIX" >&2
      else
        printf '%s 已就绪；项目上次应用版本为 v%s，与当前插件不一致；不会自动修改或迁移，请按需重新运行 setup-agile-workflow。\n' "$PREFIX" "$APPLIED_VERSION" >&2
      fi
      ;;
    missing)
      printf '%s 已就绪；检测到旧项目配置，但未记录工作流应用版本；不会自动修改，请按需重新运行 setup-agile-workflow。\n' "$PREFIX" >&2
      ;;
    invalid)
      printf '%s 已就绪；项目配置中的工作流应用版本无法解析；不会自动修复，请按需重新运行 setup-agile-workflow。\n' "$PREFIX" >&2
      ;;
  esac
fi

exit 0
