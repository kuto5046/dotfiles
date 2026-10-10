import fs from "node:fs/promises";
import path from "node:path";
import { pathToFileURL } from "node:url";
import { Presentation, PresentationFile } from "@oai/artifact-tool";

const PRESENTATIONS_SKILL_DIR = process.env.PRESENTATIONS_SKILL_DIR;
const workspaceDir = process.env.WORKSPACE_DIR;
const outputPath = process.env.FINAL_PPTX;
const runtimePython = process.env.RUNTIME_PYTHON;

for (const [name, value] of Object.entries({
  PRESENTATIONS_SKILL_DIR,
  WORKSPACE_DIR: workspaceDir,
  FINAL_PPTX: outputPath,
  RUNTIME_PYTHON: runtimePython,
})) {
  if (!value || (name !== "RUNTIME_PYTHON" && !path.isAbsolute(value))) {
    throw new Error(`${name} must be set${name === "RUNTIME_PYTHON" ? "" : " to an absolute path"}`);
  }
}

const palette = {
  canvas: "#FFFFFF",
  ink: "#20201D",
  structure: "#90B5F9",
  signal: "#524EF6",
  emphasis: "#F06449",
  muted: "#777772",
  guide: "#D9E6FD",
};
const fontFamily = "Hiragino Sans";
const buildDir = path.join(workspaceDir, ".codex-build", "noto-paper-slides-template");
const candidatePath = path.join(buildDir, "candidate.pptx");
const receiptPath = path.join(buildDir, "validation.json");

await fs.mkdir(buildDir, { recursive: true });
await fs.mkdir(path.dirname(outputPath), { recursive: true });

function addText(slide, { name, position, text, fontSize, bold = false, color = palette.ink, align = "left", autoFit = "shrinkText" }) {
  const shape = slide.shapes.add({
    geometry: "textbox",
    name,
    position,
    fill: "none",
    line: { style: "solid", fill: "none", width: 0 },
  });
  shape.text = text;
  shape.text.style = {
    typeface: fontFamily,
    fontSize,
    bold,
    color,
    alignment: align,
    autoFit,
  };
  return shape;
}

function addCommonChrome(slide, page) {
  slide.background.fill = palette.canvas;
  slide.shapes.add({
    geometry: "roundRect",
    name: "noto-signal-bar",
    position: { left: 80, top: 48, width: 9, height: 50 },
    fill: palette.signal,
    line: { style: "solid", fill: "none", width: 0 },
    borderRadius: 6,
  });
  slide.shapes.add({
    geometry: "line",
    name: "noto-header-rule",
    position: { left: 80, top: 110, width: 1120, height: 0 },
    fill: "none",
    line: { style: "solid", fill: palette.structure, width: 1.5, transparency: 38 },
  });
  addText(slide, {
    name: "noto-title",
    position: { left: 110, top: 43, width: 1020, height: 55 },
    text: "{{TITLE}}",
    fontSize: 36,
    bold: true,
  });
  addText(slide, {
    name: "noto-takeaway",
    position: { left: 110, top: 122, width: 1040, height: 44 },
    text: "{{TAKEAWAY}}",
    fontSize: 28,
    color: palette.muted,
    autoFit: "none",
  });
  addText(slide, {
    name: "noto-page",
    position: { left: 1160, top: 672, width: 40, height: 24 },
    text: String(page),
    fontSize: 14,
    bold: true,
    color: palette.muted,
    align: "right",
  });
}

function addGuide(slide, name, position, label) {
  const guide = slide.shapes.add({
    geometry: "rect",
    name,
    position,
    fill: "#F8FAFF",
    line: { style: "dash", fill: palette.guide, width: 1.5 },
  });
  guide.text = label;
  guide.text.style = {
    typeface: fontFamily,
    fontSize: 18,
    bold: true,
    color: palette.structure,
    alignment: "center",
    verticalAlignment: "middle",
    autoFit: "shrinkText",
  };
  return guide;
}

const presentation = Presentation.create({ slideSize: { width: 1280, height: 720 } });

