--[[	MGL - Mniip's Graphics Library.	Used	as API in Lua console (http://lua.org)	in The Powder Toy (http://powdertoy.co.uk)
	Copyright (C) 2011-2012 mniip

	This script is free software; you can	redistribute it and/or modify it under	the terms of the GNU General Public License	as published by the Free Software	Foundation; either version 2 of the License,	or any later version.
	
	This script is distributed in the hope that	it will be useful, but WITHOUT ANY WARRANTY,	without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR	PURPOSE.  See the GNU General Public License	for more details.
	
	You should have received a copy of the	GNU General Public License along with this	script; if not, write to the Free Software
	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA]]-- mgl={}

-- Clippnig rectangle, if set, any particle outside of it will not be drawn
mgl.cliprect={}

-- Resets clipping rectangle
function mgl.resetcliprect()
mgl.cliprect.x1=0
mgl.cliprect.y1=0
mgl.cliprect.x2=612
mgl.cliprect.y2=383
end
mgl.resetcliprect() --initially it should be reset

-- Sets clipping rectangle, new rectangle is between (x1,y1) and (x2,y2)
function mgl.setcliprect(x1,y1,x2,y2)
mgl.cliprect.x1=x1
mgl.cliprect.y1=y1
mgl.cliprect.x2=x2
mgl.cliprect.y2=y2
end

mgl.drawingmethod=0
-- Gets particle type at (x,y), returns 0 if out of bounds
function mgl.getpixel(x,y)
if x>-1 and y>-1 and x<612 and y<384 then
 if mgl.drawingmethod==0 then
  return tpt.get_property('type',x,y)
 end
else
 return 0
end
end

-- Sets particle at (x,y) to type t
function mgl.putpixel(x,y,t)
if x>-1 and y>-1 and x<612 and y<384 and x>=mgl.cliprect.x1 and y>=mgl.cliprect.y1 and x<=mgl.cliprect.x2 and y<=mgl.cliprect.y2 and not(mgl.getpixel(x,y)==t) then
 if mgl.drawingmethod==0 then
  if not(tpt.get_property('type',x,y)==0) then
   tpt.delete(x,y)
  end
  if not(t==0 or string.upper(t)=='NONE') then
   tpt.create(x,y,t)
  end
 end
end
end

-- draws a circle with center in (x,y) and radius r with type t
function mgl.circle(x,y,r,t)
for i=x,math.ceil(math.sqrt(1/2)*r)+x do
 mgl.putpixel(i,y-math.ceil(r*math.sqrt(1-(i-x)*(i-x)/r/r)),t)
 mgl.putpixel(i,y+math.ceil(r*math.sqrt(1-(i-x)*(i-x)/r/r)),t)
 mgl.putpixel(x+x-i,y-math.ceil(r*math.sqrt(1-(i-x)*(i-x)/r/r)),t)
 mgl.putpixel(x+x-i,y+math.ceil(r*math.sqrt(1-(i-x)*(i-x)/r/r)),t)
end
for i=y,math.ceil(math.sqrt(1/2)*r)+y do
 mgl.putpixel(x-math.ceil(r*math.sqrt(1-(i-y)*(i-y)/r/r)),i,t)
 mgl.putpixel(x+math.ceil(r*math.sqrt(1-(i-y)*(i-y)/r/r)),i,t)
 mgl.putpixel(x-math.ceil(r*math.sqrt(1-(i-y)*(i-y)/r/r)),y+y-i,t)
 mgl.putpixel(x+math.ceil(r*math.sqrt(1-(i-y)*(i-y)/r/r)),y+y-i,t)
end
end

-- draws an ellipse with center in (x,y) and radiuses rx and ry with type t
function mgl.ellipse(x,y,rx,ry,t)
for i=0,rx*rx/math.sqrt(ry*ry+rx*rx) do
 mgl.putpixel(x+i,y+math.sqrt(rx*rx-i*i)/rx*ry,t)
 mgl.putpixel(x-i,y+math.sqrt(rx*rx-i*i)/rx*ry,t)
 mgl.putpixel(x+i,y-math.sqrt(rx*rx-i*i)/rx*ry,t)
 mgl.putpixel(x-i,y-math.sqrt(rx*rx-i*i)/rx*ry,t)
