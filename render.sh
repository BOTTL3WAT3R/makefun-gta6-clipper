#!/bin/bash
# gta6-clipper-01 clip render — all decisions narrated in the session transcript.
# Source: GTA VI Trailer 1 (Rockstar Games official YouTube, QdBZY2fkU-0), 1920x1080.
# Format: vertical 1080x1920 Short, silent (trailer song is copyrighted -> no audio).
# Segments:
#   seg1 gator hook (blurred-pad)   src 42.50-44.20 @1x
#   seg2 gator slow replay (crop)   src 42.95-44.20 @0.5x, full-bleed crop on the gator
#   seg3 car-roof dance (blur-pad)  src 24.30-27.30 @1x
#   seg4 truck-door exit (blur-pad) src 51.15-53.65 @1x
#   seg5 gator loop-back (blur-pad) src 42.50-44.20 @1x
#   seg6 make.fun pitch end-card    generated, 6s
set -e
cd "$(dirname "$0")"
SRC=trailer1.mp4
FONT=/usr/share/fonts/truetype/noto/NotoSans-Bold.ttf
ENC="-c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p -r 30 -an"

pad () { # $1=in $2=start $3=dur $4=out $5=extra_vf_after_overlay
  ffmpeg -v error -y -ss "$2" -t "$3" -i "$SRC" -filter_complex \
    "[0:v]split[a][b];[a]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,gblur=sigma=45,eq=brightness=-0.18[bg];[b]scale=1080:-2[fg];[bg][fg]overlay=(W-w)/2:560$5" \
    $ENC "$4"
}

DT="drawtext=fontfile=$FONT:fontcolor=white:borderw=6:bordercolor=black:box=1:boxcolor=black@0.45:boxborderw=18"

# seg1 — hook: gator drag, big top text lands in the first frames
pad x 42.50 1.70 seg1.mp4 ",drawtext=fontfile=$FONT:text='ONLY IN GTA 6':fontsize=58:fontcolor=white:borderw=5:bordercolor=black:x=(w-text_w)/2:y=130,drawtext=fontfile=$FONT:text='A GATOR IN THE POOL?!':fontsize=88:fontcolor=white:borderw=7:bordercolor=black:box=1:boxcolor=black@0.45:boxborderw=20:x=(w-text_w)/2:y=215"

# seg2 — slow-mo replay, full-bleed crop centred on the gator (src x 690..1297)
ffmpeg -v error -y -ss 42.95 -t 1.25 -i "$SRC" -filter_complex \
  "[0:v]setpts=2.0*PTS,crop=607:1080:690:0,scale=1080:1920,$DT:text='HE SAID\: MY POOL NOW':fontsize=72:x=(w-text_w)/2:y=1620" \
  $ENC seg2.mp4

# seg3 — car-roof dance on the highway at night
pad x 24.30 3.00 seg3.mp4 ",$DT:text='SHE IS THE TRAFFIC NOW':fontsize=72:x=(w-text_w)/2:y=1560"

# seg4 — truck-door exit, vertical style
pad x 51.15 2.50 seg4.mp4 ",$DT:text='BRO GOT OUT... VERTICALLY':fontsize=72:x=(w-text_w)/2:y=1560"

# seg5 — gator again (loop-back payoff)
pad x 42.50 1.70 seg5.mp4 ",$DT:text='STILL NOT LEAVING':fontsize=72:x=(w-text_w)/2:y=1560"

# seg6 — pitch end-card (the make.fun pitch: no pitch = disqualification)
ffmpeg -v error -y -f lavfi -i color=c=0x14041f:s=1080x1920:r=30:d=6 -filter_complex \
  "[0:v]drawtext=fontfile=$FONT:text='MY AI AGENT':fontsize=76:fontcolor=white:x=(w-text_w)/2:y=420,drawtext=fontfile=$FONT:text='MADE THIS CLIP':fontsize=76:fontcolor=white:x=(w-text_w)/2:y=520,drawtext=fontfile=$FONT:text='Make clips with AI &':fontsize=58:fontcolor=white:x=(w-text_w)/2:y=760,drawtext=fontfile=$FONT:text='earn REAL money on':fontsize=58:fontcolor=white:x=(w-text_w)/2:y=845,drawtext=fontfile=$FONT:text='make.fun':fontsize=150:fontcolor=0xff2e88:x=(w-text_w)/2:y=960,drawtext=fontfile=$FONT:text='\$500 BOUNTY':fontsize=72:fontcolor=0xffd23f:x=(w-text_w)/2:y=1230,drawtext=fontfile=$FONT:text='make.fun/bounty/gta6-clipper-01':fontsize=42:fontcolor=white:x=(w-text_w)/2:y=1380,fade=t=in:st=0:d=0.4,fade=t=out:st=5.5:d=0.5" \
  $ENC seg6.mp4

printf "file '%s'\n" seg1.mp4 seg2.mp4 seg3.mp4 seg4.mp4 seg5.mp4 seg6.mp4 > concat.txt
mkdir -p ../clip
ffmpeg -v error -y -f concat -safe 0 -i concat.txt -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p -r 30 -an -movflags +faststart ../clip/final-clip.mp4
echo "RENDER DONE"
