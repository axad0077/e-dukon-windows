"""Generate the pure Dart runtime catalog from reviewed ARB files."""
import json, re
from pathlib import Path
root = Path(__file__).resolve().parents[1] / 'lib/src/l10n'
langs = {lang: json.loads((root / f'app_{lang}.arb').read_text()) for lang in ('uz', 'ru', 'en')}
keys = {k for k in langs['uz'] if not k.startswith('@')}
assert all({k for k in data if not k.startswith('@')} == keys for data in langs.values())
catalog = {}
for key in langs['uz']:
    if key.startswith('@'):
        continue
    row = {lang: langs[lang][key] for lang in langs}
    placeholders = {m[0] for m in re.finditer(r'\{\d+\}', row['uz'])}
    assert all({m[0] for m in re.finditer(r'\{\d+\}', value)} == placeholders for value in row.values()), key
    catalog[key] = row
(root / 'catalog.dart').write_text('const messages = <String, Map<String, String>> ' + json.dumps(catalog, ensure_ascii=False, indent=2).replace('$', '\\$') + ';\n')
print(f'Generated {len(catalog)} messages in three languages.')
