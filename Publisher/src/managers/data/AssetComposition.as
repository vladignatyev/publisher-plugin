package managers.data
{
	import com.adobe.illustrator.Artboard;
	
	import flash.utils.Dictionary;

	public class AssetComposition
	{
		private var _artboardIndex:Number = -1;		//Photoshop has no artboards
		public var layerIndexes: Dictionary = new Dictionary();	// array of visible layers
		
		public function setArtboard(artboardIndex:Number = -1):void {
			_artboardIndex = artboardIndex;
		}
		
		public function get artboardIndex():Number
		{
			return _artboardIndex;
		}
	}
}