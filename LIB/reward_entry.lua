-------------------------------------------------------------------------------
---	MXML 2 LUA ... by lMonk
---	A tool for converting between mxml file format and lua table.
--- The complete tool can be found at: https://github.com/roie-r/mxml_2_lua
-------------------------------------------------------------------------------
---	Construct reward table entries ... version: 1.0.01
-------------------------------------------------------------------------------

--  * Default is first
RC_={--	RewardChoice Enum
	ALL	= 'GiveAll',			ALL_S =	'GiveAllSilent',
	ONE	= 'SelectAlways',		ONE_S =	'SelectAlwaysSilent',
	WIN	= 'SelectFromSuccess',	WIN_S =	'SelectFromSuccessSilent',
	TRY	= 'TryEach',			TRY_1 = 'TryFirst_ThenSelectAlways',
	G1_ONE = 'GiveFirst_ThenAlsoSelectAlwaysFromRest'
}-- Enum
PC_={--	ProceduralProductCategory Enum
	LOT='Loot',					SLV='Salvage',
	DOC='Document',				FOS='Fossil',
	BIO='BioSample',			BNS='Bones',
	PLT='Plant',				TOL='Tool',
	FAR='Farm',					SLT='SeaLoot',
	SHR='SeaHorror',			SPH='SpaceHorror',
	SPB='SpaceBones',
	FRH='FreighterTechHyp',		FRS='FreighterTechSpeed',
	FRF='FreighterTechFuel',	FRT='FreighterTechTrade',
	FRC='FreighterTechCombat',	FRM='FreighterTechMine',
	FRE='FreighterTechExp',
	DBI='DismantleBio',			DTC='DismantleTech',
	DDT='DismantleData'
}-- Enum
IT_={--	InventoryType Enum
	SBT='Substance',	TCH='Technology',	PRD='Product'
}-- Enum
AR_={--	AlienRace Enum
	TRD='Traders',		WAR='Warriors',		XPR='Explorers',
	RBT='Robots',		ATL='Atlas',		DPL='Diplomats',
	XTC='Exotics',		NON='None',			BLD='Builders'
}-- Enum
CU_={--	Currency Enum
	UT='Units',			NN='Nanites',		HG='Specials'
}-- Enum
MI_={--	MultiItemRewardType Enum
	PRD='Product',				SBT='Substance',
	PRT='ProcTech',				PRP='ProcProduct',
	ISP='InventorySlot',		ISS='InventorySlotShip',
	ISW='InventorySlotWeapon'
}-- Enum
RT_={--	Rarity Enum
	C='Common',			U='Uncommon',		R='Rare'
}-- Enum
FT_={--	FrigateFlybyType Enum
	S='SingleShip',		G='AmbientGroup',	W='DeepSpaceCommon'
}-- Enum

