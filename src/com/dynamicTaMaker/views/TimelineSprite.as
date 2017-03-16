package com.dynamicTaMaker.views
{
	import com.dynamicTaMaker.utils.GameTimer;

	public dynamic class TimelineSprite extends GameSprite
	{
		public var totalFrames:int;
		private var _frames:Object;
		private var currentFrame:int = 0;
		public var looping:Boolean = true;
		
		public function TimelineSprite()
		{
			
		}
		
		public function get frames():Object
		{
			return _frames;
		}

		public function set frames(value:Object):void
		{
			_frames = value;
			
			if(_frames != null)
			{
				for(var k:String in _frames)
				{
					if(_frames[k] is Array)
					{
						totalFrames = _frames[k].length;
					}
				}
			}
			
		}

		public function play():void
		{
			//innerI = 0;
			GameTimer.getInstance().addUpdateAble(this);
			
		}
		
		public function stop():void
		{
			GameTimer.getInstance().removeUpdateAble(this);
		}
		
		public function gotoAndPlay(frameNum:int):void
		{
			//trace"playing with " + frameNum);
			currentFrame = frameNum;
			GameTimer.getInstance().removeUpdateAble(this);
			play();
		}
		
		public function update():void
		{
			var childFrames:Array;
			
			gotoAndStop(currentFrame);
			currentFrame++;
			

			if(currentFrame > totalFrames)
			{
				if (looping)
				{
					currentFrame = 0;
				}
				else
				{
					GameTimer.getInstance().removeUpdateAble(this);
				}
				
			}
		}
		
		public function gotoAndStop(frameNum:int):void
		{
			currentFrame = frameNum;
			if(_frames != null)
			{
				for(var k:String in _frames)
				{
					if(_frames[k][currentFrame])
					{
						var frame:Object = _frames[k][currentFrame];
						
						if(this[k])
						{
							this[k].x = frame.x;
							this[k].y = frame.y;
							this[k].alpha = frame.alpha;
							this[k].rotation = frame.rotation;
							this[k].scaleX = frame.scaleX;
							this[k].scaleY = frame.scaleY;
						}
					}
				}
			}
		}
	}
}