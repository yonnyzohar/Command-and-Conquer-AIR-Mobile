package com.yonnyzohar.global
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	import flash.utils.Dictionary;
	import com.yonnyzohar.global.assets.GameAssets;
	import com.yonnyzohar.global.Parameters;
	import com.yonnyzohar.global.utilities.GlobalEventDispatcher;

	public class GameSounds
	{

		private static var dict:Dictionary = new Dictionary();
		private static var channelsPool:Array = [];
		private static var soundsPool:Dictionary = new Dictionary();
		private static var sounds:Object;
		private static var bgSoundChannel:SoundChannel;

		
		public static function init():void
		{
			sounds = JSON.parse(new GameAssets.SoundsJson());
			//SoundMixer.soundTransform = new SoundTransform(Parameters.globalSoundVol);

			for(var i:int = 0; i < 30; i++)
			{
				channelsPool.push( {channel : new SoundChannel(), transform : new SoundTransform()});
			}
			
		}
		

		static public function playBGSound():void 
		{
			bgSoundChannel = playSound("themes", null, 0.1);
			bgSoundChannel.addEventListener(Event.SOUND_COMPLETE, onBGSndComplete);
		}
		
		private static function onBGSndComplete(e:Event):void 
		{
			bgSoundChannel.removeEventListener(Event.SOUND_COMPLETE, onBGSndComplete);
			playBGSound();
		}
		
		
		static public function stopBGSound():void 
		{
			if(bgSoundChannel)
			{
				bgSoundChannel.stop();
			}
		}
		
		
		
		public static function playSound(_triggerId:String, _deeperLevelName:String = null, vol:Number = 1):SoundChannel
		{
			
			
			var req:URLRequest;
			var snd:Sound;
			var sndName:String;
			var obj:Object = sounds;
			var ch:SoundChannel;
			
			if (_deeperLevelName)
			{
				obj = sounds[_deeperLevelName]
			}
			
			if (obj[_triggerId])
			{
				if (obj[_triggerId] is String)
				{
					snd = dict[_triggerId];
					
					if (snd)
					{
						ch = playSoundFile(snd, vol);
					}
					else
					{
						sndName = obj[_triggerId];
						req = new URLRequest(Parameters.binPath + "gameAssets/sounds/" + sndName +".mp3"); 
						snd = new Sound(req);
						dict[_triggerId] = snd;
						ch = playSoundFile(snd, vol);
					}
				}
				
				
				
				if (obj[_triggerId] is Array)
				{
					var a:Array = obj[_triggerId];
					var rnd:int = Math.random() * a.length;
					snd = dict[_triggerId + rnd];
					

					if (snd)
					{
						ch = playSoundFile(snd, vol);
					}
					else
					{
						sndName = a[rnd];
						req = new URLRequest(Parameters.binPath + "gameAssets/sounds/" + a[rnd] +".mp3"); 
						snd = new Sound(req);
						dict[_triggerId + rnd] = snd;
						ch = playSoundFile(snd, vol);
					}
				}
			}
			
			return ch;
		}
		
		
		
		
		public static function playSoundFile(file:Sound, vol:Number):SoundChannel
		{	
			var o:Object =  getSoundChannel();
			if (o)
			{
				var sndTransform:SoundTransform = o.transform;
				var ch:SoundChannel = o.channel;
				if(ch== null)return null;
				
				try
				{
					ch = file.play();
					sndTransform.volume = vol;
					ch.soundTransform = sndTransform;
					ch.addEventListener(Event.SOUND_COMPLETE, onSndComplete);
				}
				catch(e:Error)
				{
					//trace(e.name + " " + e.message)
				}
				return ch;
			}
			else {
				return null;
			}
		}
		
		
		private static function getSoundChannel():Object
		{
			var ch:Object;
			var len:int = channelsPool.length;
			for(var i:int = 0; i < len; i++)
			{
				if(SoundChannel(channelsPool[i].channel).hasEventListener(Event.SOUND_COMPLETE))
				{
					
				}
				else
				{
					ch = channelsPool[i];
					break;
				}
			}
			
			return ch;
		}
		

		private static function onSndComplete(event:flash.events.Event):void
		{
			SoundChannel(event.target).removeEventListener(Event.SOUND_COMPLETE, onSndComplete);
		}

	}
}