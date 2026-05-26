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
const keepMenu = args.includes('--keep-classic-menu');

const scriptPath = path.join(__dirname, '..', 'scripts', 'uninstall.ps1');
const psArgs = ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', scriptPath];
if (keepMenu) psArgs.push('-KeepClassicMenu');

try {
  execFileSync('powershell.exe', psArgs, { stdio: 'inherit' });
} catch (e) {
  process.exit(e.status || 1);
}