end
for i=0,ry*ry/math.sqrt(ry*ry+rx*rx) do
 mgl.putpixel(x+math.sqrt(ry*ry-i*i)/ry*rx,y+i,t)
 mgl.putpixel(x-math.sqrt(ry*ry-i*i)/ry*rx,y+i,t)
 mgl.putpixel(x+math.sqrt(ry*ry-i*i)/ry*rx,y-i,t)
 mgl.putpixel(x-math.sqrt(ry*ry-i*i)/ry*rx,y-i,t)
end
end

-- draws a filled ellipse with center in (x,y) and radiuses rx and ry with type t
function mgl.fillellipse(x,y,rx,ry,t)
for i=-rx+0.5,rx-0.5 do
 for j=-ry*math.sqrt(1-i*i/rx/rx)+0.5,ry*math.sqrt(1-i*i/rx/rx)-0.5 do
  mgl.putpixel(x+i,y+j,t)
 end
end
end

-- draws a line from (x1,y1) to (x2,y2) with type t
function mgl.line(x1,y1,x2,y2,t)
if ((y2-y1<x2-x1)and(x2<x1))or((x1-x2>y2-y1)) then
 mgl.line(x2,y2,x1,y1,t)
else
 if math.abs(x2-x1)>math.abs(y2-y1) then
  for i=x1,x2 do
   mgl.putpixel(i,math.floor(y1+(i-x1)*(y2-y1)/(x2-x1)),t)
  end
 else
  for i=y1,y2 do
   mgl.putpixel(math.floor(x1+(i-y1)*(x2-x1)/(y2-y1)),i,t)
  end
 end
end
end

-- draws a line from (x1,y1) to (x2,y2) with type t and style st
function mgl.styledline(x1,y1,x2,y2,t,st)
if ((y2-y1<x2-x1)and(x2<x1))or((x1-x2>y2-y1)) then
 mgl.styledline(x2,y2,x1,y1,t,s)
else
 if math.abs(x2-x1)>math.abs(y2-y1) then
  for i=x1,x2 do
   if st[i%st.length]==1 then
    mgl.putpixel(i,math.floor(y1+(i-x1)*(y2-y1)/(x2-x1)),t)
   end
  end
 else
  for i=y1,y2 do
   if st[i%st.length]==1 then
    mgl.putpixel(math.floor(x1+(i-y1)*(x2-x1)/(y2-y1)),i,t)
   end
  end
 end
end
end

-- draws a rectangle from (x1,y1) to (x2,y2) with type t
function mgl.rectangle(x1,y1,x2,y2,t)
mgl.line(x1,y1,x2,y1,t)
mgl.line(x1,y1,x1,y2,t)
mgl.line(x2,y1,x2,y2,t)
mgl.line(x1,y2,x2,y2,t)
end

-- fills shape at (x,y) with type t
function mgl.floodfillin(x,y,t)
local function doflood(x,y,t,b)
 mgl.putpixel(x,y,t)
 if mgl.getpixel(x+1,y)==b then doflood(x+1,y,t,b) end
 if mgl.getpixel(x-1,y)==b then doflood(x-1,y,t,b) end
 if mgl.getpixel(x,y+1)==b then doflood(x,y+1,t,b) end
 if mgl.getpixel(x,y-1)==b then doflood(x,y-1,t,b) end
end
doflood(x,y,t,mgl.getpixel(x,y))
end

-- fills shape at (x,y) with type t until reaches b-colored border
-- REMARK: b - numeric
function mgl.floodfillout(x,y,t,b)
if t==b then
 if b==1 then
  mgl.floodfillout(x,y,2,b)
 else
  mgl.floodfillout(x,y,1,b)
 end
 mgl.floodfillin(x,y,t)
end
if not(mgl.getpixel(x,y)==b or mgl.getpixel(x,y)==t) then
 mgl.putpixel(x,y,t)
 mgl.floodfillout(x+1,y,t,b)
 mgl.floodfillout(x-1,y,t,b)
 mgl.floodfillout(x,y+1,t,b)
 mgl.floodfillout(x,y-1,t,b)
