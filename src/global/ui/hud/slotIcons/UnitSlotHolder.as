package global.ui.hud.slotIcons
{
	
	import global.ui.hud.HUD;
	import states.game.teamsData.TeamObject;
	
	import starling.display.MovieClip;
	

	public class UnitSlotHolder extends SlotHolder
	{
		
		
		public function UnitSlotHolder(assetName:String, _contextType:String,  _teamObj:TeamObject = null, showUI:Boolean = true)
		{
			super(assetName, _contextType, _teamObj, showUI);
		}
		
		override protected function removeUi():void
		{
			buildInProgress = false;
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