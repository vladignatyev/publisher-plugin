package utils
{
	import com.adobe.illustrator.Artboard;

	public class ArtboardUtils
	{
		public static function getDimension(artboard:Artboard):* {
			if (!artboard) {
				return {"artboardWidth": -1, "artboardHeight": -1};
			}
			var artboardWidth:Number = Math.ceil(Math.abs(artboard.artboardRect[2] - artboard.artboardRect[0]));
			var artboardHeight:Number = Math.ceil(Math.abs(artboard.artboardRect[3] - artboard.artboardRect[1]));
			return {"artboardWidth": artboardWidth, "artboardHeight": artboardHeight};
		}
		
		public static function getCleanName(artboard:Artboard):String {
			var artboardName:String = (artboard as Object).toString();
			return artboardName.substr("[Artboard ".length,artboardName.length-"[Artboard ".length-1);
		}
	}
}