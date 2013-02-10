package export
{
	import com.adobe.illustrator.ExportOptionsGIF;
	import com.adobe.illustrator.ExportOptionsJPEG;
	import com.adobe.illustrator.ExportOptionsPNG24;
	import com.adobe.illustrator.ExportType;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.setTimeout;
	
	import managers.IllustratorController;
	import managers.data.PublishingItem;
	
	public class ExportOperation extends EventDispatcher
	{
		private var items:Array;
		private var controller:IllustratorController;
		private var interrupted:Boolean;
		private var pathToPublish:String;
		private var totalItems:uint;

		public function ExportOperation(controller:IllustratorController, items:Array)
		{
			super();
			this.items = items;
			this.controller = controller;
		}
		
		private function exportOne():void {
			function complete():void {
				controller.popAssetState();
				dispatchEvent(new Event(Event.COMPLETE));
			}
			
			if (interrupted) {
				complete();
				return;
			}
			
			const item:PublishingItem = items.pop() as PublishingItem;
			var format:ExportType;
			var exportOptions:*;
			
			switch(item.fileType){
				case PublishingItem.JPG:
					format = ExportType.JPEG;
					exportOptions = new ExportOptionsJPEG();
					exportOptions.artBoardClipping = true;
					exportOptions.antiAliasing = true;
					break;
				
				case PublishingItem.GIF:
					format = ExportType.GIF;
					exportOptions = new ExportOptionsGIF();
					exportOptions.colorCount = 256;
					exportOptions.antiAliasing = false;
					exportOptions.artBoardClipping = true;
					exportOptions.transparency = true;
					break;
				
				case PublishingItem.PNG24:
				default:
					format = ExportType.PNG24;
					exportOptions = new ExportOptionsPNG24();
					exportOptions.antiAliasing = true;
					exportOptions.transparency = true; //todo: get transparency from PublishingItem
					exportOptions.artBoardClipping = true;
					break;
			}
			
			controller.setAssetState(item.assetComposition);
			
			//				app.activeDocument.selectObjectsOnActiveArtboard();
			//				var sel:* = app.activeDocument.selection;
			//				app.activeDocument.rasterize(sel, sel.visibleBounds);
			
			const file:File =  new File([pathToPublish, item.systemFilename].join('/'));
			controller.activeDocument.exportFile(file, format, exportOptions);
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, totalItems - items.length, totalItems));
			
			if (items.length > 0) {
				setTimeout(exportOne, 50);
			} else {
				complete();	
			}
		}
		
		public function publish(pathToPublish:String):void {
			if (!items.length) throw new IllegalOperationError("Items to export list is empty. Please don't reuse ExportOperation object!");

			this.pathToPublish = pathToPublish;
			this.totalItems = items.length;
			controller.pushAssetState();
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, 0, items.length));
			exportOne();
		}
		
		public function stop():void {
			interrupted = true;
		}
		
	}
}