/* Automatically generated class - DO NOT MODIFY */

package ru.magicink.publisher.ns
{
	public class PublisherNamespaceXMPContextStatus
	{
		public static var CLEARED:String = "CLEARED";
		public static var INVALID:String = "INVALID";
		public static var MISSING_DECRYPTION_KEY:String = "MISSING_DECRYPTION_KEY";
		public static var ARRAY_INDEX_OUT_OF_BOUNDS:String = "ARRAY_INDEX_OUT_OF_BOUNDS";
		
		private static var opstatus:String = CLEARED;
		
		public function PublisherNamespaceXMPContextStatus()
		{
		}
		
		public static function get status():String{
			var result:String = opstatus;
			opstatus = CLEARED;
			return result;
		}
		
		internal static function set _status(status:String):void{
			opstatus = status;
		}
	}
}