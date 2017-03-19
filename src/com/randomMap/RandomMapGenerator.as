package  com.randomMap
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import global.assets.Assets;
	import global.map.SpiralBuilder;
	import global.Parameters;
	
	public class RandomMapGenerator
	{
		private const AGE:int = 4; // the OLDER it is the more land there will be
		private const LAND_THRESHOLD:Number = 117;
		private var numRows:int;
		private var numCols:int;
		private var nodes:Array;
		static public const LAND:int = 1;
		static public const SEA:int  = 2;
		public var allRegions:Dictionary;
		
		private var allRelevantTiles:Array = [];
		
		public function RandomMapGenerator():void 
		{
			
		}
		
		public function createRandomMap(_numRows:int, _numCols:int):Array
		{
			numRows = _numRows;
			numCols = _numCols;
			allRelevantTiles = [];
			nodes = new Array();
			allRegions = new Dictionary();
			var row:int = 0;
			var col:int = 0;
			
			for (row = 0; row < numRows; row++ )
			{
				nodes.push(new Array());
				
				for (col = 0; col < numCols; col++ )
				{
					var name:String = "Row: " + row + ", Col: " + col;
					var height:Number = Math.random() * 256;
					nodes[row][col] = new RandomNode(name, row, col, height)
				}
			}
			
			Parameters.boardArr = nodes;
			
			drawMap();
			
			labelMap(LAND);
			labelMap(SEA);
			

			allRelevantTiles = getAllWaterTiles(allRelevantTiles);
			drawResources();
			allRelevantTiles = drawTrees(allRelevantTiles);
			
			
			Parameters.boardArr = null;
			
			return allRelevantTiles;
		}
		
		private function drawResources():void 
		{
			var numOfResourceSpots:int = Math.random() * 5;
			var curNode:RandomNode;
			
			for (var i:int = 0; i < numOfResourceSpots; i++ )
			{
				var rndRow:int = Math.random() * numRows;
				var rndCol:int = Math.random() * numCols;
				if (nodes[rndRow] && nodes[rndRow][rndCol])
				{
					curNode = nodes[rndRow][rndCol];
					if (curNode.terrainType == RandomMapGenerator.LAND)
					{
						var pileType:int = Math.random() * 60;
						var arr:Array = SpiralBuilder.getSpiral(rndRow, rndCol, pileType);
						for (var j:int = 0; j < arr.length; j++ )
						{
							var o:Object = arr[j];
							allRelevantTiles.push( {"groundTileTexture":"grass","obstacleTextureName":"tiberium_default05","row":o.row,"regionNum":1,"col":o.col,"walkable":true,"textureFrame":0} );
						}
					}
				}
			}
		}
		
		
		private function getAllWaterTiles(_allRelevantTiles:Array):Array 
		{
			var row:int = 0;
			var col:int = 0;
			var curNode:RandomNode;
			for (row = 0; row < numRows; row++ )
			{
				for (col = 0; col < numCols; col++ )
				{
					curNode = nodes[row][col];
					if (curNode.terrainType == RandomMapGenerator.SEA)
					{
						_allRelevantTiles.push( {"col":col,"groundTileTexture":"water","walkable":false,"row":row,"regionNum":curNode.regionNum} );
					}
				}
			}
			
			return _allRelevantTiles;
		}
		
		public function drawTrees(_allRelevantTiles:Array):Array
		{
			var rnd:int = 0;
			var curNode:RandomNode;
			var trees:Object = Assets.trees.list;
			var numOfTrees:int = Math.random() * 100;
			
			var treesArr:Array = [];
			for (var k:String in trees)
			{
				treesArr.push(k);
			}
			
			for (var i:int = 0; i < numOfTrees; i++ )
			{
				var rndRow:int = Math.random() * numRows;
				var rndCol:int = Math.random() * numCols;
				if (nodes[rndRow] && nodes[rndRow][rndCol])
				{
					curNode = nodes[rndRow][rndCol];
					if (curNode.terrainType == RandomMapGenerator.LAND)
					{
						rnd = treesArr.length * Math.random();
						_allRelevantTiles.push( { "groundTileTexture":"grass", "obstacleTextureName":treesArr[rnd] + "_default00", "row":rndRow, "regionNum":curNode.regionNum, "col":rndCol, "walkable":false, "textureFrame":0 } );
					}
				}
			}
			
			
			return _allRelevantTiles;
		}
		
		public function drawMap():void
		{
			//var terrain:Array = new Array();
			var color:Number;
			var row:int = 0;
			var col:int = 0;
			var curNode:RandomNode;

			for (var i:int = 0; i < AGE; i++ )
			{
				for (row = 0; row < numRows; row++ )
				{
					for (col = 0; col < numCols; col++ )
					{
						curNode = nodes[row][col];
						var x1:int = col * Parameters.tileSize;
						var y1:int = row * Parameters.tileSize;
						
						var sum:Number = 0;
						
						sum += getLandHeight( row -1 , col -1 );//nw
						sum += getLandHeight( row -1 , col    );//n
						sum += getLandHeight( row -1 , col +1 );//ne
						sum += getLandHeight( row    , col -1 );//w
						sum += getLandHeight( row    , col +1 );//e
						sum += getLandHeight( row +1 , col -1 );//sw
						sum += getLandHeight( row +1 , col    );//s
						sum += getLandHeight( row +1 , col + 1);//se
						sum += curNode.terrainHeight * 2;
						sum /= 10.0;
						
						curNode.terrainHeight = sum;
						
						if (sum > LAND_THRESHOLD)
						{
							curNode.terrainType = RandomMapGenerator.LAND;
							curNode.walkable = true;
						}
						else
						{
							curNode.terrainType = RandomMapGenerator.SEA;
							curNode.walkable = false;
						}
						
						//this.graphics.beginFill(color);
						//this.graphics.drawRect(x1, y1, tileSize, tileSize );
						//this.graphics.endFill();
					}
				}
			}
			
			
			//addChild(createGridLines())
		}
		
		
		
		
		
		private function getLandHeight(row:int, col:int):Number 
		{
			if (row < 0){row = numRows - 1;}
			else if (row >= numRows) { row = 0; }
			
			if (col < 0){col = numCols - 1;}
			else if (col >= numCols) { col = 0; }
			
			return nodes[row][col].terrainHeight;
		}
		
		public function labelMap( terrainType:int ):void 
		{
			var row:int;
			var col:int;
			var curNode:RandomNode;
			var curRegionNum:int = ( terrainType == RandomMapGenerator.LAND ) ? 1 : 100001;
			var regionNumSetsDict:Dictionary = new Dictionary();
			//First pass
			for ( row = 0; row < numRows; row++ ) 
			{
				for ( col = 0; col < numCols; col++ ) 
				{
					curNode = nodes[ row ][ col ];
					if ( curNode.terrainType == terrainType ) 
					{
						var neighborRegionNums:Array = getNeighborRegionNums( terrainType, row, col );
						if ( neighborRegionNums.length == 0 ) 
						{ // start new region
							regionNumSetsDict[ curRegionNum ] = [ curRegionNum ];
							curNode.regionNum = curRegionNum;
							curRegionNum++;
						} 
						else 
						{
							curNode.regionNum = neighborRegionNums[ 0 ];
							for each ( var neighborRegionNum:int in neighborRegionNums ) 
							{
								regionNumSetsDict[ neighborRegionNum ] = union( regionNumSetsDict[ neighborRegionNum ], neighborRegionNums ).sort( Array.NUMERIC );
							}
						}
					}
				}
			}
			//Second pass
			var distinctRegionNums:Array = new Array();
			var regions:Dictionary       = new Dictionary();
			for each ( var regionNumSet:Array in regionNumSetsDict ) {
				var regionNum:int = regionNumSet[ 0 ];
				if ( distinctRegionNums.indexOf( regionNum ) < 0 ) {
					distinctRegionNums.push( regionNum );
					regions[ regionNum ] = new Region( regionNum );
					allRegions[ regionNum ] = regions[ regionNum ];
				}
			}
			for ( row = 0; row < numRows; row++ ) {
				for ( col = 0; col < numCols; col++ ) {
					curNode = nodes[ row ][ col ];
					if ( curNode.terrainType == terrainType ) {
						curNode.regionNum = regionNumSetsDict[ curNode.regionNum ][ 0 ];
						var region:Region = regions[ curNode.regionNum ];
						region.addNode( curNode );
					}
				}
			}
		}
		
		private function getNeighborRegionNums( terrainType:int, row:int, col:int ):Array {
			var neighborRegionNums:Array = new Array();
			neighborRegionNums = getRegionNum( terrainType, neighborRegionNums, row - 1, col - 1 ); //nw
			neighborRegionNums = getRegionNum( terrainType, neighborRegionNums, row - 1, col ); //n
			neighborRegionNums = getRegionNum( terrainType, neighborRegionNums, row - 1, col + 1 ); //n3
			neighborRegionNums = getRegionNum( terrainType, neighborRegionNums, row, col - 1 ); //w
			return neighborRegionNums.sort( Array.NUMERIC );
		}
		
		private function getRegionNum(terrainType:int, neighBorReigonNums:Array, row:int, col:int):Array 
		{
			var curNode:RandomNode = null;
			
			//check for valid location in the grid
			if (row >= 0  && col >= 0 && col < numCols && row < numRows)
			{
				curNode = nodes[row][col];
				
				if ((curNode.terrainType & terrainType) && curNode.regionNum > 0)
				{
					//we have a region
					if (neighBorReigonNums.indexOf(curNode.regionNum) < 0)
					{
						neighBorReigonNums.push(curNode.regionNum);
					}
				}
			}
			
			return neighBorReigonNums;
		}
		
		static public function union( array1:Array, array2:Array ):Array {
			if ( array1 == null || array2 == null ) {
				throw new Error( "UNION SENT NULL" );
			}
			for ( var i:int = 0; i < array2.length; i++ ) {
				if ( array1.indexOf( array2[ i ]) < 0 ) {
					array1.push( array2[ i ]);
				}
			}
			for ( i = 0; i < array1.length; i++ ) {
				if ( array2.indexOf( array1[ i ]) < 0 ) {
					array2.push( array1[ i ]);
				}
			}
			return array1;
		}
	}
	
}
