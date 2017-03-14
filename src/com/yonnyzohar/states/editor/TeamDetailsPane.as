package com.yonnyzohar.states.editor
{
	import com.yonnyzohar.dynamicTaMaker.utils.ButtonManager;
	import com.yonnyzohar.dynamicTaMaker.views.GameSprite;
	import starling.events.EventDispatcher;
	import starling.events.Event;

	public class TeamDetailsPane extends EventDispatcher
	{
		private var mc:GameSprite;
		private var controllers:Array;
		private var behaviours:Array;
		private var cash:Array;
		
		
		public function TeamDetailsPane(_mc:GameSprite, i:int)
		{
			mc = _mc;
			mc.teamMC.text = "Team " + (i + 1);
			
			controllers = [mc.humanMC, mc.pcMC];
			
				
			mc.humanMC.textBox.text = "Human";
			mc.pcMC.textBox.text = "PC";
				
			mc.humanMC.bg.visible  = false;
			mc.pcMC.bg.visible  = false;
				
				
				
			cash = [mc.thousandMC, mc.fiveThousand, mc.tenThousand];	
			
			mc.thousandMC.textBox.text = "1000";
			mc.fiveThousand.textBox.text = "5000";
			mc.tenThousand.textBox.text = "10000";
			
			
			mc.helplessMC.textBox.text = "Helpless";
			mc.baseDefenseMC.textBox.text = "Base Defense";
			mc.selfDefenseMC.textBox.text = "Self Defense";
			mc.aggressiveMC.textBox.text = "Agrressive";
			
			mc.thousandMC.bg.visible  = false;
			mc.fiveThousand.bg.visible  = true;
			mc.tenThousand.bg.visible  = false;
			
			
			behaviours = [mc.helplessMC,mc.selfDefenseMC, mc.baseDefenseMC,  mc.aggressiveMC];
			
			mc.helplessMC.bg.visible  = false;
			mc.baseDefenseMC.bg.visible  = false;
			mc.selfDefenseMC.bg.visible  = true;
			mc.aggressiveMC.bg.visible  = false;
			

			
			ButtonManager.setButton(mc.humanMC, "TOUCH", onControllerClicked);
			ButtonManager.setButton(mc.pcMC, "TOUCH", onControllerClicked);
			
			ButtonManager.setButton(mc.thousandMC, "TOUCH", onCashClicked);
			ButtonManager.setButton(mc.fiveThousand, "TOUCH", onCashClicked);
			ButtonManager.setButton(mc.tenThousand, "TOUCH", onCashClicked);
			
			ButtonManager.setButton(mc.helplessMC, "TOUCH", onBehaviourClicked);
			ButtonManager.setButton(mc.baseDefenseMC, "TOUCH", onBehaviourClicked);
			ButtonManager.setButton(mc.selfDefenseMC, "TOUCH", onBehaviourClicked);
			ButtonManager.setButton(mc.aggressiveMC, "TOUCH", onBehaviourClicked);
			
				
			if(i == 0)
			{
				mc.humanMC.bg.visible  = true;
				disableBehaviour();
			}
			else
			{
				mc.pcMC.bg.visible  = true;
			}
		}
		
		private function onBehaviourClicked(caller:GameSprite):void
		{
			mc.helplessMC.bg.visible = false;
			mc.baseDefenseMC.bg.visible = false;
			mc.selfDefenseMC.bg.visible = false;
			mc.aggressiveMC.bg.visible = false;
			caller.bg.visible = true;
		}
		
		private function onCashClicked(caller:GameSprite):void
		{
			mc.thousandMC.bg.visible  = false;
			mc.fiveThousand.bg.visible  = false;
			mc.tenThousand.bg.visible  = false;
			caller.bg.visible = true;
		}
		
		private function onControllerClicked(caller:GameSprite):void
		{
			mc.humanMC.bg.visible  = false;
			mc.pcMC.bg.visible  = false;
			caller.bg.visible = true;
			
			if(caller == mc.humanMC)
			{
				disableBehaviour();
			}
			else
			{
				enableBehaviour();
			}
				
		}
		
		private function enableBehaviour():void
		{
			mc.helplessMC.touchable = true;
			mc.baseDefenseMC.touchable = true;
			mc.selfDefenseMC.touchable = true;
			mc.aggressiveMC.touchable = true;
			
			mc.helplessMC.alpha    = 1;
			mc.baseDefenseMC.alpha = 1;
			mc.selfDefenseMC.alpha = 1;
			mc.aggressiveMC.alpha  = 1;
			
		}
		
		private function disableBehaviour():void
		{
			//mc.selfDefenseMC.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			mc.helplessMC.alpha = 0.5;
			mc.baseDefenseMC.alpha = 0.5;
			mc.selfDefenseMC.alpha = 0.5;
			mc.aggressiveMC.alpha = 0.5;
			
			mc.helplessMC.touchable = false;
			mc.baseDefenseMC.touchable = false;
			mc.selfDefenseMC.touchable = false;
			mc.aggressiveMC.touchable = false;
			
		}
		
		public function getController():int
		{
			for(var i:int = 0; i < controllers.length; i++)
			{
				if(controllers[i].bg.visible)
				{
					break;
				}
			}
					
			return i;
		}
		
		public function getStartCash():int
		{
			var funds:int;
			
			for(var i:int = 0; i < cash.length; i++)
			{
				if(cash[i].bg.visible)
				{
					funds = parseInt(cash[i].textBox.text);
					
					break;
				}
			}
			
			return funds;
		}
		
		public function getBehaviour():int
		{
			for(var i:int = 0; i < behaviours.length; i++)
			{
				if(behaviours[i].bg.visible)
				{
					break;
				}
			}
			
			return i;
		}
		
		
		public function dispose():void
		{
			ButtonManager.removeButtonEvents(mc.humanMC);
			ButtonManager.removeButtonEvents(mc.pcMC);
			ButtonManager.removeButtonEvents(mc.thousandMC);
			ButtonManager.removeButtonEvents(mc.fiveThousand);
			ButtonManager.removeButtonEvents(mc.tenThousand);
			ButtonManager.removeButtonEvents(mc.helplessMC);
			ButtonManager.removeButtonEvents(mc.baseDefenseMC);
			ButtonManager.removeButtonEvents(mc.selfDefenseMC);
			ButtonManager.removeButtonEvents(mc.aggressiveMC);

			mc = null;
			controllers = null;
			cash = null;
			behaviours = null;
			
		}
		
		
	}
}