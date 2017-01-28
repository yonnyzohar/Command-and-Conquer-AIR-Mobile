package global 
{
	import flash.events.Event;
	import flash.media.SoundChannel;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class BGSoundManager 
	{
		private static var bgSoundChannel:SoundChannel;
		
		public function BGSoundManager() 
		{
			
		}
		
		static public function playBGSound():void 
		{
			bgSoundChannel = GameSounds.playSound("themes", null, 0.1);
			if (bgSoundChannel)
			{
				bgSoundChannel.addEventListener(Event.SOUND_COMPLETE, onBGSndComplete);
			}
		}
		
		static public function stopBGSound():void 
		{
			if (bgSoundChannel)
			{
				bgSoundChannel.stop();
			}
		}
		
		static private function onBGSndComplete(e:Event):void 
		{
			bgSoundChannel.removeEventListener(Event.SOUND_COMPLETE, onBGSndComplete);
			playBGSound();
		}
		
	}

}