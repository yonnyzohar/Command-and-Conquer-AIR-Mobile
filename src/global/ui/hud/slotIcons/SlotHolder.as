package global.ui.hud.slotIcons
{
	import global.GameSounds;
	import global.Parameters;
	import global.ui.hud.HUD;
	import global.utilities.GameTimer;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import states.game.teamsData.TeamObject;
	
	import global.GameAtlas;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	public class SlotHolder extends EventDispatcher
	{
		public static var IDLE:int = 0;
		public static var CLICKED:int = 1;
		public static var BUILD_IN_PROGRESS:int = 2;
		public static var BUILD_DONE:int = 3;
		
		public var currentBuildState:int = 0;
		
		
		protected var loadingSquare:MovieClip;
		protected var mc:Image;
		public var assetName:String;
		
		private var buildTime:int;
		public var cost:int;
		public var currentPerNum:int = 0;
		protected var buildCompleteFunction:Function;
		public var contextType:String; //units or buildings
		
		protected var readyTXT:TextField;
		protected var costTf:TextField;
		
		public var disabledSlots:Array;
		
		private var costBg:Quad;
		private var bgQuad:Quad;
		protected var teamObj:TeamObject;
		private var showUI:Boolean;
		
		public var view:Sprite;
		private var count:int = 0;
		
		
		public function SlotHolder(_assetName:String, _contextType:String, _teamObj:TeamObject = null, _showUI:Boolean = true )
		{
			assetName = _assetName;
			currentBuildState = SlotHolder.IDLE;
			
			showUI = _showUI;
			teamObj = _teamObj;
			contextType = _contextType;
			
			if (showUI)
			{
				view = new Sprite();
				var w:int = 64;
				var h:int = 48;

				var textureName:String = "icons_"+assetName;
				var tex:Texture = GameAtlas.getTexture(textureName);
				if (tex)
				{
					mc = new Image(tex);
					view.addChild(mc);
					mc.touchable = false;
					w = mc.width;
					h = mc.height;
				}
			
				
				
				bgQuad = new Quad(w, h);
				bgQuad.touchable = true;
				view.addChildAt(bgQuad, 0);
				
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
					view.addChild(readyTXT);
					readyTXT.touchable = false;
					readyTXT.x = (w - readyTXT.width) / 2;
					readyTXT.y = (h - readyTXT.height) / 2;
					readyTXT.visible = false;
				}
				
				view.addEventListener(TouchEvent.TOUCH, onSlotClicked);
			}
			
			
		}
		
		public function freeze():void
		{
			if (view)
			{
				view.removeEventListener(TouchEvent.TOUCH, onSlotClicked);
			}
		}
		
		public function resume():void
		{
			if (view)
			{
				view.addEventListener(TouchEvent.TOUCH, onSlotClicked);
			}
		}
		
		private function onSlotClicked(e:TouchEvent):void 
		{
			var begin:Touch  = e.getTouch(view, TouchPhase.BEGAN);
			
			if(begin)
			{
				
				if (currentBuildState != SlotHolder.BUILD_DONE && currentBuildState != SlotHolder.BUILD_IN_PROGRESS)
				{
					if (!Parameters.editMode)
					{
						if (teamObj.cashManager.cash - cost >= 0)
						{
							GameSounds.playSound("building", "vo");
						}
					}
					
					
				}
				simulateClickOnBuild();
				e.stopPropagation();
			}
		}
		
		public function simulateClickOnBuild():void 
		{
			var currentUnitType:String;
				
			if(this is UnitSlotHolder)
			{
				currentUnitType = "unit";
			}
			else
			{
				currentUnitType = "building";
			}
			
			dispatchEventWith("SLOT_SELECTED", false, { selectedSlot : this, currentUnit :getUnit(), currentUnitName: assetName, currentUnitType: currentUnitType } );
				
		}
		
		public function getUnit():String
		{
			return assetName;
		}
		
		public function setup(assetDetails:Object):void
		{
			buildTime = assetDetails.cost;// / 100;
			if (buildTime < 1)
			{
				buildTime = 1;
			}
			
			cost = assetDetails.cost;
			
			if (showUI)
			{
				costTf = new TextField(mc.width, 15, cost + "$", "Verdana", 9, 0xffffff, true); //- Starling 1_7;
				costBg = new Quad(mc.width * 0.8, 15, 0x000000);
				costBg.alpha = 0.7;
				costTf.hAlign = "left";
				view.addChild(costBg);
				view.addChild(costTf);
			}
		}
		
		
		
		public function buildMe(_complteFnctn:Function):Boolean
		{
			if(currentBuildState == SlotHolder.BUILD_IN_PROGRESS)
			{
				return true;
			}
			else
			{
				if (showUI) view.addChild(loadingSquare);
				if (buildCompleteFunction == null)
				{
					buildCompleteFunction = _complteFnctn;
				}
				
				currentBuildState = SlotHolder.BUILD_IN_PROGRESS;
				currentPerNum = 0;
				GameTimer.getInstance().addUser(this);
				return false;
				
			}
			
			return false;
		}
		
		public function update(_pulse:Boolean):void
		{
			if (teamObj.cashManager.cash >= 0 )
			{
				count++;
				if (currentPerNum < cost)
				{
					if (teamObj.powerCtrl.POWER_SHORTAGE && (count % 4 != 0))
					{
						return;
					}

					teamObj.reduceCash(  Parameters.CASH_INCREMENT );
					
					var per:int = ((currentPerNum / cost) * 100);
					if (showUI)
					{
						loadingSquare.currentFrame = per;
						if (count % 4 == 0)
						{
							GameSounds.playSound("cash", null, 0.01);
						}
					}
					
					currentPerNum += Parameters.CASH_INCREMENT;
				}
				else
				{
					if (showUI)
					{
						loadingSquare.currentFrame = 100;
					}
					count = 0;
					GameTimer.getInstance().removeUser(this);
					done();
				}
			}
			
		}
		
		public function cancelBuild():void
		{
			count = 0;
			GameTimer.getInstance().removeUser(this);
			currentBuildState = SlotHolder.IDLE;
			removeUi();
		}
		
		protected function removeUi():void
		{
			
		}
		
		public function disable():void
		{
			if (showUI)
			{
				view.touchable = false;
				view.alpha = 0.6;
			}
			
		}
		
		public function enable():void
		{
			if (showUI)
			{
				view.touchable = true;
				view.alpha = 1;
				loadingSquare.removeFromParent();
				if(readyTXT)readyTXT.visible = false;
			}
			currentBuildState = SlotHolder.IDLE;
			
		}
		
		public function forceFinishBuild():void
		{
			done();
		}
		
		protected function done():void
		{
			currentBuildState = SlotHolder.IDLE;
			if (showUI)
			{
				if(this is UnitSlotHolder)
				{
					GameSounds.playSound("unit_ready", "vo");
				}
				else
				{
					GameSounds.playSound("construction_complete", "vo");
				}
			}
			
		}
		
		public function dispose():void
		{
			if (showUI)
			{
				view.removeEventListener(TouchEvent.TOUCH, onSlotClicked);
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
				view.removeFromParent();
				view = null;
			}
			
			if (currentBuildState == SlotHolder.BUILD_IN_PROGRESS)
			{
				dispatchEventWith("BUILD_CANCELLED_ABRUPTLY", {name : assetName});
			}
			
			GameTimer.getInstance().removeUser(this);
			currentBuildState = SlotHolder.IDLE;
			buildCompleteFunction = null;
			disabledSlots = null;
			teamObj = null;
			if (costBg) 
			{
				costBg.removeFromParent();
				costBg.dispose();
			}
			costBg = null;
			if (bgQuad) 
			{
				bgQuad.removeFromParent();
				bgQuad.dispose();
			}
		}
	}
}
