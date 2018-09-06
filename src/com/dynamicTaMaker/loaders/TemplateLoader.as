package com.dynamicTaMaker.loaders
{
	import com.dynamicTaMaker.atlases.MyTA;
	
	import com.dynamicTaMaker.views.GameButton;
	import com.dynamicTaMaker.views.GameSprite;
	import com.dynamicTaMaker.views.GameTextField;
	import com.dynamicTaMaker.views.TimelineSprite;
	import com.dynamicTaMaker.views.GameBitmapTextField;
	
	import flash.text.TextFormat;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import flash.geom.Matrix;
	
	
	

	public class TemplateLoader
	{
		private static var ta:TextureAtlas;
		//private static var placementsXML:XML;
		//private static var placementsObj:Object;
		//private static var templates:Object = new Object();
		private static var valsToSetArr:Array = [];
		private static var scenes:Array = [];
		
		public function TemplateLoader()
		{
			
		}
		
		public static function init(_ta:TextureAtlas, _placementFiles:Array):void
		{
			valsToSetArr = [];
			ta = _ta;

			for (var i:int = 0; i < _placementFiles.length; i++) {
				var _placementsObj:Object = _placementFiles[i];
				var templates:Object = getAllAssets(_placementsObj, {});
				scenes.push({
					placementsObj: _placementsObj,
					templates: templates
				});
			}
			
			//templates = getAllAssets(placementsObj, templates);
			//traceJSON.stringify(templates))
			//trace"bob");
		}
		
		
		
		public static function get(tempName:String):GameSprite
		{
			for (var i = 0; i < scenes.length; i++) {
            	var scene:Object = scenes[i];
				var baseNode:Object = scene.templates[tempName];
				var mc:GameSprite;
				if(baseNode.frames)
				{
					mc = new TimelineSprite();
					mc.frames = fixRotation(baseNode.frames);
				}
				else
				{
					mc = new GameSprite();
				}
				
				mc.name = baseNode.instanceName;

				createAsset(mc, baseNode);
				
				valsToSetArr.reverse();
				for(var i:int = 0; i < valsToSetArr.length; i++)
				{
					var val:Object = valsToSetArr[i];
					val.mc.width = val.w;
					val.mc.height = val.h;
				}
				valsToSetArr.splice(0);		
				
				return mc;
			}

			return null;
		}

		private static function getAllAssets(o:Object, allAssets:Object):Object
		{
			for(var k:String in o)
			{
				if(k == "type" && o[k] == "asset")
				{
					allAssets[o["name"]] = o;
				}
				
				if(o[k] is Object)
				{
					getAllAssets(o[k], allAssets);
				}
				
				
			}
			return allAssets;
		}
		
		
		private static function degreesToRadians(degrees:int):Number
		{
			// TODO Auto Generated method stub
			return degrees * Math.PI / 180
		}
		
		
		
		private static function createAsset(mc:GameSprite, baseNode:Object):void
		{
			for(var i:int = 0; i < baseNode.children.length; i++)
			{
				var child:Object = baseNode.children[i];
				
				var _name:String = child.name;
				var _x:int = child.x;
				var _y:int = child.y;
				var _w:int = child.width;
				var _h:int = child.height;
				var _a:Number = 0;
				var type:String = child.type;
				var asset:GameSprite;
				var matrix:Object = child.matrix;
				var tfType:String;

				if (type == "bmpTextField") {
                tfType = child.tfType;
                var bmptf:GameBitmapTextField = new GameBitmapTextField(child.text + "", {
                    font: child.size + "px " + child.font,
                    align: 'center'
               		 }, _w, _h);

					bmptf.name = _name;
					bmptf.x = _x;
					bmptf.y = _y;
					mc[_name] = bmptf;
					mc.addChild(bmptf);
            	}
				if(type == "textField")
				{
					tfType = child.tfType;
					var tf:GameTextField = new GameTextField(_w,_h,child.text + "",child.font,child.size,child.color);
					
					tf.name = _name;
					tf.x = _x;
					tf.y = _y;
					mc[_name] = tf;
					mc.addChild(tf);
				}
				if(type == "img")
				{
					var texName:String = _name;
					////tracetexName);
					texName = texName.substr(0,texName.indexOf("_"));
					////tracetexName);
					var tex:Texture = MyTA.ta.getTexture(texName);
					if(tex == null)
					{
						return;
					}
					var img:Image = new Image(tex);
					img.x = _x;
					img.y = _y;
					img.width = _w;
					img.height = _h;
					//img.touchable = false;
					mc[texName] = img;
					mc.addChild(img);
				}
				if(type == "btn")
				{
					asset = new GameButton();
					asset.name = child.instanceName;

					_x = child.x;
					_y = child.y;
					_w = int(child.width);
					_h = int(child.height);
					_a = Number(child.alpha);
					
					asset.x = _x;
					asset.y = _y;
					//btn.width = _w;
					//btn.height = _h;
					//asset.rotation = degreesToRadians(child.rotation);
					asset.alpha = _a;
					mc[asset.name] = asset;
					mc.addChild(asset);
					asset.transformationMatrix = new Matrix(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
					valsToSetArr.push({mc : asset, w :_w, h : _h });
					
					
				}
				if(type == "asset")
				{
					
					if(child.frames)
					{
						asset = new TimelineSprite();
						asset.frames = fixRotation(child.frames);
					}
					else
					{
						asset = new GameSprite();
					}
					
					
					asset.name = child.instanceName;
					
					_x = child.x;
					_y = child.y;
					_w = int(child.width);
					_h = int(child.height);
					_a = Number(child.alpha);
					
					asset.x = _x;
					asset.y = _y;
					//asset.width = _w;
					//asset.height = _h;
					//asset.rotation = degreesToRadians(child.rotation);
					asset.alpha = _a;
					mc[asset.name] = asset;
					mc.addChild(asset);

					asset.transformationMatrix = new Matrix(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
					
					valsToSetArr.push({mc : asset, w :_w, h : _h });
					
					
				}
				
				if(child.children)
				{
					if(asset)
					{
						createAsset(asset, child);
					}
					else
					{
						createAsset(mc, child);
					}
				}
			}
		}
		
		private static function fixRotation(_frames:Object):Object
		{
			for(var k:String in _frames)
			{
				for(var i:int = 0; i < _frames[k].length; i++)
				{
					if(_frames[k][i])
					{
						var rotation:int = _frames[k][i].rotation;
						_frames[k][i].rotation = degreesToRadians(rotation);
					}
				}
			}
			
			return _frames;
		}
	}
}