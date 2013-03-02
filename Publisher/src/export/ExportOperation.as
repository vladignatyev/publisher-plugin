package export
{
	import com.adobe.illustrator.ExportOptionsGIF;
	import com.adobe.illustrator.ExportOptionsJPEG;
	import com.adobe.illustrator.ExportOptionsPNG24;
	import com.adobe.illustrator.ExportType;
	import com.adobe.illustrator.RGBColor;
	
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
				setTimeout(function():void {dispatchEvent(new Event(Event.COMPLETE));}, 2000);
			}
			
			if (interrupted) {
				complete();
				return;
			}
			
			const item:PublishingItem = items.pop() as PublishingItem;
			controller.setAssetState(item.assetComposition);
			
			const filePath:String = [item.pathToPublish.replace(/\/$/g, ''), item.systemFilename].join('/');
			const file:File =  new File(filePath);
			controller.activeDocument.exportFile(file, item.exportType, item.exportOptions);
			
			if (item.exportAs2X) {
				const file2x:File =  new File([item.pathToPublish, item.systemFilename2x].join('/'));
				const exportOptions:* = item.exportOptions;
				exportOptions.verticalScale = 200.0;
				exportOptions.horizontalScale = 200.0;
				controller.activeDocument.exportFile(file2x, item.exportType, exportOptions);
			}
			
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, totalItems - items.length, totalItems));
			
			if (items.length > 0) {
				setTimeout(exportOne, 100);
			} else {
				setTimeout(complete, 100);
			}
		}
		
		public function publish():void {
			
			if (!items.length) throw new IllegalOperationError("Items to export list is empty. Please don't reuse ExportOperation object!");
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, 0, items.length));
			this.totalItems = items.length;
			controller.pushAssetState();
			setTimeout(exportOne, 100);
		}
		
		public function stop():void {
			interrupted = true;
		}
		
	}
}