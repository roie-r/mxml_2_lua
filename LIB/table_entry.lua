-------------------------------------------------------------------------------
---	MXML 2 LUA ... by lMonk
---	A tool for converting between mxml file format and lua table.
--- The complete tool can be found at: https://github.com/roie-r/mxml_2_lua
-------------------------------------------------------------------------------
---	Reality tables entries ... version: 1.01.0
---	Build full table entries for technology, proc-tech, product, recipe,
---  and basebuild objects and basebuild parts.
---	* Not ALL class properties are included. Some who are unused/deprecated
---	 or can safely remain with a default value are omitted.
-------------------------------------------------------------------------------

IT_={--	InventoryType Enum
	SBT='Substance',	TCH='Technology',	PRD='Product'
}-- Enum

--	=> build the requirements table for tech and products
--	receives a table of {id, amount, product/substance} items
function GetRequirements(r)
	if not r then return nil end
	local reqs = {meta = {name='Requirements'}}
	for _,req in ipairs(r) do
		reqs[#reqs+1] = {
			meta	= {name='Requirements', value='GcTechnologyRequirement'},
			ID		= req.id,
			Amount	= req.n,							--	i
			Type	= {
				meta	= {name='Type', value='GcInventoryType'},
				InventoryType = req.tp					--	Enum
			}
		}
	end
	return reqs
end

--	=> receives a table of {type, bonus, level} items
function TechStatBonus(tsb)
	return {
		meta	= {name='StatBonuses', value='GcStatsBonus'},
		Stat	= {
			meta		= {name='Stat', value='GcStatsTypes'},
			StatsType	= tsb.st					--	Enum
		},
		Bonus	= tsb.bn,							--	f
		Level	= tsb.lv or 0						--	i 0-4
	}
end

