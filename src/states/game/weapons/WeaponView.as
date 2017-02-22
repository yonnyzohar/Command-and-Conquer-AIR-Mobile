
package  states.game.weapons
{
	import com.greensock.easing.Expo;
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import com.greensock.TweenMax;
	import flash.geom.Point;
	import global.GameSounds;
	import global.Methods;
	import global.pools.Pool;
	import global.utilities.CircleRadiusBuilder;
	import global.utilities.GameTimer;
	import states.game.entities.EntityModel;
	import states.game.entities.EntityView;
	import states.game.entities.units.UnitModel;
	import states.game.entities.units.views.UnitView;
	
	import global.Parameters;
	import global.GameAtlas;
	import global.pools.PoolElement;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	import starling.textures.Texture;
	
	import states.game.entities.GameEntity;
	import states.game.entities.units.Unit;

	
	public class WeaponView
	{
		private var explosionMC:MovieClip;
		private var projectileMC:PoolElement;
		private var inflictDamadgeFnctn:Function;
		private var tween:TweenLite;
		private var speed:Number;
		private var dx:Number;
		private var dy:Number;
		private var destRow:int;
		private var destCol:int;
		private var targetX:int;
		private var targetY:int;
		
		private var offsetX:int = 0;
		private var offsetY:int = 0;
		//private var offsetX:int;
		//private var offsetY:int;
		
		private var lastDistX:Number;
		private var lastDistY:Number;
		private var pool:Pool;
		private var trailPool:Pool;
		private var currentBullets:Array = [];
		private var movingProjectile:Boolean;
		private var model:EntityModel;
		private var trailCounter:int = 0;
		private var enemy:GameEntity;
		private var animDirections:int;
		private var isMuzzleFlash:Boolean = false;
		
		public function WeaponView(_model:EntityModel, _explosionAnimName:String, _projectileImgName:String, _smokeTrail:Boolean, _movingProjectile:Boolean, _animDirections:int) 
		{
			animDirections = _animDirections;
			trailCounter = 0;
			model = _model;
			movingProjectile = _movingProjectile;

			if (_projectileImgName)
			{
				pool = new Pool(ProjectileView,GameAtlas.getTextures(_projectileImgName),_model.stats.pixelOffsetX, _model.stats.pixelOffsetY  );
				
				if (_smokeTrail)
				{
					trailPool = new Pool(PoolElement,GameAtlas.getTextures("smokey"), _model.stats.pixelOffsetX, _model.stats.pixelOffsetY);
					
				}
				
			}
			
			if (_explosionAnimName && _explosionAnimName != "piffpiff")
			{
				createExplosion(_explosionAnimName);
			}
		}
		
		private function createExplosion(explosionAnimName:String):void 
		{
			explosionMC = GameAtlas.createMovieClip(explosionAnimName);
			explosionMC.touchable = false;
			explosionMC.scaleX = explosionMC.scaleY = Parameters.gameScale;
			explosionMC.pivotX = explosionMC.width *  (0.5/Parameters.gameScale);
			explosionMC.pivotY = explosionMC.height *  (0.5 / Parameters.gameScale);
			
		}
		
		public function shootTarget( _enemy:GameEntity, _destRow:int,       _destCol:int, shooter:EntityView,  duration:Number, 
									 _hitPoints:int,    _damadgeRadius:int,  _inflictDamadgeFnctn:Function):void 
		{
			enemy = _enemy;
			trailCounter = 0;
			lastDistX = 0;
			lastDistY = 0;
			inflictDamadgeFnctn = _inflictDamadgeFnctn;
			
		
			projectileMC = pool.getAsset();
			
			if (projectileMC)
			{
				destRow = _destRow;
				destCol = _destCol;
				
				Parameters.upperTilesLayer.addChild(projectileMC);
				projectileMC.rotation = 0;
				projectileMC.stop();
				Starling.juggler.add(projectileMC);
					
				projectileMC.x = shooter.x;
				projectileMC.y = shooter.y;
				
				if (model.stats.name == "flame-tank")
				{
					projectileMC.x += ((model.stats.pixelOffsetX*Parameters.gameScale));
					projectileMC.y += ((model.stats.pixelOffsetY * Parameters.gameScale) );
					isMuzzleFlash = true;
				}
				if (model.stats.name == "flame-thrower" || model.stats.name == "chem-warrior" )
				{
					
					projectileMC.y += ((model.stats.pixelOffsetY * Parameters.gameScale) * 0.8 );
					projectileMC.x += ((model.stats.pixelOffsetX * Parameters.gameScale ) / 4 );
					
					isMuzzleFlash = true;
				}
				
				//bazooka all fames good at 0
				//med tak ok at 0
				
				
				if (movingProjectile)
				{
					speed = duration ;
					
					var targetObj:Object = Methods.getTargetLocation(enemy);
					targetX = targetObj.targetX;
					targetY = targetObj.targetY;
					
					if (model.stats.weapon.projectile.ballisticCurve)
					{
						var halfX:int = 0;
						var halfy:int = 0;
						speed = model.stats.weapon.projectile.bulletSpeed;
						
						if (projectileMC.x > targetX)
						{
							halfX = targetX + ((projectileMC.x - targetX)  * 0.3);
						}
						else
						{
							halfX = projectileMC.x + ((targetX - projectileMC.x)  * 0.3);
						}
						
						
						if (projectileMC.y > targetY)
						{
							halfy = targetY + ((projectileMC.y - targetY) * 0.3);
						}
						else
						{
							halfy = projectileMC.y + ((targetY - projectileMC.y)  * 0.3);
						}
						
						var dist:int = Methods.distanceTwoPoints(projectileMC.x, targetX, projectileMC.y, targetY);
						
						halfy -= (dist * 0.2);
						var time:Number = (speed * dist * 0.002);
						
						TweenMax.to(projectileMC, time, 
									{
										ease: Linear.easeNone,
										bezier: { 
											values:[
												{ 
													x:halfX, 
													y:halfy 
												}, 
												{ 
													x:targetX, 
													y:targetY 
												} 
											] 
										}, 
										onComplete:onDone, 
										onCompleteParams:[projectileMC]
									}
								);
					}
					else
					{
						if (animDirections == 32 && projectileMC.numFrames != 1)
						{
							projectileMC.setDirection32( projectileMC.x, projectileMC.y, targetX, targetY);
						}

						dx = targetX - projectileMC.x;
						dy = targetY - projectileMC.y;
						
						currentBullets.push(projectileMC);
						GameTimer.getInstance().addUser(this);
					}
					
					
					
				}
				else
				{
					if (animDirections == 32 && projectileMC.numFrames != 1 )
					{
						projectileMC.setDirection32( projectileMC.x, projectileMC.y, enemy.view.x + (enemy.view.width / 2), enemy.view.y + (enemy.view.height / 2));
						projectileMC.addEventListener(Event.COMPLETE, onProjectileDone);
						projectileMC.loop = false;
						projectileMC.play();
					}
					else
					{
						projectileMC.addEventListener(Event.COMPLETE, onProjectileDone);
						projectileMC.setDirection8( model.row, model.col, enemy.model.row, enemy.model.col,  model.stats.weapon.muzzleFlash);
						projectileMC.x -= projectileMC.width / 4;
						projectileMC.y -= projectileMC.height / 4;
						
					}
				}
			}
		}
		
		private function onProjectileDone(e:Event):void 
		{
			var mc:PoolElement = PoolElement(e.currentTarget);
			mc.removeEventListener(Event.COMPLETE, onProjectileDone);
			onDone(mc);
		}
		
		public function update(_pulse:Boolean):void
		{
			for (var i:int = 0; i < currentBullets.length; i++ )
			{
				var b:PoolElement = currentBullets[i];
				var angle:Number = Math.atan2(dy, dx);
			
				if (speed <= 0)
				{
					speed = .1;
				}
					
				var vx:Number = Math.cos(angle) * speed;
				var vy:Number = Math.sin(angle) * speed;
				b.x += vx;
				b.y += vy;
				
				trailCounter++;
				
				if (trailPool )
				{
					if (trailCounter%4 == 0)
					{
						var smokeMC:PoolElement = trailPool.getAsset();
						smokeMC.loop = false;
						smokeMC.addEventListener(Event.COMPLETE, onMCComplte);
						smokeMC.scaleX = smokeMC.scaleY = Parameters.gameScale;
						smokeMC.touchable = false;
						Parameters.upperTilesLayer.addChild(smokeMC);
						smokeMC.currentFrame = int(Math.random() * smokeMC.numFrames);
						Starling.juggler.add(smokeMC);
						smokeMC.play();
						smokeMC.x = b.x;
						smokeMC.y = b.y;
						
						//smokeMC.x += ((model.stats.pixelOffsetX*Parameters.gameScale)/2);
						//smokeMC.y += ((model.stats.pixelOffsetY*Parameters.gameScale)/2);
					}
				}
			
				var distX:Number = Math.abs(b.x - targetX);
				var distY:Number = Math.abs(b.y - targetY);
				
				//////trace("dist " + distX + "," + distY);
				
				if((distX < 5 && distY < 5) || passedTarget(distX,distY ))
				{
					//GameTimer.getInstance().removeUser(this);
					onDone(b);
				}
				
				lastDistX = distX;
				lastDistY = distY;
			}
		}
		
		private function onMCComplte(e:Event):void 
		{
			var mc:PoolElement = PoolElement(e.currentTarget);
			mc.removeEventListener(Event.COMPLETE, onMCComplte);
			mc.returnMe();
			Starling.juggler.remove(mc);
			mc = null;
			

		}
		
		private function passedTarget(distX:Number,distY:Number):Boolean
		{
			var passed:Boolean = false;
			if (lastDistX != 0 && lastDistY != 0)
			{
				if (distX > lastDistX && distY > lastDistY)
				{
					passed = true;
				}
				
			}
			return passed;
		}
		
		protected function updateShot():void
		{
			
		}
		
		private function onDone(b:PoolElement):void
		{
			if(!isMuzzleFlash)Methods.shakeMap(1);
			
			if (enemy && enemy.model)
			{
				offsetX = enemy.model.stats.pixelOffsetX;
				offsetY = enemy.model.stats.pixelOffsetY;
			}
			
			playExplosion();
			
			
			//GameSounds.playExplosionSound();
			Starling.juggler.remove(b);
			b.returnMe();
			
			if (currentBullets.indexOf(b) != -1)
			{
				currentBullets.splice(currentBullets.indexOf(b), 1);
			}
			
			if (currentBullets.length == 0)
			{
				GameTimer.getInstance().removeUser(this);
			}
			
			inflictDamadgeFnctn();
			
			
		}
		
		public function playExplosion(_x:int = 0, _y:int = 0):void 
		{
			if (_x != 0 && _y != 0)
			{
				targetX = _x;
				targetY = _y;
			}
			if (explosionMC )
			{
				Parameters.upperTilesLayer.addChild(explosionMC);
				explosionMC.x = targetX - ((offsetX * Parameters.gameScale) / 2);
				explosionMC.y = targetY - ((offsetY * Parameters.gameScale) / 2);
				//explosionMC.x += (explosionMC.width / 2);
				//explosionMC.y += (explosionMC.height / 2);
				Starling.juggler.add(explosionMC);
				explosionMC.addEventListener(Event.COMPLETE, onExplosionComplete);
				explosionMC.currentFrame = 0;
				explosionMC.play();
				GameSounds.playSound("vehicle-die", null, 0.1);
			}
		}
		
		
		
		private function onTrailComplete(e:Event):void 
		{
			var mc:PoolElement = PoolElement(e.currentTarget);
			mc.addEventListener("TRAIL_COMPLETE", onTrailComplete)
			Starling.juggler.remove(mc);
			mc.returnMe();
		}

		
		private function onExplosionComplete(e:Event):void 
		{
			Starling.juggler.remove(explosionMC);
			explosionMC.removeEventListener(Event.COMPLETE, onExplosionComplete);
			Parameters.upperTilesLayer.removeChild(explosionMC);
		}
		
		public function dispose():void 
		{
			if (explosionMC)
			{
				Starling.juggler.remove(explosionMC);
				explosionMC.removeEventListener(Event.COMPLETE, onExplosionComplete);
				explosionMC.removeFromParent();
				explosionMC = null;
			}
			GameTimer.getInstance().removeUser(this);
			
			if (projectileMC)
			{
				Starling.juggler.remove(projectileMC);
				projectileMC.returnMe();
				projectileMC.removeEventListener(Event.COMPLETE, onMCComplte);
				projectileMC = null;
			}
			
			TweenMax.killAll();
			
			pool = null;
			trailPool = null;
			currentBullets = null;
			model = null;
			enemy = null;
			
		}
	}
}