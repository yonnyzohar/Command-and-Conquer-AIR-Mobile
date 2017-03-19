package com.randomMap
{

	public class RandomNode extends Object
	{
		public var regionNum:int;
		private var _id:String;
		private var _row:int;
		private var _col:int;
		private var _terrainHeight:Number;
		private var _terrainType:int;
		public var walkable:Boolean = true;
		public var occupyingUnit:Object = null;
		
		public function RandomNode(id:String, row:int, col:int, terrainHeight:Number)
		{
			_id = id;
			_row = row;
			_col = col;
			_terrainHeight = terrainHeight;
		}
		
		public function get terrainHeight():Number {return _terrainHeight;}
		public function set terrainHeight(value:Number):void { _terrainHeight = value;}
		
		public function get col():int{return _col;}
		public function set col(value:int):void {_col = value;}
		
		public function get row():int {	return _row;}
		public function set row(value:int):void {_row = value;}
		
		public function get id():String {return _id;}
		public function set id(value:String):void {_id = value;}
		
		public function get terrainType():int {	return _terrainType;}
		public function set terrainType(value:int):void {_terrainType = value;}
	}
	
}