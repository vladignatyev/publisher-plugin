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
			var myCSXS:CSXSInterface = CSXSInterface.getInstance();
			myCSXS.addEventListener("documentAfterActivate", redispatch);
			myCSXS.addEventListener("documentBeforeDeactivate", redispatch);
			myCSXS.addEventListener("documentAfterDeactivate", redispatch);
			myCSXS.addEventListener("applicationActivate", redispatch);
		}
		
		private function redispatch(event:CSXSEvent):void {
			dispatchEvent(event.clone());
		}
	}
}