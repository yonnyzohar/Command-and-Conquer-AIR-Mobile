package com.yonnyzohar.global.ui.hud.slotIcons
{
	
	import com.yonnyzohar.global.ui.hud.HUD;
	import com.yonnyzohar.states.game.teamsData.TeamObject;
	
	import starling.display.MovieClip;
	

	public class UnitSlotHolder extends SlotHolder
	{
		
		
		public function UnitSlotHolder(assetName:String, _contextType:String,  _teamObj:TeamObject = null, showUI:Boolean = true)
		{
			super(assetName, _contextType, _teamObj, showUI);
		}
		
		override protected function removeUi():void
		{
			if(loadingSquare)loadingSquare.removeFromParent();
		}
		
		override protected function done():void
		{
			removeUi();
			buildCompleteFunction(assetName, contextType , disabledSlots);
			super.done();
		}
	}
}