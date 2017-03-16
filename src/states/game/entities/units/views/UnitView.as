package states.game.entities.units.views
{
	
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	import global.GameSounds;
	import global.Methods;
	import global.pools.PoolElement;
	import starling.events.Event;
	import states.game.entities.EntityModel;
	import states.game.entities.GunTurretView;
	import states.game.entities.units.Unit;
	
	import global.Parameters;
	import global.pools.Pool;
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

		}
		
		
		protected function createView():void
		{
			//var q:Quad = new Quad(5, 5, 0x000000);
			//addChild(q);
			//q.x += Parameters.tileSize / 2;
			//q.y += Parameters.tileSize / 2;
		}
		
		override public function addHealthBar(_healthBar:HealthBar):void
		{
			addChild(_healthBar);
			//_healthBar.y 
			_healthBar.visible = false;
		}
		
		
		
		
		public function stopShootingAndStandIdlly():void
		{
			if (state != "_stand")
			{
				traceView("animate stand stopShootingAndStandIdlly");
				state = "_stand";
				animatelayer();
			}
		}
		
		public function runIfNoAready():void
		{
			if (state != "_run")
			{
				state = "_run";
				animatelayer();
			}
		}
		
		public function stand():void
		{
		}
		
		public function animatelayer():void{}
		
		public function setDirection(curRow:int, curCol:int, destRow:int, destCol:int, targetObj:Object = null):void{}
		
		
		
		public function run(_plusNum:int = 1):void
		{
			traceView("animate run");
			state = "_run";
			
			mc.loop = true;
			
			var realRow:int = int(y + (Parameters.tileSize/2)) / Parameters.tileSize;
			var realCol:int = int(x + (Parameters.tileSize/2)) / Parameters.tileSize ;

			
			
			if ( UnitModel(model).path[ UnitModel(model).moveCounter+_plusNum])
			{
				var nextRow:int =  UnitModel(model).path[ UnitModel(model).moveCounter+_plusNum].row;
				var nextCol:int =  UnitModel(model).path[ UnitModel(model).moveCounter+_plusNum].col
				
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
		
		
		
		
		override public function addCircle(_firstMember:Boolean):void{
			super.addCircle(_firstMember);
			if(_firstMember)playSelectSound();
		}
		
		public function playSelectSound():void
		{
			
			if (this is FullCircleView)
			{
				GameSounds.playSound("vehicle-selected")
			}
			else
			{
				GameSounds.playSound("infantry-selected")
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