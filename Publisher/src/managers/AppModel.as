package managers
{
	import com.adobe.csawlib.illustrator.Illustrator;
	import com.adobe.csxs.core.CSXSInterface;
	import com.adobe.illustrator.Artboard;
	import com.adobe.illustrator.Artboards;
	import com.adobe.illustrator.Document;
	import com.adobe.illustrator.RGBColor;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.HostObject;
	
	import managers.data.AssetComposition;
	import managers.data.PublishingItem;
	
	import mx.collections.ArrayCollection;
	import mx.events.PropertyChangeEvent;

	public class AppModel extends EventDispatcher
	{
		public static const STATE_DISABLED:String = "disabled";
		public static const STATE_WELCOME:String = "welcome";
		public static const STATE_NORMAL:String = "normal";
		
			
		
		public static const FORMAT_VERSION:String = "v1.0";
		
		private static var instance:AppModel;
		
		private var _activeDocument: Document;
		private var _controller:IllustratorController;
		
		public function AppModel() {
			dataGridProvider = new ArrayCollection();
			state = STATE_DISABLED;
		}

		public function set controller(value:IllustratorController):void {
			_controller = value;
		}

		public function get activeDocument():Document
		{
			return _controller.activeDocument;
		}

		public static function getInstance():AppModel 
		{
			if ( instance == null ) {
				instance = new AppModel();
			}
			return instance;
		}
		
		public var defaultPathToPublish:String;
		
		[Bindable(event="dataGridProviderChanged")]
		public var dataGridProvider:ArrayCollection;

		[Bindable]
		public var state:String;
		
		public function initialize():void {
			clean();
			
			if (!activeDocument) {
				state = STATE_DISABLED;
			} else if (!restoreFromMeta()){
				state = STATE_WELCOME;
			} else {
				state = STATE_NORMAL;
			}
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
			var artboards:Artboards = activeDocument.artboards as Artboards;
			
			for (var i:int = 0; i < artboards.length; i++) {
				var artboard:Artboard = artboards.index(i);
				var currentComposition:AssetComposition = getCurrentAssetComposition();
				currentComposition.setArtboard(i);
				addNewDefaultFile(currentComposition);
			}
			
			state = STATE_NORMAL;
			
			try {
				if (!defaultPathToPublish || defaultPathToPublish == '')
				{					
					defaultPathToPublish = activeDocument.fullName.parent.nativePath;
				}
			} catch (e:Error) {
				trace(e);
			}
			
			updateDataGridBinding();
		}
		
		public function restoreFromMeta():Boolean {
			var xmpView: AppModelXMPView = AppModelXMPView.fromXMPSerializedView(_controller.getMetadata());
			if (xmpView) {
				this.fromXMPView(xmpView);
				return true;
			} 
			return false;
		}
		
		
		public function addNewFile(name:String, assetComposition:AssetComposition):void {
			const item:PublishingItem = new PublishingItem();
			item.activeDocument = activeDocument;
			item.assetComposition = assetComposition;
			dataGridProvider.addItem(item);
			save();
			updateDataGridBinding();
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
		
		public function clean():void {
			dataGridProvider = new ArrayCollection();
			defaultPathToPublish = '';
		}
		
		private function getFlattened():* {
			var length:int = dataGridProvider.length;
			
			var result:* = {
				"formatVersion": FORMAT_VERSION,
				"publishingItems": new Array(length)
			};
			
			for (var i:Number = 0; i < length; i++) {
				var item: PublishingItem = dataGridProvider.getItemAt(i) as PublishingItem;
				result.publishingItems[i] = item.toPlainObject();
				result.publishingItems[i]["assetComposition"] = _controller.flattenAssetComposition(item.assetComposition);
			}
			
			return result;
		}
		
		public function toXMPView():AppModelXMPView {
			return new AppModelXMPView(getFlattened());			
		}
		
		private function restoreModel(o:*):void {
			for (var i:Number = 0; i < o.publishingItems.length; i++) {
				const po:* = o.publishingItems[i];
				
				var item:PublishingItem = new PublishingItem();
				item.activeDocument = activeDocument;
				item.assetComposition = _controller.restoreAssetComposition(po.assetComposition);
				item.fromPlainObject(po);
				
				dataGridProvider.addItem(item);
			}
		}
		
		public function fromXMPView(xmpModelView:AppModelXMPView):void {
			var o:* = xmpModelView.dataObject;
			
			clean();
			
			if (o.formatVersion == FORMAT_VERSION) {
				restoreModel(o);			
			} else { //todo: remove after alpha-testing (may be)
				var pathToPublish:String = o.pathToPublish;
				
				for (var i:Number = 0; i < o.publishingItems.length; i++) {
					var filename:String = o.publishingItems[i]["filename"];
					if (!filename) {
						filename = i.toString();
					}
					var type:String = o.publishingItems[i]["fileType"];
					
					var transparency:* = o.publishingItems[i]["transparency"];
					
					if (!type) type = PublishingItem.PNG24;
					if (transparency === undefined) transparency = true;
					
					var item:PublishingItem = new PublishingItem();
					item.activeDocument = activeDocument;
					item.assetComposition = _controller.restoreAssetComposition(o.publishingItems[i].assetComposition);
					
					if (type == PublishingItem.PNG24) {
						item.png24Transparency = transparency;
					}
					item.pathToPublish = pathToPublish;
					
					item.isPublished = o.isPublished;
					item.type = type;
					item.name = filename;

					dataGridProvider.addItem(item);
				}				
			}
			
			updateDataGridBinding();
		}
		
		private function updateDataGridBinding():void {
			dispatchEvent(new Event("dataGridProviderChanged"));
		}
		
		
		public function save():void {
			if (!_controller) return;
			activeDocument.saved = false;
			_controller.saveMetadata(toXMPView().string);
		}
	}
}