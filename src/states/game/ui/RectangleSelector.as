package states.game.ui
{
	import flash.geom.Point;
	import starling.display.Quad;
	
	import global.Parameters;
	import global.pools.Pool;
	
	import starling.display.Image;
	import starling.display.Shape;
	
	import states.game.entities.units.Unit;

	public class RectangleSelector extends Quad
	{
		private var startX:int;
		private var startY:int;
		private var moveX:int;
		private var moveY:int;
		public  var unitsArray:Array = [];
		
		public function RectangleSelector()
		{
			super(10, 10, 0x1fc43a)
			alpha = 0.3;
		}
		
		public function beginDrawing(_startX:Number, _startY:Number):void
		{
			moveX = 0;
			moveY = 0;
			startX = _startX;
			startY = _startY;

			draw();
		}
		
		public function stopDrawing(click:Boolean):void
		{
			if(!click)
			{
				unitsArray.splice(0);
			}
			
			checkColission();
			width = 0;
			height = 0;
			//graphics.clear();
		}
		
		private function checkColission():void
		{
			var currentPlayer:Unit;
			var curPoint:Point;
			
			if(Parameters.humanTeam == null)return;
			
			var humanTeamLength:int = Parameters.humanTeam.length;
			
			for(var i:int = humanTeamLength-1; i >= 0; i--)
			{
				if(Parameters.humanTeam[i] is Unit)
				{
					currentPlayer = Unit(Parameters.humanTeam[i]);
				
					curPoint = new Point(currentPlayer.view.x, currentPlayer.view.y);
					
					if(bounds.containsPoint(curPoint))
					{
						//trace"yo!");
						unitsArray.push(currentPlayer);
					}
				}
			}
		}
		
		private function draw():void
		{
			if (width != moveX)
			{
				width = moveX;
			}
			if (height != moveY)
			{
				height = moveY;
			}

			/*graphics.clear();
			graphics.beginFill(0x000000, 0);
			graphics.lineStyle(3, 0x1fc43a, 1);
			graphics.drawRect(0, 0, moveX, moveY);
			graphics.endFill();*/
		}
		
		public function move(_moveX:int, _moveY:int):void
		{
			moveX = _moveX;
			moveY = _moveY;
			
			moveX = moveX - startX;
			moveY = moveY - startY;

			draw();
			
		}
	}
}