package global.ui.hud.slotIcons
{
	import global.GameAtlas;
	
	import starling.core.Starling;
	import starling.events.Event;
	

	public class BuildingSlotHolder extends SlotHolder
	{
		public function BuildingSlotHolder(_unitName:String, _contextType:String)
		{
			assetName = _unitName;
			
			super(assetName, _contextType);
		}
		
		override public function getUnit():String
		{
			return assetName;
		}
		
		override protected function done():void
		{
			addChild(readyTXT);
			readyTXT.visible = true;
			super.done();
		}
		
	}
}