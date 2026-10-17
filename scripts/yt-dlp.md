# 下载视频

```bash
yt-dlp "视频URL"
```

# 下载指定画质

```bash
yt-dlp -f "best[height<=1080]" "视频URL"  # 最高1080p
yt-dlp -f "best[height<=720]" "视频URL"   # 最高720p
```

# 只下载音频

```bash
yt-dlp -x "视频URL"  # 提取音频
yt-dlp -x --audio-format mp3 "视频URL"  # 转换为MP3
```

# 查看可用格式

```bash
yt-dlp -F "视频URL"
```

# 列出所有画质和格式

```bash
yt-dlp -f 137+140 "视频URL"  # 下载特定格式组合
```

# 指定下载位置

```bash
yt-dlp -o "~/Downloads/%(title)s.%(ext)s" "视频URL"
```

# 下载带字幕

```bash
yt-dlp --write-sub --sub-lang zh-Hans,en "视频URL"
```

# 批量下载

创建一个文本文件（如urls.txt），每行一个视频链接，然后：

```bash
yt-dlp -a urls.txt
```