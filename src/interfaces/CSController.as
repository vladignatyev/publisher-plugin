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
		function getCurrentAssetComposition():AssetComposition;
		function pushAssetState():void;
		function popAssetState():void;
		
		function getActiveDocument():*;
		
		function setupDefaultModel(model:AppModel):void;
		
		function set cleanAfterSave(value:Boolean):void;
	}
	
}