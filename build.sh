#!/bin/bash
# gta6-clipper-01 v3r — fresh cut. Stunt ~8.5s + end card ~3.5s = 12.0s, 1080x1920, 30fps.
set -e
SRC=~/workspace/makefun/clipper-v2-src/trailer.mp4
GHOST=~/workspace/makefun/clipper-v2-src/ghost.png
W=~/workspace/makefun/gta6-clipper-01-v3r-work
FONT=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
mkdir -p "$W/out" "$W/tmp"
cd "$W/tmp"

printf 'GTA 6 IS OUT NOW' > cap1.txt
printf 'HANGING OFF\nA HELICOPTER' > cap3.txt
printf 'VICE CITY NEVER SLEEPS' > cap4.txt
printf '5-STAR WANTED' > cap5.txt
printf 'Play code: makefun-runway-trail-snail' > playcode.txt

# ---- Step A: stunt 8.5s (hook 1.5 + flashback 1.5 + slow-mo 1.8 + police 1.5 + payoff 2.2)
ffmpeg -y -v error -i "$SRC" -i "$GHOST" -filter_complex "
[0:v]trim=69.4:70.9,setpts=PTS-STARTPTS,fps=30[v1];
[0:v]trim=68.5:69.4,setpts=(PTS-STARTPTS)/0.6,fps=30[v2];
[0:v]trim=69.4:70.3,setpts=(PTS-STARTPTS)/0.5,fps=30[v3];
[0:v]trim=70.3:71.8,setpts=PTS-STARTPTS,fps=30[v4];
[0:v]trim=69.4:71.6,setpts=PTS-STARTPTS,scale=2304:1296,crop=1920:1080,fps=30[v5];
[v1][v2][v3][v4][v5]concat=n=5:v=1:a=0[vcat];
[vcat]crop=ih*9/16:ih,scale=1080:1920,fps=30,
drawtext=fontfile=$FONT:textfile=cap1.txt:fontsize=96:fontcolor=white:borderw=3:bordercolor=black:box=1:boxcolor=black@0.6:boxborderw=24:x=(w-text_w)/2:y=h-460:enable='between(t,0,1.5)',
drawtext=fontfile=$FONT:textfile=cap3.txt:fontsize=80:fontcolor=white:borderw=3:bordercolor=black:box=1:boxcolor=black@0.6:boxborderw=24:x=(w-text_w)/2:y=h-620:enable='between(t,3.0,4.8)',
drawtext=fontfile=$FONT:textfile=cap4.txt:fontsize=72:fontcolor=white:borderw=3:bordercolor=black:box=1:boxcolor=black@0.6:boxborderw=24:x=(w-text_w)/2:y=h-460:enable='between(t,4.8,6.3)',
drawtext=fontfile=$FONT:textfile=stars.txt:fontsize=110:fontcolor=yellow:borderw=3:bordercolor=black:x=(w-text_w)/2:y=h-760:enable='between(t,6.3,8.5)',
drawtext=fontfile=$FONT:textfile=cap5.txt:fontsize=96:fontcolor=white:borderw=3:bordercolor=black:box=1:boxcolor=black@0.6:boxborderw=24:x=(w-text_w)/2:y=h-480:enable='between(t,6.3,8.5)'[vtxt];
[1:v]scale=120:-1[gh];
[vtxt][gh]overlay=W-140:36:enable='between(t,0,8.5)'[vout];
[0:a]atrim=69.4:70.9,asetpts=PTS-STARTPTS[a1];
[0:a]atrim=68.5:69.4,atempo=0.6,asetpts=PTS-STARTPTS[a2];
[0:a]atrim=69.4:70.3,atempo=0.5,asetpts=PTS-STARTPTS[a3];
[0:a]atrim=70.3:71.8,asetpts=PTS-STARTPTS[a4];
[0:a]atrim=69.4:71.6,asetpts=PTS-STARTPTS[a5];
[a1][a2][a3][a4][a5]concat=n=5:v=0:a=1,loudnorm=I=-14:TP=-1.5:LRA=11[aout]
" -map "[vout]" -map "[aout]" -c:v libx264 -pix_fmt yuv420p -crf 20 -preset medium -r 30 -c:a aac -b:a 128k -movflags +faststart -t 8.5 stunt.mp4

# ---- Step B: end card 3.5s (silent)
ffmpeg -y -v error -f lavfi -i color=c=0x0b0b14:s=1080x1920:r=30:d=3.5 -i "$GHOST" -f lavfi -i anullsrc=r=48000:cl=stereo -t 3.5 -filter_complex "
[1:v]scale=300:-1[gh];
[0:v][gh]overlay=(W-300)/2:560,
drawtext=fontfile=$FONT:text='MADE BY MY AI AGENT':fontsize=58:fontcolor=white:borderw=2:bordercolor=black:x=(w-text_w)/2:y=1050,
drawtext=fontfile=$FONT:text='on make.fun':fontsize=84:fontcolor=white:borderw=3:bordercolor=black:x=(w-text_w)/2:y=1150,
drawtext=fontfile=$FONT:textfile=playcode.txt:fontsize=38:fontcolor=white:borderw=2:bordercolor=black:x=(w-text_w)/2:y=1330[vout]
" -map "[vout]" -map 2:a -c:v libx264 -pix_fmt yuv420p -crf 20 -preset medium -r 30 -c:a aac -b:a 128k -movflags +faststart -t 3.5 endcard.mp4

# ---- Step C: concat -> final clip
ffmpeg -y -v error -i stunt.mp4 -i endcard.mp4 -filter_complex "[0:v]setsar=1[v0];[1:v]setsar=1[v1];[v0][0:a][v1][1:a]concat=n=2:v=1:a=1[v][a]" -map "[v]" -map "[a]" -c:v libx264 -pix_fmt yuv420p -crf 20 -preset medium -r 30 -c:a aac -b:a 128k -movflags +faststart "$W/out/clip.mp4"

echo '--- final probe:'
ffprobe -v error -show_entries format=duration,size -show_entries stream=codec_name,width,height,r_frame_rate -of default=noprint_wrappers=1 "$W/out/clip.mp4"
ffmpeg -y -v error -ss 0.7 -i "$W/out/clip.mp4" -frames:v 1 "$W/tmp/frame-hook.jpg"
ffmpeg -y -v error -ss 7.0 -i "$W/out/clip.mp4" -frames:v 1 "$W/tmp/frame-payoff.jpg"
ls -la "$W/out/clip.mp4"
sha256sum "$W/out/clip.mp4"