end
end

-- copies a rectangle  from (x1,y1) to (x2,y2), full specifies that do we need additional parameters, returns table
function mgl.copyrect(x1,y1,x2,y2,full)
local rect={}
rect.width=x2-x1
rect.height=y2-y1
if full==0 then
 rect.full=0
else
 rect.full=1
end
for i=x1,x2-1 do
 rect[i-x1]={}
 for j=y1,y2-1 do
  if full==0 then
   rect[i-x1][j-y1]=mgl.getpixel(i,j)
  else
   rect[i-x1][j-y1]={}
   rect[i-x1][j-y1].type=mgl.getpixel(i,j)
   if not (rect[i-x1][j-y1].type==0) then
    rect[i-x1][j-y1].ctype=tpt.get_property('ctype',i,j)
    rect[i-x1][j-y1].temp=tpt.get_property('temp',i,j)
    rect[i-x1][j-y1].tmp=tpt.get_property('tmp',i,j)
    rect[i-x1][j-y1].life=tpt.get_property('life',i,j)
    rect[i-x1][j-y1].tmp2=tpt.get_property('tmp2',i,j)
    rect[i-x1][j-y1].vx=tpt.get_property('vx',i,j)
    rect[i-x1][j-y1].vy=tpt.get_property('vy',i,j)
    rect[i-x1][j-y1].dcolour=tpt.get_property('dcolour',i,j)
   end
  end
 end
end
return rect
end

-- pastes rectangle rect at (x,y)
function mgl.pasterect(x,y,rect)
local w=rect.width
local h=rect.height
local f=rect.full
for i=x,x+w-1 do
 s=''
 for j=y,y+h-1 do
  if f==0 then
   if not(rect[i-x][j-y]==-1) then
    mgl.putpixel(i,j,rect[i-x][j-y])
   end
  else
   mgl.putpixel(i,j,rect[i-x][j-y].type)
   if not (rect[i-x][j-y].type==0) then
    tpt.set_property('ctype',rect[i-x][j-y].ctype,i,j)
    tpt.set_property('temp',rect[i-x][j-y].temp,i,j)
    tpt.set_property('tmp',rect[i-x][j-y].tmp,i,j)
    tpt.set_property('life',rect[i-x][j-y].life,i,j)
    tpt.set_property('tmp2',rect[i-x][j-y].tmp2,i,j)
    tpt.set_property('vx',rect[i-x][j-y].vx,i,j)
    tpt.set_property('vy',rect[i-x][j-y].vy,i,j)
    tpt.set_property('dcolour',rect[i-x][j-y].dcolour,i,j)
   end
  end
 end
end
end

-- draws rectangle from (x1,y1) to (x2,y2) filled with type t
function mgl.fillrect(x1,y1,x2,y2,t)
for i=x1,x2 do
 for j=y1,y2 do
  mgl.putpixel(i,j,t)
 end
end
end

-- edits a horizontal line y of rect, replaces it with res, returns edited table
function mgl.scanhorz(rect,y,res)
local temp=rect
for i=0,rect.width-1 do
 temp[i][y]=res[i+1]
end
return temp
end

-- edits a vertical line x of rect, replaces it with res, returns edited table
function mgl.scanvert(rect,x,res)
local temp=rect
for i=0,rect.height-1 do
 temp[x][i]=res[i+1]
end
return temp
end

function uni(s)
local l=''
for i=1,string.len(s) do
 l=l..string.char(0)..string.sub(s,i,i)
end
return l
end

function mgl.loadfont(filename)
local function readsb(n,a)
local i=0
local l=0
local r=0
for i=1,n do
l=string.byte(f:read(1))
if a==nil then
 r=r+l*256^(i-1)
else
 r=r*256+l
