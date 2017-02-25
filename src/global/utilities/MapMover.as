package global.utilities
{
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	import global.enums.MouseStates;
	import global.GameAtlas;
	import global.map.mapTypes.Board;
	import global.map.Node;
	import global.Parameters;
	import global.ui.hud.HUD;
	import global.ui.hud.MiniMap;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.RenderTexture;
	import states.game.entities.EntityView;
	import states.game.entities.GameEntity;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import states.game.ui.UnitSelectionManager;
	;
	
	public class MapMover
	{
		
		private var stageHeight:int;
		private var stageWidth:int;
		
		private var startX:int;
		private var startY:int;
		private var gameWidth:int;
		private var gameHeight:int;
		
		private var prevRow:int = -1;
		private var prevCol:int = -1;
		private var firstTime:Boolean = true;
		private var ease:int = 8;
		
		
		
		private static var FLATTEN_SCREEN:Boolean = false;
		static private var instance:MapMover = new MapMover();
		
		private var lastX:int = 0;
		private var lastY:int = 0;
		private var diffX:Number = 0;
		private var diffY:Number = 0;
		private var myTimeout:int;
		private var startDragX:int = 0;
		private var startDragY:int = 0;
		
		private static var sHelperPoint:Point = new Point();
		private static var sHelperPoint2:Point = new Point();
		private static var sHelperPoint3:Point = new Point();
		private var easeMe:Boolean = false;
		
		
		public function MapMover()
		{
			if (instance)
			{
				throw new Error("Singleton and can only be accessed through Singleton.getInstance()");
			}
		}
		
		public static function getInstance():MapMover
		{
			return instance;
		}
		
		public function init():void
		{
			KeyboardController.getInstance().init();
			stageHeight = Parameters.theStage.stageHeight;
			stageWidth = Parameters.theStage.stageWidth;
			
			gameWidth = Parameters.mapWidth; // * Parameters.gameScale;
			gameHeight = Parameters.mapHeight; // * Parameters.gameScale;
			Parameters.theStage.addEventListener(TouchEvent.TOUCH, onStageTouch);
		}
		
		public function freeze():void
		{
			Parameters.theStage.removeEventListener(TouchEvent.TOUCH, onStageTouch);
		}
		public function resume():void
		{
			Parameters.theStage.addEventListener(TouchEvent.TOUCH, onStageTouch);
		}
		
		/////////////////////////
		
		
		
		
		private function onStageTouch(e:TouchEvent):void
		{
			if (MouseStates.currentState != MouseStates.REG_PLAY || Parameters.editMode)
				return;
			var checkStart:Touch = e.getTouch(Parameters.theStage, TouchPhase.BEGAN);
			if (checkStart)
			{
				var p:Point = checkStart.getLocation(Parameters.theStage);
				
				if (p.x >= (stageWidth - HUD.hudWidth))
				{
					return;
				}
			}
			
			var checkMove:Touch = e.getTouch(Parameters.theStage, TouchPhase.MOVED);
			
			if (checkMove)
			{
			
				p = checkMove.getLocation(Parameters.theStage);
		
				if (p.x >= (stageWidth - HUD.hudWidth))
				{
					return;
				}
			}
			
			//var moving:Touch = e.getTouch(this, TouchPhase.MOVED);
			//var end:Touch    = e.getTouch(this, TouchPhase.ENDED);
			var startMulti:Vector.<Touch> = e.getTouches(Parameters.theStage, TouchPhase.BEGAN);
			var movingMulti:Vector.<Touch> = e.getTouches(Parameters.theStage, TouchPhase.MOVED);
			var endMulti:Vector.<Touch> = e.getTouches(Parameters.theStage, TouchPhase.ENDED);
			var location:Point;
			var location2:Point;
			var i:int = 0;
			
			if (startMulti != null && startMulti.length != 0)
			{
				if (startMulti.length > 1)
				{
					return;
				}
				//Parameters.tf.text = "start";
				//Parameters.theStage.addChild(Parameters.tf)
				easeMe = false;
				location = startMulti[0].getLocation(Parameters.mapHolder, sHelperPoint2);
				
				startDragX = location.x;
				startDragY = location.y;
				myTimeout = setTimeout(changeToSelect, 500, location.x, location.y);
				
				
			}
			
			if (movingMulti != null && movingMulti.length != 0)
			{
				if (movingMulti.length > 1)
				{
					return;
				}
				easeMe = false;
				location = movingMulti[0].getLocation(Parameters.mapHolder.parent, sHelperPoint);
				location2 = movingMulti[0].getLocation(Parameters.mapHolder, sHelperPoint3);
				var px:int = (sHelperPoint.x - sHelperPoint2.x);
				var py:int = (sHelperPoint.y - sHelperPoint2.y);
				onPanUpdate(px, py);
				
				if (startDragX != 0 && startDragY != 0)
				{
					var dragDiffX:int = location2.x - startDragX;
					var dragDiffY:int = location2.y - startDragY;
					
					if (Math.abs(dragDiffX) > 50 || Math.abs(dragDiffY) > 50)
					{
						clearTimeout(myTimeout)
						MouseStates.currentState = MouseStates.REG_PLAY;
					}
				}
				
			}
			
			if (endMulti && endMulti.length != 0)
			{
				p = endMulti[0].getLocation(Parameters.theStage);
				
				if (p.x >= (stageWidth - HUD.hudWidth))
				{
					return;
				}
				
				
				diffX = Parameters.mapHolder.x - lastX;
				diffY = Parameters.mapHolder.y - lastY;
				////trace("diffX " + diffX, "diffY " + diffY);
				clearTimeout(myTimeout);
				MouseStates.currentState = MouseStates.REG_PLAY;
				if (diffX != 0 && diffY != 0)
				{
					if (Math.abs(diffX) > 100)
					{
						diffX = 100;
					}
					if (Math.abs(diffY) > 100)
					{
						diffY = 100;
					}
					easeMe = true;
				}
			}
		
		}
		
		private function changeToSelect(_x:int, _y:int):void
		{
			////trace("SELECT")
			MouseStates.currentState = MouseStates.SELECT;
			UnitSelectionManager.getInstance().beginDrawingRectangle(_x, _y);
			
		}
		
		/////////////////////////
		
		public function update(_pulse:Boolean):void
		{
			var changeHappened:Boolean = false;
			
			if (easeMe)
			{
				var newY:Number = Parameters.mapHolder.y + diffY;
				var newX:Number = Parameters.mapHolder.x + diffX;
				onPanUpdate(newX, newY);
				
				diffY *= 0.9;
				diffX *= 0.9;
				
				changeHappened = true;
				
				if (Math.abs(diffX) < 1 && Math.abs(diffY) < 1)
				{
					easeMe = false;
					////trace("STOP EASE!")
				}
				
			}
			
			if (KeyboardController.up)
			{
				changeHappened = true;
				if (Parameters.mapHolder.y < 0)
				{
					Parameters.mapHolder.y += Parameters.mapMoveSpeed;
				}
				
			}
			if (KeyboardController.down)
			{
				changeHappened = true;
				
				if (((Parameters.mapHolder.y) + (Parameters.mapHeight)) >= stageHeight)
				{
					Parameters.mapHolder.y -= Parameters.mapMoveSpeed;
				}
				
			}
			if (KeyboardController.left)
			{
				changeHappened = true;
				if (Parameters.mapHolder.x < 0)
				{
					Parameters.mapHolder.x += Parameters.mapMoveSpeed;
				}
			}
			if (KeyboardController.right)
			{
				changeHappened = true;
				
				if (((Parameters.mapHolder.x) + (Parameters.mapWidth)) > (stageWidth - HUD.hudWidth))
				{
					Parameters.mapHolder.x -= Parameters.mapMoveSpeed;
				}
			}
			
			render(changeHappened)
			
			if (changeHappened)
			{
				moveMiniMap();
			}
		}
		
		private function moveMiniMap():void
		{
			var screenRow:int = Math.abs(Parameters.mapHolder.y / (Parameters.tileSize /** Parameters.gameScale*/));
			var screenCol:int = Math.abs(Parameters.mapHolder.x / (Parameters.tileSize /** Parameters.gameScale*/));
			var _stageHeight:int = Parameters.flashStage.stageHeight / Parameters.tileSize;
			var _stageWidth:int = (Parameters.flashStage.stageWidth - HUD.hudWidth) / Parameters.tileSize;
			
			MiniMap.getInstance().moveMiniMap(screenRow / (Parameters.numRows - _stageHeight), screenCol / (Parameters.numCols - _stageWidth));
		}
		
		public function render(_changeHappened:Boolean):void
		{
			if (_changeHappened)
				showHideTiles();
			if (Parameters.editMode == false)
			{
				showHideUnits(Parameters.humanTeam);
				showHideUnits(Parameters.pcTeam);
			}
			
		
		}
		
		private function showHideTiles():void
		{
			var n:Node;
			var col:int = 0;
			var row:int = 0;
			var gap:int = 1;
			
			var screenRow:int = Math.abs(Parameters.mapHolder.y / (Parameters.tileSize /** Parameters.gameScale*/));
			var screenCol:int = Math.abs(Parameters.mapHolder.x / (Parameters.tileSize /** Parameters.gameScale*/));
			var _stageWidth:int = (Parameters.flashStage.stageWidth - HUD.hudWidth) / Parameters.tileSize;
			var _stageHeight:int = Parameters.flashStage.stageHeight / Parameters.tileSize;
			var hudTiles:int = HUD.hudWidth / Parameters.tileSize;
			
			Parameters.screenDisplayArea.col = int(screenCol);
			Parameters.screenDisplayArea.row = int(screenRow);
			Parameters.screenDisplayArea.width = _stageWidth;
			Parameters.screenDisplayArea.height = _stageHeight;
			
			if (prevRow == -1 || prevCol == -1)
			{
				
				for (row = screenRow; row <= (_stageHeight + screenRow); row++)
				{
					for (col = screenCol; col <= (_stageWidth + screenCol); col++)
					{
						addTile(row, col);
						
						
					}
				}
				
				if (FLATTEN_SCREEN)
				{
					
					Board.mapContainerArr[Board.GROUND_LAYER].flatten(); // - Starling 1_7;
				}
			}
			else
			{
				if (prevRow != screenRow || prevCol != screenCol)
				{
					if (screenRow > prevRow)
					{
						//remove only the top most row
						for (row = prevRow; row < screenRow; row++)
						{
							for (col = screenCol; col < (_stageWidth + screenCol + hudTiles); col++)
							{
								removeTile(row, col);
							}
						}
						
						//add the bottom most row
						for (row = (_stageHeight + prevRow); row <= (_stageHeight + screenRow + gap); row++)
						{
							for (col = screenCol; col <= (_stageWidth + screenCol + gap); col++)
							{
								addTile(row, col);
							}
						}
					}
					else
					{
						//remove the bottom most row
						for (row = (_stageHeight + prevRow - gap); row > (_stageHeight + screenRow); row--)
						{
							for (col = screenCol; col < (_stageWidth + screenCol + hudTiles); col++)
							{
								removeTile(row, col);
							}
						}
						
						//add the top most
						for (row = prevRow; row >= screenRow; row--)
						{
							for (col = screenCol; col <= (_stageWidth + screenCol + gap); col++)
							{
								addTile(row, col);
							}
						}
					}
					
					if (screenCol > prevCol)
					{
						//remove only left most col
						for (col = prevCol; col < screenCol; col++)
						{
							for (row = screenRow; row < (_stageHeight + screenRow); row++)
							{
								removeTile(row, col);
							}
						}
						
						//add right most col
						for (col = (_stageWidth + prevCol); col <= (_stageWidth + screenCol + gap); col++)
						{
							for (row = screenRow; row <= (_stageHeight + screenRow); row++)
							{
								addTile(row, col);
							}
						}
						
					}
					else
					{
						//prevCol > screenCol
						//remove right most col
						for (col = (_stageWidth + prevCol + gap + hudTiles); col > (_stageWidth + screenCol + gap); col--)
						{
							for (row = screenRow; row <= (_stageHeight + screenRow + gap); row++)
							{
								removeTile(row, col);
							}
						}
						
						//add left most col
						for (col = prevCol; col >= screenCol; col--)
						{
							for (row = screenRow; row <= (_stageHeight + screenRow + gap); row++)
							{
								addTile(row, col);
							}
						}
					}
					
					if (FLATTEN_SCREEN)
					{
						
						Board.mapContainerArr[Board.GROUND_LAYER].flatten() // - Starling 1_7;
					}
					
				}
			}
			
			prevRow = screenRow;
			prevCol = screenCol;
		}
		
		private function removeTile(row:int, col:int):void 
		{
			if (Parameters.boardArr[row] && Parameters.boardArr[row][col])
			{
				var n:Node = Node(Parameters.boardArr[row][col]);

					if (Board.drawType == Board.DRAW_TYPE_ONLY_CENTER)
					{
						if (n.obstacleTile)
						{
							n.obstacleTile.removeFromParent();
						}
						
						if (n.shoreTile)
						{
							//n.shoreTile.removeFromParent();
						}
						
						if (n.groundTile)
						{
							n.groundTile.removeFromParent();
						}
					}
			}
		}
		
		private function addTile(row:int, col:int):void 
		{
			if (Parameters.boardArr[row] && Parameters.boardArr[row][col])
			{
				var n:Node = Node(Parameters.boardArr[row][col]);
				

				if (Board.drawType == Board.DRAW_TYPE_ONLY_CENTER)
				{
					if (n.groundTile)
					{
						Board.mapContainerArr[Board.GROUND_LAYER].addChild(n.groundTile);
					}
					if (n.obstacleTile)
					{
						Board.mapContainerArr[Board.OBSTACLE_LAYER].addChild(n.obstacleTile);
						
					}
					if (n.shoreTile && n.seen)
					{
						Board.mapContainerArr[Board.OBSTACLE_LAYER].addChildAt(n.shoreTile,0);
					}
					
					if (n.cliffTile && n.seen)
					{
						Board.mapContainerArr[Board.OBSTACLE_LAYER].addChildAt(n.cliffTile,0);
					}
				}
			}
		}
		
		private function showHideUnits(team:Array):void
		{
			var i:int = 0;
			
			
			var l:int = team.length;
			for (i = 0; i < l; i++)
			{
				var ent:GameEntity = team[i];
				var entView:EntityView = ent.view;
				if (entView)
				{
					var entViewAbsY:int = entView.y + Parameters.mapHolder.y;
					var entViewAbsX:int = entView.x + Parameters.mapHolder.x;
					
					if (entViewAbsY > (Parameters.flashStage.stageHeight - Parameters.tileSize) || (entViewAbsY + entView.height) < 0 || (entViewAbsX + entView.width) < 0 || entViewAbsX > (Parameters.flashStage.stageWidth - HUD.hudWidth - Parameters.tileSize))
					{
						if (entView.parent)entView.removeFromParent();
							
					}
					else
					{
						if (entView.parent == null)
						{
							Board.mapContainerArr[Board.UNITS_LAYER].addChild(entView);
						}
						
					}
				}
			}
		}
		
		public function onPanUpdate(x:Number, y:Number):void
		{
			lastX = Parameters.mapHolder.x;
			lastY = Parameters.mapHolder.y;
			//easeMe = false;
			
			Parameters.mapHolder.x = x;
			Parameters.mapHolder.y = y;
			
			if (Parameters.mapHolder.y > 0)
			{
				Parameters.mapHolder.y = 0;
			}
			
			if (Parameters.mapHolder.y + Parameters.mapHeight <= stageHeight)
			{
				Parameters.mapHolder.y = stageHeight - Parameters.mapHeight;
			}
			
			if (Parameters.mapHolder.x > 0)
			{
				Parameters.mapHolder.x = 0;
			}
			
			if (Parameters.mapHolder.x + Parameters.mapWidth < stageWidth - HUD.hudWidth)
			{
				Parameters.mapHolder.x = (stageWidth - HUD.hudWidth) - Parameters.mapWidth;
			}
			
			render(true)
			moveMiniMap();
		}
		
		public function moveMapByPercetage(xPer:Number, yPer:Number):void
		{
			Parameters.mapHolder.y = (Parameters.mapHeight - Parameters.flashStage.stageHeight) * (-yPer);
			Parameters.mapHolder.x = (Parameters.mapWidth - (Parameters.flashStage.stageWidth - HUD.hudWidth)) * ( -xPer);
			lastX = Parameters.mapHolder.x;
			lastY = Parameters.mapHolder.y;
			render(true)
		}
		
		public function focusOnItem(x:int, y:int):void
		{
			var xPer:Number = x / Parameters.mapWidth;
			var yPer:Number = y / Parameters.mapHeight;
			moveMapByPercetage(xPer, yPer);
			moveMiniMap();
		}
		
		public function dispose():void 
		{
			Parameters.theStage.removeEventListener(TouchEvent.TOUCH, onStageTouch);
			
			var numChildreLeft:int = Board.mapContainerArr[Board.GROUND_LAYER].numChildren; 
			if (numChildreLeft)
			{
				for (var j:int = numChildreLeft-1; j >= 0; j-- )
				{
					var child = Board.mapContainerArr[Board.GROUND_LAYER].getChildAt(j);
					child.removeFromParent();
					child = null;
				}
			}
			

			Board.mapContainerArr[Board.GROUND_LAYER] = new Sprite();
			prevRow = -1;
			prevCol = -1;
			firstTime = true;
			KeyboardController.getInstance().disable();
			lastX = 0;
			lastY = 0;
			diffX = 0;
			diffY = 0;
			startDragX = 0;
			startDragY = 0;
			
			sHelperPoint = new Point();
			sHelperPoint2 = new Point();
			sHelperPoint3 = new Point();
			clearTimeout(myTimeout)
		}
		
		
	}
}