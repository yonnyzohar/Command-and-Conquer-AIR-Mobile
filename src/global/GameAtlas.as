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
		/*private static var unitsTexture:Texture;
		private static var unitsAtlas:starling.textures.TextureAtlas;
		
		private static var buildingsTexture:Texture;
		private static var buildingsAtlas:starling.textures.TextureAtlas;
		
		private static var mapTexture:Texture;
		private static var mapAtlas:starling.textures.TextureAtlas;
		
		private static var uiTexture:Texture;
		private static var uiAtlas:starling.textures.TextureAtlas;
		
		private static var hitTexture:Texture;
		private static var hitAtlas:starling.textures.TextureAtlas;
		
		private static var buildQueTexture:Texture;
		private static var buildQueAtlas:starling.textures.TextureAtlas;*/
		
		[Embed(source="../../bin/GameLoaderWorker.swf", mimeType="application/octet-stream")]
        private static var GameLoaderWorker:Class;
		
		
		private static var urlLoader:URLLoader = new URLLoader();
		private static var l:Loader = new Loader();
		private static var bmp:Bitmap;
		private static var counter:int = 0;
		
		private static var sharedTextures:Vector.<starling.textures.TextureAtlas> = new Vector.<starling.textures.TextureAtlas>();
		private static var nodTextures:Vector.<starling.textures.TextureAtlas> = new Vector.<starling.textures.TextureAtlas>();
		private static var gdiTextures:Vector.<starling.textures.TextureAtlas> = new Vector.<starling.textures.TextureAtlas>();
		
		private static var callback:Function;
		private static var assetNames:Array = [];
		private static var xmlArr:Array = [];
		private static var imgArr:Array = [];
		private static var loadManager:GameLoadManager;
		
		private static var atlasDicts:Dictionary = new Dictionary();
		private static var worker:Worker;
		static private var backToMain:MessageChannel;
		static private var mainToBack:MessageChannel;
		static private var loadingInProgress:Boolean = false;
		static private var loadedAssets:Object = {};
		
		
		public static function initGlobalAssets():void
		{
			var scale:Number = 1;
			var mc:flash.display.MovieClip;
			
			//load the map - currently from FLA
			mc = new MapMC();
			var b:starling.textures.TextureAtlas = DynamicAtlas.fromMovieClipContainer(mc, scale, 0, true, true);
			sharedTextures.push(b);
			b = null;
			
			//load the left side ui - currently from FLA
			mc = new UIAssets()
			var d:starling.textures.TextureAtlas = DynamicAtlas.fromMovieClipContainer(mc, 1, 0, true, true);
			sharedTextures.push(d);
			d = null;
		
			mc = null;
			
			assetNames.splice(0);
			
			
			var mustMap:Object = {
				
				icons:[
					"icons"
				],
				bullets: [
					"bullets"
					
				],
				effects: [
					"effects"	
					
				],
				tiberium:[
					"tiberium"
				],
				trees:[
					"trees"
				]
				
			}
			
			var gameAssetsDir:File = File.applicationDirectory.resolvePath("gameAssets");
			if (gameAssetsDir.exists && gameAssetsDir.isDirectory)
			{
				//get all files
				var assetTypesDir:Array = gameAssetsDir.getDirectoryListing();
				
				for (var i:int = 0; i < assetTypesDir.length; i++ )
				{
					var currentTypeName:String = assetTypesDir[i].name;
					
					if (mustMap[currentTypeName])// e.g "trees"
					{
						var dir:File = assetTypesDir[i];
						var assets:Array = dir.getDirectoryListing();
						
						for (var g:int = 0; g < mustMap[currentTypeName].length; g++ )
						{
							for (var j:int = 0; j < assets.length; j++ )
							{
								var assetDir:File = assets[j];
								if (assetDir.name == mustMap[currentTypeName][g])
								{
									loadedAssets[assetDir.name] = true;
									//trace(assetDir.name);
									
									var obj:Object = 
									{
										xml :assetDir.name+"XML" , 
										ta  : assetDir.name+"IMG", 
										assetName:assetDir.name,
										xmlPath : gameAssetsDir.name + "/" + currentTypeName + "/" + assetDir.name+"/ta.xml",
										imgPath : gameAssetsDir.name + "/" + currentTypeName + "/" + assetDir.name+"/ta.png",
										side : findOwner(assetDir.name)
									}
									assetNames.push( obj );
								}
							}
						}
					}
				}
			}
			
			
			initWorker();
			
			
		}
		
		static private function initWorker():void 
		{
			worker = WorkerDomain.current.createWorker(new GameLoaderWorker(), true);
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
		
		public static function init(dirsToLoadMap:Object, _callback:Function):void
		{
			
			atlasDicts["gdi"] = gdiTextures;
			atlasDicts["nod"] = nodTextures;
			atlasDicts["none"] = sharedTextures;
			
			if (loadingInProgress)
			{
				//trace("waiting")
				GlobalEventDispatcher.getInstance().addEventListener("WORKER_DONE", runMe);
			}
			else
			{
				runMe(null)
			}
			
			function runMe(e:starling.events.Event = null):void
			{
				//trace("running!");
				callback = _callback;
				assetNames.splice(0);

				var gameAssetsDir:File = File.applicationDirectory.resolvePath("gameAssets");
				
				//go over the gameAssetsdir
				if (gameAssetsDir.exists && gameAssetsDir.isDirectory)
				{
					//get all files
					var assetTypesDir:Array = gameAssetsDir.getDirectoryListing();
					
					for (var i:int = 0; i < assetTypesDir.length; i++ )
					{
						var assetType:File = assetTypesDir[i];
						
						if (assetType.isDirectory)
						{
							//go over all subdirs in type
							var assets:Array = assetType.getDirectoryListing();
							
							for (var j:int = 0; j < assets.length; j++ )
							{
								var assetDir:File = assets[j];
								
								if (assetDir.exists)
								{
									//this is to make sure we haven't loaded this asset already
									if(dirsToLoadMap[assetDir.name] && loadedAssets[assetDir.name] == undefined)
									{
										//trace("----------adding " + assetDir.name + " TA")
										loadedAssets[assetDir.name] = true;
										var obj:Object = {
											
											xml :assetDir.name+"XML" , 
											ta  : assetDir.name+"IMG", 
											assetName:assetDir.name,
											xmlPath : gameAssetsDir.name + "/" + assetType.name + "/" + assetDir.name+"/ta.xml",
											imgPath : gameAssetsDir.name + "/" + assetType.name + "/" + assetDir.name+"/ta.png",
											side : findOwner(assetDir.name)
										}
										
										assetNames.push( obj );
									}
								}
							}
						}
					}
				}
				
				//loadManager = new GameLoadManager();
				//loadManager.addEventListener("LOAD_COMPLETE", completeHandler);
				//loadManager.init(xmlArr, imgArr);
				//var worker:Worker = WorkerFactory.getWorkerFromClass(GameLoadManager, Parameters.flashStage.loaderInfo.bytes, true);
				//worker.start();
			
				if (assetNames.length)
				{
					initWorker();
				}
				
			}
		}
		
		static private function handleBGWorkerStateChange(e:flash.events.Event):void 
		{
			if (worker.state == WorkerState.RUNNING) 
            {
				//trace("ASSET NAMES!!!!!");
                mainToBack.send(assetNames);
            }
		}
		
		static private function onBackgroundMessageToMain(e:flash.events.Event):void 
		{
			var result:Object = backToMain.receive() as Object;
			if (result.message != "asset")
			{
				//Parameters.tf.text = result.message;
				Parameters.loadingScreen.progress(counter, assetNames.length, result.message)
			}
			else
			{
				//sent an object
				Parameters.loadingScreen.progress(assetNames.length, assetNames.length, "DONE!")
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
				
			if (counter >= assetNames.length)
			{
			
				if (callback)
				{
					Parameters.loadingScreen.remove();
					callback();
				}
				killWorker();
			}
		}
		
		static private function killWorker():void 
		{
			//trace("killWorker");
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
			for(var i:int = 0; i < curTexturesArr.length; i++)
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
			
			for (var i:int = 0; i < stats.length; i++ )
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
			
			for(i = 0; i < curTexturesArr.length; i++)
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
			////trace"getTextures: " + type );
			
			var textures:Vector.<Texture>;
			for(var i:int = 0; i < curTexturesArr.length; i++)
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
			for(var i:int = 0; i < sharedTextures.length; i++)
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
			//trace"createMovieClip: " + itemName );
			var curTexturesArr:Vector.<starling.textures.TextureAtlas> = atlasDicts[owner];
			var textures:Vector.<Texture>;
			
			for(var i:int = 0; i < curTexturesArr.length; i++)
			{
				////trace"sharedTextures[i]: " + sharedTextures[i]);
				if(curTexturesArr[i].getTextures(itemName))
				{
					textures = curTexturesArr[i].getTextures(itemName);
					////trace"found: "  + textures + " l: " + textures.length);
					
					if(textures.length != 0)
					{
						break;
					}
				}
			}
			
			var mc:MovieClip = new MovieClip(textures, 10);
			return mc;
		}
	}
}


