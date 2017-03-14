package com.yonnyzohar.states.game.entities 
{
	import com.yonnyzohar.global.Parameters;
	import starling.display.MovieClip;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class GunTurretView extends MovieClip
	{
		
		public function GunTurretView(tex:Vector.<Texture>) 
		{
			super(tex);
			scaleX = scaleY = Parameters.gameScale;
			touchable = false;
		}
		
	}

}