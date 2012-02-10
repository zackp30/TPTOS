--`MODULE SYSTEM "tptos main module"

-------------------------------------------------------------------------------
--Common math functions and constants                                        --
-------------------------------------------------------------------------------

pi=     3.14159265358979323
pi2=	6.28318530717958648
pi0d5=  1.57079632679489662
e=      2.71828182845904524
sqrt2=  1.41421356237309505
phi=    1.61803398874989485
phiang= 2.39996322972865332
ln2=    0.69314718055994531
log2e=  1.44269504088896341
log10e= 0.43429448190325183
sqrt0d5=0.70710678118654752
ln10=   2.30258509299404568
maxval= 1.7976931348623     *10^308
minval= 0.5562684646268     *10^(-308)

function abs(x)
 if x<0 then
  return -x
 else
  return x
 end
end

function sign(x)
 if x<0 then
  return -1
 elseif x>0 then
  return 1
 else
  return 0
 end
end

function sqrt(x)
 return math.sqrt(x)
end

function sqrtabs(x)
 if x<0 then
  return -math.sqrt(-x)
 else
  return math.sqrt(x)
 end
end

function sin(x)
 return math.sin(x)
end

function cos(x)
 return math.cos(x)
end

function tan(x)
 return math.sin(x)/math.cos(x)
end

function cot(x)
 return math.cos(x)/math.sin(x)
end

function sec(x)
 return 1/math.cos(x)
end

function csc(x)
 return 1/math.sin(x)
end

function asin(x)
 return math.atan(x/sqrt(1-x*x))
end

function acos(x)
 return math.atan(sqrt(1-x*x)/x)
end

function atan(x)
 return math.atan(x)
end

function acot(x)
 return math.atan(1/x)
end

function asec(x)
 return acos(1/x)
end

function acsc(x)
 return asin(1/x)
end

function sinh(x)
 return math.sinh(x)
end

function cosh(x)
 return math.sinh(x)
end

function tanh(x)
 return math.tanh(x)
end

function ln(x)
 return math.log(x)
end

function log(x,y)
 return math.log(x)/math.log(y)
end

function hypot(x,y)
 return math.sqrt(x*x+y*y)
end

function random(x,y)
 return math.random(x,y)
end

function floor(x)
 return math.floor(x)
end

function ceil(x)
 return math.ceil(x)
end

function round(x)
 return math.floor(x+0.5)
end

-------------------------------------------------------------------------------
--Handle operations                                                          --
-------------------------------------------------------------------------------

tabledata={}
index_min=0
index_max=0
function getTable(index)
 return {["table"]=tabledata[index],["index"]=index}
end
function createTable()
 while not(tabledata[index_min]==nil) do
  index_min=index_min+1
  if index_min>index_max then index_max=index_min end
 end
 tabledata[index_min]={}
 index_min=index_min+1
 if index_min>index_max then index_max=index_min end
 return index_min-1
end
function freeTable(index)
 tabledata[index]=nil
 if index==index_max-1 then index_max=index end
 index_min=index
end
function pushTable(index,table)
 local function copytable(from,to)
  for k in pairs(from) do
   if type(from[k])=='table' then
    to[k]={}
    copytable(from[k],to[k])
   else
    to[k]=from[k]
   end
  end
 end
 handle=getTable(index).table
 copytable(table,handle)
end
function duplicateTable(index)
 handle=createTable()
 handle_dest=getTable(handle).table
 handle_src=getTable(index).table
 local function copytable(from,to)
  for k in pairs(from) do
   if type(from[k])=='table' then
    to[k]={}
    copytable(from[k],to[k])
   else
    to[k]=from[k]
   end
  end
 end
 copytable(handle_src,handle_dest)
end

-------------------------------------------------------------------------------
--Streaming                                                                  --
-------------------------------------------------------------------------------

stream={}
stream.smClosed=0
stream.smFromFile=1
stream.smToFile=2
stream.smFromTable=3
stream.smToTable=4
stream.smFromStream=5
stream.smToFile=6
stream.streamPrototable={
	["type"]="Stream",
	["filename"]="",
	["fileobj"]=nil,
	["tablelink"]=nil,
	["tableptr"]=0,
	["mode"]=stream.smClosed,
	["read"]=function(self,len)
 if self.mode==smFromFile then
  return self.fileobj:read(len)
 elseif self.mode==smFromTable then
  s=''
  if not(self.tablelink[self.tableptr]==nil) then
   for i=1,len do
    self.tableptr=self.tableptr+1
    if self.tablelink[self.tableptr]==nil then break end
    s=s..string.char(self.tablelink[self.tableptr])
   end
  end
  return s
 elseif self.mode==smFromStream then
  return self.tableptr:read(len)
 end
	end,
	["write"]=function(self,str)
 if self.mode==smToFile then
  self.fileobj:write(str)
 elseif self.mode==smToTable then
  for i=1,string.len(str) do
   self.tablelink[self.tableptr+i]=string.byte(string.sub(str,i,i))
  end
  self.tableptr=self.tableptr+string.len(str)
 elseif self.mode==smToStream then
  self.tablelink:write(str)
 end
	end,
	["open"]=function(self)
 if self.mode==smToFile then
  self.fileobj=io.open(self.filename,'wb')
 elseif self.mode==smToTable then
  self.tableptr=0
 elseif self.mode==smToStream then
  self.tablelink:open()
 elseif self.mode==smFromFile then
  self.fileobj=io.open(self.filename,'rb')
 elseif self.mode==smFromTable then
  self.tableptr=0
 elseif self.mode==smFromStream then
  self.tablelink:open()
 end
	end,
	["close"]=function(self)
 if self.mode==smToFile then
  self.fileobj:close()
 elseif self.mode==smToStream then
  self.tablelink:close()
 elseif self.mode==smFromFile then
  self.fileobj:close()
 elseif self.mode==smFromStream then
  self.tablelink:close()
 end
	end
}
stream.streamPrototype=createTable()
pushTable(stream.streamPrototype,stream.streamPrototable)

-------------------------------------------------------------------------------
--Time                                                                       --
-------------------------------------------------------------------------------

time={}
setmetatable(time,{
	["__index"]=function(table,key)
 if key=='seconds' then
  return os.date('*t').sec
 elseif key=='minutes' then
  return os.date('*t').min
 elseif key=='hours' then
  return os.date('*t').hour
 elseif key=='days' then
  return os.date('*t').yday
 elseif key=='years' then
  return os.date('*t').year
 elseif key=='day' then
  return os.date('*t').day
 elseif key=='month' then
  return os.date('*t').month
 elseif key=='total' then
  return os.time(os.date('*t'))
 elseif key=='_total' then
  t=os.date('*t')
  return (t.year-1970)*31536000+(t.yday+math.floor((t.year-2)/4-493))*86400+t.hour*3600+t.min*60+t.sec-14400
 end
	end
})

-------------------------------------------------------------------------------
--Bitwise math                                                               --
-------------------------------------------------------------------------------

function bnot(a)
 res=0
 for i=0,7 do
  if math.floor(a/(2^i))%2==0 then
   res=res+2^i
  end
 end
 return res
end

function wnot(a)
 res=0
 for i=0,15 do
  if math.floor(a/(2^i))%2==0 then
   res=res+2^i
  end
 end
 return res
end

function dnot(a)
 res=0
 for i=0,31 do
  if math.floor(a/(2^i))%2==0 then
   res=res+2^i
  end
 end
 return res
end

function band(a,b)
 res=0
 for i=0,7 do
  if math.floor(a/(2^i))%2==1 and math.floor(b/(2^i))%2==1 then
   res=res+2^i
  end
 end
 return res
end

function wand(a,b)
 res=0
 for i=0,15 do
  if math.floor(a/(2^i))%2==1 and math.floor(b/(2^i))%2==1 then
   res=res+2^i
  end
 end
 return res
end

function dand(a,b)
 res=0
 for i=0,31 do
  if math.floor(a/(2^i))%2==1 and math.floor(b/(2^i))%2==1 then
   res=res+2^i
  end
 end
 return res
end

function bor(a,b)
 res=0
 for i=0,7 do
  if math.floor(a/(2^i))%2==1 or math.floor(b/(2^i))%2==1 then
   res=res+2^i
  end
 end
 return res
end

function wor(a,b)
 res=0
 for i=0,15 do
  if math.floor(a/(2^i))%2==1 or math.floor(b/(2^i))%2==1 then
   res=res+2^i
  end
 end
 return res
end

function dor(a,b)
 res=0
 for i=0,31 do
  if math.floor(a/(2^i))%2==1 or math.floor(b/(2^i))%2==1 then
   res=res+2^i
  end
 end
 return res
end

function bxor(a,b)
 res=0
 for i=0,7 do
  if not(math.floor(a/(2^i))%2==math.floor(b/(2^i))%2) then
   res=res+2^i
  end
 end
 return res
end

function wxor(a,b)
 res=0
 for i=0,15 do
  if not(math.floor(a/(2^i))%2==math.floor(b/(2^i))%2) then
   res=res+2^i
  end
 end
 return res
end

function dxor(a,b)
 res=0
 for i=0,31 do
  if not(math.floor(a/(2^i))%2==math.floor(b/(2^i))%2) then
   res=res+2^i
  end
 end
 return res
end

-------------------------------------------------------------------------------
--Miscellaneous functions                                                    --
-------------------------------------------------------------------------------

environment={}
setmetatable(environment,{
	["__index"]=function(table,key)
 return os.getenv(key)
	end
})

function downloadfile(url,filename)
 os.execute('httpretv '..url..' '..filename)
end

function viewexec(command,filename)
 os.execute(command..'>'..filename)
end