#!/usr/bin/env node

import { init } from '../src/init.js';

const [, , cmd, ...args] = process.argv;

const allArgs = [cmd, ...args];
const flags = {
  force: allArgs.includes('--force') || allArgs.includes('-f'),
  dryRun: allArgs.includes('--dry-run') || allArgs.includes('-n'),
  yes: allArgs.includes('--yes') || allArgs.includes('-y'),
  verbose: allArgs.includes('--verbose') || allArgs.includes('-v'),
  help: allArgs.includes('--help') || allArgs.includes('-h'),
};

function printHelp() {
  console.log(`
FF Project - Spec-driven development framework for Amp

Usage:
  ff-project init [options]    Initialize FF in current project
  ff-project --help            Show this help message

Options:
  -f, --force      Overwrite existing files
  -n, --dry-run    Show what would be done without making changes
  -y, --yes        Skip confirmation prompts
  -v, --verbose    Show detailed output

Examples:
  npx ff-project init          # Initialize with prompts
  npx ff-project init --yes    # Initialize without prompts
  npx ff-project init --force  # Overwrite existing files
`);
}

async function main() {
  if (flags.help || !cmd) {
    printHelp();
    process.exit(cmd ? 0 : 1);
  }

  if (cmd === 'init') {
    try {
      await init(flags);
    } catch (error) {
      console.error(`\n❌ Error: ${error.message}`);
      process.exit(1);
    }
  } else {
    console.error(`Unknown command: ${cmd}`);
    printHelp();
    process.exit(1);
  }
}

main();
