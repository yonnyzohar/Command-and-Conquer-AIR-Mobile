package states.game.entities.buildings
{
	import global.GameAtlas;
	import global.Parameters;
	import global.utilities.GameTimer;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.textures.SubTexture;
	import starling.utils.Color;
	import states.game.entities.EntityModel;
	
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

		
		
		public function BuildingView(_model:EntityModel,_name:String)
		{
			filterWhite.tint(0xFFFFFF, 1);
			model = _model;
			currentState = _name + state;
			
			mc = GameAtlas.createMovieClip(currentState, model.teamName);
			mc.scaleX = mc.scaleY = Parameters.gameScale;
			mc.addEventListener(Event.COMPLETE, onBuildAnimComplete)
			mc.loop = true;
			Starling.juggler.add(mc);
			addChild(mc);
		}
		
		protected function onBuildAnimComplete(e:Event):void 
		{
			mc.removeEventListener(Event.COMPLETE, onBuildAnimComplete);
			state = "";
			setViewByHealth(1);
		}
		
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
		
		override public function addHealthBar(_healthBar:HealthBar):void
		{
			addChild(_healthBar);
			//_healthBar.visible = false;
		}
		
		override public function setViewByHealth(healthScale:Number):void 
		{
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
			
			healthAnim = healthAnim.toLowerCase()
			
			playState();
		}
		
		
		
		public function playState():void 
		{
			var newStateName:String = model.stats.name + state + healthAnim;
			////trace("newStateName " + newStateName)
			
			if (currentState != newStateName)
			{
				while(mc.numFrames > 1)
				{
					mc.removeFrameAt(0);
				}
				
				var textures:Vector.<Texture> = GameAtlas.getTextures(newStateName, this.model.teamName);
				
				if (textures == null || textures.length == 0)
				{
					state = "";
					mc.loop = true;
					newStateName = model.stats.name + (healthAnim.toLowerCase());
					textures = GameAtlas.getTextures(newStateName, this.model.teamName);
				}
			
				for each (var texture:SubTexture in textures)
				{
					mc.addFrame(texture);
				}
				
				
				if(mc.numFrames != 1)mc.removeFrameAt(0);
				
			}
			
			playMC();
			currentState = newStateName;
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
				explosionAnim = GameAtlas.createMovieClip("fball1");
				explosionAnim.loop = false;
				explosionAnim.touchable = false;
				explosionAnim.addEventListener(Event.COMPLETE, onExplosionComplte);
				explosionAnim.scaleX = explosionAnim.scaleY = Parameters.gameScale;
				Parameters.mapHolder.addChild(explosionAnim);
				Starling.juggler.add(explosionAnim);
				explosionAnim.x = x;// + (width / 2);
				explosionAnim.y = y;// + (height / 2);
			}
		}
		
		
		
		private function onExplosionComplte(e:Event):void 
		{
			Starling.juggler.remove(explosionAnim);
			explosionAnim.removeFromParent(true)
			explosionAnim.removeEventListener(Event.COMPLETE, onExplosionComplte);
			dispatchEvent(new Event("EXPLOSION_COMPLETE"))
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
	}
}