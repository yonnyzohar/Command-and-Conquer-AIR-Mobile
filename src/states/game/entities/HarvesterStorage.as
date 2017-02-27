package   states.game.entities
{
	import starling.display.Sprite;
	import com.dynamicTaMaker.views.GameSprite;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	import global.Parameters;
	
	import starling.display.Quad;
	 
	public class HarvesterStorage  extends Sprite
	{
		public var totalStore:int = 1500;
		public var currentStore:int = 0;
		private var numBoxes:int = 5;
		private var currentStorage:int = 0;
		private var boxesArr:Array = [];
		
		public function HarvesterStorage() 
		{
			createBoxes();
		}
		
		public function addToStorage(_harvestAmount:int):Boolean 
		{
			currentStore += _harvestAmount;
			
			var boxCapacity:int = totalStore / numBoxes;
			for (var i:int = 1; i <= boxesArr.length; i++ )
			{
				if (currentStore >= (boxCapacity*i) )
				{
					boxesArr[i-1]["greenFont"].visible = true;
				}
			}
			
			if (currentStore >=  totalStore)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		private function createBoxes():void 
		{
			
			var box:GameSprite;
			var size:int = Parameters.tileSize / 5;
			
			for (var i:int = 0; i < numBoxes; i++ )
			{
				box = getBox(size); 
				addChild(box);
				box.x = i * (size + 5);
				box.y -= size * 2;
				boxesArr.push(box);
				
			}
		}
		
		private function getBox(size:Number):GameSprite 
		{
			var cont:GameSprite = new GameSprite();
			var blackBG:Quad = new Quad(size, size, 0x000000);
			cont.addChild(blackBG);
			var greenFront:Quad = new Quad(size*0.9, size * 0.9, 0x00CC00);
			greenFront.x = (blackBG.width - greenFront.width) / 2;
			greenFront.y = (blackBG.height - greenFront.height) / 2;
			cont.addChild(greenFront);
			cont["greenFont"] = greenFront;
			greenFront.visible = false;
			return cont;
		}
		
		override public function dispose():void
		{
			if (boxesArr)
			{
				for (var i:int = 0; i < boxesArr.length; i++ )
				{
					boxesArr[i].removeFromParent(true);
				}
				boxesArr = null;
			}
			
		}
		
		public function clearStorage():void 
		{
			currentStore = 0;
			for (var i:int = 0; i < boxesArr.length; i++ )
			{
				boxesArr[i]["greenFont"].visible = false;
			}
		}
	}
}