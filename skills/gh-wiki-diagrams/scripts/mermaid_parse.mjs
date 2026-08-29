#!/usr/bin/env node
/**
 * Parse Mermaid from stdin, a .mmd file, or mermaid fences in a Markdown page.
 * Exit 0 on success, 1 on parse failure.
 */
import { JSDOM } from "jsdom";
import fs from "node:fs";
import process from "node:process";

const { window } = new JSDOM("<!DOCTYPE html><html><body></body></html>", {
  url: "https://knowledge.local/",
  pretendToBeVisual: true,
});

global.window = window;
global.document = window.document;
global.DOMParser = window.DOMParser;
global.XMLSerializer = window.XMLSerializer;
global.HTMLElement = window.HTMLElement;
global.SVGElement = window.SVGElement;
global.Element = window.Element;
global.getComputedStyle = window.getComputedStyle.bind(window);

const mermaid = (await import("mermaid")).default;
mermaid.initialize({ startOnLoad: false, securityLevel: "loose" });

function extractFences(text) {
  const fences = [];
  const pattern = /^```mermaid[^\n]*\n([\s\S]*?)^```/gm;
  let match;
  while ((match = pattern.exec(text)) !== null) {
    fences.push(match[1].trim());
  }
  return fences;
}

async function parseOne(source) {
  if (!source) {
    console.error("empty mermaid source");
    process.exit(1);
  }
  try {
    await mermaid.parse(source);
  } catch (error) {
    const message = error && error.message ? error.message : String(error);
    console.error(message);
    process.exit(1);
  }
}

async function readStdin() {
  const chunks = [];
  for await (const chunk of process.stdin) {
    chunks.push(chunk);
  }
  return Buffer.concat(chunks).toString("utf8");
}

const inputPath = process.argv[2];
const text = inputPath ? fs.readFileSync(inputPath, "utf8") : await readStdin();

const looksLikeMarkdown =
  Boolean(inputPath && inputPath.endsWith(".md")) || /^```mermaid/m.test(text);

if (looksLikeMarkdown) {
  const fences = extractFences(text);
  if (fences.length === 0) {
    console.error("no mermaid fences");
    process.exit(1);
  }
  for (const fence of fences) {
    await parseOne(fence);
  }
} else {
  await parseOne(text.trim());
}
