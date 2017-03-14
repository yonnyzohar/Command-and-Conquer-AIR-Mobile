package com.yonnyzohar.states.game.teamsData 
{
	import com.yonnyzohar.global.enums.Agent;
	import com.yonnyzohar.global.GameSounds;
	import com.yonnyzohar.global.Parameters;
	import com.yonnyzohar.global.utilities.GameTimer;
	import starling.events.EventDispatcher;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class CashManager extends EventDispatcher
	{
		public var cash:int;
		private var cashToAdd:int = 0;
		private var targetBalance:int;
		public var totalCashCapacity:int = 0;
		public var REACHEED_LIMIT:Boolean = false;
		private var teamObj:TeamObject;
		
		public function CashManager(_cash:int, _teamObj:TeamObject) 
		{
			teamObj = _teamObj;
			cash = _cash;
		}
		
		public function setCashToAdd(_cashToAdd:int):void 
		{
			
			cashToAdd = _cashToAdd;
			GameTimer.getInstance().addUser(this);
		}
		
		public function update(_pulse:Boolean):void
		{
			if (cashToAdd > 0 && REACHEED_LIMIT == false)
			{
				addCash(  Parameters.CASH_INCREMENT );
				cashToAdd -= Parameters.CASH_INCREMENT;
			}
			else
			{
				GameTimer.getInstance().removeUser(this);
			}
		}
		
		public function beginAddingCash(_cashToAdd:int):void
		{
			
			if (cash + cashToAdd > totalCashCapacity)
			{
				GameSounds.playSound("SilosNeeded", "vo");
			}
			
			cashToAdd +=  _cashToAdd;
			GameTimer.getInstance().addUser(this);
			
			
		}
		
		//this update function is called from the slot
		public function reduceCash(_reduceAmount:int):Boolean
		{
			var moreThanZero:Boolean = true;
			targetBalance = cash - _reduceAmount;
			cash = targetBalance;
			
			if (cash <= 0)
			{
				cash = 0;
				moreThanZero = false;
			}
			
			if (cash > totalCashCapacity)
			{
				cash = totalCashCapacity;
				REACHEED_LIMIT = true;
			}
			else
			{
				REACHEED_LIMIT = false;
			}
			
			
			return moreThanZero;
		}
		
		public function addCash(_amount:int):void 
		{
			if (REACHEED_LIMIT == false)
			{
				targetBalance = cash + _amount;
				cash = targetBalance;
				if (cash > totalCashCapacity)
				{
					cash = totalCashCapacity;
					REACHEED_LIMIT = true;
					GameSounds.playSound("SilosNeeded", "vo");
				}
				else
				{
					REACHEED_LIMIT = false;
				}
				if (teamObj.agent == Agent.HUMAN)
				{
					teamObj.buildManager.hud.updateCashUI(cash);
				}
				
			}
			
		}
		
		public function addStorage(_resourceStorage:int):void 
		{
			totalCashCapacity += _resourceStorage;
			
			if (cash > totalCashCapacity)
			{
				REACHEED_LIMIT = true;
			}
			else
			{
				REACHEED_LIMIT = false;
			}
		}
		
		public function reduceStorage(_resourceStorage:int):void 
		{
			totalCashCapacity -= _resourceStorage;
			
			if (cash > totalCashCapacity)
			{
				cash = totalCashCapacity;
				REACHEED_LIMIT = true;
			}
			else
			{
				REACHEED_LIMIT = false;
			}
		}
		
		public function dispose():void
		{
			GameTimer.getInstance().removeUser(this);
			REACHEED_LIMIT = false;
			cash = 0;
			if (teamObj)
			{
				teamObj = null;
			}
		}
		
	}

}