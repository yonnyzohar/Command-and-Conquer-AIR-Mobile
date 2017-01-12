package states.editor
{
	import com.dynamicTaMaker.loaders.TemplateLoader;
	import com.dynamicTaMaker.utils.ButtonManager;
	import com.dynamicTaMaker.views.GameSprite;
	import flash.geom.Point;
	import global.assets.Assets;
	import global.GameAtlas;
	import global.map.Node;
	import global.Parameters;
	import global.ui.hud.HUDView;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import global.ui.hud.HUDView;
	import starling.textures.Texture;

	public class ControlsPane extends EventDispatcher
	{
		public var view:GameSprite;
		private var groundTextures:Vector.<Texture>;
		private var waterTextures:Vector.<Texture>;
		private var treeTextures:Vector.<Texture>;
		private var resourceTextures:Vector.<Texture>;
		
		private var currentTile:String = "grass";
		private var currentTexture:Vector.<Texture>;
		private var xOffset:int;
		private var yOffset:int;
		
		private var currentTree:int = 0;
		private var currenttiberium:int = 0;
		
		public function ControlsPane()
		{
			view = TemplateLoader.get("PaintPaneMC");
			view.team1.index = 1;
			view.team2.index = 2;
			selectButton(view.team1);
			
			view.paintCoverMC.visible = false;
	
			
			ButtonManager.setButton(view.team1, "TOUCH", onTeamSelected);
			ButtonManager.setButton(view.team2, "TOUCH", onTeamSelected);
			ButtonManager.setButton(view.playBTN, "TOUCH", onGoClicked);
			ButtonManager.setButton(view.saveBTN, "TOUCH", onSaveClicked);
			ButtonManager.setButton(view.closeBTN, "TOUCH", onExitClicked);
			
			ButtonManager.setButton(view.rockMC, "TOUCH", onObstacleClicked);
			ButtonManager.setButton(view.treeMC, "TOUCH", onTreeClicked);
			ButtonManager.setButton(view.tileTypeMC, "TOUCH", onTileTypeClicked);
			
			ButtonManager.setButton(view.eraseMC, "TOUCH", onEraseClicked);
			ButtonManager.setButton(view.brushMC, "TOUCH", onBrushClicked);
			ButtonManager.setButton(view.bucketMC, "TOUCH", onBucketClicked);
			ButtonManager.setButton(view.noneBTN, "TOUCH", onNoneClicked);
			
			ButtonManager.setButton(view.detailsPanelBTN, "TOUCH", onDetailsPanelClicked);
			
			view.addEventListener(TouchEvent.TOUCH, onPaneTouch);
			
			view.tileTypeCoverMC.touchable = false;
			initTiles();
			initObstacles();
			
		}
		
		
		
		private function onPaneTouch(e:TouchEvent):void
		{
			var begin:Touch    = e.getTouch(view, TouchPhase.BEGAN);
			var move:Touch    = e.getTouch(view, TouchPhase.MOVED);
			var end:Touch    = e.getTouch(view, TouchPhase.ENDED);
			var location:Point;
						
			if(begin)
			{
				location = begin.getLocation(Parameters.gameHolder);
				xOffset = location.x - view.x;
				yOffset = location.y - view.y;
			}
			if(move)
			{
				location = move.getLocation(Parameters.gameHolder);
				var y:Number = location.y - yOffset;
				view.y = y;
				
				var x:Number = location.x - xOffset;
				view.x = x;
			}
			if(end)
			{
				location = end.getLocation(Parameters.gameHolder);
			}

			e.stopPropagation();
		}
		
		private function initTiles():void 
		{
			groundTextures  = GameAtlas.getTextures("grass");
			waterTextures = GameAtlas.getTextures("water");
			var img:Image = new Image(groundTextures[0]);
			
			
			img.width = 35;
			img.height = 35;
			view.tileTypeMC.addChild(img);
			view.tileTypeMC.img = img;
			currentTile = "grass";
			currentTexture = groundTextures;
			
			view.tileTypeCoverMC.x = view.tileTypeMC.x;
			view.tileTypeCoverMC.y = view.tileTypeMC.y;
			
		}
		
		private function initObstacles():void 
		{
			resourceTextures = GameAtlas.getTextures("tiberium");
			setResourceTile();
			
			//var treeTextureArrays:Array  = GameAtlas.getMultipleTextureArrays("tree");

			for (var k:String in Assets.trees.list)
			{
				var tex:Vector.<Texture> = GameAtlas.getTextures(k);
				if (treeTextures == null)
				{
					treeTextures = new Vector.<Texture> ;
				}
				if(tex)treeTextures.push(tex[0]);
				
			}
			
			 
			setTreeTile();
		}
		
		private function setTreeTile():void 
		{
			if (view.treeMC.img == null)
			{
				view.treeMC.img = new Image(treeTextures[currentTree]);
				view.treeMC.img.scaleX = view.treeMC.img.scaleY = Parameters.gameScale;
			}
			view.treeMC.img.texture = treeTextures[currentTree]
			view.treeMC.img.width = 35;
			view.treeMC.img.height = 35;
			view.treeMC.addChild(view.treeMC.img);
		}
		
		private function setResourceTile():void 
		{
			if (view.rockMC.img == null)
			{
				view.rockMC.img = new Image(resourceTextures[currenttiberium]);
			}
			view.rockMC.img.texture = resourceTextures[currenttiberium]
			view.rockMC.img.width = 35;
			view.rockMC.img.height = 35;
			view.rockMC.addChild(view.rockMC.img);
		}
		
		private function onNoneClicked(caller:GameSprite):void
		{
			view.paintCoverMC.visible = false;
			Parameters.theStage.removeEventListener(TouchEvent.TOUCH, onStagePaintBrushTouch);
			Parameters.theStage.removeEventListener(TouchEvent.TOUCH, onStageBucketTouch);
			Parameters.theStage.removeEventListener(TouchEvent.TOUCH, onStageErase);
		}
		
		private function onTreeClicked(caller:GameSprite):void
		{
			view.tileTypeCoverMC.x = view.treeMC.x;
			view.tileTypeCoverMC.y = view.treeMC.y;
			view.bucketMC.alpha = 0.5;
			view.bucketMC.touchable = false;
			view.paintCoverMC.x = view.brushMC.x;
			view.paintCoverMC.y = view.brushMC.y;
			currentTexture = treeTextures;
			
			currentTree++;
			
			if (currentTree >= treeTextures.length)
			{
				currentTree = 0;
			}
			
			setTreeTile();
			
			
		}
		
		private function onObstacleClicked(caller:GameSprite):void
		{
			view.tileTypeCoverMC.x = view.rockMC.x;
			view.tileTypeCoverMC.y = view.rockMC.y;
			view.bucketMC.alpha = 0.5;
			view.bucketMC.touchable = false;
			view.paintCoverMC.x = view.brushMC.x;
			view.paintCoverMC.y = view.brushMC.y;
			currentTexture = resourceTextures;
			
			
			currenttiberium++;
			
			if (currenttiberium >= resourceTextures.length)
			{
				currenttiberium = 0;
			}
			
			setResourceTile();
			
		}
		private function onTileTypeClicked(caller:GameSprite):void
		{
			view.tileTypeCoverMC.x = view.tileTypeMC.x;
			view.tileTypeCoverMC.y = view.tileTypeMC.y;
			view.bucketMC.alpha = 1;
			view.bucketMC.touchable = true;
			
			var curTex:Texture;
			if (currentTile == "grass")
			{
				curTex = groundTextures[0]
				currentTile = "water"
				currentTexture = groundTextures;
			}
			else if (currentTile == "water")
			{
				curTex = waterTextures[0]
				currentTile = "grass"
				currentTexture = waterTextures;
			}
			view.tileTypeMC.img.dispose();
			view.tileTypeMC.img.texture = curTex;
			view.tileTypeMC.img.width = 35;
			view.tileTypeMC.img.height = 35;
		}
		
		
		private function onEraseClicked(caller:GameSprite):void
		{
			view.paintCoverMC.visible = true;
			view.paintCoverMC.x = caller.x;
			view.paintCoverMC.y = caller.y;
			Parameters.theStage.removeEventListener(TouchEvent.TOUCH, onStagePaintBrushTouch);
			Parameters.theStage.removeEventListener(TouchEvent.TOUCH, onStageBucketTouch);
			Parameters.theStage.addEventListener(TouchEvent.TOUCH, onStageErase);
		}
		
		private function onStageErase(e:TouchEvent):void 
		{
			var begin:Touch    = e.getTouch(Parameters.theStage, TouchPhase.BEGAN);
			var move:Touch    = e.getTouch(Parameters.theStage, TouchPhase.MOVED);
			var end:Touch    = e.getTouch(Parameters.theStage, TouchPhase.ENDED);
			var location:Point;
			var targetRow:int;
			var targetCol:int;
			var boardCoordinates:Point;
			var phase:String;
			
			if(begin)
			{
				phase = "begin"
				location = begin.getLocation(Parameters.theStage);
			}
			if(move)
			{
				phase = "move"
				location = move.getLocation(Parameters.theStage);
			}
			if(end)
			{
				phase = "end"
				location = end.getLocation(Parameters.theStage);
			}
			
			if(location != null)
			{
				boardCoordinates = Parameters.mapHolder.globalToLocal(new Point(location.x, location.y));
				targetCol = (boardCoordinates.x / Parameters.tileSize)
				targetRow = (boardCoordinates.y / Parameters.tileSize)
			}
			
			eraseTile(targetRow, targetCol, phase);
			
			e.stopPropagation();
		}
		
		
		
		
		
		private function onBrushClicked(caller:GameSprite):void
		{
			view.paintCoverMC.visible = true;
			view.paintCoverMC.x = caller.x;
			view.paintCoverMC.y = caller.y;
			Parameters.theStage.addEventListener(TouchEvent.TOUCH, onStagePaintBrushTouch);
			Parameters.theStage.removeEventListener(TouchEvent.TOUCH, onStageBucketTouch);
			Parameters.theStage.removeEventListener(TouchEvent.TOUCH, onStageErase);
		}
		
		private function onStagePaintBrushTouch(e:TouchEvent):void
		{
			var begin:Touch    = e.getTouch(Parameters.theStage, TouchPhase.BEGAN);
			var move:Touch    = e.getTouch(Parameters.theStage, TouchPhase.MOVED);
			var end:Touch    = e.getTouch(Parameters.theStage, TouchPhase.ENDED);
			var location:Point;
			var targetRow:int;
			var targetCol:int;
			var boardCoordinates:Point;
			var phase:String;
			
			if(begin)
			{
				phase = "begin"
				location = begin.getLocation(Parameters.theStage);
			}
			if(move)
			{
				phase = "move"
				location = move.getLocation(Parameters.theStage);
			}
			if(end)
			{
				phase = "end"
				location = end.getLocation(Parameters.theStage);
			}
			
			if(location != null)
			{
				boardCoordinates = Parameters.mapHolder.globalToLocal(new Point(location.x, location.y));
				targetCol = (boardCoordinates.x / Parameters.tileSize)
				targetRow = (boardCoordinates.y / Parameters.tileSize)
			}
			
			fillTile(targetRow, targetCol, phase);
			
			e.stopPropagation();
		}
		
		
		
		
		private function onBucketClicked(caller:GameSprite):void
		{
			view.paintCoverMC.visible = true;
			view.paintCoverMC.x = caller.x;
			view.paintCoverMC.y = caller.y;
			Parameters.theStage.removeEventListener(TouchEvent.TOUCH, onStagePaintBrushTouch);
			Parameters.theStage.addEventListener(TouchEvent.TOUCH, onStageBucketTouch);
			Parameters.theStage.removeEventListener(TouchEvent.TOUCH, onStageErase);
			
		}
		
		private function onStageBucketTouch(e:TouchEvent):void
		{
			var begin:Touch    = e.getTouch(Parameters.theStage, TouchPhase.BEGAN);
			var move:Touch    = e.getTouch(Parameters.theStage, TouchPhase.MOVED);
			var end:Touch    = e.getTouch(Parameters.theStage, TouchPhase.ENDED);
			var location:Point;
			var targetRow:int;
			var targetCol:int;
			var boardCoordinates:Point;
			
			if(begin)
			{
				location = begin.getLocation(Parameters.theStage);
			}
			if(move)
			{
				location = move.getLocation(Parameters.theStage);
			}
			if(end)
			{
				location = end.getLocation(Parameters.theStage);
			}
			
			if(location != null && end)
			{
				boardCoordinates = Parameters.mapHolder.globalToLocal(new Point(location.x, location.y));
				targetCol = (boardCoordinates.x / Parameters.tileSize)
				targetRow = (boardCoordinates.y / Parameters.tileSize)
				
				//water is 1
				//grass is 0
				var type:int = 0;
				
				if (currentTexture == waterTextures)
				{
					type = 1;
				}
				else
				{
					type = 0;
				}
				
				floodFillTiles(targetRow, targetCol,type)
				
			}
			
			e.stopPropagation();
		}
		
		
		private function eraseTile(targetRow:int, targetCol:int, phase:String):void 
		{
			if (Parameters.boardArr[targetRow][targetCol])
			{
				var node:Node = Node(Parameters.boardArr[targetRow][targetCol]);
				if (node.obstacleTile)
				{
					node.obstacleTile.dispose();
					node.obstacleTile.removeFromParent(true);
					node.obstacleTile = null;
					node.walkable = true;
				}
			}
		}
		
		private function fillTile(targetRow:int, targetCol:int, _phase:String = ""):void 
		{
			if (Parameters.boardArr[targetRow][targetCol])
			{
				var rnd:int = Math.random() * currentTexture.length;
				var node:Node = Node(Parameters.boardArr[targetRow][targetCol]);
				var currentNum:int = 0;
				
				if (currentTexture == treeTextures || currentTexture == resourceTextures)
				{
					if (_phase == "end")
					{
						var n:String = "";
						
						if (currentTexture == treeTextures) 
						{
							currentNum = currentTree;
							n = "tree_" + currentNum;
						}
						if (currentTexture == resourceTextures)
						{
							currentNum = currenttiberium;
							n = "tiberium_" + currentNum;
						}
						
						if (node.obstacleTile)
						{
							if (node.obstacleTile.texture == currentTexture[currentNum])
							{
								return;
							}
							
							node.obstacleTile.dispose();
						}
						else
						{
							node.obstacleTile = new MovieClip(currentTexture);
							node.obstacleTile.x = node.col * Parameters.tileSize;
							node.obstacleTile.y = node.row * Parameters.tileSize;
						}
						if (currentTexture == treeTextures)
						{
							if((node.obstacleTile.height - Parameters.tileSize) > 5)
							{
								node.obstacleTile.y -= Parameters.tileSize ;
							}
						}
						
						node.walkable = false;
						node.obstacleTile.texture = currentTexture[currentNum];
						node.obstacleTile.scaleX = node.obstacleTile.scaleY = Parameters.gameScale;
						node.obstacleTile.name = n;
						//tracenode.obstacleTile.name)
						
						Parameters.mapHolder.addChild(node.obstacleTile);
					}
					
				}
				
				if (currentTexture == waterTextures || currentTexture == groundTextures)
				{
					if (currentTexture == waterTextures)
					{
						if (node.groundTile.texture == currentTexture[rnd]) return;
						node.type = 1;
						node.isWater = true;
						node.walkable = false;
					}
					if (currentTexture == groundTextures)
					{
						if (node.groundTile.texture == currentTexture[rnd]) return;
						node.type = 0;
						node.walkable = true;
						node.isWater = false;
					}
					
					if (node.obstacleTile && currentTexture == waterTextures)
					{
						node.obstacleTile.removeFromParent(true);
						node.obstacleTile = null;
					}
					
					node.groundTile.dispose();
					node.groundTile.texture = currentTexture[rnd];
				}
				
				
			}
			
			
		}
		
		private function floodFillTiles(targetRow:int, targetCol:int, type:int):void 
		{
			fillTile(targetRow, targetCol);
			
			for (var i:int = -1; i <= 1; i++ )
			{
				for (var j:int = -1; j <= 1; j++ )
				{
					if (Parameters.boardArr[targetRow+i] && Parameters.boardArr[targetRow+i][targetCol+j])
					{
						var node:Node = Node(Parameters.boardArr[targetRow + i][targetCol + j]);
						if (node.type != type)
						{
							floodFillTiles(targetRow + i, targetCol + j, type);
						}
					}
				}
			}
		}
		
		private function onDetailsPanelClicked(caller:GameSprite):void
		{
			dispatchEvent(new Event("DETAILS_PANEL_CLICKED"))
		}
		
		private function onTeamSelected(caller:GameSprite):void
		{
			selectButton(caller);
			HUDView.currentTeam = caller.index;
		}
		
		private function selectButton(caller:GameSprite):void 
		{
			view.btnCoverMC.x = caller.x;
			view.btnCoverMC.y = caller.y;
		}
		
		
		private function onExitClicked(caller:GameSprite):void 
		{
			dispatchEvent(new Event("EXIT_CLICKED"));
		}
		
		private function onSaveClicked(caller:GameSprite):void 
		{
			dispatchEvent(new Event("SAVE_CLICKED"));
		}
		
		private function onGoClicked(caller:GameSprite):void 
		{
			dispatchEvent(new Event("GO_CLICKED"));
		}

		
		public function dispose():void
		{
			view.removeEventListener(TouchEvent.TOUCH, onPaneTouch);
			Parameters.theStage.removeEventListener(TouchEvent.TOUCH, onStagePaintBrushTouch);
			Parameters.theStage.removeEventListener(TouchEvent.TOUCH, onStageBucketTouch);
			Parameters.theStage.removeEventListener(TouchEvent.TOUCH, onStageErase);
			
			ButtonManager.removeButtonEvents(view.team1);
			ButtonManager.removeButtonEvents(view.team2);
			ButtonManager.removeButtonEvents(view.playBTN);
			ButtonManager.removeButtonEvents(view.saveBTN);
			ButtonManager.removeButtonEvents(view.closeBTN);
			
			ButtonManager.removeButtonEvents(view.obstacleMC);
			ButtonManager.removeButtonEvents(view.tileTypeMC);
			ButtonManager.removeButtonEvents(view.brushMC);
			ButtonManager.removeButtonEvents(view.bucketMC);
			ButtonManager.removeButtonEvents(view.detailsPanelBTN);
			view.dispose();
			view = null;
		}
	}
}