package  states.game.entities
{
	import global.Parameters;
	
	import starling.display.Quad;
	import starling.display.Sprite;
	
	public class HealthBar extends Sprite
	{
		private var totalHealth:Number;
		private var currentHealth:Number = 100;
		
		private var frameMC:Quad;
		private var greenMC:Quad;
		
		
		
		public function HealthBar(_currentHealth:int, hWidth:int) 
		{
			totalHealth   = _currentHealth;
			currentHealth = _currentHealth;
			
			if(hWidth <  Parameters.tileSize)
			{
				hWidth =  Parameters.tileSize;
			}
			
			frameMC = new Quad(hWidth + 2,2 + 2, 0x000000);
			greenMC = new Quad(hWidth,2,0x00CC00);

			addChild(frameMC);
			addChild(greenMC);
			
			greenMC.y -= greenMC.height;
			frameMC.y -= frameMC.height;
			
			
			
		
			
		}
		
		public function hurt(hitVal:int):Number 
		{
			currentHealth -= hitVal;
			
			greenMC.scaleX = currentHealth / totalHealth;
			
			////trace"currentHealth: " + currentHealth + " totalHealth: " + totalHealth + " " + greenMC.scaleX);
			
			if (greenMC.scaleX < 0.5)
			{
				if (greenMC.scaleX < 0.2)
				{
					greenMC.color = 0xFF0000;
				}
				else {
					greenMC.color = 0xFFCC00;
				}
			}
			
			return greenMC.scaleX;
		}
	}
}