package states.game.ui
{
	import flash.geom.Point;
	import flash.utils.getTimer;
	import global.enums.Agent;
	import global.enums.MouseStates;
	import global.map.Node;
	import global.ui.hud.TeamBuildManager;
	import global.utilities.GlobalEventDispatcher;
	import global.utilities.KeyboardController;
	import global.utilities.MapMover;
	import states.game.entities.units.ShootingUnit;
	import states.game.teamsData.TeamObject;
	
	import global.Methods;
	import global.Parameters;
	import global.GameAtlas;
	import global.map.SpiralBuilder;
	import global.pools.PoolsManager;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	import states.game.entities.GameEntity;
	import states.game.entities.buildings.Building;

	public class UnitSelectionManager extends EventDispatcher
	{
		private static var instance:UnitSelectionManager = new UnitSelectionManager();
		private var recSelector:RectangleSelector = new RectangleSelector();
		private var startTouchTime:Number;
		private var endTouchTime:Number;
		private var hitMC:MovieClip;
		private var startDragCircle:MovieClip;
		
		public function UnitSelectionManager()
		{
			if (instance)
			{
				throw new Error("Singleton and can only be accessed through Singleton.getInstance()");
			}
		}
		
		public static function getInstance():UnitSelectionManager
		{
			return instance;
		}

		public function init():void
		{
			Methods.rightClickFNCTN = onRightMouseBTNClicked;
			
			hitMC = GameAtlas.createMovieClip("hitMC");
			hitMC.scaleX = hitMC.scaleY = 1;
			hitMC.pivotX =  hitMC.width * (0.5);
			hitMC.pivotY =  hitMC.height* (0.5);
			Starling.juggler.add(hitMC);
			hitMC.stop();
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
		
		
		private function onStageTouch(e:TouchEvent):void 
		{
			//var start:Touch  = e.getTouch(this, TouchPhase.BEGAN);
			//var moving:Touch = e.getTouch(this, TouchPhase.MOVED);
			//var end:Touch    = e.getTouch(this, TouchPhase.ENDED);
			
			var startMulti:Vector.<Touch> = e.getTouches(Parameters.theStage, TouchPhase.BEGAN);
			var movingMulti:Vector.<Touch> = e.getTouches(Parameters.theStage, TouchPhase.MOVED);
			var endMulti:Vector.<Touch> = e.getTouches(Parameters.theStage, TouchPhase.ENDED);
			var location:Point;
			var i:int = 0;
			
			//PAN!!!
			if (MouseStates.currentState == MouseStates.SELECT)
			{
				if(startMulti != null && startMulti.length != 0)
				{
					location = startMulti[0].getLocation(Parameters.mapHolder);
					if(startMulti.length >= 2)
					{
						//mapMover.onPanUpdate(location.x, location.y);
						recSelector.stopDrawing(false);
					}
					else
					{
						startTouchTime = getTimer();
						beginDrawingRectangle(location.x, location.y)
						
					}
				}
				
				
				
				if(movingMulti != null && movingMulti.length != 0)
				{
					location = movingMulti[0].getLocation(Parameters.mapHolder);
					if(movingMulti.length >= 2)
					{
						//mapMover.onPanUpdate(location.x, location.y);
						recSelector.stopDrawing(false);
					}
					else
					{
						recSelector.move(location.x, location.y);
					}
				}
			

			
			
				if(endMulti != null && endMulti.length != 0)
				{
					killSelectionCircle()
					location = endMulti[0].getLocation(Parameters.mapHolder);
					MouseStates.currentState = MouseStates.REG_PLAY
					
					if(endMulti.length >= 2)
					{
						//mapMover.onPanUpdate(location.x, location.y);
						recSelector.stopDrawing(false);
					}
					else
					{
						
						endTouchTime = getTimer();
						
						var targetCol:int = location.x / Parameters.tileSize;
						var targetRow:int = location.y / Parameters.tileSize;
						
						
						var click:Boolean = false;
						
						if((endTouchTime - startTouchTime) < 200)
						{
							click = true;
						}
						
						if(recSelector.width > 10 || recSelector.height > 10)
						{
							click = false;
						}
						
						recSelector.stopDrawing(click);
						
						Parameters.currentSquad = recSelector.unitsArray;
						
						//if this is a touch and not a scroll
						if(click)
						{
							sendUnitsToDest(targetCol, targetRow);
							
						}
						else
						{

							PoolsManager.selectorCirclesPool.returnAllAssets();
							
							var currentPlayer:GameEntity;
							
							
							for(i = 0; i < Parameters.humanTeam.length; i++)
							{
								currentPlayer = Parameters.humanTeam[i];
								currentPlayer.deselect();
							}
							
							
							for(i = 0; i <Parameters.currentSquad.length; i++)
							{
								currentPlayer = Parameters.currentSquad[i];
								currentPlayer.selected(i==0);
							}

						}
						
						
						recSelector.removeFromParent();
					}
				}
			}
			else
			{
				if (startMulti != null && startMulti.length != 0)
				{
					startTouchTime = getTimer();
				}
				if (endMulti != null && endMulti.length != 0)
				{
					killSelectionCircle()
					location = endMulti[0].getLocation(Parameters.mapHolder);
					endTouchTime = getTimer();
					var click:Boolean = false;
						
					if((endTouchTime - startTouchTime) < 200)
					{
						click = true;
						if (MouseStates.currentState == MouseStates.REPAIR || MouseStates.currentState == MouseStates.SELL)
						{
							return;
						}
						
						var targetCol:int = location.x / Parameters.tileSize;
						var targetRow:int = location.y / Parameters.tileSize;
						sendUnitsToDest(targetCol, targetRow);	
					}
				}
			}

		}
		
		private function killSelectionCircle():void 
		{
			if (startDragCircle != null)
			{
				startDragCircle.visible = false;
				startDragCircle.stop();
			}
		}
		
		public function beginDrawingRectangle(x:Number, y:Number):void 
		{
			recSelector.beginDrawing(x, y);
			Parameters.mapHolder.addChild(recSelector);
			recSelector.x = x;
			recSelector.y = y;
			
			///////////////////
			
			if (startDragCircle == null)
			{
				startDragCircle = GameAtlas.createMovieClip("startDragCircle");
				startDragCircle.fps = 40;
				//startDragCircle.loop = false;
				
				
				startDragCircle.touchable = false;
				startDragCircle.scaleX = startDragCircle.scaleY = Parameters.gameScale;
				startDragCircle.pivotX =  startDragCircle.width * (0.5/Parameters.gameScale);
				startDragCircle.pivotY =  startDragCircle.height *  (0.5/Parameters.gameScale);
				
				Starling.juggler.add(startDragCircle);
				startDragCircle.stop();
				
				startDragCircle.visible = false;
			}
			startDragCircle.currentFrame = 0;
			startDragCircle.play();
			startDragCircle.x = x;
			startDragCircle.y = y;
			startDragCircle.visible = true;
			Parameters.mapHolder.addChild(startDragCircle);
		}
		
		
		
		private function sendUnitsToDest(targetCol:int, targetRow:int):void 
		{
			var i:int = 0;
			var playHitAnim:Boolean = false;
			var p:GameEntity = getSelectedPlayer(targetCol, targetRow);
			
			//trace"p: " + p);
			
			if(p != null)
			{
				//this is in case a harvester wants to go back to base
				var playDefault:Boolean = true;
				if (Parameters.currentSquad)
				{
					var selectedAsset:GameEntity = Parameters.currentSquad[0];
					var n:Node = Node(Parameters.boardArr[targetRow][targetCol])
					if(n.occupyingUnit)
					{
						var u = n.occupyingUnit;
						
						if (u is Building && u.hasBuildingClickFunction)
						{
							var o:Object = u.onBuildingClickedFNCTN();
							targetRow = o.row;
							targetCol = o.col;
							if (selectedAsset && selectedAsset.model.stats.name == o.assetName)
							{
								selectedAsset.onDestinationReceived(targetRow, targetCol);
								playHitAnim = true;
								playDefault = false;
							}
						}
						
					}
				}
				
				if (playDefault)
				{
					if (Parameters.currentSquad == null)
					{
						Parameters.currentSquad = [];
					}
					
					PoolsManager.selectorCirclesPool.returnAllAssets();
								
					var currentPlayer:GameEntity;
					
					for(i = 0; i < Parameters.humanTeam.length; i++)
					{
						currentPlayer = Parameters.humanTeam[i];
						currentPlayer.deselect();
					}
					
					if(p is Building)
					{
						onRightMouseBTNClicked();
						p.selected(false);
						Parameters.currentSquad.push(p);
					}
					else
					{
						p.selected(true);
						Parameters.currentSquad.push(p);
					}
				}
				
				
				
			}
			else
			{
				//trace"Parameters.currentSquad.length: " + Parameters.currentSquad.length);
				if (Parameters.currentSquad == null) return;
				if(Parameters.currentSquad.length == 1)
				{
					//traceParameters.currentSquad[0]);
					
					if(Parameters.currentSquad[0] is Building)
					{
						Parameters.currentSquad[0].deselect();
					}
					else
					{
						//trace"alright already!");
						p = Parameters.currentSquad[0];
						playHitAnim = true;
						p.onDestinationReceived(targetRow, targetCol);
					}
				}
				else
				{
					var placementsArr:Array = SpiralBuilder.getSpiral(targetRow, targetCol, Parameters.currentSquad.length);
					//trace"placementsArr: " + placementsArr);
					
					//NEED TO DEFINE PEREMITER AROUND POINT FOR SPREAD OF UNITS!
					for(i = 0; i < Parameters.currentSquad.length; i++)
					{
						if(Parameters.currentSquad[i] is Building)
						{
							Parameters.currentSquad[i].deselect();
						}
						else
						{
							p = Parameters.currentSquad[i];
							p.onDestinationReceived(placementsArr[i].row, placementsArr[i].col, (i==0));
							playHitAnim = true;
						}
					}
				}
				
				if(playHitAnim)
				{
					hitMC.fps = 60;
					hitMC.currentFrame = 1;
					hitMC.addEventListener(Event.COMPLETE, onHitmcComplete);
					hitMC.play();
					Parameters.mapHolder.addChild(hitMC);
					hitMC.y = (targetRow * Parameters.tileSize) + (Parameters.tileSize/2);
					hitMC.x = (targetCol * Parameters.tileSize) + (Parameters.tileSize/2);
				}
				
				
			}
		}
		
		private function onHitmcComplete(e:Event):void
		{
			Parameters.mapHolder.removeChild(hitMC);
			hitMC.stop();
		}
			
		
		
		private function getSelectedPlayer(targetCol:int, targetRow:int):GameEntity
		{
			var touchedUnit:GameEntity;
			
			if (Parameters.humanTeam == null) return null;
			
			if (Parameters.boardArr[targetRow][targetCol])
			{
				var node:Node = Node(Parameters.boardArr[targetRow][targetCol]);
				if (node.occupyingUnit && node.occupyingUnit.model && node.occupyingUnit.model.controllingAgent == Agent.HUMAN)
				{
					touchedUnit = node.occupyingUnit;
				}
				
			}
			
			
			return touchedUnit;
		}
		
		private function onRightMouseBTNClicked():void
		{
			MouseStates.currentState = MouseStates.REG_PLAY;
			if (Parameters.currentSquad == null) return;
			
			if(KeyboardController.ctrl)
			{
				//HudController.completedAsset = { "name" : "minigunner", "type" : "units" };
				//GlobalEventDispatcher.getInstance().dispatchEvent(new Event("UNIT_CONSTRUCTED"));
				var currentUnit:GameEntity = Parameters.currentSquad[0];
				if (currentUnit && currentUnit.model && currentUnit.model.dead == false)
				{
					var currentTeamObj:TeamObject = currentUnit.myTeamObj;
					currentTeamObj.spawnEnemyUnit(currentUnit.model.row + 3, currentUnit.model.col - 3, true);
				}
				
				
			}
			
			Parameters.currentSquad.splice(0);
			recSelector.unitsArray.splice(0);
			PoolsManager.selectorCirclesPool.returnAllAssets();
			var currentPlayer:GameEntity;
			
			for(var i:int = 0; i <Parameters.humanTeam.length; i++)
			{
				currentPlayer = Parameters.humanTeam[i];
				currentPlayer.deselect();
			}
		}
	}
}