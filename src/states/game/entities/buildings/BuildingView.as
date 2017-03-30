package states.game.entities.buildings
{
	import global.GameAtlas;
	import global.GameSounds;
	import global.Methods;
	import global.map.mapTypes.Board;
	import global.Parameters;
	import global.utilities.GameTimer;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.textures.SubTexture;
	import starling.utils.Color;
	import states.game.entities.EntityModel;
	import states.game.stats.BuildingsStatsObj;
	
	import starling.display.Image;
	import starling.filters.ColorMatrixFilter;
	import starling.textures.Texture;
	import states.game.entities.HealthBar;
	import states.game.entities.EntityView;

	public class BuildingView extends EntityView
	{
		public var state:String = "_build";
		private var healthAnim:String = "_healthy";
		private var texture:Texture;
		private var currentState:String;
		private static var filterWhite:ColorMatrixFilter = new ColorMatrixFilter();
		private var baseIMG:Image;
		
		
		public function BuildingView(_model:EntityModel,_name:String)
		{
			filterWhite.tint(0xFFFFFF, 1);
			model = _model;
			currentState = _name + state;
			
			mc = GameAtlas.createMovieClip(currentState, model.teamColor);
			mc.scaleX = mc.scaleY = Parameters.gameScale;
			mc.addEventListener(Event.COMPLETE, onBuildAnimComplete)
			mc.loop = true;
			Starling.juggler.add(mc);
			addChild(mc);
		}
		
		public function skipBuild():void 
		{
			onBuildAnimComplete();
		}
		
		protected function onBuildAnimComplete(e:Event = null):void 
		{
			mc.removeEventListener(Event.COMPLETE, onBuildAnimComplete);
			state = "";
			setViewByHealth(1);
			addBaseImage();
			
		}
		
		private function addBaseImage():void 
		{
			if (BuildingsStatsObj(model.stats).hasBaseIMG)
			{
				if (baseIMG == null)
				{
					baseIMG = new Image(GameAtlas.getTexture(model.stats.name +"-base"+ healthAnim + "00", model.teamColor));
					baseIMG.scaleX = baseIMG.scaleY = Parameters.gameScale;
					addChildAt(baseIMG, 0);
				}
			}
		}
		
		
		
		override public function addHealthBar(_healthBar:HealthBar):void
		{
			addChild(_healthBar);
			//_healthBar.visible = false;
		}
		
		override public function setViewByHealth(healthScale:Number):void 
		{
			var prevAnim:String = healthAnim;
			if (healthScale > .5) 
			{
				healthAnim = "_healthy"
			} 
			else if (healthScale > .25) {
				healthAnim = "_damaged"
			} 
			else if (healthScale > .05) {
				healthAnim = "_ultra-damaged"
			} 
			else 
			{
				healthAnim = "_dead"
			}
			
			if (prevAnim == "_healthy" && healthAnim == "_damaged")
			{
				
			}
			
			if (prevAnim == "_damaged" && healthAnim == "_ultra-damaged")
			{
				GameSounds.playSound("building_damadged");
			}
			
			healthAnim = healthAnim.toLowerCase()
			
			playState();
		}
		
		
		
		public function playState():void 
		{
			var newStateName:String = model.stats.name + state + healthAnim;
			
			if (currentState != newStateName)
			{
				while(mc.numFrames > 1)
				{
					mc.removeFrameAt(0);
				}
				
				var textures:Vector.<Texture> = GameAtlas.getTextures(newStateName, this.model.teamColor);
				
				if (textures == null || textures.length == 0)
				{
					state = "";
					mc.loop = true;
					newStateName = model.stats.name + (healthAnim.toLowerCase());
					textures = GameAtlas.getTextures(newStateName, this.model.teamColor);
				}
			
				for each (var texture:SubTexture in textures)
				{
					mc.addFrame(texture);
				}
				
				
				if (mc.numFrames != 1) mc.removeFrameAt(0);
				
				playMC();
				currentState = newStateName;
				
			}
			//trace("currentState " + currentState + " newStateName " + newStateName);
		}
		
		public function playSellAnimation():void
		{
			var sellState:String = model.stats.name + "_build";
			
			while(mc.numFrames > 1)
			{
				mc.removeFrameAt(0);
			}
			
			var textures:Vector.<Texture> = GameAtlas.getTextures(sellState, this.model.teamColor);
			textures.reverse();
			
			
			for each (var texture:SubTexture in textures)
			{
				mc.addFrame(texture);
			}
			
			if (mc.numFrames != 1) mc.removeFrameAt(0);
			mc.loop = false;
			mc.addEventListener(Event.COMPLETE, onSellAnimComplete);
			if (baseIMG)
			{
				baseIMG.removeFromParent();
			}
			baseIMG = null;
			playMC();	
			
		}
		
		private function onSellAnimComplete(e:Event):void 
		{
			mc.removeEventListener(Event.COMPLETE, onSellAnimComplete);
			dispatchEvent(new Event("SELL_ANIM_COMPLETE"));
		}
		
		protected function playMC():void
		{
			mc.currentFrame = 0;
			mc.play();
		}
		
		public function playExplosion():void
		{
			if (explosionAnim == null)
			{
				mc.visible = false;
				
				if (!Methods.isOnScreen(model.row, model.col))
				{
					return;
				}
				
				if (visible == false )
				{
					return;
				}
				
				
				explosionAnim = GameAtlas.createMovieClip("fball1");
				explosionAnim.loop = false;
				explosionAnim.touchable = false;
				explosionAnim.addEventListener(Event.COMPLETE, onExplosionComplte);
				explosionAnim.scaleX = explosionAnim.scaleY = Parameters.gameScale;
				Board.mapContainerArr[Board.UNITS_LAYER].addChild(explosionAnim);
				Starling.juggler.add(explosionAnim);
				explosionAnim.x = x;// + (width / 2);
				explosionAnim.y = y;// + (height / 2);
			}
			if (baseIMG)
			{
				baseIMG.removeFromParent();
			}
			baseIMG = null;
		}
		
		
		
		private function onExplosionComplte(e:Event):void 
		{
			explosionAnim.removeFromParent();
			Starling.juggler.remove(explosionAnim);
			explosionAnim.removeEventListener(Event.COMPLETE, onExplosionComplte);
			explosionAnim = null;
		}
		
		private var flashTotal:int = 50;
		private var flashCurrent:int = 0;
		
		public function highlightBuilding():void
		{
			flashCurrent = 0;
			GameTimer.getInstance().addUser(this);
		}
		
		public function update(_pulse:Boolean):void
		{
		
			if (flashCurrent % 5 == 0)
			{
				if (mc.filter == filterWhite)
				{
					mc.filter = null;
				}
				else
				{
					mc.filter = filterWhite;
				}
			}
			
			
			if (flashCurrent == flashTotal)
			{
				mc.filter = null;
				GameTimer.getInstance().removeUser(this);
			}
			
			flashCurrent++;
		}
		
		override public function addCircle(_firstMember:Boolean):void
		{
			super.addCircle(_firstMember);
			circle.width = mc.width;
			circle.height = mc.height / 2;
			circle.y += mc.height / 2;
		}
		
		//when constructing an asset
		public function setConstructAnimation():void 
		{
			state = "-construct";
			mc.loop = false;
			playState();
			mc.addEventListener(Event.COMPLETE, onConstructAnimComplete);
		}
		
		private function onConstructAnimComplete(e:Event):void
		{
			mc.removeEventListener(Event.COMPLETE, onConstructAnimComplete);
			stopConstructAnimation();
		}
		
		public function stopConstructAnimation():void 
		{
			state = "";
			healthAnim = healthAnim.toLowerCase()
			mc.loop = true;
			playState();
		}
		
		override public function dispose():void
		{
			if (mc)
			{
				mc.removeEventListener(Event.COMPLETE, onConstructAnimComplete);
				mc.removeEventListener(Event.COMPLETE, onSellAnimComplete);
				mc.removeEventListener(Event.COMPLETE, onBuildAnimComplete);
			}
			if (baseIMG)
			{
				baseIMG.removeFromParent();
			}
			baseIMG = null;
			if (explosionAnim)
			{
				explosionAnim.removeEventListener(Event.COMPLETE, onExplosionComplte);
				
				if (explosionAnim.isPlaying == false)
				{
					explosionAnim.removeFromParent();
					explosionAnim = null;
				}
			}
			
			
			super.dispose();
		}
	}
}