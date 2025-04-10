-------------------------------------------------------------------------------
---	MXML 2 LUA ... by lMonk
---	A tool for converting between mxml file format and lua table.
--- The complete tool can be found at: https://github.com/roie-r/mxml_2_lua
-------------------------------------------------------------------------------
---	Construct dialog alien puzzle entries ... version: 0.8.0
-------------------------------------------------------------------------------

--	=> build GcAlienPuzzleOption for diaolg entry
function DialogOption(opt, pid, i)
	return {
		meta = {name='Options', value='GcAlienPuzzleOption', _index=i},
		Name					= opt.name,
		Text					= opt.text,
		IsAlien					= opt.isalien,						-- b
		Cost					= opt.cost,							-- s
		Rewards					= StringArray(opt.rewards, 'Rewards'),
		Mood = {
			meta = {name='Mood', value='GcAlienMood'},
			Mood				= opt.mood,							-- Enum
		},
		Prop = {
			meta = {name='Prop', value='GcNPCPropType'},
			NPCProp				= opt.prop or 'DontCare',			-- Enum
		},
		KeepOpen				= opt.keepopen,						-- b
		DisplayCost				= true,
		MarkInteractionComplete	= opt.markcomplete,					-- b
		NextInteraction			= opt.nextinteraction or pid,		-- s (id)
		SelectedOnBackOut		= opt.selectedonback,				-- b
		TitleOverride			= opt.titleoverride,				-- s
	}
end

--	=> build GcPuzzleTextFlow for diaolg entry
function DialogTextFlow(flow, i)
	return {	
		meta = {name='AdvancedInteractionFlow', value='GcPuzzleTextFlow', _index=i},
		Text						= flow.text,					-- s
		IsAlien						= flow.isalien,					-- b
		Title						= flow.title,					-- s
		Mood = {
			meta = {name='Mood', value='GcAlienMood'},
			Mood 					= flow.Mood						-- Enum
		},
		TranslateAlienTextOverride	= flow.TranslateAlienText,		-- Enum
		BracketsOverride			= flow.bracketsoverride,		-- Enum
		AlienLanguageOverride = {
			meta = {name='AlienLanguageOverride', value='GcAlienRace'},
			AlienRace				= flow.race or 'None',			-- Enum
		},
		AudioEvent = {
			meta = {name='AudioEvent', value='GcAudioWwiseEvents'},
			AkEvent					= flow.audio					-- Enum
		},
		ShowHologram				= flow.showhologram,
		DisablingConditionTest = {
			meta = {name='DisablingConditionTest', value='GcMissionConditionTest'},
			ConditionTest			= flow.conditiontest			-- Enum
		},
		DisablingConditionId		= flow.disablingcondition		-- s
	}
end

--	=> build an entry for NMS_DIALOG_GCALIENPUZZLETABLE
--	* handles multiple entries
function DialogEntry(entries)
	local function diagEntry(diag)
		return {
			meta = {name='Table', value='GcAlienPuzzleEntry', _id=diag.id},
			Id 							= diag.id,
			ProgressionIndex 			= diag.progressindex or -1,	-- i
			MinProgressionForSelection	= diag.minprogression,		-- i
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
			TranslationBrackets			= diag.translationbrackets,	-- b
			ProgressiveDialogue			= diag.progressive,			-- b
			RequiresScanEvent			= diag.scanevent,			-- s
			Mood = {
				meta = {name='Mood', value='GcAlienMood'},
				Mood					= diag.mood					-- Enum
			},
			Prop = {
				meta = {name='Prop', value='GcNPCPropType'},
				NPCProp					= diag.prop or 'DontCare',	-- Enum
			},
			CustomFreighterTextIndex	= -1,
			RadialInteraction			= diag.radialinteraction,	-- b
			AllowNoOptions				= diag.allownooptions,		-- b
			UseTitleOverrideInLabel		= true,
			Options						= (
				function()
					local opts = {meta = {name='Options'}}
					for i, opt in ipairs(diag.options) do
						opts[#opts+1] = DialogOption(opt, diag.id, i-1)
					end
					return opts
				end
			)(),
			AdvancedInteractionFlow		= diag.interactionflow and (
				function()
					local txts = {meta = {name='AdvancedInteractionFlow'}}
					for i, txt in ipairs(diag.interactionflow) do
						txts[#txts+1] = DialogTextFlow(txt, i-1)
					end
					return txts
				end
			)() or nil
		}
	end
	return ProcessOnenAll(entries, diagEntry)
end
