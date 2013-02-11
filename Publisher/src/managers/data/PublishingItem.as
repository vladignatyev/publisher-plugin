package managers.data
{
	import com.adobe.illustrator.Artboard;
	import com.adobe.illustrator.Document;
	import com.adobe.illustrator.ExportOptionsJPEG;
	import com.adobe.illustrator.ExportOptionsPNG24;
	import com.adobe.illustrator.ExportType;
	import com.adobe.illustrator.RGBColor;
	
	import flash.events.EventDispatcher;
	
	import utils.ArtboardUtils;

	[Bindable]
	public class PublishingItem extends EventDispatcher
	{
		public static const PNG24:String = "png24";
		public static const JPG:String = "jpg";
		
		public var activeDocument:Document;
		public var assetComposition:AssetComposition;
		
		
		//@see: http://wwwimages.adobe.com/www.adobe.com/content/dam/Adobe/en/devnet/pdf/illustrator/scripting/cs6/Illustrator-Scripting-Reference-JavaScript.pdf
		
		public var jpgQualitySetting:int = 80;
		public var jpgAntiAliasing:Boolean = true;
		public var jpgOptimization:Boolean = true;
		public var jpgBlurAmount:Number = 0;
				
		public var png24Transparency:Boolean = true;
		public var png24AntiAliasing:Boolean = true;
		
		public var matte:Boolean = false;		
		public var matteColor:RGBColor = new RGBColor();
				
		public var exportAs2X:Boolean = true;
		
		public var name:String = "";
		public var type:String = PublishingItem.PNG24;
		
		public var isPublished:Boolean = true;	
		
		public var pathToPublish:String = "";
		
		public function PublishingItem() {
			super();
		}
		
		public function fromPlainObject(po:*):void { //todo: упростить с использованием dynamic class
			this.name = po["name"];
			this.type = po["type"];
			this.pathToPublish = po["pathToPublish"];
			this.isPublished = po["isPublished"];
			
			this.jpgQualitySetting = po["jpgQualitySetting"];
			this.jpgAntiAliasing = po["jpgAntiAliasing"];
			this.jpgOptimization = po["jpgOptimization"];
			this.jpgBlurAmount = po["jpgBlurAmount"];
			
			this.png24Transparency = po["png24Transparency"];
			this.png24AntiAliasing = po["png24AntiAliasing"];
			
			this.matte = po["matte"];		
			this.matteColor = new RGBColor();
			this.matteColor.red = po["matteColor"][0];
			this.matteColor.green = po["matteColor"][1];
			this.matteColor.blue = po["matteColor"][2];
			
			this.exportAs2X = po["exportAs2X"];
		}
		
		public function toPlainObject():* { //todo: упростить с использованием dynamic class
			const po:* = {};
			po["name"] = this.name;
			po["type"] = this.type;
			po["pathToPublish"] = this.pathToPublish;
			po["isPublished"] = this.isPublished;
			
			po["jpgQualitySetting"] = this.jpgQualitySetting;
			po["jpgAntiAliasing"] = this.jpgAntiAliasing;
			po["jpgOptimization"] = this.jpgOptimization;
			po["jpgBlurAmount"] = this.jpgBlurAmount;
			
			po["png24Transparency"] = this.png24Transparency;
			po["png24AntiAliasing"] = this.png24AntiAliasing;
			
			po["matte"] = this.matte;		
			po["matteColor"] = [this.matteColor.red, this.matteColor.green, this.matteColor.blue];
			po["exportAs2X"] = this.exportAs2X;
			
			return po;
		}
		
		public function get exportOptions():* {
			var exportOptions:*;
			switch(type){
				case PublishingItem.JPG:
					exportOptions = new ExportOptionsJPEG();
					exportOptions.artBoardClipping = true;
					exportOptions.antiAliasing = jpgAntiAliasing;
					exportOptions.matte = matte;
					exportOptions.matteColor = matteColor;
					exportOptions.blurAmount = jpgBlurAmount;
					exportOptions.optimization = jpgOptimization;
					exportOptions.qualitySetting = jpgQualitySetting;
					return exportOptions;
				
				case PublishingItem.PNG24:
				default:
					exportOptions = new ExportOptionsPNG24();
					exportOptions.matte = false;
					exportOptions.matteColor = matteColor;
					exportOptions.antiAliasing = png24AntiAliasing;
					exportOptions.transparency = png24Transparency; //todo: get transparency from PublishingItem
					exportOptions.artBoardClipping = true;
			}
			return exportOptions;
		}
		
		public function get exportType():ExportType {
			if (type == PublishingItem.JPG) return ExportType.JPEG;
			return ExportType.PNG24;
		}
		
		public function get systemFilename():String {
			var extension:String = type == PublishingItem.JPG?'jpg':'png';
			return this.name + '.' + extension;
		}
		
		public function get systemFilename2x():String {
			var extension:String = type == PublishingItem.JPG?'jpg':'png';
			return this.name + '@2x.' + extension;
		}
		
		public function get artboardName():String {
			return ArtboardUtils.getCleanName(activeDocument.artboards.index(assetComposition.artboardIndex));
		}
		
		public function get dimensionsString():String {
			if (assetComposition && activeDocument.artboards.index(assetComposition.artboardIndex)) {
				var dimensions:* = ArtboardUtils.getDimensions(activeDocument.artboards.index(assetComposition.artboardIndex));
				return Math.round(dimensions.artboardWidth) + "×" + Math.round(dimensions.artboardHeight);
			} 
			return "";
		}
	}
}