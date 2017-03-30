package states.game.teamsData
{
	import flash.desktop.NativeProcessStartupInfo;
	import flash.net.ObjectEncoding;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	import global.ai.AIController;
	import global.enums.Agent;
	import global.enums.AiBehaviours;
	import global.enums.UnitStates;
	import global.GameSounds;
	import global.map.mapTypes.Board;
	import global.map.Node;
	import global.map.SpiralBuilder;
	import global.Methods;
	import global.Parameters;
	import global.utilities.SightManager;
	import states.game.entities.buildings.RepairFacility;
	import states.game.teamsData.PowerController;
	import states.game.teamsData.TeamBuildManager;
	import global.utilities.GameTimer;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import states.game.entities.buildings.Building;
	import states.game.entities.buildings.BuildingModel;
	import states.game.entities.buildings.BuildingView;
	import states.game.entities.buildings.Refinery;
	import states.game.entities.buildings.Turret;
	import states.game.entities.GameEntity;
	import states.game.stats.AssetStatsObj;
	import states.game.stats.BuildingsStats;
	import states.game.stats.BuildingsStatsObj;
	import states.game.stats.InfantryStats;
	import states.game.stats.TurretStats;
	import states.game.stats.VehicleStats;
	import states.game.entities.units.*;
	import states.game.stats.VehicleStatsObj;
	import states.game.ui.SellRepairManager;
	
	public class TeamObject extends EventDispatcher
	{
		public var ai:int;
		public var agent:int;
		public var teamName:String;
		
		public var team:Array = [];
		
		public var enemyTeams:Array = [];
		private var enemyTeamObjs:Array = [];
		
		
		
		public var teamNum:int;
		
		public var buildManager:TeamBuildManager;
		
		public var powerCtrl:PowerController;
		public var startParams:Object;
		
		
		
		public var teamBuildingsDict:Dictionary = new Dictionary();
		private var buildingsSight:Object;
		
		private var sellRepairManager:SellRepairManager;

		private var fromSaveGame:Boolean;
		public var cashManager:CashManager;
		
		public var currentSearchAndDestroyEnemy:GameEntity;
		private var teamHarvester:Harvester;
		private var teamRefinery:Refinery;
		private var numTurrets:int = 0;
		private var numOfHarvesters:int = 0;
		public var sightManager:SightManager;
		public var color:uint;
		public var teamColor:String;
		public var aiController:AIController;
		public var weaponsProvider:String;
		
		public function TeamObject(_startParams:Object, _teamNum:int,  _fromSaveGame:Boolean)
		{
			teamColor = _startParams.color;
			weaponsProvider = _startParams.weaponsProvider;
			
			color=  Parameters.colors[_startParams.color]
			
			startParams = _startParams;
			ai = startParams.AiBehaviour;
			agent = startParams.agent;
			teamName = startParams.teamName;
			fromSaveGame = _fromSaveGame;
			
			teamNum = _teamNum;

			buildingsSight = new Object();
			
			if (cashManager == null)
			{
				cashManager = new CashManager(startParams.cash, this);
			}
			if (sellRepairManager == null)
			{
				sellRepairManager = new SellRepairManager(this);
			}
			
			sightManager = new SightManager(this);
			
			GameTimer.getInstance().addUser(this);
		}
		
		
		public function getSaveObj():Object
		{
		
			var o:Object = { };
			o.AiBehaviour = ai;
			o.Agent = agent;
			o.teamName = teamName;
			o.cash = cashManager.cash;
			o.teamNum = teamNum;
			o.color = teamColor;
			o.weaponsProvider = weaponsProvider;
			
			var teamLen:int = team.length;
			o.startVehicles = [];
			o.startTurrets = [];
			o.startUnits = [];
			o.startBuildings = [];
			var u:GameEntity;
			for (var i:int = 0; i < teamLen; i++ )
			{
				u = team[i];
				var stats:Object = {"row" : u.model.row, "col" : u.model.col, "health" : u.getHealth(), "ai" : u.aiBehaviour, "uniqueID" : u.uniqueID, "name" : u.name}
				if (u is Infantry)
				{
					o.startUnits.push(stats)
				}
				if (u is Vehicle)
				{
					
					if (u is Harvester)
					{
						stats.storageAmount = Harvester(u).getStorageAmount();
					}
					
					o.startVehicles.push(stats)
				}
				if (u is Building)
				{
					if (u is Turret)
					{
						o.startTurrets.push(stats)
					}
					else
					{
						o.startBuildings.push(stats)
					}
				}
			}
			
			return o;
		}
		
		public function init():void
		{
		
			createStartAssets();
			if (!powerCtrl)
			{
				powerCtrl = new PowerController();
			}
			
			sightManager.init();
		}
		
		
		
		public function createStartAssets():void
		{
			var i:int = 0;
			var selRow:int;
			var selCol:int;
			//var p:Unit;
			var teamStatsObj:TeamObject;
			var teamsData:Object;
			//var b:Building;
			var obj:Object;
			var ent:GameEntity;
			//var startBuilding:Object;
			var placementsArr:Array;
			var typesArr:Array = ["startVehicles", "startUnits", "startBuildings", "startTurrets" ];
			var classes:Array = [Vehicle, Infantry, Building, Turret];
			//team 1
			var len:int = typesArr.length;
			for (var g:int = 0; g < len; g++ )
			{
				var curType:String = typesArr[g];
				var CLS:Class = classes[g];
				var len2:int = startParams[curType].length;
				
				for(i = 0; i < len2; i++ )
				{
					obj = startParams[curType][i];
					
					selRow = obj.row;
					selCol = obj.col;
					
					var statsObj:AssetStatsObj = Methods.getCurretStatsObj(obj.name);
					
					if (obj.name == "harvester")
					{
						ent = new Harvester(VehicleStatsObj(statsObj), this, enemyTeams, teamNum);
						
						if (obj.storageAmount)
						{
							Harvester(ent).storageBar.addToStorage(obj.storageAmount);
						}
						
					}
					else if (obj.name == "refinery")
					{
						ent = new Refinery(BuildingsStatsObj(statsObj), this, enemyTeams, teamNum);
					}
					else if (obj.name == "repair-facility")
					{
						ent = new RepairFacility(BuildingsStatsObj(statsObj), this, enemyTeams, teamNum);
					}
					else
					{
						ent = new CLS(statsObj, this, enemyTeams, teamNum);
					}
					
					Board.mapContainerArr[Board.UNITS_LAYER].addChild(ent.view);
					
					if (curType == "startBuildings" || curType == "startTurrets")
					{
						ent.addEventListener("SOLD", onSold);
					}
					
					placementsArr = SpiralBuilder.getSpiral(selRow, selCol, 1);
					ent.placeUnit(placementsArr[0].row, placementsArr[0].col, fromSaveGame);
					team.push(ent);
					
					if (obj.health)
					{
						ent.setHealth(obj.health);
					}
					
					
					if (obj.ai)
					{
						ent.changeAI(obj.ai);
					}
					
					if (curType == "startBuildings")
					{
						
						var curBuildingObj:BuildingsStatsObj = BuildingsStats.dict[obj.name];
						
						if (curBuildingObj.resourceStorage)
						{
							cashManager.addStorage(curBuildingObj.resourceStorage);
						}
						
						
						addBuildingToDict(curBuildingObj.buildingType);
						addBuildingSightToBase(ent.getSight());
						
					}
					
					
					if (curType == "startBuildings" || curType == "startTurrets")
					{
						Building(ent).skipBuild();
					}
				}
				
			}
			
			buildManager = new TeamBuildManager();
			buildManager.init(startParams, this);
			buildManager.addEventListener("UNIT_CONSTRUCTED", onUnitContructed);
			buildManager.addEventListener("BUILDING_PLACED", onBuildingPlaced);
			handleHud();
			fromSaveGame = false;
		}
		
		private function handleHud():void 
		{
			if (agent == Agent.HUMAN)
			{
				var numBuildings:int = Methods.countKeysInDict(teamBuildingsDict);
				if (numBuildings)
				{
					buildManager.hud.enterHud();
				}
				else
				{
					buildManager.hud.exitHud();
				}
			}
		}
		
		private function addBuildingToDict(_buildingType:String):void 
		{
			if (teamBuildingsDict[_buildingType] == undefined)
			{
				teamBuildingsDict[_buildingType] = 1;
			}
			else
			{
				teamBuildingsDict[_buildingType]++;
			}
		}
		
		private function removeBuildingFromDict(_buildingType:String):int
		{
			var numBuildingsOfThisType:int = 0;
			if (teamBuildingsDict[_buildingType])
			{
				teamBuildingsDict[_buildingType]--;
				numBuildingsOfThisType = teamBuildingsDict[_buildingType];
				
				if (teamBuildingsDict[_buildingType] <= 0)
				{
					numBuildingsOfThisType = 0;
					delete teamBuildingsDict[_buildingType];
				}
			}
			return numBuildingsOfThisType;
		}
		
		private var callingForHelp:Boolean = false;
		private var timeoutRunning:Boolean = false;
		private var timeoutCounter:int = 0;
		private var timeoutTime:int = 10;
		
		//many classes have been made obsolete - their functions moved to this udate loop/ rather have one loop over the entire team than 10
		public function update(_pulse:Boolean):void
		{
			var totalPowerIn:int = 0;//how much it takes
			var totalPowerOut:int = 0;//how much it gives
			
			if (_pulse)
			{
				team.sortOn(["row"], Array.NUMERIC);
				numTurrets = 0;
				numOfHarvesters = 0;
			}
			
		
			var teamLength:int = team.length;
			var p:GameEntity;
				
			for (var i:int = 0; i < teamLength; i++ )
			{
				p = team[i];
				if(p)
				{
					p.update(_pulse);
				
					if (p.model)
					{
						if(p.model.dead == false)
						{
							if (_pulse)
							{
								sightManager.addSight(p);
								
								if (p is Building)
								{
									totalPowerIn  += BuildingsStatsObj(BuildingModel(p.model).stats).powerIn;
									totalPowerOut += BuildingsStatsObj(BuildingModel(p.model).stats).powerOut;
									
									if ((p is Turret) == false)
									{
										addBuildingSightToBase(p.getSight());
									}
									
									
								}
								
								if (p is Turret)
								{
									numTurrets++;
								}
								
								if (p is Refinery)
								{
									teamRefinery = Refinery(p);
								}
								
								if (p is Harvester)
								{
									teamHarvester = Harvester(p);
									numOfHarvesters++;
								}
								
								if (Methods.isOnScreen(p.model.row, p.model.col))
								{
									p.addMeToBoard(Board.mapContainerArr[Board.UNITS_LAYER]);
								}
								
								
								
							
							
							
								if (agent == Agent.PC || Parameters.AI_ONLY_GAME)
								{
									if (callingForHelp)
									{
										if (timeoutRunning == false)
										{
											timeoutCounter = 0;
											timeoutRunning = true;
										}
										else
										{
											timeoutCounter++;
											sendRescue(p);
											
											if (timeoutCounter >= timeoutTime)
											{
												timeoutCounter = 0;
												timeoutRunning = false;
												callingForHelp = false;
											}
										}
									}
									else
									{
										if (p.underAttack)
										{
											callingForHelp = true;
											
											p.underAttack = false;
										}
									}
								}
							}	
						}
						else
						{
							onDead(p);
						}
					}
				}
			}
			
			if (_pulse)
			{
				powerCtrl.updatePower(agent, totalPowerIn, totalPowerOut);
				buildManager.hud.updatePower(totalPowerIn, totalPowerOut);
			}
		}
		

		private function sendRescue(rescueingUnit:GameEntity):void 
		{
			if (rescueingUnit is Building)  
			{
				return;
			}
			if (rescueingUnit is Harvester)
			{
				return;
			}
			if (rescueingUnit.aiBehaviour == AiBehaviours.HELPLESS || rescueingUnit.aiBehaviour == AiBehaviours.SEEK_AND_DESTROY)
			{
				return;
			}
			
		
			rescueingUnit.aiBehaviour = AiBehaviours.SEEK_AND_DESTROY;
			
		}
		
		public function doesBuildingExist(_buildingName:String):Boolean
		{
			var avaliable:Boolean = false;
			if (teamBuildingsDict[_buildingName])
			{
				avaliable = true;
			}

			return avaliable;
		}
		
		public function getRefinery():Refinery 
		{
			return teamRefinery;
		}
		
		public function getHarvester():Harvester 
		{
			if (teamHarvester && teamHarvester.model && teamHarvester.model.dead == false)
			{
				return teamHarvester;
			}
			else
			{
				return null;
			}

		}
		
		private function onUnitContructed(e:Event):void
		{
			var assetName:String = e.data.name;
			var assetType:String = e.data.type;
			var p:GameEntity;
			var teamObject:TeamObject;
			var currenteamNum:int = 0;
			
			
			
			var curRowCol:Object;
			var placementsArr:Array;
			//is this infantry?
			if (InfantryStats.dict[assetName])
			{
				curRowCol = buildManager.getProducingBuilding(InfantryStats.dict[assetName], team);
				if (curRowCol)
				{
					placementsArr = SpiralBuilder.getSpiral(curRowCol.row, curRowCol.col, 1);
					p = new Infantry(InfantryStats.dict[assetName], this, enemyTeams, teamNum);
					Infantry(p).placeUnit(placementsArr[0].row, placementsArr[0].col);
				}
				
			}
			else
			{
				curRowCol = buildManager.getProducingBuilding(VehicleStats.dict[assetName], team);
				placementsArr = SpiralBuilder.getSpiral(curRowCol.row, curRowCol.col, 1);
				if (curRowCol)
				{
					if (assetName == "harvester")
					{
						p = new Harvester(VehicleStats.dict[assetName], this, enemyTeams, teamNum);
					}
					else
					{
						p = new Vehicle(VehicleStats.dict[assetName], this, enemyTeams, teamNum);
					}
					
					
					Vehicle(p).placeUnit(placementsArr[0].row, placementsArr[0].col);
				}
				
				
			}
			
			buildManager.assetBuildComplete(assetName);
			
			if (p)
			{
				Board.mapContainerArr[Board.UNITS_LAYER].addChild(p.view);
				
				team.push(p);
				p.sayHello();
				dispatchEvent( new Event("ASSET_CONSTRUCTED"))
			}
			
			
		}
		
		private function onBuildingPlaced(e:Event):void
		{
			var assetName:String = e.data.name;
			var assetType:String = e.data.type;
			var p:GameEntity;
			var teamObject:TeamObject;
			var currenteamNum:int = 0;
			var isBuilding:Boolean = false;
			
			
			if (BuildingsStats.dict[assetName])
			{
				var curBuildingObj:BuildingsStatsObj = BuildingsStats.dict[assetName];
				isBuilding = true;
						
				if (curBuildingObj.resourceStorage)
				{
					cashManager.addStorage(curBuildingObj.resourceStorage);
				}
				
				
				if (assetName == "refinery")
				{
					p = new Refinery(BuildingsStats.dict[assetName], this, enemyTeams, teamNum);
				}
				else if (assetName == "repair-facility")
				{
					p = new RepairFacility(BuildingsStats.dict[assetName], this, enemyTeams, teamNum);
				}
				else
				{
					p = new Building(BuildingsStats.dict[assetName], this, enemyTeams, teamNum);
				}
				
				addBuildingToDict(BuildingsStats.dict[assetName].buildingType);
				handleHud();
				
				
				
			}
			else
			{
				p = new Turret(TurretStats.dict[assetName], this, enemyTeams, teamNum);
			}
			
			p.addEventListener("SOLD", onSold);
			Board.mapContainerArr[Board.UNITS_LAYER].addChild(p.view);
			team.push(p);
			p.placeUnit(buildManager.targetRow, buildManager.targetCol);
			
			var newConstructionOptions:Boolean = buildManager.updateUnitsAndBuildings(assetName);
			if (newConstructionOptions && agent == Agent.HUMAN)
			{
				GameSounds.playSound("new_construction_options", "vo");
			}
			
			p.sayHello();
			//this is temporary until the pc can build its own

			buildManager.assetBuildComplete(assetName);
			
			dispatchEvent( new Event("ASSET_CONSTRUCTED"))
			
		}
		
		private function addBuildingSightToBase(sight:Array):void 
		{
			var len2:int = sight.length;
			var n:Node;
			var g:int = 0;
			for (g = 0; g < len2; g++ )
			{
				n = sight[g];
				var nodeName:String = n.name;
				buildingsSight[nodeName] = n;
			}
		}
		
		private function removeBuildingSightFromBase(sight:Array):void 
		{
			var len2:int = sight.length;
			var n:Node;
			var g:int = 0;
			for (g = 0; g < len2; g++ )
			{
				n = sight[g];
				var nodeName:String = n.name;
				delete buildingsSight[nodeName];
			}
		}
		
		public function handleAtachedUnit(assetName:String, _buildingRow:int, _buildingCol:int):GameEntity 
		{
			var p:GameEntity;
			var curRowCol:Object;
			var placementsArr:Array;
			
			if (BuildingsStats.dict[assetName] && BuildingsStats.dict[assetName].attachedUnit)
			{
				var attachedUnit:String = BuildingsStats.dict[assetName].attachedUnit;
				
				if (InfantryStats.dict[attachedUnit])
				{
					p = new Infantry(InfantryStats.dict[attachedUnit], this, enemyTeams, teamNum);
					curRowCol = buildManager.getProducingBuilding(InfantryStats.dict[attachedUnit], team);
					placementsArr = SpiralBuilder.getSpiral(buildManager.targetRow, buildManager.targetCol, 1);
					p.placeUnit(placementsArr[0].row, placementsArr[0].col);
				}
				else
				{
					if (attachedUnit == "harvester")
					{
						p = new Harvester(VehicleStats.dict[attachedUnit], this, enemyTeams, teamNum);
					}
					else
					{
						p = new Vehicle(VehicleStats.dict[attachedUnit], this, enemyTeams, teamNum);
					}
					
					placementsArr = SpiralBuilder.getSpiral(_buildingRow, _buildingCol, 1);
					p.placeUnit(placementsArr[0].row, placementsArr[0].col);
				}
				
				Board.mapContainerArr[Board.UNITS_LAYER].addChild(p.view);
				
				team.push(p);
				p.sayHello();
			}
			
			return p;
		}
		
		public function setEnemyTeamObj(_enemyTeamObj:TeamObject):void 
		{
			enemyTeamObjs.push(_enemyTeamObj);
			enemyTeams.push(_enemyTeamObj.team);
		}
		
		public function spawnEnemyUnit(row:int, col:int, searchAndDestroy:Boolean = true):void 
		{
			enemyTeamObjs[0].spawnSoldier(row, col, searchAndDestroy);
		}
		
		private function onSold(e:Event):void
		{
			var p:Building = Building(e.target);
			p.removeEventListener("SOLD", onSold);
			var cost:int = BuildingsStatsObj(BuildingModel(p.model).stats).cost;
			cashManager.setCashToAdd(cost / 2);
			
			onDead(p);
		}
		

		

		private function onDead(p:GameEntity):void
		{
			var residentSoldiersArr:Array = [];
			var row:int;
			var col:int;
			var currentTeamObj:TeamObject = GameEntity(p).myTeamObj;
			var numResidents:int = 0;
			var i:int = 0;
			p.removeEventListener("SOLD", onSold);
			
			if (p is Building && (p is Turret) == false)
			{
				row = p.model.row;
				col = p.model.col;
				removeBuildingSightFromBase(p.getSight());
				
				var curBuildingObj:BuildingsStatsObj = BuildingsStatsObj(BuildingModel(p.model).stats);
				
				if (curBuildingObj.residents)
				{
					numResidents = curBuildingObj.residents;
					
					for (i = 0; i < numResidents; i++)
					{
						spawnSoldier(row, col);
						
					}
				}
				
				var numBuildingsOfThisType:int = removeBuildingFromDict(curBuildingObj.buildingType);
				if (numBuildingsOfThisType == 0)
				{
					buildManager.removeDependantUnitsAndBuildings(Building(p).name);
				}
				
				
				handleHud();
				
				
						
				if (curBuildingObj.resourceStorage)
				{
					cashManager.reduceStorage(curBuildingObj.resourceStorage);
				}
				
				
				
			}
			
			var removed:Boolean = false;
			if (team != null)
			{
				if (team.indexOf(p) != -1)
				{
					removed = true;
					team.splice(team.indexOf(p), 1);
				}
			}
			p.dispose();
			p = null;
			
			dispatchEventWith("ASSET_DESTROYED", false, {numResidents: numResidents});
		}
		
		
		
		
		
		public function spawnSoldier(row:int, col:int, searchAndDestroy:Boolean = true):void 
		{
			var soldier:Infantry = new Infantry(InfantryStats.dict["minigunner"], this, enemyTeams, teamNum);
			var placementsArr:Array = SpiralBuilder.getSpiral(row, col, 1);
			soldier.placeUnit(placementsArr[0].row, placementsArr[0].col);
			Board.mapContainerArr[Board.UNITS_LAYER].addChild(soldier.view);
			team.push(soldier);
			if(searchAndDestroy)soldier.changeAI(AiBehaviours.SEEK_AND_DESTROY);
		}
		
		public function reduceCash(_reduceAmount:int):Boolean
		{	
			var moreThanZero:Boolean = cashManager.reduceCash(_reduceAmount);
			
			
			////trace(cash);
			if (agent == Agent.HUMAN)
			{
				buildManager.hud.updateCashUI(cashManager.cash);
			}
			
			
			return moreThanZero;
			
		}
		
		public function addCash(_amount:int):void
		{
			cashManager.addCash(_amount);
			
			
			if (agent == Agent.HUMAN)
			{
				buildManager.hud.updateCashUI(cashManager.cash);
			}
		}
		
		
		public function getNumOfHarvesters():int 
		{
			return numOfHarvesters;
		}
		
		public function dispose():void 
		{
			GameTimer.getInstance().removeUser(this);
			if (buildManager)
			{
				buildManager.dispose();
				buildManager.removeEventListener("UNIT_CONSTRUCTED", onUnitContructed);
				buildManager.removeEventListener("BUILDING_PLACED", onBuildingPlaced);
			}
			
			buildManager = null;
			
			if (team)
			{
				var teamLen:int = team.length;
				for (var i:int = 0; i < teamLen; i++ )
				{
					team[i].removeEventListener("SOLD", onSold);
					team[i].dispose();
					team[i] = null;
				}
			}
			
			
			
			team = null;
			enemyTeams = null;
			powerCtrl = null;
			teamBuildingsDict = null;
			if (sellRepairManager)
			{
				sellRepairManager.dispose();
			}
			
			sellRepairManager = null;
			if (cashManager)
			{
				cashManager.dispose();
			}
			
			cashManager = null;
			enemyTeamObjs = null;
			
			if (aiController)
			{
				aiController.dispose();
			}
			aiController = null;
		}
		
		public function getNumTurrets():int 
		{
			return numTurrets;
		}
		
		public function getBaseNodes():Object 
		{
			return buildingsSight;
		}
		
		public function applyAI():void 
		{
			aiController = new AIController();
			aiController.applyAI(this, startParams);
		}
	}
}