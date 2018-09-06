package com.dynamicTaMaker.views
{
	import com.dynamicTaMaker.utils.GameTimer;
	import flash.geom.Matrix;

	public dynamic class TimelineSprite extends GameSprite
	{
		public var totalFrames:int;
		private var _frames:Object;
		private var currentFrame:int = 0;
		public var looping:Boolean = true;
		private var callback:Function;
		
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
						if (_frames[k].length > totalFrames) {
                        	totalFrames = _frames[k].length;
                    	}
					}
				}
			}
			
		}

		public function play():void
		{
			//innerI = 0;
			GameTimer.getInstance().addUpdateAble(this);
			for (var i:int = 0; i < this.numChildren; i++) {
				var child:GameSprite = this.getChildAt(i) as GameSprite;
				if (child is TimelineSprite) {
					child.play();
				}
			}
			
		}
		
		public function stop():void
		{
			GameTimer.getInstance().removeUpdateAble(this);
			for (var i:int = 0; i < this.numChildren; i++) {
				var child:GameSprite = this.getChildAt(i) as GameSprite;
				if (child is TimelineSprite) {
					child.stop();
				}
			}
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

				if (callback) {
                	callback();
            	}
				
			}
		}

		public function removeStateEndEventListener():void {
        	callback = null;
   		 }

    	public function addStateEndEventListener(func:Function):void {
        	callback = func;
    	}
		
		public function gotoAndStop(frameNum:int):void
		{
			currentFrame = frameNum;
			trace(currentFrame);
			if(_frames != null)
			{
				for(var k:String in _frames)
				{
					if(_frames[k][currentFrame])
					{
						var frame:Object = _frames[k][currentFrame];
						
						if(this[k])
						{
							if (frame.x != undefined) {
                            	this[k].x = frame.x;
							}
							if (frame.y != undefined) {
								this[k].y = frame.y;
							}
							if (frame.alpha != undefined) {
								this[k].alpha = frame.alpha;
							}

							if (frame.scaleX != undefined) {
								//this[k].scaleX = frame.scaleX;
							}
							if (frame.scaleY != undefined) {
								//this[k].scaleY = frame.scaleY;
							}
							if (frame.rotation != undefined) {
								//this[k].rotation = frame.rotation;
							}

							trace(k, currentFrame, frame.alpha);
							
							//this[k].rotation = frame.rotation;
							//this[k].scaleX = frame.scaleX;
							//this[k].scaleY = frame.scaleY;

							var matrix:Object = frame.matrix;
							this[k].transformationMatrix = new Matrix(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);

						}
					}
				}
			}
		}
	}
}