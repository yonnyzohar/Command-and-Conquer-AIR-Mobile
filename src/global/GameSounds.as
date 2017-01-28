package global
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import global.assets.GameAssets;
	import global.Parameters;

	public class GameSounds
	{

		public static var dict:Dictionary = new Dictionary();
		private static var channelsPool:Array = [];
		private static var soundsPool:Dictionary = new Dictionary();
		private static var sounds:Object;
		
		
		public function GameSounds()
		{
			//var myTransform = new SoundTransform();
			//myTransform.volume = 0.5;
			//myChannel.soundTransform = myTransform;
		}
		
		
		
		public static function init():void
		{
			sounds = JSON.parse(new GameAssets.SoundsJson());
			//SoundMixer.soundTransform = new SoundTransform(Parameters.globalSoundVol);

			for(var i:int = 0; i < 30; i++)
			{
				channelsPool.push( {channel : new SoundChannel(), transform : new SoundTransform()});
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
						req = new URLRequest("gameAssets/sounds/" + sndName +".mp3"); 
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
						req = new URLRequest("gameAssets/sounds/" + a[rnd] +".mp3"); 
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
					trace(e.name + " " + e.message)
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
		

		private static function onSndComplete(event:Event):void
		{
			SoundChannel(event.target).removeEventListener(Event.SOUND_COMPLETE, onSndComplete);
		}
		
		
		
		/*
		
		
		public static function playSound(snd:String):void
		{
			var ch:SoundChannel = getSoundChannel();
			if(ch== null)return;
			
			var SndClass:Class;
			var sound:Sound;
			
			if(soundsPool[snd] == null)
			{
				SndClass = GameSounds.dict[snd];
				sound = new SndClass();
				soundsPool[snd] = sound;
			}
			try
			{
				ch = soundsPool[snd].play();
				ch.addEventListener(Event.SOUND_COMPLETE, onSndComplete);
			}
			catch(e:Error)
			{
				
			}
			
			
			
		}*/
	}
}