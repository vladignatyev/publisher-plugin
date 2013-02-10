package managers
{
	import com.adobe.csawlib.illustrator.Illustrator;
	import com.adobe.csxs.core.CSXSInterface;
	import com.adobe.csxs.types.*;
	import com.adobe.illustrator.Artboard;
	import com.adobe.illustrator.Artboards;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.HostObject;
	
	import mx.collections.ArrayCollection;
	import managers.data.PublishingItem;
	import managers.data.AssetComposition;

	[Bindable]
	public class AppModel extends EventDispatcher
	{
		private static var instance:AppModel;
		
		private var _activeDocument:*;	//todo: ебучий пиздец! нужно ряд интерфейсов сделать, чтобы отгородить от имплементации платформы, динамическую тпизацию выпилить и забыть в страшном сне
		private var _controller:IllustratorController;
		
		public function AppModel() {
		}

		public function set controller(value:IllustratorController):void {
			_controller = value;
		}

		public function get activeDocument():*
		{
			return _activeDocument;
		}

		public function set activeDocument(value:*):void
		{
			_activeDocument = value;
		}

		public static function getInstance():AppModel 
		{
			if ( instance == null ) {
				instance = new AppModel();
			}
			return instance;
		}
		
		public var hostName:String = "";
		private var _pathToPublish:String;
		
		public function set pathToPublish(value:String):void {
			if (value == _pathToPublish) return;
			_pathToPublish = value;
			if (activeDocument) {
				save();
			}
		}
		
		public function get pathToPublish():String {
			return _pathToPublish;
		}
		
		public var dataGridProvider:ArrayCollection = new ArrayCollection();

		public var formatNames:ArrayCollection = new ArrayCollection(
			[{label:"JPEG", ext:"jpg"}, 
			 {label:"GIF", ext:"gif"}, 
			 {label:"PNG24", ext:"png"}
			]);
		
		private var _formatName:String = "";
		
		public var state:String = "disabled";
		
		public function initialize():void {
			if (!activeDocument) {
				state = "disabled";
				return;
			} else if (!restoreFromMeta()){
				defaultInit();
			} else {
				state = "normal";
			}
			
			if (!pathToPublish || pathToPublish == '')
			{
				
				pathToPublish = activeDocument.fullName.parent.nativePath;
			}
		}
		
		public function defaultInit():void {
			//настраиваем модель поумолчанию
			clean();
			state = "welcome";
		}
		
		public function setupDefaultModel():void {
			var artboards:Artboards = activeDocument.artboards as Artboards;
			
			for (var i:int = 0; i < artboards.length; i++) {
				var artboard:Artboard = artboards.index(i);
				var currentComposition:AssetComposition = getCurrentAssetComposition();
				currentComposition.setArtboard(i);
				addNewDefaultFile(currentComposition);
			}
			
			pathToPublish = '';
			
		}
		
		public function getCurrentAssetComposition():AssetComposition
		{
			var newAssetComposition:AssetComposition = new AssetComposition();
			var artboardIndex:Number = activeDocument.artboards.getActiveArtboardIndex();
			newAssetComposition.setArtboard(artboardIndex);
			
			var layersCount:Number = activeDocument.layers.length;
			for (var i:int =0; i < layersCount; i++) {
				var layer:* = activeDocument.layers.index(i); 
				if (layer.visible) {
					newAssetComposition.layerIndexes[layer.hostObjectDelegate] = i;
				}
			}
			return newAssetComposition;
		}

		
		public function setupDefault():void {
			lockSavingOnUpdates();
			setupDefaultModel();
			unlockSavingOnUpdates();
			state = "normal";
			
			try {
			if (!pathToPublish || pathToPublish == '')
			{
				pathToPublish = activeDocument.fullName.parent.nativePath;
			}
			} catch (e:Error) {
				trace(e);
			}
		}
		
		public function restoreFromMeta():Boolean {
			_controller.updateXMPCapabilities(activeDocument);
			var xmpView: AppModelXMPView = AppModelXMPView.fromXMPSerializedView(_controller.getMetadata());
			if (xmpView) {
				this.fromXMPView(xmpView);
				return true;
			} 
			return false;
		}
		
		///// GETTERS & SETTERS
		public function get formatName():String
		{
			return _formatName;
		}
		
		public function set formatName(value:String):void
		{
			_formatName = value;
			dispatchEvent(new Event("formatNameUpdated"));
		}

		
		public function addNewFile(name:String, assetComposition:AssetComposition):void {
			dataGridProvider.addItem(new PublishingItem(name, PublishingItem.PNG24, true, _activeDocument, "", true, assetComposition));
			save();
		}
		
		private function getFilename(customName:String = ""):String {
			var name:String = customName;
			if (name == "") {
				var n:String = "1";
				if (dataGridProvider) {
					n = (dataGridProvider.length + 1).toString();
				}
				name = n;
			}
//			return [name, getExtension()].join('.');
			return name;
		}
		
		public function addNewDefaultFile(assetComposition:AssetComposition):void {
 			addNewFile(getFilename(), assetComposition);
		}
		
		public function deleteFileByIndex(index:Number):void {
			if (dataGridProvider.length > 0) {
				dataGridProvider.removeItemAt(index);
				save();
			}
		}
		
		private function lockSavingOnUpdates():void {
			_lockedSavingOnUpdates = true;
		}
		
		private var _lockedSavingOnUpdates:Boolean  = false;
		
		private function unlockSavingOnUpdates():void {
			_lockedSavingOnUpdates = false;
		}
		
		public function clean():void {
			lockSavingOnUpdates();
			dataGridProvider.disableAutoUpdate();
			dataGridProvider.removeAll();
			_pathToPublish = '';
			if (!activeDocument) {
				state = 'disabled';
			}
			dataGridProvider.enableAutoUpdate();
			unlockSavingOnUpdates();
		}
		
		private function getExtension():String {
			// Ищем среди массива форматов файлов и узнаем расширение
			var formatNamesFiltered:ArrayCollection = new ArrayCollection (formatNames.toArray());
			formatNamesFiltered.filterFunction = function(item:Object):Boolean {
				return item.label == formatName;
			}
			formatNamesFiltered.refresh();
			return formatNamesFiltered.getItemAt(0).ext;
		}
		
		private function getFlattened():* {
			var length:int = dataGridProvider.length;
			
			var result:* = {
				"formatName":formatName,
				"pathToPublish":pathToPublish,
				"publishingItems": new Array(length)
			};
			
			for (var i:Number = 0; i < length; i++) {
				var item: PublishingItem = dataGridProvider.getItemAt(i) as PublishingItem;
				result.publishingItems[i] = {
					"isPublished":item.isPublished,
					"filename": item.filename,
					"fileType": item.fileType,
					"transparency": item.transparency,
					"icon": item.icon,
					"artboardName":item.artboardName,
					"assetComposition":_controller.flattenAssetComposition(item.assetComposition)
				};
			}
			
			return result;
		}
		
		public function toXMPView():AppModelXMPView {
			return new AppModelXMPView(getFlattened());			
		}
		
		public function gridChanged():void {
			if (!_lockedSavingOnUpdates) save();
		}
		
		public function fromXMPView(xmpModelView:AppModelXMPView):void {
			clean();
			var dO:* = xmpModelView.dataObject;
			this.formatName = dO.formatName;
			this.pathToPublish = dO.pathToPublish;
			
			lockSavingOnUpdates();
			dataGridProvider.disableAutoUpdate();
			for (var i:Number=0; i < dO.publishingItems.length; i++) {
				
				const filename:String = dO.publishingItems[i]["filename"];
				var fileType:String = dO.publishingItems[i]["fileType"];
				
				var transparency:* = dO.publishingItems[i]["transparency"];
				
				if (!fileType) fileType = PublishingItem.PNG24;
				if (transparency === undefined) transparency = true;
				
				dataGridProvider.addItem(new PublishingItem(filename, fileType, transparency, activeDocument, 
					dO.publishingItems[i].icon, dO.isPublished, _controller.restoreAssetComposition(dO.publishingItems[i].assetComposition)));
			}
			dataGridProvider.enableAutoUpdate();
			unlockSavingOnUpdates();
		}
		
		
		public function save():void {
			if (!_controller) return;
			activeDocument.saved = false;
			_controller.updateXMPCapabilities(activeDocument);
			_controller.saveMetadata(toXMPView().string);
		}
	}
}