package global.assets
{
	public class GameAssets
	{
		[Embed(source="teams.xml",mimeType="application/octet-stream")]
		public static const TeamsXml:Class;
		
		[Embed(source = 'levels.json', mimeType='application/octet-stream')]
		public static const LevelsJson:Class;
		
		[Embed(source = "../../../bin/aiFlow.json", mimeType = "application/octet-stream")]
		public static const AIJson:Class;
		
		/*//units
		[Embed(source="units.xml",mimeType="application/octet-stream")]
		public static const UnitsXml:Class;
		
		[Embed(source="units.png")]
		public static const UnitsAtlas:Class;
		
		//buildings
		[Embed(source="buildings.xml",mimeType="application/octet-stream")]
		public static const BuildingsXml:Class;
		
		[Embed(source="buildings.png")]
		public static const BuildingsAtlas:Class;
		
		//map
		[Embed(source="map.xml",mimeType="application/octet-stream")]
		public static const MapXml:Class;
		
		[Embed(source="map.png")]
		public static const MapAtlas:Class;
		
		//hit
		[Embed(source="hit.xml",mimeType="application/octet-stream")]
		public static const HitXml:Class;
		
		[Embed(source="hit.png")]
		public static const HitAtlas:Class;*/
		
		
		//[Embed(source="assAssets.xml",mimeType="application/octet-stream")]
		//public static const AllAssetsXML:Class;
		
		//[Embed(source="assAssets.png")]
		//public static const AllAssetsAtlas:Class;
		
		//ui
		//[Embed(source="ui.xml",mimeType="application/octet-stream")]
		//public static const UIXml:Class;
		
		//[Embed(source="ui.png")]
		//public static const UIAtlas:Class;
		
		//[Embed(source="buildQue.xml",mimeType="application/octet-stream")]
		//public static const BuildQueXml:Class;
		
		//[Embed(source="buildQue.png")]
		//public static const BuildQueAtlas:Class;
		
	}
}