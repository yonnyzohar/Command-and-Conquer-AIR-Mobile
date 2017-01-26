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
		
		override protected function done():void
		{
			if (view)
			{
				view.addChild(readyTXT);
				readyTXT.visible = true;
			}
			
			if (buildCompleteFunction)
			{
				buildCompleteFunction(assetName);
			}
			
			super.done();
		}
		
	}
}