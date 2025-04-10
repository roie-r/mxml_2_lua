-------------------------------------
dofile('LIB/_lua_2_mxml.lua')
dofile('LIB/dialog_entry.lua')
-------------------------------------

NMS_MOD_DEFINITION_CONTAINER = {
	MOD_FILENAME 		= '_TEST L2E add new dialog.pak',
	MOD_AUTHOR			= 'lMonk',
	NMS_VERSION			= '5.63',
	MODIFICATIONS 		= {{
	MBIN_CHANGE_TABLE	= {
	{
		MBIN_FILE_SOURCE	= 'METADATA/REALITY/TABLES/NMS_DIALOG_GCALIENPUZZLETABLE.MBIN',
		MXML_CHANGE_TABLE	= {
			{
				PRECEDING_KEY_WORDS	= 'Table',
				ADD					= ToMxml(DialogEntry({
					id					= 'WEAPON_UPGRADE',
					progressindex		= -1,					-- default value - can be omitted
					minprogression		= 0,					-- default
					race				= 'None',				-- default (enum)
					itype				= 'WeaponSalvage',
					category			= 'Default',			-- default (enum)
					title				= '',
					text				= '',
					textalien			= '',
					translatealien		= false,				-- default
					translationbrackets	= true,
					progressive			= true,
					scanevent			= '',
					mood				= 'Neutral',			-- default (enum)
					prop				= 'DontCare',			-- default (enum)
					radialinteraction	= false,
					allownooptions		= false,
					options				= {
						{
							name				= 'UI_WEAP_UPGRADE_INV_OPTB',
							text				= '',
							isalien				= false,
							cost				= 'C_INV_WEAP_P',
							rewards				= {'R_WEAPSLOT_PROD'},
							mood				= 'Neutral',
							prop				= 'DontCare',
							keepopen			= false,
							markcomplete		= true,
							nextinteraction		= nil,				-- if nil gets diag id
							selectedonback		= false,
							titleoverride		= ''
						},
						{
							name				= 'UI_WEAP_UPGRADE_INV_OPTA',
							cost				= 'C_INV_WEAP_C',
							rewards				= {'R_WEAPSLOT_CASH'},
							markcomplete		= true
						},
						{
							name				= 'UI_SALVAGE_CLASS_OPT',
							text				= 'UI_WEAP_UPGRADE_CLASS_RES',
							isalien				= true,
							cost				= 'C_WEAP_UPGRADE',
							rewards				= {'R_WEAP_UPGRADE'},
							markcomplete		= true
						},
						{
							name				= 'ALL_REQUEST_LEAVE',
							selectedonback		= true
						}
					},
					interactionflow		= {
						{
							text				= 'UI_WEAPON_TERMINAL_LANG',
							isalien				= true,
							title				= '',
							mood				= 'Neutral',
							TranslateAlienText	= 'None',			-- default (enum)
							bracketsoverride	= 'None',			-- default (enum)
							race				= 'None',
							audio				= nil,
							showhologram		= true,
							conditiontest		= 'AnyFalse',		-- default (enum)
							disablingcondition	= nil,
						}
					}
				}))
			}
		}
	}
}}}}
