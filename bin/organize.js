#!/usr/bin/env node
'use strict';
const { execFileSync } = require('child_process');
const path = require('path');
const os = require('os');

if (os.platform() !== 'win32') {
  console.error('folder-organizer requires Windows + PowerShell.');
  process.exit(1);
}

const args = process.argv.slice(2);
const targetPath = args.find(a => !a.startsWith('-')) || process.cwd();
const apply = args.includes('-apply') || args.includes('--apply');
const modeArg = args.find(a => a.startsWith('--mode=') || a.startsWith('-mode='));
const mode = modeArg ? modeArg.split('=')[1] : 'content';

const scriptPath = path.join(__dirname, '..', 'scripts', 'organize.ps1');
const psArgs = ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', scriptPath,
  '-TargetPath', targetPath, '-Mode', mode];
if (apply) psArgs.push('-Apply');

try {
  execFileSync('powershell.exe', psArgs, { stdio: 'inherit' });
} catch (e) {
  process.exit(e.status || 1);
}
