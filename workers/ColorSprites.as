package 
{
	import flash.display.BitmapData;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class ColorSprites 
	{
		
		private static var colors:Array = [[0, 0, 0], [193, 0, 173], [0, 175, 171], [0, 182, 0], [16, 16, 16], [252, 255, 50], [255, 49, 77], [186, 79, 0], [191, 0, 0], [0, 255, 255], [93, 0, 255], [30, 0, 175], [0, 0, 0], [85, 85, 85], [170, 170, 170], [255, 255, 255], [255, 216, 133], [255, 207, 143], [255, 208, 134], [255, 207, 129], [255, 208, 115], [255, 191, 108], [255, 192, 83], [252, 174, 75], [252, 175, 51], [247, 148, 10], [232, 117, 0], [217, 90, 0], [201, 60, 0], [183, 40, 0], [171, 12, 0], [153, 0, 0], [0, 200, 225], [55, 164, 205], [75, 139, 185], [87, 112, 168], [75, 139, 185], [55, 164, 205], [30, 182, 225], [255, 255, 255], [255, 255, 255], [0, 189, 0], [127, 0, 0], [127, 0, 0], [109, 0, 0], [100, 0, 0], [109, 0, 0], [19, 0, 0], [17, 12, 12], [10, 17, 12], [17, 11, 20], [11, 16, 20], [20, 20, 24], [33, 28, 28], [21, 33, 28], [32, 32, 28], [23, 28, 32], [27, 32, 36], [36, 36, 40], [50, 39, 40], [37, 49, 44], [53, 48, 44], [40, 39, 48], [41, 52, 52], [51, 57, 52], [71, 55, 56], [24, 71, 38], [47, 66, 38], [35, 66, 56], [51, 70, 55], [45, 83, 59], [68, 69, 59], [106, 80, 53], [56, 55, 69], [52, 69, 68], [49, 63, 111], [67, 73, 68], [88, 71, 72], [67, 87, 71], [83, 91, 71], [104, 89, 84], [79, 104, 74], [59, 104, 84], [84, 103, 84], [100, 103, 74], [121, 102, 74], [99, 107, 88], [120, 106, 88], [95, 120, 87], [116, 119, 91], [77, 120, 96], [78, 119, 117], [99, 124, 100], [122, 117, 117], [147, 86, 78], [143, 113, 86], [141, 121, 108], [99, 137, 90], [111, 137, 99], [110, 153, 115], [131, 140, 103], [152, 139, 102], [148, 152, 101], [131, 139, 116], [147, 156, 114], [175, 150, 114], [137, 170, 114], [169, 174, 117], [85, 117, 168], [143, 114, 172], [70, 134, 146], [114, 143, 137], [4, 4, 8], [20, 19, 28], [34, 44, 53], [50, 73, 76], [61, 89, 98], [77, 110, 118], [91, 130, 138], [106, 150, 158], [61, 31, 18], [98, 40, 24], [134, 39, 31], [170, 28, 28], [194, 27, 9], [221, 0, 0], [249, 0, 0], [255, 0, 0], [141, 141, 65], [159, 166, 86], [179, 191, 115], [198, 215, 144], [181, 167, 130], [149, 129, 116], [121, 100, 101], [0, 116, 114], [0, 95, 102], [0, 77, 94], [0, 59, 81], [0, 51, 73], [24, 72, 34], [24, 90, 41], [35, 106, 53], [42, 127, 64], [116, 99, 42], [150, 123, 57], [190, 147, 71], [229, 171, 92], [255, 154, 31], [255, 215, 40], [112, 75, 53], [137, 92, 69], [175, 120, 85], [33, 29, 53], [64, 64, 64], [165, 146, 123], [184, 206, 0], [170, 185, 0], [202, 219, 0], [0, 162, 45], [0, 107, 18], [205, 255, 255], [144, 208, 211], [213, 199, 172], [220, 211, 193], [195, 254, 0], [127, 238, 0], [109, 213, 0], [202, 202, 202], [72, 72, 72], [179, 177, 233], [159, 128, 0], [143, 112, 0], [119, 87, 0], [79, 33, 21], [145, 0, 0], [253, 218, 110], [229, 194, 95], [204, 173, 84], [184, 152, 71], [142, 115, 48], [102, 77, 30], [59, 45, 17], [17, 12, 3], [198, 178, 88], [173, 157, 77], [146, 141, 69], [126, 120, 58], [110, 104, 51], [89, 88, 40], [72, 70, 33], [57, 53, 26], [218, 218, 218], [190, 190, 190], [161, 161, 161], [133, 133, 133], [109, 109, 109], [80, 80, 80], [52, 52, 52], [24, 24, 24], [222, 221, 230], [195, 192, 211], [166, 162, 191], [134, 130, 158], [102, 98, 126], [73, 70, 94], [45, 42, 61], [20, 19, 28], [255, 199, 111], [182, 111, 70], [136, 173, 200], [95, 87, 139], [95, 62, 102], [149, 72, 97], [124, 47, 72], [150, 144, 79], [126, 120, 53], [255, 138, 146], [255, 118, 126], [0, 112, 152], [0, 83, 123], [0, 158, 146], [0, 129, 118], [0, 101, 89], [118, 134, 176], [90, 146, 201], [137, 137, 133], [149, 150, 132], [169, 149, 140], [173, 177, 139], [139, 132, 184], [154, 131, 184], [155, 145, 188], [170, 146, 171], [169, 148, 188], [201, 184, 137], [170, 147, 196], [180, 171, 204], [208, 178, 203], [234, 216, 231], [29, 25, 6], [37, 33, 10], [41, 37, 14], [47, 50, 17], [55, 58, 25], [63, 66, 29], [71, 74, 37], [79, 82, 45], [88, 91, 53], [91, 100, 61], [99, 108, 69], [107, 116, 83], [115, 124, 91], [123, 131, 103], [131, 139, 116], [255, 255, 255]];

		private static var palettes:Object = {
				gdi: 	[176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191],
				nod: 	[127, 126, 125, 124, 122, 46, 120, 47, 125, 124, 123, 122, 42, 121, 120, 120],
				yellow: [176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191],
				red: 	[127, 126, 125, 124, 122, 46, 120, 47, 125, 124, 123, 122, 42, 121, 120, 120],
				teal: 	[2, 119, 118, 135, 136, 138, 112, 12, 118, 135, 136, 137, 138, 139, 114, 112],
				orange: [24, 25, 26, 27, 29, 31, 46, 47, 26, 27, 28, 29, 30, 31, 43, 47],
				green: 	[5, 165, 166, 167, 159, 142, 140, 199, 166, 167, 157, 3, 159, 143, 142, 141],
				gray: 	[161, 200, 201, 202, 204, 205, 206, 12, 201, 202, 203, 204, 205, 115, 198, 114],
				neutral: [176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191],
				darkgray: [14, 195, 196, 13, 169, 198, 199, 112, 14, 195, 196, 13, 169, 198, 199, 112],
				brown: 		[146, 152, 209, 151, 173, 150, 173, 183, 146, 152, 209, 151, 173, 150, 173, 183]
			};
		
		public function ColorSprites() 
		{
			
		}
		
		public static function colorImages(bd:BitmapData, color:String):BitmapData 
		{
			var paletteOriginal:Array = palettes["yellow"];
			var paletteFinal:Array = palettes[color]
			var rThreshold:int = 25;
			var gThreshold:int = 25;
			var bThreshold:int = 25;
			var bdWidth:int = bd.width;
			var bdHeight:int = bd.height;
			
			if (color == "yellow")
			{
				return bd;
			}
			   
			for(var col:int = 0; col < bdWidth; col++)
			{
				 for(var row:int = 0; row < bdHeight; row++)
				 {
					 var pixel:uint = bd.getPixel(col, row);
					 //if pixel si not transparent
					 if(pixel != 0)
					 {
						//var rgb:Object = hexToRGB(pixel);
						
						var red:uint   = ((pixel & 0xFF0000) >> 16);
						var green:uint = ((pixel & 0x00FF00) >> 8);
						var blue:uint  = ((pixel & 0x0000FF));
						
						
						//iterate over each color array
						for (var i:int = 16 - 1; i >= 0; i--) 
						{
							//get the actual color in the original array
							var colorOriginal:Array = colors[paletteOriginal[i]];
							//get the coresponding color in the new array
							var colorFinal:Array    = colors[paletteFinal[i]];
							
							//if the current pixel and the colot from the original array are similar - replace it with the value of the new array
							if (Math.abs(red - colorOriginal[0])   < rThreshold && 
								Math.abs(green - colorOriginal[1]) < gThreshold && 
								Math.abs(blue - colorOriginal[2])  < bThreshold) 
							{
								red = colorFinal[0];
								green = colorFinal[1];
								blue = colorFinal[2];
								var xolorHex:String = (RGBtoHEX(red, green, blue ))
								var decimal:uint = parseInt (xolorHex, 16);
								bd.setPixel(col, row, decimal);
								break
							}
						}
					 }
					 
				 }
			}
			
			return bd;
		}
		
		private static function hexToRGB(hex:Number):Object
			{
				var rgbObj:Object = {
					red: ((hex & 0xFF0000) >> 16),
					green: ((hex & 0x00FF00) >> 8),
					blue: ((hex & 0x0000FF))
				};
			 
				return rgbObj;
			}

		private static function RGBtoHEX(r:int, g:int, b:int):String { 
				var s = (r << 16 | g << 8 | b).toString(16); 
				while (s.length < 6)
				{
					s="0"+s;
				}
				return "0x"+s;
		}
		
	}

}

