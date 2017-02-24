package states.game.ui 
{
	import flash.geom.Point;
	import global.enums.Agent;
	import global.enums.MouseStates;
	import global.map.Node;
	import global.Parameters;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import states.game.entities.buildings.Building;
	import states.game.entities.GameEntity;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class SellRepairManager 
	{
		static private var instance:SellRepairManager = new SellRepairManager();
		
		public function SellRepairManager()
		{
			if (instance)
			{
				throw new Error("Singleton and can only be accessed through Singleton.getInstance()");
			}
		}
		
		public static function getInstance():SellRepairManager
		{
			return instance;
		}
		
		public function init():void
		{
			Parameters.theStage.addEventListener(TouchEvent.TOUCH, onStageTouch);
		}
		
		public function freeze():void 
		{
			Parameters.theStage.removeEventListener(TouchEvent.TOUCH, onStageTouch);
		}
		
		public function resume():void
		{
			Parameters.theStage.addEventListener(TouchEvent.TOUCH, onStageTouch);
		}
		
		public function dispose():void 
		{
			Parameters.theStage.removeEventListener(TouchEvent.TOUCH, onStageTouch);
		}
		
		private function onStageTouch(e:TouchEvent):void 
		{
			var start:Touch  = e.getTouch(Parameters.theStage, TouchPhase.BEGAN);
			var moving:Touch = e.getTouch(Parameters.theStage, TouchPhase.MOVED);
			var end:Touch    = e.getTouch(Parameters.theStage, TouchPhase.ENDED);
			var targetCol:int;
			var targetRow:int;
			var n:Node;
			var occupyingUnit:GameEntity;
			
			var location:Point;
			

			var i:int = 0;
			
			if (MouseStates.currentState == MouseStates.SELL)
			{
				if (end)
				{
					location = end.getLocation(Parameters.mapHolder);
					targetCol = location.x / Parameters.tileSize;
					targetRow = location.y / Parameters.tileSize;
					if (Parameters.boardArr[targetRow] && Parameters.boardArr[targetRow][targetCol])
					{
						n = Node(Parameters.boardArr[targetRow][targetCol]);
						if (n.occupyingUnit)
						{
							occupyingUnit = GameEntity(n.occupyingUnit);
							if (occupyingUnit is Building)
							{
								if(occupyingUnit.model.controllingAgent == Agent.HUMAN)
								{
									Building(occupyingUnit).buildingSold();
								}
							}
						}
					}
				}
			}
			if (MouseStates.currentState == MouseStates.REPAIR)
			{
				if (end)
				{
					location = end.getLocation(Parameters.mapHolder);
					targetCol = location.x / Parameters.tileSize;
					targetRow = location.y / Parameters.tileSize;
					if (Parameters.boardArr[targetRow] && Parameters.boardArr[targetRow][targetCol])
					{
						n = Node(Parameters.boardArr[targetRow][targetCol]);
						if (n.occupyingUnit)
						{
							occupyingUnit = GameEntity(n.occupyingUnit);
							if (occupyingUnit is Building)
							{
								if(occupyingUnit.model.controllingAgent == Agent.HUMAN)
								{
									Building(occupyingUnit).buildingRepaired();
								}
							}
						}
					}
				}
			}
		}
	}
}