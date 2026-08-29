#!/usr/bin/env node
/**
 * Parse a Mermaid diagram from stdin using mermaid.parse (no Chromium).
 * Exit 0 on success, 1 on parse failure.
 */
import { JSDOM } from "jsdom";
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

const chunks = [];
for await (const chunk of process.stdin) {
  chunks.push(chunk);
}
const source = Buffer.concat(chunks).toString("utf8").trim();

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
