package states.game.entities.units.views
{
	
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	import global.Methods;
	import global.pools.PoolElement;
	import starling.events.Event;
	import states.game.entities.EntityModel;
	import states.game.entities.GunTurretView;
	
	import global.Parameters;
	import global.pools.Pool;
	import global.sounds.GameSounds;
	import global.utilities.CircleRadiusBuilder;
	
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.filters.ColorMatrixFilter;
	
	import states.game.entities.EntityView;
	import states.game.entities.GameEntity;
	import states.game.entities.HealthBar;
	import states.game.entities.units.UnitModel;

	public class UnitView extends EntityView
	{
		protected var frameName:String;
		public var state:String = "_stand";
		public var dir:String = "_south";
		
		public var standCount:int = 0;
		
		private var shootInterval:int = 50;
		private var shootCounter:int = 0;
		
		
		
		protected var dieSounds:Array = [];
		protected var shootSounds:Array = [];
		
		public function UnitView(_model:EntityModel)
		{
			model = _model;

			 //createSoundModule();
		}
		
		
		
		private function createSoundModule():void
		{
			var i:int = 0;
			var SndClass:Class;
			
			if(model.sounds.shootSounds != null)
			{
				for(i = 0; i < model.sounds.shootSounds.length; i++)
				{
					SndClass = GameSounds.dict[model.sounds.shootSounds[i]];
					shootSounds.push(new SndClass());
				}
			}
			
			if(model.sounds.dieSounds != null)
			{
				for(i = 0; i < model.sounds.dieSounds.length; i++)
				{
					SndClass = GameSounds.dict[model.sounds.dieSounds[i]];
					dieSounds.push(new SndClass());
				}
			}
			
		}
		
		override public function addHealthBar(_healthBar:HealthBar):void
		{
			addChild(_healthBar);
			//_healthBar.y 
			_healthBar.visible = false;
		}
		
		
		
		
		public function stopShootingAndStandIdlly():void
		{
			traceView("animate stand stopShootingAndStandIdlly");
			state = "_stand";
			animatelayer();
			
		}
		
		public function stand():void
		{
		}
		
		public function animatelayer():void{}
		
		public function setDirection(curRow:int, curCol:int, destRow:int, destCol:int, targetObj:Object = null):void{}
		
		
		
		public function run():void
		{
			traceView("animate run");
			state = "_run";
			
			mc.loop = true;
			
			var realRow:int = int(y/Parameters.tileSize);
			var realCol:int = int(x/Parameters.tileSize);
			
			//model.row, model.col
			
			if (realRow == UnitModel(model).path[ UnitModel(model).moveCounter].row && realCol == UnitModel(model).path[ UnitModel(model).moveCounter].col )
			{
				 UnitModel(model).moveCounter++;
			}
			
			if ( UnitModel(model).path[ UnitModel(model).moveCounter])
			{
				var nextRow:int =  UnitModel(model).path[ UnitModel(model).moveCounter].row;
				var nextCol:int =  UnitModel(model).path[ UnitModel(model).moveCounter].col
				
				setDirection(realRow, realCol, nextRow, nextCol);
				animatelayer();
			}
			
			
			
		}
		
		override public function shoot(enemy:GameEntity, eRow:int, eCol:int):void
		{
			traceView("animate shoot");
			state = "_fire";

			mc.removeEventListener(Event.COMPLETE, onShootAnimComplte);
			mc.addEventListener(Event.COMPLETE, onShootAnimComplte);
			shootAnimPlaying = true;
			mc.loop = false;// model.unitStats.loopShootAnim;
			
			
			var targetObj:Object = Methods.getTargetLocation(enemy);
			
			setDirection(model.row, model.col,eRow, eCol, targetObj);
			animatelayer();

		}
		
		private function onShootAnimComplte(e:Event):void 
		{
			shootAnimPlaying = false;
			mc.removeEventListener(Event.COMPLETE, onShootAnimComplte);
		}
		
		
		
		
		
		private function playShootSound():void
		{
			var rnd:int = int(shootSounds.length * Math.random());
			
			if(shootSounds[rnd])
			{
				//GameSounds.playSoundFile(shootSounds[rnd]);
			}
		}
		
		public function playOrderSound():void
		{
			//GameSounds.playOrderSoundFromList(model.sounds.orderSounds)
		}
		
		override public function addCircle(_firstMember:Boolean):void{
			super.addCircle(_firstMember);
			if(_firstMember)playSelectSound();
		}
		
		public function playSelectSound():void
		{
			//GameSounds.playSelectSoundFromList(model.sounds.selectSounds)
		}
		
		public function playDeathSound():void
		{
			var rnd:int = int(dieSounds.length * Math.random());
			
			if(dieSounds[rnd])
			{
				//GameSounds.playSoundFile(dieSounds[rnd]);
			}
		}
		
				
		
		override public function dispose():void
		{
			model = null;
			
			dieSounds.splice(0);
			shootSounds.splice(0);
			
			dieSounds = null;
			shootSounds = null;
			
			super.dispose();
		}
		
		
	}
}