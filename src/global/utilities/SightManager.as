package global.utilities
{
	import global.enums.Agent;
	import global.map.Node;
	import global.Parameters;
	import starling.display.Quad;
	import starling.events.EventDispatcher;
	import states.game.entities.buildings.Building;
	import states.game.entities.GameEntity;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class SightManager extends EventDispatcher
	{
		static private var instance:SightManager = new SightManager();
		
		private static var human_buildingsSight:Array = [];
		private static var pc_buildingsSight:Array = [];
		
		public function SightManager()
		{
			if (instance)
			{
				throw new Error("Singleton and can only be accessed through Singleton.getInstance()");
			}
		}
		
		public static function getInstance():SightManager
		{
			return instance;
		}
		
		public function showAllSightSquares():void 
		{
			var q:Quad;
			var a:Array = [Parameters.humanTeam, Parameters.pcTeam];
			var len:int = a.length;
			for (var i:int = 0; i < len; i++ )
			{
				var team:Array = a[i];
				var len2:int = team.length;
				for (var j:int = 0; j < len2; j++ )
				{
					var p:GameEntity = team[j];
					var sightArray:Array = p.getSight();
					var len3:int = sightArray.length;
					for (var g:int = 0; g < len3; g++ )
					{
						var n:Node = sightArray[g];
						q = new Quad(Parameters.tileSize, Parameters.tileSize);
						q.x = Parameters.tileSize * n.col;
						q.y = Parameters.tileSize * n.row;
						q.touchable = false;
						q.alpha = 0.1;
						Parameters.upperTilesLayer.addChild(q);
					}
					
				}
			}
		}
		
		public function init():void 
		{
			var p:GameEntity;
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
			
			var len3:int = Parameters.pcTeam.length;
			for (var i:int = 0; i < len3; i++ )
			{
				p = Parameters.pcTeam[i];
				p.view.visible = false;
			}
			
			var len4:int = Parameters.humanTeam.length;
			for (i = 0; i < len4; i++ )
			{
				p = Parameters.humanTeam[i];
				var sightArray:Array = p.getSight();
				var len5:int = sightArray.length;
				for (var g:int = 0; g < len5; g++ )
				{
					n = sightArray[g];
					n.seen = true;
				}
			}
			
			GameTimer.getInstance().addUser(this);
		}
		
		public function update(_pulse:Boolean):void
		{
			if (_pulse)
			{
				human_buildingsSight.splice(0);
				var i:int = 0;
				var g:int = 0;
				var sightArray:Array;
				var p:GameEntity;
				var len:int = Parameters.humanTeam.length;
				
				for (i = 0; i < len; i++ )
				{
					p = Parameters.humanTeam[i];
					sightArray = p.getSight();
					var len2:int = sightArray.length;
					for (g = 0; g < len2; g++ )
					{
						var n:Node = sightArray[g];
						n.seen = true;
						if (p is Building)
						{
							human_buildingsSight.push(n);
						}
					}
				}
				
				pc_buildingsSight.splice(0);
				var len3:int = Parameters.pcTeam.length;
				for (i = 0; i < len3; i++ )
				{
					p = Parameters.pcTeam[i];
					sightArray = p.getSight();
					var len4:int = sightArray.length;
					for (g = 0; g < len4; g++ )
					{
						n = sightArray[g];
						if (Parameters.DEBUG_MODE)
						{
							n.seen = true;// -- setting this to true will make pc units appear in the minimap!
						}
						if (p is Building)
						{
							pc_buildingsSight.push(n);
						}
					}
				}
			}
		}
		
		public function getTargetWithinBase(_controlingAgent:int, teamName:String):GameEntity 
		{
			var callerTeam:Array;
			var myTeamBuildings:Array;
			var enemy:GameEntity;
			var p:GameEntity;
			var sightArray:Array;
			var n:Node;
			
			if (_controlingAgent == Agent.PC)
			{
				callerTeam = Parameters.pcTeam;
				myTeamBuildings = pc_buildingsSight;
			}
			else
			{
				callerTeam = Parameters.humanTeam;
				myTeamBuildings = human_buildingsSight;
			}
			
			var len:int = myTeamBuildings.length;
			for (var g:int = 0; g < len; g++ )
			{
				n = myTeamBuildings[g];
				if (n.occupyingUnit && n.occupyingUnit.myTeamObj.teamName != teamName )
				{
					enemy = n.occupyingUnit;
					break;
				}
			}
			
			
			
			return enemy;
		}
		
		public function getBaseNodes(_agent:int):Array 
		{
			if (_agent == Agent.HUMAN)
			{
				return human_buildingsSight;
			}
			else
			{
				return pc_buildingsSight;
			}
		}
		
		public function dispose():void 
		{
			human_buildingsSight = null;
			pc_buildingsSight = null;
		}
	}
}