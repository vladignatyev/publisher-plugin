package managers
{
	import serialization.json.JSON;

	/**
	 * Класс-контейнер для хранения конвертированной модели
	 * Хуй знает зачем он нужен. Просто болит зад и голова.
	 * 
	 * */
	public class AppModelXMPView
	{
		private var _dataObject:*;
		
		public function AppModelXMPView(dataObject: * = null)
		{
			_dataObject = dataObject;
		}
		
		public function get string():String 
		{
			if (_dataObject) 
			{
				return JSON.encode(_dataObject);
			} 
			return null;
		}
		
		public static function fromXMPSerializedView(jsonString: String):AppModelXMPView 
		{
			if (!jsonString) return null;
			var obj:* = JSON.decode(jsonString);
			return new AppModelXMPView(obj);
		}
		
		public function get dataObject():* 
		{
			return _dataObject;
		}
		
	}
}