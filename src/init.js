import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import readline from 'node:readline';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const TEMPLATE_ROOT = path.resolve(__dirname, '../templates');

const AGENTS_MD_MARKERS = {
  begin: '<!-- ff-project:begin -->',
  end: '<!-- ff-project:end -->',
};

/**
 * Copy directory recursively
 */
async function copyDir(src, dest, flags, stats) {
  const entries = await fs.readdir(src, { withFileTypes: true });

  for (const entry of entries) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);

    if (entry.isDirectory()) {
      await ensureDir(destPath, flags, stats);
      await copyDir(srcPath, destPath, flags, stats);
    } else {
      await copyFile(srcPath, destPath, flags, stats);
    }
  }
}

/**
 * Ensure directory exists
 */
async function ensureDir(dirPath, flags, stats) {
  try {
    await fs.access(dirPath);
  } catch {
    if (flags.dryRun) {
      console.log(`  📁 Would create: ${dirPath}`);
    } else {
      await fs.mkdir(dirPath, { recursive: true });
      if (flags.verbose) {
        console.log(`  📁 Created: ${dirPath}`);
      }
    }
    stats.dirsCreated++;
  }
}

/**
 * Copy single file with conflict handling
 */
async function copyFile(src, dest, flags, stats) {
  const relativeDest = path.relative(process.cwd(), dest);

  try {
    await fs.access(dest);
    // File exists
    if (flags.force) {
      if (flags.dryRun) {
        console.log(`  📄 Would overwrite: ${relativeDest}`);
      } else {
        await fs.copyFile(src, dest);
        if (flags.verbose) {
          console.log(`  📄 Overwritten: ${relativeDest}`);
        }
      }
      stats.filesOverwritten++;
    } else {
      if (flags.verbose) {
        console.log(`  ⏭️  Skipped (exists): ${relativeDest}`);
      }
      stats.filesSkipped++;
    }
  } catch {
    // File doesn't exist, copy it
    if (flags.dryRun) {
      console.log(`  📄 Would create: ${relativeDest}`);
    } else {
      await fs.copyFile(src, dest);
      if (flags.verbose) {
        console.log(`  📄 Created: ${relativeDest}`);
      }
    }
    stats.filesCreated++;
  }
}

/**
 * Handle AGENTS.md with managed block strategy
 */
async function handleAgentsMd(flags, stats) {
  const agentsMdPath = path.join(process.cwd(), 'AGENTS.md');
  const templatePath = path.join(TEMPLATE_ROOT, 'AGENTS.md');
  const templateContent = await fs.readFile(templatePath, 'utf-8');

  // Wrap template in managed block markers
  const managedBlock = `${AGENTS_MD_MARKERS.begin}
${templateContent.trim()}
${AGENTS_MD_MARKERS.end}`;

  try {
    const existingContent = await fs.readFile(agentsMdPath, 'utf-8');

    // Check if managed block already exists
    if (existingContent.includes(AGENTS_MD_MARKERS.begin)) {
      // Replace existing managed block
      const regex = new RegExp(
        `${escapeRegex(AGENTS_MD_MARKERS.begin)}[\\s\\S]*?${escapeRegex(AGENTS_MD_MARKERS.end)}`,
        'g'
      );
      const newContent = existingContent.replace(regex, managedBlock);

      if (flags.dryRun) {
        console.log('  📄 Would update managed block in: AGENTS.md');
      } else {
        await fs.writeFile(agentsMdPath, newContent);
        if (flags.verbose) {
          console.log('  📄 Updated managed block in: AGENTS.md');
        }
      }
      stats.filesUpdated++;
    } else {
      // Append managed block
      const newContent = `${existingContent.trim()}\n\n${managedBlock}\n`;

      if (flags.dryRun) {
        console.log('  📄 Would append FF block to: AGENTS.md');
      } else {
        await fs.writeFile(agentsMdPath, newContent);
        if (flags.verbose) {
          console.log('  📄 Appended FF block to: AGENTS.md');
        }
      }
      stats.filesUpdated++;
    }
  } catch {
    // File doesn't exist, create it
    if (flags.dryRun) {
      console.log('  📄 Would create: AGENTS.md');
    } else {
      await fs.writeFile(agentsMdPath, `${managedBlock}\n`);
      if (flags.verbose) {
        console.log('  📄 Created: AGENTS.md');
      }
    }
    stats.filesCreated++;
  }
}

