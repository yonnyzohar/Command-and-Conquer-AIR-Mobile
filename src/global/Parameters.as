package global 
{
	import flash.display.Stage;
	import global.map.Node;
	import starling.text.TextField;
	import states.game.teamsData.TeamObject;
	
	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.textures.RenderTexture;
	
	import states.LoadingScreen;

	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class Parameters 
	{
		public static var CASH_INCREMENT:int = 1;
		static public var UNIT_MOVE_FACTOR:Number = 0.1;
		
		
		public static var mapMoveSpeed:int = 5;
		public static var DEBUG_MODE:Boolean = false;
		public static var boardArr:Array = new Array();
		public static var theStage:starling.display.Stage;
		public static var flashStage:flash.display.Stage;
		
		public static  var numRows:int;
		public static  var numCols:int;
		public static  var tileSize:int = 0;
		
		public static var humanTeam:Array = [];
		public static var currentSquad:Array;
		
		public static var gameHolder:Main; // holds everything
		public static var mapHolder:Sprite;// holds units
		
		public static var gameScale:Number = 1;
		
		public static var mapWidth:int;
		public static var mapHeight:int;
		public static var loadingScreen:LoadingScreen; 
		
		public static var editMode:Boolean = false;
		
		public static var editObj:Object = new Object();
		static public var globalSoundVol:Number = 1;
		
		static public var screenDisplayArea:Object = { };
		
		static public var useFilters:Boolean = false;
		
		static public var AI_ONLY_GAME:Boolean = false;
		static public var gameSpeed:Number = 2;
		
		static public var editLoad:Boolean = false;
		
		static public var colors:Object = {
			
			yellow: 0xffcc00,
			red: 	0xff0000,
			teal: 	0x008080,
			orange: 0xffa500,
			green: 	0x00b300,
			gray: 	0x808080,
			neutral: 0x000000,
			darkgray :0xa9a9a9,
			brown: 	0x663300
		};

		static public var binPath:String;
		static public var runningInWeb:Boolean = false;
		
		static public var gameTeamObjects:Array = [];
		
		
	}
}