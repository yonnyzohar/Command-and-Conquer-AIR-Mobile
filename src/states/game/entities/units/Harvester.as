package  states.game.entities.units
{
	import global.enums.Agent;
	import global.enums.UnitStates;
	import global.GameAtlas;
	import global.map.mapTypes.Board;
	import global.map.Node;
	import global.map.ResourceNode;
	import global.map.SpiralBuilder;
	import global.Methods;
	import global.Parameters;
	import global.utilities.GameTimer;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.textures.SubTexture;
	import states.game.entities.buildings.Building;
	import states.game.entities.buildings.Refinery;
	import states.game.entities.HarvesterStorage;
	import states.game.entities.units.views.FullCircleView;
	import states.game.stats.VehicleStatsObj;
	import states.game.teamsData.TeamObject;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class Harvester extends Vehicle
	{
		private var currentFrame:int;
		private var destResourceNode:Node;
		private var harvestAnimPlaying:Boolean = false;
		private var refinery:Refinery;
		private var isFull:Boolean = false;
		private var loadingBegan:Boolean = false;
		protected var storageBar:HarvesterStorage ;
		private const HARVEST_AMOUNT:int = 10;
		
		public function Harvester(_unitStats:VehicleStatsObj, teamObj:TeamObject, _enemyTeam:Array, myTeam:int) 
		{
			super(_unitStats, teamObj, _enemyTeam, myTeam);
			storageBar = new HarvesterStorage();
			view.addChild(storageBar);
			
		}
		
		override public function update(_pulse:Boolean):void
		{
			if(model != null && model.dead == false)
			{
				resetRowCol()
				switch(model.currentState)
				{
					case UnitStates.IDLE:
						handleIdleState(_pulse);
						break;
					case UnitStates.WALK:
						handleWalkState(_pulse);
						break;
					case UnitStates.SEARCH_FOR_RESOURCES:
						handleSearchState(_pulse);
						break;
					case UnitStates.HARVEST:
						handleHarvestState(_pulse);
						break;
					case UnitStates.DIE:
						handleDeath(_pulse);
						break;
					case UnitStates.RETURN_TO_REFINERY:
						handleReturnToRefinery(_pulse);
						break;
					case UnitStates.LOADING_RESOURCES:
						handleLoadingResources(_pulse);
						break
					case UnitStates.WALK_ERROR:
						handleWalkError(_pulse);
						break;
				}
			}
		}
		
		private function handleLoadingResources(pulse:Boolean):void
		{
			if (loadingBegan == false)
			{
				refinery.beginLoading(storageBar.currentStore, onLoadComplete);
				FullCircleView(view).stopRotation();
				
				view.alpha = 0;
				view.mc.visible = false;
				storageBar.visible = false;
				loadingBegan = true;
			}
		}
		
		private function onLoadComplete():void
		{
			view.alpha = 1;
			view.mc.visible = true;
			storageBar.visible = true;
			storageBar.currentStore = 0;
			storageBar.clearStorage()
			loadingBegan = false;
			isFull = false;
			harvestAnimPlaying = false;
			destResourceNode = null;
			searchForResources();
		}
		
		private function inRefineryDock():Boolean 
		{
			if (refinery != null && refinery.model && refinery.model.dead == false)
			{
				var node:Node = refinery.getLoadingLoacation()
				if (node)
				{
					if (this.model.row == node.row && model.col == node.col)
					{
						return true;
					}
					else
					{
						return false;
					}
				}
				else
				{
					return false;
				}
			}
			else
			{
				return false;
			}
		}
		
		private function handleReturnToRefinery(pulse:Boolean):void 
		{
			if (refineryExists())
			{
				var node:Node = refinery.getLoadingLoacation();
				if (node == null)
				{
					refinery = myTeamObj.getRefinery();
					if (refinery)
					{
						node = refinery.getLoadingLoacation();
					}
				}
				if (node)
				{
					getWalkPath(node.row, node.col);
					setState(UnitStates.WALK);
				}
				else
				{
					setState(UnitStates.IDLE);
				}
				
			}
		}
		
		private function handleSearchState(pulse:Boolean):void 
		{
			if (refineryExists() && isFull == false)
			{
				findResources(pulse);
			}
			else
			{
				setState(UnitStates.IDLE);
			}
			
		}
		
		private function refineryExists():Boolean 
		{
			if (!refinery)
			{
				refinery = myTeamObj.getRefinery();
			}
			
			if (refinery)
			{
				return true;
			}
			else
			{
				return false;
			}
			
		}
		
		public function searchForResources(_refinery:Refinery = null):void
		{
			if (_refinery)
			{
				refinery = _refinery;
			}
			setState(UnitStates.SEARCH_FOR_RESOURCES);
		}
		
		override protected function handleIdleState(_pulse:Boolean):void
		{

			if ( !model.dead && inRefineryDock() && storageBar.currentStore > 0)
			{
				loadingBegan = false;
				setState(UnitStates.LOADING_RESOURCES);
			}
			else
			{
				if (!inRefineryDock() && storageBar.currentStore == storageBar.totalStore)
				{
					setState(UnitStates.RETURN_TO_REFINERY);
				}
				else
				{
					super.handleIdleState(_pulse);
					if (model.controllingAgent == Agent.PC)
					{
						setState(UnitStates.SEARCH_FOR_RESOURCES);
					}
					else
					{
						setState(UnitStates.HARVEST);
					}
				}
				
			}
		}
		
		
		
		override protected function handleWalkState(_pulse:Boolean):void
		{
			if(UnitModel(model).rotating)
			{
				return;
			}
			
			super.handleWalkState(_pulse);
			
		}
		
		
		override protected function onDoneRotating(e:Event):void 
		{
			view.removeEventListener("DONE_ROTATING", onDoneRotating);
			
			
		}
		
		
		override protected function lookAround():void
		{
		
			if(isValidTiberium(destResourceNode))
			{
				getWalkPath(destResourceNode.row, destResourceNode.col);
				
			}
			else
			{
				stopMovingAndSplicePath();
				setState(UnitStates.IDLE);
			}
			
		}
		
		private function isValidTiberium(destResourceNode:Node):Boolean 
		{
			return true;
		}
		
		protected function findClosestResourceOnMap():Node
		{
			var closestResource:Node;
			var shortestDist:int = 100000;
			
			for (var k:String in Board.resourceNodes)
			{
				var n:Node = Board.resourceNodes[k];
				if (n.isResource)
				{
					var dist:int = Methods.distanceTwoPoints(n.col, model.col, n.row, model.row);
					if (dist < shortestDist)
					{
						shortestDist = dist;
						closestResource = n;
					}
				}
				
				
			}
			
			return closestResource;
		}
		
		override public function onDestinationReceived(targetRow:int, targetCol:int, _first:Boolean = true):void
		{
			returnRegHarvester()
			super.onDestinationReceived(targetRow, targetCol,_first);
		}
		
		protected function findResources(_pulse:Boolean):void
		{
			if (destResourceNode == null || destResourceNode.isResource == false)
			{
				
				destResourceNode = findClosestResourceOnMap();
				if (destResourceNode != null)
				{
					setState(UnitStates.WALK);
				}
				else
				{
					setState(UnitStates.IDLE)
				}
			}
			else
			{
				
				if (model.row == destResourceNode.row && model.col == destResourceNode.col)
				{
					setState(UnitStates.HARVEST);
				}
				
			}
		}
		
		private function handleHarvestState(pulse:Boolean):void 
		{
			if (isFull)
			{
				setState(UnitStates.RETURN_TO_REFINERY);
				return;
			}
			
			if (!harvestAnimPlaying && destResourceNode && destResourceNode.isResource == true)
			{
				FullCircleView(view).setDirection(model.row, model.col, destResourceNode.row, destResourceNode.col);
				if (UnitModel(model).rotating == false)
				{
					startHarvest();
				}
			}
			else
			{
				if (destResourceNode == null  || destResourceNode.isResource == false)
				{
					if (Parameters.boardArr[model.row] && Parameters.boardArr[model.row][model.col])
					{
						var curNode:Node = Parameters.boardArr[model.row][model.col];
						if (curNode is ResourceNode && curNode.isResource)
						{
							destResourceNode = curNode;
							//model.isSelected = false;
							setState(UnitStates.HARVEST);
						}
						else
						{
							setState(UnitStates.IDLE);
						}
					}
				}
			}
		}
		
		private function startHarvest():void 
		{
			GameTimer.getInstance().removeUser(view);
			harvestAnimPlaying = true;
			var west:int = 8; // _degrees == 0 || _degrees == 360
			var north_west:int = 4;
			var north:int = 0;
			var north_east:int = 29;
			var east:int = 24;
			var south_east:int = 20;
			var south:int = 16;
			var south_west:int = 12;
			var _degrees = FullCircleView(view).degrees;
			
			currentFrame = view.mc.currentFrame;
			
			var textureName:String;
			
			////////////////////////////
			
			//west
			if(_degrees >= 0 &&  _degrees <= 44)
			{
				textureName = "_west";
			}
			//north_west
			if(_degrees >= 45 && _degrees <= 89)
			{
				textureName = "_NORTH_west";
			}
			
			//north
			if(_degrees >= 90 && _degrees <= 134)//--CORRECT
			{
				textureName = "_north";
			}
			
			//north_east
			if(_degrees >= 135 && _degrees <= 179)
			{
				textureName = "_NORTH_east";
			}
			
			//east
			if(_degrees >= 180 && _degrees <= 224)
			{
				textureName = "_east";
			}
			
			//south_east
			if(_degrees >= 225 && _degrees <= 269)
			{
				textureName = "_SOUTH_east";
			}
			
			//south
			if(_degrees >= 270 && _degrees <= 314)
			{
				textureName = "_south";
			}
			
			
			//south_west
			if(_degrees >= 315 && _degrees <= 359)
			{
				textureName = "_SOUTH_west";
			}
			
			swapMCTextures(model.stats.name + "_harvest" + textureName);
		}
		
		private function swapMCTextures(frameName:String):void
		{
			while(view.mc.numFrames > 1)
			{
				view.mc.removeFrameAt(0);
			}
			
			if (!view.texturesDict[frameName])
			{
				view.texturesDict[frameName] = GameAtlas.getTextures(frameName, this.model.teamName);
			}
			
			for each (var texture:SubTexture in view.texturesDict[frameName])
			{
				view.mc.addFrame(texture);
			}
			
			view.mc.removeFrameAt(0);
			view.mc.currentFrame = 0;
			
			view.mc.loop = false;
			view.mc.addEventListener(Event.COMPLETE, onHarvestLoopComplete);
			view.mc.play();
			Starling.juggler.add(MovieClip(view.mc));
		}
		
		private function onHarvestLoopComplete(e:Event):void 
		{
			if (destResourceNode == null)
			{
				returnRegHarvester()
				setState(UnitStates.SEARCH_FOR_RESOURCES);
			}
			else
			{
				ResourceNode(destResourceNode).reduceResource(HARVEST_AMOUNT);
				isFull = storageBar.addToStorage(HARVEST_AMOUNT);
				
				if (isFull)
				{
					returnRegHarvester()
					setState(UnitStates.RETURN_TO_REFINERY);
				}
				else
				{
					if (destResourceNode.isResource)
					{
						view.mc.currentFrame = 0;
						view.mc.play();
					}
					else
					{
						returnRegHarvester()
						setState(UnitStates.SEARCH_FOR_RESOURCES);
						
					}
				}
			}
			
			
			
		}
		
		private function returnRegHarvester():void
		{
			if (harvestAnimPlaying)
			{
				view.mc.removeEventListener(Event.COMPLETE, onHarvestLoopComplete);
				Starling.juggler.remove(MovieClip(view.mc));
				
				while(view.mc.numFrames > 1)
				{
					view.mc.removeFrameAt(0);
				}
				
				for each (var texture:SubTexture in view.texturesDict["default"])
				{
					view.mc.addFrame(texture);
				}
				
				view.mc.removeFrameAt(0);
				view.mc.currentFrame = currentFrame;
				harvestAnimPlaying = false;
			}
			destResourceNode = null;
		}
		
		override protected function handleDeath(_pulse:Boolean):void
		{
			storageBar.dispose();
			super.handleDeath(_pulse);
		}
		
		
		override public function hurt(_hitVal:int, _currentInfantryDeath:String, projectileName:String = null ):Boolean
		{
			dispatchEvent(new Event("UNDER_ATTACK"));
			return super.hurt(_hitVal, _currentInfantryDeath,projectileName )
		}
	}
}