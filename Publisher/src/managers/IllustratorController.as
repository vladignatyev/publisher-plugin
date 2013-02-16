package managers
{
	import com.adobe.csawlib.illustrator.Illustrator;
	import com.adobe.cshostadapter.*;
	import com.adobe.illustrator.*;
	import com.dofaster.publisher.ns.PublisherNamespaceXMPContext;
	
	import export.ExportOperation;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.net.FileReference;
	import flash.utils.getQualifiedClassName;
	
	import managers.data.AssetComposition;
	import managers.data.PublishingItem;
	
	import mx.collections.ArrayCollection;
	
	import utils.ArtboardUtils;
	
	public class IllustratorController extends EventDispatcher
	{
		private static var model:AppModel = AppModel.getInstance();
		private static var instance:IllustratorController;
		private static var adapter:AIEventAdapter;
		private var _app:Application;
				
		public function IllustratorController() {
		}
		
		
		public static function getInstance():IllustratorController {
			if ( instance == null )
			{
				instance = new IllustratorController();
				instance.app = Illustrator.app;
				
			}
						
			return instance;			
		}

		public function attach():void{
			adapter = AIEventAdapter.getInstance();

//			adapter.addEventListener(AIEvent.LAYER_LIST_CHANGED, documentChangedHandler);
//			adapter.addEventListener(AIEvent.DOCUMENT_CROP_AREA_MODIFIED, documentChangedHandler);
		}
				
		
		public function detach():void 
		{
			try{
				adapter = null;
//				adapter.removeEventListener(AIEvent.LAYER_LIST_CHANGED, documentChangedHandler);
//				adapter.removeEventListener(AIEvent.DOCUMENT_CROP_AREA_MODIFIED, documentChangedHandler);
			}
			catch(error:Error){}
		}
		
		public function export(items:Array):ExportOperation {
			const itemsToPublish:Array = [];
			
			for (var i:int=0; i < model.dataGridProvider.length; i++) {
				const item:PublishingItem = model.dataGridProvider.getItemAt(i) as PublishingItem;
				if (item.isPublished) {
					itemsToPublish.push(item);
				}
			}
			
			return new ExportOperation(this, itemsToPublish);
		}
		
		
		
		public function get activeDocument():Document {
			return app.activeDocument;
		}
		
		//todo вынести вверх по иерархии
		private var userAssetStateStack:Vector.<AssetComposition> = new Vector.<AssetComposition>();
		
		//todo вынести вверх по иерархии
		public function popAssetState():void
		{
			if (userAssetStateStack.length > 0) {
				setAssetState(userAssetStateStack.pop());
			}
		}
		
		//todo вынести вверх по иерархии
		public function pushAssetState():void
		{
			userAssetStateStack.push(model.getCurrentAssetComposition());
		}
		
//		protected function hideAllLayers():void {
//			var layersCount:Number = app.activeDocument.layers.length;
//			for (var i:int =0; i < layersCount; i++) {	//скрыли все
//				app.activeDocument.layers.index(i).visible = false; 
//			}
//		}
		
		public function setAssetState(assetComposition:AssetComposition):void
		{
			app.activeDocument.artboards.setActiveArtboardIndex(assetComposition.artboardIndex);	//выбрали артборд
			
//			hideAllLayers();

			var layersCount:Number = app.activeDocument.layers.length;
			
			for (var j:int = 0; j < layersCount; j++) {
				var layer:* = app.activeDocument.layers.index(j);
				if (assetComposition.layerIndexes[layer.hostObjectDelegate] is int) {
					app.activeDocument.layers.index(j).visible = true;
				} else {
					app.activeDocument.layers.index(j).visible = false;
				}
				
			}
		}
		
		public function changeArtboardToComposition(assetComposition:AssetComposition):void {
			app.activeDocument.artboards.setActiveArtboardIndex(assetComposition.artboardIndex);
		}
		
		public function fitViewportToAssetComposition(assetComposition:AssetComposition):void {
			setAssetState(assetComposition);
					
			var artBoardRect:Array = app.activeDocument.artboards.index(assetComposition.artboardIndex).artboardRect;
			
			
			var center:Array = app.activeDocument.convertCoordinate([(artBoardRect[2]-artBoardRect[0])/2,
				(artBoardRect[3]-artBoardRect[1])/2], 
				CoordinateSystem.ARTBOARDCOORDINATESYSTEM, CoordinateSystem.DOCUMENTCOORDINATESYSTEM);
			app.activeDocument.activeView.centerPoint = [center[0], center[1]];
			app.activeDocument.activeView.zoom = 1.0;
		}
		
		/***
		 * 
		 *              XMP Metadata saving and retrieving
		 * 
		 * 
		 * */
		public var xmpContext: PublisherNamespaceXMPContext;

		public function get app():Application
		{
			return _app;
		}

		public function set app(value:Application):void
		{
			_app = value;
		}
		
		/**
		 * Необходимо вызывать этот метод каждый раз после сохранения метаданных и при загрузке нового документа
		 * */
		public function updateXMPCapabilities(activeDocument:*):void {
			if (!activeDocument) return;
			xmpContext = new PublisherNamespaceXMPContext((activeDocument as Document).XMPString);
		}
		
		public function saveMetadata(modelMetaData:String):void {
			xmpContext.publisherNamespace.assetsMetadata = modelMetaData;
			app.activeDocument.XMPString = xmpContext.serializeToXML();
			app.activeDocument.saved = false;
		}
		
		public function getMetadata():String {
			return xmpContext.publisherNamespace.assetsMetadata;
		}
		
		public function getExportPath():String {
			return xmpContext.publisherNamespace.exportPath;
		}
				
		public function restoreAssetComposition (flattenedComposition:*):AssetComposition {
			var assetComposition:AssetComposition = new AssetComposition();
			assetComposition.setArtboard(flattenedComposition.artboardIndex);
			for (var i:Number = 0; i < flattenedComposition.layerIndexes.length; i++) {
				var layer:Layer = model.activeDocument.layers.index(flattenedComposition.layerIndexes[i].index);
				if (!layer) {
					return null;
				}
				assetComposition.layerIndexes[layer.hostObjectDelegate] = flattenedComposition.layerIndexes[i].index;
			}
			return assetComposition;
		}
		
		public function flattenAssetComposition(assetComposition:AssetComposition):* {
			var indexesLength:int = 0;
			for (var k:* in assetComposition.layerIndexes) {
				indexesLength++;
			}
			var result:* = {
				"artboardIndex":assetComposition.artboardIndex,
					layerIndexes:new Array(indexesLength)
			};
			
			var i:Number = 0;
			for (var keyObjectDelegate:* in assetComposition.layerIndexes) {
				var actualLayerIndex:Number = assetComposition.layerIndexes[keyObjectDelegate];
				result.layerIndexes[i] = {
					"index":actualLayerIndex, 
					"layerName":(model.activeDocument as Document).layers.index(actualLayerIndex).name
				}; 
				i++;
			}
			
			return result;
		}
	}
}
