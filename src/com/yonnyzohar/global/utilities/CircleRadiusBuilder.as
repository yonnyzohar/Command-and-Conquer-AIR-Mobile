package com.yonnyzohar.global.utilities
{
	
	public class  CircleRadiusBuilder
	{
		/** Distribute the points clockwise around the circle. */
		private static const CLOCKWISE : String = "clockwise";
		/** Distribute the points counterclockwise around the circle. */
		private static const COUNTERCLOCKWISE : String = "counterclockwise";
		
		/**
		 *  This method accepts arguments based on the size and position of your circle
		 *  along with the amount of points to distribute around the circle,
		 *  what angle to start the first point, which direction to plot the points,
		 *  how much of the circumference to use for the distribution, and which direction
		 *  around the circle to plot the points.
		 *  @example example:
		 *
		 *  @param centerx The center x position of the circle to place the points around.
		 *  @param centery The center y position of the circle to place the points around.
		 *  @param radi The radius of the circle to distribute the points around.
		 *  @param total The total amount of point to distribute around the circle.
		 *  @param startangle [Optional] The starting angle of the first point. This is based on the 0-360 range.
		 *  @param arc [Optional] The length of distribution around the circle to evenly distribute the points. This is based on 0-360.
		 *  @param dir [Optional] This determines the direction that the points will distribute around the circle.
		 *  @param evenDist [Optional] If set to true, AND if you're arc angle is less than 360, this will evently distribute the points around the circle.<br/>If set to true, the points are visually arranged in this manner POINT-SPACE-POINT-SPACE-POINT, if set to false, an extra space will be added after the last point: POINT-SPACE-POINT-SPACE-POINT-SPACE
		 *
		 *  @return Returns an Array containing Points.
		 */
		
		public static function getPointsAroundCircumference(centerx : Number, centery : Number, circleradius : Number, totalpoints : int, startangle : Number = 0, arc : int = 360, pointdirection : String = "clockwise", evendistribution : Boolean = true) : Array
		{
			var mpi : Number = Math.PI / 180;
			var startRadians : Number = startangle * mpi;
			
			var incrementAngle : Number = arc / totalpoints;
			var incrementRadians : Number = incrementAngle * mpi;
			
			if(arc < 360)
			{
				// this spreads the points out evenly across the arc
				if(evendistribution)
				{
					incrementAngle = arc / (totalpoints - 1);
					incrementRadians = incrementAngle * mpi;
				}
				else
				{
					incrementAngle = arc / totalpoints;
					incrementRadians = incrementAngle * mpi;
				}
			}
			
			var pts : Array = [];
			
			while(totalpoints--)
			{
				var xp : Number = centerx + Math.sin(startRadians) * circleradius;
				var yp : Number = centery + Math.cos(startRadians) * circleradius;
				var pt : Object = new Object();
				pt.x = xp;
				pt.y = yp;
				pt.angle = startRadians;
				pts.push(pt);
				
				if(pointdirection == COUNTERCLOCKWISE)
				{
					startRadians += incrementRadians;
				}
				else
				{
					startRadians -= incrementRadians;
				}
			}
			
			return pts;
		}
	}
}




