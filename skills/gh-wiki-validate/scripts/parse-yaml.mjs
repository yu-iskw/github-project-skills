#!/usr/bin/env node
/**
 * Parse a YAML file and print JSON. Exit 1 if the file is missing or invalid.
 */
import { parse } from "yaml";
import fs from "node:fs";
import process from "node:process";

const inputPath = process.argv[2];
if (!inputPath) {
  console.error("usage: parse-yaml.mjs FILE.yml");
  process.exit(1);
}

let text;
try {
  text = fs.readFileSync(inputPath, "utf8");
} catch (error) {
  console.error(error && error.message ? error.message : String(error));
  process.exit(1);
}

try {
  const data = parse(text);
  if (data === undefined || data === null) {
    console.error("empty YAML document");
    process.exit(1);
  }
  process.stdout.write(`${JSON.stringify(data)}\n`);
} catch (error) {
  const message = error && error.message ? error.message : String(error);
  console.error(message);
  process.exit(1);
}
