package  states.game.weapons
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import flash.geom.Point;
	import global.map.Node;
	import global.Methods;
	import global.pools.Pool;
	import global.utilities.CircleRadiusBuilder;
	import states.game.entities.EntityModel;
	import states.game.entities.EntityView;
	import states.game.entities.units.UnitModel;
	import states.game.entities.units.views.UnitView;
	import states.game.stats.WeaponStatsObj;
	
	import global.Parameters;
	import global.GameAtlas;
	import global.pools.PoolElement;
	import global.sounds.GameSounds;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.textures.Texture;
	
	import states.game.entities.GameEntity;
	import states.game.entities.units.Unit;
	import starling.display.Shape;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class Weapon// extends PoolElement
	{
		private var view:WeaponView;
		
		protected var hitPoints:int;
		protected var damadgeRadius:int;
		private var destRow:int;
		private var destCol:int;
		private var projectileVisible:Boolean;
		private var weaponStats:WeaponStatsObj;
		private var model:EntityModel;
		private var piffPiff:MovieClip;
		private var currentTarget:GameEntity;
		private var shape:Shape;
		private var smokePool:Pool;
		
		public function Weapon(_weaponStats:WeaponStatsObj,  _model:EntityModel) 
		{
			model = _model;
			weaponStats = _weaponStats;
			damadgeRadius = weaponStats.projectile.warhead.spread;
			hitPoints = weaponStats.damage;
			
			var directions:int = 0;
			 //weaponStats.projectile.warhead.infantryDeath
			 var weaponImg:String;
			 var movingProjectile:Boolean;
			 
			if (weaponStats.projectile.image)
			{
				weaponImg = weaponStats.projectile.image;
				movingProjectile = true;
			}
			else
			{
				weaponImg = weaponStats.muzzleFlash;
				movingProjectile = false;
			}
			if (weaponStats.projectile.name == "lasershot")
			{
				smokePool = new Pool(PoolElement,GameAtlas.getTextures(weaponStats.projectile.explosion), _model.stats.pixelOffsetX, _model.stats.pixelOffsetY);
			}
			view = new WeaponView(_model, weaponStats.projectile.explosion, weaponImg, weaponStats.projectile.smokeTrail, movingProjectile, weaponStats.projectile.directions );
			
			

		}
		
		private function isValidEnemy(e:GameEntity):Boolean
		{
			if (e == null)return false;
			if ( e.model == null ) return false;
			if (e.model.dead) return false;
			return true;
		}
		
		public function shoot(enemy:GameEntity, shooterView:EntityView):void
		{

			if (isValidEnemy(enemy))
			{
				currentTarget = enemy;
				destRow = currentTarget.model.row;
				destCol = currentTarget.model.col;
				var targetObj:Object = Methods.getTargetLocation(enemy);
				
				for(var i:int = model.stats.numOfCannons; i >= 1; i--)
				{
					//playShootSound();
					
					if (weaponStats.projectile.name.indexOf("invisible") != -1)
					{
						if (piffPiff == null)
						{
							piffPiff = GameAtlas.createMovieClip("piffpiff");
							piffPiff.loop = false;
							piffPiff.touchable = false;
							Starling.juggler.add(piffPiff);
							piffPiff.addEventListener(Event.COMPLETE, onPiffPiffComplete);
							
						}
						
						
						
						piffPiff.x = targetObj.targetX + ((Math.random() * 10) - 5);
						piffPiff.y = targetObj.targetY + ((Math.random() * 10) - 5);
						piffPiff.currentFrame = 0;
						piffPiff.visible = true;
						Parameters.upperTilesLayer.addChild(piffPiff);
						piffPiff.play();
						inflictDamadge();
					}
					else if (weaponStats.projectile.name == "lasershot")
					{
						if (enemy && enemy.model && enemy.model.dead == false)
						{
							if (!shape)
							{
								shape = new Shape();
							}
							Parameters.upperTilesLayer.addChild(shape);
							shape.alpha = 1;
							shape.x = shooterView.x;
							shape.y = shooterView.y;
							shape.x += 30;
							shape.y += 15;
							shape.graphics.clear();
							shape.graphics.lineStyle(3, 0xFF0000);
							
							var rndX:Number = enemy.model.stats.pixelWidth * Math.random();
							var rndY:Number = enemy.model.stats.pixelHeight * Math.random();
							
							var p:Point = enemy.view.localToGlobal( new Point(rndX,rndY) );
							var pp:Point = shape.globalToLocal(p)
							shape.graphics.lineTo(pp.x, pp.y);
							playLaserExplosion(enemy.view.x + rndX, enemy.view.y + rndY);
							TweenLite.to(shape, 1, { alpha:0, onComplete:function():void{shape.removeFromParent()} } );
							inflictDamadge();
						}
						
					}
					else
					{
						view.shootTarget(
										currentTarget,
										destRow,
										destCol,
										shooterView,
										weaponStats.projectile.bulletSpeed,
										weaponStats.damage,
										weaponStats.projectile.warhead.spread, 
										inflictDamadge
						);

					}
					
				}
			}
			else
			{
				//stop();
				currentTarget = null;
			}
		}
		
		private function playLaserExplosion(rndX:Number, rndY:Number):void 
		{
			var smokeMC:PoolElement = smokePool.getAsset();
			smokeMC.loop = false;
			smokeMC.touchable = false;
			smokeMC.scaleX = smokeMC.scaleY = Parameters.gameScale;
			smokeMC.pivotX = smokeMC.width * (0.5/Parameters.gameScale);
			smokeMC.pivotY = smokeMC.height * (0.5/Parameters.gameScale);
			
			
			
			smokeMC.x = rndX;
			smokeMC.y = rndY;
			smokeMC.addEventListener(Event.COMPLETE, onMCComplte);
			Parameters.upperTilesLayer.addChild(smokeMC);
			smokeMC.currentFrame = int(Math.random() * smokeMC.numFrames);
			Starling.juggler.add(smokeMC);
		}
		
		private function onMCComplte(e:Event):void 
		{
			var mc:PoolElement = PoolElement(e.currentTarget);
			mc.removeEventListener(Event.COMPLETE, onMCComplte);
			mc.returnMe();
			Starling.juggler.remove(mc);
			mc = null;
			

		}
		
		private function onPiffPiffComplete(e:Event):void 
		{
			piffPiff.visible = false;
			piffPiff.stop();
		}
		
		public function stop():void 
		{
			if (piffPiff != null)
			{
				piffPiff.visible = false;
				piffPiff.stop();
				piffPiff.removeEventListener(Event.COMPLETE, onPiffPiffComplete);
				piffPiff.removeFromParent();
				Starling.juggler.remove(piffPiff);
			}
		}
		
		private function getHitUnit():GameEntity 
		{
			var u:GameEntity;
			var n:Node = Node(Parameters.boardArr[destRow][destCol]);
			var hitRow:int;
			var hitCol:int;
			
			if (isValidEnemy(currentTarget))
			{
				u = currentTarget;
				hitRow = destRow;
				hitCol = destCol;
				
				/*if (n.occupyingUnit)
				{
					u = n.occupyingUnit;
					hitRow = destRow;
					hitCol = destCol;
				}
				else
				{
					OuterLoop: for (var i:int = -1; i <= 1; i++ )
					{
						for (var j:int = -1; j <= 1; j++ )
						{
							if (Parameters.boardArr[destRow + i] && Parameters.boardArr[destRow + i][destCol + j])
							{
								n = Node(Parameters.boardArr[destRow + i][destCol + j]);
								if (n.occupyingUnit)
								{
									u = n.occupyingUnit;
									hitRow = destRow + i;
									hitCol = destCol + j;
									break OuterLoop;
								}
							}
						}
					}
				}*/
			}

			
			////trace("trying to hit " + u + " at row: " + hitRow + " col: " + hitCol )
			
			return u
		}
		
		
		protected function inflictDamadge():void
		{
			var u:GameEntity = getHitUnit();
			var ii:int = 0;
			var i:int;
			var j:int;
			var team1Length:int = Parameters.humanTeam.length;
			var team2Length:int = Parameters.pcTeam.length;
			damadgeRadius = 0;//till i figure this out...
			
			
			var dead:Boolean = false;

			if (u && u.model && u.model.dead == false)
			{
				
				var row:int = u.model.row;
				var col:int = u.model.col;
				var n:Node = Node(Parameters.boardArr[row][col])
				if (n.obstacleTile && n.obstacleTile.currentFrame == 0)
				{
					n.obstacleTile.fps = 2;
					Starling.juggler.add(n.obstacleTile);
					n.obstacleTile.addEventListener(Event.COMPLETE, onTreeBurnComplete)
					n.obstacleTile.play();
				}
					
				
				dead = u.hurt(hitPoints, weaponStats.projectile.warhead.infantryDeath, weaponStats.projectile.name );
			}
			else
			{
				dead = true;
			}
			
			if (dead || model.dead || u == null)
			{
				stop();
			}

			return;
			
		}		
		
		private function onTreeBurnComplete(e:Event):void 
		{
			var mc:MovieClip = MovieClip(e.currentTarget);
			mc.removeEventListener(Event.COMPLETE, onTreeBurnComplete);
			Starling.juggler.remove(mc);
		}
		
		
	}
}