package states.game 
{
	
	import com.greensock.TweenLite;
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
	import starling.text.TextField;
	import states.game.entities.buildings.BuildingModel;
	import states.game.entities.buildings.Turret;
	import states.game.entities.GameEntity;
	import states.game.entities.units.UnitModel;
	import states.game.entities.units.*;
	
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
	import states.game.teamsData.TeamsLoader;
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
		
		

		public function Game() 
		{
			teamslisting = new TeamsListingWindow();
			LevelManager.init();
			TeamsLoader.init();//loads in xml with num of units in each team- to be changed later
		}
		
		public function init():void 
		{
			LevelManager.currentlevelData = LevelManager.getLevelData(0);
			LevelManager.loadRelevantAssets(LevelManager.currentlevelData, onLoadAssetsComplete);

		}
		
		private function onLoadAssetsComplete():void
		{
			PoolsManager.init();
			Parameters.numRows = LevelManager.currentlevelData.numTiles;
			Parameters.numCols = LevelManager.currentlevelData.numTiles;
			
			
			baordMC = Board.getInstance();
			baordMC.init(false);
			
			//Parameters.gameHolder.addChild(Parameters.mapHolder);
			addTeams();
			
			UnitSelectionManager.getInstance().init();
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
			
			///the teams!//
			var teamObjects:Array = [];
			
			var numTeams:int = TeamsLoader.numTeams();
			
			
			
			
			var team1Obj:TeamObject = new TeamObject(LevelManager.currentlevelData.team1, 1);
			var team2Obj:TeamObject = new TeamObject(LevelManager.currentlevelData.team2, 2);
			
			team1Obj.addEventListener("ASSET_DESTROYED", onAssetDestroyed);
			team2Obj.addEventListener("ASSET_DESTROYED", onAssetDestroyed);
			team1Obj.addEventListener("ASSET_CONSTRUCTED", onAssetDestroyed);
			team2Obj.addEventListener("ASSET_CONSTRUCTED", onAssetDestroyed);
			
			teamObjects.push( team1Obj );
			teamObjects.push( team2Obj );
			
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
			
			
			
			team1Obj.setEnemyTeamObj(team2Obj);
			team2Obj.setEnemyTeamObj(team1Obj);
			
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
			
			if(Parameters.pcTeam.length == 0 || Parameters.humanTeam.length == 0)
			{
				endGame();
			}
			
			if (Parameters.pcTeam.length == 0)
			{
				showMissionAccomplished();
			}
			if (Parameters.humanTeam.length == 0)
			{
				showMissionFailed();
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
				for (var i:int = 0; i < Parameters.humanTeam.length; i++ )
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
			
				var i:int = 0;
				for (i = 0; i <  Parameters.humanTeam.length; i++ )
				{
					if(Parameters.humanTeam[i] is Unit  || Parameters.humanTeam[i] is Turret )
					{
						Parameters.humanTeam[i].update(_pulse);
					}
				}
				
				for (i = 0; i <   Parameters.pcTeam.length; i++ )
				{
					if(Parameters.pcTeam[i] is Unit || Parameters.pcTeam[i] is Turret )
					{
						Parameters.pcTeam[i].update(_pulse);
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
			
			//trace"END GAME!!!")
			//GameAtlas.createMovieClip("loadingSquare");
		}
	}
}