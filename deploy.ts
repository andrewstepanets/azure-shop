import { execSync } from 'child_process';
import * as fs from 'fs';

// Change directory to 'app' and run the build command
execSync('npm run build', { stdio: 'inherit', cwd: './app' });

// Read configuration from deploy-config.json
const config = JSON.parse(fs.readFileSync('./deploy-config.json', 'utf8'));

// Upload the build to Azure Blob Storage with the --overwrite flag
const deployCommand = `az storage blob upload-batch -s '${config.buildPath}' -d '$web' --account-name '${config.storageAccountName}' --overwrite`;
execSync(deployCommand, { stdio: 'inherit' });

console.log('Deployment complete!');
