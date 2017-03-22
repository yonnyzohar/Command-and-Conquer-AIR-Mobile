package global.ui.hud
{
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
	import states.game.teamsData.TeamObject;
	
	public class MiniMap extends Sprite
	{
		
		private var miniMap:Sprite = new starling.display.Sprite();
		private var mapMover:MapMover;
		private var xOffset:int;
		private var yOffset:int;
		
		private var map:Quad ;
		private var mapImage:Image;
		
		
		private var COLOR_WATER:uint = 0x33adff;
		private var COLOR_GROUND:uint = 0x339933;
		private var COLOR_OBSTACLES:uint = 0x006600;
		
		
		
		private var mapWidth:int;
		private var mapHeight:int;
		private var DRAW_WITH_QUADS:Boolean = false;
		
		private var mapBd:BitmapData;
		private var unitsBd:BitmapData;
		
		private var mapTimer:int = 0;
		private var mapShown:Boolean = false;
		
		private var selectionArea:MiniMapSelectionAreaView;
		private var teamObj:TeamObject;
		
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
		
		public function init(_w:int, _h:int, _teamObj:TeamObject):void 
		{
			teamObj = _teamObj;
			mapWidth = _w ;
			mapHeight = _h ;
			mapMover = MapMover.getInstance();
			map = new Quad(mapWidth, mapHeight, 0x000000);
			
			var ratioW:Number = Parameters.flashStage.stageWidth / (Parameters.numCols * Parameters.tileSize)
			var ratioH:Number = Parameters.flashStage.stageHeight / (Parameters.numRows * Parameters.tileSize)
			
			addChild(map);
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
				if (teamObj.powerCtrl.POWER_SHORTAGE)
				{
					shutDownMap();
					mapShown = false;
					return;
				}
				
				var hasCommCenter:Boolean = false;
				var g:GameEntity;
				humanTeamLength = Parameters.humanTeam.length;
				
				for (i = 0; i < humanTeamLength; i++ )
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
			
			if (Parameters.editMode == false)
			{
				var humanTeamLength:int =  Parameters.humanTeam.length;
				var team1Obj:TeamObject;
				
				for (var i:int = 0; i < humanTeamLength; i++ )
				{
					g = Parameters.humanTeam[i];
					if (team1Obj == null)
					{
						team1Obj = g.myTeamObj;
					}
					
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
									drawPixel( g.model.row + row, g.model.col+ col, tileSize,  team1Obj.color, mapBd);
								}
							}
						}
					}
					else
					{
						drawPixel( g.model.row, g.model.col, tileSize,  team1Obj.color,  mapBd);
					}
				}
				team1Obj = null;
				
				 var teamObject:TeamObject;
				 var team:Array;
				 var teamLen:int = 0;
				
				for (var j:int = 0; j < Parameters.gameTeamObjects.length; j++ )
				{
					teamObject = Parameters.gameTeamObjects[j];
					if (teamObject.agent ==  Agent.PC)
					{
						team =  teamObject.team;
						teamLen = team.length;
						for (i = 0; i < teamLen; i++ )
						{
							g = team[i];

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
											drawPixel( g.model.row + row, g.model.col + col,tileSize,  teamObject.color,  mapBd);
										}
									}
								}
							}
							else
							{
								drawPixel(  g.model.row, g.model.col,tileSize,  teamObject.color,  mapBd);
							}
						}
					}
					
				}
			}

			
			

			var texture:Texture = Texture.fromBitmapData(mapBd);
			if (mapImage == null)
			{
				mapImage = new Image(texture);
			}
			mapImage.texture = texture;
			map.visible = true;
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
			if (!Parameters.AI_ONLY_GAME)
			{
				map.visible = false;
				if(mapImage)mapImage.removeFromParent();
				selectionArea.visible = false;
			}
			
			
		}
		
		private function drawPixel(row:int, col:int, tileSize:Number, color:uint, bd:BitmapData):void 
		{
			bd.setPixel(col, row, color);
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
		
		
		
		public function moveMiniMap(rowsPer:Number, colsPer:Number):void 
		{
			if (selectionArea)
			{
				selectionArea.x = (mapWidth - selectionArea.width) * colsPer;
				selectionArea.y = (mapHeight - selectionArea.height) * rowsPer;
			}
			
			
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
			if (mapImage)
			{
				mapImage.removeFromParent();
			}
			mapImage = null;
			if (map)
			{
				map.removeFromParent();
				map = null;
				
			}
			mapMover = null;
			
			GameTimer.getInstance().removeUser(this);
			if (mapBd)
			{
				mapBd.dispose();
				mapBd = null;
			}
			if (unitsBd)
			{
				unitsBd.dispose();
				unitsBd = null;
			}
			teamObj = null;
		}
		
	}

}