package interfaces
{
	public interface IMetadataProvider
	{
		function getMetadata():String;
		
		function updateXMPCapabilities(activeDocument:*):void;		
		function saveMetadata(modelMetaData:String):void;
	}
}