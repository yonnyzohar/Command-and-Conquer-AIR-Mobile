package states.editor
{
	import com.dynamicTaMaker.loaders.TemplateLoader;
	import com.dynamicTaMaker.utils.ButtonManager;
	import com.dynamicTaMaker.views.GameSprite;
	import starling.events.EventDispatcher;
	import global.Parameters;

	public class DetailsPanelController extends EventDispatcher
	{
		public var view:GameSprite;
		
		private var gameObj:Object = { };
		private var currentTech:int = 1;
		private var colorsArr:Array = [];
		private var controllers:Array = [];
		private var weaponsProviders:Array = [];

		
		public function DetailsPanelController()
		{
			view = TemplateLoader.get("DetailsPanelMC");
			//teamPane = new TeamDetailsPane(view.playerBlock, 0);
			
			view.tilesTXT.text = currentTech;
			ButtonManager.setButton(view.addRowBTN, "TOUCH", increateTech);
			ButtonManager.setButton(view.removeRowBTN, "TOUCH", decreaseTech);
			
			
			view.playerBlock.teamMC.text = "";
			
			
			ButtonManager.setButton(view.playerBlock.humanMC, "TOUCH", onControllerClicked);
			ButtonManager.setButton(view.playerBlock.pcMC	, "TOUCH", onControllerClicked);
			ButtonManager.setButton(view.playerBlock.yellowMC , "TOUCH", onColorClicked);
			ButtonManager.setButton(view.playerBlock.redMC	 , "TOUCH", onColorClicked);
			ButtonManager.setButton(view.playerBlock.tealMC	 , "TOUCH", onColorClicked);
			ButtonManager.setButton(view.playerBlock.orangeMC , "TOUCH", onColorClicked);
			ButtonManager.setButton(view.playerBlock.greenMC	 , "TOUCH", onColorClicked);
			ButtonManager.setButton(view.playerBlock.grayMC	 , "TOUCH", onColorClicked);
			ButtonManager.setButton(view.playerBlock.brownMC	 , "TOUCH", onColorClicked);
			
			ButtonManager.setButton(view.playerBlock.gdiSide	 , "TOUCH", onWeaponsProviderClicked);
			ButtonManager.setButton(view.playerBlock.nodSide	 , "TOUCH", onWeaponsProviderClicked);
			
			
			view.playerBlock.humanMC.textBox.text = "HUMAN";
			view.playerBlock.pcMC.textBox.text = "PC";
			
			controllers = [
				view.playerBlock.humanMC,
			    view.playerBlock.pcMC	
			];
			
			colorsArr = [
			
				view.playerBlock.yellowMC ,
				view.playerBlock.redMC	 ,
				view.playerBlock.tealMC	 ,
				view.playerBlock.orangeMC ,
				view.playerBlock.greenMC	 ,
				view.playerBlock.grayMC	 ,
				view.playerBlock.brownMC	 

			];
			
			weaponsProviders = [
			
				view.playerBlock.gdiSide,
				view.playerBlock.nodSide
			
			];
			

			onControllerClicked(view.playerBlock.humanMC);
			onColorClicked(view.playerBlock.yellowMC);
			onWeaponsProviderClicked(view.playerBlock.gdiSide);
			
			view.playerBlock.gdiSide.textBox.text = "GDI";
			view.playerBlock.nodSide.textBox.text = "NOD";
			
			
			view.bg
			view.plusBtn
			view.minusBtn


			ButtonManager.setButton(view.xButton, "TOUCH", onXClicked);
			
		}
		
		private function onWeaponsProviderClicked(caller:GameSprite):void 
		{
			for (var i:int = 0; i < weaponsProviders.length; i++ )
			{
				weaponsProviders[i].alpha = 0.2;
			}
			caller.alpha = 1;
		}
		
		
		private function onControllerClicked(caller:GameSprite):void 
		{
			for (var i:int = 0; i < controllers.length; i++ )
			{
				controllers[i].alpha = 0.2;
			}
			caller.alpha = 1;
		}
		
		private function onColorClicked(caller:GameSprite):void 
		{
			for (var i:int = 0; i < colorsArr.length; i++ )
			{
				colorsArr[i].alpha = 0.2;
			}
			caller.alpha = 1;
		}
		
		private function increateTech(caller:GameSprite):void
		{
			currentTech++;
			view.tilesTXT.text = currentTech;
		}
		
		private function decreaseTech(caller:GameSprite):void
		{
			currentTech--;
			view.tilesTXT.text = currentTech;
		}
		
		private function onXClicked(caller:GameSprite):void
		{
			view.visible = false;
		}
		

		
		
		public function dispose():void
		{
			
			ButtonManager.removeButtonEvents(view.xButton);
			view.dispose();
			view = null;
		}
			
		
	}
}