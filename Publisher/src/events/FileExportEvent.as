package events
{
	import flash.events.Event;
	
	public class FileExportEvent extends Event
	{
		
		public static const FILE_EXPORT:String = "fileExport";
		
		public function FileExportEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}