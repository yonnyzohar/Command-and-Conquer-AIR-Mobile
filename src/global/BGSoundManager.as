package global 
{
	import starling.events.Event;
	import global.utilities.GlobalEventDispatcher;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class BGSoundManager 
	{

		static public function playBGSound():void 
		{
			if (!GlobalEventDispatcher.getInstance().hasEventListener("BG_SOUND_COMPLETE"))
			{
				GlobalEventDispatcher.getInstance().addEventListener("BG_SOUND_COMPLETE", onBGSndComplete);
			}
			
			GameSounds.playSound("themes", null, 0.1);
			
		}
		
		static public function stopBGSound():void 
		{
			
			GameSounds.stopBGSound();
			
		}
		
		
		static private function onBGSndComplete(e:Event):void 
		{
			playBGSound();
		}
	}

}