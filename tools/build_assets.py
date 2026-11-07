#!/usr/bin/env python3
"""Author the original After Hours mesh/PBR source pack. Requires Pillow and NumPy.
No downloaded models or textures. OBJ units are Roblox studs, Y up, front -Z.
"""
from pathlib import Path
import math, json
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]/'assets'/'source'
ROOT.mkdir(parents=True,exist_ok=True)
TEX=ROOT/'textures'; TEX.mkdir(exist_ok=True)
rng=np.random.default_rng(4026); n=512
y,x=np.mgrid[:n,:n]
noise=rng.normal(0,1,(n,n))
materials={}
for kind in ['brick','asphalt','wood','fabric','paint']:
 if kind=='brick':
  bx=(x+((y//64)%2)*64)%128; by=y%64; edge=np.minimum.reduce([bx,127-bx,by,63-by]); brick=edge>4
  base=np.where(brick[:,:,None],np.array([112,79,70]),np.array([76,78,78])); detail=noise*3+np.sin(x/8)*1.5
  h=np.where(brick,0.75,0.28)+noise*.016; rough=np.where(brick,210,230)
 elif kind=='asphalt':
  base=np.full((n,n,3),[58,63,68]); detail=noise*5; h=noise*.04; rough=np.full((n,n),225)
 elif kind=='wood':
  grain=np.sin(y/n*math.pi*80+np.sin(x/n*math.pi*4)*1.4)+0.4*np.sin(y/n*math.pi*200)
  base=np.full((n,n,3),[133,99,69]); detail=grain*11+noise*2; h=grain*.07+noise*.01; rough=190-grain*10
 elif kind=='fabric':
  weave=np.cos(x/n*math.pi*256)*np.cos(y/n*math.pi*256)
  base=np.full((n,n,3),[82,116,112]); detail=weave*9+noise*2; h=weave*.06; rough=np.full((n,n),235)
 else:
  base=np.full((n,n,3),[106,138,133]); detail=noise*1.7; h=noise*.002; rough=np.full((n,n),96)
 rgb=np.uint8(np.clip(base+detail[:,:,None],0,255)); Image.fromarray(rgb).quantize(colors=96,dither=Image.Dither.NONE).save(TEX/f'{kind}_color.png',optimize=True)
 dx=(np.roll(h,-1,axis=1)-np.roll(h,1,axis=1))*2; dy=(np.roll(h,-1,axis=0)-np.roll(h,1,axis=0))*2
 normals=np.dstack((-dx,-dy,np.ones((n,n)))); normals/=np.linalg.norm(normals,axis=2)[:,:,None]
 Image.fromarray(np.uint8((normals*.5+.5)*255)).quantize(colors=256,dither=Image.Dither.NONE).save(TEX/f'{kind}_normal.png',optimize=True)
 Image.fromarray(np.uint8(np.clip(rough,0,255))).save(TEX/f'{kind}_roughness.png')
 materials[kind]={'color':f'textures/{kind}_color.png','normal':f'textures/{kind}_normal.png','roughness':f'textures/{kind}_roughness.png','size':[512,512]}
mtl=[]
for name,kind,color,metal in [('Paint','paint',(1,1,1),.5),('Wood','wood',(1,1,1),0),('Fabric','fabric',(1,1,1),0),('Steel','paint',(.34,.4,.45),.8),('Chrome','paint',(.8,.85,.9),.95),('Rubber','asphalt',(.35,.35,.35),0),('Glass','paint',(.16,.25,.3),.1),('Light','paint',(1,.88,.65),.1),('Foliage','paint',(.32,.7,.35),0)]:
 mtl.extend([f'newmtl {name}',f'Kd {color[0]} {color[1]} {color[2]}',f'Pm {metal}','Pr 0.65' if name in ['Wood','Fabric','Rubber'] else 'Pr 0.3', 'd 0.45' if name=='Glass' else 'd 1.0',f'map_Kd textures/{kind}_color.png',f'map_Bump textures/{kind}_normal.png',f'map_Pr textures/{kind}_roughness.png',''])
(ROOT/'AfterHours.mtl').write_text('\n'.join(mtl))
class Mesh:
 def __init__(self,name): self.name=name; self.verts=[]; self.uv=[]; self.normals=[]; self.faces=[]
 def face(self,points,material='Paint'):
  a,b,c=np.array(points[:3],dtype=float); normal=np.cross(b-a,c-a); length=np.linalg.norm(normal)
  if length<1e-8:return
  normal/=length; start=len(self.verts)
  for i,p in enumerate(points): self.verts.append(tuple(p)); self.normals.append(tuple(normal)); self.uv.append([(0,0),(1,0),(1,1),(0,1)][i%4])
  for i in range(1,len(points)-1): self.faces.append(((start+1,start+i+1,start+i+2),material))
 def box(self,center,size,material='Paint',bevel=.08):
  cx,cy,cz=center; w,h,d=(v/2 for v in size); b=min(bevel,w*.3,h*.3,d*.3)
  outline=[(-w+b,-d),(w-b,-d),(w,-d+b),(w,d-b),(w-b,d),(-w+b,d),(-w,d-b),(-w,-d+b)]
  rings=[]
  for height,shrink in [(-h,b),(-h+b,0),(h-b,0),(h,b)]:
   rings.append([(cx+vx*(1-shrink/w),cy+height,cz+vz*(1-shrink/d)) for vx,vz in outline])
  self.face(rings[0],material); self.face(list(reversed(rings[-1])),material)
  for k in range(3):
   for i in range(8): self.face([rings[k][i],rings[k+1][i],rings[k+1][(i+1)%8],rings[k][(i+1)%8]],material)
 def cylinder(self,center,radius,length,material='Steel',axis='X',segments=24):
  cx,cy,cz=center
  def p(a,t):
   u,v=math.cos(t)*radius,math.sin(t)*radius
   return (cx+a,cy+u,cz+v) if axis=='X' else ((cx+u,cy+a,cz+v) if axis=='Y' else (cx+u,cy+v,cz+a))
  rings=[[p(a,2*math.pi*i/segments) for i in range(segments)] for a in [-length/2,length/2]]
  self.face(rings[0] if axis=="Y" else list(reversed(rings[0])),material); self.face(list(reversed(rings[1])) if axis=="Y" else rings[1],material)
  for i in range(segments): self.face(([rings[0][i],rings[1][i],rings[1][(i+1)%segments],rings[0][(i+1)%segments]] if axis=="Y" else [rings[0][i],rings[0][(i+1)%segments],rings[1][(i+1)%segments],rings[1][i]]),material)
 def ellipsoid(self,center,size,material='Foliage'):
  cx,cy,cz=center;rx,ry,rz=(n/2 for n in size);rings=[]
  for lat in range(7):
   phi=-1.45+lat*2.9/6
   rings.append([(cx+rx*math.cos(phi)*math.cos(i*math.pi/6),cy+ry*math.sin(phi),cz+rz*math.cos(phi)*math.sin(i*math.pi/6)) for i in range(12)])
  self.face(rings[0],material);self.face(list(reversed(rings[-1])),material)
  for lat in range(6):
   for i in range(12):self.face([rings[lat][i],rings[lat+1][i],rings[lat+1][(i+1)%12],rings[lat][(i+1)%12]],material)
 def write(self):
  lines=['# Original After Hours asset / Y up / studs','mtllib AfterHours.mtl','o '+self.name]
  lines += ['v %.6f %.6f %.6f'%v for v in self.verts]
  lines += ['vt %.6f %.6f'%uv for uv in self.uv]
  lines += ['vn %.6f %.6f %.6f'%v for v in self.normals]
  last=None
  for face,mat in self.faces:
   if mat!=last: lines.extend(['g '+mat,'usemtl '+mat]);last=mat
   lines.append('f '+' '.join(f'{i}/{i}/{i}' for i in face))
  (ROOT/(self.name+'.obj')).write_text('\n'.join(lines)+'\n')
  return {'vertices':len(self.verts),'triangles':len(self.faces),'bounds':[list(np.min(self.verts,axis=0)),list(np.max(self.verts,axis=0))]}
models={}
for is_van in [False,True]:
 m=Mesh('VanBody' if is_van else 'SedanBody')
 m.box((0,-.1,0),(6.1,1.5,12.5 if is_van else 10.8),bevel=.18)
 m.box((0,.9,-4.2),(5.8,.55,3.1),bevel=.16)
 m.box((0,3.2,-2.5 if is_van else -.2),(5.45,.34,4 if is_van else 4.8),bevel=.15)
 if is_van:
  m.box((0,1.95,2),(5.9,4.5,7),bevel=.22)
  for side in [-1,1]:
   m.box((side*1.42,1.95,5.55),(2.65,3.8,.16),bevel=.06)
   m.box((side*.45,1.8,5.69),(.65,.17,.18),'Chrome',.04)
   for height in [.6,1,3.6]:m.box((side*3, height, 2),(.09,.09,6.4),'Steel',.025)
 else:
  m.box((0,.8,4),(5.8,.65,2.6),bevel=.16)
  m.face([(-2.5,1.1,2.8),(2.5,1.1,2.8),(2.45,3,1.7),(-2.45,3,1.7)],'Glass')
 m.face([(-2.55,1.05,-4.15),(-2.45,3.05,-3.55),(2.45,3.05,-3.55),(2.55,1.05,-4.15)],'Glass')
 for side in [-1,1]:
  m.box((side*2.72,2,-2.1),(.12,1.8,2.7),'Glass',.03)
  for z in [-3.7,-.65]:m.box((side*2.78,2,z),(.2,2.3,.2),bevel=.04)
  m.box((side*3.35,1.85,-3.15),(.45,.7,.85),bevel=.12)
  m.box((side*3.05,.8,-1),(.18,.18,.7),'Chrome',.04)
  m.box((side*1.85,.48,-5.75),(1.5,.5,.2),'Light',.06)
  m.box((side*1.85,.55,6.32 if is_van else 5.48),(1.3,.38,.15),'Light',.04)
 m.box((0,-.55,-5.85),(5.9,.35,.3),'Steel',.06)
 m.box((0,.4,-5.82),(2.1,.45,.2),'Steel',.03)
 for n in range(-3,4):m.box((n*.25,.4,-5.95),(.08,.35,.04),'Chrome',.01)
 models[m.name]=m.write()
m=Mesh('Wheel');m.cylinder((0,0,0),1.175,.8,'Rubber');m.cylinder((.43,0,0),.7,.08,'Chrome')
for a in range(8):
 t=a*math.pi/4;m.box((.49,math.cos(t)*.38,math.sin(t)*.38),(.1,.22,.22),'Steel',.025)
models[m.name]=m.write()
m=Mesh('Sofa');m.box((0,1.2,0),(9,1,3.5),'Fabric',.18)
for side in [-1,1]:
 m.box((side*4.2,2.1,0),(1.1,2.2,3.7),'Fabric',.2)
 for z in [-1.3,1.3]:m.box((side*3.6,.5,z),(.45,1,.45),'Wood',.08)
for n in [-1,0,1]:m.box((n*2.45,1.95,-.2),(2.3,.7,3),'Fabric',.14);m.box((n*2.45,2.9,1.4),(2.35,2.2,.7),'Fabric',.18)
models[m.name]=m.write()
m=Mesh('Chair');m.box((0,2,0),(2.6,.45,2.6),'Wood',.18);m.box((0,3.6,1.1),(2.6,1.2,.4),'Wood',.16)
for x_ in [-1,1]:
 for z_ in [-1,1]:m.cylinder((x_,1,z_),.1,2,'Steel','Y',12)
 m.cylinder((x_,3,1.1),.1,2,'Steel','Y',12)
models[m.name]=m.write()
m=Mesh('Locker')
for n in [-1,0,1]:
 m.box((n*2.75,3.5,0),(2.6,7,2.2),'Steel',.08);m.box((n*2.75,3.5,-1.16),(2.35,6.6,.12),'Paint',.03)
 for y_ in [5.4,5.7,6.0]:m.box((n*2.75,y_,-1.24),(1.4,.07,.03),'Rubber',.01)
 m.box((n*2.75+.8,3.5,-1.28),(.12,.7,.12),'Chrome',.02)
models[m.name]=m.write()
m=Mesh('Streetlamp');m.cylinder((0,5.5,0),.16,11,'Steel','Y',16);m.box((0,11,-1.1),(.25,.25,2.4),'Steel');m.box((0,10.8,-2),(1.7,.35,2),'Steel',.12);m.box((0,10.55,-2),(1.3,.06,1.6),'Light',.02);m.cylinder((0,.25,0),.65,.5,'Steel','Y',16);models[m.name]=m.write()
m=Mesh('Dumpster');m.box((0,2,0),(7,4,4),'Steel',.18);m.box((0,4.15,0),(7.4,.3,4.4),'Paint',.1)
for side in [-1,1]:
 m.box((side*3.65,2.7,0),(.2,.2,1.8),'Chrome')
 for z_ in [-1.4,1.4]:m.cylinder((side*2.7,.15,z_),.45,.3,'Rubber','X',16)
models[m.name]=m.write()
m=Mesh('Tree');m.cylinder((0,3.5,0),.45,7,'Wood','Y',12)
for center,size in [((0,8.5,0),(5.4,5.8,5.2)),((-2.3,7,0),(4.8,5.2,4.8)),((2.1,7.6,.6),(4.6,5.3,4.8)),((0,7.3,-2),(4.6,4.8,4.8))]:m.ellipsoid(center,size)
models[m.name]=m.write()
manifest={'license':'Original project assets; project owner may use, edit and publish these with the game. No third-party model or texture dependencies.','coordinateSystem':'Y up, front -Z, units = Roblox studs','models':models,'textures':materials}
(ROOT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('Authored',len(models),'OBJ models,',len(materials)*3,'PBR texture maps;',sum(x['triangles'] for x in models.values()),'triangles total')
