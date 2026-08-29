#!/usr/bin/env node
/**
 * Parse Markdown YAML frontmatter and extract [[Wiki]] links from the body.
 * Prints { frontmatter, wiki_links, body }. Exit 1 if frontmatter is missing.
 */
import { parse } from "yaml";
import fs from "node:fs";
import process from "node:process";

const inputPath = process.argv[2];
if (!inputPath) {
  console.error("usage: frontmatter.mjs PAGE.md");
  process.exit(1);
}

let text;
try {
  text = fs.readFileSync(inputPath, "utf8");
} catch (error) {
  console.error(error && error.message ? error.message : String(error));
  process.exit(1);
}

const match = text.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n?([\s\S]*)$/);
if (!match) {
  console.error("missing YAML frontmatter");
  process.exit(1);
}

let frontmatter;
try {
  frontmatter = parse(match[1]);
} catch (error) {
  const message = error && error.message ? error.message : String(error);
  console.error(message);
  process.exit(1);
}

if (frontmatter === undefined || frontmatter === null || typeof frontmatter !== "object") {
  console.error("frontmatter is not a mapping");
  process.exit(1);
}

const body = match[2];
const wiki_links = [];
const seen = new Set();
const pattern = /\[\[([^\]|#]+)(?:[|#][^\]]*)?\]\]/g;
let linkMatch;
while ((linkMatch = pattern.exec(body)) !== null) {
  const target = linkMatch[1].trim();
  if (target && !seen.has(target)) {
    seen.add(target);
    wiki_links.push(target);
  }
}

const mermaid_families = [];
const fencePattern = /^```mermaid[^\n]*\n([\s\S]*?)^```/gm;
let fenceMatch;
while ((fenceMatch = fencePattern.exec(body)) !== null) {
  const lines = fenceMatch[1].split(/\r?\n/);
  let family = "";
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("%%")) {
      continue;
    }
    family = trimmed.split(/\s+/)[0];
    break;
  }
  mermaid_families.push(family);
}

process.stdout.write(`${JSON.stringify({ frontmatter, wiki_links, body, mermaid_families })}\n`);
