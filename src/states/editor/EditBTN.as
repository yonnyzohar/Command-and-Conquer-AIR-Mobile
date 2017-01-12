package states.editor
{
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.TextField;

	public class EditBTN extends Sprite
	{
		private var bg:Quad;
		private var tf:TextField;
		
		public function EditBTN(str:String, color:uint)
		{
			bg = new Quad(45 ,45, color);
			tf = new TextField(45, 45, str);
			tf.color = 0xffffff;

			addChild(bg);
			addChild(tf);
		}
		
		public function disable():void
		{
			alpha = 0.5;
			touchable= false;
			
		}
		
		public function enable():void
		{
			alpha = 1;
			touchable= true;
			
		}
	}
}