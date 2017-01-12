package global.ui.hud.slotIcons
{
	
	import global.ui.hud.HUDView;
	
	import starling.display.MovieClip;
	

	public class UnitSlotHolder extends SlotHolder
	{
		
		
		public function UnitSlotHolder(_unitName:String, _contextType:String)
		{
			assetName = _unitName;
			
			super(_unitName, _contextType);
		}
		
		override public function getUnit():String
		{
			var pos:String = "";
			var n:String;

			return assetName;
		}
		
		override protected function done():void
		{
			buildInProgress = false;
			loadingSquare.removeFromParent();
			buildCompleteFunction(assetName, contextType , disabledSlots);
			buildCompleteFunction = null;
			super.done();
		}
	}
}