package com.dynamicTaMaker.views
{
	import com.greensock.TweenLite;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.TextureAtlas;

	public dynamic class GameButton extends GameSprite 
	{
		public var textBox:TextField;
		private var labelStr:String;
		private var origScaleX:Number;
		private var origScaleY:Number;
		private var canTouch:Boolean = true;
		
		
		public function GameButton(_labelStr:String = "")
		{
			addEventListener(TouchEvent.TOUCH, btnClickBehaviour);
		}
		
		private function btnClickBehaviour(e:TouchEvent):void 
		{
			var touch:Touch = e.getTouch(this, TouchPhase.ENDED);
			
			if (touch && canTouch)
			{
				canTouch = false;
				origScaleX = this.scaleX;
				origScaleY = this.scaleY;
				TweenLite.to(this, 0.15, {scaleX:origScaleX*0.9, scaleY:origScaleY*0.9, onComplete:tweenBack}) 
			}
		}
		
		private function tweenBack():void 
		{
			
			TweenLite.to(this, 0.15, {scaleX:origScaleX, scaleY:origScaleY, onComplete:animDone}) 
		}
		
		private function animDone():void
		{
			canTouch = true;
		}
		
	}
	
}