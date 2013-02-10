package interfaces
{
	import managers.AppModel;
	import managers.AssetComposition;

	public interface CSController
	{
		
		function attach():void;
		function detach():void;

		function export():void;
		
		function changeArtboardToComposition(assetComposition:AssetComposition):void;
		
		function fitViewportToAssetComposition(assetComposition:AssetComposition):void;
		function setAssetState(assetComposition:AssetComposition):void;
		function pushAssetState():void;
		function popAssetState():void;
		
		function getActiveDocument():*;

	}
	
}