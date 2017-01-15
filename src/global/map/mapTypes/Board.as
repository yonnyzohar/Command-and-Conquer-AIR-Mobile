package global.map.mapTypes
{
	
	import flash.display3D.textures.RectangleTexture;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	import global.GameAtlas;
	import global.map.Node;
	import global.map.ResourceNode;
	import starling.display.MovieClip;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import states.game.stats.LevelManager;
	
	import global.Parameters;
	import global.GameAtlas;
	import global.utilities.DragScroll;
	import global.utilities.GameTimer;
	import global.utilities.GlobalEventDispatcher;
	import global.utilities.MapMover;
	
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.RenderTexture;
	
	
	
	public class Board
	{
		public static var drawType:int;
		public static var DRAW_TYPE_ALL_TILES:int = 0;
		public static var DRAW_TYPE_ONLY_CENTER:int = 1;
		public static var RENDER_TEXTURE:int = 2;
		public static var resourceNodes:Object = { };
		
		private var renderTextures:Array = [];
		
		private var canvas:RenderTexture;
		
		
		static private var instance:Board = new Board();
		private var dragScroll:DragScroll = new DragScroll();
		
		
		
		public var treesAndRocks:Array = new Array();
		
		private var mapMover:MapMover;
		
		public var useImg:Boolean = true;
		
		private var textures:Vector.<Texture>;

		
		public function Board()
		{
			
			if (instance)
			{
				throw new Error("Singleton and can only be accessed through Singleton.getInstance()");
			}
		}
		
		public static function getInstance():Board
		{
			return instance;
		}
		

		
		public function init(editMode:Boolean):void
		{
			
			if (Parameters.tileSize == 0)
			{
				Parameters.tileSize = getTileSize(); 
			}
			
			Parameters.mapWidth = Parameters.numCols * Parameters.tileSize;
			Parameters.mapHeight = Parameters.numRows * Parameters.tileSize;
			
			/*if (editMode)
			{
				drawType = Board.DRAW_TYPE_ALL_TILES;
			}
			else
			{}*/
			
			if (Parameters.DEBUG_MODE)
			{
				drawType =  Board.DRAW_TYPE_ALL_TILES;
			}
			else
			{
				drawType = Board.DRAW_TYPE_ONLY_CENTER;
			}
			
			
			if (drawType ==  Board.RENDER_TEXTURE)
			{
				var w:Number = Parameters.mapWidth / 1024;
				var h:Number = Parameters.mapHeight / 1024;
				
				var intW:int = w;
				var intH:int = h;
				
				
				for (var row:int = 0; row < intH; row++ )
				{
					renderTextures.push([]);
					
					for (var col:int = 0; col < intW; col++ )
					{
						renderTextures[row].push(new RenderTexture(1024, 1024));
						//trace("created render texture");
					}
				}
			}
			
			destroyMap();
			
			GlobalEventDispatcher.getInstance().addEventListener("MAP_LOAD_DONE", onMapLoadDone);
			
			
			createNodes();
			drawActualTiles();
		}
		
		
		
		private function getTileSize():Number 
		{
			return getGrassTile().width;
		}
		
		private function destroyMap():void 
		{
			treesAndRocks.splice(0);
			
			var n:Node;
			if (Parameters.boardArr)
			{
				for (var row:int = 0; row < Parameters.boardArr.length; row++ )
				{
					for (var col:int = 0; col < Parameters.boardArr[row].length; col++ )
					{
						n =  Parameters.boardArr[row][col];
						if (n.groundTile)
						{
							n.groundTile.dispose();
							n.groundTile.removeFromParent(true);
						}
						
						if (n.obstacleTile)
						{
							n.obstacleTile.dispose();
							n.obstacleTile.removeFromParent(true);
						}
						n.occupyingUnit = null;
						n = null;
					}
				}
				Parameters.boardArr[row] = null;
				Parameters.boardArr = [];
			}
			
		}
		
		private function onMapLoadDone(e:starling.events.Event):void
		{
			if (drawType ==  Board.RENDER_TEXTURE)
			{
				
				for (var row:int = 0; row <  renderTextures.length; row++)
				{
					for (var col:int = 0; col <  renderTextures[row].length; col++)
					{
						var renderTex:RenderTexture = RenderTexture(renderTextures[row][col]);
						var mapImg:Image = new Image(renderTex );
						mapImg.x = renderTex.width * col;
						mapImg.y = renderTex.height * row;
						Parameters.mapHolder.addChild(mapImg);
						//trace("adding render tex at " + mapImg.x + " " + mapImg.y)
					}
				}
				
			}
			
			
			//trace"MAP LOAD DONE!!!!!!!!!!!!!!!!!!!!!!!!");
			GlobalEventDispatcher.getInstance().removeEventListener("MAP_LOAD_DONE", onMapLoadDone);
			//drawGridlines();
			//mapImg.blendMode = BlendMode.NONE;
			//mapImg.flatten();
			mapMover = MapMover.getInstance();
			mapMover.init();
			
			
			
			//Parameters.mapHolder.addChild(mapImg);
			createWallsAndTrees();
			var totalMapSize:Rectangle = new Rectangle(0, 0, Parameters.tileSize * Parameters.numCols, Parameters.tileSize * Parameters.numRows);
			var screenSize:Rectangle   = new Rectangle(0, 0, Parameters.flashStage.stageWidth, Parameters.flashStage.stageHeight);
			//dragScroll.init(Parameters.mapHolder, Parameters.theStage, totalMapSize,screenSize, mapMover.render);
			mapMover.render(true);
			
			GameTimer.getInstance().addUser(this);
		}
		
		
		
		private function createNodes():void 
		{
			//trace"createNodes");
			var i:int = 0;
			var n:Node;
			
			for (i = 0; i <  Parameters.numRows; i++ )
			{
				Parameters.boardArr.push([])
				
				for (var j:int = 0; j <  Parameters.numCols; j++ )
				{
					n = new Node();
					n.row = i;
					n.col = j;
					if (Parameters.editMode)
					{
						n.seen = true;
					}
					Parameters.boardArr[i].push(n);
				}
			}

		}
		
		private function addTileTocorrectCanves(node:Node, img:Image):void
		{
			var row:Number = node.row / Parameters.numRows;
			var col:Number = node.col / Parameters.numCols;
			
			var renderRows:int = renderTextures.length;
			var renderCols:int = renderTextures[0].length;
			
			var rowPer:int = int( renderRows * row);
			var colPer:int = int(renderCols * col);
			
			if (rowPer == Number.NEGATIVE_INFINITY || rowPer == Number.POSITIVE_INFINITY)
			{
				rowPer = 0;
			}
			if (colPer == Number.NEGATIVE_INFINITY || colPer == Number.POSITIVE_INFINITY)
			{
				colPer = 0;
			}
			
			img.x = node.col * Parameters.tileSize;
			img.y = node.row * Parameters.tileSize;
			
			img.x -= (1024 * colPer )
			img.y -= (1024 *rowPer )
			
			////trace(rowPer + " " + colPer );
			var renderTex:RenderTexture = renderTextures[rowPer][colPer];
			renderTex.draw(img);
		}
		
		
		private function getGrassTile():Image
		{
			var rndImg:int;
			
			if (textures == null)
			{
				textures = GameAtlas.getTextures("grass");
			}
			var rndImg:int = Math.random() * textures.length; 
			var img:Image = new Image(textures[rndImg]);
			img.scaleX = img.scaleY = (Parameters.gameScale);
			img.blendMode = BlendMode.NONE;
			img.touchable = false;
			
			return img;
		}

		private function drawActualTiles():void
		{
			var _currentTile:int = 0;
			
			var n:Node;
			var len:int = Parameters.boardArr.length;
			
			for (var row:int = 0; row <  len; row++ )
			{
				var len1:int = Parameters.boardArr[row].length
				for (var col:int = 0; col <  len1; col++ )
				{
					n =  Parameters.boardArr[row][col];
					
					n.groundTile = getGrassTile();  
					n.groundTile.y = n.row * Parameters.tileSize;
					n.groundTile.x = n.col * Parameters.tileSize;
					n.groundTile.scaleX += 0.5;
					n.groundTile.scaleY += 0.5;
					
					if (drawType == Board.DRAW_TYPE_ALL_TILES)
					{
						Parameters.mapHolder.addChild(n.groundTile);
					}
					if (drawType == Board.RENDER_TEXTURE)
					{
						//trace("grass");
						addTileTocorrectCanves(n, n.groundTile);
						//canvas.draw(n.groundTile);
					}
				}
			}
			
			if (Parameters.editMode && Parameters.editLoad == false)
			{
				return
			}
				
			var waterTextures:Vector.<Texture>  = GameAtlas.getTextures("water");
			var waterTiles:Array = [];
			var mapObj:Object;
			//create all water tiles
			for (var i:int = 0; i < LevelManager.currentlevelData.map.length; i++ )
			{
				mapObj = LevelManager.currentlevelData.map[i];
				n =  Parameters.boardArr[mapObj.row][mapObj.col];
				n.walkable = mapObj.walkable;
				n.regionNum = mapObj.regionNum;
				
				if (mapObj.groundTileTexture == "water")
				{
					n.isWater = true;
					var rndImg:int = Math.random() * waterTextures.length; 
					n.groundTile.texture = waterTextures[rndImg];
					n.groundTile.touchable = false;
					waterTiles.push(n);
			
					
					if (drawType == Board.RENDER_TEXTURE)
					{
						//trace("water");
						addTileTocorrectCanves(n, n.groundTile);
						//canvas.draw(n.groundTile);
					}
				}
			}
			
			/*var d:Object = { };
			d["topRight"] = 0;
			d["topLeft"] = 1;
			d["bottomLeft"] = 2;
			d["bottomRight"] = 3;
			
			var e:Object = {}
			e["top"] = 4;
			e["Right"] = 5;
			e["bottom"] = 6;
			e["Left"] = 7;

			
			//rearrange all water tiles
			var beachTextures:Vector.<Texture>  = GameAtlas.getTextures("beach");
			for (i = 0; i < waterTiles.length; i++ )
			{
				n =  waterTiles[i];
				var top:String = "";
				var bottom:String="";
				var Left:String = "";
				var Right:String = "";
				var oneColLeft:Node; 
				var oneColRight:Node;
				var oneRowUp:Node;
				var oneRowDown:Node;
				var g:int = 0;
				
				if (Parameters.boardArr[n.row][n.col - 1])
				{
					oneColLeft = Parameters.boardArr[n.row][n.col - 1];
					
					if (oneColLeft && oneColLeft.walkable)
					{
						Left = "Left";
					}
				}
				
				if (Parameters.boardArr[n.row][n.col + 1])
				{
					oneColRight = Parameters.boardArr[n.row][n.col + 1];
				
					if (oneColRight && oneColRight.walkable)
					{
						Right = "Right";
					}
					
				}
				
				if (Parameters.boardArr[n.row-1] && Parameters.boardArr[n.row-1][n.col])
				{
					oneRowUp = Parameters.boardArr[n.row-1][n.col];
				
					if (oneRowUp && oneRowUp.walkable)
					{
						top = "top";
					}
				}
				
				if (Parameters.boardArr[n.row+1] && Parameters.boardArr[n.row+1][n.col])
				{
					oneRowDown = Parameters.boardArr[n.row+1][n.col];
				
					if (oneRowDown && oneRowDown.walkable)
					{
						bottom = "bottom";
					}
				}
				
				var topRight:String = top + Right;
				var topLeft:String = top + Left;
				var bottomLeft:String = bottom + Left;
				var bottomRight:String = bottom + Right;
				
				var a:Array = [topRight, topLeft, bottomLeft, bottomRight ];
				var success:Boolean = false;
				
				for (g = 0; g < a.length; g++ )
				{
					var texName:String = a[g];
					if (d[texName])
					{
						var frame:int = d[texName]
						n.groundTile.texture = beachTextures[frame];
						n.groundTile.touchable = false;
						success = true;
						
						if (drawType == Board.RENDER_TEXTURE)
						{
							//trace("shore");
							addTileTocorrectCanves(n, n.groundTile);
						}
					}
				}
				
				if (!success)
				{
					a = [top, bottom, Left, Right ];
					var c:Array = [oneRowUp ,oneRowDown,  oneColLeft, oneColRight];
					for (g = 0; g < a.length; g++ )
					{
						texName = a[g];
						if (e[texName])
						{
							var frame:int = e[texName]
							c[g].groundTile.texture = beachTextures[frame];
							c[g].groundTile.touchable = false;
							
							if (a[g] == "top" && Parameters.boardArr[c[g].row][c[g].col - 1] && Parameters.boardArr[c[g].row][c[g].col - 1].isWater)
							{
								c[g].groundTile.texture = beachTextures[d["topRight"]];
							}
							
												
							if (a[g] == "top" && Parameters.boardArr[c[g].row][c[g].col + 1] && Parameters.boardArr[c[g].row][c[g].col + 1].isWater)
							{
								c[g].groundTile.texture = beachTextures[d["topLeft"]];
							}
							
							if (a[g] == "bottom" && Parameters.boardArr[c[g].row][c[g].col - 1] && Parameters.boardArr[c[g].row][c[g].col - 1].isWater)
							{
								c[g].groundTile.texture = beachTextures[d["bottomRight"]];
							}
							
							if (a[g] == "bottom" && Parameters.boardArr[c[g].row][c[g].col + 1] && Parameters.boardArr[c[g].row][c[g].col + 1].isWater)
							{
								c[g].groundTile.texture = beachTextures[d["bottomLeft"]];
							}
							
							
							
							if (drawType == Board.RENDER_TEXTURE)
							{
								//trace("shore");
								addTileTocorrectCanves(n, n.groundTile);
							}
						}
					}
				}
				
				
				
			}*/
			waterTiles.splice(0);
			waterTiles = null;
				
			
			
			
			GlobalEventDispatcher.getInstance().dispatchEvent(new starling.events.Event("MAP_LOAD_DONE"));
			
		}
		
		public function createWallsAndTrees():void
		{
			if (Parameters.editMode && Parameters.editLoad == false)
			{
				return;
			}
			
			resourceNodes = { };
			
			//trace"createWallsAndTrees");
			var createWalls:int = 0;
			var wallImg:Image;
			var node:Node;
			var resourceTextures:Vector.<Texture> = GameAtlas.getTextures("tiberium");
			var resourceNode:ResourceNode;
	

			for (var i:int = 0; i < LevelManager.currentlevelData.map.length; i++ )
			{
				var obj:Object = LevelManager.currentlevelData.map[i];
				
				if (obj.groundTileTexture != "grass")
				{
					continue;
				}
				
				var row:int = obj.row;
				var col:int = obj.col;
				var textureName:String = obj.obstacleTextureName;
				var textureFrame:int = obj.textureFrame;
				

				if(Parameters.boardArr[row])
				{
					if(Parameters.boardArr[row][col])
					{
						node = Node(Parameters.boardArr[row][col]);

						if (textureName == "tree")
						{
							//-06
							var str:String = "";
							if (textureFrame < 10)
							{
								str = "0" + textureFrame;
							}
							else
							{
								str = String(textureFrame);
							}
							
							if (textureFrame == 0)
							{
								continue;
							}
							
							
							var treeTextures:Vector.<Texture> = GameAtlas.getTextures("tree-"+str);
							node.obstacleTile = new MovieClip(treeTextures);
							node.obstacleTile.currentFrame = 0;
							node.walkable = false;
							node.obstacleTile.touchable = false;
							var w:int = node.obstacleTile.width / Parameters.tileSize;
							var h:int = node.obstacleTile.height / Parameters.tileSize;
							
							for (var r:int = row; r <  row + h; r++ )
							{
								for (var c:int = col; c <  col + w; c++ )
								{
									if (Parameters.boardArr[r] && Parameters.boardArr[r][c])
									{
										Parameters.boardArr[r][c].walkable = false;
									}
								}
							}
						}
						if (textureName == "tiberium")
						{
							resourceNode = new ResourceNode();
							copyNode(resourceNode, node);
							Parameters.boardArr[row][col] = resourceNode;
							
							resourceNode.initResource(resourceTextures, textureFrame);
							resourceNodes[resourceNode.row + "_" + resourceNode.col] = resourceNode;
							node = resourceNode;
						}
						
						
						node.obstacleTile.loop = false;
						node.obstacleTile.name = textureName + "_" + textureFrame;
						
						node.obstacleTile.scaleX = node.obstacleTile.scaleY = Parameters.gameScale;
						node.obstacleTile.x = col * Parameters.tileSize;
						node.obstacleTile.y = row * Parameters.tileSize;
						
						
						
						
						if (textureName == "tree")
						{
							if(node.obstacleTile.height > Parameters.tileSize)
							{
								if((node.obstacleTile.height - Parameters.tileSize) > 5)
								{
									node.obstacleTile.y -= Parameters.tileSize ;
								}
							}
							treesAndRocks.push({"view" : node.obstacleTile, "row" :node.row, "col": node.col, type : "tree"});
						}
						
						
						
						
						if (drawType == Board.DRAW_TYPE_ALL_TILES)
						{
							Parameters.mapHolder.addChild(node.obstacleTile);
						}
						
						wallImg = null;
					}
				}
			}
		}
		
		private function copyNode(resourceNode:ResourceNode, node:Node):void 
		{
			resourceNode.groundTile      = node.groundTile;
			resourceNode.groundTile.x    = node.groundTile.x;
			resourceNode.groundTile.y    = node.groundTile.y;
			resourceNode.obstacleTile    = node.obstacleTile;   
			resourceNode.isWater         = node.isWater;        
			resourceNode.isResource      = node.isResource ;    
			resourceNode.type            = node.type;           
			resourceNode.g               = node.g   ;           
			resourceNode.h               = node.h  ;            
			resourceNode.f               = node.f  ;            
			resourceNode.parent          = node.parent ;         
			resourceNode.row             = node.row  ;          
			resourceNode.col             = node.col   ;         
			resourceNode.walkable        = node.walkable;       
			resourceNode.regionNum       = node.regionNum ;     
			resourceNode.occupyingUnit   = node.occupyingUnit ; 
			resourceNode.withinUnitRange = node.withinUnitRange;
			
			
		}
		
		
		
		
		public function highlightUnwalkableNodes():void
		{
			var node:Node;
			
			for(var row:int = 0; row < Parameters.boardArr.length; row++)
			{
				for(var col:int = 0; col < Parameters.boardArr[row].length; col++)
				{
					node = Node(Parameters.boardArr[row][col]);
					
					//trace"node.walkable: " + node.walkable);
					if(node.walkable == false)
					{
						var destSquare:Quad = new Quad(Parameters.tileSize, Parameters.tileSize, Math.round(Math.random()*0xFFFFFF));
						destSquare.alpha = 0.4;
						destSquare.x = col * Parameters.tileSize;
						destSquare.y = row * Parameters.tileSize;
						Parameters.mapHolder.addChild(destSquare);
					}
				}
			}
		}
		
		public function update(_pulse:Boolean):void
		{
			mapMover.update(_pulse);
		}
		
		/*public function drawUnit(view:UnitView):void
		{
			//canvas.draw(view);
		}*/
		

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function drawGridlines():void 
		{
			var line:Quad;
			
			for (var i:int = 0; i < Parameters.numRows ; i++ )
			{
				line = new Quad(Parameters.mapWidth, 1, 0x00000); 
				line.x = 0;
				line.y = Parameters.tileSize * i;
				line.touchable = false;
				
				if(useImg)
				{
					//canvas.draw(line);
				}

			}
			
			for (i = 0; i < Parameters.numCols ; i++ )
			{
				line = new Quad(1, Parameters.mapHeight, 0x00000); 
				line.x = Parameters.tileSize * i;
				line.y = 0;
				line.touchable = false;
				
				if(useImg)
				{
					//canvas.draw(line);
				}
			}
			
			
			line = null;
		}
	}
}
