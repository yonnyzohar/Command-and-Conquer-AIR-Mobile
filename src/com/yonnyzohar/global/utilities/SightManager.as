package com.yonnyzohar.global.utilities
{
	import com.yonnyzohar.global.enums.Agent;
	import com.yonnyzohar.global.map.mapTypes.Board;
	import com.yonnyzohar.global.map.Node;
	import com.yonnyzohar.global.Parameters;
	import starling.display.Quad;
	import starling.events.EventDispatcher;
	import com.yonnyzohar.states.game.entities.buildings.Building;
	import com.yonnyzohar.states.game.entities.buildings.Turret;
	import com.yonnyzohar.states.game.entities.GameEntity;
	import com.yonnyzohar.states.game.teamsData.TeamObject;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class SightManager extends EventDispatcher
	{
		private var buildingsSight:Array;
		private var teamObj:TeamObject;
		
		public function SightManager(_teamObj:TeamObject)
		{
			teamObj = _teamObj;
			buildingsSight = [];
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
		
		public function resetSight():void
		{
			buildingsSight.splice(0);
		}
		
		public function addSight(p:GameEntity):void
		{
			var agent:int = teamObj.agent;
			var sightArray:Array = p.getSight();
			var len2:int = sightArray.length;
			var agent:int = teamObj.agent;
			var n:Node;
			var g:int = 0;
			for (g = 0; g < len2; g++ )
			{
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
				
				
				if (p is Building && !(p is Turret) && buildingsSight.indexOf(n) == -1)
				{
					buildingsSight.push(n);
				}
			}
		}
		
		public function getBaseNodes():Array 
		{
			return buildingsSight;
		}
		
		public function dispose():void 
		{
			buildingsSight = [];
		}
		
		
		
		
		/*public function getTargetWithinBase(_controlingAgent:int, teamName:String):GameEntity 
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
		}*/
		
		
		
		/*public function showAllSightSquares():void 
		{
			var q:Quad;
			var a:Array = [Parameters.humanTeam, Parameters.pcTeam];
			var len:int = a.length;
			var p:GameEntity;
			var sightArray:Array;
			var len3:int;
			var n:Node;
			
			for (var i:int = 0; i < len; i++ )
			{
				var team:Array = a[i];
				var len2:int = team.length;
				for (var j:int = 0; j < len2; j++ )
				{
					p = team[j];
					sightArray = p.getSight();
					len3 = sightArray.length;
					for (var g:int = 0; g < len3; g++ )
					{
						n = sightArray[g];
						q = new Quad(Parameters.tileSize, Parameters.tileSize);
						q.x = Parameters.tileSize * n.col;
						q.y = Parameters.tileSize * n.row;
						q.touchable = false;
						q.alpha = 0.1;
						Board.mapContainerArr[Board.EFFECTS_LAYER].addChild(q);
					}
					
				}
			}
		}*/
	}
}