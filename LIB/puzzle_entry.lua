-------------------------------------------------------------------------------
---	MXML 2 LUA ... by lMonk
---	A tool for converting between mxml file format and lua table.
--- The complete tool can be found at: https://github.com/roie-r/mxml_2_lua
-------------------------------------------------------------------------------
---	!! WORK IN PROGESS !! WORK IN PROGESS !! WORK IN PROGESS !!
---	Construct alien puzzle dialog entries ... version: 0.0.08
-------------------------------------------------------------------------------

-- mutlitool upgrade station >> 1 install slot / 2 purchase new slot / 3 upgrade class
-- UI_WEAPON_UPGRADE_LABEL >> UI_WEAP_UPGRADE_INV_OPTB / UI_WEAP_UPGRADE_INV_OPTA ?? UI_WEAPON_UPGRADE_OPT_A / UI_SALVAGE_CLASS_OPT

-- UI_SALVAGE_MT_TITLE >> UI_COST_SALVAGE_WORTH
-- multi-tool decommissioning >> 1 claim scrap worth ## units

function PuzzleOption(option)
---	!! WORK IN PROGESS !!
	return {
		meta = {name='Options', value='GcAlienPuzzleOption'},
		Name					= option.name,
		Text					= option.text,
		IsAlien					= option.isalien,				-- b
		Cost					= option.cost,					-- s
		Rewards					= StringArray(option.rewards, 'Rewards'),
		Mood = {
			meta = {name='Mood', value='GcAlienMood'},
			Mood				= option.mood,					-- Enum
		},
		Prop = {
			meta = {name='Prop', value='GcNPCPropType'},
			NPCProp				= option.prop or 'DontCare',	-- Enum
		},
		KeepOpen				= option.keepopen,				-- b
		DisplayCost				= true,
		MarkInteractionComplete	= option.markcomplete,			-- b
		NextInteraction			= option.next,
		SelectedOnBackOut		= option.selectedonback,		-- b
	}
end

function PuzzleEntry(diag)
---	!! WORK IN PROGESS !!
	return {
		meta = {name='Table', value='GcAlienPuzzleEntry'},
		Id 							= diag.id,
		ProgressionIndex 			= diag.index or -1,
		MinProgressionForSelection	= diag.minprogress or nil,
		Race = {
			meta = {name='Race', value='GcAlienRace'},
			AlienRace				= diag.race or 'None',		-- Enum
		},
		Type = {
			meta = {name='Type', value='GcInteractionType'},
			InteractionType			= diag.itype,				-- Enum
		},
		Category = {
			meta = {name='Category', value='GcAlienPuzzleCategory'},
			AlienPuzzleCategory		= diag.category or 'Default',-- Enum
		},
		Title						= diag.title,				-- s
		Text						= diag.text,				-- s
		TextAlien					= diag.textalien,			-- s
		TranslateAlienText			= diag.translatealien,		-- b
		ProgressiveDialogue			= diag.progressive,			-- b
		RequiresScanEvent			= diag.scanevent,			-- s
		Mood = {
			meta = {name='Mood', value='GcAlienMood'},
			Mood					= diag.mood or 'Neutral',	-- Enum
		},
		Prop = {
			meta = {name='Prop', value='GcNPCPropType'},
			NPCProp					= diag.prop or 'DontCare',	-- Enum
		},
		CustomFreighterTextIndex	= -1,
		UseTitleOverrideInLabel		= true,
		Options						= (
			function()
				local opts = {meta = {name='Options'}}
				for _, option in ipairs(diag.options) do
					opts[#opts+1] = PuzzleOption(option)
				end
				return opts
			end
		)()
	}
end
