package com.dynamicTaMaker.views
{
	import starling.text.TextField;
	
	public dynamic class GameTextField extends TextField
	{
		public var innerVal:int;
		public var z:int;
		private var bgTF:TextField;
		
		public function GameTextField(_width:int, _height:int, _text:String, _fontName:String="Verdana", _fontSize:Number=12, _color:uint=0, _bold:Boolean=false) 
		{
			super( _width, _height, _text, _fontName, _fontSize, _color, _bold);
		}
		
		public function setName(_name:String, placement:String = ""):void
		{
			this.name = _name;
			
			if (placement == "middle")
			{
				pivotX = width * 0.5;
				pivotY = height * 0.5;
			}
		}
		
		
		
		public function setText(str:String):void
		{
			this.text = str;
			
			if (bgTF != null)
			{
				bgTF.text = str;
			}
		}
		
		public function killMe():void
		{
			if (bgTF)
			{
				bgTF.dispose();
				bgTF.removeFromParent(true);
				bgTF = null;
			}
			
			dispose();
			removeFromParent(true);
		}
		
	}

}