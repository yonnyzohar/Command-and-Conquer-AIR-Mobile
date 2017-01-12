package states.game.teamsData
{
	import global.assets.GameAssets;

	public class TeamsLoader
	{
		private static var xml:XML;
		private static var teams:XMLList;
		
		public function TeamsLoader()
		{
			
		}
		
		public static function init():void
		{
			xml = XML(new GameAssets.TeamsXml());
			teams = xml.teams.team;
			//trace"teams loaded");
		}
		
		public static function numTeams():int
		{
			return teams.length();
		}
		
		public static function getTeamData(i:int):Object
		{
			return teams[i];
		}
	}
}