package com.yonnyzohar.states.game.ui
{
	import flash.geom.Point;
	import flash.utils.getTimer;
	import com.yonnyzohar.global.enums.Agent;
	import com.yonnyzohar.global.enums.MouseStates;
	import com.yonnyzohar.global.map.mapTypes.Board;
	import com.yonnyzohar.global.map.Node;
	import com.yonnyzohar.states.game.teamsData.TeamBuildManager;
	import com.yonnyzohar.global.utilities.GlobalEventDispatcher;
	import com.yonnyzohar.global.utilities.KeyboardController;
	import com.yonnyzohar.global.utilities.MapMover;
	import com.yonnyzohar.states.game.entities.buildings.BuildingView;
	import com.yonnyzohar.states.game.entities.units.ShootingUnit;
	import com.yonnyzohar.states.game.entities.units.Unit;
	import com.yonnyzohar.states.game.teamsData.TeamObject;
	
	import com.yonnyzohar.global.Methods;
	import com.yonnyzohar.global.Parameters;
	import com.yonnyzohar.global.GameAtlas;
	import com.yonnyzohar.global.map.SpiralBuilder;
	import com.yonnyzohar.global.pools.PoolsManager;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	import com.yonnyzohar.states.game.entities.GameEntity;
	import com.yonnyzohar.states.game.entities.buildings.Building;

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
			var len:int = 0;
			
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
							
							len = Parameters.humanTeam.length;
							for(i = 0; i < len; i++)
							{
								currentPlayer = Parameters.humanTeam[i];
								currentPlayer.deselect();
							}
							
							len = Parameters.currentSquad.length;
							for(i = 0; i < len; i++)
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
					click = false;
						
					if((endTouchTime - startTouchTime) < 200)
					{
						click = true;
						if (MouseStates.currentState == MouseStates.REPAIR || MouseStates.currentState == MouseStates.SELL)
						{
							return;
						}
						
						targetCol = location.x / Parameters.tileSize;
						targetRow = location.y / Parameters.tileSize;
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
			Board.mapContainerArr[Board.EFFECTS_LAYER].addChild(recSelector);
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
			Board.mapContainerArr[Board.EFFECTS_LAYER].addChild(startDragCircle);
		}
		
		
		
		
		
		private function sendUnitsToDest(targetCol:int, targetRow:int):void 
		{
			var i:int = 0;
			var playHitAnim:Boolean = false;
			var p:GameEntity = getSelectedPlayer(targetCol, targetRow);
			var len:int = 0;
			var u:GameEntity;
			
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
						u = n.occupyingUnit;
						
						if (selectedAsset is Unit && u is Building && Building(u).hasBuildingClickFunction)
						{
							var o:Object = Building(u).onBuildingClickedFNCTN(selectedAsset);
							if (o)
							{
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
				}
				
				if (playDefault)
				{
					if (Parameters.currentSquad == null)
					{
						Parameters.currentSquad = [];
					}
					
					PoolsManager.selectorCirclesPool.returnAllAssets();
								
					var currentPlayer:GameEntity;
					len = Parameters.humanTeam.length;
					for(i = 0; i < len; i++)
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
						p.onDestinationReceived(targetRow, targetCol);
						if (p.myTeamObj)
						{
							playHitAnim = highlightAttackBuilding(targetRow, targetCol, p.myTeamObj.teamName);
						}
						
					}
				}
				else
				{
					//var placementsArr:Array = SpiralBuilder.getSpiral(targetRow, targetCol, Parameters.currentSquad.length);
					//trace"placementsArr: " + placementsArr);
					
					//NEED TO DEFINE PEREMITER AROUND POINT FOR SPREAD OF UNITS!
					len = Parameters.currentSquad.length;
					for(i = 0; i < len ; i++)
					{
						if(Parameters.currentSquad[i] is Building)
						{
							Parameters.currentSquad[i].deselect();
						}
						else
						{
							p = Parameters.currentSquad[i];
							p.onDestinationReceived(targetRow, targetCol, (i == 0));
							if (p.myTeamObj)
							{
								playHitAnim = highlightAttackBuilding(targetRow, targetCol, p.myTeamObj.teamName);
							}
							
						}
					}
				}
				
				if(playHitAnim)
				{
					hitMC.fps = 60;
					hitMC.currentFrame = 1;
					hitMC.addEventListener(Event.COMPLETE, onHitmcComplete);
					hitMC.play();
					Board.mapContainerArr[Board.EFFECTS_LAYER].addChild(hitMC);
					hitMC.y = (targetRow * Parameters.tileSize) + (Parameters.tileSize/2);
					hitMC.x = (targetCol * Parameters.tileSize) + (Parameters.tileSize/2);
				}
				
				
			}
		}
		
		private function highlightAttackBuilding(targetRow:int, targetCol:int, teamName:String):Boolean 
		{
			var n:Node = Node(Parameters.boardArr[targetRow][targetCol]);
			var showHitAnim:Boolean = true;
			var u:GameEntity;
			if(n.occupyingUnit)
			{
				u = n.occupyingUnit;
				
				if (u is Building && u && u.model && u.myTeamObj.teamName != teamName)
				{
					BuildingView(u.view).highlightBuilding();
					showHitAnim = false;
				}
			}
			return showHitAnim;
		}
		
		private function onHitmcComplete(e:Event):void
		{
			hitMC.removeFromParent();
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
			var len:int = Parameters.humanTeam.length;
			for(var i:int = 0; i < len; i++)
			{
				currentPlayer = Parameters.humanTeam[i];
				currentPlayer.deselect();
			}
		}
		
		public function dispose():void 
		{
			Parameters.theStage.removeEventListener(TouchEvent.TOUCH, onStageTouch);
			if (hitMC)
			{
				hitMC.dispose();
				hitMC.removeFromParent();
				hitMC = null;
			}
			
			if (startDragCircle)
			{
				startDragCircle.dispose();
				startDragCircle.removeFromParent();
				startDragCircle = null;
			}
		}
	}
}