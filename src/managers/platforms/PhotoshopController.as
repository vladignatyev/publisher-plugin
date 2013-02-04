package managers.platforms
{
	import com.adobe.csawlib.photoshop.Photoshop;
	import com.adobe.cshostadapter.PSEvent;
	import com.adobe.cshostadapter.PSEventAdapter;
	import com.adobe.csxs.types.Extension;
	import com.adobe.photoshop.*;
	
	import flash.filesystem.File;
	import flash.net.FileReference;
	import flash.utils.getQualifiedClassName;
	
	import interfaces.CSController;
	
	import managers.AppModel;
	import managers.AssetComposition;
	
	public class PhotoshopController implements CSController
	{
		public static var app:Application = Photoshop.app;
		private static var model:AppModel = AppModel.getInstance();
		private static var instance:PhotoshopController;

		public function set cleanAfterSave(value:Boolean):void {
//			_cleanAfterSave = value;
		}
		
		public function getActiveDocument():* {
			return app.activeDocument;
		}
		
		public function setupDefaultModel(model:AppModel):void {
		}
		
		public static function getInstance():CSController {
			if ( instance == null )
			{
				instance = new PhotoshopController;
			}
			return instance;			
		}
		//This example does not make use of any Photoshop-specific events,
		//so attach and detach are empty. I've left them here for future use.
		public function detach():void 
		{
		}
		public function attach():void
		{
		}
		
		public function handlePSEvent(event:PSEvent):void 
		{
			handleEvent();
		}
		
		public function handleEvent():void 
		{
		}

		public function refreshModel():void {
			model.pathToPublish = PhotoshopController.app.activeDocument.path.nativePath;
		}
		
		public function export():void{
			//In Photoshop, the type of the saveOptions paramter of the saveAs method
			//determines the saved file type. Each format has a different set of options.
			var saveOptions:Object;
//			switch(model.formatName){
//				case "JPEG":
//					saveOptions = new JPEGSaveOptions();
//					//Set JPEG save options here.
//					saveOptions.quality = 12;
//					saveOptions.formatOptions = FormatOptions.PROGRESSIVE;
//					saveOptions.scans = 2;
//					break;
//				case "TIFF":
//					saveOptions = new TiffSaveOptions();
//					//Set TIFF save options here.
//					saveOptions.layers = true;
//					saveOptions.alphaChannels = true;
//					saveOptions.imageCompression = TIFFEncoding.TIFFZIP;
//					saveOptions.transparency = true;
//					break;
//				case "PDF":
//					saveOptions = new PDFSaveOptions();
//					//Set PDF save options here.
//					saveOptions.view = false;
//					//If you need to export to a particular PDF standard, you can use the
//					//saveOptions.PDFStandard property, as shown in the line below.
//					//saveOptions.PDFStandard = PDFStandard.PDFX42008;
//					break;
//			}
//			app.activeDocument.saveAs(file as File, saveOptions, true);
		}
		
		public function popAssetState():void
		{
			// TODO Auto Generated method stub
			throw new Error("Not implemented");
		}
		
		public function pushAssetState():void
		{
			// TODO Auto Generated method stub
			throw new Error("Not implemented");
		}
		
		
		
		public function setAssetState(assetComposition:AssetComposition):void
		{
			// TODO Auto Generated method stub
			throw new Error("Not implemented");
		}
		
		public function getCurrentAssetComposition():AssetComposition
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function fitViewportToAssetComposition(assetComposition:AssetComposition):void {
			throw new Error("Not implemented");
		}
		
	}
}