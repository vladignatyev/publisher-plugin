package managers
{
	import com.adobe.illustrator.Artboard;
	import com.adobe.illustrator.Document;
	import com.adobe.illustrator.ExportType;
	import com.adobe.indesign.Book;
	
	import utils.ArtboardUtils;

	/**
	 * Единица публикации :)
	 * */
	[Bindable]
	public class PublishingItem
	{
		public static const PNG24:String = "png24";
		public static const JPG:String = "jpg";
		
		public var filename:String = "";
		public var fileType:String = PublishingItem.PNG24;
		
		public var transparency:Boolean = true;
		
		public var isPublished:Boolean = true;	
		
		public var assetComposition:AssetComposition;
		
		public var icon:String = "";
		
		private var _activeDocument:Document;
		
		public function PublishingItem (
			filename:String,
			fileType:String,
			transparency:Boolean,
			activeDocument: *,
			icon:String = "",
			isPublished:Boolean = true,
			layerComposition:AssetComposition = null
		) {
			this._activeDocument = activeDocument as Document;
			this.filename = filename;
			this.icon = icon;
			this.assetComposition = layerComposition;
			this.fileType = fileType;
			this.transparency = transparency;
			
		}
		
		public function get systemFilename():String {
			var extension:String = fileType == PublishingItem.JPG?'jpg':'png';
			return this.filename + '.' + extension;
		}
		
		public function get artboardName():String {
			return ArtboardUtils.getCleanName(_activeDocument.artboards.index(assetComposition.artboardIndex));
		}
		
		public function get dimensionsString():String {
			if (assetComposition && _activeDocument.artboards.index(assetComposition.artboardIndex)) {
				var dimensions:* = ArtboardUtils.getDimension(_activeDocument.artboards.index(assetComposition.artboardIndex));
				return [Math.round(dimensions.artboardWidth), "×", Math.round(dimensions.artboardHeight)].join('');
			} 
			return "";
		}
	}
}