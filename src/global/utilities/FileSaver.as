package global.utilities
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	
	public class FileSaver
	{
		private var newFileStream:FileStream = new FileStream();
		private var outputDir:File = File.desktopDirectory;
		private var outputFile:File;
		
		static private var instance:FileSaver = new FileSaver();
		
		public function FileSaver()
		{
			if (instance)
			{
				throw new Error("Singleton and can only be accessed through Singleton.getInstance()");
			}
		}
		
		public static function getInstance():FileSaver
		{
			return instance;
		}
		
		public function save(fileName:String, fileConts:String):void
		{
			outputFile = outputDir.resolvePath(fileName);
			newFileStream.openAsync (outputFile, FileMode.WRITE);
			newFileStream.writeUTFBytes(fileConts);
			newFileStream.close ();
			
		}
	}
}