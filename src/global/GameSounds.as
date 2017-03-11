package global
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import global.assets.GameAssets;
	import global.Parameters;
	import global.utilities.GlobalEventDispatcher;
	import starling.events.Event;

	public class GameSounds
	{

		/*private static var dict:Dictionary = new Dictionary();
		private static var channelsPool:Array = [];
		private static var soundsPool:Dictionary = new Dictionary();*/
		private static var sounds:Object;
		static private var soundWorkerToMain:MessageChannel;
		static private var mainToSoundWorker:MessageChannel;
		private static var worker:Worker;
		
		[Embed(source="../../bin/GameSoundManager.swf", mimeType="application/octet-stream")]
		private static var GameSoundWorker:Class;
		
		private static var workerInstance:ByteArray;
		
		
		public static function init():void
		{
			sounds = JSON.parse(new GameAssets.SoundsJson());
			initWorker();
			//SoundMixer.soundTransform = new SoundTransform(Parameters.globalSoundVol);

			/*for(var i:int = 0; i < 30; i++)
			{
				channelsPool.push( {channel : new SoundChannel(), transform : new SoundTransform()});
			}*/
			
		}
		
		static private function initWorker():void 
		{
			workerInstance = new GameSoundWorker()
			worker = WorkerDomain.current.createWorker(workerInstance, true);
			//this is a message channel between the worker to main thread
			soundWorkerToMain = worker.createMessageChannel(Worker.current);
			//this is a message channel between the main to worker thread
			mainToSoundWorker = Worker.current.createMessageChannel(worker);
			
			worker.setSharedProperty("soundWorkerToMain", soundWorkerToMain);
			worker.setSharedProperty("mainToSoundWorker", mainToSoundWorker)
			soundWorkerToMain.addEventListener(flash.events.Event.CHANNEL_MESSAGE, onBackgroundMessageToMain);
			worker.addEventListener(flash.events.Event.WORKER_STATE, handleBGWorkerStateChange);
			worker.start(); 
			
		}
		
		static private function handleBGWorkerStateChange(e:flash.events.Event):void 
		{
			if (worker.state == WorkerState.RUNNING) 
            {
                mainToSoundWorker.send({soundsJsonObj : sounds });
            }
		}
		
		static private function onBackgroundMessageToMain(e:flash.events.Event):void 
		{
			var result:Object = soundWorkerToMain.receive() as Object;
			if (result && result.message)
			{
				if (result.message == "BG_SOUND_COMPLETE")
				{
					GlobalEventDispatcher.getInstance().dispatchEvent(new starling.events.Event("BG_SOUND_COMPLETE"));
				}
			}
		}
		
		static public function stopBGSound():void 
		{
			if (worker.state == WorkerState.RUNNING) 
			{
				mainToSoundWorker.send({message : "STOP_BG_SOUND"});
			}
		}
		
		
		
		public static function playSound(_triggerId:String, _deeperLevelName:String = null, vol:Number = 1):SoundChannel
		{
			if (worker.state == WorkerState.RUNNING) 
            {
                mainToSoundWorker.send({soundToPlay : true,  triggerId : _triggerId, deeperLevelName : _deeperLevelName, vol : vol});
            }
			
			return null;
			
			
			/*var req:URLRequest;
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
			
			return ch;*/
		}
		
		
		
		/*
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
		

		private static function onSndComplete(event:Event):void
		{
			SoundChannel(event.target).removeEventListener(Event.SOUND_COMPLETE, onSndComplete);
		}*/

	}
}