package managers
{
	import com.adobe.csawlib.CSHostObject;
	import com.adobe.csawlib.illustrator.IllustratorHostObject;
	import com.adobe.csxs.core.CSXSInterface;
	import com.adobe.csxs.types.AppSkinInfo;
	import com.adobe.csxs.types.HostEnvironment;
	import com.adobe.csxs.types.SyncRequestResult;
	import com.adobe.illustrator.Application;
	import com.adobe.photoshop.Application;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileReference;
	
	import interfaces.CSController;
	import interfaces.IAssetCompositionInflator;
	import interfaces.IMetadataProvider;
	
	import managers.platforms.IllustratorController;
	import managers.platforms.PhotoshopController;
	
	import mx.controls.DataGrid;
	import mx.events.CollectionEvent;
	
	/**
	 * 
	 * */
	public class AppController implements CSController
	{
		
		private static var instance:AppController;
		
		private var model:AppModel = AppModel.getInstance();

		private var appController:CSController;
		
		public function set cleanAfterSave(value:Boolean):void {
			appController.cleanAfterSave = value;
		}
		
		[Bindable]
		public var hostEnv:HostEnvironment;
		
		[Bindable]
		public var skin:AppSkinInfo;
		
		public function AppController() {
			switch(model.hostName){
				case "illustrator":
				case "ILST":	
					appController = IllustratorController.getInstance()
					break;
				case "photoshop":
					appController = PhotoshopController.getInstance();
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
		
		public static function getInstance():AppController 
		{
			if (instance == null)
			{
				instance = new AppController();
			}
			return instance;
		}
		
		public function newFile (): void {
			model.addNewDefaultFile(getCurrentAssetComposition());
		}
		
		public function deleteSelectedFile(selectedFileItem:*, selectedFileIndex:Number): void {
			if (selectedFileIndex > -1) model.deleteFileByIndex(selectedFileIndex);
		}
		
		public function detach():void 
		{
			appController.detach();
			model.activeDocument = null;
			model.clean();
		}
		
		public function export():void 
		{
			appController.export();
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
			model.activeDocument = getActiveDocument();
			model.metadataProvider = appController as IMetadataProvider;
			model.controller = appController;
			model.assetCompositionInflator = appController as IAssetCompositionInflator;
		}
		
		public function popAssetState():void
		{
			appController.popAssetState();
		}
		
		public function pushAssetState():void
		{
			appController.pushAssetState();
		}
		
		public function getCurrentAssetComposition():AssetComposition
		{
			return appController.getCurrentAssetComposition();
		}
		
		public function changeCompositionToLastCreated():void {
			changeCompositionToIndex(model.dataGridProvider.length - 1);
		}
		
		public function getAssetCompositionByIndex(index:Number):AssetComposition {
			return (model.dataGridProvider.getItemAt(index) as PublishingItem).assetComposition;
		}
		
		public function changeCompositionToIndex(index:Number):void {
			fitViewportToAssetComposition(getAssetCompositionByIndex(index));
		}
		
		public function updateNthAssetWithCurrentComposition(i:Number):void {
			var item:PublishingItem = model.dataGridProvider.getItemAt(i) as PublishingItem;
			if (item) {
				item.assetComposition = getCurrentAssetComposition();
			}
		}
		
		public function getActiveDocument():* {
			return appController.getActiveDocument();
		}
		
		public function documentActivated():void {
			if (!getActiveDocument()) return;			
			model.activeDocument = getActiveDocument();
			model.initialize();
		}
		
		public var fileListDG:DataGrid;
		
		public function documentDeactivated():void {
			appController.cleanAfterSave = true;
		}
		
		public function appActivated():void {
		}
	
		public function setupDefaultModel(model:AppModel):void {
			appController.setupDefaultModel(model);
		}
	}
}