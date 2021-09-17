package  
{
	import flash.system.MessageChannel;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.utils.ByteArray;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.system.Worker;
	
	public class SoundManagerWorker extends Sprite
	{
		private var soundWorkerToMain:MessageChannel;
		private var mainToSoundWorker:MessageChannel;	
		private var bgSoundChannel:SoundChannel;
		
		private var dict:Dictionary = new Dictionary();
		private var channelsPool:Array = [];
		private var soundsPool:Dictionary = new Dictionary();
		private var sounds:Object;
		private var binPath:String = "";
		
		public function SoundManagerWorker() 
		{
			soundWorkerToMain = Worker.current.getSharedProperty("soundWorkerToMain");
			mainToSoundWorker = Worker.current.getSharedProperty("mainToSoundWorker");
			
			if(mainToSoundWorker)
			{
				mainToSoundWorker.addEventListener(flash.events.Event.CHANNEL_MESSAGE, onMainMessageToBackground);	
			}
		}
		
		private function onMainMessageToBackground(e:flash.events.Event):void 
		{
			if (!mainToSoundWorker.messageAvailable)
                return;
            
            var result:Object = mainToSoundWorker.receive() as Object;
			trace("result.binPath " + result.binPath)
			if(result.binPath)
			{
				binPath = result.binPath;
			}
			
			if(result.soundsJsonObj)
			{
				sounds = result.soundsJsonObj;
				initMe();
			}
			if(result.soundToPlay)
			{
				var sc:SoundChannel = playSound(result.triggerId, result.deeperLevelName, result.vol);
				if(result.triggerId == "themes")
				{
					bgSoundChannel = sc;
					bgSoundChannel.addEventListener(Event.SOUND_COMPLETE, onBGSndComplete);
				}
			}
			if(result.message && result.message ==  "STOP_BG_SOUND")
			{
				if(bgSoundChannel)
				{
					bgSoundChannel.stop();
				}
			}
		}
		
		private function onBGSndComplete(e:Event):void 
		{
			bgSoundChannel.removeEventListener(Event.SOUND_COMPLETE, onBGSndComplete);
			bgSoundChannel = null;
			bgSoundChannel = playSound("themes", null, 0.1);
			bgSoundChannel.addEventListener(Event.SOUND_COMPLETE, onBGSndComplete);
		}
		
		private function initMe():void
		{
			for(var i:int = 0; i < 30; i++)
			{
				channelsPool.push( {channel : new SoundChannel(), transform : new SoundTransform()});
			}
			
		}
		
		private function playSound(_triggerId:String, _deeperLevelName:String = null, vol:Number = 1):SoundChannel
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
						req = new URLRequest(binPath + "gameAssets/sounds/" + sndName +".mp3"); 
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
						req = new URLRequest(binPath + "gameAssets/sounds/" + a[rnd] +".mp3"); 
						snd = new Sound(req);
						dict[_triggerId + rnd] = snd;
						ch = playSoundFile(snd, vol);
					}
				}
			}
			
			return ch;
		}
		
		private function playSoundFile(file:Sound, vol:Number):SoundChannel
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
		
		
		private function getSoundChannel():Object
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
		

		private function onSndComplete(event:Event):void
		{
			SoundChannel(event.target).removeEventListener(Event.SOUND_COMPLETE, onSndComplete);
		}
	}
}	
