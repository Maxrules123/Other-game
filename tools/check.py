#!/usr/bin/env python3
"""Compile real Luau sources, execute domain tests with engine mocks, build with Rojo.
Usage: python tools/check.py --luau /path/to/luau --rojo /path/to/rojo
Uses executables from PATH by default. Does not claim Roblox engine playtesting.
"""
import argparse, json, pathlib, shutil, subprocess, tempfile
ROOT = pathlib.Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser()
p.add_argument('--luau', default=shutil.which('luau'))
p.add_argument('--rojo', default=shutil.which('rojo'))
args = p.parse_args()
if not args.luau or not args.rojo:
    p.error('Install Luau CLI and Rojo, or pass --luau and --rojo.')
compiler = str(pathlib.Path(args.luau).with_name('luau-compile'))
files = sorted((ROOT / 'src').rglob('*.luau'))
for path in files:
    result = subprocess.run([compiler, str(path)], capture_output=True, text=True)
    if result.returncode:
        raise SystemExit(result.stderr)
print(f'PASS: {len(files)} Luau files compiled')
modules = ['shared/Config', 'shared/Rules', 'server/MissionService', 'server/InventoryService', 'server/PlayerDataService', 'server/GameService']
bundle = 'local Sources = {}\n'
for module in modules:
    source = (ROOT / 'src' / (module + '.luau')).read_text()
    bundle += 'Sources[' + json.dumps(module.split('/')[-1]) + '] = [====[\n' + source + '\n]====]\n'
bundle += (ROOT / 'tests' / 'domain.luau').read_text()
with tempfile.TemporaryDirectory() as tmp:
    test = pathlib.Path(tmp) / 'domain.luau'
    test.write_text(bundle)
    subprocess.run([args.luau, str(test)], check=True)
    subprocess.run([args.rojo, 'build', str(ROOT/'default.project.json'), '-o', str(pathlib.Path(tmp)/'game.rbxlx')], check=True)
print('PASS: Rojo build. Roblox Studio runtime checks remain manual; see TESTING.md.')
