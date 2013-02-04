package managers
{
	import com.adobe.csawlib.illustrator.Illustrator;
	import com.adobe.csxs.core.CSXSInterface;
	import com.adobe.csxs.types.*;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.HostObject;
	
	import interfaces.CSController;
	import interfaces.IAssetCompositionInflator;
	import interfaces.IMetadataProvider;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class AppModel extends EventDispatcher
	{
		private static var instance:AppModel;
		
		private var _activeDocument:*;	//todo: ебучий пиздец! нужно ряд интерфейсов сделать, чтобы отгородить от имплементации платформы, динамическую тпизацию выпилить и забыть в страшном сне
		private var _metadataProvider:IMetadataProvider;
		private var _inflator:IAssetCompositionInflator;
		private var _controller:CSController;
		
		public function AppModel() {
		}

		public function set controller(value:CSController):void {
			_controller = value;
		}
		
		public function get metadataProvider():IMetadataProvider
		{
			return _metadataProvider;
		}

		public function set metadataProvider(value:IMetadataProvider):void
		{
			_metadataProvider = value;
		}

		public function get activeDocument():*
		{
			return _activeDocument;
		}

		public function set activeDocument(value:*):void
		{
			_activeDocument = value;
		}

		public function set assetCompositionInflator(value:IAssetCompositionInflator):void
		{
			_inflator = value;
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
			if (activeDocument) activeDocument.saved = false;
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
			} else {
				state = "normal";
			}
			if (!restoreFromMeta()){
				defaultInit();
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
		
		public function setupDefault():void {
			lockSavingOnUpdates();
			_controller.setupDefaultModel(this);
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
			metadataProvider.updateXMPCapabilities(activeDocument);
			var xmpView: AppModelXMPView = AppModelXMPView.fromXMPSerializedView(metadataProvider.getMetadata());
			if (xmpView) {
				this.fromXMPView(xmpView);
				return true;
			} 
			return false;
		}
		
		//Called from the extension's onCreationComplete() function.
		public function readyState(): void
		{
			this.hostName = computeHostName();
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
			dataGridProvider.addItem(new PublishingItem(name, _activeDocument, "", true, assetComposition));
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
			return [name, getExtension()].join('.');
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
			pathToPublish = '';
			dataGridProvider.enableAutoUpdate();
			unlockSavingOnUpdates();
			if (!activeDocument) {
				state = 'disabled';
			}
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
			
			trace("pathToPublish:" + pathToPublish);
			
			for (var i:Number = 0; i < length; i++) {
				var item: PublishingItem = dataGridProvider.getItemAt(i) as PublishingItem;
				result.publishingItems[i] = {
					"isPublished":item.isPublished,
					"filename": item.filename,
					"icon": item.icon,
					"artboardName":item.artboardName,
					"assetComposition":_inflator.flattenAssetComposition(item.assetComposition)
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
				dataGridProvider.addItem(new PublishingItem(dO.publishingItems[i].filename, activeDocument, 
					dO.publishingItems[i].icon, dO.isPublished, _inflator.restoreAssetComposition(dO.publishingItems[i].assetComposition)));
			}
			dataGridProvider.enableAutoUpdate();
			unlockSavingOnUpdates();
		}
		
		
		public function save():void {
			if (!metadataProvider) return;
			metadataProvider.updateXMPCapabilities(activeDocument);
			metadataProvider.saveMetadata(toXMPView().string);
		}
	}
}