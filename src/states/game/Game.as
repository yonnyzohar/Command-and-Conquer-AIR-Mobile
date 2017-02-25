package states.game 
{
	
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import flash.events.DataEvent;
	import global.ai.AIController;
	import global.BGSoundManager;
	import global.GameAtlas;
	import global.GameSounds;
	import global.map.mapTypes.Board;
	import global.map.SpiralBuilder;
	import global.Methods;
	import global.pools.Pool;
	import global.pools.PoolElement;
	import global.pools.PoolsManager;
	import global.ui.hud.HUD;
	import global.ui.hud.TeamBuildManager;
	import global.utilities.GlobalEventDispatcher;
	import global.utilities.MapMover;
	import global.utilities.SightManager;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.TextField;
	import states.game.entities.buildings.BuildingModel;
	import states.game.entities.buildings.Turret;
	import states.game.entities.GameEntity;
	import states.game.entities.units.UnitModel;
	import states.game.entities.units.*;
	import states.game.ui.SellRepairManager;
	
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import global.Parameters;
	import global.enums.Agent;
	import global.map.Node;
	import global.map.ZindexManager;
	import global.utilities.GameTimer;
	
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.filters.ColorMatrixFilter;
	
	import states.game.entities.buildings.Building;
	import states.game.entities.units.ShootingUnit;
	import states.game.entities.units.Unit;
	import states.game.stats.LevelManager;
	import states.game.stats.*;
	import states.game.entities.units.*;
	import states.game.teamsData.TeamObject;
	import states.game.ui.TeamsListingWindow;
	import states.game.ui.UnitSelectionManager;

	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class Game extends EventDispatcher
	{
		private var baordMC:Board;
		private var teamslisting:TeamsListingWindow;
		private var aiController:AIController;
		private var finalMessage:MovieClip;
		private var team1Obj:TeamObject;
		private var team2Obj:TeamObject;
		

		public function Game() 
		{
			teamslisting = new TeamsListingWindow();
			LevelManager.init();
			setSpeed(1);
		}
		
		private function setSpeed(number:Number):void 
		{
			//unit move
			Parameters.CASH_INCREMENT *= number;
			Harvester.HARVEST_AMOUNT *= number;
			Parameters.UNIT_MOVE_FACTOR  /= number;
			
			trace("CASH_INCREMENT " + Parameters.CASH_INCREMENT);
			trace("HARVEST_AMOUNT " + Harvester.HARVEST_AMOUNT);
			trace("UNIT_MOVE_FACTOR " + Parameters.UNIT_MOVE_FACTOR);
		}
		
		public function init(_levelNum:int):void 
		{
			LevelManager.currentlevelData = LevelManager.getLevelData(_levelNum);
			LevelManager.loadRelevantAssets(LevelManager.currentlevelData, onLoadAssetsComplete);
			
			
		}
		
		private function onLoadAssetsComplete():void
		{
			PoolsManager.init();
			Parameters.numRows = LevelManager.currentlevelData.numTiles;
			Parameters.numCols = LevelManager.currentlevelData.numTiles;
			
			
			baordMC = Board.getInstance();
			baordMC.init(false);
			Parameters.mapHolder.addChild(Board.mapContainerArr[Board.GROUND_LAYER]);
			Parameters.mapHolder.addChild(Board.mapContainerArr[Board.OBSTACLE_LAYER]);
			Parameters.mapHolder.addChild(Board.mapContainerArr[Board.UNITS_LAYER]);
			Parameters.mapHolder.addChild(Board.mapContainerArr[Board.EFFECTS_LAYER]);
			
			addTeams();
			
			UnitSelectionManager.getInstance().init();
			SellRepairManager.getInstance().init();
			GameTimer.getInstance().addUser(this);
			Parameters.theStage.addChild(teamslisting.view);
			teamslisting.view.x = Parameters.theStage.stageWidth - teamslisting.view.width;
			
			fixOnBase();
			SightManager.getInstance().init();
			BGSoundManager.playBGSound();
			
			
			//SightManager.getInstance().showAllSightSquares();
		}
		
		
		private function addTeams():void 
		{
			//TEAMS MOVED OUT TO XML
			var i:int = 0;
			var selRow:int;
			var selCol:int;
			var p:Unit;
			var teamStatsObj:TeamObject;
			var teamsData:Object;
			var b:Building;
			
			team1Obj = new TeamObject(LevelManager.currentlevelData.team1, 1);
			team2Obj = new TeamObject(LevelManager.currentlevelData.team2, 2);
			
			team1Obj.addEventListener("ASSET_DESTROYED", onAssetDestroyed);
			team2Obj.addEventListener("ASSET_DESTROYED", onAssetDestroyed);
			team1Obj.addEventListener("ASSET_CONSTRUCTED", onAssetDestroyed);
			team2Obj.addEventListener("ASSET_CONSTRUCTED", onAssetDestroyed);
			
			
			team1Obj.setEnemyTeamObj(team2Obj);
			team2Obj.setEnemyTeamObj(team1Obj);
			
			
			aiController = new AIController();
			
			
			if(team1Obj.agent == Agent.HUMAN)
			{
				Parameters.humaTeamObject = team1Obj;
				team1Obj.init(Parameters.humanTeam, Parameters.pcTeam);
				team2Obj.init(Parameters.pcTeam, Parameters.humanTeam);
				aiController.applyAI(team2Obj);
			}
			else if(team2Obj.agent == Agent.HUMAN)
			{
				Parameters.humaTeamObject = team2Obj;
				team1Obj.init(Parameters.pcTeam, Parameters.humanTeam);
				team2Obj.init(Parameters.humanTeam, Parameters.pcTeam);
				aiController.applyAI(team1Obj);
			}
			
			
			
			
			
			teamslisting.updateTeams(Parameters.humanTeam.length, Parameters.pcTeam.length);
		}
		
		private function onAssetDestroyed(e:Event):void 
		{
			if (e.data && e.data.numResidents)
			{
				var numResidents:int = e.data.numResidents;
				Methods.shakeMap(numResidents);
				
			}
			
			teamslisting.updateTeams(Parameters.humanTeam.length, Parameters.pcTeam.length);
			
			
			
			if (Parameters.pcTeam.length == 0)
			{
				showMissionAccomplished();
			}
			if (Parameters.humanTeam.length == 0)
			{
				showMissionFailed();
				
			}
			
			if(Parameters.pcTeam.length == 0 || Parameters.humanTeam.length == 0)
			{
				endGame();
				setTimeout(function():void
				{
					dispatchEvent(new Event("LEAVE_MISSION"));
				},2000);
				
			}
			
		}
		
		private function freezeGame():void
		{
			GameTimer.getInstance().freezeTimer();
			MapMover.getInstance().freeze();
			UnitSelectionManager.getInstance().freeze();
			Parameters.humaTeamObject.buildManager.hud.unitsContainer.freeze();
			Parameters.humaTeamObject.buildManager.hud.buildingsContainer.freeze();
		}
		
		
		private function showMissionFailed():void 
		{
			freezeGame();
			finalMessage = GameAtlas.createMovieClip("missionFailed");
			Parameters.theStage.addChild(finalMessage);
			finalMessage.scaleX = finalMessage.scaleY = Parameters.gameScale;
			finalMessage.x = (Parameters.theStage.stageWidth - finalMessage.width) / 2;
			finalMessage.y = (Parameters.theStage.stageHeight - finalMessage.height) / 2;
			GameSounds.playSound("mission_failure", "vo");
			BGSoundManager.stopBGSound();
			
		}
		
		private function showMissionAccomplished():void 
		{
			freezeGame();
			finalMessage = GameAtlas.createMovieClip("missionAccomplished");
			Parameters.theStage.addChild(finalMessage);
			finalMessage.scaleX = finalMessage.scaleY = Parameters.gameScale;
			finalMessage.x = (Parameters.theStage.stageWidth - finalMessage.width) / 2;
			finalMessage.y = (Parameters.theStage.stageHeight - finalMessage.height) / 2;
			GameSounds.playSound("mission_accomplished", "vo");
			BGSoundManager.stopBGSound();
		}
		
		
		
		private function fixOnBase():void 
		{
			var base:Building;
			
			if (Parameters.humanTeam)
			{
				var len:int = Parameters.humanTeam.length;
				for (var i:int = 0; i < len; i++ )
				{
					if (Parameters.humanTeam[i] is Building)
					{
						if (Parameters.humanTeam[i].name == "construction-yard")
						{
							base = Parameters.humanTeam[i];
							break;
						}
					}
				}
			}
			
			if (base)
			{
				MapMover.getInstance().focusOnItem(base.view.x, base.view.y);
				
			}
		}
		
				

		public function update(_pulse:Boolean):void
		{
			var p:GameEntity;
			var i:int = 0;
			var len:int = Parameters.humanTeam.length;
			for (i = 0; i <  len; i++ )
			{
				p = Parameters.humanTeam[i];
				if (p)
				{
					p.update(_pulse);
				}
				

			}
			
			len = Parameters.pcTeam.length;
			for (i = 0; i <   len; i++ )
			{
				p = Parameters.pcTeam[i];
				if (p)
				{
					p.update(_pulse);
				}
				
			}
				
			if (_pulse)
			{
				
				ZindexManager.setIndices(Parameters.humanTeam);
				ZindexManager.setIndices(Parameters.pcTeam);
				//ZindexManager.setIndices(baordMC.treesAndRocks);
			}
			
		}

		
		private function endGame():void
		{
			//stage.removeEventListener(Event.ENTER_FRAME, loop);
			var i:int = 0;
			
			for (i = 0; i <  Parameters.humanTeam.length; i++ )
			{
				Parameters.humanTeam[i].end();
			}
			
			for (i = 0; i <   Parameters.pcTeam.length; i++ )
			{
				Parameters.pcTeam[i].end();
			}
		}
		
		
		public function dispose():void 
		{
			if (finalMessage)
			{
				finalMessage.removeFromParent();
			}
			GameTimer.getInstance().removeUser(this);
			
			baordMC.dispose();
			
			
			Parameters.humaTeamObject = null;
			teamslisting.dispose();
			teamslisting = null;
			aiController.dispose();
			team1Obj.removeEventListener("ASSET_DESTROYED", onAssetDestroyed);
			team2Obj.removeEventListener("ASSET_DESTROYED", onAssetDestroyed);
			team1Obj.removeEventListener("ASSET_CONSTRUCTED", onAssetDestroyed);
			team2Obj.removeEventListener("ASSET_CONSTRUCTED", onAssetDestroyed);
			team1Obj.dispose();
			team2Obj.dispose();
			
			team2Obj = null;
			team1Obj = null;
			aiController = null;
			
			Parameters.humanTeam = [];
			Parameters.pcTeam = [];
			UnitSelectionManager.getInstance().dispose();
			SellRepairManager.getInstance().dispose();
			SightManager.getInstance().dispose();
			BGSoundManager.stopAllSounds();
			Parameters.currentSquad = null;
			TweenMax.killAll();
			removeAllChildren([Parameters.gameHolder, Parameters.mapHolder , Board.mapContainerArr[Board.GROUND_LAYER], Board.mapContainerArr[Board.OBSTACLE_LAYER], Board.mapContainerArr[Board.UNITS_LAYER],Board.mapContainerArr[Board.EFFECTS_LAYER] ]);
			GameTimer.getInstance().dispose();
			
			Board.mapContainerArr[Board.GROUND_LAYER].removeFromParent();
			Board.mapContainerArr[Board.UNITS_LAYER].removeFromParent();
			Board.mapContainerArr[Board.EFFECTS_LAYER].removeFromParent();
			Board.mapContainerArr[Board.OBSTACLE_LAYER].removeFromParent();
			
			Board.mapContainerArr[Board.GROUND_LAYER] = null;
			Board.mapContainerArr[Board.OBSTACLE_LAYER] = null;
			Board.mapContainerArr[Board.UNITS_LAYER] = null;
		    Board.mapContainerArr[Board.EFFECTS_LAYER] = null;
		   Board.mapContainerArr = null;
		  }
		
		private function removeAllChildren(a:Array):void 
		{
			for (var i:int = 0; i < a.length; i++ )
			{
				var sp:Sprite = a[i];
				var numChildreLeft:int = sp.numChildren; 
				if (numChildreLeft)
				{
					for (var j:int = numChildreLeft-1; j >= 0; j-- )
					{
						var child = sp.getChildAt(j);
						child.removeFromParent();
						child = null;
					}
				}
				
			}
		}
	}
}