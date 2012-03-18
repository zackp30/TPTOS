--`MODULE SYSTEM "tptos main module"

-------------------------------------------------------------------------------
--Common math functions and constants                                        --
-------------------------------------------------------------------------------

pi=     3.14159265358979323	--Pi
pi2=	6.28318530717958648	--2*Pi
pi0d5=  1.57079632679489662	--Pi/2
e=      2.71828182845904524	--E
sqrt2=  1.41421356237309505	--sqrt(2)
phi=    1.61803398874989485	--Golden ratio, (1+sqrt(5))/2
phiang= 2.39996322972865332	--Golden angle, Pi*(2+sqrt(5))
ln2=    0.69314718055994531	--Log_E(2)
log2e=  1.44269504088896341	--Log_2(E)
log10e= 0.43429448190325183	--Log_10(E)
sqrt0d5=0.70710678118654752	--sqrt(1/2) aka sqrt(2)/2
ln10=   2.30258509299404568	--Log_E(10)
maxval= 1.7976931348623*10^308	--maximal float value
minval= 0.5562684646268/10^308	--minimal float value

-- returns ablsolute value of given argument
function abs( x  )
	if x < 0 then
		return -x
	else
		return x
	end
end

-- returns sign of given argument
function sign( x )
	if x < 0 then
		return -1
	elseif x > 0 then
		return 1
	else
		return 0
	end
end

-- returns square root of given argument
function sqrt( x )
	return math.sqrt( x )
end

--returns absolute square root of given argument
--sign(x)*sqrt(|x|)
function sqrtabs( x )
	if x < 0 then
		return -math.sqrt( -x )
	else
		return math.sqrt( x )
	end
end

--returns sine of given argument
function sin( x )
	return math.sin( x )
end

--returns cosine of given argument
function cos( x )
	return math.cos( x )
end

--returns tangent of given argument
function tan( x )
	return math.sin( x ) / math.cos( x )
end

--returns cotangent of given argument
function cot( x )
	return math.cos( x ) / math.sin( x )
end

--returns secant of given argument
function sec( x )
	return 1 / math.cos( x )
end

--returns cosecant of given argument
function csc( x )
	return 1 / math.sin( x )
end

--returns inverse sine of given argument
function asin( x )
	return math.atan( x / sqrt( 1 - x * x ) )
end

--returns inverse cosine of given argument
function acos( x )
	return math.atan( sqrt( 1 - x * x ) / x )
end

--returns inverse tangent of given argument
function atan( x )
	return math.atan( x )
end

--returns inverse cotangent of given argument
function acot( x )
	return math.atan( x ) + pi0d5
end

--returns inverse secant of given argument
function asec( x )
	return acos( 1 / x )
end

--returns inverse cosecant of given argument
function acsc( x )
	return asin( 1/x )
end

--returns hyperbolic sine of given argument
function sinh( x )
	return math.sinh( x )
end

--returns hyperbolic cosine of given argument
function cosh( x )
	return math.sinh( x )
end

--returns hyperbolic tangent of given argument
function tanh( x )
	return math.tanh( x )
end

--returns logarithm of given argument with base E
function ln( x )
	return math.log( x )
end

--returns logarithm of first argument with base of second argument
function log( x , y )
	return math.log( x )/math.log( y )
end

--returns length of vector from origin to point with coordinates specified by arguments
--sqrt(a^2+b^2+c^2+d^2...)
function hypot( ... )
	sum = 0
	for i = 1 , arg.n do
		sum = sum + arg[ i ] ^ 2
	end
	return math.sqrt( sum )
end

--random( x,y ) returns a random integer in [x;y) interval
--random( x ) returns a random integer in [0;x) interval
--random() returns a random float in [0;1) interval
function random( x,y )
	return math.random( x,y )
end

--returns floor of given argument
function floor( x )
	return math.floor( x )
end

--returns ceil of given argument
function ceil( x )
	return math.ceil( x )
end

--returns an integer closest to given argument
function round( x )
	return math.floor( x+0.5 )
end

-------------------------------------------------------------------------------
--Handle operations                                                          --
-------------------------------------------------------------------------------

--table to store data in
tabledata = {}
--minimal handle
index_min = 0
--maximal handle
index_max = 0

--returns a table with handle of given argument
function getTable( index )
	return { [ "table" ] = tabledata[ index ] , [ "index" ] = index }
end

--finds a place for new table, returns handle
function createTable()
	while not ( tabledata[ index_min ]==nil ) do
		index_min = index_min + 1
		if index_min > index_max then index_max = index_min end
	end
	tabledata[ index_min ] = {}
	index_min = index_min + 1
	if index_min > index_max then index_max = index_min end
 	return index_min - 1
end

--frees a place for a table with a handle of a given argument
function freeTable( index )
	tabledata[ index ] = nil
	if index == index_max - 1 then index_max = index end
	index_min = index
end

--does the same as getTable(index).table=table but copying instead of just moving it
function pushTable( index , table )
	local function copytable( from , to )
		for k in pairs( from ) do
			if type( from[ k ] )=='table' then
				to[ k ] = {}
				copytable( from[ k ],to[ k ] )
			else
				to[ k ]=from[ k ]
			end
		end
	end
	local destination = getTable( index ).table
	copytable( table , destination )
end

--duplicates a table with handle of given argument, returns handle of resulting table
function duplicateTable( index )
	local handle = createTable()
	local destination = getTable( handle ).table
	local source = getTable( index ).table
	local function copytable( from , to )
		for k in pairs( from ) do
			if type( from[ k ] ) == 'table' then
				to[ k ] = {}
				copytable( from[ k ],to[ k ] )
			else
				to[ k ]=from[ k ]
			end
		end
	end
 copytable( source , destination )
 return handle
end

-------------------------------------------------------------------------------
--Streaming                                                                  --
-------------------------------------------------------------------------------

stream = {}
stream.smClosed =	0	--Stream is closed
stream.smFromFile =	1	--Stream reads from file
stream.smToFile =	2	--Stream writes to file
stream.smFromTable =	3	--Stream reads from table
stream.smToTable =	4	--Stream writes to table
stream.smFromStream =	5	--Stream reads from another stream
stream.smToStream =	6	--Stream writes to another stream

--table to new stream to be inherited from
stream.streamPrototable = {
	[ "type" ] = "Stream" ,
	[ "filename" ] = "" ,		--stores name of opened file
	[ "fileobj" ] = nil ,		--stores opened file class
	[ "tablelink" ] = nil ,		--stores link at table it reads from
	[ "tableptr" ] = 0 ,		--stores data pointer for table
	[ "mode" ]= stream.smClosed ,	--stores mode
	--read data from stream with length of given argument
	[ "read" ] = function( self , length )
		if self.mode == stream.smFromFile then
		--if reads from file just alias the call
			return self.fileobj:read( len )
		elseif self.mode == stream.smFromTable then
		--if reads fom table collect data byte-by-byte
			local result = ''
			-- if there's still something to read
			if not( self.tablelink[ self.tableptr+1 ] == nil ) then
				for i = 1 , length do
					self.tableptr = self.tableptr + 1
					--if end-of-...stream
					if self.tablelink[ self.tableptr ] == nil then break end
					result = result .. string.char( self.tablelink[ self.tableptr ] )
				end
			else
			--if there's nothing to read
				return nil
			end
		return result
		elseif self.mode == stream.smFromStream then
		--if reads from another stream just alias the call
			return self.tableptr:read( len )
		end
	end ,
	--write data to stream
	[ "write" ] = function( self , data )
		if self.mode == stream.smToFile then
		--if writes to file just alias the call
			self.fileobj:write( data )
		elseif self.mode == stream.smToTable then
		--if writes to table write it byte-by-byte
			for i = 1 , string.len( str ) do
				self.tablelink[ self.tableptr + i ] = string.byte( string.sub( str , i , i ) )
			end
			self.tableptr=self.tableptr+string.len(str )
		elseif self.mode == stream.smToStream then
		--if writes to another stream just alias the call
			self.tablelink:write( str )
		end
	end ,
	--close the stream
	["close"]=function( self )
		if self.mode == stream.smToFile then
			self.fileobj:close()
		elseif self.mode == stream.smToStream then
			self.tablelink:close()
		elseif self.mode == stream.smToTable then
		--add a nil at the end to generate end-of-stream in futher reading
			self.tablelink[tableptr+1]=nil
		elseif self.mode == stream.smFromFile then
			self.fileobj:close()
		elseif self.mode == stream.smFromStream then
			self.tablelink:close()
		end
	end
}

--storing prototype
stream.streamPrototype = createTable()
pushTable( stream.streamPrototype , stream.streamPrototable )

--function that opens a stream
--filename may be a string
--or a table
stream.open = function( filename , mode)
	handle = duplicateTable( stream.streamPrototype )
	result = getTable( handle ).table
	if type( name ) == "table" then
	--if filename is actually a table
		if mode == "r" or mode == "rb" then
			result.mode = stream.smFromTable
		elseif mode == "w" or mode == "wb" then
			result.mode = stream.smToTable
		end
		result.tablelink = filename
	else
		if mode == "r" or mode == "rb" then
			result.mode = stream.smFromFile
		elseif mode == "w" or mode == "wb" then
			res.mode = stream.smToFile
		end
		res.filename = name
		res.fileobj = io.open( filename , mode )
	end
	return result,handle
end

-------------------------------------------------------------------------------
--Time                                                                       --
-------------------------------------------------------------------------------

time = {}
setmetatable(time,{
	[ "__index" ] = function( table , key )
		if key == 'seconds' then
			return os.date( '*t' ).sec
		elseif key == 'minutes' then
			return os.date( '*t' ).min
		elseif key == 'hours' then
			return os.date( '*t' ).hour
		elseif key == 'days' then
			return os.date( '*t' ).yday
		elseif key == 'years' then
			return os.date( '*t' ).year
		elseif key == 'day' then
			return os.date( '*t' ).day
		elseif key == 'month' then
			return os.date( '*t' ).month
		elseif key == 'total' then
			return os.time( os.date( '*t' ) )
		elseif key == '_total' then
			t=os.date( '*t' )
			--nice formula i know      s/yr                                                             s/day                                        2sh yrs
			return ( t.year - 1970 ) * 31536000 + ( t.yday + math.floor( ( t.year - 2 ) / 4 - 493 ) ) * 86400 + t.hour * 3600 + t.min * 60 + t.sec - 14400
		end
	end
} )

-------------------------------------------------------------------------------
--Bitwise math                                                               --
-------------------------------------------------------------------------------

--byte not
function bnot( a )
	result = 0
	for i = 0 , 7 do
		if math.floor( a / ( 2 ^ i ) ) % 2 == 0 then
			result = result + 2 ^ i
		end
	end
	return result
end

--word not
function wnot( a )
	result = 0
	for i = 0 , 15 do
		if math.floor( a / ( 2 ^ i ) ) % 2 == 0 then
			result = result + 2 ^ i
		end
	end
	return result
end

--dword not
function dnot( a )
	result = 0
	for i = 0 , 31 do
		if math.floor( a / ( 2 ^ i ) ) % 2 == 0 then
			result = result + 2 ^ i
		end
	end
	return result
end

--byte and
function band( a , b )
	result = 0
	for i = 0 , 7 do
 		if math.floor( a / ( 2 ^ i ) ) % 2 == 1 and math.floor( b / ( 2 ^ i ) ) % 2 == 1 then
			result = result + 2 ^ i
		end
	end
	return result
end

--word and
function wand( a , b )
	result = 0
	for i = 0 , 15 do
		if math.floor( a / ( 2^i ) ) % 2 == 1 and math.floor( b / ( 2^i ) ) % 2 == 1 then
			result = result + 2 ^ i
		end
	end
	return result
end

--dword and
function dand( a , b )
	result = 0
	for i = 0 , 31 do
		if math.floor( a /(  2 ^ i ) ) % 2 == 1 and math.floor( b / ( 2 ^ i ) ) % 2 == 1 then
			result = result + 2 ^ i
		end
	end
	return result
end

--byte or
function bor( a , b )
	result = 0
	for i = 0 , 7 do
		if math.floor( a / ( 2 ^ i ) ) % 2==1 or math.floor( b / ( 2^i ) ) % 2==1 then
			result = result + 2 ^ i
		end
	end
	return result
end

--word or
function wor( a , b )
	result = 0
	for i=0 , 15 do
		if math.floor( a / ( 2 ^ i ) ) % 2 == 1 or math.floor( b / ( 2 ^ i ) ) % 2 == 1 then
			result = result + 2 ^ i
		end
	end
	return result
end

--dword or
function dor( a , b )
	result = 0
	for i = 0 , 31 do
		if math.floor( a / ( 2 ^ i ) ) % 2 == 1 or math.floor( b / ( 2 ^ i ) ) % 2 == 1 then
			result = result + 2 ^ i
		end
	end
	return result
end

--byte xor
function bxor( a , b )
	result = 0
	for i = 0 , 7 do
		if not ( math.floor( a / ( 2 ^ i ) ) % 2 == math.floor( b / ( 2 ^ i ) ) % 2 ) then
			result = result + 2 ^ i
		end
	end
	return result
end

--word xor
function wxor( a , b )
	result = 0
	for i = 0 , 15 do
		if not ( math.floor( a / ( 2 ^ i ) ) % 2 == math.floor( b / ( 2 ^ i ) ) % 2 ) then
			result = result + 2 ^ i
		end
	end
	return result
end

--dword xor
function wxor( a , b )
	result = 0
	for i = 0 , 31 do
		if not( math.floor( a / ( 2 ^ i ) ) % 2 == math.floor( b / ( 2 ^ i ) ) % 2 ) then
			result = result + 2 ^ i
		end
	end
	return result
end

-------------------------------------------------------------------------------
--Miscellaneous functions                                                    --
-------------------------------------------------------------------------------

--environment metatable
--use like environment.path
environment = {}
setmetatable( environment , {
	[ "__index" ] = function( table , key )
		return os.getenv( key )
	end
} )

--downloads file from given url to given file
function downloadfile( url , filename )
	os.execute( 'httpretv ' .. url .. ' ' .. filename )
end