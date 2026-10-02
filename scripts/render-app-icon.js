#!/usr/bin/env node
// Renders Resources/AppIcon.iconset/*.png from the SVG sources with headless
// Chrome, so build.sh can pack them into AppIcon.icns with iconutil.
//
//   npm install -g playwright            # once; uses installed Google Chrome,
//   NODE_PATH="$(npm root -g)" node scripts/render-app-icon.js
//
// Falls back to Playwright's own Chromium (`npx playwright install chromium`)
// when Google Chrome is not installed; GLANCEBAR_CHROME=<path> forces a binary.
// Run it only when Resources/AppIcon.svg or AppIcon-small.svg change; the
// rendered PNGs are committed so a normal build needs none of this.
'use strict';

const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require('playwright');

const root = path.resolve(__dirname, '..');
const outDir = path.join(root, 'Resources', 'AppIcon.iconset');
const fullSVG = fs.readFileSync(path.join(root, 'Resources', 'AppIcon.svg'), 'utf8');
const smallSVG = fs.readFileSync(path.join(root, 'Resources', 'AppIcon-small.svg'), 'utf8');

// iconutil's required file names → pixel size. 16 and 32 px use the
// simplified artwork, everything else the full one.
const files = {
  'icon_16x16.png': 16,
  'icon_16x16@2x.png': 32,
  'icon_32x32.png': 32,
  'icon_32x32@2x.png': 64,
  'icon_128x128.png': 128,
  'icon_128x128@2x.png': 256,
  'icon_256x256.png': 256,
  'icon_256x256@2x.png': 512,
  'icon_512x512.png': 512,
  'icon_512x512@2x.png': 1024,
};

async function launch() {
  if (process.env.GLANCEBAR_CHROME) {
    return chromium.launch({ executablePath: process.env.GLANCEBAR_CHROME });
  }
  try {
    return await chromium.launch({ channel: 'chrome' });
  } catch {
    return chromium.launch();
  }
}

(async () => {
  fs.mkdirSync(outDir, { recursive: true });
  const browser = await launch();
  try {
    const page = await browser.newPage({ deviceScaleFactor: 1 });
    for (const [name, px] of Object.entries(files)) {
      const svg = (px <= 32 ? smallSVG : fullSVG)
        .replace('<svg ', `<svg style="display:block;width:${px}px;height:${px}px" `);
      await page.setViewportSize({ width: px, height: px });
      await page.setContent(
        `<!doctype html><html><head><meta charset="utf-8"></head>` +
        `<body style="margin:0;background:transparent">${svg}</body></html>`
      );
      const png = await page.screenshot({
        omitBackground: true,
        clip: { x: 0, y: 0, width: px, height: px },
      });
      fs.writeFileSync(path.join(outDir, name), png);
      console.log(`${name.padEnd(22)} ${px}x${px}`);
    }
  } finally {
    await browser.close();
  }
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