//queue.append( new SWFLoader("swf/child.swf", {name:"childClip", estimatedBytes:3000, container:this, x:250, autoPlay:false}) );
//queue.append( new MP3Loader("mp3/audio.mp3", {name:"audio", repeat:2, autoPlay:true}) );


//start loading

/*var assets:Array = [
	//{"img" : new GameAssets.UnitsAtlas(), 		"xml" : new GameAssets.UnitsXml()},
	//{"img" : new GameAssets.BuildingsAtlas(), 	"xml" : new GameAssets.BuildingsXml()},
	//{"img" : new GameAssets.MapAtlas(), 		"xml" : new GameAssets.MapXml()},
	//{"img" : new GameAssets.HitAtlas(), 		"xml" : new GameAssets.HitXml() },
	//{"img" : new GameAssets.UIAtlas(), 			"xml" : new GameAssets.UIXml() },
	//{"img" : new GameAssets.AllAssetsAtlas(), 	"xml" : new GameAssets.AllAssetsXML() },
	//{"img" : new GameAssets.BuildQueAtlas(), 	"xml" : new GameAssets.BuildQueXml()}
];


var bmp:Bitmap;
var xml:XML;
var texture:Texture;
var atlas:starling.textures.TextureAtlas;
for(var i:int = 0; i < assets.length; i++)
{
	bmp = assets[i].img;
	xml = XML(assets[i].xml);
	texture = Texture.fromBitmap(bmp);
	atlas = new starling.textures.TextureAtlas(texture, xml);
	
	
	bmp.bitmapData.dispose();
	bmp = null;
	sharedTextures.push(atlas);
}*/