----------------------------------------------------------------------
dofile('LIB/lua_2_exml.lua')
dofile('LIB/table_entry.lua')
----------------------------------------------------------------------

NMS_MOD_DEFINITION_CONTAINER = {
	MOD_FILENAME 		= '_TEST L2E add new products.pak',
	MOD_AUTHOR			= 'lMonk',
	NMS_VERSION			= '4.45',
	MODIFICATIONS 		= {{
	MBIN_CHANGE_TABLE	= {
	{
		MBIN_FILE_SOURCE	= 'METADATA/REALITY/TABLES/NMS_REALITY_GCPRODUCTTABLE.MBIN',
		EXML_CHANGE_TABLE	= {
			{
				PRECEDING_KEY_WORDS	= 'Table',
				ADD					= ToExml({
					[1] = ProductEntry({
						id				= 'ULTRAPRODX40',
						name			= 'PRODX40_NAME',
						namelower		= 'PRODX40_NAME_L',
						subtitle		= 'CURIO4_SUBTITLE',
						description		= 'PRODX40_DESC',
						basevalue		= 624000000,
						color			= 'ffcccccc',
						category		= 'Special',
						type			= 'Tradeable',
						rarity			= 'Rare',
						legality		= 'Legal',
						iscraftable		= true,
						requirements	= {
							{id='ULTRAPROD1', 		n=20,	tp=I_.PRD},
							{id='ULTRAPROD2', 		n=20,	tp=I_.PRD}
						},
						stackmultiplier	= 16,
						icon			= 'TEXTURES/UI/FRONTEND/ICONS/U4PRODUCTS/PRODUCT.CAPTUREDNANODE.DDS'
					}),
					[2] = ProductEntry({
						id				= 'SUPERFOOD',
						name			= 'SUPERFOOD_NAME',
						namelower		= 'SUPERFOOD_NAME_L',
						subtitle		= 'PROD_NIP_SUBTITLE',
						description		= 'SUPERFOOD_DESC',
						basevalue		= 2,
						color			= 'ff1a273d',
						category		= 'Exotic',
						type			= 'Consumable',
						rarity			= 'Rare',
						legality		= 'Legal',
						consumable		= true,
						requirements	= {
							{id='SENTINEL_LOOT',	n=2,	tp=I_.PRD},
							{id='FOOD_V_ROBOT',		n=2,	tp=I_.PRD},
							{id='STELLAR2',			n=50,	tp=I_.SBT}
						},
						stackmultiplier	= 20,
						icon			= 'TEXTURES/UI/FRONTEND/ICONS/PRODUCTS/PRODUCT.GLOWPELLET.DDS'
					})
				})
			}
		}
	}
}}}}
