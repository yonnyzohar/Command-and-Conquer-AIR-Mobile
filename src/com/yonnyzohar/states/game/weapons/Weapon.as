package com.yonnyzohar.states.game.weapons
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import flash.geom.Point;
	import com.yonnyzohar.global.GameSounds;
	import com.yonnyzohar.global.map.mapTypes.Board;
	import com.yonnyzohar.global.map.Node;
	import com.yonnyzohar.global.Methods;
	import com.yonnyzohar.global.pools.Pool;
	import com.yonnyzohar.global.utilities.CircleRadiusBuilder;
	import starling.display.Sprite;
	import com.yonnyzohar.states.game.entities.EntityModel;
	import com.yonnyzohar.states.game.entities.EntityView;
	import com.yonnyzohar.states.game.entities.units.UnitModel;
	import com.yonnyzohar.states.game.entities.units.views.UnitView;
	import com.yonnyzohar.states.game.stats.WeaponStatsObj;
	
	import com.yonnyzohar.global.Parameters;
	import com.yonnyzohar.global.GameAtlas;
	import com.yonnyzohar.global.pools.PoolElement;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.textures.Texture;
	
	import com.yonnyzohar.states.game.entities.GameEntity;
	import com.yonnyzohar.states.game.entities.units.Unit;
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

			view = new WeaponView(_model, weaponStats.projectile.explosion, weaponImg, weaponStats.projectile.smokeTrail, movingProjectile, weaponStats.projectile.directions );
			
			

		}
		
		private function isValidEnemy(e:GameEntity):Boolean
		{
			if (e == null)return false;
			if ( e.model == null ) return false;
			if (e.model.dead) return false;
			return true;
		}
		
		private function playShootSound():void
		{
			if (weaponStats.sound)
			{
				GameSounds.playSound(weaponStats.sound);
			}
			else
			{
				//trace("NO SOUND!!")
			}
			
			
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
					playShootSound();
					
					if (weaponStats.projectile.name.indexOf("invisible") != -1 && weaponStats.muzzleFlash == null)
					{
						if (piffPiff == null)
						{
							piffPiff = GameAtlas.createMovieClip("piffpiff");
							piffPiff.loop = false;
							piffPiff.touchable = false;
						}
						
						
						piffPiff.addEventListener(Event.COMPLETE, onPiffPiffComplete);
						piffPiff.x = targetObj.targetX + ((Math.random() * 10) - 5);
						piffPiff.y = targetObj.targetY + ((Math.random() * 10) - 5);
						piffPiff.currentFrame = 0;
						piffPiff.visible = true;
						Starling.juggler.add(piffPiff);
						Board.mapContainerArr[Board.EFFECTS_LAYER].addChild(piffPiff);
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
							Board.mapContainerArr[Board.EFFECTS_LAYER].addChild(shape);
							shape.alpha = 1;
							shape.x = shooterView.x;
							shape.y = shooterView.y;
							//shape.x += 30;
							//shape.y += 15;
							
							shape.x += Parameters.tileSize / 2;// ((model.stats.pixelOffsetX * Parameters.gameScale));
							shape.y -= Parameters.tileSize / 2;// ((model.stats.pixelOffsetY * Parameters.gameScale) );
							
							shape.graphics.clear();
							shape.graphics.lineStyle(3, 0xFF0000);
							
							var rndX:Number = enemy.model.stats.pixelWidth * Math.random();
							var rndY:Number = enemy.model.stats.pixelHeight * Math.random();
							
							var p:Point = enemy.view.localToGlobal( new Point(rndX,rndY) );
							var pp:Point = shape.globalToLocal(p)
							shape.graphics.lineTo(pp.x, pp.y);
							Methods.createSmoke(enemy.view.x + rndX, enemy.view.y + rndY);
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
		
		
		
		private function onPiffPiffComplete(e:Event):void 
		{
			piffPiff.visible = false;
			piffPiff.stop();
			stop();
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
			}

			
			//////trace("trying to hit " + u + " at row: " + hitRow + " col: " + hitCol )
			
			return u
		}
		
		
		protected function inflictDamadge():void
		{
			var u:GameEntity = getHitUnit();
			var ii:int = 0;
			var i:int;
			var j:int;

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
		
		public function dispose():void 
		{
			weaponStats = null;
			model = null;
			if (piffPiff)
			{
				piffPiff.stop();
				piffPiff.removeEventListener(Event.COMPLETE, onPiffPiffComplete);
				piffPiff.removeFromParent();
				Starling.juggler.remove(piffPiff);
			}
			currentTarget = null;
			shape = null;
			if (view)
			{
				view.dispose();
				view = null;
			}
		}
		
		
	}
}