--	=> Build an entry for NMS_REALITY_GCTECHNOLOGYTABLE
--	* handles multiple entries
function TechnologyEntry(items)
	local function techEntry(tech)
		return {
			meta			= {name='Table', value='GcTechnology'},
			ID				= tech.id,
			Group			= tech.group,									--	s
			Name			= tech.name,									--	s
			NameLower		= tech.namelower,								--	s
			Subtitle		= tech.subtitle,								--	s
			Description		= tech.description,								--	s
			Teach			= true,
			HintStart		= tech.hintstart,
			HintEnd			= tech.hintend,
			Icon			= {
				meta	= {name='Icon', value='TkTextureResource'},
				Filename	= tech.icon,									--	s
			},
			Colour			= ColorData(tech.color, 'Colour'),				--	rgb/hex
			Level			= 1,
			Chargeable		= tech.chargeable,								--	b
			ChargeAmount	= tech.chargeamount	or 100,						--	i
			ChargeType		= {
				meta	= {name='ChargeType', value='GcRealitySubstanceCategory'},
				SubstanceCategory = (tech.chargetype or 'Earth'),			--	E
			},
			ChargeBy		= StringArray(tech.chargeby, 'ChargeBy'),		--	Id
			ChargeMultiplier= tech.chargemultiply or 1,
			BuildFullyCharged= true,
			UsesAmmo		= tech.usesammo,								--	b
			AmmoId			= tech.ammoid,									--	Id
			PrimaryItem		= tech.primaryitem,								--	b
			Upgrade			= tech.upgrade,									--	b
			Core			= tech.core,									--	b
			Procedural		= tech.istemplate,								--	not a bug
			Category		= {
				meta	= {name='Category', value='GcTechnologyCategory'},
				TechnologyCategory = tech.category,							--	Enum
			},
			Rarity			= {
				meta	= {name='Rarity', value='GcTechnologyRarity'},
				TechnologyRarity = tech.rarity	or 'Normal',				--	Enum
			},
			Value			= tech.value		or 10,						--	i
			Requirements	= GetRequirements(tech.requirements),
			BaseStat		= {
				meta	= {name='BaseStat', value='GcStatsTypes'},
				StatsType	= tech.basestat,								--	Enum
			},
			StatBonuses		= (
				function()
					local stats = {meta = {name='StatBonuses'}}
					for _,tsb in ipairs(tech.statbonuses) do
						stats[#stats+1] = TechStatBonus(tsb)
					end
					return stats
				end
			)(),
			RequiredTech	= tech.requiredtech,							--	Id
			FocusLocator	= tech.focuslocator,							--	??
			UpgradeColour	= ColorData(tech.upgradecolor, 'UpgradeColour'),--	rgb/hex
			LinkColour		= ColorData(tech.linkcolor, 'LinkColour'),		--	rgb/hex
			BaseValue		= 1,
			RequiredRank	= tech.requiredrank	or 1,
			FragmentCost	= tech.fragmentcost	or 1,
			TechShopRarity	= {
				meta	= {name='TechShopRarity', value='GcTechnologyRarity'},
				TechnologyRarity = tech.rarity	or 'Normal',				--	E
			},
			WikiEnabled		= tech.wikienabled,								--	b
			DamagedDescription	= tech.damagedesc,							--	s
			IsTemplate		= tech.istemplate,								--	b
			ExclusivePrimaryStat= tech.exclusiveprimarystat					--	b
		}
	end
	return ProcessOnenAll(items, techEntry)
end

--	=> Build an entry for NMS_REALITY_GCPRODUCTTABLE
--	* handles multiple entries
function ProductEntry(items)
	local function prodEntry(prod)
		return {
			meta	= {name='value', value='GcProductData'},
			ID			= prod.id,
			Name		= prod.name,									--	s
			NameLower	= prod.namelower,								--	s
			Subtitle	= prod.subtitle,								--	s
			Description	= prod.description,								--	s
			DebrisFile	= {
				meta	= {name='DebrisFile', value='TkModelResource'},
				Filename= 'MODELS/EFFECTS/DEBRIS/TERRAINDEBRIS/TERRAINDEBRIS4.SCENE.MBIN'
			},
			BaseValue	= prod.basevalue or 1,							--	i
			Icon		= {
				meta	= {name='Icon', value='TkTextureResource'},
				Filename= prod.icon										--	s
			},
			Colour		= ColorData(prod.color, 'Colour'),				--	rgb/hex
			Category	= {
				meta	= {name='Category', value='GcRealitySubstanceCategory'},
				SubstanceCategory	= prod.category	or 'Earth'			--	Enum
			},
			Type		= {
				meta	= {name='Type', value='GcProductCategory'},
				ProductCategory		= prod.type		or 'Component'		--	Enum
			},
			Rarity		= {
				meta	= {name='Rarity', value='GcRarity'},
				Rarity				= prod.rarity	or 'Common'			--	Enum
			},
			Legality	= {
				meta	= {name='Legality', value='GcLegality'},
				Legality			= prod.legality	or 'Legal'			--	Enum
			},
			Consumable				= prod.consumable,					--	b
			ChargeValue				= prod.chargevalue,					--	i
			StackMultiplier			= prod.stackmultiplier	or 1,
			DefaultCraftAmount		= prod.craftamount		or 1,
			CraftAmountStepSize		= prod.craftstep		or 1,
			CraftAmountMultiplier	= prod.crafmultiplier	or 1,
			Requirements			= GetRequirements(prod.requirements),
			Cost		= {
				meta	= {name='Cost', value='GcItemPriceModifiers'},
				SpaceStationMarkup	= prod.spacestationmarkup,
				LowPriceMod			= prod.lowpricemod		or -0.1,
				HighPriceMod		= prod.highpricemod		or 0.1,
				BuyBaseMarkup		= prod.buybasemarkup	or 0.2,
				BuyMarkupMod		= prod.buymarkupmod
			},
			RecipeCost				= prod.recipecost		or 1,
			SpecificChargeOnly		= prod.specificchargeonly,			--	b
			NormalisedValueOnWorld	= prod.normalisedvalueonworld,		--	f
			NormalisedValueOffWorld	= prod.normalisedvalueoffworld,		--	f
			TradeCategory = {
				meta	= {name='TradeCategory', value='GcTradeCategory'},
				TradeCategory	= prod.tradecategory or 'None'			--	Enum
			},
			WikiCategory				= prod.wikicategory or 'NotEnabled',
			IsCraftable					= prod.iscraftable,				--	b
			DeploysInto					= prod.deploysinto,				--	Id
			EconomyInfluenceMultiplier	= prod.economyinfluence,		--	i
			PinObjective				= prod.pinobjective,			--	s
			PinObjectiveTip				= prod.pinobjectivetip,			--	s
			CookingIngredient			= prod.cookingingredient,		--	b
			CookingValue				= prod.cookingvalue,			--	i
			FoodBonusStat = {
				meta	= {name='FoodBonusStat', value='GcStatsTypes'},
				StatsType	= prod.foodbonusstat or 'Unspecified'		--	Enum
			},
			FoodBonusStatAmount			= prod.foodbonusstatamount,		--	f
			GoodForSelling				= prod.goodforselling,			--	b
			GiveRewardOnSpecialPurchase	= prod.rewardspecialpurchase,	--	b
			EggModifierIngredient		= prod.eggmodifier,				--	b
			IsTechbox					= prod.istechbox,				--	b
			CanSendToOtherPlayers		= prod.sendtoplayer				--	b
		}
	end
	return ProcessOnenAll(items, prodEntry)
end

--	=> receives a table of {type, min, max, weightcurve, always} items
function ProcTechStatLevel(tsl)
	return {
		meta		= {name='value', value='GcProceduralTechnologyStatLevel'},
		Stat		= {
			meta = {name='Stat', value='GcStatsTypes'},
			StatsType = tsl.st,							--	Enum
		},
		ValueMin	= tsl.mn and tsl.mn or tsl.mx,		--	f
		ValueMax	= tsl.mx,							--	f
		WeightingCurve = {
			meta = {name='WeightingCurve', value='GcWeightingCurve'},
			WeightingCurve = tsl.wc or 'NoWeighting',	--	Enum
		},
		AlwaysChoose= tsl.ac							--	b
	}
end

--	=> Build an entry for NMS_REALITY_GCPROCEDURALTECHNOLOGYTABLE
--	* handles multiple entries
function ProcTechEntry(items)
	local function proctechEntry(tech)
		return {
			meta	= {name='value', value='GcProceduralTechnologyData'},
			ID				= tech.id,
			Template		= tech.template,
			Name			= tech.name,
			NameLower		= tech.namelower,
			Group			= tech.namelower, -- not a bug
			Subtitle		= tech.subtitle,
			Description		= tech.description,
			Colour			= ColorData(tech.color, 'Colour'),			--	rgb/hex
			Quality			= tech.quality or 'Normal',					--	Enum
			Category		= {
				meta = {name='Category', value='GcProceduralTechnologyCategory'},
				ProceduralTechnologyCategory = tech.category,			--	Enum
			},
			NumStatsMin		= tech.numstatsmin,							--	i
			NumStatsMax		= tech.numstatsmax,							--	i
			WeightingCurve	= {
				meta = {name='WeightingCurve', value='GcWeightingCurve'},
				WeightingCurve = tech.weightingcurve or 'NoWeighting',	--	Enum
			},
			UpgradeColour	= ColorData(tech.upgradecolor, 'UpgradeColour'),
			StatLevels		= (
				function()
					local stats = {meta = {name='StatLevels'}}
					for _,sl in ipairs(tech.statlevels) do
						stats[#stats+1] = ProcTechStatLevel(sl)
					end
					return stats
				end
			)()
		}
	end
	return ProcessOnenAll(items, proctechEntry)
end

--	=> Build an entry for BASEBUILDINGOBJECTSTABLE
--	* handles multiple entries
function BaseBuildObjectEntry(items)
	local function baseObjectEntry(bpart)
		return {
			meta = {name='value', value='GcBaseBuildingEntry'},
			ID							= bpart.id,
			Style						= {
				meta		= {name='Style', value='GcBaseBuildingPartStyle'},
				Style		= bpart.style or 'None'						--	Enum
			},
			PlacementScene				= {
				meta		= {name='PlacementScene', value='TkModelResource'},
				Filename	= bpart.placementscene
			},
			DecorationType				= {
				meta		= {name='DecorationType', value='GcBaseBuildingObjectDecorationTypes'},
				BaseBuildingDecorationType = bpart.decorationtype or 'Normal'--	Enum
			},
			IsPlaceable					= bpart.isplaceable,			--	b
			IsDecoration				= bpart.isdecoration,			--	b
			BuildableOnPlanetBase 		= bpart.onplanetbase,			--	b
			BuildableOnFreighter		= bpart.onfreighter,			--	b
			BuildableOnPlanet			= bpart.onplanet,				--	b
			BuildableUnderwater			= true,
			BuildableAboveWater			= true,
			CheckPlayerCollision		= false,
			CanRotate3D					= true,
			CanScale					= true,
			Groups						= (
				function()
					if not bpart.groups then return nil end
					local T = {meta = {name='Groups'}}
					for _,v in ipairs(bpart.groups) do
						T[#T+1] = {
							meta	= {name='value', value='GcBaseBuildingEntryGroup'},
							Group			= v.group,
							SubGroupName	= v.subname
						}
					end
					return T
				end
			)(),
			StorageContainerIndex 		= -1,							--	i
			CanChangeColour				= true,
			CanChangeMaterial			= true,
			CanPickUp					= bpart.canpickup,				--	b
			ShowInBuildMenu				= true,
			CompositePartObjectIDs		= StringArray(bpart.compositeparts, 'CompositePartObjectIDs'),
			FamilyIDs					= StringArray(bpart.familyids, 'FamilyIDs'),
			BuildEffectAccelerator		= 1,							--	i
			RemovesAttachedDecoration	= true,
			RemovesWhenUnsnapped		= false,
			EditsTerrain				= bpart.editsterrain,			--	b
			BaseTerrainEditShape		= 'Cube',						--	Enum
			MinimumDeleteDistance		= 1,							--	i
			IsSealed					= bpart.issealed,				--	b
			CloseMenuAfterBuild			= bpart.closemenuafterbuild,
			LinkGridData				= {
				meta = {name='LinkGridData', value='GcBaseLinkGridData'},
				Connection = {
					meta	= {name='Connection', value='GcBaseLinkGridConnectionData'},
					Network	= {
						meta = {name='Network', value='GcLinkNetworkTypes'},
						LinkNetworkType = bpart.linknetwork or 'Power'	--	Enum
					},
					NetworkSubGroup		= bpart.networksubgroup,		--	i
					NetworkMask			= bpart.networkmask,			--	i
					ConnectionDistance	= 0.1							--	f
				},
				Rate					= bpart.rate,					--	f
				Storage					= bpart.storage					--	i
			},
			ShowGhosts					= bpart.showghosts,				--	b
			GhostsCountOverride			= 0,
			SnappingDistanceOverride	= 0,
			RegionSpawnLOD				= 1
		}
	end
	return ProcessOnenAll(items, baseObjectEntry)
end

--	=> Build an entry for BASEBUILDINGPARTSTABLE
--	* handles multiple entries
function BaseBuildPartEntry(items)
	local function basePartEntry(bpart)
		local T = {
			meta	= {name='value', value='GcBaseBuildingPart'},
			ID		= bpart.id,
			StyleModels = {meta = {name='StyleModels'}}
		}
		for _,src in ipairs(bpart.stylemodels) do
			T.StyleModels[#T.StyleModels+1] = {
				meta = {name='value', value='GcBaseBuildingPartStyleModel'},
				Style = {
					meta = {name='Style', value='GcBaseBuildingPartStyle'},
					Style = src.style or 'None',						--	Enum
				},
				Model = {
					meta = {name='Model', value='TkModelResource'},
					Filename = src.act,
				},
				Inactive = {
					meta = {name='Inactive', value='TkModelResource'},
					Filename = src.lod
				}
			}
		end
		return T
	end
	return ProcessOnenAll(items, basePartEntry)
end

--	=> Build an entry for NMS_REALITY_GCRECIPETABLE
--	* handles multiple entries
function RefinerRecipeEntry(items)
	local function addIngredient(elem, result)
		return {
			meta	= {name=(result and 'Result' or 'value'), value='GcRefinerRecipeElement'},
			Id		= elem.id,
			Amount	= elem.n,										--	i
			Type	= {
				meta			= {name='Type', value='GcInventoryType'},
				InventoryType	= elem.tp							--	Enum
			}
		}
	end
	local function refinerecipeEntry(recipe)
		local igrds = {meta = {name='Ingredients'}}
		for _,elem in ipairs(recipe.ingredients) do
			igrds[#igrds+1] = addIngredient(elem)
		end
		return {
			meta	= {name='value', value='GcRefinerRecipe'},
			Id			= recipe.id,
			RecipeType	= recipe.name,									--	s
			RecipeName	= recipe.name,									--	s
			TimeToMake	= recipe.make,									--	i
			Cooking		= recipe.cook,									--	b
			Result		= addIngredient(recipe.result, true),
			Ingredients	= igrds
		}
	end
	return ProcessOnenAll(items, refinerecipeEntry)
end

--	=> builds a LocalisationTable from text entries.
--	receives a table of items in the following structure
--	UNIQUE_ID = {
--	  EN = [[your text line here]],
--	  FR = [[votre ligne de texte ici]],
--	}
function LocalisationTable(texts)
	local languages = {
		EN = 'English',
		FR = 'French',
		IT = 'Italian',
		DE = 'German',
		ES = 'Spanish',
		RU = 'Russian',
		PL = 'Polish',
		NL = 'Dutch',
		PT = 'Portuguese',
		LA = 'LatinAmericanSpanish',
		BR = 'BrazilianPortuguese',
		Z1 = 'SimplifiedChinese',
		ZH = 'TraditionalChinese',
		Z2 = 'TencentChinese',
		KO = 'Korean',
		JA = 'Japanese',
		US = 'USEnglish'
	}
	-- replace problematic characters with char entities
	local function insertCharEntities(s)
		local entity = {
			{'&',	'&amp;'}, -- must be first
			{'<',	'&lt;'},
			{'>',	'&gt;'},
			{'"',	'&quot;'},
			{'|N|',	'&#xA;'}
		}
		for _,e in ipairs(entity) do
			s = s:gsub(e[1], e[2])
		end
		return s
	end
	if not texts then return nil end
	local l_txt = {meta = {name='Table'}}
	for id, text in pairs(texts) do
		local inx = #l_txt+1
		l_txt[inx] = {
			meta	= {name='Table', value='TkLocalisationEntry'},
			Id		= id
		}
		for code, txt in pairs(text) do
			l_txt[inx][languages[code]] = insertCharEntities(txt)
		end
	end
	return l_txt
end
