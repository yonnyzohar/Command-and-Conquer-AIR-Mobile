package
{
	import com.greensock.*;
	import com.greensock.loading.*;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.display.*;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.system.Worker;
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.utils.ByteArray;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	 
	public class GameLoadManager extends Sprite
	{
		private var queue:LoaderMax;
		private var backToMain:MessageChannel;
		private var mainToBack:MessageChannel;
		private var assetNames:Array ;
		private var current:int = 0;
		private var len:int;
		
		public function GameLoadManager() 
		{
			//trace("GameLoadManager!!!!!!!!!!")
			backToMain = Worker.current.getSharedProperty("backToMain");
			mainToBack = Worker.current.getSharedProperty("mainToBack");
			//trace("1")
			if(mainToBack)
			{
				mainToBack.addEventListener(flash.events.Event.CHANNEL_MESSAGE, onMainMessageToBackground);	
			}
		}
		
		private function onMainMessageToBackground(e:flash.events.Event):void 
		{
			if (!mainToBack.messageAvailable)
                return;
            
            assetNames = mainToBack.receive() as Array;
			len = assetNames.length;
			
			loadAsset();
		}
		
		
		public function initMe():void
		{
			/*xml :assetDir.name+"XML" , 
			ta  : assetDir.name+"IMG", 
			assetName:assetDir.name,
			xmlPath : gameAssetsDir.name + "/" + assetType.name + "/" + assetDir.name+"/ta.xml",
			imgPath : gameAssetsDir.name + "/"+assetType.name + "/"+assetDir.name+"/ta.png"*/
			
			/*for (var i:int = 0; i < len; i++ )
			{
				o = assetNames[i];
				queue.append( new XMLLoader(o.xmlPath, { name:o.xml } ) );
				queue.append( new ImageLoader(o.imgPath, { name:o.ta } ) );
			}
			queue.load();*/
		}
		
		private function loadAsset():void 
		{
			queue = new LoaderMax( { name:"mainQueue", onProgress:progressHandler, onComplete:completeHandler, onError:errorHandler, onChildOpen:childOpened } );
			
			if (current < len)
			{
				var o:Object  = assetNames[current];
				queue.append( new XMLLoader(o.xmlPath, { name:o.xml } ) );
				queue.append( new ImageLoader(o.imgPath, { name:o.ta } ) );
				queue.load();
			}
		}
		
		private function childOpened(event:LoaderEvent):void 
		{
			//Parameters.tf.text = ("loading: " + event.target.name);
			backToMain.send({message : "loading: " + event.target.name});
		}
		
		private function progressHandler(event:LoaderEvent):void 
		{
			//Parameters.tf.text = ("progress: " + event.target.name);
			//backToMain.send({message : "progress: " + event.target.name});
		}
		
		private function completeHandler(event:LoaderEvent):void 
		{
			try
			{
				var o:Object = assetNames[current];
				var assetName:String = o.assetName;
				var image:ContentDisplay = LoaderMax.getContent(o.ta);
				var bmp:Bitmap = Bitmap(image.getChildAt(0));
				var xml:XML = LoaderMax.getContent(o.xml);
				
				o.xml = xml;
				o.width = bmp.width;
				o.height = bmp.height;
				o.bitmapDatas = { };
				
				var i:int = 0;
				var color:String;
				var weaponsColorsMap:Object = o.colors;
				var byteArrayBD:ByteArray;
				var copy:BitmapData;
				
				
				
				if ( o.side == "none")
				{
					trace(o.side)
					byteArrayBD = new ByteArray();
					bmp.bitmapData.copyPixelsToByteArray(bmp.bitmapData.rect, byteArrayBD);
					o.bitmapDatas["none"] = byteArrayBD;
				}
				else if (o.side == "both" )
				{
					for (var k:String in weaponsColorsMap)
					{
						for (i = 0; i < weaponsColorsMap[k].length; i++ )
						{
							byteArrayBD = new ByteArray();
							color = weaponsColorsMap[k][i];
							copy = getImageCopy(bmp);
							copy = ColorSprites.colorImages(copy, color);
							copy.copyPixelsToByteArray(copy.rect, byteArrayBD);
							o.bitmapDatas[color] = byteArrayBD;
						}
					}
				}
				else
				{
					for (i = 0; i < weaponsColorsMap[o.side].length; i++ )
					{
						byteArrayBD = new ByteArray();
						color = weaponsColorsMap[o.side][i];
						copy = getImageCopy(bmp);
						copy = ColorSprites.colorImages(copy, color);
						copy.copyPixelsToByteArray(copy.rect, byteArrayBD);
						o.bitmapDatas[color] = byteArrayBD;
					}
				}
				
				
				/*if (o.side == "gdi" )
				{
					bmp.bitmapData.copyPixelsToByteArray(bmp.bitmapData.rect, byteArrayBD);
					o.gdiBD = byteArrayBD;
				}
				
				if (o.side == "nod" )
				{
					bmp.bitmapData = ColorSprites.colorImages(bmp.bitmapData, "nod");
					bmp.bitmapData.copyPixelsToByteArray(bmp.bitmapData.rect, byteArrayBD);
					o.nodBD = byteArrayBD;
				}
				if (o.side == "both" )
				{
					bmp.bitmapData.copyPixelsToByteArray(bmp.bitmapData.rect, byteArrayBD);
					o.gdiBD = byteArrayBD;
					
					bmp.bitmapData = ColorSprites.colorImages(bmp.bitmapData, "nod");
					bmp.bitmapData.copyPixelsToByteArray(bmp.bitmapData.rect, byteArrayBD2);
					o.nodBD = byteArrayBD2;
				}*/
				
				
				//assetNames[i] = o;
				trace("returning!!")
				backToMain.send({message : "asset", data : o});
				current++;
				loadAsset();
			}
			catch (e:Error)
			{
				backToMain.send({message : e.message});
			}
			
		}
		
		private function getImageCopy(orig:Bitmap):BitmapData
		{
			var copyBD:BitmapData = new BitmapData(orig.width, orig.height, true, 0);
			var rect:Rectangle = new Rectangle(0, 0, orig.width, orig.height);
			copyBD.copyPixels(orig.bitmapData, rect, new Point());
			
			return copyBD;
		}
		
				
		private function errorHandler(event:LoaderEvent):void 
		{
			//Parameters.tf.text = ("error occured with " + event.target + ": " + event.text);
			backToMain.send({message : "error occured with " + event.target + ": " + event.text})
		}
		
	}

}