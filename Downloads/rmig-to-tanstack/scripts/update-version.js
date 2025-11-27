import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Read package.json to get version
const packageJsonPath = path.join(__dirname, '..', 'package.json');
const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));

// Update version.json in public folder
const versionJsonPath = path.join(__dirname, '..', 'public', 'version.json');
const versionData = {
  version: packageJson.version,
  buildTime: new Date().toISOString(),
  name: packageJson.name
};

fs.writeFileSync(versionJsonPath, JSON.stringify(versionData, null, 2));

console.log(`✅ Version updated to ${packageJson.version}`);
