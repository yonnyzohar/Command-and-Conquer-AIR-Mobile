package global.sounds
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;
	import global.Parameters;

	public class GameSounds
	{
		[Embed(source = 'BuildingCreate.mp3')]
		public static var BuildingCreateSND : Class;
		
		[Embed(source = 'BuildingExplods.mp3')]
		public static var BuildingExplodsSND : Class;
		
		[Embed(source = 'BuildingSold.mp3')] 
		public static var BuildingSoldSND : Class;
		
		[Embed(source = 'Electrify.mp3')]
		public static var ElectrifySND : Class;
		
		[Embed(source = 'Explosion.mp3')]
		public static var ExplosionSND : Class;
		
		[Embed(source = 'Explosion1.mp3')]
		public static var Explosion1SND : Class;
		
		[Embed(source = 'Explosion2.mp3')]
		public static var Explosion2SND : Class;
		
		[Embed(source = 'Explosion3.mp3')]
		public static var Explosion3SND : Class;
		
		[Embed(source = 'Explosion4.mp3')]
		public static var Explosion4SND : Class;
		
		[Embed(source = 'FireRocket.mp3')]
		public static var FireRocketSND : Class;
		
		[Embed(source = 'FireRocket1.mp3')]
		public static var FireRocket1SND : Class;
		
		[Embed(source = 'FireRocket2.mp3')]
		public static var FireRocket2SND : Class;
		
		[Embed(source = 'GUN.mp3')]
		public static var GUNSND : Class;
		
		[Embed(source = 'HeavyMG.mp3')] 
		public static var HeavyMGSND : Class;
		
		[Embed(source = 'HUD1.mp3')]
		public static var HUD1SND : Class;
		
		[Embed(source = 'HUD2.mp3')]
		public static var HUD2SND : Class;
		
		[Embed(source = 'HUD3.mp3')]
		public static var HUD3SND : Class;
		
		[Embed(source = 'HUD4.mp3')] 
		public static var HUD4SND : Class;
		
		[Embed(source = 'HUD5.mp3')] 
		public static var HUD5SND : Class;
		
		[Embed(source = 'HUD6.mp3')] 
		public static var HUD6SND : Class;
		
		[Embed(source = 'HUD7.mp3')] 
		public static var HUD7SND : Class;
		
		[Embed(source = 'HUD8.mp3')] 
		public static var HUD8SND : Class;
		
		[Embed(source = 'HUDSelect.mp3')] 
		public static var HUDSelectSND : Class;
		
		[Embed(source = 'MachineGun.mp3')] 
		public static var MachineGunSND : Class;
		
		[Embed(source = 'MachineGun1.mp3')]
		public static var MachineGun1SND : Class;
		
		[Embed(source = 'MachineGun3.mp3')]
		public static var MachineGun3SND : Class;
		
		[Embed(source = 'MiniMap.mp3')] 
		public static var MiniMapSND : Class;
		
		[Embed(source = 'Pistol.mp3')] 
		public static var PistolSND : Class;
		
		[Embed(source = 'PowerDown.mp3')] 
		public static var PowerDownSND : Class;
		
		[Embed(source = 'SoldierDie.mp3')]
		public static var SoldierDieSND : Class;
		
		[Embed(source = 'SoldierDie1.mp3')] 
		public static var SoldierDie1SND : Class;
		
		[Embed(source = 'SoldierDie2.mp3')] 
		public static var SoldierDie2SND : Class;
		
		[Embed(source = 'SoldierDie3.mp3')] 
		public static var SoldierDie3SND : Class;
		
		[Embed(source = 'SoldierDie4.mp3')] 
		public static var SoldierDie4SND : Class;
		
		[Embed(source = 'SoldierDie5.mp3')] 
		public static var SoldierDie5SND : Class;
		
		[Embed(source = 'SoldierDie6.mp3')] 
		public static var SoldierDie6SND : Class;
		
		[Embed(source = 'SoldierDie7.mp3')]
		public static var SoldierDie7SND : Class;
		
		[Embed(source = 'SoldierOrdered.mp3')] 
		public static var SoldierOrderedSND : Class;
		
		[Embed(source = 'SoldierOrdered1.mp3')] 
		public static var SoldierOrdered1SND : Class;
		
		[Embed(source = 'SoldierOrdered10.mp3')] 
		public static var SoldierOrdered10SND : Class;
		
		[Embed(source = 'SoldierOrdered11.mp3')] 
		public static var SoldierOrdered11SND : Class;
		
		[Embed(source = 'SoldierOrdered2.mp3')] 
		public static var SoldierOrdered2SND : Class;
		
		[Embed(source = 'SoldierOrdered3.mp3')] 
		public static var SoldierOrdered3SND : Class;
		
		[Embed(source = 'SoldierOrdered4.mp3')] 
		public static var SoldierOrdered4SND : Class;
		
		[Embed(source = 'SoldierOrdered5.mp3')] 
		public static var SoldierOrdered5SND : Class;
		
		[Embed(source = 'SoldierOrdered6.mp3')]
		public static var SoldierOrdered6SND : Class;
		
		[Embed(source = 'SoldierOrdered7.mp3')] 
		public static var SoldierOrdered7SND : Class;
		
		[Embed(source = 'SoldierOrdered8.mp3')] 
		public static var SoldierOrdered8SND : Class;
		
		[Embed(source = 'SoldierOrdered9.mp3')]
		public static var SoldierOrdered9SND : Class;
		
		[Embed(source = 'SoldierSelect.mp3')] 
		public static var SoldierSelectSND : Class;
		
		[Embed(source = 'SoldierSelect1.mp3')] 	
		public static var SoldierSelect1SND : Class;
		
		[Embed(source = 'SoldierSelect10.mp3')] 	
		public static var SoldierSelect10SND : Class;
		
		[Embed(source = 'SoldierSelect2.mp3')] 	
		public static var SoldierSelect2SND : Class;
		
		[Embed(source = 'SoldierSelect3.mp3')] 
		public static var SoldierSelect3SND : Class;
		
		[Embed(source = 'SoldierSelect4.mp3')] 
		public static var SoldierSelect4SND : Class;
		
		[Embed(source = 'SoldierSelect5.mp3')]
		public static var SoldierSelect5SND : Class;
		
		[Embed(source = 'SoldierSelect6.mp3')]
		public static var SoldierSelect6SND : Class;
		
		[Embed(source = 'SoldierSelect7.mp3')]
		public static var SoldierSelect7SND : Class;
		
		[Embed(source = 'SoldierSelect8.mp3')] 
		public static var SoldierSelect8SND : Class;
		
		[Embed(source = 'SoldierSelect9.mp3')] 
		public static var SoldierSelect9SND : Class;
		
		[Embed(source = 'Squash.mp3')] 
		public static var SquashSND : Class;
		
		[Embed(source = 'TankFire.mp3')] 	
		public static var TankFireSND : Class;
		
		[Embed(source = 'TankFire1.mp3')] 
		public static var TankFire1SND : Class;
		
		[Embed(source = 'TankFire2.mp3')] 	
		public static var TankFire2SND : Class;
		
		[Embed(source = 'VehicleSelected.mp3')] 
		public static var VehicleSelectedSND : Class;
		
		[Embed(source = 'VehicleSelected1.mp3')] 	
		public static var VehicleSelected1SND : Class;
		
		[Embed(source = 'Wall.mp3')] 
		public static var WallSND : Class;
		
		public static var dict:Dictionary = new Dictionary();
		private static var channelsPool:Array = [];; 
		
		private static var explosions:Array = [new ExplosionSND(), new Explosion1SND(), new Explosion2SND(),new Explosion3SND(), new Explosion4SND()];
		
		private static var soundsPool:Dictionary = new Dictionary();
		
		public function GameSounds()
		{
			
		}
		
		
		
		public static function init():void
		{
			SoundMixer.soundTransform = new SoundTransform(Parameters.globalSoundVol);
			
			dict['BuildingCreate'] = BuildingCreateSND;
			dict['BuildingExplods'] = BuildingExplodsSND;
			dict['BuildingSold'] = BuildingSoldSND;
			dict['Electrify'] = ElectrifySND;
			dict['Explosion'] = ExplosionSND;
			dict['Explosion1'] = Explosion1SND;
			dict['Explosion2'] = Explosion2SND;
			dict['Explosion3'] = Explosion3SND;
			dict['Explosion4'] = Explosion4SND;
			dict['FireRocket'] = FireRocketSND;
			dict['FireRocket1'] = FireRocket1SND;
			dict['FireRocket2'] = FireRocket2SND;
			dict['GUN'] = GUNSND;
			dict['HeavyMG'] = HeavyMGSND;
			dict['HUD1'] = HUD1SND;
			dict['HUD2'] = HUD2SND;
			dict['HUD3'] = HUD3SND;
			dict['HUD4'] = HUD4SND;
			dict['HUD5'] = HUD5SND;
			dict['HUD6'] = HUD6SND;
			dict['HUD7'] = HUD7SND;
			dict['HUD8'] = HUD8SND;
			dict['HUDSelect'] = HUDSelectSND;
			dict['MachineGun'] = MachineGunSND;
			dict['MachineGun1'] = MachineGun1SND;
			dict['MachineGun3'] = MachineGun3SND;
			dict['MiniMap'] = MiniMapSND;
			dict['Pistol'] = PistolSND;
			dict['PowerDown'] = PowerDownSND;
			dict['SoldierDie'] = SoldierDieSND;
			dict['SoldierDie1'] = SoldierDie1SND;
			dict['SoldierDie2'] = SoldierDie2SND;
			dict['SoldierDie3'] = SoldierDie3SND;
			dict['SoldierDie4'] = SoldierDie4SND;
			dict['SoldierDie5'] = SoldierDie5SND;
			dict['SoldierDie6'] = SoldierDie6SND;
			dict['SoldierDie7'] = SoldierDie7SND;
			dict['SoldierOrdered'] = SoldierOrderedSND;
			dict['SoldierOrdered1'] = SoldierOrdered1SND;
			dict['SoldierOrdered10'] = SoldierOrdered10SND;
			dict['SoldierOrdered11'] = SoldierOrdered11SND;
			dict['SoldierOrdered2'] = SoldierOrdered2SND;
			dict['SoldierOrdered3'] = SoldierOrdered3SND;
			dict['SoldierOrdered4'] = SoldierOrdered4SND;
			dict['SoldierOrdered5'] = SoldierOrdered5SND;
			dict['SoldierOrdered6'] = SoldierOrdered6SND;
			dict['SoldierOrdered7'] = SoldierOrdered7SND;
			dict['SoldierOrdered8'] = SoldierOrdered8SND;
			dict['SoldierOrdered9'] = SoldierOrdered9SND;
			dict['SoldierSelect'] = SoldierSelectSND;
			dict['SoldierSelect1'] = SoldierSelect1SND;
			dict['SoldierSelect10'] = SoldierSelect10SND;
			dict['SoldierSelect2'] = SoldierSelect2SND;
			dict['SoldierSelect3'] = SoldierSelect3SND;
			dict['SoldierSelect4'] = SoldierSelect4SND;
			dict['SoldierSelect5'] = SoldierSelect5SND;
			dict['SoldierSelect6'] = SoldierSelect6SND;
			dict['SoldierSelect7'] = SoldierSelect7SND;
			dict['SoldierSelect8'] = SoldierSelect8SND;
			dict['SoldierSelect9'] = SoldierSelect9SND;
			dict['Squash'] = SquashSND;
			dict['TankFire'] = TankFireSND;
			dict['TankFire1'] = TankFire1SND;
			dict['TankFire2'] = TankFire2SND
			dict['VehicleSelected'] = VehicleSelectedSND
			dict['VehicleSelected1'] = VehicleSelected1SND
			dict['Wall'] = WallSND;
			
			for(var i:int = 0; i < 30; i++)
			{
				channelsPool.push( new SoundChannel());
			}
			
		}
		
		public static function playSelectSoundFromList(arr:Array):void
		{
			var ch:SoundChannel = getSoundChannel();
			
			if(ch== null)return;
			var rnd:int = int(arr.length * Math.random());
			var SndClass:Class;
			var snd:Sound;
			
			if(arr[rnd])
			{
				SndClass = GameSounds.dict[arr[rnd]];
				snd = new SndClass();
				
				try
				{
					ch = snd.play();
					ch.addEventListener(Event.SOUND_COMPLETE, onSndComplete);
				}
				catch(e:Error)
				{
					
				}
				
				
			}
		}
		
		private static function getSoundChannel():SoundChannel
		{
			var ch:SoundChannel;
			var len:int = channelsPool.length;
			for(var i:int = 0; i < len; i++)
			{
				if(SoundChannel(channelsPool[i]).hasEventListener(Event.SOUND_COMPLETE))
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
		
		
		public static function playOrderSoundFromList(arr:Array):void
		{
			var ch:SoundChannel = getSoundChannel();
			
			if(ch== null)return;
			var rnd:int = int(arr.length * Math.random());
			var SndClass:Class;
			var snd:Sound;
			
			if(arr[rnd])
			{
				SndClass = GameSounds.dict[arr[rnd]];
				snd = new SndClass();
				
				try
				{
					ch = snd.play();
				ch.addEventListener(Event.SOUND_COMPLETE, onSndComplete);
				}
				catch(e:Error)
				{
					
				}
				
				
			}
		}
		
		private static function onSndComplete(event:Event):void
		{
			SoundChannel(event.target).removeEventListener(Event.SOUND_COMPLETE, onSndComplete);
		}
		
		public static function playExplosionSound():void
		{
			var ch:SoundChannel = getSoundChannel();
			
			if(ch== null)return;
			
			var rnd:int = int(explosions.length * Math.random());
			if(explosions[rnd])
			{
				try
				{
					ch = explosions[rnd].play();
					ch.addEventListener(Event.SOUND_COMPLETE, onSndComplete);
				}
				catch(e:Error)
				{
					
				}
				
			}
			
		}
		
		public static function playSoundFile(file:Sound):void
		{
			var ch:SoundChannel = getSoundChannel();
			if(ch== null)return;
			
			try
			{
				ch = file.play();
				ch.addEventListener(Event.SOUND_COMPLETE, onSndComplete);
			}
			catch(e:Error)
			{
				
			}
			
			
		}
		
		
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
			
			
			
		}
	}
}