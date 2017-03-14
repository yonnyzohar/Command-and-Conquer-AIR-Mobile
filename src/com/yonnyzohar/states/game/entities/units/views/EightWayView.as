package com.yonnyzohar.states.game.entities.units.views
{
	import flash.utils.Dictionary;
	import com.yonnyzohar.global.Parameters;
	import starling.display.BlendMode;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.events.Event;
	import com.yonnyzohar.states.game.entities.units.views.UnitView;
	
	import com.yonnyzohar.global.GameAtlas;
	
	import starling.core.Starling;
	import starling.filters.ColorMatrixFilter;
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	import com.yonnyzohar.states.game.entities.units.UnitModel;

	public class EightWayView extends UnitView
	{
		private var standInterval:int = 100;
		private var lastFrame:String;
		
		public function EightWayView(_model:UnitModel)
		{
			super(_model);
			
			if(model.stats.singleAnimState)
			{
				frameName = model.stats.name + "" + dir;
			}
			else
			{
				frameName = model.stats.name + "" + state + "" + dir;
			}
			
			if(lastFrame != frameName)
			{
				swapMCTextures(frameName);
			}
			lastFrame = frameName;
		}
		
		override public function stand():void
		{
			standCount++;

			if(standCount >= standInterval)
			{
				traceView("animate stand");
				
				var rndRow:int = int(Math.random() * 3) - 1;
				var rndCol:int = int(Math.random() * 3) - 1;
				
				if (mc)
				{
					mc.loop = true;
				}
				state = "_stand";
				setDirection(model.row, model.col, model.row + rndRow, model.col + rndCol)
				animatelayer();
				standCount = 0;
			}
		}
		
		
		
		override public function animatelayer():void
		{
			if(model.stats.singleAnimState)
			{
				frameName = model.stats.name + "" + dir;
			}
			else
			{
				frameName = model.stats.name + "" + state + "" + dir;
			}
			
			if(lastFrame != frameName)
			{
				swapMCTextures(frameName);
			}
		}
		
		private function swapMCTextures(frameName:String):void
		{
			if(mc != null)
			{
				while(mc.numFrames > 1)
				{
					mc.removeFrameAt(0);
				}
				
				if (!texturesDict[frameName])
				{
					texturesDict[frameName] = GameAtlas.getTextures(frameName, this.model.teamName);
				}
				else
				{
					//trace"got texture from dict");
				}
				
				for each (var texture:SubTexture in texturesDict[frameName])
				{
					mc.addFrame(texture);
				}
				
				mc.removeFrameAt(0);
				mc.currentFrame = 0;
				
			}
			else
			{
				createView();
			}
			
			
			mc.play();

			lastFrame = frameName;
		}
		
		override protected function createView():void
		{
			
			mc = GameAtlas.createMovieClip(frameName, this.model.teamName);
			if (mc == null)
			{
				return;
			}
			
			//mc.blendMode = BlendMode.NONE;
			
			mc.scaleX = mc.scaleY = Parameters.gameScale;
			mc.x += ((model.stats.pixelOffsetX*Parameters.gameScale)/2);
			mc.y += ((model.stats.pixelOffsetY*Parameters.gameScale)/2);
			
			mc.touchable = false;
			mc.loop = true;
			addChild(mc);
			
			Starling.juggler.add(MovieClip(mc));
			super.createView();
		}
		
		override public function setDirection(curRow:int, curCol:int, destRow:int, destCol:int, targetObj:Object = null):void
		{
			if(curRow == destRow && curCol == destCol)return;
			
			dir = "";
			
			var firstDir:String = "";
			var secondDir:String = "";
			
			//////////////////////
			
			var degrees:int = Math.atan2( curRow -  destRow,  curCol - destCol) / Math.PI * 180;
			
			while ( degrees >= 360 )
			{
				degrees -= 360;
			}
			while ( degrees < 0 )
			{
				degrees += 360;
			}
			
			
			degrees = Math.ceil(degrees);
			
			if(degrees >= 66 && degrees < 112)
			{
				firstDir = "_north";
			}
			if(degrees >= 22 && degrees < 66)
			{
				firstDir = "_north";
				secondDir = "_west";
			}
			
			if(degrees >= 0 && degrees < 22)
			{
				secondDir = "_west";
			}
			
			if(degrees >= 337 && degrees <= 359)
			{
				secondDir = "_west";
			}
			if(degrees >= 292 && degrees < 337)
			{
				firstDir = "_south";
				secondDir = "_west";
			}
			if(degrees >= 247 && degrees < 292)
			{
				firstDir = "_south";
			}
			if(degrees >= 202 && degrees < 247)
			{
				firstDir = "_south";
				secondDir = "_east";
			}
			if(degrees >= 157 && degrees < 202)
			{
				secondDir = "_east";
			}
			
			if(degrees >= 112 && degrees < 157)
			{
				firstDir = "_north";
				secondDir = "_east";
			}
			
			
			if(secondDir != "")
			{
				firstDir = firstDir.toUpperCase();
			}
			
			dir =  firstDir + "" + secondDir;
		}
		
		override public function dispose():void
		{
			if (mc)
			{
				mc.removeFromParent();
			}
			
			Starling.juggler.remove(MovieClip(mc));
			texturesDict = null;
			super.dispose();
		}
	}
}