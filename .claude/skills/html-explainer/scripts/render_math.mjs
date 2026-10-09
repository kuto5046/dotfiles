#!/usr/bin/env node
// Render explicit math/tex placeholders; embed KaTeX CSS and WOFF2 fonts.
import fs from 'node:fs';
import path from 'node:path';
import { createRequire } from 'node:module';

const args = process.argv.slice(2);
const usage = 'Usage: node render_math.mjs input.html output.html --katex-dir /path/to/node_modules/katex';
if (args.includes('--help')) {
  console.log(usage);
  process.exit(0);
}

try {
  if (args.length !== 4 || args[2] !== '--katex-dir') throw new Error(usage);
  const [input, output, , katexDirArg] = args;
  const katexDir = path.resolve(katexDirArg);
  const require = createRequire(import.meta.url);
  const katex = require(katexDir);
  const version = JSON.parse(fs.readFileSync(path.join(katexDir, 'package.json'), 'utf8')).version;
  const source = fs.readFileSync(input, 'utf8');
  if (!/<!doctype\s+html\s*>/i.test(source) || !/<\/head\s*>/i.test(source)) {
    throw new Error('Input must be a complete HTML5 document with a closing head element.');
  }
  if (source.includes('id="html-explainer-math"')) {
    throw new Error('Input is already rendered. Regenerate from the source draft.');
  }
  if (fs.existsSync(output)) throw new Error('Output exists; choose a new path or remove the intended old output first.');

  let count = 0;
  const rendered = source.replace(/<script\b([^>]*)>([\s\S]*?)<\/script\s*>/gi, (whole, attrs, tex) => {
    const type = /\btype\s*=\s*(["'])(.*?)\1/i.exec(attrs)?.[2].trim();
    if (!type || !/^math\/tex(?:\s*;\s*mode\s*=\s*display)?$/i.test(type)) return whole;
    const displayMode = /;/.test(type);
    if (!tex.trim()) throw new Error('An empty math/tex placeholder was found.');
    const html = katex.renderToString(tex.trim(), {
      displayMode,
      output: 'htmlAndMathml',
      throwOnError: true,
      trust: false,
      strict: 'error',
      maxExpand: 1000,
      maxSize: 20,
    });
    count++;
    return displayMode ? `<div class="math-display">${html}</div>` : `<span class="math-inline">${html}</span>`;
  });
  if (!count) throw new Error('No explicit math/tex placeholders found.');

  const dist = path.join(katexDir, 'dist');
  let fontCount = 0;
  const css = fs.readFileSync(path.join(dist, 'katex.min.css'), 'utf8').replace(/@font-face\s*\{[^}]*\}/g, face => {
    const src = /src\s*:\s*([^;}]*)/.exec(face);
    if (!src) throw new Error('KaTeX font-face has no src.');
    const font = /url\(\s*["']?([^\s"')]+\.woff2)["']?\s*\)/.exec(src[1]);
    if (!font) throw new Error('KaTeX font-face has no WOFF2 source.');
    const fontPath = path.resolve(dist, font[1]);
    if (!fontPath.startsWith(dist + path.sep)) throw new Error('Font path escapes KaTeX dist.');
    const bytes = fs.readFileSync(fontPath).toString('base64');
    fontCount++;
    return face.replace(src[0], `src:url(data:font/woff2;base64,${bytes}) format("woff2")`);
  });
  if (!fontCount || /url\(\s*["']?(?!data:)/i.test(css)) throw new Error('Unembedded CSS asset remains.');
  const layout = `
.math-display { max-width:100%; overflow-x:auto; overflow-y:hidden; padding:.2em 0; }
.math-display .katex-display { margin:.55em 0; text-align:left; }
.math-display .katex-display>.katex { text-align:left; }
.math-display .katex { font-size:1.15em; }
.math-inline .katex { font-size:1.08em; }
@media(max-width:700px) { .math-display .katex { font-size:1.05em; } }
@media print { .math-display { overflow:visible; break-inside:avoid; } }
`;
  const license = fs.readFileSync(path.join(katexDir, 'LICENSE'), 'utf8').replace(/--/g, '—');
  const style = `<!-- KaTeX ${version}\n${license}\n-->\n<style id="html-explainer-math">\n${css}\n${layout}</style>\n`;
  const result = rendered.replace(/<\/head\s*>/i, style + '</head>');
  fs.writeFileSync(output, result, { encoding:'utf8', flag:'wx' });
  console.log(JSON.stringify({output:path.resolve(output),equations:count,embeddedFonts:fontCount,katexVersion:version,bytes:Buffer.byteLength(result)}));
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}
