package com.rectanglePacker.utils
{
	import com.rectanglePacker.utils.CTextureData;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author 
	 */
	public class CMaxRectBinPack 
	{
		public var m_binWidth : int;
		public var m_binHeight : int;
		public var m_freeRectangles : Vector.<Rectangle>;
		
		public function CMaxRectBinPack(binWidth : int, binHeight : int) 
		{
			m_binWidth = binWidth;
			m_binHeight = binHeight;
			
			m_freeRectangles= new Vector.<Rectangle>;
			m_freeRectangles.push(new Rectangle(0, 0, m_binWidth, m_binHeight));
		}
		
		public function reset(binWidth : int = -1, binHeight : int = -1) : void
		{
			if (binWidth != -1 && binHeight != -1)
			{
				m_binWidth = binWidth;
				m_binHeight = binHeight;
			}
			m_freeRectangles= new Vector.<Rectangle>;
			m_freeRectangles.push(new Rectangle(0, 0, m_binWidth, m_binHeight));
		}
		
		public function isContainedIn(a : Rectangle, b : Rectangle) : Boolean
		{
			return a.x >= b.x && a.y >= b.y 
				&& a.x+a.width <= b.x+b.width 
				&& a.y+a.height <= b.y+b.height;
		}
		
		public function scoreRect(width : int, height : int, method : String) : Object
		{
			var score1 : int;
			var score2 : int;
			var newNode : Rectangle;
			var result : Object = new Object();
			
			result.score1 = int.MAX_VALUE;
			result.score2 = int.MAX_VALUE;
			
			if (method == "area")
			{
				FindPositionForNewNodeBestAreaFit(width, height, result );
			}
			else
			{
				findPositionForNewNodeBestShortSideFit(width, height, result );
			}
			/*switch(method)
			{
			case "RectBestShortSideFit":  findPositionForNewNodeBestShortSideFit(width, height, result ); break;
			case RectBottomLeftRule: newNode = FindPositionForNewNodeBottomLeft(width, height, score1, score2); break;
			case RectContactPointRule: newNode = FindPositionForNewNodeContactPoint(width, height, score1); 
				score1 = -score1; // Reverse since we are minimizing, but for contact point score bigger is better.
				break;
			case RectBestLongSideFit: newNode = FindPositionForNewNodeBestLongSideFit(width, height, score2, score1); break;
			case RectBestAreaFit: newNode = FindPositionForNewNodeBestAreaFit(width, height, score1, score2); break;
			}*/

			newNode = result.bestNode;
			// Cannot fit the current rectangle.
			if (newNode.height == 0)
			{
				result.score1 = int.MAX_VALUE;
				result.score2 = int.MAX_VALUE;
				result.failed = true;
			}
						
			return result;
		}
		
		public function findPositionForNewNodeBestShortSideFit(width : int, height : int, output : Object) : void	
		{
			var bestShortSideFit : int
			var bestLongSideFit : int;
			var bestNode : Rectangle = new Rectangle();
			

			bestShortSideFit = int.MAX_VALUE;
			var len : int = m_freeRectangles.length;

			for(var i : int = 0; i < len; ++i)
			{
				// Try to place the rectangle in upright (non-m_freeRectangles) orientation.
				if (m_freeRectangles[i].width >= width && m_freeRectangles[i].height >= height)
				{
					var leftoverHoriz: int = Math.abs(m_freeRectangles[i].width - width);
					var leftoverVert : int = Math.abs(m_freeRectangles[i].height - height);
					var shortSideFit : int = Math.min(leftoverHoriz, leftoverVert);
					var longSideFit : int = Math.max(leftoverHoriz, leftoverVert);

					if (shortSideFit < bestShortSideFit || (shortSideFit == bestShortSideFit && longSideFit < bestLongSideFit))
					{
						bestNode.x = m_freeRectangles[i].x;
						bestNode.y = m_freeRectangles[i].y;
						bestNode.width = width;
						bestNode.height = height;
						bestShortSideFit = shortSideFit;
						bestLongSideFit = longSideFit;
					}
				}

				/*if (freeRectangles[i].width >= height && freeRectangles[i].height >= width)
				{
					int flippedLeftoverHoriz = abs(freeRectangles[i].width - height);
					int flippedLeftoverVert = abs(freeRectangles[i].height - width);
					int flippedShortSideFit = min(flippedLeftoverHoriz, flippedLeftoverVert);
					int flippedLongSideFit = max(flippedLeftoverHoriz, flippedLeftoverVert);

					if (flippedShortSideFit < bestShortSideFit || (flippedShortSideFit == bestShortSideFit && flippedLongSideFit < bestLongSideFit))
					{
						bestNode.x = freeRectangles[i].x;
						bestNode.y = freeRectangles[i].y;
						bestNode.width = height;
						bestNode.height = width;
						bestShortSideFit = flippedShortSideFit;
						bestLongSideFit = flippedLongSideFit;
					}
				}*/
			}
			
			output.score1 = bestShortSideFit;
			output.score2 = bestShortSideFit;
			output.bestNode = bestNode;
			
		}
		
		public function FindPositionForNewNodeBestAreaFit(width : int, height : int, output : Object) : void	
		{
			var bestAreaFitScore : Number = 0;			
			var bestNode : Rectangle = new Rectangle();
						
			var len : int = m_freeRectangles.length;
			
			var inputRectArea : int = width * height;

			for(var i : int = 0; i < len; ++i)
			{
				// Try to place the rectangle in upright (non-m_freeRectangles) orientation.
				if (m_freeRectangles[i].width >= width && m_freeRectangles[i].height >= height)
				{
					var freeRectArea : int = m_freeRectangles[i].width * m_freeRectangles[i].height;
					var score : Number = inputRectArea / freeRectArea;					

					if (score > bestAreaFitScore)
					{
						bestNode.x = m_freeRectangles[i].x;
						bestNode.y = m_freeRectangles[i].y;
						bestNode.width = width;
						bestNode.height = height;
						bestAreaFitScore = score;
						
					}
				}

				/*if (freeRectangles[i].width >= height && freeRectangles[i].height >= width)
				{
					int flippedLeftoverHoriz = abs(freeRectangles[i].width - height);
					int flippedLeftoverVert = abs(freeRectangles[i].height - width);
					int flippedShortSideFit = min(flippedLeftoverHoriz, flippedLeftoverVert);
					int flippedLongSideFit = max(flippedLeftoverHoriz, flippedLeftoverVert);

					if (flippedShortSideFit < bestShortSideFit || (flippedShortSideFit == bestShortSideFit && flippedLongSideFit < bestLongSideFit))
					{
						bestNode.x = freeRectangles[i].x;
						bestNode.y = freeRectangles[i].y;
						bestNode.width = height;
						bestNode.height = width;
						bestShortSideFit = flippedShortSideFit;
						bestLongSideFit = flippedLongSideFit;
					}
				}*/
			}
			
			output.score1 = bestAreaFitScore;
			output.score2 = bestAreaFitScore;
			output.bestNode = bestNode;
			
		}
		
		public function splitFreeNode(freeNode : Rectangle, usedNode : Rectangle ) : Boolean
		{
			// Test with SAT if the rectangles even intersect.
			if (usedNode.x >= freeNode.x + freeNode.width || usedNode.x + usedNode.width <= freeNode.x ||
				usedNode.y >= freeNode.y + freeNode.height || usedNode.y + usedNode.height <= freeNode.y)
				return false;

			if (usedNode.x < freeNode.x + freeNode.width && usedNode.x + usedNode.width > freeNode.x)
			{
				// New node at the top side of the used node.
				if (usedNode.y > freeNode.y && usedNode.y < freeNode.y + freeNode.height)
				{
					var newNode : Rectangle = new Rectangle(freeNode.x, freeNode.y, freeNode.width, freeNode.height);
					newNode.height = usedNode.y - newNode.y;
					m_freeRectangles.push(newNode);
				}

				// New node at the bottom side of the used node.
				if (usedNode.y + usedNode.height < freeNode.y + freeNode.height)
				{
					newNode = new Rectangle(freeNode.x, freeNode.y, freeNode.width, freeNode.height);
					newNode.y = usedNode.y + usedNode.height;
					newNode.height = freeNode.y + freeNode.height - (usedNode.y + usedNode.height);
					m_freeRectangles.push(newNode);
				}
			}

			if (usedNode.y < freeNode.y + freeNode.height && usedNode.y + usedNode.height > freeNode.y)
			{
				// New node at the left side of the used node.
				if (usedNode.x > freeNode.x && usedNode.x < freeNode.x + freeNode.width)
				{
					newNode = new Rectangle(freeNode.x, freeNode.y, freeNode.width, freeNode.height);
					newNode.width = usedNode.x - newNode.x;
					m_freeRectangles.push(newNode);
				}

				// New node at the right side of the used node.
				if (usedNode.x + usedNode.width < freeNode.x + freeNode.width)
				{
					newNode = new Rectangle(freeNode.x, freeNode.y, freeNode.width, freeNode.height);
					newNode.x = usedNode.x + usedNode.width;
					newNode.width = freeNode.x + freeNode.width - (usedNode.x + usedNode.width);
					m_freeRectangles.push(newNode);
				}
			}

			return true;
		}

		public function pruneFreeList() : void
		{
			/* 
			///  Would be nice to do something like this, to avoid a Theta(n^2) loop through each pair.
			///  But unfortunately it doesn't quite cut it, since we also want to detect containment. 
			///  Perhaps there's another way to do this faster than Theta(n^2).

			if (freeRectangles.size() > 0)
				clb::sort::QuickSort(&freeRectangles[0], freeRectangles.size(), NodeSortCmp);

			for(size_t i = 0; i < freeRectangles.size()-1; ++i)
				if (freeRectangles[i].x == freeRectangles[i+1].x &&
					freeRectangles[i].y == freeRectangles[i+1].y &&
					freeRectangles[i].width == freeRectangles[i+1].width &&
					freeRectangles[i].height == freeRectangles[i+1].height)
				{
					freeRectangles.erase(freeRectangles.begin() + i);
					--i;
				}
			*/

			/// Go through each pair and remove any rectangle that is redundant.
			for(var i : int = 0; i < m_freeRectangles.length; ++i)
				for(var j : int = i+1; j < m_freeRectangles.length; ++j)
				{
					if (isContainedIn(m_freeRectangles[i], m_freeRectangles[j]))
					{
						m_freeRectangles.splice(i, 1);
						--i;
						break;
					}
					if (isContainedIn(m_freeRectangles[j], m_freeRectangles[i]))
					{
						m_freeRectangles.splice(j, 1);
						--j;
					}
				}
		}
		
		public function placeRect(node : Rectangle) : void
		{
			var numRectanglesToProcess : int = m_freeRectangles.length;
			for(var i : int = 0; i < numRectanglesToProcess; ++i)
			{
				if (splitFreeNode(m_freeRectangles[i], node))
				{
					m_freeRectangles.splice(i, 1);
					--i;
					--numRectanglesToProcess;
				}
			}

			pruneFreeList();

			//m_usedRectangles.push(node);
			//		dst.push_back(bestNode); ///\todo Refactor so that this compiles.
		}
		
		public function insertRects(textureDataArray : Vector.<CTextureData>, huristics : String = "", padding : int = 1) : Boolean
		{			
			
			var rects : Vector.<CTextureData> = new Vector.<CTextureData>();
			var td : CTextureData;
			for (var i : int = 0; i < textureDataArray.length; ++i)
			{
				td = textureDataArray[i];
				rects.push(td);
			}
			var bestNode : Rectangle;
			var result : Object;
			var rectWidth : int;
			var rectHeight : int;
			
			if (huristics == "simple")
			{
				for(i = 0; i < rects.length; ++i)
				{
					
					td = rects[i];
					rectWidth = td.img.width < m_binWidth ? td.img.width + padding : td.img.width;
					rectHeight = td.img.height < m_binHeight? td.img.height + padding : td.img.height;
					
					result = scoreRect(rectWidth, rectHeight, huristics);
					if (result.failed == true)
					{
						return false;
					}
					bestNode = result.bestNode;
					td.m_textureRect = bestNode;
					placeRect(bestNode);
				}
			}
			else
			{
				while(rects.length > 0)
				{
					var bestScore1 : int = int.MAX_VALUE;
					var bestScore2 : int = int.MAX_VALUE;
					var bestRectIndex : int = -1;					
					// find the rect scoring the highest
					for(i = 0; i < rects.length; ++i)
					{						
						td = rects[i];
						rectWidth = td.img.width < m_binWidth ? td.img.width + padding : td.img.width;
						rectHeight = td.img.height < m_binHeight? td.img.height + padding : td.img.height;
						
						result = scoreRect(rectWidth, rectHeight, huristics);
						
						if (result.score1 < bestScore1 || (result.score1 == bestScore1 && result.score2 < bestScore2))
						{
							bestScore1 = result.score1;
							bestScore2 = result.score2;
							bestNode = result.bestNode;
							td.m_textureRect = bestNode;
							bestRectIndex = i;
						}
					}

					if (bestRectIndex == -1)
					{
						return false;
					}

					placeRect(bestNode);
					rects.splice(bestRectIndex, 1);
				}
			}
			
			
			
			for (i = 0; i < textureDataArray.length; ++i)
			{
				td = textureDataArray[i];
				td.m_textureRect.width -= padding;
				td.m_textureRect.height -= padding;
			}
			
			return true;
		}
		
		public function dispose():void 
		{
			m_freeRectangles = null;
		}
		
	}

}