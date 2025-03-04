----------------------------------------------------------------------
dofile('LIB/_lua_2_mxml.lua')
dofile('LIB/table_entry.lua')
----------------------------------------------------------------------

NMS_MOD_DEFINITION_CONTAINER = {
	MOD_FILENAME 		= '_TEST L2E add new products.pak',
	MOD_AUTHOR			= 'lMonk',
	NMS_VERSION			= '5.58',
	MODIFICATIONS 		= {{
	MBIN_CHANGE_TABLE	= {
	{
		MBIN_FILE_SOURCE	= 'METADATA/REALITY/TABLES/NMS_REALITY_GCPRODUCTTABLE.MBIN',
		MXML_CHANGE_TABLE	= {
			{
				PRECEDING_KEY_WORDS	= 'Table',
				ADD					= ToMxml(ProductEntry({
					{
						id				= 'ULTRAPRODX40',
						name			= 'PRODX40_NAME',
						namelower		= 'PRODX40_NAME_L',
						subtitle		= 'CURIO4_SUBTITLE',
						description		= 'PRODX40_DESC',
						basevalue		= 624000000,
						color			= 'FFCCCCCC',
						category		= 'Special',
						type			= 'Tradeable',
						rarity			= 'Rare',
						legality		= 'Legal',
						iscraftable		= true,
						requirements	= {
							{id='ULTRAPROD1', 		n=20,	tp=IT_.PRD},
							{id='ULTRAPROD2', 		n=20,	tp=IT_.PRD}
						},
						stackmultiplier	= 16,
						icon			= 'TEXTURES/UI/FRONTEND/ICONS/U4PRODUCTS/PRODUCT.CAPTUREDNANODE.DDS'
					},
					{
						id				= 'SUPERFOOD',
						name			= 'SUPERFOOD_NAME',
						namelower		= 'SUPERFOOD_NAME_L',
						subtitle		= 'PROD_NIP_SUBTITLE',
						description		= 'SUPERFOOD_DESC',
						basevalue		= 2,
						color			= 'FF1A273D',
						category		= 'Exotic',
						type			= 'Consumable',
						rarity			= 'Rare',
						legality		= 'Legal',
						consumable		= true,
						requirements	= {
							{id='SENTINEL_LOOT',	n=2,	tp=IT_.PRD},
							{id='FOOD_V_ROBOT',		n=2,	tp=IT_.PRD},
							{id='STELLAR2',			n=50,	tp=IT_.SBT}
						},
						stackmultiplier	= 20,
						foodbonusstat		= 'Suit_Jetpack_Tank',
						foodbonusstatamount = 0.8,
						icon			= 'TEXTURES/UI/FRONTEND/ICONS/PRODUCTS/PRODUCT.GLOWPELLET.DDS'
					}
				}))
			}
		}
	}
}}}}
