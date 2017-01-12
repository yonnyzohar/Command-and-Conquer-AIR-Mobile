package global.ui.hud.slotIcons
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import global.ui.hud.HUDView;
	import global.utilities.GameTimer;
	import global.utilities.GlobalEventDispatcher;
	import starling.display.MovieClip;
	import starling.events.Event;
	
	import global.GameAtlas;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	public class SlotHolder extends Sprite
	{
		protected var loadingSquare:MovieClip;
		//protected var bg:Quad;
		protected var mc:Image;
		protected var imgeName:String;
		public var assetName:String;
		
		private var buildTime:int;
		public var cost:int;
		public var buildInProgress:Boolean = false;
		public var currentPerNum:int = 0;
		protected var buildCompleteFunction:Function;
		public var contextType:String; //units or buildings
		
		protected var readyTXT:TextField;
		protected var costTf:TextField;
		
		public var buildingDone:Boolean = false;
		public var disabledSlots:Array;
		
		private var costBg:Quad;
		private var bgQuad:Quad;
		
		
		public function SlotHolder(_imgeName:String, _contextType:String)
		{
			contextType = _contextType;
			var w:int = 64;
			var h:int = 48;

			var textureName:String = "icons_"+_imgeName;
			var tex:Texture = GameAtlas.getTexture(textureName);
			if (tex)
			{
				mc = new Image(tex);
				addChild(mc);
				mc.touchable = false;
				w = mc.width;
				h = mc.height;
			}
		
			
			
			bgQuad = new Quad(w, h);
			bgQuad.touchable = true;
			addChildAt(bgQuad, 0);
			
			if(loadingSquare == null)
			{
				loadingSquare = GameAtlas.createMovieClip("loadingSquare");
				loadingSquare.alpha = 0.5;
				loadingSquare.width = w;
				loadingSquare.height = h;
				loadingSquare.touchable = false;
			}
			
			loadingSquare.currentFrame = 0;
			
			if (contextType == "building" || contextType == "turret")
			{
				readyTXT = new TextField(78, 20, "READY", "Verdana", 15, 0xffffff, true);// - Starling 1_7;
				addChild(readyTXT);
				readyTXT.touchable = false;
				readyTXT.x = (w - readyTXT.width) / 2;
				readyTXT.y = (h - readyTXT.height) / 2;
				readyTXT.visible = false;
			}
			
		}
		
		public function getUnit():String
		{
			return null;
		}
		
		public function setup(assetDetails:Object):void
		{
			buildTime = assetDetails.cost;// / 100;
			if (buildTime < 1)
			{
				buildTime = 1;
			}
			
			cost = assetDetails.cost;
			
			costTf = new TextField(mc.width, 15, cost + "$", "Verdana", 9, 0xffffff, true); //- Starling 1_7;
			costBg = new Quad(mc.width * 0.8, 15, 0x000000);
			costBg.alpha = 0.7;
			costTf.hAlign = "left";
			addChild(costBg);
			addChild(costTf);
		}
		
		
		
		public function buildMe(_complteFnctn:Function):Boolean
		{
			if(buildInProgress)
			{
				return true;
			}
			else
			{
				if(loadingSquare.texture != null)
				{
					buildCompleteFunction = _complteFnctn;
					buildInProgress = true;
					currentPerNum = 0;
					addChild(loadingSquare);
					buildingDone = false;
					GameTimer.getInstance().addUser(this);
					//TweenLite.to(this, buildTime,{ease: Linear.easeNone, currentPerNum:100, onUpdate:setCorrectFrame, onComplete:done});
					return false;
				}
			}
			
			return false;
		}
		
		public function update(_pulse:Boolean):void
		{
			if (HUDView.getInstance().getBalance() > 0 )
			{
				if (currentPerNum < cost)
				{
					HUDView.getInstance().reduceCash(  1 );
					
					var per:int = ((currentPerNum / cost) * 100);
					loadingSquare.currentFrame = per;
					currentPerNum++;
				}
				else
				{
					GameTimer.getInstance().removeUser(this);
					done();
				}
			}
			
		}
		
		
		public function disable():void
		{
			this.touchable = false;
			this.alpha = 0.6;
		}
		
		public function enable():void
		{
			this.touchable = true;
			this.alpha = 1;
			buildInProgress = false;
			loadingSquare.removeFromParent();
			if(readyTXT)readyTXT.visible = false;
		}
		
		protected function done():void{
			buildingDone = true;
			if (buildCompleteFunction)
			{
				buildCompleteFunction(assetName);
			}
			
		}
		
		override public function dispose():void
		{
			loadingSquare = null;
			var a:Array = [ mc, costTf, readyTXT ];
			for (var i:int = 0; i < a.length; i++ )
			{
				if (a[i] != null)
				{
					a[i].removeFromParent(true)
					a[i].dispose();
					a[i] = null;
				}
			}
			a = null;
			
			buildInProgress = false;
			buildCompleteFunction = null;
			
			super.dispose();
		}
	}
}