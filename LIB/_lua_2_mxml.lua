-------------------------------------------------------------------------------
---	MXML 2 LUA ... by lMonk ... version: 1.0.01
---	A tool for converting between mxml file format and lua table.
--- The complete tool can be found at: https://github.com/roie-r/mxml_2_lua
-------------------------------------------------------------------------------
---	MXML builder - Build mxml from lua table
--- Tools for color -and vector class, ordered string list
-------------------------------------------------------------------------------

--	=> Generate an MXML-tagged text from a lua table representation of mxml file
--	@param class: a lua2mxml formatted table
function ToMxml(class)
	--	replace a boolean with its text equivalent (ignore otherwise)
	--	@param b: any value
	local function bool(b)
		return type(b) == 'boolean' and (b == true and 'true' or 'false') or b
	end
	local function mxml_r(tlua)
		local out = {}
		function out:add(t)
			for _,v in ipairs(t) do self[#self+1] = v end
		end
		for attr, cls in pairs(tlua) do
			if attr ~= 'meta' then
				out[#out+1] = '<Property '
				if type(cls) == 'table' and cls.meta then
				-- add new section and recurs for nested sections
					for k, v in pairs(cls.meta) do
						if k:sub(-1) ~= '_' then out:add({k, '="', bool(v), '"', ' '}) end
					end
					table.remove(out) -- trim last space
					out:add({'>', mxml_r(cls), '</Property>'})
				else
				-- add section properties
					local att, val = nil, nil
					if tonumber(attr) then
						if type(cls) == 'table' then
							att, val = next(cls)
						else
							att = tlua.meta.name
							val = cls
						end
					else
						att = attr
						val = cls
					end
					if att == 'name' then
						out:add({att, '="', bool(val), '"/>'})
					else
						out:add({'name="', att, '" value="', bool(val), '"/>'})
					end
				end
			end
		end
		return table.concat(out)
	end
	-------------------------------------------------------------------------
	-- check the table level structure and meta placement
	-- add parent table for the recursion and handle multiple tables
	if type(class) ~= 'table' then return nil end
	local klen=0; for _ in pairs(class) do klen=klen+1 end

	if klen == 1 and class[1].meta then
		return mxml_r(class)
	elseif class.meta and klen > 1 then
		return mxml_r( {class} )
	-- concatenate unrelated (instead of nested) mxml sections
	elseif type(class[1]) == 'table' and klen > 1 then
		local T = {}
		for _, tb in pairs(class) do
			T[#T+1] = mxml_r((tb.meta and klen > 1) and {tb} or tb)
		end
		return table.concat(T)
	end
	return nil
end

--	=> Adds the header and class template for a standard mxml file
--	@param data: A lua2mxml formatted table
--	@param template: [optional] A class template string. Overwrites the internal template!
function FileWrapping(tlua, ext_tmpl)
	local wrapper = '<?xml version="1.0" encoding="utf-8"?><Data template="%s">%s</Data>'
	if type(tlua) == 'string' then
		return wrapper:format(ext_tmpl, tlua)
	end
	-- replace existing or add template layer if needed
	if ext_tmpl then
		if tlua.meta.template then
			tlua.meta.template = ext_tmpl
		else
			tlua = {
				meta = {template=ext_tmpl},
				tlua
			}
		end
	end
	-- strip mock template
	local txt_data = ToMxml(tlua):sub(#tlua.meta.template + 23, -12)
	return wrapper:format(tlua.meta.template, txt_data)
end

--	=> Translates a 0xFF hex section from a longer string to 0-1.0 percentage
--	@param hex: hex string (case insensitive [A-z0-9])
--	@param i: the hex pair's index
function Hex2Percent(hex, i)
	return math.floor(tonumber(hex:sub(i * 2 - 1, i * 2), 16) / 255 * 1000) / 1000
end

--	=> Builds a Colour class
--	@param T: ARGB color in percentage values or hex format.
--	  Either {1.0, 0.5, 0.4, 0.3} or {<a=1.0> <,r=0.5> <,g=0.4> <,b=0.3>} or 'FFA0B1C2'
--	@param color_name: class name
function ColorData(C, color_name)
	local argb = {}
	if type(C) == 'string' then
		for i=#C > 6 and 1 or 2, #C/2 do
			argb[i] = Hex2Percent(C, i)
		end
	elseif C == 0 then
		argb = {1, -1, -1, -1} -- 'real' black
	else
		argb = C or {}
	end
	return {
		meta= {name=color_name},
		{A	= (argb[1] or argb.a) or 1},
		{R	= (argb[2] or argb.r) or 1},
		{G	= (argb[3] or argb.g) or 1},
		{B	= (argb[4] or argb.b) or 1}
	}
end

--	=> Builds an amumss VCT table from a hex color string
--	@param h: hex color string in ARGB or RGB format (default is white)
--	(not really the place for this one, but it's convenient)
function Hex2VCT(h)
	local argb = {{'A', 1}, {'R', -1}, {'G', -1}, {'B', -1}}
	if h == 0 then return argb end -- 'real' black
	for i=#h > 6 and 1 or 2, #h/2 do
		argb[i][2] = Hex2Percent(h, i)
	end
	return argb
end

--	=> Builds a Vector 2, 3 or 4f class, depending on number of values
--	@param T: xy<z<t>> vector
--	  Either {1.0, 0.5 <,0.4, <,2>>} or {x=1.0, y=0.5 <,z=0.4 <,t=2>>}
--	@param vector_name: class name
function VectorData(T, vector_name)
	if not T then return nil end
	return {
		-- if a name is present then use 2-property tags
		meta= {name=vector_name},
		{X	= T[1] or T.x},
		{Y	= T[2] or T.y},
		{Z	= (T[3] or T.z) or nil},
		{W	= (T[4] or T.w) or nil}
	}
end

--	=> Builds a 'name' type array of strings
--	@param t: an ordered (non-keyed) table of strings
--	@param s_arr_name: class name
function StringArray(t, s_arr_name)
	if not t then return nil end
	local T = { meta = {name=s_arr_name} }
	for _,s in ipairs(t) do
		T[#T+1] = { [s_arr_name] = s }
	end
	return T
end

--	=> Determine if received is a single or multi-item
--	then process items through the received function
--	@param items: table of item properties or a non-keyed table of items (keys are ignored)
--	@param acton: the function to process the items in the table
function ProcessOnenAll(items, acton)
	-- first key = 1 means multiple entries
	if next(items) == 1 then
		local T = {}
		for _,e in ipairs(items) do
			T[#T+1] = acton(e)
		end
		return T
	end
	return acton(items)
end
