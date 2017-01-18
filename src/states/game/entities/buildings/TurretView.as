package states.game.entities.buildings 
{
	import states.game.entities.EntityModel;
	import states.game.entities.GameEntity;
	import states.game.entities.units.views.UnitView;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class TurretView extends BuildingView
	{
		
		public function TurretView(_model:EntityModel,_name:String) 
		{
			super(_model,_name)
		}
		
		override public function shoot(enemy:GameEntity, eRow:int, eCol:int):void
		{
			state = "_fire";
			playState();
			mc.loop = false;
		}
		
	}

}