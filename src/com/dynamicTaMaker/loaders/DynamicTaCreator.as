package com.dynamicTaMaker.loaders
{
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
	
	import com.dynamicTaMaker.utils.PNGEncoder;

	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class DynamicTaCreator extends EventDispatcher
	{
		private var rejectsArr:Array = [];
		
		private var brk:String = '\n';
		private var lastY:int = 0;
		private var lastX:int = 0;
		private var widestInRow:int = 0;
		private var count:int = 0;
		private var dimentionsW:int = 1024;
		private var dimentionsH:int = 1024;
		
		private var view:MovieClip;
		private var imagesData:Array = [];
		private var chosenArr:Array;
		private var taMC:MovieClip = new MovieClip();
		
		public var taPlacements:String;
		public var TAbitmapData:BitmapData;
		//public var placementsXML:String = "";
		public var viewHeirarchyObj:Object;
		
		
		private static var exportFile:Boolean = false;
		
		public function DynamicTaCreator() 
		{
			
		}

		
		public function init(_view:MovieClip):void
		{
			view = _view;
			// we are stopping all the mc's recursively in the loaded movie clip, because otherwise, some of the code could have run already (like cuePoint) and this would mess the anim tracks.
			stopAllMCs(view);
			
			//printLine("<?xml version='1.0' encoding='UTF-16'?>")
			//printLine("<assets>");
			viewHeirarchyObj = {};
			parse(view, viewHeirarchyObj);
			//traceJSON.stringify(viewHeirarchyObj));
			//printLine("</assets>");
			
			chosenArr = imagesData;
			
			chosenArr.sortOn("area",Array.NUMERIC);
			chosenArr.reverse();
			createTA();
			view = null;
		}
		
		
		
		private function createTA():void 
		{
			taPlacements = '<?xml version="1.0" encoding="utf-8"?>' + brk;
			taPlacements += '<TextureAtlas imagePath="ta.png">'+ brk;
			
			displayImages();
			
            TAbitmapData = new BitmapData(taMC.width, taMC.height, true, 0x0);
            TAbitmapData.draw(taMC, new Matrix(1, 0, 0, 1, -taMC.x, -taMC.y));
			
			if(exportFile)
			{
				saveOutTA(TAbitmapData, "ta.png");
				saveXML(taPlacements, "ta.xml");
				saveXML(JSON.stringify(viewHeirarchyObj), "placements.json");
			}
			
			//
			dispatchEvent(new Event("TA_CREATED"))
		}
		
			
		
		private function displayImages():void 
		{
			for (var i:int = 0; i < chosenArr.length; i++ )
			{
				var bmp:Bitmap = new Bitmap(chosenArr[i].img);
				var m_name:String = chosenArr[i].parentLikage;
				taMC.addChild(bmp);
				bmp.y = lastY;
				bmp.x = lastX;
				
				if (bmp.width > widestInRow)
				{
					widestInRow = bmp.width ;
				}
				
				if (bmp.y + bmp.height > dimentionsH)
				{
					lastY = 0;
					lastX += widestInRow;
					widestInRow = 0;
				}
				else
				{
					lastY += bmp.height;
				}
				taPlacements += '<SubTexture name="' +m_name + '" x="' + bmp.x + '" y="' + bmp.y + '" width="' + bmp.width + '" height="' + bmp.height + '" pivotX="1" pivotY="1"/>'+ brk;
			}

			taPlacements += '</TextureAtlas>';

		}
		
	
		
		protected function stopAllMCs(view : MovieClip) : void
		{
			view.gotoAndStop(1);
			var child : MovieClip;
			for (var i : int = 0; i < view.numChildren; ++i)
			{
				child = view.getChildAt(i) as MovieClip;
				if (child)
				{
					stopAllMCs(child);
				}
			}
		}
		
		private function parse(mc:MovieClip, parentObj:Object):void //spacer:String
		{
			var obj:Object = {};
			for (var i:int = 0; i < mc.numChildren; i++ )
			{
				if (mc.getChildAt(i) is MovieClip)
				{
					var child:MovieClip = MovieClip(mc.getChildAt(i));
					var templateItem:Boolean = false;
					var nodeName:String = child.name;
					
					if (getQualifiedClassName(child) != "flash.display::MovieClip")
					{
						nodeName = getQualifiedClassName(child);
						templateItem = true;
					}
					
					if(child.name.indexOf("BTN") != -1 )
					{
						obj = {};
						obj.type = "btn";
						obj.name = nodeName;
						obj.template = templateItem;
						obj.instanceName = child.name;
						obj.x = int(child.x);
						obj.y=  int(child.y);
						obj.rotation= int(child.rotation);
						obj.width=int(child.width);
						obj.height=int(child.height);
						obj.alpha=Number(child.alpha);
						
						addObj(parentObj, obj);
						

						//printLine(spacer +"<btn name ='" + nodeName + "' template='" + templateItem + "' instanceName='"+child.name+"' x='"+int(child.x)+"' y='"+int(child.y)+"' rotation='"+int(child.rotation)+"' width='"+int(child.width)+"' height='"+int(child.height)+"' alpha='"+Number(child.alpha)+"' >");
						parse(child, obj);//spacer + " "
						//printLine(spacer +"</btn>");
					}
					else
					{
						
							obj = {};
							obj.type = "asset";
							obj.name = nodeName;
							obj.template = templateItem;
							obj.instanceName = child.name;
							obj.x = int(child.x);
							obj.y=  int(child.y);
							obj.rotation= int(child.rotation);
							obj.width=int(child.width);
							obj.height=int(child.height);
							obj.alpha=Number(child.alpha);
							
							if(mc.totalFrames> 1)
							{
								if(parentObj.frames == undefined)
								{
									//traceparentObj.name , parentObj.instanceName);
									parentObj.frames = getAnimTrack(mc);
								}
								
							}
							
							addObj(parentObj, obj);
							//printLine(spacer +"  <asset name='" + nodeName + "' template='" + templateItem + "' instanceName='"+child.name+"' x='"+int(child.x)+"' y='"+int(child.y)+"' rotation='"+int(child.rotation)+"' width='"+int(child.width)+"' height='"+int(child.height)+"'  alpha='"+Number(child.alpha)+"'  >");
							//spacer + " "
							//printLine(spacer +"  </asset>");
						
						
						parse(child, obj);
							
					}
					
					
				}
				else if(mc.getChildAt(i) is TextField)
				{
					var tf:TextField = TextField(mc.getChildAt(i));
					
					obj = {};
					obj.type = "textField";
					obj.name = tf.name;
					obj.template = templateItem;
					obj.x = int(tf.x);
					obj.y=  int(tf.y);
					obj.rotation= int(tf.rotation);
					obj.width=int(tf.width);
					obj.height=int(tf.height);
					obj.alpha=Number(tf.alpha);
					obj.text = tf.text;
					obj.tfType = tf.type;
					obj.size = tf.defaultTextFormat.size;
					obj.align = tf.defaultTextFormat.align;
					obj.font = tf.defaultTextFormat.font;
					obj.color = tf.defaultTextFormat.color;
					obj.z = i;
					
					addObj(parentObj, obj);
					
					
					//printLine(spacer +"<textField name='" + tf.name + "'>");
					//printLine(spacer +"   <x>"+int(tf.x)+"</x>")
					//printLine(spacer +"   <y>" + int(tf.y) + "</y>")
					//printLine(spacer +"   <text>" + tf.text + "</text>")
					//printLine(spacer +"   <type>" +tf.type + "</type>")
					//printLine(spacer +"   <width>"+int(tf.width)+"</width>")
					//printLine(spacer +"   <height>"+int(tf.height)+"</height>")
					//printLine(spacer +"   <size>"+tf.defaultTextFormat.size+"</size>")
					//printLine(spacer +"   <align>"+tf.defaultTextFormat.align+"</align>")
					//printLine(spacer +"   <font>"+tf.defaultTextFormat.font+"</font>")
					//printLine(spacer +"   <color>"+tf.defaultTextFormat.color+"</color>")
					//printLine(spacer +"   <rotation>"+int(tf.rotation)+"</rotation>")
					//printLine(spacer +"   <z>"+i+"</z>")
					//printLine(spacer +"</textField>");
				}
				else 
				{
					if (mc.getChildAt(i) is Shape)
					{
						var shp:Shape = Shape(mc.getChildAt(i));
						var bounds:Rectangle = shp.getBounds(shp);
						
						var parentTempName:String = getQualifiedClassName(mc);
						
						
						obj = {};
						obj.type = "img";
						obj.name = parentTempName + "_IMG";
						obj.x = bounds.x;
						obj.y = bounds.y;
						obj.width=int(shp.width);
						obj.height=int(shp.height);
						
						addObj(parentObj, obj);
						
						
						//printLine(spacer +"<img name='" + parentTempName + "_IMG'>");
						//printLine(spacer +"   <x>"+bounds.x+"</x>")
						//printLine(spacer +"   <y>" + bounds.y + "</y>")
						//printLine(spacer +"   <width>"+int(shp.width)+"</width>")
						//printLine(spacer +"   <height>" + int(shp.height) + "</height>")
						//printLine(spacer +"</img>");
						tryToPush(getImage(shp), mc);
					}
					
				}
			}
		}
		
		private function addObj(parentObj:Object, obj:Object):void
		{
			if(parentObj.children == undefined)
			{
				parentObj.children = [];
			}
			parentObj.children.push(obj);
			
		}	
		
		private function playMCFrame( mc:MovieClip):void
		{
			mc.gotoAndStop(mc.currentFrame==mc.totalFrames ? 1 : mc.currentFrame+1);
			
			if(mc.numChildren)
			{
				for(var i:int = 0 ; i <mc.numChildren; i++ )
				{
					if(mc.getChildAt(i) is MovieClip)
					{
						playMCFrame( MovieClip(mc.getChildAt(i)));
					}
				}
			}
		}
		
		private function getAnimTrack(mc:MovieClip):Object
		{
			var layers:Object = {};
			var child:MovieClip;
			for(var j:int = 1; j <= mc.totalFrames; j++)
			{
				mc.gotoAndStop(j);
				//playMCFrame(mc);
				
				for(var i:int = 0; i < mc.numChildren; i++)
				{
					if(mc.getChildAt(i) is MovieClip)
					{
						child = MovieClip(mc.getChildAt(i));
						
						if(child)
						{
							if(layers[child.name] == undefined)
							{
								layers[child.name]=[];
							}
							
							var o:Object =  {};
							o.x = int(child.x);
							o.y=  int(child.y);
							o.rotation= int(child.rotation);
							//o.width=int(child.width);
							//o.height=int(child.height);
							o.scaleX = child.scaleX;
							o.scaleY = child.scaleY;
							o.alpha=Number(child.alpha);
							
							//tracemc.name, mc.height);
							
							layers[child.name].push(o);
						}
					}
				}
			}
			
			//traceJSON.stringify(layers));
			return layers;
		}
		
		
		
		private function tryToPush(bd:BitmapData, parentMC:MovieClip):void 
		{
			var exists:Boolean = false;
			var _parentLikage:String = getQualifiedClassName(parentMC);
			
			
	
			
			//if this linkage exists, don't bother
			for (var i:int = 0; i < imagesData.length; i++ )
			{
				if (_parentLikage == imagesData[i].parentLikage)
				{
					exists = true;
					break;
				}
			}
			
			for (i = 0; i < imagesData.length; i++ )
			{
				if (imagesData[i].img.compare(bd) == 0)
				{
					//trace"exists!");
					rejectsArr.push({parentLikage: _parentLikage, img: bd , area: int(bd.width )});
					exists = true;
					break;
				}
				
			}
			
			if (exists == false)
			{
				imagesData.push({parentLikage: _parentLikage, img: bd , area: int(bd.width )});
			}
			
		}
		private function printLine(str:String):void
		{
			//placementsXML += str;
		}
		
		private function getOnlyText(text:String):String 
		{
			return text.substr(0, text.lastIndexOf(" "));
		}
		
		private function getImage(d:DisplayObject):BitmapData
		{
			var oldMatrix:Matrix = d.parent.transform.matrix;
			d.parent.transform.matrix = new Matrix();
			var rect:Rectangle = d.getBounds(d.parent);
			var sourceBMD:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
			var matrix:Matrix = new Matrix();
			matrix.translate(-rect.x, -rect.y);
			sourceBMD.draw(d, matrix);
			d.parent.transform.matrix = oldMatrix;
			return sourceBMD;
		}
		
		private function saveOutTA(_bd:BitmapData, fileName:String):void
		{
			// use adobe’s encoder to create a byteArray
			var byteArray:ByteArray = PNGEncoder.encode(_bd);
			var file:File = File.desktopDirectory.resolvePath(fileName);
			var wr:File = new File(file.nativePath);
			var stream:FileStream = new FileStream();
			stream.open( wr , FileMode.UPDATE);
			stream.writeBytes( byteArray, 0, byteArray.length );

		}
		
		private function saveXML(str:String, fileName:String):void
		{
			var wr:File = File.desktopDirectory.resolvePath(fileName);
			var stream:FileStream = new FileStream();
			stream.open( wr , FileMode.WRITE);
			stream.writeUTFBytes(str);
			stream.close();
			
		}	

	}

}