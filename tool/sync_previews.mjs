// Copies the site's demos into registry/previews, one per component, for `ashlar update
// --preview` to draw a component before and after an update. The site's demos are the one
// source: run this after changing one. Imports point at the gallery's ui folder, as the
// tests' do, and are pointed at the app's own when written there.
// Run from the repository root: node tool/sync_previews.mjs
import fs from 'fs';

const demos = '../ashlar-ui-site/lib/widgets/demos';
const out = 'registry/previews';
const registry = JSON.parse(fs.readFileSync('registry/registry.json', 'utf8'));
fs.mkdirSync(out, { recursive: true });
let n = 0;
for (const f of fs.readdirSync(demos).filter((f) => f.endsWith('.dart'))) {
  const item = f.replace(/\.dart$/, '').replaceAll('_', '-');
  if (!registry[item] || registry[item].block) continue;
  const src = fs
    .readFileSync(`${demos}/${f}`, 'utf8')
    .replaceAll("import '../ui/", "import 'package:ashlar_ui_gallery/ui/");
  fs.writeFileSync(`${out}/${f}`, `// The ${item} picture ashlar update --preview draws, from the site's demo.\n${src}`);
  registry[item].preview = `previews/${f}`;
  n++;
}
// Written back one item a line, as the file is kept.
const lines = Object.entries(registry).map(([k, v]) => `  ${JSON.stringify(k)}: ${JSON.stringify(v).replace(/^\{/, '{ ').replace(/\}$/, ' }').replace(/":/g, '": ').replace(/,"/g, ', "')}`);
fs.writeFileSync('registry/registry.json', `{\n${lines.join(',\n')}\n}\n`);
console.log(`previews: ${n}`);
