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
		
		public static var pcTeam:Array = [];
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
		
		static public var team2Obj:TeamObject;
		static public var team1Obj:TeamObject;
		
		static public var AI_ONLY_GAME:Boolean = false;
		static public var gameSpeed:int = 10;
		
		static public var editLoad:Boolean = false;
		
		static public var team1Colors:Object = {
			UNITS : 0xffcc00,
			BUILDINGS : 0xffcc00
		};
		
		static public var team2Colors:Object = {
			UNITS : 0xff6600,
			BUILDINGS : 0xff6600
		};
		static public var binPath:String;
		static public var runningInWeb:Boolean = false;
		
		
	}
}