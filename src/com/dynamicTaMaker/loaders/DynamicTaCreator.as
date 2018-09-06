package com.dynamicTaMaker.loaders {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;

	import com.dynamicTaMaker.utils.*;
	import com.rectanglePacker.utils.*

	//https://github.com/jakesgordon/bin-packing/blob/master/js/packer.js

	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class DynamicTaCreator extends EventDispatcher {
		private var rejectsArr: Array = [];

		private var brk: String = '\n';
		private var lastY: int = 0;
		private var lastX: int = 0;
		private var widestInRow: int = 0;
		private var count: int = 0;
		private var dimentionsW: int = 2048;
		private var dimentionsH: int = 1024;

		private var view: MovieClip;
		private var imagesData: Vector.<CTextureData> = new Vector.<CTextureData>();
		private var taMC: MovieClip = new MovieClip();

		public var taPlacements: String;
		public var TAbitmapData: BitmapData;
		//public var placementsXML:String = "";
		public var viewHeirarchyObj: Object;
		private var mPacker: CMaxRectBinPack; //RectanglePacker;
		private var m_defaultFontsList: Array = [];
		public var m_fontsDataMap: Object = {};
		public var m_uniqueFontsMap: Object = {};
		private var m_textureDataArray: Array = [];


		private var outputType: String = "Starling"; //Starling / JSON


		private static var exportFile: Boolean = false;

		public function DynamicTaCreator() {
			trace("YO YO YO")
		}


		public function init(_view: MovieClip): void {
			view = _view;
			// we are stopping all the mc's recursively in the loaded movie clip, because otherwise, some of the code could have run already (like cuePoint) and this would mess the anim tracks.
			stopAllMCs(view);

			//printLine("<?xml version='1.0' encoding='UTF-16'?>")
			//printLine("<assets>");
			viewHeirarchyObj = {};
			parse(view, viewHeirarchyObj);
			//traceJSON.stringify(viewHeirarchyObj));
			//printLine("</assets>");


			//imagesData.sortOn("area", Array.NUMERIC);
			//imagesData.reverse();
			createTA();
			createFontsFile();
			view = null;
		}





		private function createTA(): void {
			if (outputType == "Starling") {
				taPlacements = '<?xml version="1.0" encoding="utf-8"?>' + brk;
				taPlacements += '<TextureAtlas imagePath="ta.png">' + brk;
			} else {
				taPlacements = '{"frames":{';
			}


			displayImages();


			if (outputType == "Starling") {
				taPlacements += '</TextureAtlas>';
			} else {
				taPlacements += '},"meta":{"image": "ta.png","format": "RGBA8888","size": {"w":' + taMC.width + ',"h":' + taMC.height + '},"scale": "1"}}';
			}

			TAbitmapData = new BitmapData(taMC.width, taMC.height, true, 0x0);
			TAbitmapData.draw(taMC, new Matrix(1, 0, 0, 1, -taMC.x, -taMC.y));

			if (exportFile) {
				saveOutTA(TAbitmapData, "ta.png");

				if (outputType == "Starling") {
					saveXML(taPlacements, "ta.xml");
				} else {
					saveXML(taPlacements, "ta.json");
				}

				saveXML(JSON.stringify(viewHeirarchyObj), "placements.json");
			}

			//
			dispatchEvent(new Event("TA_CREATED"))
		}


		///addding rectangle packer!!!
		private function displayImages(): void {
			var chosenArrLen: int = imagesData.length;
			var padding: int = 10;

			if (mPacker == null) {
				//mPacker = new RectanglePacker(dimentionsW, dimentionsH, padding);
				mPacker = new CMaxRectBinPack(dimentionsW, dimentionsH);
			} else {
				//mPacker.reset(dimentionsW, dimentionsH, padding);
			}

			var bmp: Bitmap;
			var m_name: String;
			var i: int = 0;
			var j: int = 0;
			var font: Object;
			var index: int;
			var rect:Rectangle;


			mPacker.insertRects(imagesData, null, 1);
			//mPacker.packRectangles();




			for (index = 0; index < imagesData.length; index++) {
				var imgData: CTextureData = imagesData[index];
				bmp = new Bitmap(imgData.img);
				m_name = imgData.parentLikage;
				rect = imgData.m_textureRect

				if (m_textureDataArray.length > 0) {
					outer1: for (var fontId:String in m_fontsDataMap) {
						font = m_fontsDataMap[fontId];
						for (i = 0; i < font.m_textureDataArray.length; i++) {
							if (font.m_textureDataArray[i].m_extraData.linkage == m_name) {
								font.m_textureDataArray[i].m_textureRect = {
									x: rect.x,
									y: rect.y,
									width: rect.width,
									height: rect.height
								};
								break outer1;
							}
						}

					}
				}




				taMC.addChild(bmp);
				bmp.y = rect.y;
				bmp.x = rect.x;



				if (outputType == "Starling") {
					taPlacements += '<SubTexture name="' + m_name + '" x="' + bmp.x + '" y="' + bmp.y + '" width="' + bmp.width + '" height="' + bmp.height + '" pivotX="1" pivotY="1"/>' + brk;
				} else {
					var comma: String = ',';
					if (index  == chosenArrLen - 1) {
						comma = '';
					}

					taPlacements += '"' + m_name + '":{"frame":{"x":' + bmp.x + ',"y":' + bmp.y + ',"w":' + bmp.width + ',"h":' + bmp.height + '},' + brk;
					//taPlacements += '"rotated": false,' + brk;
					//taPlacements += '"trimmed": true,' + brk;
					//taPlacements += '"spriteSourceSize": {"x":0,"y":0,"w":' + bmp.width + ',"h":' + bmp.height + '}' + brk;
					taPlacements += '"sourceSize": {"w":' + bmp.width + ',"h":' + bmp.height + '}' + brk;
					taPlacements += '}' + comma + '' + brk;
				}

			}

		}



		protected function stopAllMCs(view: MovieClip): void {
			view.gotoAndStop(1);
			var child: MovieClip;
			var numOfChildren: int = view.numChildren
			for (var i: int = 0; i < numOfChildren; ++i) {
				child = view.getChildAt(i) as MovieClip;
				if (child) {
					stopAllMCs(child);
				}
			}
		}

		protected function getTextField(mc: MovieClip): TextField {
			var child: DisplayObject;
			var numChildren: int = mc.numChildren;
			for (var i: int = 0; i < numChildren; ++i) {
				child = mc.getChildAt(i);
				if (child is TextField) {
					return child as TextField;
				} else if (child is MovieClip) {
					return getTextField(child as MovieClip);
				}
			}
			return null;
		}

		protected function createFont(textItem: MovieClip, fontId: String): Object {
			var uniqueFontName: String;
			var tf: TextField = getTextField(textItem);
			if (tf) {
				var spaces: RegExp = / /gi; // match "spaces" in a string
				var format: TextFormat = tf.defaultTextFormat;

				textItem.m_color = format.color; //maybe comment this out


				textItem.m_align = format.align;

				// This is a unique font name based on the font, color and size, to make sure that we add each font to the texture only once.
				uniqueFontName = format.font + "_" + format.color.toString() + "_" + format.size.toString();
				uniqueFontName = uniqueFontName.replace(spaces, "");

				if (m_defaultFontsList.indexOf(uniqueFontName) == -1) {
					if (m_fontsDataMap[uniqueFontName] == null) {
						var textureData: Object;
						var embeddedChars: String = FontUtils.getEmbeddedChars(tf.text.replace(spaces, ""));

						// If we have the text item as UpperOnly, we would like to replace the lowercase characters with an empty string.
						//if (textItem is TextItemUpperOnly || textItem is FontItemUpperOnly)
						//{
						//	var nonUpperCasePattern : RegExp;
						//	
						//	// in case of noNumbers, also remove the numbers
						//	if (textItem is TextItemUpperOnlyNoNumbers || textItem is FontItemUpperOnlyNoNumbers)
						//	{
						//		nonUpperCasePattern = /[a-z0123456789]/g;
						//	}
						//	else
						//	{
						//		nonUpperCasePattern = /[a-z]/g;
						//		
						//	}
						//	embeddedChars = embeddedChars.replace(nonUpperCasePattern, "");
						//}


						var font: Object;

						// If the font hasn't been created yet, we will create it and add it to the map.
						if (m_uniqueFontsMap[uniqueFontName] == null) {
							font = FontUtils.createFont(textItem, tf, embeddedChars, fontId, uniqueFontName);
							m_uniqueFontsMap[uniqueFontName] = font;

							font.m_textureDataArray = [];
							font.m_charsAdvance = [];
							var char: String;
							var bmpObject: Object;
							// going over all the embedded characters and creating a textureData for them
							for (var i: int = 0; i < embeddedChars.length; ++i) {
								char = embeddedChars.charAt(i);
								if (char.charCodeAt(0) == 13) {
									continue;
								}

								tf.text = char;

								bmpObject = FontUtils.createTightBitmap(textItem, tf);

								if (bmpObject) {
									textureData = {};
									textureData.m_bd = bmpObject.bitmapData;
									textureData.m_extraData = bmpObject;
									//this is what goes in the fnt file 
									font.m_textureDataArray.push(textureData);
									m_textureDataArray.push(textureData);

									var xadvance: int = tf.getLineMetrics(0).width;
									font.m_charsAdvance.push(xadvance);

								}
							}
						}
						// This means that we already created this font, take the CFont object from the map, for re-use.
						else {
							font = m_uniqueFontsMap[uniqueFontName];
						}
					}

					m_fontsDataMap[uniqueFontName] = font;
				}
			}
			return font;

		}

		//need to get x, y, width and height of node in TA of font
		private function createFontsFile(): void {

			var fontsXML: XML = <font/> ;
			if (m_textureDataArray.length > 0) {
				//fontsXML.@source = "bob";
				for (var fontId: String in m_fontsDataMap) {
					var font: Object = m_fontsDataMap[fontId];
					FontUtils.getFontXMLNode(fontId, font, font.m_textureDataArray, "ta.png", fontsXML);

				}

				// saving the .fnt file.
				saveXML(fontsXML.toXMLString(), "font.xml");
			}
		}


		private function parse(mc: MovieClip, parentObj: Object): void //spacer:String
		{
			var obj: Object = {};
			var i: int = 0;
			for (i = 0; i < mc.numChildren; i++) {
				if (mc.getChildAt(i) is MovieClip) {
					var child: MovieClip = MovieClip(mc.getChildAt(i));
					var matrix: Matrix = child.transform.matrix;
					var CLSName: String = getQualifiedClassName(child);


					var templateItem: Boolean = false;
					var nodeName: String = child.name;

					if (CLSName != "flash.display::MovieClip") {
						//this means we are exporting this node
						nodeName = getQualifiedClassName(child);
						templateItem = true;
					}

					if (CLSName.indexOf("TextItem") != -1) {
						var fontCharsBDArray: Object = createFont(child, CLSName);
						var m_textureDataArray = fontCharsBDArray.m_textureDataArray;

						for (var j: int = 0; j < m_textureDataArray.length; j++) {
							var bd: BitmapData = m_textureDataArray[j].m_bd;
							var uniqueName: String = getQualifiedClassName(child) + j;
							m_textureDataArray[j].m_extraData.linkage = uniqueName;
							tryToPush(bd, uniqueName);
						}

						var tf: TextField = getTextField(child);

						obj = {};
						obj.type = "bmpTextField";
						obj.name = child.name;
						obj.template = templateItem;
						obj.x = int(child.x);
						obj.y = int(child.y);
						obj.rotation = int(child.rotation);
						obj.width = int(child.width);
						obj.height = int(child.height);
						obj.alpha = Number(child.alpha);
						obj.text = tf.text;
						obj.tfType = tf.type;
						obj.size = tf.defaultTextFormat.size;
						obj.align = tf.defaultTextFormat.align;
						obj.font = fontCharsBDArray.m_uniqueFontName; //tf.defaultTextFormat.font;
						obj.color = tf.defaultTextFormat.color;
						obj.z = i;

						addObj(parentObj, obj);


						continue;
					}



					if (nodeName.indexOf("BTN") != -1) //child.name.indexOf("BTN")
					{
						obj = {};
						obj.type = "btn";
						obj.name = nodeName;
						obj.template = templateItem;
						obj.instanceName = child.name;
						obj.x = int(child.x);
						obj.y = int(child.y);
						obj.rotation = int(child.rotation);
						obj.width = int(child.width);
						obj.height = int(child.height);
						obj.alpha = Number(child.alpha);

						obj.matrix = {
							a: matrix.a,
							b: matrix.b,
							c: matrix.c,
							d: matrix.d,
							tx: matrix.tx,
							ty: matrix.ty
						};

						addObj(parentObj, obj);
						parse(child, obj);
					} else {

						obj = {};
						obj.type = "asset";
						obj.name = nodeName;
						obj.template = templateItem;
						obj.instanceName = child.name;
						obj.x = int(child.x);
						obj.y = int(child.y);
						obj.scaleX = child.scaleX;
						obj.scaleY = child.scaleY;
						obj.rotation = int(child.rotation);
						obj.width = int(child.width);
						obj.height = int(child.height);
						obj.alpha = Number(child.alpha);
						obj.matrix = {
							a: matrix.a,
							b: matrix.b,
							c: matrix.c,
							d: matrix.d,
							tx: matrix.tx,
							ty: matrix.ty
						};

						if (mc.totalFrames > 1) {
							if (parentObj.frames == undefined) {
								//traceparentObj.name , parentObj.instanceName);
								parentObj.frames = getAnimTrack(mc);
							}

						}

						addObj(parentObj, obj);
						parse(child, obj);
					}
				} else if (mc.getChildAt(i) is TextField) {
					var tf: TextField = TextField(mc.getChildAt(i));

					obj = {};
					obj.type = "textField";
					obj.name = tf.name;
					obj.template = templateItem;
					obj.x = int(tf.x);
					obj.y = int(tf.y);
					obj.rotation = int(tf.rotation);
					obj.width = int(tf.width);
					obj.height = int(tf.height);
					obj.alpha = Number(tf.alpha);
					obj.text = tf.text;
					obj.tfType = tf.type;
					obj.size = tf.defaultTextFormat.size;
					obj.align = tf.defaultTextFormat.align;
					obj.font = tf.defaultTextFormat.font;
					obj.color = tf.defaultTextFormat.color;
					obj.z = i;

					addObj(parentObj, obj);
				} else {
					if (mc.getChildAt(i) is Shape) {
						var shp: Shape = Shape(mc.getChildAt(i));
						var bounds: Rectangle = shp.getBounds(shp);

						var parentTempName: String = getQualifiedClassName(mc);


						obj = {};
						obj.type = "img";
						obj.name = parentTempName + "_IMG";
						obj.x = bounds.x;
						obj.y = bounds.y;
						obj.width = int(shp.width);
						obj.height = int(shp.height);


						addObj(parentObj, obj);
						tryToPush(getImage(shp), getQualifiedClassName(mc));
					}

				}
			}
		}

		private function addObj(parentObj: Object, obj: Object): void {
			if (parentObj.children == undefined) {
				parentObj.children = [];
			}
			parentObj.children.push(obj);

		}

		private function playMCFrame(mc: MovieClip): void {
			mc.gotoAndStop(mc.currentFrame == mc.totalFrames ? 1 : mc.currentFrame + 1);

			if (mc.numChildren) {
				for (var i: int = 0; i < mc.numChildren; i++) {
					if (mc.getChildAt(i) is MovieClip) {
						playMCFrame(MovieClip(mc.getChildAt(i)));
					}
				}
			}
		}

		private function getAnimTrack(mc: MovieClip): Object {
			var layers: Object = {};
			var lastPlacements: Object = {};

			var child: MovieClip;
			for (var j: int = 1; j <= mc.totalFrames; j++) {
				mc.gotoAndStop(j);
				//playMCFrame(mc);

				for (var i: int = 0; i < mc.numChildren; i++) {
					if (mc.getChildAt(i) is MovieClip) {
						child = MovieClip(mc.getChildAt(i));

						if (child) {
							var currX: int = int(child.x);
							var currY: int = int(child.y);
							var rot: int = int(child.rotation);
							var sX: Number = child.scaleX;
							var sY: Number = child.scaleY;
							var a: Number = child.alpha;
							var matrix: Matrix = child.transform.matrix;
							var m:Object = {
								a: matrix.a,
								b: matrix.b,
								c: matrix.c,
								d: matrix.d,
								tx: matrix.tx,
								ty: matrix.ty
							};

							var firstTime: Boolean = false;
							var o: Object = {
								frame: true
							};

							if (layers[child.name] == undefined) {
								layers[child.name] = [];
							}



							if (lastPlacements[child.name] == undefined) {
								firstTime = true;
								lastPlacements[child.name] = {
									"x": currX,
									"y": currY,
									"rotation": rot,
									"scaleX": sX,
									"scaleY": sY,
									"alpha": a,
									"matrix": m,
									frame: true
								};
								layers[child.name].push({
									"x": currX,
									"y": currY,
									"rotation": rot,
									"scaleX": sX,
									"scaleY": sY,
									"alpha": a,
									"matrix": m,
									frame: true
								});

							} else {
								if (lastPlacements[child.name].x != currX) {
									o.x = currX;
									lastPlacements[child.name].x = currX;
								}
								if (lastPlacements[child.name].y != currY) {
									o.y = currY;
									lastPlacements[child.name].y = currY;
								}
								if (lastPlacements[child.name].rotation != rot) {
									o.rotation = rot;
									lastPlacements[child.name].rotation = rot;
								}
								if (lastPlacements[child.name].scaleX != sX) {
									o.scaleX = sX;
									lastPlacements[child.name].scaleX = sX;
								}
								if (lastPlacements[child.name].scaleY != sY) {
									o.scaleY = sY;
									lastPlacements[child.name].scaleY = sY;
								}
								if (lastPlacements[child.name].alpha != a) {
									o.alpha = a;
									lastPlacements[child.name].alpha = a;
								}

								o.matrix = m;


								layers[child.name].push(o);
							}
						}
					}
				}
			}

			//traceJSON.stringify(layers));
			return layers;
		}



		private function tryToPush(bd: BitmapData, _parentLikage: String): void {
			var exists: Boolean = false;

			//if this linkage exists, don't bother
			for (var i: int = 0; i < imagesData.length; i++) {
				if (_parentLikage == imagesData[i].parentLikage) {
					exists = true;
					trace("linkage exists " + _parentLikage);
					break;
				}
			}

			for (i = 0; i < imagesData.length; i++) {
				if (imagesData[i].img.compare(bd) == 0) {
					exists = true;
					break;
				}

			}

			if (exists == false) {
				imagesData.push(new CTextureData(bd, _parentLikage));

				/*{
					parentLikage: _parentLikage,
					img: bd,
					area: int(bd.width)
				}*/
			}

		}
		private function printLine(str: String): void {
			//placementsXML += str;
		}

		private function getOnlyText(text: String): String {
			return text.substr(0, text.lastIndexOf(" "));
		}

		private function getImage(d: DisplayObject): BitmapData {
			var oldMatrix: Matrix = d.parent.transform.matrix;
			d.parent.transform.matrix = new Matrix();
			var rect: Rectangle = d.getBounds(d.parent);
			var sourceBMD: BitmapData = new BitmapData(rect.width, rect.height, true, 0);
			var matrix: Matrix = new Matrix();
			matrix.translate(-rect.x, -rect.y);
			sourceBMD.draw(d, matrix);
			d.parent.transform.matrix = oldMatrix;
			return sourceBMD;
		}

		private function saveOutTA(_bd: BitmapData, fileName: String): void {
			// use adobe’s encoder to create a byteArray
			var byteArray: ByteArray = PNGEncoder.encode(_bd);
			var file: File = File.desktopDirectory.resolvePath(fileName);
			var wr: File = new File(file.nativePath);
			var stream: FileStream = new FileStream();
			stream.open(wr, FileMode.UPDATE);
			stream.writeBytes(byteArray, 0, byteArray.length);

		}

		private function saveXML(str: String, fileName: String): void {
			var wr: File = File.desktopDirectory.resolvePath(fileName);
			var stream: FileStream = new FileStream();
			stream.open(wr, FileMode.WRITE);
			stream.writeUTFBytes(str);
			stream.close();

		}
	}



}