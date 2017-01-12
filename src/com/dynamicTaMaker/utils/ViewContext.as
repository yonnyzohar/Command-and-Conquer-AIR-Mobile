package com.dynamicTaMaker.utils
{
	import com.dynamicTaMaker.views.GameSprite;
	import starling.display.Stage;

	public class ViewContext
	{
		static public var theStage:Stage;
		static public var mainView:GameSprite;
		public static var screenWidth:int;
		public static var screenHeight:int;
		
		public static function getView(viewName:String):*
		{
			return mainView.getView(viewName);
		}
		
			
		public static function matchSizeToScreen(view:GameSprite):void
		{
			var origWidth:int = view.width;
			view.width = ViewContext.theStage.stageWidth;
			var wScale:Number = view.width / origWidth;
			view.height *= wScale;
			//view.x = (ViewContext.theStage.stageWidth - view.width)/2;
			//view.y = (ViewContext.theStage.stageHeight - view.height)/2;
			
		}
	}
}