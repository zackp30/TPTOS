--[[
	MGL - Mniip's Graphics Library.	Used
	as API in Lua console (http://lua.org)
	in The Powder Toy (http://powdertoy.co.uk)
	Copyright (C) 2011-2012 mniip

	This script is free software; you can
	redistribute it and/or modify it under
	the terms of the GNU General Public
	License as published by the Free Software
	Foundation; either version 2 of the License,
	or any later version.
	
	This script is distributed in the hope that
	it will be useful, but WITHOUT ANY WARRANTY,
	without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR
	PURPOSE. See the GNU General Public License
	for more details.
	
	You should have received a copy of the
	GNU General Public License along with this
	script; if not, write to the Free Software
	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA


]]--

mgl={}

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
f=stream.open(filename,"rb")
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

xsmono_fnt={83,111,109,101,102,111,110,116,110,97,109,101,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,83,111,109,101,99,111,112,121,114,105,103,104,116,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,11,1,1,65,0,32,0,5,0,0,0,0,0,0,0,0,0,0,0,33,0,5,4,4,4,4,4,4,4,0,4,0,0,34,0,5,5,5,0,0,0,0,0,0,0,0,0,35,0,5,10,10,31,10,10,10,31,10,10,0,0,36,0,5,4,14,21,20,14,5,21,14,4,0,0,37,0,5,9,21,10,2,4,8,10,21,18,0,0,38,0,5,12,18,18,20,8,21,18,18,13,0,0,39,0,5,4,4,0,0,0,0,0,0,0,0,0,40,0,5,2,4,8,8,8,8,8,4,2,0,0,41,0,5,8,4,2,2,2,2,2,4,8,0,0,42,0,5,10,4,10,0,0,0,0,0,0,0,0,43,0,5,0,0,4,4,31,4,4,0,0,0,0,44,0,5,0,0,0,0,0,0,0,12,4,8,0,45,0,5,0,0,0,0,31,0,0,0,0,0,0,46,0,5,0,0,0,0,0,0,0,12,12,0,0,47,0,5,1,1,2,2,4,8,8,16,16,0,0,48,0,5,14,19,19,21,21,21,25,25,14,0,0,49,0,5,4,12,20,4,4,4,4,4,31,0,0,50,0,5,14,17,1,2,4,8,16,17,31,0,0,51,0,5,14,17,1,1,14,1,1,17,14,0,0,52,0,5,17,17,17,17,31,1,1,1,1,0,0,53,0,5,31,16,16,16,30,1,1,17,14,0,0,54,0,5,14,17,16,16,31,17,17,17,14,0,0,55,0,5,31,17,2,2,4,4,4,4,4,0,0,56,0,5,14,17,17,17,14,17,17,17,14,0,0,57,0,5,14,17,17,17,15,1,1,17,14,0,0,58,0,5,0,0,0,12,12,0,0,12,12,0,0,59,0,5,0,0,0,12,12,0,0,12,4,8,0,60,0,5,1,2,4,8,16,8,4,2,1,0,0,61,0,5,0,0,0,31,0,31,0,0,0,0,0,62,0,5,16,8,4,2,1,2,4,8,16,0,0,63,0,5,14,17,1,1,2,4,4,0,4,0,0,64,0,5,14,17,19,21,21,19,16,17,14,0,0,65,0,5,14,17,17,17,31,17,17,17,17,0,0,66,0,5,30,17,17,17,30,17,17,17,30,0,0,67,0,5,14,17,16,16,16,16,16,17,14,0,0,68,0,5,30,17,17,17,17,17,17,17,30,0,0,69,0,5,31,16,16,16,30,16,16,16,31,0,0,70,0,5,31,16,16,16,30,16,16,16,16,0,0,71,0,5,14,17,16,16,23,17,17,17,14,0,0,72,0,5,17,17,17,17,31,17,17,17,17,0,0,73,0,5,31,4,4,4,4,4,4,4,31,0,0,74,0,5,3,1,1,1,1,1,1,17,14,0,0,75,0,5,17,17,18,20,24,20,18,17,17,0,0,76,0,5,16,16,16,16,16,16,16,16,31,0,0,77,0,5,17,27,21,17,17,17,17,17,17,0,0,78,0,5,17,25,21,19,17,17,17,17,17,0,0,79,0,5,14,17,17,17,17,17,17,17,14,0,0,80,0,5,30,17,17,17,30,16,16,16,16,0,0,81,0,5,14,17,17,17,17,17,21,18,13,0,0,82,0,5,30,17,17,17,30,17,17,17,17,0,0,83,0,5,14,17,16,16,14,1,1,17,14,0,0,84,0,5,31,21,4,4,4,4,4,4,4,0,0,85,0,5,17,17,17,17,17,17,17,17,14,0,0,86,0,5,17,17,17,17,17,17,17,10,4,0,0,87,0,5,17,17,17,17,17,17,21,21,10,0,0,88,0,5,17,17,17,10,4,10,17,17,17,0,0,89,0,5,17,17,17,10,4,4,4,4,4,0,0,90,0,5,31,17,1,2,4,8,16,17,31,0,0,91,0,5,14,8,8,8,8,8,8,8,14,0,0,92,0,5,16,16,8,8,4,2,2,1,1,0,0,93,0,5,14,2,2,2,2,2,2,2,14,0,0,94,0,5,4,10,17,0,0,0,0,0,0,0,0,95,0,5,0,0,0,0,0,0,0,0,31,0,0,96,0,5,4,2,0,0,0,0,0,0,0,0,0,97,0,5,0,0,0,0,14,1,15,17,15,0,0,98,0,5,16,16,16,16,30,17,17,17,30,0,0,99,0,5,0,0,0,0,14,17,16,17,14,0,0,100,0,5,1,1,1,1,15,17,17,17,15,0,0,101,0,5,0,0,0,0,14,17,31,16,14,0,0,102,0,5,7,8,8,8,30,8,8,8,0,0,0,103,0,5,0,0,0,0,14,17,17,17,15,1,14,104,0,5,16,16,16,16,30,17,17,17,17,0,0,105,0,5,0,0,0,4,0,12,4,4,31,0,0,106,0,5,0,0,0,1,0,14,1,1,1,17,14,107,0,5,16,16,17,18,20,24,20,18,17,0,0,108,0,5,28,4,4,4,4,4,4,4,31,0,0,109,0,5,0,0,0,0,26,21,21,21,21,0,0,110,0,5,0,0,0,0,30,17,17,17,17,0,0,111,0,5,0,0,0,0,14,17,17,17,14,0,0,112,0,5,0,0,0,0,30,17,17,17,30,16,16,113,0,5,0,0,0,0,15,17,17,17,15,1,1,114,0,5,0,0,0,0,22,25,16,16,16,0,0,115,0,5,0,0,0,0,15,16,14,1,30,0,0,116,0,5,8,8,8,8,31,8,8,8,7,0,0,117,0,5,0,0,0,0,17,17,17,17,15,0,0,118,0,5,0,0,0,0,17,17,17,10,4,0,0,119,0,5,0,0,0,0,17,17,21,21,10,0,0,120,0,5,0,0,0,0,17,10,4,10,17,0,0,121,0,5,0,0,0,0,17,17,17,17,15,1,30,122,0,5,0,0,0,0,31,2,4,8,31,0,0,123,0,5,2,4,4,4,8,4,4,4,2,0,0,124,0,5,4,4,4,4,0,4,4,4,4,0,0,125,0,5,8,4,4,4,2,4,4,4,8,0,0,126,0,5,0,0,0,0,128,21,2,0,0,0,0,127,0,5,0,0,31,17,17,17,17,31,0,0,0}
xsmono=mgl.loadfont(xsmono_fnt)

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
