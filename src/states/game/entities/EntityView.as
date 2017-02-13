package states.game.entities
{
	
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	import global.GameAtlas;
	import global.map.Node;
	import global.Parameters;
	import global.pools.PoolsManager;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import states.game.entities.units.UnitModel;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;

	public class EntityView extends Sprite
	{
		protected var blocksArr:Array = [];
		protected var circle:Image;
		public var mc:starling.display.MovieClip;
		public var model:EntityModel;
		public var explosionAnim:MovieClip;
		public var shootAnimPlaying:Boolean = false;
		public var recoilAnimating:Boolean = false;
		public var texturesDict:Dictionary = new Dictionary();
		
		public function EntityView()
		{
			
		}
		
		
		
		public function addHealthBar(_healthBar:HealthBar):void{}
		
		public function traceView(msg:String):void
		{
			/*if(model == null)return;
			if(model.controllingAgent == Agent.HUMAN)
			{
				if(model.isSelected)
				{
					////trace"team: " + model.teamName + " id: " + model.playerID + "frameName: " + frameName + " msg : " + msg)
				}
			}*/
		}
		
		public function drawRange(_prevRow:int, _prevCol:int, _row:int, _col:int):void 
		{
			if(model.stats.weapon && model.stats.weapon.range)
			{
				var node:Node;
				var _shootRange:int = model.stats.weapon.range;
				//trace("_shootRange: " + _shootRange + " _row: " + _row + " _col " + _col)
				
				for (var i:int = -_shootRange; i <= _shootRange; i++ )
				{
					for (var j:int = -_shootRange; j <= _shootRange; j++ )
					{
						if (Parameters.boardArr[_prevRow + i] && Parameters.boardArr[_prevRow + i][_prevCol + j])
						{
							node = Node(Parameters.boardArr[_prevRow + i][_prevCol + j]);
							if (node.groundTile)
							{
								node.groundTile.alpha = 1;
							}
						}
					}
				}
				
				
				for (i = -_shootRange; i <= _shootRange; i++ )
				{
					for (j = -_shootRange; j <= _shootRange; j++ )
					{
						if (Parameters.boardArr[_row + i] && Parameters.boardArr[_row + i][_col + j])
						{
							node = Node(Parameters.boardArr[_row + i][_col + j]);
							if (node.groundTile)
							{
								node.groundTile.alpha = 0.5;
							}
						}
					}
				}
				
				if (Parameters.boardArr[_row] && Parameters.boardArr[_row][_col])
				{
					node = Node(Parameters.boardArr[_row][_col]);
					if (node.groundTile)
					{
						node.groundTile.alpha = 0.1;
					}
				}
			}
		}
		
		public function addCircle(_firstMember:Boolean):void
		{
			var addCircle:Boolean = false;
			
			if(circle == null)
			{
				addCircle = true;
			}
			else
			{
				if(!contains(circle))
				{
					addCircle = true;
				}
			}
			
			if(addCircle)
			{
				circle = PoolsManager.selectorCirclesPool.getAsset();
				circle.y =  -model.stats.pixelOffsetY;
				addChildAt(circle, 0);
			}
		}
		
		override public function dispose():void
		{
			if (mc is MovieClip) Starling.juggler.remove(MovieClip(mc));
			mc.visible = false;
			mc.removeFromParent();
			mc = null;
			if(circle != null)circle.removeFromParent();
		}
		
		public function setViewByHealth(healthScale:Number):void 
		{
			
		}
		
		public function shoot(enemy:GameEntity, eRow:int, eCol:int):void
		{
			/*traceView("animate shoot");
			state = "_fire";

			mc.removeEventListener(Event.COMPLETE, onShootAnimComplte);
			mc.addEventListener(Event.COMPLETE, onShootAnimComplte);
			shootAnimPlaying = true;
			mc.loop = false;// model.unitStats.loopShootAnim;
			
			
			var targetObj:Object = Methods.getTargetLocation(enemy);
			
			setDirection(model.row, model.col,eRow, eCol, targetObj);
			animatelayer();*/

		}
		
		public function recoil(enemy:GameEntity):void
		{
			var middleEnemyX:int = enemy.view.x + (enemy.view.width/2);
			var middleEnemyY:int = enemy.view.y + (enemy.view.height/4);
			animateRecoil(middleEnemyX, middleEnemyY);
			
		}
		
		protected function animateRecoil(destX:int, destY:int ):void
		{
			if(recoilAnimating)return;
			var dx:Number = destX - x;
			var dy:Number = destY - y;
			var angle:Number = Math.atan2(dy, dx);
			
			var speed:Number = 0;
			
			if (model is UnitModel)
			{
				speed =  UnitModel(model).stats.speed;
			}
			
			if (speed <= 0)
			{
				speed = 0.5;
			}
			
			var origX:int = x;
			var origY:int = y;
			
			var recoilX:Number = x - vx;
			var recoilY:Number = y - vy;
			
			var vx:Number = Math.cos(angle) *speed;
			var vy:Number = Math.sin(angle) * speed;
			
			if(isNaN(angle))
			{
				x = origX;
				y = origY;
				recoilAnimating = false;
			}
			else
			{
				recoilAnimating = true;
				x -= vx;
				y -= vy;
				setTimeout(function():void{recoilAnimating = false; x = origX; y = origY; },100);
			}
		}
		
	}
}