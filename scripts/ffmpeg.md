# 视频格式转换

```bash
# 转换视频格式
ffmpeg -i input.mp4 output.avi

# 转换为H.264编码的MP4
ffmpeg -i input.avi -c:v libx264 -c:a aac output.mp4
```

# 视频旋转

```bash
# 顺时针旋转90度
ffmpeg -i input.mp4 -vf "transpose=1" output.mp4

# 逆时针旋转90度
ffmpeg -i input.mp4 -vf "transpose=2" output.mp4

# 旋转180度
ffmpeg -i input.mp4 -vf "transpose=2,transpose=2" output.mp4

```

# 合并音视频

```bash
ffmpeg -i video.mp4 -i audio.m4a -c copy output.mp4

ffmpeg -i video.mp4 -i audio.m4a -c:v copy -c:a aac output.mp4
```

# 压缩视频

```bash
ffmpeg -i input_2160p.mp4 -vf scale=1920:1080 output_1080p.mp4

# 保持宽高比
ffmpeg -i input_2160p.mp4 -vf scale=1920:-1 output_1080p.mp4

# H.264
ffmpeg -i input_2160p.mp4 -vf scale=1920:1080 -c:v libx264 -crf 23 -c:a copy output_1080p.mp4

# H.265/HEVC，压缩率更高
ffmpeg -i input_2160p.mp4 -vf scale=1920:1080 -c:v libx265 -crf 24 -preset slow -c:a aac -b:a 192k output_1080p.mp4

# H.265极致画质
ffmpeg -i input_2160p.mp4 -vf scale=1920:1080 -c:v libx265 -crf 20 -preset slower -c:a copy output_1080p.mp4

```

参数说明:

* -vf scale=1920:1080 - 设置输出分辨率
* -c:v libx264 - 使用 H.264 视频编码器
* -crf 23 - 质量参数 (18-28,数值越小质量越高,文件越大)
* -preset slow - 编码速度预设 (slower = 更好压缩,但更慢)
* -c:a copy - 直接复制音频不重新编码
* -c:a aac -b:a 128k - 重新编码音频为 AAC 128kbps