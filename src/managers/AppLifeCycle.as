package managers
{
	import com.adobe.csxs.core.CSXSInterface;
	import com.adobe.csxs.events.*;
	import com.adobe.csxs.types.*;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import managers.AppController;
	import managers.AppModel;
	public class AppLifeCycle
	{
		private static var instance:AppLifeCycle;
		private static var controller:AppController = AppController.getInstance();
		private static var model:AppModel = AppModel.getInstance();
		public static function getInstance() : AppLifeCycle 
		{
			if ( instance == null )
			{
				instance = new AppLifeCycle();
				instance.start();
			}
			return instance;
		}
		
		public function start():void
		{
			//Add CSXS "standardized" events.
			var myCSXS:CSXSInterface = CSXSInterface.getInstance();
			myCSXS.addEventListener("documentAfterActivate", documentAfterActivate_handler);
			
			myCSXS.addEventListener("documentBeforeDeactivate", documentBeforeDeactivate_handler);
			myCSXS.addEventListener("documentAfterDeactivate", documentAfterDeactivate_handler);
			myCSXS.addEventListener("applicationActivate", applicationActivate_handler);
			//Add CSXS events.
//			myCSXS.addEventListener(StateChangeEvent.WINDOW_OPEN, eventHandler);
//			myCSXS.addEventListener(StateChangeEvent.WINDOW_SHOW, eventHandler);
		}
		
		private function documentAfterActivate_handler(event:CSXSEvent):void {
			trace('documentAfterActivate_handler');
			controller.documentActivated();
		}
		
		private function documentBeforeDeactivate_handler(event:CSXSEvent):void {
			trace('documentBeforeDeactivate_handler');
			controller.documentDeactivated();
		}
		
		private function documentAfterDeactivate_handler(event:CSXSEvent):void {
			trace('documentAfterDeactivate_handler');
			model.activeDocument = null;
			model.clean();
		}
		
		private function applicationActivate_handler(event:CSXSEvent):void {
			trace('documentAfterDeactivate_handler');
			controller.appActivated();
		}
		
		
	}
}