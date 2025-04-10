-------------------------------------------------------------------------------
---	MXML 2 LUA ... by lMonk
---	A tool for converting between mxml file format and lua table.
--- The complete tool can be found at: https://github.com/roie-r/mxml_2_lua
-------------------------------------------------------------------------------
---	Convert mxml to lua ... version: 1.0.03
---	Parse mxml file -or sections and convert to lua during run-time
---	 or pretty-print the mxml as a ready-to-load lua file.
-------------------------------------------------------------------------------

--	=> Strip the XML header and data template if found
--	The template is re-added as a faux property
--	@param mxml: mxml-formatted string
local function unWrap(mxml)
	if mxml:sub(1, 5) == '<?xml' then
		return ('<Property template="%s">%s</Property>'):format(
			mxml:match('<Data template="([%w_]+)">'),
			mxml:sub(mxml:find('<Property'), -8)
		)
	else
		return mxml
	end
end

--	=> Parse attributes from xml tag and return them in a table
--	* Keys with [_] suffix are ignored by ToMxml
--	@param prop: string containing xml tag attributes
local function parseTag(prop)
	if #prop < 1 then return nil end
	local attr = {-- the attribute container for each tag
		opn_ = prop:sub(-1) ~= '/',
		ord_ = {} -- keep order for writing attributes to file
	}
	for at1, val in prop:gmatch('(.-)="(.-)"') do
		local att = at1:gsub('^%s+', '')
		attr[att] = val
		attr.ord_[#attr.ord_+1] = att
	end
	local ln = select(2, prop:gsub('=', ''))
	attr.lst_ = ln == 1
	local prx = attr.name and attr.name:sub(0,2) or nil
	attr.cls_ = prx == 'Gc' or prx == 'Tk' or ln > 1
	return attr
end

--	=> Returns a table representation of MXML sections
--	When parsing a full file, the header is stripped and a mock template is added
--	* Does not handle commented lines!
--	@param mxml: requires complete MXML sections in the nomral format
--	@param use_id: use _id as section key where possible [Default: false]
function ToLua(mxml, use_id)
	local function eval(val)
		if val == 'true' then
			return true
		elseif val == 'false' then
			return false
		elseif tonumber(val) and #val < 18 and not val:match('^0x') then
			return tonumber(val)
		else
			return val
		end
	end
	local tlua, st_node = {}, {}
	local parent= tlua
	local node	= nil
	for prop in unWrap(mxml):gmatch('<[/]?Property[ ]?(.-[/]?)>') do
		local tag = parseTag(prop)
		if tag then
			if tag.opn_ then -- open tag; add new section
				st_node[#st_node+1] = parent
				node = {meta = tag}
				local key = nil
				if tag._id and use_id then
					key = tag._id
				elseif parent.meta and (parent.meta.template or parent.meta.cls_) then
					key = tag.name
				else
					key = #parent + 1
				end
				parent[key] = node
				parent = node
			else -- closed tag; add property to section
				local att, val = nil, nil
				if tag.lst_ then
					att = #node+1
					val = {name = eval(tag.name)} -- list stub
				elseif parent.meta.lst_ and not parent.meta.template and not parent.meta.cls_ then
					att = #node+1
					if parent.meta.name == tag.name then
						val = eval(tag.value)
					else
						val = {[tag.name] = eval(tag.value)}
					end
				else
					att = tag.name
					val = eval(tag.value)
				end
				node[att] = val
			end
		else
			-- go back to parent node
			parent = table.remove(st_node)
			node = parent
		end
	end
	return tlua[1] -- discard the wrapping table
end

--	=> Converts MXML to a pretty-printed, ready-to-work, lua script.
--	When parsing a full file, the header is stripped and a mock template is added
--	* Does not handle commented lines!
--	@param vars: a table containing the following required properties
--	{
--	  mxml	 = A full file or complete MXML sections in the nomral format
--	  indent = code indentation..			Default: [\t] (tab)
--	  com	 = ['] or ["]..					Default: [']
--	  sq_k	 = enclose keys in bracers..	Default: false
--	  use_id = use _id as key...			Default: false
--	  intern = include internal meta data	Default: false
--	}
--	* or just the mxml string (instead of a table)
function PrintMxmlAsLua(vars)
	local function eval(val)
		if val == 'true' or val == 'false' then
			return val
		elseif tonumber(val) and #val < 18 and not val:match('^0x') then
			return val
		else
			return '[['..val..']]'
		end
	end
	local tlua	= {}
	function tlua:add(t)
		if type(t) == 'table' then
			for _,v in ipairs(t) do self[#self+1] = v end
		else
			self[#self+1] = t
		end
	end
	function tlua:rem(t)
		for i=(t and #t or 1), 1, -1 do table.remove(self, t and t[i] or nil) end
	end
	local ind		= vars.indent or '\t'
	local com		= vars.com or [[']]
	local ko		= vars.sq_k and '['..com or ''
	local kc		= vars.sq_k and com..']' or ''
	local lvl		= 0
	local parent	= nil
	local st_node	= {}
	for prop in unWrap(vars.mxml or vars):gmatch('<[/]?Property[ ]?(.-[/]?)>') do
		local tag = parseTag(prop)
		if tag then
			if tag.opn_ then -- open tag; add new section
				st_node[#st_node+1] = parent
				tlua:add(ind:rep(lvl))
				if tag._id and vars.use_id then
					tlua:add({ko, tag._id, kc, ' = '})
				elseif parent and (parent.template or parent.cls_) then
					tlua:add({ko, tag.name, kc, ' = '})
				end
				lvl = lvl + 1
				tlua:add({'{\n', ind:rep(lvl), 'meta = {'})
				for _,att in ipairs(tag.ord_) do
					tlua:add({att, '=', com, tag[att], com, ', '})
				end
				if vars.intern then -- include internal meta data
					for at, vl in pairs(tag) do
						if at:sub(-1) == '_' then tlua:add({at, '=', com, tostring(vl), com, ', '}) end
					end
				end
				tlua:rem() -- trim last comma
				tlua:add('},\n')
				parent = tag -- keep parent atributes
			else
				-- add section properties
				tlua:add(ind:rep(lvl))
				if tag.lst_ then
					tlua:add({'{', ko, 'name', kc, ' = ', eval(tag.name), '}'})
				elseif parent.lst_ and not parent.template and not parent.cls_ then
					if parent.name == tag.name then
						tlua:add(eval(tag.value))
					else
						tlua:add({'{', ko, tag.name, kc, ' = ', eval(tag.value), '}'})
					end
				else
					tlua:add({ko, tag.name, kc, ' = ', eval(tag.value)})
				end
				tlua:add(',\n')
			end
		else
			-- closing the section
			lvl = lvl - 1
			parent = table.remove(st_node)
			tlua[#tlua] = tlua[#tlua]:gsub(',\n', '\n') -- trim the comma from last
			tlua:add({ind:rep(lvl), '},\n'})
		end
	end
	-- start & end trims
	if tlua[6] == ' = ' then
		tlua:rem({3,4,5,6})
	end
	table.insert(tlua, 1, 'return ')
	tlua[#tlua] = '}'
	return table.concat(tlua)
end

--	=> A direct access-index for a SCENE file.
--	Returns a table with Name property as keys linking to their to TkSceneNodeData sections.
function SceneNames(node, keys)
	keys = keys or {}
	if node.meta[2] == 'TkSceneNodeData' then
		keys[node.Name] = node
	end
	for _, scn in ipairs(node.Children or {}) do
		SceneNames(scn, keys)
	end
	return keys
end

--	=> A Union All function for an ordered array of tables. Last in the array wins
--	Returns a copy by-value. A repeating keys's values are overwritten.
--	@param arr: A table of tables.
function UnionTables(arr)
	local merged = {}
	for _, tbl in ipairs(arr) do
		for k, val in pairs(tbl) do
			if type(val) == 'table' then
				merged[k] = merged[k] or {}
				merged[k] = UnionTables({merged[k], val})
			else
				merged[k] = val
			end
		end
	end
	return merged
end
