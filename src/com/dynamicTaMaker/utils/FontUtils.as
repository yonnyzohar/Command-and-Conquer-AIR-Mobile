package com.dynamicTaMaker.utils {
	import com.dynamicTaMaker.utils.PNGEncoder;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextLineMetrics;
	import flash.utils.ByteArray;

	/**
	 * ...
	 * @author CD
	 */
	public class FontUtils {

		public static function drawTextField(textHolder: DisplayObject): BitmapData {
			// adding the textfield to an empty sprite and doing some manipulations to fix issues with the positioning of the bd.draw() call
			// see http://stackoverflow.com/questions/6953326/get-bitmapdata-from-a-displayobject-included-transparent-area-and-effect-area for details
			var childIndex: Number;
			var parent: DisplayObjectContainer = textHolder.parent;
			if (parent) {
				childIndex = parent.getChildIndex(textHolder);
			}

			var container: Sprite = new Sprite;
			container.addChild(textHolder);
			var containerRect: Rectangle = container.getBounds(container);

			var bd: BitmapData = new BitmapData(containerRect.width, containerRect.height, true, 0);
			var matrix: Matrix = new Matrix;
			matrix.translate(-containerRect.x, -containerRect.y);
			bd.draw(container, matrix);

			if (parent) {
				parent.addChildAt(textHolder, childIndex);
			}

			return bd;
		}

		public static function getEmbeddedChars(text: String): String {
			// We will decide which characters to embed according to the text..			
			// These are the alphabet without the X and x which represent a multiplier, for this case we will create only numerals and X
			var lettersPattern: RegExp = /[a-wyzA-WYZ]/g;
			var multiplierPattern: RegExp = /[0123456789X]/g;

			var embeddedChars: String;
			var additionalChars: String;
			var existsCharsPattern: RegExp;

			// If it contains numbers only, we will embed all of the digits and commas

			if (text.search(multiplierPattern) != -1 && text.search(lettersPattern) == -1) {

				embeddedChars = "0123456789,.XMKBT";


				existsCharsPattern = /[0-9,]/g;

				additionalChars = text.replace(existsCharsPattern, "");
				embeddedChars += additionalChars;
			}
			// If it contains letters, we will export all alpha numeric characters
			else if (text.search(lettersPattern) != -1) {
				embeddedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,.0123456789!?:";

				existsCharsPattern = /[a-zA-Z,.0123456789]/g;

				additionalChars = text.replace(existsCharsPattern, "");
				embeddedChars += additionalChars;
			}

			return embeddedChars;
		}

		public static function createTightBitmap(textHolder: DisplayObject, tf: TextField): Object {
			var bmpObject: Object;

			try {
				var oldTextFormat: TextFormat = tf.getTextFormat();
				var oldAlignment: String = oldTextFormat.align;
				oldTextFormat.align = TextFormatAlign.LEFT;
				tf.setTextFormat(oldTextFormat);
				var filters: Array = tf.filters;
				tf.filters = new Array();
				var rawbd: BitmapData = drawTextField(textHolder);


				oldTextFormat.align = oldAlignment;
				tf.setTextFormat(oldTextFormat);
				tf.filters = filters;
				var bd: BitmapData = drawTextField(textHolder);


				var minX: int = bd.width;
				var minY: int = bd.height;
				var maxX: int = 0;
				var maxY: int = 0;

				var minrawX: int = rawbd.width;
				var minrawY: int = rawbd.height;
				var maxrawX: int = 0;
				var maxrawY: int = 0;

				var line: int;
				var startX: int;
				var endX: int;
				var pixelValue: int;
				var nonTransparentPixel: Boolean;
				line = 0;
				maxX = 0;
				maxY = 0;
				minX = bd.width;
				minY = bd.height;

				for (line = 0; line < bd.height; ++line) {
					nonTransparentPixel = false;
					startX = 0;
					endX = bd.width - 1;
					while (startX < endX) {
						pixelValue = bd.getPixel32(startX, line);
						if (pixelValue == 0) {

						} else {
							if (startX < minX) {
								minX = startX;
							}
							if (startX > maxX) {
								maxX = startX;
							}
							nonTransparentPixel = true;
						}

						startX++;

						pixelValue = bd.getPixel32(endX, line);
						if (pixelValue == 0) {

						} else {
							if (endX > maxX) {
								maxX = endX;
							}

							if (endX < minX) {
								minX = endX;
							}
							nonTransparentPixel = true;
						}
						endX--;
					}

					if (nonTransparentPixel) {
						if (line < minY) {
							minY = line;
						}
						if (line > maxY) {
							maxY = line;
						}
					}
				}

				for (line = 0; line < rawbd.height; ++line) {
					nonTransparentPixel = false;
					startX = 0;
					endX = rawbd.width - 1;
					while (startX < endX) {
						pixelValue = rawbd.getPixel32(startX, line);
						if (pixelValue == 0) {

						} else {
							if (startX < minrawX) {
								minrawX = startX;
							}
							if (startX > maxrawX) {
								maxrawX = startX;
							}
							nonTransparentPixel = true;
						}
						startX++;
						pixelValue = rawbd.getPixel32(endX, line);
						if (pixelValue == 0) {

						} else {
							if (endX > maxrawX) {
								maxrawX = endX;
							}

							if (endX < minrawX) {
								minrawX = endX;
							}
							nonTransparentPixel = true;
						}
						endX--;
					}
					if (nonTransparentPixel) {
						if (line < minrawY) {
							minrawY = line;
						}
						if (line > maxrawY) {
							maxrawY = line;
						}
					}
				}

				var charWidth: int = tf.getLineMetrics(0).width;
				var bitmapRawWidth: int = maxrawX - minrawX;
				var bitmapWidth: int = maxX - minX;
				var bitmapHeight: int = maxY - minY;

				var croppedWidth: int = bitmapWidth + 1;
				var croppedHeight: int = bitmapHeight + 1;


				var cropedBD: BitmapData = new BitmapData(croppedWidth, croppedHeight, true, 0);
				var rect: Rectangle = new Rectangle(minX, minY, croppedWidth, croppedHeight);

				cropedBD.copyPixels(bd, rect, new Point(), null, null, false);
				bmpObject = {};
				bmpObject.bitmapData = cropedBD;
				bmpObject.maxX = maxX;
				bmpObject.maxY = maxY;
				bmpObject.minX = minX;
				bmpObject.minY = minY;
				// store the original bitmap width and the minimum X for later use
				// we use the unsed originalWidth and originalHeight fields for that
				bmpObject.originalWidth = bitmapRawWidth;
				// textfield adds extra 3 pixels to the left - so we substruct 3
				bmpObject.originalHeight = minrawX - 3;
			} catch (err: Error) {
				// Sometimes there is an error here if the text field in the fla is set as multiline and the embedded characters get some weird addition.
				trace("Error in createTightBitmap", err.message, "textHolder=", textHolder,  tf.text  ,textHolder , " with font " , tf.defaultTextFormat.font, "is the font embedded?");
			}

			return bmpObject;
		}

		public static function getSpaceWidth(textHolder: DisplayObject, tf: TextField): Number {
			tf.text = "0";
			var bmpObject: Object = createTightBitmap(textHolder, tf);
			var zeroCharWidth: Number = bmpObject.bitmapData.width;
			tf.text = "0 0";
			bmpObject = createTightBitmap(textHolder, tf);
			var spaceCharWidth: Number = bmpObject.bitmapData.width - 2 * zeroCharWidth;
			if (spaceCharWidth < 0) {
				spaceCharWidth = 0; // there's a bug where some fonts return a negative value here
			}
			return spaceCharWidth;
		}

		public static function isTextTransparent(tf: TextField): Boolean {
			var embeddedChars: String = tf.text;
			for (var i: int = 0; i < embeddedChars.length; ++i) {
				var char: String = embeddedChars.charAt(i);
				tf.text = char;
				var bd: BitmapData = drawTextField(tf);

				var isTransparent: Boolean = true;
				var line: int;
				var startX: int;
				var pixelValue: int;

				for (line = 0; line < bd.height; ++line) {
					for (startX = 0; startX < bd.width; ++startX) {
						pixelValue = bd.getPixel32(startX, line);
						if (pixelValue != 0) {
							isTransparent = false;
						}
					}
				}

				if (isTransparent) {
					trace("ERROR : TextField " + tf.name + " IS MISSING THE CHAR : " + char + " FORGOT TO EMBED FONTS?");
					return true;
				}
			}

			return false;
		}

		public static function createFont(textHolder: DisplayObject, tf: TextField, embeddedChars: String, id: String = "", uniqueFontName: String = ""): Object {
			var font: Object = {};
			font.m_spaceOffset = getSpaceWidth(textHolder, tf);
			font.m_letterSpacing = 0;
			//override m_spaceOffset with the value listed in the FontItem if it's there

			font.m_textFormat = tf.getTextFormat();

			font.m_filters = tf.filters;
			font.m_embeddedChars = embeddedChars;

			var metrics: TextLineMetrics = tf.getLineMetrics(0);

			font.m_lineHeight = metrics.ascent + metrics.descent + metrics.leading;

			if (id != "") {
				font.m_id = id;
			}

			if (uniqueFontName != "") {
				font.m_uniqueFontName = uniqueFontName;
			}

			// get the 0 char as a reference to the line
			tf.text = "0";
			var bmpObject: Object = createTightBitmap(textHolder, tf);

			font.m_lineReference = bmpObject;
			return font;
		}
		
		public static function getFontXMLNode(fontId : String, font : Object, textureDataArray : Array, taName:String, fontNode:XML) : XML
		{
			if (font == null || textureDataArray.length == 0)
			{
				return null;
			}
			
			/*<info chasrset="" unicode="0" stretchH="100" smooth="1" aa="1" padding="0,0,0,0" spacing="1,1" />
    <common lineHeight="119" base="61" scaleW="512" scaleH="512" pages="1" packed="0" />*/
			
			//<common lineHeight="119" base="61" scaleW="512" scaleH="512" pages="1" packed="0" />
			
			/*<pages>
				<page id="0" file="winCallouts1.png" />
			</pages>*/
			
			var infoNode : XML = <info/>;
			var commonNode : XML = <common/>;
			var charsNode : XML = <chars/>;
			var pagesNode:XML = <pages/>;
			var pageNode:XML = <page/>;
			
			pageNode.@id = "0";
			pageNode.@file = taName;
			
			var charNode : XML;
			
			var fontName : String = font.m_textFormat.font;
			var cutIndex : int = fontName.lastIndexOf(" ");
			var m_uniqueFontName : String = font.m_uniqueFontName;
			
			commonNode.@lineHeight = int(font.m_lineHeight);
			
			commonNode.@base="61";
			commonNode.@scaleW="512";
			commonNode.@scaleH="512";
			commonNode.@pages="1";
			commonNode.@packed="0";
			
			infoNode.@face = fontId;
			infoNode.@size = font.m_textFormat.size;
			//infoNode.@family = fontName.substr(0, cutIndex)
			
			var style:String = fontName.substr(cutIndex + 1);
			if(style == "Bold")
			{
				infoNode.@bold = "1";
				
			}
			
			infoNode.@italic = "0";
			infoNode.@chasrset="" ;
			infoNode.@unicode="0";
			infoNode.@stretchH="100";
			infoNode.@smooth="1";
			infoNode.@aa="1";
			infoNode.@padding="0,0,0,0";
			infoNode.@spacing="1,1";
			
			//infoNode.@style = fontName.substr(cutIndex + 1);
			
			//infoNode.@spaceOffset = font.m_spaceOffset;
			
			if (font.m_lineSpacing)
			{
				//infoNode.@lineSpacing = font.m_lineSpacing;
				infoNode.@lineHeight = int(font.m_lineHeight) + int(font.m_lineSpacing);
			}
			
			charsNode.@count = textureDataArray.length;
			
			var textureData : Object;
			var charCode : int;
			for (var i : int = 0; i < textureDataArray.length; ++i)
			{
				textureData = textureDataArray[i];
				charNode = <char/>
				
				charCode = font.m_embeddedChars.charCodeAt(i);
				charNode.@id = charCode;
				charNode.@x = textureData.m_textureRect.x;
				charNode.@y = textureData.m_textureRect.y;
				charNode.@width = textureData.m_textureRect.width;
				charNode.@height = textureData.m_textureRect.height;
				//charNode.@xoffset = 0;
				var yOffset : int = textureData.m_extraData.minY - font.m_lineReference.minY;
				charNode.@yoffset = yOffset;
				var xoffset : int = textureData.m_extraData.originalHeight;
				if (xoffset < 0) 
				{
					xoffset = 0;
				}
				charNode.@xoffset = xoffset;
				var xadvance : int = font.m_charsAdvance[i];
				var xadvanceExtra : int = (textureData.m_extraData.maxX - textureData.m_extraData.minX) - textureData.m_extraData.originalWidth;
				// the *0.7 is just a hard coded "NICE" looking number there is no math behind it
				xadvance += xadvanceExtra * 0.7 + font.m_letterSpacing;
				charNode.@xadvance = xadvance;
				charsNode.appendChild(charNode);
			}
			fontNode.appendChild(infoNode);
			pagesNode.appendChild(pageNode);
			fontNode.appendChild(pagesNode);
			fontNode.appendChild(commonNode);
			fontNode.appendChild(charsNode);
			
			return fontNode;
		}
		
		
		
		
	}
}