package global.ui.hud.slotIcons
{
	import global.GameAtlas;
	import states.game.teamsData.TeamObject;
	
	import starling.core.Starling;
	import starling.events.Event;
	

	public class BuildingSlotHolder extends SlotHolder
	{
		public function BuildingSlotHolder(assetName:String, _contextType:String,  _teamObj:TeamObject = null, showUI:Boolean = true)
		{
			super(assetName, _contextType, _teamObj, showUI);
		}
		
		override protected function removeUi():void
		{
			if (view)
			{
				view.addChild(readyTXT);
				readyTXT.visible = true;
			}
		}
		
		override protected function done():void
		{
			 removeUi();
			
			if (buildCompleteFunction != null)
			{
				buildCompleteFunction(assetName);
			}
			
			super.done();
		}
		
	}
}