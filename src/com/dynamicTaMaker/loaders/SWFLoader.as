package com.dynamicTaMaker.loaders
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	public class SWFLoader extends EventDispatcher
	{
		private var loader : Loader = new Loader();
		private var loadedSwf:MovieClip;
		
		public function SWFLoader()
		{
		}
		
		public function loadSWF(animSWF : String) : void
		{
			// this is a hack to get around the security domain restrictions
			// first we load the swf as a byte array from the remote locations
			// and then in swfLoaded() we will use that byte array to load the swf into the application domain
			var urlLoader : URLLoader = new URLLoader();
			var urlRequest : URLRequest = new URLRequest(animSWF);
			
			urlLoader.addEventListener(Event.COMPLETE, swfLoaded);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, failedHandler);
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.load(urlRequest);
		}
		
		protected function swfLoaded(e : Event) : void
		{
			//trace"DynamicTaCreator.swfLoaded");
			var urlLoader : URLLoader = URLLoader(e.target);
			
			// add an Application context and allow bytecode execution 
			var context : LoaderContext = new LoaderContext();
			context.allowLoadBytesCodeExecution = true;
			context.applicationDomain = ApplicationDomain.currentDomain;
			
			
			loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, completeHandler);
			loader.contentLoaderInfo.addEventListener(flash.events.IOErrorEvent.IO_ERROR, failedHandler);
			loader.loadBytes(urlLoader.data, context);
		}
		
		protected function failedHandler(event : flash.events.IOErrorEvent) : void
		{
			//trace"error " + event.errorID);
		}
		
		protected function completeHandler(e : flash.events.Event) : void
		{
			//trace"swf loaded");
			// get the root movie clip of the fla
			loadedSwf = e.target.content as MovieClip;
			loader.unload();
			
			
			
		}
	}
}