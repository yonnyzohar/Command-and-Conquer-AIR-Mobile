package com.yonnyzohar.states.game.entities.buildings 
{
	import starling.events.Event;
	import com.yonnyzohar.states.game.entities.EntityModel;
	import com.yonnyzohar.states.game.entities.GameEntity;
	import com.yonnyzohar.states.game.entities.units.views.UnitView;
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
			mc.removeEventListener(Event.COMPLETE, onBuildAnimComplete);
			state = "_fire";
			playState();
			mc.stop();
			mc.loop = false;
		}
		
	}

}