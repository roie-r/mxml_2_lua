-------------------------------------------------------------------------------
---	Construct reward table entries (VERSION: 0.88.03) ... by lMonk
---	* Requires _lua_2_mxml.lua !
---	* This script should be in [AMUMSS folder]\ModScript\ModHelperScripts\LIB
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

function R_TableItem(item, gc_reward, props)
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
	return R_TableItem(
		item,
		'GcRewardMultiSpecificItems',
		{
			Silent	= item.sl,									-- b
			Items	= T
		}
	)
end

function R_Substance(item)
	return R_TableItem(
		item,
		'GcRewardSpecificSubstance',
		{
			ID				= item.id,
			RewardAsBlobs	= item.bb,							-- b
			Silent			= item.sl							-- b
		}
	)
end

function R_Product(item)
	return R_TableItem(
		item,
		'GcRewardSpecificProduct',
		{
			ID		= item.id,
			Silent	= item.sl									-- b
		}
	)
end

function R_ProcProduct(item)
	return R_TableItem(
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

function R_ProcTechProduct(item)
	return R_TableItem(
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

function R_DisguisedProduct(item)
	return R_TableItem(
		item,
		'GcRewardDisguisedProduct',
		{
			ID						= item.id,
			DisplayAs				= item.display,				-- s
			UseDisplayIDWhenInShip	= true,						-- b
		}
	)
end

function R_ProductAllList(item)
	return R_TableItem(
		item,
		'GcRewardMultiSpecificProducts',
		{
			ProductIds = StringArray(item.id, 'ProductIds')
		}
	)
end

function R_Technology(item)
	return R_TableItem(
		item,
		'GcRewardSpecificTech',
		{
			TechId	= item.id,
			Silent	= item.sl									-- b
		}
	)
end

function R_TechnologyList(item)
	return R_TableItem(
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

function R_ProductRecipe(item)
	return R_TableItem(
		item,
		'GcRewardSpecificProductRecipe',
		{
			ID		= item.id,
			Silent	= item.sl									-- b
		}
	)
end

function R_ProductRecipeList(item)
	return R_TableItem(
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

function R_Word(item)
	return R_TableItem(
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

function R_Money(item)
	return R_TableItem(
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

function R_Jetboost(item)
	return R_TableItem(
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

function R_Stamina(item)
	return R_TableItem(
		item,
		'GcRewardFreeStamina',
		{
			Duration		= (10 * item.tm)					-- f
		}
	)
end

function R_Hazard(item)
	return R_TableItem(
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

function R_Shield(item)
	return R_TableItem(item, 'GcRewardShield', {})
end

function R_Health(item)
	return R_TableItem(
		item,
		'GcRewardHealth',
		{
			SilentUnlessShieldAtMax = item.sl
		}
	)
end

function R_Wanted(item)
	return R_TableItem(
		item,
		'GcRewardWantedLevel',
		{
			Level	= item.lvl or 0								-- i (0-5)
		}
	)
end

function R_NoSentinels(item)
	return R_TableItem(
		item,
		'GcRewardDisableSentinels',
		{
			Duration			= item.tm or -1,				-- f
			WantedBarMessage	= 'UI_SENTINELS_DISABLED_MSG'
		}
	)
end

function R_Storm(item)
	return R_TableItem(
		item,
		'GcRewardTriggerStorm',
		{
			Duration			= item.tm or -1					-- f
		}
	)
end

function R_FlyBy(item)
	return R_TableItem(
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

function R_OpenPage(item)
	return R_TableItem(
		item,
		'GcRewardOpenPage',
		{
			PageToOpen				= item.id,					-- Enum
			ReinteractWhenComplete	= item.Reinteract			-- b
		}
	)
end

function R_UnlockTree(item)
	return R_TableItem(
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

function R_UnlockSeasonal(item)
	return R_TableItem(
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

function R_Special(item)
	return R_TableItem(
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

--	Used by ship & tool rewards for tech inventory only
local function InventoryContainer(inventory)
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

function R_Ship(item)
	return R_TableItem(
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
				Inventory	= InventoryContainer(item.inventory),
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

function R_Multitool(item)
	return R_TableItem(
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
				Inventory	= InventoryContainer(item.inventory),
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
