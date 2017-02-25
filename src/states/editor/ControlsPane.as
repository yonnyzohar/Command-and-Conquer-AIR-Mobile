package states.editor
{
	import com.dynamicTaMaker.loaders.TemplateLoader;
	import com.dynamicTaMaker.utils.ButtonManager;
	import com.dynamicTaMaker.views.GameSprite;
	import flash.geom.Point;
	import global.assets.Assets;
	import global.GameAtlas;
	import global.map.mapTypes.Board;
	import global.map.Node;
	import global.Parameters;
	import global.ui.hud.HUD;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import global.ui.hud.HUD;
	import starling.textures.Texture;

	public class ControlsPane extends EventDispatcher
	{
		public var view:GameSprite;
		private var groundTextures:Vector.<Texture>;
		private var waterTextures:Vector.<Texture>;
		private var treeTextures:Vector.<Texture>;
		private var resourceTextures:Vector.<Texture>;
		
		private var topShoreTextures:Vector.<Texture>;
		private var bottomShoreTextures:Vector.<Texture>;
		private var leftShoreTextures:Vector.<Texture>;
		private var rightShoreTextures:Vector.<Texture>;
		private var cornerShoreTextures:Vector.<Texture>;
		
		
		private var topRidgeTextures:Vector.<Texture>;
		private var bottomRidgeTextures:Vector.<Texture>;
		private var leftRidgeTextures:Vector.<Texture>;
		private var rightRidgeTextures:Vector.<Texture>;
		private var cornerRidgeTextures:Vector.<Texture>;
		
		private var currentTile:String = "grass";
		private var currentTexture:Vector.<Texture>;
		private var xOffset:int;
		private var yOffset:int;
		
		private var currentTree:int = 0;
		private var currenttiberium:int = 0;
		
		private var currentTopShore:int = 0;
		private var currentBottomShore:int = 0;
		private var currentLeftShore:int = 0;
		private var currentRightShore:int = 0;
		private var currentCornerShore:int = 0;
		
		private var currentTopRidge:int = 0;
		private var currentBottomRidge:int = 0;
		private var currentLeftRidge:int = 0;
		private var currentRightRidge:int = 0;
		private var currentCornerRidge:int = 0;
		
		private var shoreCliffObstacle:MovieClip;
		
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
			
			ButtonManager.setButton(view.shore_top, "TOUCH", onShoreTopClicked);
			ButtonManager.setButton(view.shore_bottom, "TOUCH", onShoreBottomClicked);
			ButtonManager.setButton(view.shore_left, "TOUCH", onShoreLeftClicked);
			ButtonManager.setButton(view.shore_right, "TOUCH", onShoreRightClicked);
			ButtonManager.setButton(view.shore_corner, "TOUCH", onShoreCornerClicked);
			
			
			ButtonManager.setButton(view.ridges_top, "TOUCH", onRidgeTopClicked);
			ButtonManager.setButton(view.ridges_bottom, "TOUCH", onRidgeBottomClicked);
			ButtonManager.setButton(view.ridges_left, "TOUCH", onRidgeLeftClicked);
			ButtonManager.setButton(view.ridges_right, "TOUCH", onRidgeRightClicked);
			ButtonManager.setButton(view.ridges_corner, "TOUCH", onRidgeCornerClicked);
			
			
			
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
		
		//////////////////////////////////////////----shores----------//////////////////////////////////////
		private function onShoreTopClicked(caller:GameSprite):void
		{
			var isAlreadyCovered:Boolean = highlightMe(view.shore_top);
			
			currentTexture = topShoreTextures;
			
			if(isAlreadyCovered)currentTopShore++;
			
			if (currentTopShore >= topShoreTextures.length)
			{
				currentTopShore = 0;
			}
			
			setTile(view.shore_top, topShoreTextures, currentTopShore);
		}
		
		private function onShoreBottomClicked(caller:GameSprite):void
		{
			var isAlreadyCovered:Boolean = highlightMe(view.shore_bottom);
			
			currentTexture = bottomShoreTextures;
			
			if(isAlreadyCovered)currentBottomShore++;
			
			if (currentBottomShore >= bottomShoreTextures.length)
			{
				currentBottomShore = 0;
			}
			
			setTile(view.shore_bottom, bottomShoreTextures, currentBottomShore);
		}
		
		private function onShoreLeftClicked(caller:GameSprite):void
		{
			var isAlreadyCovered:Boolean = highlightMe(view.shore_left);
			
			currentTexture = leftShoreTextures;
			
			if(isAlreadyCovered)currentLeftShore++;
			
			if (currentLeftShore >= leftShoreTextures.length)
			{
				currentLeftShore = 0;
			}
			
			setTile(view.shore_left, leftShoreTextures, currentLeftShore);
		}
		
		private function onShoreRightClicked(caller:GameSprite):void
		{
			var isAlreadyCovered:Boolean = highlightMe(view.shore_right);
			
			currentTexture = rightShoreTextures;
			
			if(isAlreadyCovered)currentRightShore++;
			
			if (currentRightShore >= rightShoreTextures.length)
			{
				currentRightShore = 0;
			}
			
			setTile(view.shore_right, rightShoreTextures, currentRightShore);
		}
		
		private function onShoreCornerClicked(caller:GameSprite):void
		{
			var isAlreadyCovered:Boolean = highlightMe(view.shore_corner);
			
			currentTexture = cornerShoreTextures;
			
			if(isAlreadyCovered)currentCornerShore++;
			
			if (currentCornerShore >= cornerShoreTextures.length)
			{
				currentCornerShore = 0;
			}
			
			setTile(view.shore_corner, cornerShoreTextures, currentCornerShore);
		}
		
		
		/////////////////////////////////////////---ridges---/////////////////////////////////////
		private function onRidgeTopClicked(caller:GameSprite):void
		{
			var isAlreadyCovered:Boolean = highlightMe(view.ridges_top);
			
			currentTexture = topRidgeTextures;
			
			if(isAlreadyCovered)currentTopRidge++;
			
			if (currentTopRidge >= topRidgeTextures.length)
			{
				currentTopRidge = 0;
			}
			
			setTile(view.ridges_top, topRidgeTextures, currentTopRidge);
		}
		
		private function onRidgeBottomClicked(caller:GameSprite):void
		{
			var isAlreadyCovered:Boolean = highlightMe(view.ridges_bottom);
			
			currentTexture = bottomRidgeTextures;
			
			if(isAlreadyCovered)currentBottomRidge++;
			
			if (currentBottomRidge >= bottomRidgeTextures.length)
			{
				currentBottomRidge = 0;
			}
			
			setTile(view.ridges_bottom, bottomRidgeTextures, currentBottomRidge);
		}
		
		private function onRidgeLeftClicked(caller:GameSprite):void
		{
			var isAlreadyCovered:Boolean = highlightMe(view.ridges_left);
			
			currentTexture = leftRidgeTextures;
			
			if(isAlreadyCovered)currentLeftRidge++;
			
			if (currentLeftRidge >= leftRidgeTextures.length)
			{
				currentLeftRidge = 0;
			}
			
			setTile(view.ridges_left, leftRidgeTextures, currentLeftRidge);
		}
		
		private function onRidgeRightClicked(caller:GameSprite):void
		{
			var isAlreadyCovered:Boolean = highlightMe(view.ridges_right);
			
			currentTexture = rightRidgeTextures;
			
			if(isAlreadyCovered)currentRightRidge++;
			
			if (currentRightRidge >= rightRidgeTextures.length)
			{
				currentRightRidge = 0;
			}
			
			setTile(view.ridges_right, rightRidgeTextures, currentRightRidge);
		}
		
		private function onRidgeCornerClicked(caller:GameSprite):void
		{
			var isAlreadyCovered:Boolean = highlightMe(view.ridges_corner);
			
			currentTexture = cornerRidgeTextures;
			
			if(isAlreadyCovered)currentCornerRidge++;
			
			if (currentCornerRidge >= cornerRidgeTextures.length)
			{
				currentCornerRidge = 0;
			}
			
			setTile(view.ridges_corner, cornerRidgeTextures, currentCornerRidge);
		}
		///////////////////////////////////////
		
		
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
			setTile(view.rockMC, resourceTextures,currenttiberium);
			
			var a:Array = [];
			//we need to get only the first frame of each tree
			for (var k:String in Assets.trees.list)
			{
				a.push(k);
				
			}
			
			a.sort();
			
			for (var i:int = 0; i < a.length; i++ )
			{
				var tex:Vector.<Texture> = GameAtlas.getTextures(a[i]);
				if (treeTextures == null)
				{
					treeTextures = new Vector.<Texture> ;
				}
				if(tex)treeTextures.push(tex[0]);
			}
			
			setTile(view.treeMC, treeTextures, currentTree);
			
			topShoreTextures = GameAtlas.getTextures("shore_top_low");
			setTile(view.shore_top, topShoreTextures, currentTopShore);
			
			bottomShoreTextures = GameAtlas.getTextures("shore_bottom_low");
			setTile(view.shore_bottom, bottomShoreTextures, currentBottomShore);
			
			leftShoreTextures = GameAtlas.getTextures("shore_left_low");
			setTile(view.shore_left, leftShoreTextures, currentLeftShore);
			
			rightShoreTextures = GameAtlas.getTextures("shore_right_low");
			setTile(view.shore_right, rightShoreTextures, currentRightShore);
			
			cornerShoreTextures = GameAtlas.getTextures("shore_corner_low");
			setTile(view.shore_corner, cornerShoreTextures, currentCornerShore);
			
			
			topRidgeTextures = GameAtlas.getTextures("ridges_top");
			setTile(view.ridges_top, topRidgeTextures, currentTopRidge);
			
			bottomRidgeTextures = GameAtlas.getTextures("ridges_bottom");
			setTile(view.ridges_bottom, bottomRidgeTextures, currentBottomRidge);
			
			leftRidgeTextures = GameAtlas.getTextures("ridges_left");
			setTile(view.ridges_left, leftRidgeTextures, currentLeftRidge);
			
			rightRidgeTextures = GameAtlas.getTextures("ridges_right");
			setTile(view.ridges_right, rightRidgeTextures, currentRightRidge);
			
			cornerRidgeTextures = GameAtlas.getTextures("ridges_corner");
			setTile(view.ridges_corner, cornerRidgeTextures, currentCornerRidge);
		}
		

		
		
		private function setTile(mc:GameSprite, texture:Vector.<Texture>, count:int):void 
		{
			if (mc.img == null)
			{
				mc.img = new Image(texture[count]);
				mc.img.scaleX = mc.img.scaleY = Parameters.gameScale;
			}
			mc.img.texture = texture[count]
			mc.img.width = 35;
			mc.img.height = 35;
			mc.addChild(mc.img);
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
			var isAlreadyCovered:Boolean = highlightMe(view.treeMC);
			
			currentTexture = treeTextures;
			
			if(isAlreadyCovered)currentTree++;
			
			if (currentTree >= treeTextures.length)
			{
				currentTree = 0;
			}
			
			setTile(view.treeMC, treeTextures, currentTree);
			
			
		}
		
		private function highlightMe(mc:GameSprite):Boolean
		{
			var isAlreadyHere:Boolean = false;
			if (view.tileTypeCoverMC.x == mc.x && view.tileTypeCoverMC.y == mc.y)
			{
				isAlreadyHere = true;
			}
			view.tileTypeCoverMC.x = mc.x;
			view.tileTypeCoverMC.y = mc.y;
			view.bucketMC.alpha = 0.5;
			view.bucketMC.touchable = false;
			view.paintCoverMC.x = view.brushMC.x;
			view.paintCoverMC.y = view.brushMC.y;
			return isAlreadyHere
		}
		
		private function onObstacleClicked(caller:GameSprite):void
		{
			var isAlreadyCovered:Boolean = highlightMe(view.rockMC);
			currentTexture = resourceTextures;
			
			
			if(isAlreadyCovered)currenttiberium++;
			
			if (currenttiberium >= resourceTextures.length)
			{
				currenttiberium = 0;
			}
			
			setTile(view.rockMC, resourceTextures,currenttiberium);
			
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
				
				if(phase == "end")removeUnitFromArray(targetRow, targetCol);
			}
			
			eraseTile(targetRow, targetCol, phase);
			
			e.stopPropagation();
		}
		
		private function removeUnitFromArray(_row:int, _col:int):void
		{
			var o:Object;
			var typesArr:Array = ["startVehicles", "startUnits", "startBuildings", "startTurrets" ];
			for (var i:int = 0; i < typesArr.length; i++ )
			{
				for (var j:int = 0; j < Parameters.editObj.team1[typesArr[i]].length; j++ )
				{
					o = Parameters.editObj.team1[typesArr[i]][j];
					if (o)
					{
						if (o.row == _row && o.col == _col)
						{
							o.asset.removeFromParent();
						}
					}
					
				}
				
				for (j = 0; j < Parameters.editObj.team2[typesArr[i]].length; j++ )
				{
					o = Parameters.editObj.team1[typesArr[i]][j];
					if (o)
					{
						if (o.row == _row && o.col == _col)
						{
							o.asset.removeFromParent();
						}
					}
					
				}
			}
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
				fillTile(targetRow, targetCol, phase);
			}
			
			
			
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
				
				if (node.shoreTile)
				{
					node.shoreTile.dispose();
					node.shoreTile.removeFromParent();
					node.shoreTile = null;
					node.walkable = true;
				}
				
				if (node.cliffTile)
				{
					node.cliffTile.dispose();
					node.cliffTile.removeFromParent();
					node.cliffTile = null;
					node.walkable = true;
				}
				
				
			}
		}
		
		
		
		private function fillTile(targetRow:int, targetCol:int, _phase:String = ""):void 
		{
			if (Parameters.boardArr[targetRow] && Parameters.boardArr[targetRow][targetCol])
			{
				var rnd:int = Math.random() * currentTexture.length;
				var node:Node = Node(Parameters.boardArr[targetRow][targetCol]);
				var currentNum:int = 0;
				
				if (currentTexture == topRidgeTextures || currentTexture == bottomRidgeTextures || currentTexture == leftRidgeTextures || currentTexture == rightRidgeTextures || currentTexture == cornerRidgeTextures)
				{
					if (_phase == "begin")
					{
						if (currentTexture == topRidgeTextures)
						{
							n = getShoreN("ridges_top_", currentTopRidge);
						}

						if (currentTexture == bottomRidgeTextures)
						{
							n = getShoreN("ridges_bottom_", currentBottomRidge);
						}
						
						if (currentTexture == leftRidgeTextures)
						{
							n = getShoreN("ridges_left_", currentLeftRidge);
						}
						if (currentTexture == rightRidgeTextures)
						{
							n = getShoreN("ridges_right_", currentRightRidge);
						}
						if (currentTexture == cornerRidgeTextures)
						{
							n = getShoreN("ridges_corner_", currentCornerRidge);
						}
						
						var o:Array = Assets.ridges.list[n].gridBuild;
						shoreCliffObstacle = GameAtlas.createMovieClip(n);
						shoreCliffObstacle.x = node.col * Parameters.tileSize;
						shoreCliffObstacle.y = node.row * Parameters.tileSize;
						shoreCliffObstacle.width = o[0].length * Parameters.tileSize;// * Parameters.gameScale;
						shoreCliffObstacle.height = o.length * Parameters.tileSize;// * Parameters.gameScale;
						Board.mapContainerArr[Board.GROUND_LAYER].addChild(shoreCliffObstacle);
						
					}
					if (_phase == "move")
					{
						if (shoreCliffObstacle)
						{
							shoreCliffObstacle.x = node.col * Parameters.tileSize;
							shoreCliffObstacle.y = node.row * Parameters.tileSize;
						}
					}
					if (_phase == "end")
					{
						if (shoreCliffObstacle) 
						{
							shoreCliffObstacle.removeFromParent();
							shoreCliffObstacle = null;
						}
						
						if (currentTexture == topRidgeTextures)
						{
							n = getShoreN("ridges_top_", currentTopRidge);
							node.num = currentTopRidge;
						}

						if (currentTexture == bottomRidgeTextures)
						{
							n = getShoreN("ridges_bottom_", currentBottomRidge);
							node.num = currentBottomRidge;
						}
						
						if (currentTexture == leftRidgeTextures)
						{
							n = getShoreN("ridges_left_", currentLeftRidge);
							node.num = currentLeftRidge;
						}
						if (currentTexture == cornerRidgeTextures)
						{
							n = getShoreN("ridges_right_", currentRightRidge);
							node.num = currentRightRidge;
						}
						if (currentTexture == cornerRidgeTextures)
						{
							n = getShoreN("ridges_corner_", currentCornerRidge);
							node.num = currentCornerRidge;
						}
						
						o = Assets.ridges.list[n].gridBuild;
						
						node.cliffTile = new Image(GameAtlas.getTexture(n));
						node.cliffTile.x = node.col * Parameters.tileSize;
						node.cliffTile.y = node.row * Parameters.tileSize;
						node.walkable = false;
						node.cliffTile.width = o[0].length * Parameters.tileSize;// * Parameters.gameScale;
						node.cliffTile.height = o.length * Parameters.tileSize;// * Parameters.gameScale;
						node.cliffTile.name = n;
						Board.mapContainerArr[Board.GROUND_LAYER].addChild(node.cliffTile);
					}
				}
				
				
				if (currentTexture == topShoreTextures || currentTexture == bottomShoreTextures || currentTexture == leftShoreTextures || currentTexture == rightShoreTextures || currentTexture == cornerShoreTextures)
				{
					if (_phase == "begin")
					{
						if (currentTexture == topShoreTextures)
						{
							n = getShoreN("shore_top_low_", currentTopShore);
						}

						if (currentTexture == bottomShoreTextures)
						{
							n = getShoreN("shore_bottom_low_", currentBottomShore);
						}
						
						if (currentTexture == leftShoreTextures)
						{
							n = getShoreN("shore_left_low_", currentLeftShore);
						}
						if (currentTexture == rightShoreTextures)
						{
							n = getShoreN("shore_right_low_", currentRightShore);
						}
						if (currentTexture == cornerShoreTextures)
						{
							n = getShoreN("shore_corner_low_", currentCornerShore);
						}
						
						o = Assets.shores.list[n].gridBuild;
						shoreCliffObstacle = GameAtlas.createMovieClip(n);
						shoreCliffObstacle.x = node.col * Parameters.tileSize;
						shoreCliffObstacle.y = node.row * Parameters.tileSize;
						shoreCliffObstacle.width = o[0].length * Parameters.tileSize;// * Parameters.gameScale;
						shoreCliffObstacle.height = o.length * Parameters.tileSize;// * Parameters.gameScale;
						Board.mapContainerArr[Board.GROUND_LAYER].addChild(shoreCliffObstacle);
						
					}
					if (_phase == "move")
					{
						if (shoreCliffObstacle)
						{
							shoreCliffObstacle.x = node.col * Parameters.tileSize;
							shoreCliffObstacle.y = node.row * Parameters.tileSize;
						}
					}
					if (_phase == "end")
					{
						if (shoreCliffObstacle) 
						{
							shoreCliffObstacle.removeFromParent();
							shoreCliffObstacle = null;
						}
						
						if (currentTexture == topShoreTextures)
						{
							n = getShoreN("shore_top_low_", currentTopShore);
							node.num = currentTopShore;
						}

						if (currentTexture == bottomShoreTextures)
						{
							n = getShoreN("shore_bottom_low_", currentBottomShore);
							node.num = currentBottomShore;
						}
						
						if (currentTexture == leftShoreTextures)
						{
							n = getShoreN("shore_left_low_", currentLeftShore);
							node.num = currentLeftShore;
						}
						if (currentTexture == rightShoreTextures)
						{
							n = getShoreN("shore_right_low_", currentRightShore);
							node.num = currentRightShore;
						}
						if (currentTexture == cornerShoreTextures)
						{
							n = getShoreN("shore_corner_low_", currentCornerShore);
							node.num = currentCornerShore;
						}
						
						o = Assets.shores.list[n].gridBuild;
						
						node.shoreTile = new Image(GameAtlas.getTexture(n));
						node.shoreTile.x = node.col * Parameters.tileSize;
						node.shoreTile.y = node.row * Parameters.tileSize;
						node.walkable = false;
						node.shoreTile.width = o[0].length * Parameters.tileSize;// * Parameters.gameScale;
						node.shoreTile.height = o.length * Parameters.tileSize;// * Parameters.gameScale;
						node.shoreTile.name = n;
						Board.mapContainerArr[Board.GROUND_LAYER].addChild(node.shoreTile);
					}
				}
				
				if (currentTexture == treeTextures || currentTexture == resourceTextures)
				{
					if (_phase == "end")
					{
						var n:String = "";
						
						if (currentTexture == treeTextures) 
						{
							currentNum = currentTree;
							n = getShoreN("tree-", currentNum);
							n += "_default00"
						}
						if (currentTexture == resourceTextures)
						{
							currentNum = currenttiberium;
							n = getShoreN("tiberium_default", currentNum);
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
							node.obstacleTile = GameAtlas.createMovieClip(n);
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
						node.obstacleTile.scaleX = node.obstacleTile.scaleY = Parameters.gameScale;
						node.obstacleTile.name = n;
						node.num = currentNum;
						Board.mapContainerArr[Board.GROUND_LAYER].addChild(node.obstacleTile);
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
					
					
					node.groundTile.dispose();
					node.groundTile.texture = currentTexture[rnd];
				}
				
			}
		}
		
		
		private function getShoreN( _name:String, _count:int):String 
		{

			var currentNum:int = _count;
			var str:String = ""
			if (currentNum < 10)
			{
				str = "0" + currentNum;
			}
			else
			{
				str = String(currentNum);
			}
			var n:String = _name + str;
			
			return n
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
			HUD.currentTeam = caller.index;
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