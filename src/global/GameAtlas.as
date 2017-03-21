package  global 
{
	
	import com.greensock.loading.display.ContentDisplay;
	import com.greensock.loading.LoaderMax;
	import com.WorkerFactory;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.system.MessageChannel;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	import global.utilities.ColorSprites;
	import global.utilities.GlobalEventDispatcher;
	import starling.events.Event;
	import states.game.stats.AssetStatsObj;
	import states.game.stats.BuildingsStats;
	import states.game.stats.InfantryStats;
	import states.game.stats.TurretStats;
	import states.game.stats.VehicleStats;
	
	import global.assets.GameAssets;
	
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.events.EventDispatcher;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	
	
	import com.emibap.textureAtlas.DynamicAtlas;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.text.Font;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.EnterFrameEvent;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.Color;
	import flash.display.Sprite;
	import flash.system.Worker;
	import flash.events.Event;
	

	public class GameAtlas extends EventDispatcher
	{
		
		[Embed(source="../../bin/GameLoaderWorker.swf", mimeType="application/octet-stream")]
        private static var GameLoaderWorker:Class;
		
		
		private static var urlLoader:URLLoader = new URLLoader();
		private static var l:Loader = new Loader();
		private static var bmp:Bitmap;
		private static var counter:int = 0;
		
		private static var sharedTextures:Vector.<starling.textures.TextureAtlas> 
		private static var nodTextures:Vector.<starling.textures.TextureAtlas>
		private static var gdiTextures:Vector.<starling.textures.TextureAtlas>
		
		private static var callback:Function;
		private static var assetNames:Array = [];
		private static var loadManager:GameLoadManager;
		
		private static var atlasDicts:Dictionary = new Dictionary();
		private static var worker:Worker;
		static private var backToMain:MessageChannel;
		static private var mainToBack:MessageChannel;
		static public var loadingInProgress:Boolean = false;
		static private var selectedAssets:Object = { };
		static public var completedAssets:Object = { };
		private static var stopMe:Boolean = false;
		private static var workerInstance:ByteArray;
		
		private static var gameAssetsDir:File;
		
		private static var assetDirsMap:Object = {};
		
		//private static var mapMC:MapMC;
		//private static var uiMC:UIAssets;
		
		public static function reset():void
		{
			sharedTextures = new Vector.<starling.textures.TextureAtlas>();
			nodTextures = new Vector.<starling.textures.TextureAtlas>();
			gdiTextures = new Vector.<starling.textures.TextureAtlas>();
			callback = null;
			assetNames.splice(0);
			atlasDicts = new Dictionary();
			loadingInProgress = false;
			selectedAssets = { };
			completedAssets = { };
			if (workerInstance)
			{
				workerInstance = null;
			}
			if (backToMain)
			{
				backToMain.removeEventListener(flash.events.Event.CHANNEL_MESSAGE, onBackgroundMessageToMain);
			}
			backToMain = null;
			
			if (worker)
			{
				worker.removeEventListener(flash.events.Event.WORKER_STATE, handleBGWorkerStateChange);
			}
			worker = null;
			
		}
		
		
		public static function initGlobalAssets(_callback:Function):void
		{
			reset();
			callback = _callback;
			
			var scale:Number = 1;
			
			//load the map - currently from FLA
			/*mapMC = new MapMC();
			var b:starling.textures.TextureAtlas = DynamicAtlas.fromMovieClipContainer(mapMC, 1, 0, true, true);
			sharedTextures.push(b);
			b = null;*/
			
			//load the left side ui - currently from FLA
			/*uiMC = new UIAssets()
			var d:starling.textures.TextureAtlas = DynamicAtlas.fromMovieClipContainer(uiMC, 1, 0, true, true);
			sharedTextures.push(d);*/
			//d = null;
			//mapMC = null;
			//uiMC = null;
			
			assetNames.splice(0);
			
			
			////////////////
			var dirPath:String;
			var len:int;
			var len1:int;
			gameAssetsDir = getGameAssetsDir();
			
			if (gameAssetsDir.exists && gameAssetsDir.isDirectory)
			{
				//get all files
				var assetTypesDir:Array = gameAssetsDir.getDirectoryListing();
				var assetTypesDirLen:int = assetTypesDir.length;
				
				for (var i:int = 0; i < assetTypesDirLen; i++ )
				{
					var currentTypeName:String = assetTypesDir[i].name; // tiberium, map, infantry, vehicles, turrets
					
					if(currentTypeName != "sounds")
					{
						dir = assetTypesDir[i];
						if(dir.isDirectory)
						{
							var assets:Array = dir.getDirectoryListing();
							len = assets.length;
							for (var g:int = 0; g < len; g++ )
							{
								len1 = assets.length;
								for (var j:int = 0; j < len1; j++ )
								{
									var assetDir:File = assets[j];
									
									var assetPathStr:String = assetDir.nativePath;
									assetPathStr = assetPathStr.substring(assetPathStr.indexOf("bin/"));
									trace(assetPathStr);
									assetDirsMap[assetDir.name] = assetPathStr;//assetDir;
								}
							}
						}
					}
				}
			}
			
			///////////////
			
			
			var mustMap:Array = [
					"icons",
					"bullets",
					"effects",	
					"tiberium",
					"trees",
					"shores",
					"ridges",
					"tiles",
					"ui"
				];
				
			len1 = mustMap.length;
			for (var j:int = 0; j < len1; j++ )
			{
				var assetTypeName:String = mustMap[j];
				selectedAssets[assetTypeName] = true;
				dirPath = assetDirsMap[assetTypeName]
									
				var obj:Object = 
				{
					xml : assetTypeName+"XML" , 
					ta  : assetTypeName+"IMG", 
					assetName:assetTypeName,
					xmlPath : dirPath + File.separator + "ta.xml",
					imgPath : dirPath + File.separator + "ta.png",
					side : findOwner(assetDir.name)
				}
				assetNames.push( obj );
			}

			initWorker();
			
		}
		
		private static function getGameAssetsDir():File
		{
			if(gameAssetsDir == null)
			{
				gameAssetsDir = File.applicationDirectory.resolvePath("gameAssets");
				Parameters.binPath = "";
				
				if (gameAssetsDir.exists == false)
				{
					gameAssetsDir = File.applicationDirectory.resolvePath("bin");
					gameAssetsDir = gameAssetsDir.resolvePath("gameAssets");
					Parameters.binPath = "bin/";
				}
			}
			
			
			return gameAssetsDir;
		}
		
		
		
		public static function init(dirsToLoadMap:Object, _callback:Function):void
		{
			
			atlasDicts["gdi"] = gdiTextures;
			atlasDicts["nod"] = nodTextures;
			atlasDicts["none"] = sharedTextures;
			
			if (loadingInProgress)
			{
				////trace("waiting")
				GlobalEventDispatcher.getInstance().addEventListener("WORKER_DONE", runMe);
			}
			else
			{
				runMe(null)
			}
			
			function runMe(e:starling.events.Event = null):void
			{
				callback = _callback;
				var assetsToLoad:Array = [];
				var dir:File;
				
				for (var k:String in dirsToLoadMap)
				{
					if(selectedAssets[k] == undefined)
					{
						trace("----------adding " + k + " TA")
						selectedAssets[k] = true;
						dir = assetDirsMap[k]
						var obj:Object = {
							
							xml :k +"XML" , 
							ta  : k +"IMG", 
							assetName:k,
							xmlPath : dir.nativePath + File.separator + "ta.xml",
							imgPath : dir.nativePath + File.separator + "ta.png",
							side : findOwner(k)
						}
						
						assetsToLoad.push( obj );
					}
				}
				
				
						
				if (assetsToLoad.length)
				{
					assetNames = assetsToLoad;
					initWorker();
				}
				else
				{
					if (_callback != null)
					{
						_callback();
					}
				}
				
			}
		}
		
		static private function initWorker():void 
		{
			workerInstance = new GameLoaderWorker()
			worker = WorkerDomain.current.createWorker(workerInstance, true);
			//this is a message channel between the worker to main thread
			backToMain = worker.createMessageChannel(Worker.current);
			//this is a message channel between the main to worker thread
			mainToBack = Worker.current.createMessageChannel(worker);
			
			worker.setSharedProperty("backToMain", backToMain);
			worker.setSharedProperty("mainToBack", mainToBack)
			counter = 0;
			backToMain.addEventListener(flash.events.Event.CHANNEL_MESSAGE, onBackgroundMessageToMain);
			worker.addEventListener(flash.events.Event.WORKER_STATE, handleBGWorkerStateChange);
			loadingInProgress = true;
			worker.start(); 
			
		}
		
		static private function handleBGWorkerStateChange(e:flash.events.Event):void 
		{
			if (worker.state == WorkerState.RUNNING) 
            {
                mainToBack.send(assetNames);
            }
		}
		
		static private function onBackgroundMessageToMain(e:flash.events.Event):void 
		{
			var result:Object = backToMain.receive() as Object;
			if (result.message != "asset" )
			{
				if (!stopMe)
				{
					Parameters.loadingScreen.progress(counter, assetNames.length, result.message)
				}
			}
			else
			{
				if (!stopMe)
				{
					Parameters.loadingScreen.progress(assetNames.length, assetNames.length, "DONE!")
				}
				createAtlases(result.data);
			}
		}

		
		static private function createAtlases(_obj:Object):void 
		{
			//var image:ContentDisplay = LoaderMax.getContent(o.ta);
			//var bmp:Bitmap = Bitmap(image.getChildAt(0));
			//var xml:XML = LoaderMax.getContent(o.xml);
			
			var assetName:String = _obj.assetName;
			var byteArrayBD:ByteArray;
			var bmpd:BitmapData;
			var xml:XML = XML(_obj.xml);

			
			var side:String = _obj.side;// findOwner(assetName);
			
			var texture:Texture;
			var atlas:starling.textures.TextureAtlas;
			
			if (side == "gdi" )
			{
				byteArrayBD = _obj.gdiBD; 
				byteArrayBD.position = 0; // read informations from start.
				bmpd = new BitmapData(_obj.width, _obj.height, true, 0xFFFFFF);
				bmpd.setPixels(bmpd.rect, byteArrayBD);
				texture = Texture.fromBitmapData(bmpd);
				atlas = new starling.textures.TextureAtlas(texture, xml);
				gdiTextures.push(atlas);
			}
			if (side == "nod" )
			{
				byteArrayBD = _obj.nodBD; 
				byteArrayBD.position = 0; // read informations from start.
				bmpd = new BitmapData(_obj.width, _obj.height, true, 0xFFFFFF);
				bmpd.setPixels(bmpd.rect, byteArrayBD);
				texture = Texture.fromBitmapData(bmpd);
				atlas = new starling.textures.TextureAtlas(texture, xml);
				nodTextures.push(atlas);
			}
			
			if (side == "none" )
			{
				byteArrayBD = _obj.noneBD; 
				byteArrayBD.position = 0; // read informations from start.
				bmpd = new BitmapData(_obj.width, _obj.height, true, 0xFFFFFF);
				bmpd.setPixels(bmpd.rect, byteArrayBD);
				texture = Texture.fromBitmapData(bmpd);
				atlas = new starling.textures.TextureAtlas(texture, xml);
				sharedTextures.push(atlas);
			}
			//here we have to color i for nod units
			if (side == "both" )
			{
				byteArrayBD = _obj.gdiBD; 
				byteArrayBD.position = 0; // read informations from start.
				bmpd = new BitmapData(_obj.width, _obj.height, true, 0xFFFFFF);
				bmpd.setPixels(bmpd.rect, byteArrayBD);
				texture = Texture.fromBitmapData(bmpd);
				atlas = new starling.textures.TextureAtlas(texture, xml);
				gdiTextures.push(atlas);
				
				byteArrayBD = _obj.nodBD; 
				byteArrayBD.position = 0; // read informations from start.
				bmpd = new BitmapData(_obj.width, _obj.height, true, 0xFFFFFF);
				bmpd.setPixels(bmpd.rect, byteArrayBD);
				texture = Texture.fromBitmapData(bmpd);
				atlas = new starling.textures.TextureAtlas(texture, xml);
				nodTextures.push(atlas);
				
			}
			
			bmpd.dispose();
			counter++;
			
			completedAssets[assetName] = true;
				
			if (counter >= assetNames.length)
			{
			
				if (callback != null)
				{
					//stopMe = true;
					Parameters.loadingScreen.remove();
					callback();
					callback = null;
				}
				killWorker();
			}
		}
		
		static private function killWorker():void 
		{
			trace("killWorker");
			worker.removeEventListener(flash.events.Event.WORKER_STATE, handleBGWorkerStateChange);
			worker.terminate();
			worker = null;
			
			backToMain.removeEventListener(flash.events.Event.CHANNEL_MESSAGE, onBackgroundMessageToMain);
			backToMain = null;
			mainToBack = null;
			loadingInProgress = false;
			GlobalEventDispatcher.getInstance().dispatchEvent(new starling.events.Event("WORKER_DONE"));
		}
		 
		
		

		public static function createFrame(itemName:String, owner:String = "none"):Image
		{	
			var curTexturesArr:Vector.<starling.textures.TextureAtlas> = atlasDicts[owner];
			
			
			//trace"createFrame: " + itemName );
			var textures:Vector.<Texture>;
			var texture:Texture;
			var image:Image;
			var curTexturesArrLen:int = curTexturesArr.length;
			for(var i:int = 0; i < curTexturesArrLen; i++)
			{
				var ta:starling.textures.TextureAtlas = curTexturesArr[i];
				
				if(ta.getTextures(itemName).length != 0)
				{
					textures = ta.getTextures(itemName);
					texture = textures[0]
					image = new Image(texture);
					break;
				}
			}
			
			
			
			image.scaleX = image.scaleY = Parameters.gameScale;
			return image;
		}
		
		private static function findOwner(_assetName:String):String
		{
			var stats:Array = [BuildingsStats.dict, VehicleStats.dict, InfantryStats.dict, TurretStats.dict];
			var owner:String = "none";
			
			var statsLen:int = stats.length;
			for (var i:int = 0; i < statsLen; i++ )
			{
				var curDict:Dictionary = stats[i];	
				if (curDict[_assetName])
				{
					var o:AssetStatsObj = curDict[_assetName];
					if (o.owner)
					{
						owner = o.owner;
						break;
					}
				}
				
			}
			return owner;
		}
		
		public static function getTexture(itemName:String, owner:String = "none"):Texture
		{
			var texture:Texture;
			var i:int = 0;
			var curTexturesArr:Vector.<starling.textures.TextureAtlas>;
			var textures:Vector.<Texture>;
			
			
			curTexturesArr = atlasDicts[owner];
			var curTexturesArrLen:int = curTexturesArr.length;
			for(i = 0; i < curTexturesArrLen; i++)
			{
				var ta:starling.textures.TextureAtlas = curTexturesArr[i];
				if(ta.getTextures(itemName).length != 0)
				{
					textures = ta.getTextures(itemName);
					
					texture = textures[0]
					break;
				}
			}

			return texture;
		}
		
		static public function getTextures(type:String , owner:String = "none"):Vector.<Texture> 
		{
			var curTexturesArr:Vector.<starling.textures.TextureAtlas> = atlasDicts[owner];
			var curTexturesArrLen:int = curTexturesArr.length;
			
			var textures:Vector.<Texture>;
			for(var i:int = 0; i < curTexturesArrLen; i++)
			{
				if(curTexturesArr[i].getTextures(type).length != 0)
				{
					textures = curTexturesArr[i].getTextures(type);
					break;
				}
			}
			
			return textures;
		}
		
		static public function getMultipleTextureArrays(type:String):Array
		{
			var a:Array = [];
			var len:int = sharedTextures.length;
			for(var i:int = 0; i < len; i++)
			{
				if(sharedTextures[i].getTextures(type).length != 0)
				{
					a.push(sharedTextures[i])
				}
			}
			
			return a;
		}
		
		static public function createMovieClip(itemName:String, owner:String = "none"):starling.display.MovieClip 
		{

			var curTexturesArr:Vector.<starling.textures.TextureAtlas> = atlasDicts[owner];
			var textures:Vector.<Texture>;
			var curTexturesArrLen:int = curTexturesArr.length;
			
			for(var i:int = 0; i < curTexturesArrLen; i++)
			{
				if(curTexturesArr[i].getTextures(itemName))
				{
					textures = curTexturesArr[i].getTextures(itemName);
					
					if(textures.length != 0)
					{
						break;
					}
				}
			}
			
			if (textures)
			{
				return new MovieClip(textures, 10)
			}
			else
			{
				return null;
			}
		}
	}
}