/**
 * Setup developer identity
 */
async function setupDeveloper(flags, stats) {
  const developerPath = path.join(process.cwd(), '.ff', '.developer');

  try {
    await fs.access(developerPath);
    if (flags.verbose) {
      console.log('  ⏭️  Skipped (exists): .ff/.developer');
    }
    stats.filesSkipped++;
  } catch {
    if (flags.dryRun) {
      console.log('  📄 Would create: .ff/.developer');
    } else {
      // Try to get git user name
      let developerName = 'developer';
      try {
        const { execSync } = await import('node:child_process');
        developerName = execSync('git config user.name', { encoding: 'utf-8' }).trim() || 'developer';
      } catch {
        // Git not available, use default
      }
      await fs.writeFile(developerPath, developerName);
      if (flags.verbose) {
        console.log(`  📄 Created: .ff/.developer (${developerName})`);
      }
    }
    stats.filesCreated++;
  }
}

function escapeRegex(string) {
  return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

async function confirm(message) {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  return new Promise((resolve) => {
    rl.question(`${message} (y/N) `, (answer) => {
      rl.close();
      resolve(answer.toLowerCase() === 'y' || answer.toLowerCase() === 'yes');
    });
  });
}

/**
 * Main init function
 */
export async function init(flags) {
  console.log('\n🚀 FF Project Initialization\n');

  if (flags.dryRun) {
    console.log('📋 Dry run mode - no changes will be made\n');
  }

  // Confirm unless --yes
  if (!flags.yes && !flags.dryRun) {
    const proceed = await confirm('Initialize FF in current directory?');
    if (!proceed) {
      console.log('\n❌ Cancelled');
      process.exit(0);
    }
    console.log('');
  }

  const stats = {
    dirsCreated: 0,
    filesCreated: 0,
    filesOverwritten: 0,
    filesSkipped: 0,
    filesUpdated: 0,
  };

  // 1. Copy .agents/skills/
  console.log('📦 Installing skills...');
  const agentsDir = path.join(process.cwd(), '.agents', 'skills');
  await ensureDir(path.join(process.cwd(), '.agents'), flags, stats);
  await ensureDir(agentsDir, flags, stats);
  await copyDir(path.join(TEMPLATE_ROOT, 'agents', 'skills'), agentsDir, flags, stats);

  // 2. Copy .ff/spec/
  console.log('📚 Installing specs...');
  const ffDir = path.join(process.cwd(), '.ff');
  await ensureDir(ffDir, flags, stats);
  await ensureDir(path.join(ffDir, 'spec'), flags, stats);
  await copyDir(path.join(TEMPLATE_ROOT, 'ff', 'spec'), path.join(ffDir, 'spec'), flags, stats);

  // 3. Copy .ff/.gitignore
  await copyFile(
    path.join(TEMPLATE_ROOT, 'ff', '.gitignore'),
    path.join(ffDir, '.gitignore'),
    flags,
    stats
  );

  // 4. Setup .ff/.developer
  console.log('👤 Setting up developer identity...');
  await setupDeveloper(flags, stats);

  // 5. Handle AGENTS.md
  console.log('📝 Configuring AGENTS.md...');
  await handleAgentsMd(flags, stats);

  // Summary
  console.log('\n✨ Done!\n');
  console.log('Summary:');
  if (stats.dirsCreated > 0) console.log(`  📁 Directories created: ${stats.dirsCreated}`);
  if (stats.filesCreated > 0) console.log(`  📄 Files created: ${stats.filesCreated}`);
  if (stats.filesUpdated > 0) console.log(`  📄 Files updated: ${stats.filesUpdated}`);
  if (stats.filesOverwritten > 0) console.log(`  📄 Files overwritten: ${stats.filesOverwritten}`);
  if (stats.filesSkipped > 0) console.log(`  ⏭️  Files skipped: ${stats.filesSkipped}`);

  console.log('\nNext steps:');
  console.log('  1. Review .ff/spec/ and customize for your project');
  console.log('  2. Check .ff/.developer has your name');
  console.log('  3. In Amp, run: load ff-start');
  console.log('');
}
