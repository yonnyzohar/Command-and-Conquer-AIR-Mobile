package states.game.stats
{
	import flash.utils.Dictionary;
	import global.assets.GameAssets;
	import global.GameAtlas;
	import global.Parameters;

	public class LevelManager
	{
		private static var levelsJson:Object;
		public static var currentlevelData:Object;
		
		
		public static function init():void
		{
			levelsJson = JSON.parse(new GameAssets.LevelsJson());
		}
		
		public static function getLevelData(levelNum:int):Object
		{
			return levelsJson.levels[levelNum];
		}
		
		//parse the level json and see the tech level + all units in the level. then load in ONLY the ones needed for this level.
		//we have a texture issue!
		static public function loadRelevantAssets(_levelData:Object, _completeFunction:Function):void 
		{
			if (_levelData == null)
			{
				_levelData = {tech : 10 }
			}
			var levelTech:int = _levelData.tech;
			
			var arrs:Array = ["startBuildings", "startVehicles", "startUnits", "startTurrets"];
			var stats:Array = [BuildingsStats.dict, VehicleStats.dict, InfantryStats.dict, TurretStats.dict];
			
			var dirsToLoadMap:Object = { };
			var a:int = 1;
			var i:int = 0;
			var j:int = 0;
			var curDict:Dictionary;
			
			for (i = 0; i < stats.length; i++ )
			{
				curDict = stats[i];	
				for (var k:String in curDict)
				{
					if (Parameters.editMode)
					{
						if (curDict[k].tech <= levelTech)
						{
							dirsToLoadMap[k] = k;
						}
						
					}
				}
			}
			
			
			
			var numTeams:int = _levelData.teams.length;
			var teams:Array = _levelData.teams;
			var color:String;
			var weaponsProvider:String;
			var assetObj:Object = { };
			
			for (a = 0; a < numTeams; a++  )
			{
				weaponsProvider = teams[a].weaponsProvider;
				color = teams[a].color;
				
				
				if (assetObj[weaponsProvider] == undefined)
				{
					assetObj[weaponsProvider] = [];
				}
				assetObj[weaponsProvider].push(color);
				
				for (i = 0; i < arrs.length; i++ )
				{
					for (j = 0; j < teams[a][arrs[i]].length; j++ )
					{
						var currentObj:Object = teams[a][arrs[i]][j];
						var n:String = currentObj.name;
						
						var correspondingObj:Object = stats[i][currentObj.name];
						dirsToLoadMap[n] = n;
						if (correspondingObj.connectedSprites)
						{
							for (var g:int = 0; g < correspondingObj.connectedSprites.length; g++ )
							{
								var cp:String = correspondingObj.connectedSprites[g];
								dirsToLoadMap[cp] = cp;
							}
						}
						
						
						curDict = stats[i];	
						
						
						if (curDict[n].tech > levelTech)
						{
							////trace(n + " tech is " + curDict[n].tech + " current " + levelTech)
						}
					}
				}
			}
			
			
			GameAtlas.setGameColors(assetObj);
			

			//now that i have the assets i need to load in this level - go load only them!!!
			GameAtlas.init(dirsToLoadMap , _completeFunction);//1
		}
		
		static public function createEditData(teamsArr:Array, tech:int):void 
		{
			var levelObj:Object = {tech : tech , teams:[] };
			var obj:Object;
			
			var map:Object = {
				humanMC  : 0 ,
				pcMC	 : 1 ,
				
				yellowMC : "yellow" ,
				redMC	  : "red", 
				tealMC	  : "teal", 
				orangeMC  : "orange",
				greenMC	 : "green",
				grayMC	  : "gray", 
				brownMC	 : "brown",
				
				gdiSide	: "gdi",
				nodSide	: "nod"
			}
			
			
			
			for (var i:int = 0; i < teamsArr.length; i++ )
			{
				obj = teamsArr[i].obj;
				var team:Object = {
					"AiBehaviour":1, 
					"cash":5000, 
					"startVehicles":[], 
					"startBuildings":[],
					"startTurrets":[],
					"startUnits":[] ,
					agent : map[obj.controller], 
					color : map[obj.color], 
					weaponsProvider : map[obj.weaponsProvider],
					teamName : obj.teamName 
				
				}
					

				levelObj.teams.push(team);
			}
			
			LevelManager.currentlevelData = levelObj;

		}
		
		/*public static function getTeam1ByLevel(levelNum:int):Object
		{
			var obj:Object;
			
			if (levelsJson.levels[levelNum].team1);
			{
				obj = levelsJson.levels[levelNum].team1;
			}
			
			
			return obj;
		}
		
		public static function getTeam2ByLevel(levelNum:int):Object
		{
			var obj:Object;
			
			if (levelsJson.levels[levelNum].team2);
			{
				obj = levelsJson.levels[levelNum].team2;
			}
			
			
			return obj;
		}*/
	}
}