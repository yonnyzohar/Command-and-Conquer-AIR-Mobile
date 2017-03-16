package states.game.stats
{
	import flash.utils.Dictionary;
	import global.assets.Assets;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class WeaponStats 
	{
		public static var dict:Dictionary = new Dictionary();
		
		public function WeaponStats() 
		{
			//infantryObj.damadgeRadius 		= curUnit.damadgeRadius;
			//infantryObj.projectilePool 	    =  PoolsManager.gunPool;
			//infantryObj.shootInterval 		= curUnit.shootInterval;
			//infantryObj.shootCycleInterval  = curUnit.shootCycleInterval;
			//infantryObj.loopShootAnim 		= curUnit.loopShootAnim;
			//infantryObj.hitPoints 		    = curUnit.hitPoints;//this is how much damadge the weapon causes, cancelling this!
			//infantryObj.shootRange 		    = curUnit.shootRange;//this is passed to the weapon, cancelling this!
		}
		
		static public function init():void 
		{
			for (var weapon:String in Assets.weapons.list)
			{
				var curWeapon:Object = Assets.weapons.list[weapon];
				var weaponObj:WeaponStatsObj  = new WeaponStatsObj();
				
				weaponObj.name		           = curWeapon.name; // name of weapon
				weaponObj.damage               = curWeapon.damage; // how much damadge does it do
				weaponObj.projectile           = BulletStats.dict[curWeapon.projectile]; // , sprite sheet
				weaponObj.rateOfFire           = curWeapon.rateOfFire; // how many times a second
				weaponObj.range                = curWeapon.range; // range of fire
				weaponObj.sound                = curWeapon.sound; // string of sound to be loaded when firing
				weaponObj.secondaryRateOfFire  = curWeapon.secondaryRateOfFire;
				weaponObj.canAttackAir         = curWeapon.canAttackAirs;
				weaponObj.muzzleFlash		   = curWeapon.muzzleFlash;
				
				if (weaponObj.muzzleFlash != null)
				{
					
					var currEffect:Object = Assets.effects.list[weaponObj.muzzleFlash];
					if (currEffect)
					{
						weaponObj.projectile.directions = currEffect.directions;
					}
					
					//////trace(weaponObj.projectile.directions);
				}
				dict[weaponObj.name] = weaponObj;
			}
			
			//weapons have bullets, bullets have warheads ad effects
			
			/*chaingun: 
			{
                    name: "chaingun",
                    projectile: "invisibleheavy",
                    damage: 25,
                    rateOfFire: 50,
                    range: 4,
                    sound: "gun8"
            },*/
			
			//bullet
				/*ballistic: {
					name: "ballistic",
					explosion: "art-exp1", -- the effect
					warhead: "highexplosive",
					ballisticCurve: true,
					rotationSpeed: 0,
					bulletSpeed: 30,
					count: 1,
					delay: 6,
					innacurate: true,
					smokeTrail: false,
					image: "120mm",
					directions: 32,
				},*/
			
				//wearhead
				/*highexplosive: {
					name: "highexplosive",
					spread: 6,
					wood: true,
					walls: true,
					infantryDeath: "die-frag",
					damageVersusArmor: [87.5, 75, 56.25, 25, 100, 0]
				}*/
		}
		
	}

}