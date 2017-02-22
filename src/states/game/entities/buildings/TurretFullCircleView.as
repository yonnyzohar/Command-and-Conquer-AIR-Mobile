package states.game.entities.buildings
{
	import global.enums.UnitStates;
	import global.GameAtlas;
	import global.Methods;
	import global.Parameters;
	import global.utilities.GameTimer;
	import starling.core.Starling;
	import starling.events.Event;
	import states.game.entities.EntityModel;
	import states.game.entities.GameEntity;
	import states.game.stats.TurretStatsObj;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class TurretFullCircleView extends BuildingView
	{
		public var degrees:Number = 1;
		public var currentFrameNum:int = 8;
		private var endFrame:int = 8;
		private var oldDegrees:int = 45;
		private var framesToPlay:Number;
		private var rotArr:Array = [];
		private var rotI:Number = 0;
		
		private var divisionValue:int;
		
		private var turnSpeed:Number;
		
		public function TurretFullCircleView(_model:EntityModel)
		{
			super(_model, _model.stats.name);
			swapMCTextures(degrees);
			turnSpeed = TurretStatsObj(model.stats).turnSpeed;
			if (turnSpeed == 0)
			{
				turnSpeed = 0.5;
			}
			rotate();
		}
		
		
		
		override public function shoot(enemy:GameEntity, eRow:int, eCol:int):void
		{
			var targetObj:Object = Methods.getTargetLocation(enemy);
			
			////trace("turret shoot")
			setDirection(model.row, model.col,eRow, eCol, targetObj);

		}
		

		
		public function setDirection(curRow:int, curCol:int, destRow:int, destCol:int, targetObj:Object = null):void
		{
			
			if(curRow == destRow && curCol == destCol)return;
			if( TurretModel(model).rotating)return;
			
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
			swapMCTextures(degrees);
			rotate();
			oldDegrees = degrees;

		}
		
		private function swapMCTextures(_degrees:int):void
		{
			if(mc != null &&  TurretModel(model).rotating == false && oldDegrees != degrees)
			{
				TurretModel(model).rotating = true;
				
			}
			endFrame = Methods.degreesToFrame(_degrees, oldDegrees);
		}
		
		override protected function onBuildAnimComplete(e:Event):void 
		{
			super.onBuildAnimComplete(e);
			Starling.juggler.remove(mc);
			mc.stop();
		}
		
		override protected function playMC():void
		{
			return;
			
		}
		

		private function rotate():void 
		{
			if (currentFrameNum == endFrame)
			{
				TurretModel(model).rotating = false;
				doneRotate(endFrame);
				return;
			}
			else {
				rotArr = Methods.getShortestPath(currentFrameNum, endFrame);
				rotI = 0;
				framesToPlay = rotArr.length;
				////trace("framesToPlay " + framesToPlay)
				GameTimer.getInstance().addUser(this);
			}
			

		}
		
		override public function setViewByHealth(healthScale:Number):void 
		{
			if (TurretModel(model).rotating)
			{
				GameTimer.getInstance().removeUser(this);
				doneRotate(endFrame);
			}
			
			super.setViewByHealth(healthScale)
		}
		
		
		override public function update(_pulse:Boolean):void
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
					if ( int(rotI) == rotI && rotArr[rotI])
					{
						try {
							mc.currentFrame = rotArr[rotI]
						}
						catch (e:Error)
						{
							//trace(e.message)
						}
						
					}
					////trace(rotI + " / " + rotArr.length)
					rotI += turnSpeed;
				}
				else
				{
					doneRotate(endFrame);
				}
			}
			else
			{
				doneRotate(endFrame);
			}
		}
		
		private function doneRotate(endFrame:int):void
		{
			////trace("doneRotate: currentFrameNum = " + currentFrameNum + " endFrame: " + endFrame);
			currentFrameNum = endFrame;
			
			if (mc && endFrame <= mc.numFrames)
			{
				mc.currentFrame = endFrame
			}
			GameTimer.getInstance().removeUser(this);
			
			TurretModel(model).rotating = false;
			if (model.currentState == UnitStates.SHOOT)
			{
				 dispatchEvent(new starling.events.Event("DONE_ROTATING"))
			}
		}
		
				
		
		
		override public function dispose():void
		{
			GameTimer.getInstance().removeUser(this);
			super.dispose();
		}
		
	}

}