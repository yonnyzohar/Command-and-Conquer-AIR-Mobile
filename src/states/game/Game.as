package states.game 
{
	
	import com.greensock.TweenMax;
	import com.randomMap.RandomMapGenerator;
	import flash.events.DataEvent;
	import global.ai.AIController;
	import global.enums.AiBehaviours;
	import global.GameAtlas;
	import global.GameSounds;
	import global.map.mapTypes.Board;
	import global.map.SpiralBuilder;
	import global.Methods;
	import global.pools.Pool;
	import global.pools.PoolElement;
	import global.pools.PoolsManager;
	import global.ui.hud.HUD;
	import states.game.teamsData.TeamBuildManager;
	import global.utilities.GlobalEventDispatcher;
	import global.utilities.MapMover;
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
	import flash.net.SharedObject;
	
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
		
		private var finalMessage:MovieClip;
		
		public var playerSide:int;
		public var levelNum:int;
		private var savedObject:Object;
		
		
		
		

		public function Game() 
		{
			var sharedObj:SharedObject = SharedObject.getLocal("sharedObj");
			if (sharedObj.data.speed == undefined)
			{
				sharedObj.data.speed = Parameters.gameSpeed;
				sharedObj.flush();
			}
			else{
				Parameters.gameSpeed = sharedObj.data.speed;
			}
			

			LevelManager.init();
		}
		
		
		
		public function init(_levelNum:int, _playerSide:int, _savedObject:Object = null):void 
		{
			levelNum   = _levelNum;
			playerSide = _playerSide;
			savedObject = _savedObject;
			LevelManager.currentlevelData = LevelManager.getLevelData(_levelNum);
			var dataObj:Object = LevelManager.currentlevelData;
			if (savedObject)
			{
				dataObj = savedObject;
			}
			
			Parameters.loadingScreen.init();
			LevelManager.loadRelevantAssets(dataObj, onLoadAssetsComplete);
			
			
		}
		
		private function onLoadAssetsComplete():void
		{
			PoolsManager.init();
			Parameters.numRows = LevelManager.currentlevelData.numTiles;
			Parameters.numCols = LevelManager.currentlevelData.numTiles;
			
			//var randomMapGenerator:RandomMapGenerator = new RandomMapGenerator();
			//LevelManager.currentlevelData.map =  randomMapGenerator.createRandomMap(Parameters.numRows, Parameters.numCols);
			
			
			baordMC = Board.getInstance();
			baordMC.init(false,LevelManager.currentlevelData.map);
			
			Board.mapContainerArr[Board.GROUND_LAYER].touchable = false;
			Board.mapContainerArr[Board.OBSTACLE_LAYER].touchable = false;
			Board.mapContainerArr[Board.UNITS_LAYER].touchable = false;
			Board.mapContainerArr[Board.EFFECTS_LAYER].touchable = false;
			
			Parameters.mapHolder.addChild(Board.mapContainerArr[Board.GROUND_LAYER]);
			Parameters.mapHolder.addChild(Board.mapContainerArr[Board.OBSTACLE_LAYER]);
			Parameters.mapHolder.addChild(Board.mapContainerArr[Board.UNITS_LAYER]);
			Parameters.mapHolder.addChild(Board.mapContainerArr[Board.EFFECTS_LAYER]);
			
			addTeams();
			
			UnitSelectionManager.getInstance().init();
			
			
			
			if (savedObject)
			{
				MapMover.getInstance().forceMoveMap(savedObject.currX, savedObject.currY);
			}
			else
			{
				fixOnBase();
			}
			
			GameSounds.playBGSound();
			dispatchEvent(new Event("GAME_LOAD_COMPLETE"))
			Parameters.loadingScreen.remove();
			
			var n:Node;
			var len:int = Parameters.boardArr.length;
			
			for (var row:int = 0; row < len; row++ )
			{
				var len2:int = Parameters.boardArr[0].length;
				for (var col:int = 0; col < len2; col++ )
				{
					n = Parameters.boardArr[row][col];
					n.seen = false;
				}
			}
			
		}
		
		
		private function addTeams():void 
		{
			//TEAMS MOVED OUT TO XML
			var i:int = 0;
			var selRow:int;
			var selCol:int;
			var p:Unit;
			var teamObject:TeamObject;
			var teamsData:Object;
			var b:Building;
			var jsonTeams:Array = LevelManager.currentlevelData.teams;
			var teamStartObj:Object;
			var j:int;
			
			if (savedObject)
			{
				jsonTeams = savedObject.teams;
			}
			
			for (i = 0; i < jsonTeams.length; i++ )
			{
				teamStartObj = jsonTeams[i];
				teamObject = new TeamObject(teamStartObj, i, (savedObject != null));
				teamObject.ai = AiBehaviours.SELF_DEFENSE;
				teamObject.addEventListener("ASSET_DESTROYED", onAssetDestroyed);
				teamObject.addEventListener("ASSET_CONSTRUCTED", onAssetDestroyed);
				teamObject.agent =  Agent.PC;
				
				Parameters.gameTeamObjects.push(teamObject);
			}
			
			//this is to determine human side on new game click
			if (playerSide != 0)
			{
				for (i = 0; i < Parameters.gameTeamObjects.length; i++ )
				{
					teamObject = Parameters.gameTeamObjects[i]
					if (playerSide == 1)
					{
						if (teamObject.weaponsProvider == "gdi")
						{
							teamObject.setHuman();
							break;
						}
					}
					if (playerSide == 2)
					{
						if (teamObject.weaponsProvider == "nod")
						{
							teamObject.setHuman();
							break;
						}
					}
				}
			}
			
			var enemyTeamObj:TeamObject;
			
			//determine enemies. in AI game everyone is figting everyone
			if (Parameters.AI_ONLY_GAME)
			{
				for (i = 0; i < Parameters.gameTeamObjects.length; i++ )
				{
					teamObject = Parameters.gameTeamObjects[i]
					for (j = 0; j < Parameters.gameTeamObjects.length; j++ )
					{
						if (i != j)
						{
							enemyTeamObj = Parameters.gameTeamObjects[j];
							teamObject.setEnemyTeamObj(enemyTeamObj);
						}
					}
				}
			}
			else
			{
				for (i = 0; i < Parameters.gameTeamObjects.length; i++ )
				{
					teamObject = Parameters.gameTeamObjects[i]
					for (j = 0; j < Parameters.gameTeamObjects.length; j++ )
					{
						
						enemyTeamObj = Parameters.gameTeamObjects[j];
						if(enemyTeamObj.agent != teamObject.agent)
						{
							teamObject.setEnemyTeamObj(enemyTeamObj);
						}
					}
				}
			}

			
			
			for (i = 0; i < Parameters.gameTeamObjects.length; i++ )
			{
				teamObject = Parameters.gameTeamObjects[i]
				teamObject.init();
				
				if (teamObject.agent ==  Agent.PC)
				{
					teamObject.applyAI();
				}
				else
				{
					Parameters.humanTeam = teamObject.team;
					
					if (Parameters.AI_ONLY_GAME)
					{
						teamObject.applyAI();
					}
				}
			}
			updateTeams();

			
			
			if (savedObject)
			{
				Board.getInstance().showVisibleTiles(savedObject.visibleTiles);
			}
		}
		
		private function updateTeams():void 
		{
			/*if (teamslisting == null)
			{
				teamslisting = new TeamsListingWindow();
				Parameters.theStage.addChild(teamslisting.view);
				teamslisting.view.x = Parameters.theStage.stageWidth - teamslisting.view.width;
			}
			teamslisting.updateTeams(Parameters.gameTeamObjects[0].team.length, Parameters.gameTeamObjects[1].team.length);*/
		}
		
		private function onAssetDestroyed(e:Event):void 
		{
			if (e.data && e.data.numResidents)
			{
				var numResidents:int = e.data.numResidents;
				Methods.shakeMap(numResidents);
				
			}
			
			updateTeams();
			
			var humanDead:Boolean = false;
			var allPCSDead:Boolean = true;
			var teamObject:TeamObject;
			
			for (var i:int = Parameters.gameTeamObjects.length-1; i >= 0 ; i-- )
			{
				teamObject = Parameters.gameTeamObjects[i];
				if (teamObject.agent == Agent.PC && teamObject.team.length != 0)
				{
					allPCSDead = false;
					break;
				}
				
				
			}
			
			
			
			if (allPCSDead == true)
			{
				showMissionAccomplished();
			}
			if (Parameters.humanTeam.length == 0)
			{
				showMissionFailed();
			}
			
			if(allPCSDead == true || Parameters.humanTeam.length == 0)
			{
				endGame();
			}
			
		}
		
		public function freezeGame():void
		{
			GameTimer.getInstance().freezeTimer();
			MapMover.getInstance().freeze();
			UnitSelectionManager.getInstance().freeze();
		}
		
		
		public function resumeGame():void {
			GameTimer.getInstance().resumeTimer();
			MapMover.getInstance().resume();
			UnitSelectionManager.getInstance().resume();

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
			GameSounds.stopBGSound();
			
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
			GameSounds.stopBGSound();
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
		
				



		
		public function endGame():void
		{
			//stage.removeEventListener(Event.ENTER_FRAME, loop);
			var i:int = 0;
			
			
			var teamObject:TeamObject;
			var team:Array;
			
			for (i = 0; i < Parameters.gameTeamObjects.length; i++ )
			{
				teamObject = Parameters.gameTeamObjects[i];
				team = teamObject.team;
				for (var j:int = 0; j < team.length; j++ )
				{
					team[j].end();
				}
				
				
				
			}
			
			setTimeout(function():void
			{
				dispatchEvent(new Event("LEAVE_MISSION"));
				
			},2000);
		}
		
		public function abortGame():void
		{
			GameSounds.playSound("battle_control_terminated", "vo");
			endGame()
		}
		
		
		public function dispose():void 
		{
			if (finalMessage)
			{
				finalMessage.removeFromParent();
			}
			GameSounds.stopBGSound();
			
			baordMC.dispose();
			
			var teamObject:TeamObject;
			for (var i:int = 0; i < Parameters.gameTeamObjects.length; i++ )
			{
				teamObject = Parameters.gameTeamObjects[i];
				teamObject.removeEventListener("ASSET_DESTROYED", onAssetDestroyed);
				teamObject.removeEventListener("ASSET_CONSTRUCTED", onAssetDestroyed);
				teamObject.dispose();
				teamObject = null;
			}
			
			if (teamslisting)
			{
				teamslisting.dispose();
			}
			
			teamslisting = null;
	
			
			Parameters.humanTeam = [];
			UnitSelectionManager.getInstance().dispose();
			
			GameSounds.stopBGSound();
			Parameters.currentSquad = null;
			TweenMax.killAll();
			removeAllChildren([Parameters.gameHolder, Parameters.mapHolder , Board.mapContainerArr[Board.GROUND_LAYER], Board.mapContainerArr[Board.OBSTACLE_LAYER], Board.mapContainerArr[Board.UNITS_LAYER],Board.mapContainerArr[Board.EFFECTS_LAYER] ]);
			GameTimer.getInstance().dispose();
			
			
			Board.mapContainerArr[Board.GROUND_LAYER] = null;
			Board.mapContainerArr[Board.OBSTACLE_LAYER] = null;
			Board.mapContainerArr[Board.UNITS_LAYER] = null;
		    Board.mapContainerArr[Board.EFFECTS_LAYER] = null;
			
			Parameters.gameTeamObjects = [];
		  }
		
		private function removeAllChildren(a:Array):void 
		{
			for (var i:int = 0; i < a.length; i++ )
			{
				var sp:Sprite = a[i];
				if (sp)
				{
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
}