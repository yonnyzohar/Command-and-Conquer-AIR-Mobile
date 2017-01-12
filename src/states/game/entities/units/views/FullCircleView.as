package states.game.entities.units.views
{
	
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import global.enums.UnitStates;
	import global.Methods;
	import global.utilities.GameTimer;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.MovieClip;
	import starling.events.Event;
	import states.game.entities.EntityModel;
	import states.game.entities.GunTurretView;
	import states.game.stats.VehicleStatsObj;
	
	import global.Parameters;
	import global.GameAtlas;
	
	import starling.animation.Tween;
	import starling.display.Image;
	import starling.filters.ColorMatrixFilter;
	import starling.textures.Texture;
	
	import states.game.entities.units.UnitModel;
	
	public class FullCircleView extends UnitView
	{
		public var degrees:Number = 1;
		public var currentFrameNum:int = 8;
		private var tweenPlay:Tween;
		private var endFrame:int = 8;
		private var oldDegrees:int = 45;
		private var tween:TweenLite;
		
		private var rotArr:Array = [];
		private var rotI:Number = 0;
		
		private var divisionValue:int;
		
		private var turretMC:GunTurretView;
		private var turnSpeed:Number;
		
		
		
		public function FullCircleView(_model:EntityModel)
		{
			super(_model);
			swapMCTextures(degrees);
			turnSpeed = VehicleStatsObj(model.stats).turnSpeed;
			rotate();
		}
		
		override public function stand():void
		{
			stopShootingAndStandIdlly();
		}
		
		
		public function addTurret(_turretMC:GunTurretView):void 
		{
			turretMC = _turretMC;
			turretMC.x += ((model.stats.pixelOffsetX*Parameters.gameScale)/2);
			turretMC.y += ((model.stats.pixelOffsetY * Parameters.gameScale) / 2);
			turretMC.currentFrame = 0;
			addChild(turretMC);
		}
		
		protected function createView():void
		{
			if (mc != null) return;
			var defaultTextures:Vector.<Texture>  = GameAtlas.getTextures(model.stats.name+"_move", model.teamName);
			texturesDict["default"] = defaultTextures;
			mc = new MovieClip(defaultTextures, 10);// GameAtlas.createMovieClip(model.stats.name+"_move", model.teamName);
			mc.scaleX = mc.scaleY = Parameters.gameScale;
			mc.x += ((model.stats.pixelOffsetX*Parameters.gameScale)/2);
			mc.y += ((model.stats.pixelOffsetY*Parameters.gameScale)/2);
			mc.touchable = false;
			mc.currentFrame = currentFrameNum;
			addChild(mc);
		}
		
		override public function setDirection(curRow:int, curCol:int, destRow:int, destCol:int, targetObj:Object = null):void
		{
			if(curRow == destRow && curCol == destCol)return;
			if( UnitModel(model).rotating)return;
			
			var destRowY:int = destRow * Parameters.tileSize;
			var destColX:int = destCol * Parameters.tileSize;
			var myX:Number = x;
			var myY:Number = y;
			
			if (targetObj)
			{
				destColX = targetObj.targetX;
				destRowY = targetObj.targetY;
				myX = x + mc.x;
				myY = y + mc.y;
			}
			
			////////////////////////
			//degrees = Math.atan2( curRow -  destRow,  curCol - destCol) / Math.PI * 180;
			degrees = Math.atan2( myY -  destRowY,  myX - destColX) / Math.PI * 180;
			
			while ( degrees >= 360 )
			{
				degrees -= 360;
			}
			while ( degrees < 0 )
			{
				degrees += 360;
			}
			
			
			degrees = Math.ceil(degrees);
			
			////trace(degrees);

			//taking this out of the if statement solved the animation bug...
			swapMCTextures(degrees);
			rotate();
			oldDegrees = degrees;

		}
		
		private function swapMCTextures(_degrees:int):void
		{
			if(mc != null &&  UnitModel(model).rotating == false)
			{
				 UnitModel(model).rotating = true;
				// //trace("_degrees, oldDegrees " + _degrees, oldDegrees)
				endFrame = Methods.degreesToFrame(_degrees, oldDegrees);
			}
			else
			{
				createView();
			}
		}
		
		private var framesToPlay:Number;

		private function rotate():void 
		{
			if (currentFrameNum == endFrame)
			{
				UnitModel(model).rotating = false;
				return;
			}
			rotArr = Methods.getShortestPath(currentFrameNum, endFrame);
			////trace("rotArr " + rotArr)
			rotI = 0;
			
			framesToPlay = rotArr.length;
			GameTimer.getInstance().addUser(this);

		}
		
		public function stopRotation():void
		{
			GameTimer.getInstance().removeUser(this);
			rotArr = [];
			UnitModel(model).rotating = false;
		}
		
		public function update(_pulse:Boolean):void
		{
			if (rotI < framesToPlay)
			{
				updateView();
			}
			else
			{
				GameTimer.getInstance().removeUser(this);
				doneRotate(endFrame);
			}
		}
		
		private function updateView():void
		{
			if(mc == null)
			{
				GameTimer.getInstance().removeUser(this);
				return;
			}
			
			if(mc != null && rotArr.length != 0)
			{
				if (rotI < rotArr.length )
				{
					//if rot is a whole number
					if ( int(rotI) === rotI )
					{
						if (turretMC)
						{
							if (model.currentState == UnitStates.SHOOT)
							{
								turretMC.currentFrame = rotArr[rotI]
							}
							else
							{
								turretMC.currentFrame = rotArr[rotI]
								mc.currentFrame = rotArr[rotI]
							}
						}
						else
						{
							mc.currentFrame = rotArr[rotI]
						}
					}
					
					
					
					rotI += turnSpeed;
				}
				else
				{
					////trace("REACHED THE END OF THE ROTATION")
				}
			}
			else
			{
				UnitModel(model).rotating = false;
			}
		}
		
		private function doneRotate(endFrame:int):void
		{
			////trace("doneRotate: currentFrameNum = " + currentFrameNum + " endFrame: " + endFrame);
			currentFrameNum = endFrame;
			rotI = rotArr.length - 1;
			if (rotArr.length != 0)
			{
				if (turretMC) 
				{
					if (model.currentState == UnitStates.SHOOT)
					{
						turretMC.currentFrame = endFrame
					}
					else
					{
						turretMC.currentFrame = endFrame
						mc.currentFrame = endFrame
					}
				}
				else
				{
					if(mc)mc.currentFrame = endFrame
				}
			}
			
			 UnitModel(model).rotating = false;
		}
		
		
		
		
		
		override public function dispose():void
		{
			super.dispose();
			if (turretMC)
			{
				turretMC.removeFromParent();
				turretMC = null;
			}
		}
		
		public function playExplosion(deathAnimation:String):void 
		{
			var explosionMC:MovieClip = GameAtlas.createMovieClip(deathAnimation);
			explosionMC.touchable = false;
			Parameters.mapHolder.addChild(explosionMC);
			explosionMC.scaleX = explosionMC.scaleY = Parameters.gameScale;
			explosionMC.x = x; 
			explosionMC.y = y;
			Starling.juggler.add(explosionMC);
			explosionMC.addEventListener(Event.COMPLETE, onExplosionComplete);
			explosionMC.play();
		}
		
		private function onExplosionComplete(e:Event):void
		{
			var explosionMC:MovieClip = MovieClip(e.currentTarget)
			Starling.juggler.remove(explosionMC);
			explosionMC.removeEventListener(Event.COMPLETE, onExplosionComplete);
			Parameters.mapHolder.removeChild(explosionMC);
		}
		
		
	}
}