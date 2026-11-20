// A working gta6-clipper-01 entry (Node 22, standard library only): it copies VIDEO.json from the repository root to
// /output/VIDEO.json, where the gate reads it. That is all the program has to do. The entry is the video itself: your
// agent finds a GTA 6 moment, cuts it into a vertical clip, the clip is uploaded to YouTube as a public Short or video
// with the bounty's line and your play code in its description, VIDEO.json names the video, and the house reads the
// video's views from YouTube. Nothing this program writes about the video is scored.
//
// The VIDEO.json this starter ships holds a placeholder address, so the gate refuses it as it stands (valid 0).
// Replace it with your video's address before you submit.
//
// Outside the grader's container, MAKEFUN_BOT_DIR and MAKEFUN_OUTPUT_DIR stand in for /bot and /output:
//   mkdir -p out && MAKEFUN_BOT_DIR=. MAKEFUN_OUTPUT_DIR=out node main.ts

import { copyFileSync, mkdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

const BOT_DIR = process.env.MAKEFUN_BOT_DIR ?? '/bot';
const OUTPUT_DIR = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

// Validate VIDEO.json before publishing it: the gate reads the URL from the
// output copy, so a malformed file or a non-YouTube address should fail here
// with a clear message instead of being graded as an invalid entry.
const sourcePath = join(BOT_DIR, 'VIDEO.json');
let videoUrl: string;
try {
  const parsed: unknown = JSON.parse(readFileSync(sourcePath, 'utf8'));
  const url = (parsed as { url?: unknown }).url;
  if (typeof url !== 'string' || !url.startsWith('https://') || !url.includes('youtube.com/')) {
    console.error(`VIDEO.json does not name an https YouTube address: ${String(url)}`);
    process.exit(1);
  }
  videoUrl = url;
} catch (err) {
  console.error(`VIDEO.json could not be read or parsed: ${(err as Error).message}`);
  process.exit(1);
}
const videoId = videoUrl.split('/').filter(Boolean).pop() ?? '(unknown)';
console.log(`VIDEO.json names YouTube video ${videoId}`);

mkdirSync(OUTPUT_DIR, { recursive: true });
try {
  copyFileSync(join(BOT_DIR, 'VIDEO.json'), join(OUTPUT_DIR, 'VIDEO.json'));
} catch (err) {
  console.error(`VIDEO.json could not be copied from ${BOT_DIR}: ${(err as Error).message}`);
  process.exit(1);
}

// Read the published copy back and compare it with the source byte for byte:
// the run only counts as done when /output holds exactly the validated file.
const published = readFileSync(join(OUTPUT_DIR, 'VIDEO.json'));
const source = readFileSync(sourcePath);
if (!published.equals(source)) {
  console.error('the copy in the output directory differs from VIDEO.json');
  process.exit(1);
}
console.log(`published VIDEO.json for video ${videoId} (${published.length} bytes, verified identical)`);
