package states
{
	import global.Parameters;
	import global.utilities.GlobalEventDispatcher;
	import starling.text.TextField;
	
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.EventDispatcher;

	public class LoadingScreen
	{
		public var view:Sprite;
		private var totalIterations:int;
		private var loaded:int = 0;
		private var bg:Quad;
		private var green:Quad;
		private var tf:TextField;
		private var br:String = "\n";
		
		public function LoadingScreen()
		{
			if (view == null)
			{
				view = new starling.display.Sprite();
				bg = new Quad(Parameters.flashStage.stageWidth, Parameters.flashStage.stageHeight * 0.01, 0x000000);
				green = new Quad(Parameters.flashStage.stageWidth, Parameters.flashStage.stageHeight * 0.01, 0x0cc34);
				
			
				tf = new starling.text.TextField(Parameters.flashStage.stageWidth, Parameters.flashStage.stageHeight, "");
				tf.format.setTo("Verdana", 20);
				tf.format.color = 0xffffff;
				
				
				tf.touchable = false;
				view.addChild(bg);
				view.addChild(green);
				view.y = 0;// Parameters.flashStage.stageHeight - view.height;
				view.addChild(tf);
				//tf.y -= tf.height;
			}
			
		}
		
		public function init():void
		{
			Parameters.gameHolder.addChild(view);
			green.scaleX = 0;
		}
		
		public function progress(loaded:Number, total:Number, message:String):void
		{
			green.scaleX = loaded / total;
			tf.text = message;
		}
		
		public function remove():void 
		{
			tf.text = "";
			view.removeFromParent();
		}
		
		public function displayMessage(str:String):void 
		{
			tf.text += (str +br) ;
			if (tf.textBounds.height > Parameters.flashStage.stageHeight)
			{
				tf.text = "";
			}
		}
	}
}