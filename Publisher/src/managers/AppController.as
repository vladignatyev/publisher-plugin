package managers
{
	import com.adobe.csawlib.CSHostObject;
	import com.adobe.csawlib.illustrator.IllustratorHostObject;
	import com.adobe.csxs.core.CSXSInterface;
	import com.adobe.csxs.events.CSXSEvent;
	import com.adobe.csxs.events.MenuClickEvent;
	import com.adobe.csxs.types.AppSkinInfo;
	import com.adobe.csxs.types.HostEnvironment;
	import com.adobe.csxs.types.SyncRequestResult;
	import com.adobe.illustrator.Application;
	
	import export.ExportOperation;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.HostObject;
	import flash.filesystem.File;
	import flash.net.FileReference;
	
	import managers.data.AssetComposition;
	import managers.data.PublishingItem;
	
	import mx.controls.DataGrid;
	import mx.events.CollectionEvent;
	
	/**
	 * 
	 * */
	public class AppController extends EventDispatcher
	{
		
		private static var instance:AppController;
		
		private var model:AppModel = AppModel.getInstance();

		public var appController:IllustratorController;
		

		[Bindable]
		public var hostEnv:HostEnvironment;
		
		[Bindable]
		public var skin:AppSkinInfo;
		
		private var lifeCycle:AppLifeCycle;
		
		public function AppController() {
			
			initCSXSLifecycle();
			
			
			
			switch(AppController.computeHostName()){
				case "illustrator":
				case "ILST":	
					appController = IllustratorController.getInstance()
					break;
			}			
			
			attach();
			
			var result:SyncRequestResult = CSXSInterface.getInstance().getHostEnvironment();
			if(SyncRequestResult.COMPLETE == result.status && result.data)
			{
				hostEnv = result.data as HostEnvironment;
				skin = hostEnv.appSkinInfo;
			}
			
		}
		
		private function initCSXSLifecycle():void {
			lifeCycle = AppLifeCycle.getInstance();
			lifeCycle.addEventListener("documentAfterActivate", documentActivated);
			lifeCycle.addEventListener("documentBeforeActivate", documentActivated);
			lifeCycle.addEventListener("documentAfterDeactivate", documentDeactivatedHandler);
		}
		
		
		private function documentDeactivatedHandler(event:CSXSEvent):void {
			dispatchEvent(event.clone());
		}		
		
		
		private static function computeHostName(): String
		{
			var comAdobeDot:String = "com.adobe.";
			// Seems like HostObject.available always returns true,
			// and mainExtension is empty
			// So unless mainExtension name is greater than bare minimum,
			// we are probably not in HBAPI host
			if(HostObject.available && 
				HostObject.mainExtension != null
				&& HostObject.mainExtension.length > comAdobeDot.length
			)
			{
				var qName:String = HostObject.mainExtension;
				
				if(qName.indexOf(comAdobeDot) == 0)
				{
					// We assume something like com.adobe.somehostnamehere.STUFFWECANIGNORE::Classname
					// as a case we want to watch out for
					var nextSeg:String = qName.substring(qName.indexOf(comAdobeDot) + comAdobeDot.length);
					var dotIndex:int = nextSeg.indexOf(".");
					var colonIndex:int = nextSeg.indexOf(":");
					var index:int = dotIndex > 0 ? dotIndex : colonIndex;
					if(index > 0)
					{
						var thostName:String = nextSeg.substring(0,index);
						return thostName;
					} 
					else
					{
						// We might have started with say com.adobe.illustrator
						return nextSeg;
					}
				}
				return "Unable to compute from HBAPI";
			}
			else
			{
				// Use CSXS interface
				var result:SyncRequestResult = CSXSInterface.getInstance().getHostEnvironment();
				if(SyncRequestResult.COMPLETE == result.status && result.data)
				{
					var host:HostEnvironment = result.data as HostEnvironment;
					if(host.appName != null)
					{
						return host.appName;
					}
				}
			}
			return "Unable to compute via fallback";
		}
		
		public static function getInstance():AppController 
		{
			if (instance == null)
			{
				instance = new AppController();
			}
			return instance;
		}
		
		public function deleteSelectedFile(selectedFileItem:*, selectedFileIndex:Number): void {
			if (selectedFileIndex > -1) model.deleteFileByIndex(selectedFileIndex);
		}
		
		public function detach():void 
		{
			appController.detach();
			model.clean();
		}
		
		public function export():ExportOperation 
		{
//			return appController.export();
			return null;
		}
		
		
		public function setAssetState(newState:AssetComposition):void {
			appController.setAssetState(newState);
		}
		
		public function fitViewportToAssetComposition(assetComposition:AssetComposition):void {
			appController.fitViewportToAssetComposition(assetComposition);
		}
		
		public function changeArtboardToComposition(assetComposition:AssetComposition):void {
			appController.changeArtboardToComposition(assetComposition);
		}


		public function attach():void
		{
			appController.attach();
			model.controller = appController;
		}
		
		public function popAssetState():void
		{
			appController.popAssetState();
		}
		
		public function pushAssetState():void
		{
			appController.pushAssetState();
		}
		
		
//		public function changeCompositionToLastCreated():void {
//			changeCompositionToIndex(model.dataProvider.length - 1);
//		}
				
//		public function changeCompositionToIndex(index:Number):void {
//			fitViewportToAssetComposition(model.getAssetCompositionByIndex(index));
//		}
		
		public function updateNthAssetWithCurrentComposition(i:Number):void {
			var item:PublishingItem = model.dataProvider.getItemAt(i) as PublishingItem;
			if (item) {
				item.assetComposition = model.getCurrentAssetComposition();
			}
		}
		
		public function documentActivated(event:CSXSEvent = null):void {
			dispatchEvent(event.clone());
			model.initialize();
		}
		
		public function appActivated():void {
		}
	
	}
}