--	=> Build reward table entry
function R_RewardTableEntry(rte)
	-- accepts an external list, if not found builds a new one
	if not rte.list then
		rte.list = {}
		for _,rwd in ipairs(rte.itemlist) do
			rte.list[#rte.list+1] = rwd.f(rwd)
		end
	end
	rte.list.meta = {name='List'}
	return {
		meta = {
			name		='GenericTable',
			value		='GcGenericRewardTableEntry',
			_id			=rte.id,
			_overwrite	=rte.overwrite or nil
		},
		Id	 = rte.id,
		List = {
			meta = {name='List', value='GcRewardTableItemList'},
			RewardChoice	= rte.choice or RC_.ONE,			-- Enum
			OverrideZeroSeed= rte.zeroseed,						-- b
			List			= rte.list
		}
	}
end

--	=> Build a single reward item
local function R_tableItem(item, gc_reward, props)
	props.AmountMin = item.mn or item.mx						-- i
	props.AmountMax = item.mx									-- i
	props.meta = {name=gc_reward}
	return {
		meta = {name='List', value='GcRewardTableItem'},
		PercentageChance	= item.c or 1,						-- f
		LabelID				= item.bl,							-- s
		Reward				= {
			meta = {name='Reward', value=gc_reward},
			props
		}
	}
end

--	=> Build GcMultiSpecificItemEntry
function R_MultiItem(item)
	local T = {meta = {name='Items'}}
	for _,itm in ipairs(item.lst) do
		T[#T+1] = {
			meta = {name='Items', value='GcMultiSpecificItemEntry'},
			Id					= itm.id,
			MultiItemRewardType	= itm.mi or MI_.PRD,			-- Enum
			Amount				= itm.am or 1,					-- i
			ProcTechGroup		= itm.tg,						-- s
			ProcTechQuality		= itm.qt, 						-- [0-4] used instead of ProcProdRarity
			IllegalProcTech		= itm.igl,						-- b
			SentinelProcTech	= itm.sen,						-- b
			ProcProdType		= {
				meta = {name='ProcProdType', value='GcProceduralProductCategory'},
				ProceduralProductCategory = itm.pc or PC_.LOT	-- Enum
			}
		}
	end
	return R_tableItem(
		item,
		'GcRewardMultiSpecificItems',
		{
			Silent	= item.sl,									-- b
			Items	= T
		}
	)
end

--	=> Build GcRewardSpecificSubstance
function R_Substance(item)
	return R_tableItem(
		item,
		'GcRewardSpecificSubstance',
		{
			ID				= item.id,
			RewardAsBlobs	= item.bb,							-- b
			Silent			= item.sl							-- b
		}
	)
end

--	=> Build GcRewardSpecificProduct
function R_Product(item)
	return R_tableItem(
		item,
		'GcRewardSpecificProduct',
		{
			ID		= item.id,
			Silent	= item.sl									-- b
		}
	)
end

--	=> Build GcRewardProceduralProduct
function R_ProcProduct(item)
	return R_tableItem(
		item,
		'GcRewardProceduralProduct',
		{
			Type	= {
				meta = {name='Type', value='GcProceduralProductCategory'},
				ProceduralProductCategory = item.pc or PC_.LOT	-- Enum
			},
			OverrideRarity	= item.rt ~= nil,
			Rarity	= {
				meta = {name='Rarity', value='GcRarity'},
				Rarity	= item.rt or RT_.C						-- Enum
			},
			FreighterTechQualityOverride = item.qt or -1		-- [0-3]
		}
	)
end

--	=> Build GcRewardProcTechProduct
function R_ProcTechProduct(item)
	return R_tableItem(
		item,
		'GcRewardProcTechProduct',
		{
			Group					= item.tg,					-- s
			WeightedChanceNormal	= item.w1 or 3,				-- i
			WeightedChanceRare		= item.w2 or 3,				-- i
			WeightedChanceEpic		= item.w3 or 3,				-- i
			WeightedChanceLegendary	= item.w4 or 3,				-- i
			ForceRelevant			= item.frl,					-- b
			ForceQualityRelevant	= item.fqr,					-- b
		}
	)
end

--	=> Build GcRewardDisguisedProduct
function R_DisguisedProduct(item)
	return R_tableItem(
		item,
		'GcRewardDisguisedProduct',
		{
			ID						= item.id,
			DisplayAs				= item.display,				-- s
			UseDisplayIDWhenInShip	= true,						-- b
		}
	)
end

--	=> Build GcRewardMultiSpecificProducts
function R_ProductAllList(item)
	return R_tableItem(
		item,
		'GcRewardMultiSpecificProducts',
		{
			ProductIds = StringArray(item.id, 'ProductIds')
		}
	)
end

--	=> Build GcRewardSpecificTech
function R_Technology(item)
	return R_tableItem(
		item,
		'GcRewardSpecificTech',
		{
			TechId	= item.id,
			Silent	= item.sl									-- b
		}
	)
end

--	=> Build GcRewardMultiSpecificTechRecipes
function R_TechnologyList(item)
	return R_tableItem(
		item,
		'GcRewardMultiSpecificTechRecipes',
		{
			TechIds			= StringArray(item.id, 'TechIds'),
			DisplayTechId	= item.id[1],						-- s
			SetName			= item.nm,							-- s
			Silent			= item.sl							-- b
		}
	)
end

--	=> Build GcRewardSpecificProductRecipe
function R_ProductRecipe(item)
	return R_tableItem(
		item,
		'GcRewardSpecificProductRecipe',
		{
			ID		= item.id,
			Silent	= item.sl									-- b
		}
	)
end

--	=> Build GcRewardMultiSpecificProductRecipes
function R_ProductRecipeList(item)
	return R_tableItem(
		item,
		'GcRewardMultiSpecificProductRecipes',
		{
			ProductIds		= StringArray(item.id, 'ProductIds'),
			DisplayProductId= item.id[1],						-- s
			SetName			= item.nm,							-- s
			Silent			= item.sl							-- b
		}
	)
end

--	=> Build GcRewardTeachWord
function R_Word(item)
	return R_tableItem(
		item,
		'GcRewardTeachWord',
		{
			Race = {
				meta		= {name='Race', value='GcAlienRace'},
				AlienRace	= item.ar							-- Enum
			}
		}
	)
end

--	=> Build GcRewardMoney
function R_Money(item)
	return R_tableItem(
		item,
		'GcRewardMoney',
		{
			Currency = {
				meta		= {name='Currency', value='GcCurrency'},
				Currency	= item.id							-- Enum
			}
		}
	)
end

--	=> Build GcRewardJetpackBoost
function R_Jetboost(item)
	return R_tableItem(
		item,
		'GcRewardJetpackBoost',
		{
			Duration		= (10 *  item.tm),					-- f
			ForwardBoost	= (4.2 * item.pw),					-- f
			UpBoost			= (0.9 * item.pw),					-- f
			IgnitionBoost	= (1.6 * item.pw)					-- f
		}
	)
end

--	=> Build GcRewardFreeStamina
function R_Stamina(item)
	return R_tableItem(
		item,
		'GcRewardFreeStamina',
		{
			Duration		= (10 * item.tm)					-- f
		}
	)
end

--	=> Build GcRewardRefreshHazProt
function R_Hazard(item)
	return R_tableItem(
		item,
		'GcRewardRefreshHazProt',
		{
			Amount			= item.am,							-- f
			Silent			= item.sl,							-- b
			SpecificHazard	= item.hz and {
				meta	= {name='SpecificHazard', value='GcPlayerHazardType'},
				Hazard	= item.hz								-- Enum
			} or nil
		}
	)
end

--	=> Build GcRewardShield
function R_Shield(item)
	return R_tableItem(item, 'GcRewardShield', {})
end

--	=> Build GcRewardHealth
function R_Health(item)
	return R_tableItem(
		item,
		'GcRewardHealth',
		{
			SilentUnlessShieldAtMax = item.sl
		}
	)
end

--	=> Build GcRewardWantedLevel
function R_Wanted(item)
	return R_tableItem(
		item,
		'GcRewardWantedLevel',
		{
			Level	= item.lvl or 0								-- i (0-5)
		}
	)
end

--	=> Build GcRewardDisableSentinels
function R_NoSentinels(item)
	return R_tableItem(
		item,
		'GcRewardDisableSentinels',
		{
			Duration			= item.tm or -1,				-- f
			WantedBarMessage	= 'UI_SENTINELS_DISABLED_MSG'
		}
	)
end

--	=> Build GcRewardTriggerStorm
function R_Storm(item)
	return R_tableItem(
		item,
		'GcRewardTriggerStorm',
		{
			Duration			= item.tm or -1					-- f
		}
	)
end

--	=> Build GcRewardFrigateFlyby
function R_FlyBy(item)
	return R_tableItem(
		item,
		'GcRewardFrigateFlyby',
		{
			FlybyType = {
				meta	= {name='FlybyType', value='GcFrigateFlybyType'},
				FrigateFlybyType = item.tp or FT_.W				-- Enum
			},
			AppearanceDelay	= item.tm or 3,						-- f
			CameraShake		= 'FRG_FLYBY_PREP'
		}
	)
end

--	=> Build GcRewardOpenPage
function R_OpenPage(item)
	return R_tableItem(
		item,
		'GcRewardOpenPage',
		{
			PageToOpen				= item.id,					-- Enum
			ReinteractWhenComplete	= item.Reinteract			-- b
		}
	)
end

--	=> Build GcRewardOpenUnlockTree
function R_UnlockTree(item)
	return R_tableItem(
		item,
		'GcRewardOpenUnlockTree',
		{
			TreeToOpen = {
				meta	= {name='TreeToOpen', value='GcUnlockableItemTreeGroups'},
				UnlockableItemTree = item.id					-- Enum
			}
		}
	)
end

--	=> Build GcRewardUnlockSeasonReward
function R_UnlockSeasonal(item)
	return R_tableItem(
		item,
		'GcRewardUnlockSeasonReward',
		{
			ProductID				= item.id,
			Silent					= item.sl,					-- b
			UseSpecialFormatting	= item.frt,					-- b
			MarkAsClaimedInShop		= item.mc or true,			-- b
			UniqueInventoryItem		= item.unq					-- b
		}
	)
end

--	=> Build GcRewardSpecificSpecial
function R_Special(item)
	return R_tableItem(
		item,
		'GcRewardSpecificSpecial',
		{
			ProductID				= item.id,
			ShowSpecialProductPopup	= item.pop,					-- b
			UseSpecialFormatting	= item.frt,					-- b
			HideInSeasonRewards		= item.hid					-- b
		}
	)
end

--	=> Build GcInventoryElement
--	Used by ship & tool rewards for tech inventory only
local function inventoryContainer(inventory)
	if not inventory then return nil end
	local T = {meta = {name='Slots'}}
	for id, chrg in pairs(inventory) do
		T[#T+1] = {
			meta	= {name='Slots', value='GcInventoryElement'},
			Id				= id,
			Amount			= chrg and 10000 or -1,				-- i
			MaxAmount		= chrg and 10000 or 100,			-- i
			FullyInstalled	= true,
			Type			= {
				meta	= {name='Type', value='GcInventoryType'},
				InventoryType	= IT_.TCH						-- Enum
			},
			Index	= {
				meta	= {name='Index', value='GcInventoryIndex'},
				X		= -1,									-- i
				Y		= -1									-- i
			}
		}
	end
	return T
end

--	=> Build GcRewardSpecificShip
function R_Ship(item)
	return R_tableItem(
		item,
		'GcRewardSpecificShip',
		{
			ShipResource = {
				meta	= {name='ShipResource', value='GcResourceElement'},
				Filename = item.filename,						-- s
				Seed	= item.seed,							-- uint
			},
			ShipLayout	= {
				meta	= {name='ShipLayout', value='GcInventoryLayout'},
				Slots	= item.slots or 50						-- i
			},
			ShipInventory = {
				meta	= {name='ShipInventory', value='GcInventoryContainer'},
				Inventory	= inventoryContainer(item.inventory),
				Class		= {
					meta	= {name='Class', value='GcInventoryClass'},
					InventoryClass	= item.class and item.class:upper() or 'C'	-- Enum
				},
				BaseStatValues	= (
					function()
						local stat = nil
						if item.filename:find('BIOSHIP')  then stat = 'ALIEN_SHIP' end
						if item.filename:find('SENTINEL') then stat = 'ROBOT_SHIP' end
						return stat and {
							meta	= {name='BaseStatValues'},
							{
								meta		= {name='BaseStatValues', value='GcInventoryBaseStatEntry'},
								Value		= 1,
								BaseStatID	= stat
							}
						} or nil
					end
				)(),
			},
			Customisation = item.custom and {
				meta = {name='Customisation', value='GcCharacterCustomisationData'},
				DescriptorGroups	= StringArray(item.custom.shipparts, 'DescriptorGroups'),
				PaletteID			= item.custom.paletteid,
				Colours				= (
					function()
						local T = {meta = {name='Colours'}}
						for _,col in ipairs(item.custom.colors) do
							T[#T+1] = {
								meta	= {name='Colours', value='GcCharacterCustomisationColourData'},
								Palette	= {
									meta	= {name='Palette', value='TkPaletteTexture'},
									Palette		= col.palette,				-- Enum
									ColourAlt	= col.alt					-- Enum
								},
								Colour	= ColorData(col.rgb, 'Colour')		-- rgb
							}
						end
						return T
					end
				)(),
				TextureOptions		= {
					meta = {name='TextureOptions'},
					{
						meta = {name='TextureOptions', value='GcCharacterCustomisationTextureOptionData'},
						TextureOptionGroupName	= item.custom.texturegroup,	-- s
						TextureOptionName		= item.custom.texturename	-- s
					}
				},
				Scale	= 1
			} or nil,
			ShipType	= {
				meta	= {name='ShipType', value='GcSpaceshipClasses'},
				ShipClass	= item.modeltype					-- Enum
			},
			UseOverrideSizeType	= item.sizetype ~= nil,
			OverrideSizeType	= {
				meta	= {name='OverrideSizeType', value='GcInventoryLayoutSizeType'},
				SizeType	= item.sizetype	or 'DrpLarge'		-- Enum
			},
			NameOverride	= item.name,						-- s
			IsRewardShip	= true,
			IsGift			= true,
			ModelViewOverride	= {
				meta	= {name='ModelViewOverride', value='GcModelViews'},
				ModelViews	= item.modelviews or 'Ship'			-- Enum
			}
		}
	)
end

--	=> Build GcRewardSpecificWeapon
function R_Multitool(item)
	return R_tableItem(
		item,
		'GcRewardSpecificWeapon',
		{
			WeaponResource = {
				meta	= {name='WeaponResource', value='GcExactResource'},
				Filename		= item.filename,				-- s
				GenerationSeed	= item.seed						 -- uint
			},
			WeaponLayout	= {
				meta	= {name='WeaponLayout', value='GcInventoryLayout'},
				Slots	= item.slots or 30,						-- i
				Seed	= item.seed								-- uint
			},
			WeaponInventory	= {
				meta	= {name='WeaponInventory', value='GcInventoryContainer'},
				Inventory	= inventoryContainer(item.inventory),
				Class		= {
					meta	= {name='Class', value='GcInventoryClass'},
					InventoryClass	= item.class and item.class:upper() or 'C'	-- Enum
				}
			},
			WeaponType		= {
				meta	= {name='WeaponType', value='GcWeaponClasses'},
				WeaponStatClass	= item.modeltype				-- Enum
			},
			InventorySizeOverride	= {
				meta	= {name='InventorySizeOverride', value='GcInventoryLayoutSizeType'},
				SizeType	= item.sizetype	or 'WeaponLarge'	-- Enum
			},
			NameOverride	= item.name,						-- s
			IsRewardWeapon	= true,
			IsGift		 	= true
		}
	)
end
