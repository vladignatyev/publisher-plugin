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
		public var filename:String = "";
		public var isPublished:Boolean = true;	
		
//		public var fileType:ExportType = ExportType.PNG24; //RESERVED FIELD
		
		
		public var assetComposition:AssetComposition;
		
		public var icon:String = "";
		
		private var _activeDocument:Document;
		
		public function PublishingItem (
			filename:String,
activeDocument: *,
			icon:String = "",
			isPublished:Boolean = true,
			layerComposition:AssetComposition = null
		) {
			this._activeDocument = activeDocument as Document;
			this.filename = filename;
			this.icon = icon;
			this.assetComposition = layerComposition;
		}
		
		public function get artboardName():String {
			return ArtboardUtils.getCleanName(_activeDocument.artboards.index(assetComposition.artboardIndex));
		}
		
		public function get dimensionsString():String {
			if (assetComposition && _activeDocument.artboards.index(assetComposition.artboardIndex)) {
				var dimensions:* = ArtboardUtils.getDimension(_activeDocument.artboards.index(assetComposition.artboardIndex));
				return [Math.round(dimensions.artboardWidth), "×", Math.round(dimensions.artboardHeight), "px"].join('');
			} 
			return "";
		}
	}
}