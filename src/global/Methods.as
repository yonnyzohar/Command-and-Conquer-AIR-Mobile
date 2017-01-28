package global
{
	import com.greensock.TweenLite;
	import flash.system.Capabilities;
	import global.enums.AiBehaviours;
	import global.map.Node;
	import global.pools.Pool;
	import global.pools.PoolElement;
	import global.ui.hud.HUD;
	import global.utilities.CircleRadiusBuilder;
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;
	import states.game.entities.buildings.Building;
	import states.game.entities.EntityModel;
	import states.game.entities.EntityView;
	import states.game.entities.GameEntity;
	import states.game.stats.AssetStatsObj;
	import states.game.stats.BuildingsStats;
	import states.game.stats.InfantryStats;
	import states.game.stats.TurretStats;
	import states.game.stats.VehicleStats;

	public class Methods
	{
		public function Methods()
		{
		}
		
		public static var rightClickFNCTN:Function;
		private static var androidDevice:Boolean = false;
		private static var iosDevice:Boolean = false;
		static private var smokePool:Pool;
		
		public static  function estimateDistance(endY:Number, curY:Number, endX:Number, curX:Number):Number
		{
			return int(Math.abs(endY - curY) + Math.abs(endX - curX));
		}
		
		public static function getCurretStatsObj(_name:String):AssetStatsObj 
		{
			if (InfantryStats.dict[_name])
			{
				return InfantryStats.dict[_name];
			}
			if (BuildingsStats.dict[_name])
			{
				return BuildingsStats.dict[_name];
			}
			if (VehicleStats.dict[_name])
			{
				return VehicleStats.dict[_name];
			}
			if (TurretStats.dict[_name])
			{
				return TurretStats.dict[_name];
			}
			return null;
		}
		
		public static function degreesToFrame(_degrees:int, oldDegrees:int):int 
		{
			var specialCase:Boolean = false;
			var endFrame:int = 0;
				
			if(oldDegrees >= 0 && oldDegrees <= 45)
			{
				if(_degrees <= 360 && _degrees >= 315)
				{
					specialCase = true;
				}
			}
			
			
			//west
			if(_degrees == 0 || _degrees == 360)
			{
				endFrame = 8;//--CORRECT
			}
			if(_degrees >= 1 && _degrees <= 11)
			{
				endFrame = 7;
			}
			if(_degrees >= 12 && _degrees <= 22)
			{
				endFrame = 6;
			}
			if(_degrees >= 23 && _degrees <= 34)
			{
				endFrame = 5;
			}
			if(_degrees >= 35 && _degrees <= 44)
			{
				endFrame = 4;
			}
			//north_west
			if(_degrees == 45 )
			{
				endFrame = 4; //CORRECT
			}
			if(_degrees >= 46 && _degrees <= 75)
			{
				endFrame = 3;
			}
			if(_degrees >= 76 && _degrees <= 89)
			{
				endFrame = 1;
			}
			//north
			if(_degrees == 90)//--CORRECT
			{
				endFrame = 0;
			}
			if(_degrees >= 91 && _degrees <= 115)
			{
				endFrame = 31;
			}
			if(_degrees >= 116 && _degrees <= 134)
			{
				endFrame = 30;
			}
			//north_east
			if(_degrees == 135)
			{
				endFrame = 29;
			}
			if(_degrees >= 136 && _degrees <= 147)
			{
				endFrame = 28;
			}
			if(_degrees >= 148 && _degrees <= 159)
			{
				endFrame = 27;
			}
			if(_degrees > 160 && _degrees < 171)
			{
				endFrame = 26;
			}
			if(_degrees >= 172 && _degrees <= 179)
			{
				endFrame = 25;
			}
			//east
			if(_degrees == 180)
			{
				endFrame = 24;//--CORRECT
			}
			if(_degrees >= 181 && _degrees <= 192)
			{
				endFrame = 23;
			}
			if(_degrees >= 193 && _degrees <= 204)
			{
				endFrame = 22;
			}
			if(_degrees >= 205 && _degrees <= 216)
			{
				endFrame = 21;
			}
			if(_degrees >= 217 && _degrees <= 224)
			{
				endFrame = 20;
			}
			//south_east
			if(_degrees == 225)
			{
				endFrame = 20;//-CORRECT
			}
			if(_degrees >= 226 && _degrees <= 248)
			{
				endFrame = 19;
			}
			if(_degrees >= 249 && _degrees <= 269)
			{
				endFrame = 18;
			}
			//south
			if(_degrees == 270)
			{
				endFrame = 16;
			}
			if(_degrees >= 271 && _degrees <= 292)
			{
				endFrame = 15;
			}
			if(_degrees >= 293 && _degrees <= 314)
			{
				endFrame = 14;
			}
			
			//south_west
			if(_degrees == 315)
			{
				endFrame = 12;//--CORRECT
			}
			if(_degrees >= 316 && _degrees <= 327)
			{
				endFrame = 11;
			}
			if(_degrees >= 328 && _degrees <= 339)
			{
				endFrame = 10;
			}
			if(_degrees >= 340 && _degrees <= 351)
			{
				endFrame = 9;
			}
			if(_degrees >= 352 && _degrees <= 363)
			{
				endFrame = 8;
			}
			

					
			return endFrame;
		}
		
		public static function getShortestPath(currentFrameNum:int, endFrame:int):Array
		{
			var rotArr:Array = [];
			var i:int;
			
			//if he is facing north west and wants to go to south west
			if((currentFrameNum >= 0 && currentFrameNum < 8) && (endFrame <= 31 && endFrame > 25))
			{
				for(i = currentFrameNum; i >= 0; i--)
				{
					rotArr.push(i);
				}
				
				for(i = 31; i >= endFrame; i--)
				{
					rotArr.push(i);
				}
			}
			else if((endFrame >= 0 && endFrame < 8) && (currentFrameNum <= 31 && currentFrameNum > 25))
			{
				for(i = currentFrameNum; i <= 31; i++)
				{
					rotArr.push(i);
				}
				
				for(i = 0; i < endFrame; i++)
				{
					rotArr.push(i);
				}
			}
			else
			{
				if(endFrame > currentFrameNum)
				{
					for(i = currentFrameNum; i <= endFrame; i++)
					{
						rotArr.push(i);
					}
				}
				if(endFrame < currentFrameNum)
				{
					for(i = currentFrameNum; i >= endFrame; i--)
					{
						rotArr.push(i);
					}
				}
			}
			
			return rotArr;
		}
		
		
		public static function distanceTwoPoints(x1:Number, x2:Number,  y1:Number, y2:Number):Number 
		{
			var dx:Number = x1-x2;
			var dy:Number = y1-y2;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		
		public static function isAndroid():Boolean
		{
			androidDevice = (Capabilities.version.substr(0, 3) == "AND");
			return androidDevice;
		}
		
		public static function isIOS():Boolean
		{
			iosDevice = (Capabilities.version.substr(0, 3) == "IOS");
			return iosDevice
		}
		
		public static function isMobile():Boolean
		{
			////traceCapabilities.version);
			return (androidDevice || iosDevice); // || isBlackberry()
		}
		
		
		static public function assetIsOnScreen(_row:int, _col:int):Boolean
		{
			var assetOnScreen:Boolean = false;
			var screenRow:int   = Math.abs( Parameters.mapHolder.y  /  (Parameters.tileSize  )  );
			var screenCol:int   = Math.abs( Parameters.mapHolder.x  /  (Parameters.tileSize  )  );
			var _stageWidth:int  = (Parameters.flashStage.stageWidth - HUD.hudWidth) / Parameters.tileSize;
			var _stageHeight:int = Parameters.flashStage.stageHeight / Parameters.tileSize;
			
			if (_row >= screenRow && _row <= (_stageHeight + screenRow))
			{
				if (_col >= screenCol && _col <= (_stageWidth + screenCol) )
				{
					assetOnScreen = true;
				}
			}
			return assetOnScreen;
		}
		
		static public function getTargetLocation(enemy:GameEntity):Object 
		{
			var targetX:int;
			var targetY:int;
			//this is a building
			if (enemy.model.stats.pixelOffsetX == 0 && enemy.model.stats.pixelOffsetY == 0)
			{
				var arr:Array = CircleRadiusBuilder.getPointsAroundCircumference(enemy.view.x + (enemy.view.width/2), enemy.view.y + (enemy.view.height/2), 15, 10, 0);
				var rnd:int = Math.random() * arr.length;
				var pnt:Object = arr[int(arr.length/2)];
				
				targetX = pnt.x;
				targetY = pnt.y;
			}
			else
			{
				//this is a unit
				targetX = enemy.view.x;// - (enemy.model.stats.pixelOffsetX * Parameters.gameScale);
				targetY = enemy.view.y;// - (enemy.model.stats.pixelOffsetY * Parameters.gameScale);
			}
			
			return { targetX : targetX, targetY : targetY }  ;
			
			
			
		}
		
		static public function validTile(row:int, col:int):Boolean
		{
			if (Parameters.boardArr[row] == undefined)return false;
			if (Parameters.boardArr[row] == null)return false;
			if (Parameters.boardArr[row][col] == undefined)return false;
			if (Parameters.boardArr[row][col] == null)return false;
			return true;
		}
		
		static public function isValidEnemy(e:GameEntity, teamNum:int):Boolean
		{
			if (e == null)return false;
			if ( e.model == null ) return false;
			if (e.model.dead) return false;
			if (e.teamNum == teamNum) return false;
			return true;
		}
		
		static public function createSmoke(_X:Number, _Y:Number, cont:Sprite = null):void
		{
			if (Math.random() < 0.4)
			{
			
				if (!smokePool)
				{
					smokePool = new Pool(PoolElement,GameAtlas.getTextures("smoke"), 0, 0);
				}
				
				var smokeMC:PoolElement = smokePool.getAsset();
				smokeMC.loop = false;
				smokeMC.touchable = false;
				smokeMC.scaleX = smokeMC.scaleY = Parameters.gameScale;
				
					
				
				smokeMC.pivotX = smokeMC.width * (0.5/Parameters.gameScale);
				smokeMC.pivotY = smokeMC.height * (0.5/Parameters.gameScale);
				smokeMC.x = _X;
				smokeMC.y = _Y;
				smokeMC.addEventListener(Event.COMPLETE, onMCComplte);
				
				if (cont)
				{
					cont.addChild(smokeMC);
				}
				else
				{
					Parameters.upperTilesLayer.addChild(smokeMC);
				}
				
				smokeMC.currentFrame = int(Math.random() * smokeMC.numFrames);
				Starling.juggler.add(smokeMC);
			}
			
		}
		
		static public function shakeMap(numResidents:int):void 
		{
			var origPosX:int = Parameters.gameHolder.x;
			var origPosY:int = Parameters.gameHolder.y;
			
			TweenLite.to(Parameters.gameHolder, 0.1, 
			{
				x:origPosX + (Math.random() * numResidents), 
				y:origPosY + (Math.random() * numResidents), 
				onComplete:function()
				{
					TweenLite.to(Parameters.gameHolder, 0.1, 
					{ 
						x:origPosX - (Math.random() * numResidents), 
						y: origPosY - (Math.random() * numResidents), 
						onComplete:function()
						{
							TweenLite.to(Parameters.gameHolder, 0.1, 
							{ 
								x:origPosX, 
								y: origPosY 
							})
						}
					})
				}
			})
		}
		

		
		private static function onMCComplte(e:Event):void 
		{
			var mc:PoolElement = PoolElement(e.currentTarget);
			mc.removeEventListener(Event.COMPLETE, onMCComplte);
			mc.returnMe();
			Starling.juggler.remove(mc);
			mc = null;
			

		}
		
		//use searchWholeMap for search and destroy	
		public static function findClosestTargetOnMap(shooter:GameEntity, searcWholeMap:Boolean ):GameEntity
		{
			var model:EntityModel = shooter.model;
			
			if (shooter.aiBehaviour == AiBehaviours.HELPLESS) return null;
			
			var p:GameEntity;
			var closestEnemny:GameEntity;
			

			if(model.enemyTeam == null)
			{
				return null;
			}
			
			if(model.enemyTeam.length == 0)
			{
				return null;
			}
			
			var sightRange:int = model.stats.weapon.range;
			var enemyTeamLength:int = model.enemyTeam.length;
			var shortestDist:int = 100000;
			
			for(var i:int = enemyTeamLength -1; i >= 0; i--)
			{
				p = GameEntity(model.enemyTeam[i]);
				
				if(p.model != null)
				{
					if(p.model.dead == false)
					{
						var dist:int = Methods.distanceTwoPoints(p.model.col, model.col, p.model.row, model.row);
						
						if (p is Building)
						{
							var buildingTiles:Array = Building(p).getBuildingTiles();
							var n:Node;
							for (var j:int = 0; j < buildingTiles.length; j++ )
							{
								n = buildingTiles[j];
								dist = Methods.distanceTwoPoints(n.col, model.col, n.row, model.row);
								if (dist <= sightRange)
								{
									if (dist < shortestDist)
									{
										shortestDist = dist;
										closestEnemny = p;
									}
								}
							}
						}
						
						if (searcWholeMap)
						{
							if (dist < shortestDist)
							{
								shortestDist = dist;
								closestEnemny = p;
							}
						}
						else
						{
							if (dist <= sightRange)
							{
								if (dist < shortestDist)
								{
									shortestDist = dist;
									closestEnemny = p;
								}
							}
						}
					}
				}
			}
			
			return closestEnemny;
		}
	}
}