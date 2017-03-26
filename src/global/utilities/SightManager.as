package global.utilities
{
	import flash.utils.Dictionary;
	import global.enums.Agent;
	import global.map.mapTypes.Board;
	import global.map.Node;
	import global.Parameters;
	import starling.display.Quad;
	import starling.events.EventDispatcher;
	import states.game.entities.buildings.Building;
	import states.game.entities.buildings.Turret;
	import states.game.entities.GameEntity;
	import states.game.teamsData.TeamObject;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class SightManager extends EventDispatcher
	{
		
		private var teamObj:TeamObject;
		
		public function SightManager(_teamObj:TeamObject)
		{
			teamObj = _teamObj;
			
		}
		

		public function init():void 
		{
			var p:GameEntity;
			var n:Node;
			var sightArray:Array;
			var len5:int;
			var agent:int = teamObj.agent;
			
			var len3:int = teamObj.team.length;
			for (var i:int = 0; i < len3; i++ )
			{
				p = teamObj.team[i];
				
				if (agent == Agent.HUMAN)
				{
					sightArray = p.getSight();
					len5 = sightArray.length;
					for (var g:int = 0; g < len5; g++ )
					{
						n = sightArray[g];
						n.seen = true;
					}
				}
				else
				{
					p.view.visible = false;
				}
			}
		}
		
				
		public function addSight(p:GameEntity):void
		{
			var agent:int = teamObj.agent;
			//get this units sight array
			var sightArray:Array = p.getSight();
			var len2:int = sightArray.length;
			var n:Node;
			var g:int = 0;
			for (g = 0; g < len2; g++ )
			{
				//current node in sight array
				n = sightArray[g];
				
				if (agent == Agent.HUMAN)
				{
					n.seen = true;
				}
				else
				{
					if (Parameters.AI_ONLY_GAME)
					{
						n.seen = true;// -- setting this to true will make pc units appear in the minimap!
					}
				}
			}
		}
		
		
		public function dispose():void 
		{
			
		}

	}
}