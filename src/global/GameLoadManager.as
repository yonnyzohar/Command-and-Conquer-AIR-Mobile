package global
{
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import com.greensock.*;
	import com.greensock.loading.*;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.display.*;
	import flash.display.Sprite;
	import flash.system.Worker;
	
	 
	public class GameLoadManager extends Sprite
	{
		private var queue:LoaderMax;
		
		public function GameLoadManager() 
		{
			super();
			//trace("isPrimordial: " + Worker.current.isPrimordial)
			//queue = new LoaderMax( { name:"mainQueue", onProgress:progressHandler, onComplete:completeHandler, onError:errorHandler, onChildOpen:childOpened } );
			
		}
		
		
		public function init(xmlArr:Array , imgArr:Array):void
		{
			var curXML:Object;
			var curIMG:Object;
			var len:int = xmlArr.length;
			
			for (var i:int = 0; i < len; i++ )
			{
				curXML = xmlArr[i];
				curIMG = imgArr[i];
				
				queue.append( new XMLLoader(curXML.file, { name:curXML.name } ) );
				queue.append( new ImageLoader(curIMG.file, { name:curIMG.name } ) );
			}
			
			queue.load();
		}
		
		private function childOpened(event:LoaderEvent):void 
		{
			
		}
		
		private function progressHandler(event:LoaderEvent):void 
		{
			//Parameters.tf.text = ("progress: " + event.target.name);
		}
		
		private function completeHandler(event:LoaderEvent):void 
		{
			//dispatchEvent(new Event("LOAD_COMPLETE"));
		}
		
		private function errorHandler(event:LoaderEvent):void 
		{
			//Parameters.tf.text = ("error occured with " + event.target + ": " + event.text);
		}
		
	}

}