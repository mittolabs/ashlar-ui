// Puts a doc comment above each public field that has none, from tool/field_docs.json:
// "Class.field" first, then "field". Splits `final T a, b;` when the two differ.
// Usage: node tool/insert_docs.mjs registry/*.dart
import fs from 'node:fs';

const docs = JSON.parse(fs.readFileSync(new URL('./field_docs.json', import.meta.url), 'utf8'));
const wrap = (text, indent) => {
  const out = [];
  let line = '';
  for (const word of text.split(' ')) {
    if ((indent + '/// ' + line + ' ' + word).length > 90 && line) {
      out.push(`${indent}/// ${line}`);
      line = word;
    } else line = line ? `${line} ${word}` : word;
  }
  if (line) out.push(`${indent}/// ${line}`);
  return out;
};
let added = 0;
for (const file of process.argv.slice(2)) {
  const lines = fs.readFileSync(file, 'utf8').split('\n');
  const out = [];
  let owner = null;
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const decl = line.match(/^(?:abstract |final |sealed |base )*(?:class|enum|extension|mixin) (\w+)/);
    if (decl) owner = decl[1];
    const field = line.match(/^(\s{2})final (.+?) ((?:\w+)(?:, \w+)*);$/);
    // The line before, past annotations: a doc comment means it has one.
    let k = out.length - 1;
    while (k >= 0 && out[k].trim().startsWith('@')) k--;
    const documented = k >= 0 && out[k].trim().startsWith('///');
    if (field && owner && !documented) {
      const [, indent, type, names] = field;
      const list = names.split(', ');
      const found = list.map((n) => docs[`${owner}.${n}`] ?? (owner.startsWith('_') && !owner.startsWith('_Cartesian') ? undefined : docs[n]));
      if (found.every((d) => d)) {
        if (new Set(found).size === 1) {
          out.push(...wrap(found[0], indent), line);
        } else {
          list.forEach((n, j) => {
            if (j > 0) out.push('');
            out.push(...wrap(found[j], indent), `${indent}final ${type} ${n};`);
          });
        }
        added += list.length;
        continue;
      }
    }
    out.push(line);
  }
  fs.writeFileSync(file, out.join('\n'));
}
console.log(`documented ${added} fields`);
