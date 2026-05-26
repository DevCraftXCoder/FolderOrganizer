#!/usr/bin/env node
'use strict';
const { execFileSync } = require('child_process');
const path = require('path');
const os = require('os');

if (os.platform() !== 'win32') {
  console.log('folder-organizer is Windows-only. PowerShell setup skipped on', os.platform());
  process.exit(0);
}

const installScript = path.join(__dirname, 'install.ps1');

try {
  execFileSync('powershell.exe', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', installScript], {
    stdio: 'inherit'
  });
} catch (e) {
  console.error('\nSetup failed. Run manually:');
  console.error('  powershell -File "' + installScript + '"');
  process.exit(0); // non-fatal — scripts still usable via npx/node
}
