-------------------------------------------------------------------------------
---	MXML 2 LUA (VERSION: 0.88.02) ... by lMonk
---	A tool for converting mxml to an equivalent lua table and back again.
---	Functions for converting an mxml file, or sections of one, to
---	 a lua table during run-time, or printing the mxml as a lua script.
---	* This script should be in [AMUMSS folder]\ModScript\ModHelperScripts\LIB
-------------------------------------------------------------------------------

--	Strip the XML header and data template if found
--	The template is re-added as a property
--	@param mxml: mxml-formatted string
function UnWrap(mxml)
	if mxml:sub(1, 5) == '<?xml' then
		local template = mxml:match('<Data template="([%w_]+)">')
		return '<Property template="'..template..'">\n'..
				mxml:sub(mxml:find('<Property'), -8)..'</Property>'
	else
		return mxml
	end
end

--	Returns a table representation of MXML sections
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
	local function parseTag(line)
		if #line < 1 then return nil end
		local attr = {
			opn_ = line:sub(-1) ~= '/',
			n_	 = 0
		}
		for att, val in line:gmatch('(.-)="(.-)"') do
			attr[att:gsub('^%s+', '')] = val
			attr.n_ = attr.n_ + 1
		end
		return attr
	end
	local tlua, st_node = {}, {}
	local parent= tlua
	local node	= nil
	for prop in UnWrap(mxml):gmatch('<[/]?Property[ ]?(.-[/]?)>') do
		local tag = parseTag(prop)
		if tag then
			if tag.opn_ then -- open tag; add new section
				st_node[#st_node+1] = parent
				node = {meta = tag}
				if tag._id then
					if use_id then
						key = tag._id
					else
						key = #parent + 1
					end
				elseif tag._index then
					key = #parent + 1
				elseif (tag.name and tag.n_ == 1) or (parent.meta and parent.meta.n_ > 1) then
					key = tag.name
				else
					key = #parent + 1
				end
				parent[key] = node
				parent = node
			else -- closed tag; add property to section
				local att, val = nil, nil
				if tag.name and tag.n_ == 1 then
					att = #node+1
					val = {name = eval(tag.name)} -- list stub
				elseif parent.meta.n_ > 1 or parent.meta.template then
					att = tag.name
					val = eval(tag.value)
				elseif parent.meta.n_ == 1 then
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

--	Converts MXML to a pretty-printed, ready-to-work, lua script.
--	When parsing a full file, the header is stripped and a mock template is added
--	* Does not handle commented lines!
--	@param vars: a table containing the following required properties
--	{
--	  mxml	 = A full file or complete MXML sections in the nomral format
--	  indent = code indentation..			Default: [\t] (tab)
--	  com	 = ['] or ["]..					Default: [']
--	  sq_k	 = enclose keys in bracers..	Default: false
--	  use_id = use _id as key...			Default: false
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
	local function parseTag(line)
		if #line < 1 then return nil end
		local attr = {
			opn_	= line:sub(-1) ~= '/',
			n_		= 0
		}
		for att, val in line:gmatch('(.-)="(.-)"') do
			attr[att:gsub('^%s+', '')] = val
			attr.n_ = attr.n_ + 1
		end
		return attr
	end
	local tlua	= {}
	function tlua:add(t)
		for _,v in ipairs(t) do self[#self+1] = v end
	end
	function tlua:ins(s, i)
		table.insert(self, i, s)
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
	for prop in UnWrap(vars.mxml or vars):gmatch('<[/]?Property[ ]?(.-[/]?)>') do
		local tag = parseTag(prop)
		if tag then
			if tag.opn_ then -- open tag; add new section
				st_node[#st_node+1] = parent
				tlua:add({ind:rep(lvl)})
				if tag._id then
					if vars.use_id then
						tlua:add({ko, tag._id, kc, ' = '})
					else
						do end
					end
				elseif tag._index then
					do end
				elseif (tag.name and tag.n_ == 1) or (parent and parent.n_ > 1) then
					tlua:add({ko, tag.name, kc, ' = '})
				end
				lvl = lvl + 1
				tlua:add({'{\n', ind:rep(lvl), 'meta = {'})
				for at, vl in pairs(tag) do
					if at:sub(-1) ~= '_' then tlua:add({at, '="', vl, '"', ', '}) end
				end
				tlua:rem() -- trim last comma
				tlua:add({'},\n'})
				parent = tag -- keep parent atributes
			else
				-- add section properties
				tlua:add({ind:rep(lvl)})
				if tag.n_ == 1 then
					if tag.name then
						at = 'name'
						vl = tag.name
					else
						at = 'value'
						vl = tag.value
					end
					tlua:add({'{', ko, at, kc, ' = ', eval(vl), '}'})
				elseif parent.n_ > 1 or parent.template then
					tlua:add({ko, tag.name, kc, ' = ', eval(tag.value)})
				elseif parent.n_ == 1 then
					if parent.name == tag.name then
						tlua:add({eval(tag.value)})
					else
						tlua:add({'{', ko, tag.name, kc, ' = ', eval(tag.value), '}'})
					end
				else
					tlua:add({ko, tag.name, kc, ' = ', eval(tag.value)})
				end
				tlua:add({',\n'})
			end
		else
			-- closing the section
			lvl = lvl - 1
			parent = table.remove(st_node)
			-- trim the comma from the last object
			tlua[#tlua] = tlua[#tlua]:gsub(',\n', '\n')
			tlua:add({ind:rep(lvl), '},\n'})
		end
	end
	-- start & end trims
	if tlua[6] == ' = ' then
		tlua:rem({3,4,5,6})
	end
	tlua:ins('return ', 1)
	tlua[#tlua] = '}'
	return table.concat(tlua)
end

--	A direct access-index for a SCENE file.
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

-- A Union All function for an ordered array of tables. Last in the array wins
-- Returns a copy by-value. A repeating keys's values are overwritten.
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
