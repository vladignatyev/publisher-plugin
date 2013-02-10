package managers
{
	import com.adobe.csxs.core.CSXSInterface;
	import com.adobe.csxs.events.*;
	import com.adobe.csxs.types.*;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class AppLifeCycle extends EventDispatcher
	{
		private static var instance:AppLifeCycle;

		public static function getInstance() : AppLifeCycle 
		{
			if (!instance) {
				instance = new AppLifeCycle();
				instance.start();
			}
			return instance;
		}
		
		public function start():void
		{
			//Add CSXS "standardized" events.
			var myCSXS:CSXSInterface = CSXSInterface.getInstance();
			myCSXS.addEventListener("documentAfterActivate", redispatch/*documentAfterActivate_handler*/);
			myCSXS.addEventListener("documentBeforeDeactivate", redispatch);
			myCSXS.addEventListener("documentAfterDeactivate", redispatch/*documentAfterDeactivate_handler*/);
			myCSXS.addEventListener("applicationActivate", redispatch/*applicationActivate_handler*/);
			
		}
		
		private function redispatch(event:CSXSEvent):void {
			dispatchEvent(event.clone());
		}
		/*
		private function documentAfterActivate_handler(event:CSXSEvent):void {
			trace('documentAfterActivate_handler');
			controller.documentActivated();
		}
		
		private function documentAfterDeactivate_handler(event:CSXSEvent):void {
			trace('documentAfterDeactivate_handler');
			model.activeDocument = null;
			model.state = 'disabled';
//			model.clean();
		}
		
		private function applicationActivate_handler(event:CSXSEvent):void {
			trace('aplpicationActivate_handler');
			controller.appActivated();
		}
		
		*/
	}
}