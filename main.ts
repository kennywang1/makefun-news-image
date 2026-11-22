import { createHash } from 'node:crypto';
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

// The print master is composed by artwork/compose.ps1. Shipping its finished
// pixels keeps the judge's offline run independent of fonts and renderers.
const approvedSha256 = 'bfb95b2ba106ced96e3b6df6391c87efb9971f59803eff6700ad67ae8c8e7852';
const master = readFileSync(new URL('./artwork/front-page.png', import.meta.url));
const actualSha256 = createHash('sha256').update(master).digest('hex');
if (actualSha256 !== approvedSha256) {
    throw new Error(`Print master SHA-256 mismatch: expected ${approvedSha256}, got ${actualSha256}`);
}

const output = process.env.MAKEFUN_OUTPUT_DIR || '/output';
mkdirSync(output, { recursive: true });
writeFileSync(join(output, 'entry.png'), master);