end
end
return r
end
f=io.open(filename,"rb")
local fnt={}
fnt.name=f:read(128)
fnt.credit=f:read(123)
fnt.height=readsb(1)
fnt.kerning=readsb(1)
fnt.spacing=readsb(1)
fnt.default=readsb(2)
local head=f:read(3)
local data=''
local num=0
local t=0
while not(head==nil) do
 num=string.byte(head,1)+string.byte(head,2)*256
 fnt[num]={}
 fnt[num].width=string.byte(head,3)
 for i=0,fnt.height-1 do
  fnt[num][i]=readsb(1+math.floor((string.byte(head,3)-1)/8),1)
 end
 head=f:read(3)
end
f:close()
return fnt
end
-- returns text width if written with font fnt
function mgl.textwidth(text,fnt,param)
local dt=0
for i=1,string.len(text)/2 do
 if not(fnt[string.byte(text,2*i)+string.byte(text,2*i-1)*256]==nil) then
  dt=dt+fnt[string.byte(text,2*i)+string.byte(text,2*i-1)*256].width+fnt.kerning
  if math.floor(param/8)%2==1 then
   dt=dt+1
  end
 end
end
return dt
end

-- draws text at (x,y) with type t and font fnt
-- param:	0:normal
--	 	1:center aligned
--		2:right aligned
--		+4:italic
--		+8:bold
--		+16:underlined
--		+32:striked
function mgl.drawtext(x,y,text,t,fnt,param)
local dt=0
if param%4==1 then
 dt=math.floor(-mgl.textwidth(text,fnt,param)/2)
elseif param%4==2 then
 dt=-mgl.textwidth(text,fnt,param)
end
local ddt=dt
for i=1,string.len(text)/2 do
 if not(fnt[string.byte(text,2*i)+string.byte(text,2*i-1)*256]==nil) then
  for j=0,fnt.height-1 do
   for k=0,fnt[string.byte(text,2*i)+string.byte(text,2*i-1)*256].width-1 do
    if math.floor(fnt[string.byte(text,2*i)+string.byte(text,2*i-1)*256][j]/(2^(fnt[string.byte(text,2*i)+string.byte(text,2*i-1)*256].width-k-1)))%2==1 then
     if math.floor(param/4)%2==1 then
      mgl.putpixel(x+dt+k+math.floor((fnt.height-2-j)/2),y+j,t)
     else
      mgl.putpixel(x+dt+k,y+j,t)
     end
     if math.floor(param/8)%2==1 then
      if math.floor(param/4)%2==1 then
       mgl.putpixel(x+dt+k+1+math.floor((fnt.height-2-j)/2),y+j,t)
      else
       mgl.putpixel(x+dt+k+1,y+j,t)
      end
     end
    end
   end
  end
  dt=dt+fnt[string.byte(text,2*i)+string.byte(text,2*i-1)*256].width+fnt.kerning
  if math.floor(param/8)%2==1 then
   dt=dt+1
  end
 end
end
if math.floor(param/16)%2==1 then
 mgl.line(x+dt-mgl.textwidth(text,fnt,param),y+fnt.height-fnt.spacing,x+dt-1-fnt.kerning,y+fnt.height-fnt.spacing,t)
end
if math.floor(param/32)%2==1 then
 mgl.line(x+dt-mgl.textwidth(text,fnt,param),y+math.floor(fnt.height/2)-fnt.spacing,x+dt-1-fnt.kerning,y+math.floor(fnt.height/2)-fnt.spacing,t)
end
end
xsmono=mgl.loadfont('xsmono.fnt')

function mgl.saverect(x1,y1,x2,y2,filename,name)
f=io.open(filename,"w")
f:write(name..'={}\n')
f:write(name..'.width='..(x2-x1)..'\n')
f:write(name..'.height='..(y2-y1)..'\n')
f:write(name..'.full=0\n')
f:write('for i=0,'..(y2-y1)..' do '..name..'[i]={} end\n')
for i=y1,y2 do
 f:write(name..'=mgl.scanhorz('..name..','..(i-y1)..',{')
 for j=x1,x2 do
  f:write(mgl.getpixel(j,i))
  if j<x2 then
   f:write(',')
  end
 end
 f:write('})\n')
end
f:close()
end

-- these all should be because of TPTOS standard
-- initializes MGL
function mgl.initialize()
end

-- finalizes MGL
function mgl.finalize()
end

-- deletes MGL from memory
function mgl.unload()
mgl=nil
end
