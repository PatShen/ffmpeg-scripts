#!/usr/bin/env zsh
# merge_mp4.sh — 扫描指定目录下所有 MP4，合并后输出到同一目录
#
# 用法:
#   ./merge_mp4.sh <目录> <输出文件名>
#   ./merge_mp4.sh <目录>            # 输出名交互式输入
#   ./merge_mp4.sh                   # 目录和输出名均交互式输入
#
# 示例:
#   ./merge_mp4.sh /data/clips final
#   ./merge_mp4.sh ./recordings output.mp4

set -euo pipefail

# ── 颜色输出 ────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; NC='\033[0m'

info()  { print -P "%F{cyan}[INFO]%f  $*"; }
ok()    { print -P "%F{green}[OK]%f    $*"; }
warn()  { print -P "%F{yellow}[WARN]%f  $*"; }
error() { print -P "%F{red}[ERROR]%f $*" >&2; }

# ── 参数：目录 ──────────────────────────────────────────────
if [[ $# -ge 1 ]]; then
    TARGET_DIR="$1"
else
    read "INPUT_DIR?请输入目标目录（直接回车使用当前目录）: "
    TARGET_DIR="${INPUT_DIR:-.}"
fi

# 校验目录存在
if [[ ! -d "$TARGET_DIR" ]]; then
    error "目录不存在：$TARGET_DIR"
    exit 1
fi

TARGET_DIR="$(realpath "$TARGET_DIR")"
info "目标目录：$TARGET_DIR"

# ── 收集 MP4 文件（按文件名自然排序）─────────────────────────
# zsh glob：N = 无匹配不报错，oe = 按名排序，大小写折叠靠 glob qualifier (i)
MP4_FILES=("${(@f)$(find "$TARGET_DIR" -maxdepth 1 -iname "*.mp4" | sort)}")
# 过滤掉 find 无结果时的空元素
MP4_FILES=("${(@)MP4_FILES:#}")

if [[ ${#MP4_FILES[@]} -eq 0 ]]; then
    error "目录下没有找到任何 .mp4 文件：$TARGET_DIR"
    exit 1
fi

info "找到以下 ${#MP4_FILES[@]} 个 MP4 文件（合并顺序）："
for i in {1..${#MP4_FILES[@]}}; do
    printf "  %2d. %s\n" "$i" "$(basename "${MP4_FILES[$i]}")"
done
echo

# ── 参数：输出文件名 ─────────────────────────────────────────
if [[ $# -ge 2 ]]; then
    OUTPUT_NAME="$2"
else
    read "INPUT_NAME?请输入输出文件名（不含扩展名，直接回车使用 merged）: "
    OUTPUT_NAME="${INPUT_NAME:-merged}"
fi

# 确保以 .mp4 结尾
[[ "$OUTPUT_NAME" != *.mp4 ]] && OUTPUT_NAME="${OUTPUT_NAME}.mp4"

# 输出路径 = 目标目录 / 文件名
OUTPUT="${TARGET_DIR}/${OUTPUT_NAME}"

# 防止输出文件本身被纳入合并列表
for f in "${MP4_FILES[@]}"; do
    if [[ "$(realpath "$f")" == "$OUTPUT" ]]; then
        error "输出文件名与源文件重名：$OUTPUT_NAME，请换一个名字。"
        exit 1
    fi
done

if [[ -f "$OUTPUT" ]]; then
    warn "输出文件已存在：$OUTPUT"
    read "CONFIRM?覆盖？[y/N] "
    [[ "${CONFIRM:l}" != "y" ]] && { info "已取消。"; exit 0; }
fi

# ── 生成 concat 列表（临时文件）────────────────────────────
LIST_FILE="$(mktemp /tmp/ffmpeg_concat_XXXXXX.txt)"
trap 'rm -f "$LIST_FILE"' EXIT

for f in "${MP4_FILES[@]}"; do
    ABS_PATH="$(realpath "$f")"
    printf "file '%s'\n" "${ABS_PATH//\'/\'\\\'\'}" >> "$LIST_FILE"
done

info "concat 列表："
cat "$LIST_FILE"
echo

# ── 执行合并 ────────────────────────────────────────────────
info "开始合并 → $OUTPUT"
ffmpeg -f concat -safe 0 -i "$LIST_FILE" -c copy "$OUTPUT"

ok "合并完成：$OUTPUT"
echo
# 输出文件信息
ffprobe -v quiet -show_entries format=duration,size \
        -of default=noprint_wrappers=1 "$OUTPUT" 2>/dev/null | \
while IFS='=' read -r key val; do
    case $key in
        duration) printf "  时长：%02d:%02d:%06.3f\n" \
                    $((${val%.*}/3600)) $(( (${val%.*}%3600)/60 )) \
                    "$(echo "$val % 60" | bc)" ;;
        size)     printf "  大小：%.2f MB\n" "$(echo "scale=2; $val/1048576" | bc)" ;;
    esac
done
