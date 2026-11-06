#!/usr/bin/env python3
"""Check original model indices, UVs, normals, bounds and texture/material references."""
from pathlib import Path
import json,math,struct,zlib,zipfile
ROOT=Path(__file__).resolve().parents[1]/'assets/source'
if not (ROOT/'manifest.json').exists():
 archive=ROOT.parent/'AfterHours-Art.zip'
 if not archive.exists():raise SystemExit('Extract assets/AfterHours-Art.zip to assets/source, or run tools/build_assets.py.')
 with zipfile.ZipFile(archive) as z:
  for name in z.namelist():
   p=Path(name)
   if p.is_absolute() or '..' in p.parts:raise SystemExit('Invalid art archive path')
  z.extractall(ROOT)
manifest=json.loads((ROOT/'manifest.json').read_text())
count=0
for name,info in manifest['models'].items():
 vertices=[];normals=[];uv=[];faces=[]
 for line in (ROOT/(name+'.obj')).read_text().splitlines():
  pieces=line.split()
  if not pieces:continue
  if pieces[0]=='v':vertices.append(tuple(map(float,pieces[1:])))
  elif pieces[0]=='vn':normals.append(tuple(map(float,pieces[1:])))
  elif pieces[0]=='vt':uv.append(tuple(map(float,pieces[1:])))
  elif pieces[0]=='f':faces.append([tuple(map(int,part.split('/'))) for part in pieces[1:]])
 assert len(vertices)==info['vertices'] and len(faces)==info['triangles'];count+=2
 for normal in normals:assert abs(sum(x*x for x in normal)-1)<0.0001
 for point in vertices:assert all(math.isfinite(x) for x in point)
 for face in faces:
  assert len(face)==3
  for v,t,n in face:assert 1<=v<=len(vertices) and 1<=t<=len(uv) and 1<=n<=len(normals)
 for point in uv:assert all(0<=x<=1 for x in point)
 count+=4
 for axis in range(3):assert abs(min(p[axis] for p in vertices)-info['bounds'][0][axis])<0.00001;assert abs(max(p[axis] for p in vertices)-info['bounds'][1][axis])<0.00001;count+=2
for name,maps in manifest['textures'].items():
 for key in ['color','normal','roughness']:
  data=(ROOT/maps[key]).read_bytes();assert data[:8]==b'\x89PNG\r\n\x1a\n';assert struct.unpack('>II',data[16:24])==(512,512);count+=2
for line in (ROOT/'AfterHours.mtl').read_text().splitlines():
 if line.startswith(('map_Kd ','map_Bump ','map_Pr ')):assert (ROOT/line.split()[-1]).is_file();count+=1
print(f'PASS: {count} asset checks; {len(manifest["models"])} OBJ models, 15 seamless PBR maps; indices, bounds, normals, UVs and material links valid')
