package global.assets
{
	public class GameAssets
	{
		
		[Embed(source = 'levels.json', mimeType='application/octet-stream')]
		public static const LevelsJson:Class;
		
		[Embed(source = "../../../bin/aiFlow.json", mimeType = "application/octet-stream")]
		public static const AIJson:Class;
		
		[Embed(source = "../../../bin/sounds.json", mimeType = "application/octet-stream")]
		public static const SoundsJson:Class;
		
		
		
	}
}