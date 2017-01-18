package states.editor
{
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import global.GameAtlas;
	import global.map.Node;
	import global.map.SpiralBuilder;
	import starling.textures.Texture;
	import states.game.stats.LevelManager;
	import states.game.teamsData.TeamsLoader;
	
	import global.Parameters;
	import global.GameAtlas;
	import global.map.mapTypes.Board;
	import global.ui.hud.HUDView;
	import global.utilities.FileSaver;
	import global.utilities.GlobalEventDispatcher;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	

	public class EditController extends Sprite
	{
		private var detailsPanel:DetailsPanelController;
		private var baordMC:Board;
		private var view:HUDView;
		private var model:EditModel;
		private var currentImage:EditAssetObj;
		private var lastLoc:Point;
		
		private var unitsArr:Array = [];
		private var controlsPane:ControlsPane;
		
		public function EditController()
		{
			//LevelManager.init();
			TeamsLoader.init();
			//LevelManager.currentlevelData = LevelManager.getLevelData(0);
			LevelManager.loadRelevantAssets(LevelManager.currentlevelData, onLoadAssetsComplete);
		}
		
		private function onLoadAssetsComplete():void
		{
			unitsArr.splice(0);
			model = new EditModel();
			baordMC = Board.getInstance();
			baordMC.init(true);
			view = HUDView.getInstance();
			view.init();
			view.addMiniMap();
			view.initEdit();
			view.unitsContainer.addEventListener("SLOT_SELECTED", onUnitSelected);
			view.buildingsContainer.addEventListener("SLOT_SELECTED", onBuildingSelected);
			
			Parameters.editObj = new Object();
			Parameters.editObj.team1 = new Object();
			Parameters.editObj.team2 = new Object();
			
			Parameters.editObj.team1.startVehicles = [];
			Parameters.editObj.team1.startUnits = [];
			Parameters.editObj.team1.startBuildings = [];
			Parameters.editObj.team1.startTurrets = [];
			
			Parameters.editObj.team2.startVehicles = [];
			Parameters.editObj.team2.startUnits = [];
			Parameters.editObj.team2.startBuildings = [];
			Parameters.editObj.team2.startTurrets = [];
			
			//["startVehicles", "startUnits", "startBuildings", "startTurrets" ]
			
			if (Parameters.editLoad)
			{
				createStartAssets();
			}
			

			init()
		}
		
		public function createStartAssets():void
		{
			var i:int = 0;
			var selRow:int;
			var selCol:int;
			var teamsData:Object;
			var obj:Object;
			var placementsArr:Array;
			var typesArr:Array = ["startVehicles", "startUnits", "startBuildings", "startTurrets" ];
			var names:Array = ["vehicle", "infantry", "building", "turret" ];
			var teams:Array = ["team1", "team2"];
			var gdiNod:Array = ["gdi", "nod"];
			var teamsArr:Array = [Parameters.humanTeam, Parameters.pcTeam]
			
			Parameters.editObj = LevelManager.currentlevelData;
			
			for (var j:int = 0; j < teams.length; j++ )
			{
				for (var g:int = 0; g < typesArr.length; g++ )
				{
					var curType:String = typesArr[g];
					
					for(i = 0; i < LevelManager.currentlevelData[teams[j]][curType].length; i++ )
					{
						obj = LevelManager.currentlevelData[teams[j]][curType][i];
						
						selRow = obj.row;
						selCol = obj.col;
						
			
						placeImage( names[g], obj.name, gdiNod[j]);
						currentImage.x =  (Parameters.tileSize * selCol) ;
						currentImage.y =  (Parameters.tileSize * selRow) ;
						currentImage.model.row = selRow;
						currentImage.model.col = selCol;
						currentImage.model.name = obj.name;
						teamsArr[j].push(currentImage);
					}
				}
			}
			
			
		}
		
		private function onBuildingSelected(e:Event):void
		{
			model.currentUnit = view.buildingsContainer.currentUnit;
			model.currentUnitName = view.buildingsContainer.currentUnitName;
			model.currentType = view.buildingsContainer.selectedSlot.contextType;
			
			var gdiOrNod:String = "gdi"
			if (HUDView.currentTeam == 2)
			{
				gdiOrNod = "nod";
			}
			placeImage(model.currentType, model.currentUnit, gdiOrNod);
			

		}
		
		private function onUnitSelected(e:Event):void
		{
			model.currentUnit = view.unitsContainer.currentUnit;
			model.currentUnitName = view.unitsContainer.currentUnitName;
			model.currentType = view.unitsContainer.selectedSlot.contextType;
			var gdiOrNod:String = "gdi"
			if (HUDView.currentTeam == 2)
			{
				gdiOrNod = "nod";
			}
			placeImage(model.currentType, model.currentUnit, gdiOrNod);
			
			
		}
		
		private function placeImage(currentType:String, currentUnit:String, owner:String):void 
		{
			try {
				currentImage = new EditAssetObj()
			
				if (currentType == "infantry")
				{
					currentImage.addChild(new Image(GameAtlas.getTexture(currentUnit + "_stand", owner)));
					
				}
				if (currentType == "vehicle")
				{
					currentImage.addChild(new Image(GameAtlas.getTexture(currentUnit + "_move", owner)));
					var tex:Texture = GameAtlas.getTexture(currentUnit + "_turret", owner);
					if (tex)
					{
						currentImage.addChild(new Image(tex));
					}
					
				}
				if (currentType == "building" || currentType == "turret")
				{
					currentImage.addChild(new Image(GameAtlas.getTexture(currentUnit+"_healthy", owner)));
				}
				
				currentImage.model.name = currentUnit;
				currentImage.model.type = currentType;
				currentImage.model.owner = owner;
				
				currentImage.scaleX = currentImage.scaleY = Parameters.gameScale;
				Parameters.mapHolder.addChild(currentImage);
			}
			catch (e:Error)
			{
				currentImage = null;
			}
			
			
		}
			
		public function init():void
		{
			//Parameters.loadingScreen.init();
			
					
			view.x = Parameters.flashStage.stageWidth - view.getWidth();
			Parameters.theStage.addEventListener(TouchEvent.TOUCH, onStageTouch);
			Parameters.gameHolder.addChild(Parameters.mapHolder);
			Parameters.gameHolder.addChild(view);
			
			controlsPane = new ControlsPane();
			
			Parameters.gameHolder.addChild(controlsPane.view);
			controlsPane.addEventListener("GO_CLICKED", onGoClicked);
			controlsPane.addEventListener("EXIT_CLICKED", onExitClicked);
			controlsPane.addEventListener("SAVE_CLICKED", onSaveClicked);
			controlsPane.addEventListener("DETAILS_PANEL_CLICKED", onDetailsPanelClicked);
			
			detailsPanel = new DetailsPanelController();
			Parameters.gameHolder.addChild(detailsPanel.view);
			detailsPanel.view.width = Parameters.flashStage.stageWidth;
			detailsPanel.view.height = Parameters.flashStage.stageHeight;
					

		}
		
		private function onDetailsPanelClicked(e:Event):void 
		{
			detailsPanel.view.visible = true;
		}
		
		
		
		private function onStageTouch(e:TouchEvent):void
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
			
			if(currentImage != null)
			{
				if(location != null)
				{
					lastLoc = location;
					
					boardCoordinates = Parameters.mapHolder.globalToLocal(new Point(lastLoc.x, lastLoc.y));
					
					targetCol = (boardCoordinates.x / Parameters.tileSize)
					targetRow = (boardCoordinates.y / Parameters.tileSize)
					
					currentImage.x =  (Parameters.tileSize * targetCol) ;
					currentImage.y =  (Parameters.tileSize * targetRow) ;
				}
				
				if(end)
				{
					currentImage.model.row = targetRow;
					currentImage.model.col = targetCol;
					
					if (HUDView.currentTeam == 1)
					{
						Parameters.humanTeam.push(currentImage);
					}
					else
					{
						Parameters.pcTeam.push(currentImage);
					}
					
					addToCorrectArray(currentImage);
					
					
					unitsArr.push(currentImage);
					currentImage = null;
				}
			}
			
			e.stopPropagation();
		}
		
		private function addToCorrectArray(currentImage:EditAssetObj):void 
		{
			var o:Object = {name : currentImage.model.name, row : currentImage.model.row, col: currentImage.model.col }

			if(HUDView.currentTeam == 1)
			{
				//["startVehicles", "startUnits", "startBuildings", "startTurrets" ];
				 
				
				if(model.currentType == "infantry")
				{
					Parameters.editObj.team1.startUnits.push(o );
				}
				
				if( model.currentType == "vehicle")
				{
					Parameters.editObj.team1.startVehicles.push(o );
				}
				
				if(model.currentType == "building")
				{
					Parameters.editObj.team1.startBuildings.push(o );
				}
				
				if( model.currentType == "turret")
				{
					Parameters.editObj.team1.startTurrets.push(o );
				}
				
			}
			else
			{
				if(model.currentType == "infantry")
				{
					Parameters.editObj.team2.startUnits.push(o);
				}
				
				if( model.currentType == "vehicle")
				{
					Parameters.editObj.team2.startVehicles.push(o );
				}
				
				if(model.currentType == "building")
				{
					Parameters.editObj.team2.startBuildings.push(o );
				}
				
				if( model.currentType == "turret")
				{
					Parameters.editObj.team2.startTurrets.push(o );
				}
				
			}
		}
		
		
		
		
		
		private function onGoClicked(e:Event):void
		{
			fillObject();
			dispatchEvent(new Event("DONE_EDITING"));
		}
		
		private function fillObject():void
		{
			Parameters.editObj.tech = 5;
			Parameters.editObj.team1.teamName =  "gdi";
			Parameters.editObj.team2.teamName =  "nod";
			
			Parameters.editObj.team1.AiBehaviour = DetailsPanelController.team1Behaviour;
			Parameters.editObj.team2.AiBehaviour = DetailsPanelController.team2Behaviour;
			
			Parameters.editObj.team1.Agent = DetailsPanelController.team1Controller;
			Parameters.editObj.team2.Agent = DetailsPanelController.team2Controller;
			
			Parameters.editObj.team1.cash = DetailsPanelController.team1StartCash;
			Parameters.editObj.team2.cash = DetailsPanelController.team2StartCash;
			Parameters.editObj.numTiles = Parameters.numRows;
			Parameters.editObj.map = getMap();
			
			//trace(JSON.stringify(Parameters.editObj));
			
		}
		
		private function getMap():Array 
		{
			var a:Array = [];
			var node:Node;
			var mapNode:Object;
			
			for (var row:int = 0; row <  Parameters.boardArr.length; row++ )
			{
				
				for (var col:int = 0; col <  Parameters.boardArr[row].length; col++ )
				{
					node = Node(Parameters.boardArr[row][col]);
					mapNode = { };
					mapNode.walkable = node.walkable;
					mapNode.regionNum = node.regionNum;
					mapNode.row = row;
					mapNode.col = col;
					
					if (node.shoreTile)
					{
						mapNode.groundTileTexture = "grass";
						var texName:String = node.shoreTile.name;
						mapNode.obstacleTextureName = texName;
						a.push(mapNode);
					}
					
					if ( node.cliffTile)
					{
						mapNode.groundTileTexture = "grass";
						var texName:String = node.cliffTile.name;
						mapNode.obstacleTextureName = texName;
						a.push(mapNode);
					}
					
					
					if (node.obstacleTile)
					{
						mapNode.groundTileTexture = "grass";
						var texName:String = node.obstacleTile.name;
						
						var nme:String = texName.substr(0, texName.indexOf("_"))
						trace(texName, nme, node.num);
						mapNode.textureFrame = node.num;
						mapNode.obstacleTextureName = texName;
						a.push(mapNode);
						
					}
					else if(node.isWater)
					{
						mapNode.groundTileTexture = "water";
						a.push(mapNode);
					}
					
					
					
					
					//var row:int = obj.row;
					//var col:int = obj.col;
					//var textureName:String = obj.textureName;
					//var textureFrame:int = obj.textureFrame;
				}
			}
			
			return a;
		}
		
		private function onExitClicked(e:Event):void
		{
			dispatchEvent(new Event("EDITING_CANCELED"));
		}
		
		private function onSaveClicked(e:Event):void
		{
			fillObject();
			FileSaver.getInstance().save("savedLevel.json", JSON.stringify(Parameters.editObj));

		}
		
		override public function dispose():void
		{
			for(var i:int = 0; i <unitsArr.length; i++)
			{
				unitsArr[i].removeFromParent(true);
				unitsArr[i] = null;
			}
			unitsArr = null;
			
			view.removeEventListener("UNIT_SELECTED", onUnitSelected);
			view.removeEventListener("BUILDING_SELECTED", onUnitSelected);
			controlsPane.removeEventListener("GO_CLICKED", onGoClicked);
			controlsPane.removeEventListener("EXIT_CLICKED", onExitClicked);
			controlsPane.removeEventListener("SAVE_CLICKED", onSaveClicked);
			controlsPane.removeEventListener("DETAILS_PANEL_CLICKED", onDetailsPanelClicked);
			Parameters.theStage.removeEventListener(TouchEvent.TOUCH, onStageTouch);
			view.removeFromParent();

			view.dispose();
			view = null;
			model = null;
			
			if(currentImage)
			{
				currentImage.dispose();
			}
			controlsPane.view.removeFromParent();
			controlsPane.dispose();		
			controlsPane = null;
			currentImage= null;
			lastLoc= null;
			
			super.dispose();
		}
	}
}