const cover = presentation.slides.add();
cover.background.fill = palette.canvas;
cover.shapes.add({
  geometry: "roundRect",
  name: "noto-cover-signal-bar",
  position: { left: 92, top: 122, width: 10, height: 176 },
  fill: palette.signal,
  line: { style: "solid", fill: "none", width: 0 },
  borderRadius: 6,
});
addText(cover, {
  name: "noto-cover-title",
  position: { left: 132, top: 116, width: 990, height: 185 },
  text: "{{PAPER_TITLE}}",
  fontSize: 46,
  bold: true,
});
addText(cover, {
  name: "noto-cover-subtitle",
  position: { left: 132, top: 332, width: 900, height: 72 },
  text: "{{FRAMING_LINE}}",
  fontSize: 24,
  color: palette.muted,
});
addText(cover, {
  name: "noto-cover-meta",
  position: { left: 132, top: 588, width: 960, height: 52 },
  text: "{{AUTHORS / VENUE / DATE}}",
  fontSize: 16,
  color: palette.muted,
});

const visual = presentation.slides.add();
addCommonChrome(visual, 2);
addGuide(visual, "REMOVE-ME-visual-guide", { left: 80, top: 190, width: 1120, height: 440 }, "WIDE VISUAL / FIGURE / CHART");

const split = presentation.slides.add();
addCommonChrome(split, 3);
addText(split, {
  name: "noto-body",
  position: { left: 88, top: 205, width: 420, height: 390 },
  text: "{{2–4 FACTS, CONDITIONS, OR DECISIONS}}",
  fontSize: 22,
});
addGuide(split, "REMOVE-ME-split-visual-guide", { left: 540, top: 190, width: 660, height: 440 }, "ONE SELF-CONTAINED VISUAL");

const evidence = presentation.slides.add();
addCommonChrome(evidence, 4);
addGuide(evidence, "REMOVE-ME-evidence-guide", { left: 80, top: 190, width: 810, height: 420 }, "ORIGINAL PAPER EVIDENCE");
addText(evidence, {
  name: "noto-callout",
  position: { left: 930, top: 225, width: 260, height: 250 },
  text: "{{UP TO TWO CALLOUTS}}",
  fontSize: 20,
});
addText(evidence, {
  name: "noto-source",
  position: { left: 88, top: 625, width: 900, height: 30 },
  text: "{{SOURCE}}",
  fontSize: 12,
  color: palette.muted,
});

const results = presentation.slides.add();
addCommonChrome(results, 5);
addGuide(results, "REMOVE-ME-results-guide", { left: 80, top: 190, width: 850, height: 420 }, "EDITABLE CHART OR TABLE");
addText(results, {
  name: "noto-result-note",
  position: { left: 975, top: 240, width: 215, height: 220 },
  text: "{{DECISIVE COMPARISON}}",
  fontSize: 20,
  bold: true,
  color: palette.emphasis,
});
addText(results, {
  name: "noto-source",
  position: { left: 88, top: 625, width: 900, height: 30 },
  text: "{{SOURCE}}",
  fontSize: 12,
  color: palette.muted,
});

for (const slide of presentation.slides.items) {
  slide.speakerNotes.textFrame.setText("Noto template reference slide. Duplicate the matching slide, replace all sample tokens, and remove REMOVE-ME-* guides in final decks.");
}

await (await PresentationFile.exportPptx(presentation)).save(candidatePath);

const { finalizePresentation } = await import(
  pathToFileURL(path.join(PRESENTATIONS_SKILL_DIR, "container_tools", "artifact_tool_utils.mjs")).href
);

await finalizePresentation({
  workspaceDir,
  candidatePath,
  finalPath: outputPath,
  pythonExecutable: runtimePython,
  integrityValidatorPath: path.join(PRESENTATIONS_SKILL_DIR, "container_tools", "inspect_presentation_package_integrity.py"),
  layoutValidatorPath: path.join(PRESENTATIONS_SKILL_DIR, "container_tools", "inspect_presentation_layout_geometry.py"),
  layoutArgs: ["--expected-slide-size-emu", "12192000,6858000", "--validate-heading-fit"],
  explicitTotalSlideCount: 5,
  requiredNativeTableOwnerSlides: [],
  requiredNativeChartOwnerSlides: [],
  fontPolicy: { basis: "design", families: [fontFamily] },
  verifyArtifactToolImport: true,
  receiptPath,
});

console.log(outputPath);
