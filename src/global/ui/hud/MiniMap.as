package global.ui.hud
{
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import global.enums.Agent;
	import global.map.Node;
	import global.Parameters;
	import global.utilities.GameTimer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import global.utilities.MapMover;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.RenderTexture;
	import starling.textures.Texture;
	import states.game.entities.buildings.Building;
	import states.game.entities.buildings.BuildingModel;
	import states.game.entities.GameEntity;
	import states.game.stats.BuildingsStatsObj;
	
	public class MiniMap extends Sprite
	{
		
		private var miniMap:Sprite = new starling.display.Sprite();
		private var mapMover:MapMover;
		private var xOffset:int;
		private var yOffset:int;
		
		private var map:Quad ;
		private var canvas:RenderTexture;
		private var warCanvas:RenderTexture;
		private var unitsImg:Image;
		private var mapImage:Image;
		
		
		private var COLOR_WATER:uint = 0x33adff;
		private var COLOR_GROUND:uint = 0x339933;
		private var COLOR_OBSTACLES:uint = 0x006600;
		private var TEAM_1_UNITS:uint = 0xffff66;
		private var TEAM_1_BUILDINGS:uint = 0xffcc00;
		private var TEAM_2_UNITS:uint = 0xff9966;
		private var TEAM_2_BUILDINGS:uint = 0xff6600;
		
		private var mapWidth:int;
		private var mapHeight:int;
		private var DRAW_WITH_QUADS:Boolean = false;
		
		private var mapBd:BitmapData;
		private var unitsBd:BitmapData;
		
		private var mapTimer:int = 0;
		private var mapShown:Boolean = false;
		
		private var selectionArea:MiniMapSelectionAreaView;
		
		private static var instance:MiniMap = new MiniMap();
		
		public function MiniMap()
		{
			if (instance)
			{
				throw new Error("Singleton and can only be accessed through Singleton.getInstance()");
			}
		}
		
		public static function getInstance():MiniMap
		{
			return instance;
		}
		
		public function init(_w:int, _h:int):void 
		{
			mapWidth = _w ;
			mapHeight = _h ;
			mapMover = MapMover.getInstance();
			map = new Quad(mapWidth, mapHeight, 0x000000);
			
			var ratioW:Number = Parameters.flashStage.stageWidth / (Parameters.numCols * Parameters.tileSize)
			var ratioH:Number = Parameters.flashStage.stageHeight / (Parameters.numRows * Parameters.tileSize)
			
			addChild(map);
			//if(!Parameters.editMode)addChild(contructMap(map))
			selectionArea = new MiniMapSelectionAreaView(mapWidth * ratioW, mapHeight * ratioH); 
			addChild(selectionArea);
			
			
			addEventListener(TouchEvent.TOUCH, onTouch);
			
			GameTimer.getInstance().addUser(this)
		}
		
		public function update(_pulse:Boolean):void
		{

			if (!_pulse)
			{
				return;
			}
			
			mapTimer++;
			
			if (mapTimer == 3)
			{
				mapTimer = 0;
			}
			else
			{
				return;
			}
			
			if (!Parameters.editMode)
			{
				if (Parameters.humaTeamObject.powerCtrl.POWER_SHORTAGE)
				{
					shutDownMap();
					mapShown = false;
					return;
				}
				
				var hasCommCenter:Boolean = false;
				var g = null;
				
				for (var i:int = 0; i < Parameters.humanTeam.length; i++ )
				{
					g = Parameters.humanTeam[i];
					
					if (g.model.controllingAgent == Agent.PC && g.view.visible == false)
					{
						continue;
					}
					
					if (g is Building)
					{
						if (Building(g).name == "communications-center" || Building(g).name == "advanced-communications-tower")
						{
							hasCommCenter = true;
							break;
						}
					}
				}
				
				if (hasCommCenter == false)
				{
					shutDownMap();
					mapShown = false;
					return;
				}
			}
			
			
			
			
			
			var tileSize:Number = mapWidth / Parameters.numCols;
			var q:Quad;
			var t:Image;
			var n:Node;
			var row:int;
			var col:int;
			var j:int = 0;
			var occupyArray:Array;
			var len:int;
			var curTile:int ; 
			var proposedRow:int;
			var proposedCol:int;
			
		
			if (mapBd == null)
			{
				mapBd = new BitmapData(Parameters.numCols, Parameters.numRows, false, 0x000000);
			}
			else
			{
				mapBd.fillRect(new Rectangle(0, 0, Parameters.numCols, Parameters.numRows), 0x000000);
			}
			
			
			
			for (row = 0; row < Parameters.numRows; row++ )
			{
				for (col = 0; col < Parameters.numCols; col++ )
				{
					n = Node(Parameters.boardArr[row][col]);
					if (n.seen)
					{
						if (n.groundTile)
						{
							if (n.isWater)
							{
								drawPixel( row, col, tileSize,  COLOR_WATER, mapBd);
							}
							else
							{
								drawPixel( row, col, tileSize,  COLOR_GROUND, mapBd);
							}
						}
						
						if (n.obstacleTile || n.cliffTile)
						{
							drawPixel( row, col, tileSize,  COLOR_OBSTACLES, mapBd);
						}
					}
					
					n  = null;
					t = null;
				}
			}
			

			
			for (var i:int = 0; i < Parameters.humanTeam.length; i++ )
			{
				g = Parameters.humanTeam[i];
				
				if (!Parameters.editMode)
				{
					if (g.model.controllingAgent == Agent.PC && g.view.visible == false)
					{
						continue;
					}
				}
				
				
				if (g is Building)
				{
					occupyArray = BuildingsStatsObj(g.model.stats).gridShape;
					
					for (row = 0; row < occupyArray.length; row++ )
					{
						for (col = 0; col < occupyArray[row].length; col++ )
						{
							var curTile:int = occupyArray[row][col];
							
							if (curTile == 1)
							{
								drawPixel( g.model.row + row, g.model.col+ col, tileSize,  TEAM_1_BUILDINGS, mapBd);
							}
						}
					}
				}
				else
				{
					drawPixel( g.model.row, g.model.col, tileSize,  TEAM_1_UNITS,  mapBd);
				}
			}
			
			for (i = 0; i < Parameters.pcTeam.length; i++ )
			{
				g = Parameters.pcTeam[i];
				if (!Parameters.editMode)
				{
					if (g.model.controllingAgent == Agent.PC && g.view.visible == false)
					{
						continue;
					}
				}
				
				
				if (g is Building)
				{
					occupyArray = BuildingsStatsObj(g.model.stats).gridShape;
					
					for (row = 0; row < occupyArray.length; row++ )
					{
						for (col = 0; col < occupyArray[row].length; col++ )
						{
							curTile = occupyArray[row][col];
							
							if (curTile == 1)
							{
								drawPixel( g.model.row + row, g.model.col + col,tileSize,  TEAM_2_BUILDINGS,  mapBd);
							}
						}
					}
				}
				else
				{
					drawPixel(  g.model.row, g.model.col,tileSize,  TEAM_2_UNITS,  mapBd);
				}
			}
			

			var texture:Texture = Texture.fromBitmapData(mapBd);
			if (mapImage == null)
			{
				mapImage = new Image(texture);
			}
			mapImage.texture = texture;
			//mapImage.touchable = false;
			//var scale:Number = Parameters.numCols / map.width;
			//mapImage.scaleX = mapImage.scaleY = 1;
			//mapImage.scaleX /= scale;
			//mapImage.scaleY /= scale;
			addChild(mapImage)
			mapImage.width = mapWidth;
			mapImage.height = mapHeight;
			
			selectionArea.touchable = false;
			addChild(selectionArea);
			selectionArea.visible = true;
			Node.CHANGE_MADE_TO_MAP = false;
			mapShown = true;
		}
		

		
		private function shutDownMap():void 
		{
			map.visible = false;
			if(mapImage)mapImage.removeFromParent();
			selectionArea.visible = false;
			
		}
		
		private function drawPixel(row:int, col:int, tileSize:Number, color:uint, bd:BitmapData):void 
		{
			bd.setPixel(col, row, color);
		}
	
		
		private function addTexture(canvas:RenderTexture, t:Image, texture:Texture,tileSize:Number, row:int, col:int):void 
		{
			t = new Image(texture);
			t.width = tileSize;
			t.height = tileSize;
			t.y = tileSize * row;
			t.x = tileSize * col;
			canvas.draw(t);
		}
		
		private function onTouch(e:TouchEvent):void
		{
			var startMulti:Touch = e.getTouch(this, TouchPhase.BEGAN);
			var movingMulti:Touch = e.getTouch(this, TouchPhase.MOVED);
			var endMulti:Touch = e.getTouch(this, TouchPhase.ENDED);
			var location:Point;
			
			
			if(startMulti != null )
			{
				location = startMulti.getLocation(this);
				beginScroll(location.x,location.y );
			}
			
			if(movingMulti != null )
			{
				location = movingMulti.getLocation(this);
				mouseMoveHandler(location.x,location.y);
			}
			
			if(endMulti != null )
			{
				location = endMulti.getLocation(this);
				mouseUpHandler(location.x,location.y);
			}
			
			e.stopPropagation();
		}
		
		private function beginScroll(locX:int, locY:int):void
		{
			selectionArea.x = locX - (selectionArea.width/2);
			selectionArea.y = locY - (selectionArea.height/2);
			xOffset = locX - selectionArea.x;
			yOffset = locY - selectionArea.y;
		}
		
		private function mouseMoveHandler(locX:int, locY:int):void 
		{
			var y:Number = locY - yOffset;
			selectionArea.y = y;
			
			if (selectionArea.y < 0) 
			{
				selectionArea.y = 0;
			} 
			if (selectionArea.y + selectionArea.height > mapHeight) 
			{
				selectionArea.y = mapHeight - selectionArea.height;
			} 
			
			var x:Number = locX - xOffset;
			selectionArea.x = x;
			
			if (selectionArea.x < 0) 
			{
				selectionArea.x = 0;
			} 
			if (selectionArea.x + selectionArea.width > mapWidth) 
			{
				selectionArea.x = mapWidth - selectionArea.width;
			} 
			
			var xPer:Number = selectionArea.x / (mapWidth - selectionArea.width);
			var yPer:Number = selectionArea.y / (mapHeight - selectionArea.height);
				
			
			mapMover.moveMapByPercetage(xPer , yPer );
			
			
		}
		
		
		private function mouseUpHandler(locX:int, locY:int):void 
		{
			/*var time:Number = (getTimer() - t2) / 1000;
			var xVelocity:Number = (mc.x - x2) / time;
			var yVelocity:Number = (mc.y - y2) / time;
			ThrowPropsPlugin.to(mc, {throwProps:{
				y:{velocity:yVelocity, max:bounds.top, min:bounds.top - yOverlap, resistance:300},
				x:{velocity:xVelocity, max:bounds.left, min:bounds.left - xOverlap, resistance:300}
			}, ease:Strong.easeOut
			}, 10, 0.3, 1);*/
			

		}
		
		override public function dispose():void
		{
			removeEventListener(TouchEvent.TOUCH, onTouch);
			if (selectionArea)
			{
				
				selectionArea.dispose();
				selectionArea.removeFromParent(true);
			}
			
			selectionArea = null;
		}
		
		public function moveMiniMap(rowsPer:Number, colsPer:Number):void 
		{
			selectionArea.x = (mapWidth - selectionArea.width) * colsPer;
			selectionArea.y = (mapHeight - selectionArea.height) * rowsPer;
			
		}
		
	}

}