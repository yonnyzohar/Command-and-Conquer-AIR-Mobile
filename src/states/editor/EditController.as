package states.editor
{
	import com.randomMap.RandomMapGenerator;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import global.GameAtlas;
	import global.map.Node;
	import global.map.SpiralBuilder;
	import starling.textures.Texture;
	import states.game.stats.BuildingsStats;
	import states.game.stats.InfantryStats;
	import states.game.stats.LevelManager;
	import states.game.stats.TurretStats;
	import states.game.stats.VehicleStats;
	
	import global.Parameters;
	import global.GameAtlas;
	import global.map.mapTypes.Board;
	import global.ui.hud.HUD;
	import global.utilities.FileSaver;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	

	public class EditController extends Sprite
	{
		
		private var baordMC:Board;
		private var hud:HUD;
		private var model:EditModel;
		private var currentImage:EditAssetObj;
		private var lastLoc:Point;
		
		private var unitsArr:Array = [];
		private var controlsPane:ControlsPane;
		private var editTeamsArr:Array;
		
		public function EditController()
		{
			LevelManager.init();
			//LevelManager.currentlevelData = LevelManager.getLevelData(0);
			LevelManager.loadRelevantAssets(LevelManager.currentlevelData, onLoadAssetsComplete);
		}
		
		private function onLoadAssetsComplete():void
		{
			unitsArr.splice(0);
			model = new EditModel();
			baordMC = Board.getInstance();
			
			if(Parameters.editLoad)
			{
				baordMC.init(false,LevelManager.currentlevelData.map);
			}
			else
			{
				var randomMapGenerator:RandomMapGenerator = new RandomMapGenerator();
				baordMC.init(true, randomMapGenerator.createRandomMap(Parameters.numRows, Parameters.numCols));
			}
			
			
			hud = new HUD(true);
			hud.init();
			hud.addMiniMap();
			
			
			var currentBuildings:Dictionary = populateCorrectTech(BuildingsStats.dict);
			var currentTurrets:Dictionary   = populateCorrectTech(TurretStats.dict);
			var currentInfantry:Dictionary  = populateCorrectTech(InfantryStats.dict);
			var currentVehicles:Dictionary  = populateCorrectTech(VehicleStats.dict);
			
			
			
			hud.initEdit(currentBuildings, currentTurrets, currentInfantry, currentVehicles);
			hud.unitsContainer.addEventListener("SLOT_SELECTED", onUnitSelected);
			hud.buildingsContainer.addEventListener("SLOT_SELECTED", onBuildingSelected);
			
			
			Board.mapContainerArr[Board.GROUND_LAYER].touchable = false;
			Board.mapContainerArr[Board.OBSTACLE_LAYER].touchable = false;
			Board.mapContainerArr[Board.UNITS_LAYER].touchable = false;
			Board.mapContainerArr[Board.EFFECTS_LAYER].touchable = false;
			
			Parameters.mapHolder.addChild(Board.mapContainerArr[Board.GROUND_LAYER]);
			Parameters.mapHolder.addChild(Board.mapContainerArr[Board.OBSTACLE_LAYER]);
			Parameters.mapHolder.addChild(Board.mapContainerArr[Board.UNITS_LAYER]);
			Parameters.mapHolder.addChild(Board.mapContainerArr[Board.EFFECTS_LAYER]);
			
			Parameters.editObj = LevelManager.currentlevelData;
			
			
			createStartAssets();
			
			

			init();
			
			setInterval(function():void
			{
				//trace("saving!")
				onSaveClicked();
			},30000);
		}
		
		private function populateCorrectTech(dict:Dictionary):Dictionary 
		{
			var returnDict:Dictionary = new Dictionary();
			for (var k in dict)
			{
				if (dict[k].tech <= LevelManager.currentlevelData.tech)
				{
					returnDict[k] = dict[k];
				}
			}
			
			return returnDict;
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
			var names:Array = ["vehicle", "infantry", "building", "turret"];
			
			var teams:Array = Parameters.editObj.teams;
			
			for (var j:int = 0; j < teams.length; j++ )
			{
				var team:Object = teams[j];
				var color:String = team.color;
				
				for (var g:int = 0; g < typesArr.length; g++ )
				{
					var curType:String = typesArr[g];
					
					for(i = 0; i < team[curType].length; i++ )
					{
						obj = team[curType][i];
						
						selRow = obj.row;
						selCol = obj.col;
						
						placeImage( names[g], obj.name, color);
						currentImage.x =  (Parameters.tileSize * selCol) ;
						currentImage.y =  (Parameters.tileSize * selRow) ;
						currentImage.model.row = selRow;
						currentImage.model.col = selCol;
						currentImage.model.name = obj.name;
						obj.asset = currentImage;
					}
				}
			}
			currentImage = null;
			
		}
		
		private function removeBadData():void
		{
			var teams:Array = Parameters.editObj.teams;
			var typesArr:Array = ["startVehicles", "startUnits", "startBuildings", "startTurrets" ];
			var obj:Object;
			
			for (var j:int = 0; j < teams.length; j++ )
			{
				var team:Object = teams[j];
				for (var g:int = 0; g < typesArr.length; g++ )
				{
					var curType:String = typesArr[g];
					
					for(var i:int = 0; i < team[curType].length; i++ )
					{
						obj = team[curType][i];
						delete obj.asset;
					}
				}
			}
		}
		
		private function onBuildingSelected(e:Event):void
		{
			model.currentUnit = hud.buildingsContainer.currentUnit;
			model.currentUnitName = hud.buildingsContainer.currentUnitName;
			model.currentType = hud.buildingsContainer.selectedSlot.contextType;
			
			var gdiOrNod:String = "gdi"
			if (HUD.currentTeam == 2)
			{
				gdiOrNod = "nod";
			}
			placeImage(model.currentType, model.currentUnit, gdiOrNod);
			

		}
		
		private function onUnitSelected(e:Event):void
		{
			model.currentUnit = hud.unitsContainer.currentUnit;
			model.currentUnitName = hud.unitsContainer.currentUnitName;
			model.currentType = hud.unitsContainer.selectedSlot.contextType;
			
			
			
			placeImage(model.currentType, model.currentUnit, Parameters.editObj.teams[HUD.currentTeam].color);
			
			
		}
		
		private function placeImage(currentType:String, currentUnit:String, color:String):void 
		{
			trace("edit: " + currentType + ", " + currentUnit + " " + color);
			currentImage = new EditAssetObj()
			
			if (currentType == "infantry")
			{
				currentImage.addChild(new Image(GameAtlas.getTexture(currentUnit + "_stand", color)));
				
			}
			if (currentType == "vehicle")
			{
				currentImage.addChild(new Image(GameAtlas.getTexture(currentUnit + "_move", color)));
				var tex:Texture = GameAtlas.getTexture(currentUnit + "_turret", color);
				if (tex)
				{
					currentImage.addChild(new Image(tex));
				}
				
			}
			if (currentType == "building" || currentType == "turret")
			{
				currentImage.addChild(new Image(GameAtlas.getTexture(currentUnit+"_healthy", color)));
			}
			
			currentImage.model.name = currentUnit;
			currentImage.model.type = currentType;
			currentImage.model.color = color;
			
			currentImage.scaleX = currentImage.scaleY = Parameters.gameScale;
			Board.mapContainerArr[Board.UNITS_LAYER].addChild(currentImage);
		
			
		}
			
		public function init():void
		{
			
			hud.ui.x = Parameters.flashStage.stageWidth - hud.getWidth();
			Parameters.theStage.addEventListener(TouchEvent.TOUCH, onStageTouch);
			Parameters.gameHolder.addChild(Parameters.mapHolder);
			Parameters.gameHolder.addChild(hud.ui);
			Parameters.gameHolder.addChild(hud.miniMap);
			
			var colors:Array = [];
			for (var i:int = 0; i < Parameters.editObj.teams.length; i++ )
			{
				colors.push(Parameters.editObj.teams[i].color);
			}
			
			
			
			controlsPane = new ControlsPane(colors);
			
			Parameters.gameHolder.addChild(controlsPane.view);
			controlsPane.addEventListener("GO_CLICKED", onGoClicked);
			controlsPane.addEventListener("EXIT_CLICKED", onExitClicked);
			controlsPane.addEventListener("SAVE_CLICKED", onSaveClicked);
			controlsPane.addEventListener("DETAILS_PANEL_CLICKED", onDetailsPanelClicked);
			
			
					

		}
		
		private function onDetailsPanelClicked(e:Event):void 
		{
			//detailsPanel.view.visible = true;
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
					
					
					addToCorrectArray(currentImage);
					
					
					unitsArr.push(currentImage);
					currentImage = null;
				}
			}
			
			e.stopPropagation();
		}
		
		
		
		private function addToCorrectArray(currentImage:EditAssetObj):void 
		{
			var o:Object = {name : currentImage.model.name, row : currentImage.model.row, col: currentImage.model.col, asset: currentImage}
			var currentTeam:Object = Parameters.editObj.teams[HUD.currentTeam];

				if(model.currentType == "infantry")
				{
					currentTeam.startUnits.push(o );
				}
				
				if( model.currentType == "vehicle")
				{
					currentTeam.startVehicles.push(o );
				}
				
				if(model.currentType == "building")
				{
					currentTeam.startBuildings.push(o );
				}
				
				if( model.currentType == "turret")
				{
					currentTeam.startTurrets.push(o );
				}
				

		}
		
		
		
		
		
		private function onGoClicked(e:Event):void
		{
			fillObject();
			dispatchEvent(new Event("DONE_EDITING"));
		}
		
		private function fillObject():void
		{
			removeBadData();
			Parameters.editObj.numTiles = Parameters.numRows;
			Parameters.editObj.map = getMap();
			
			////trace(JSON.stringify(Parameters.editObj));
			
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
						texName = node.cliffTile.name;
						mapNode.obstacleTextureName = texName;
						a.push(mapNode);
					}
					
					
					if (node.obstacleTile)
					{
						mapNode.groundTileTexture = "grass";
						texName = node.obstacleTile.name;
						
						var nme:String = texName.substr(0, texName.indexOf("_"))
						//trace(texName, nme, node.num);
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
		
		private function onSaveClicked(e:Event = null):void
		{
			fillObject();
			FileSaver.getInstance().save("savedLevel.json", JSON.stringify(Parameters.editObj), File.desktopDirectory);

		}
		
		override public function dispose():void
		{
			for(var i:int = 0; i <unitsArr.length; i++)
			{
				unitsArr[i].removeFromParent(true);
				unitsArr[i] = null;
			}
			unitsArr = null;
			
			hud.removeEventListener("UNIT_SELECTED", onUnitSelected);
			hud.removeEventListener("BUILDING_SELECTED", onUnitSelected);
			controlsPane.removeEventListener("GO_CLICKED", onGoClicked);
			controlsPane.removeEventListener("EXIT_CLICKED", onExitClicked);
			controlsPane.removeEventListener("SAVE_CLICKED", onSaveClicked);
			controlsPane.removeEventListener("DETAILS_PANEL_CLICKED", onDetailsPanelClicked);
			Parameters.theStage.removeEventListener(TouchEvent.TOUCH, onStageTouch);
			hud.ui.removeFromParent();

			hud.dispose();
			hud = null;
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