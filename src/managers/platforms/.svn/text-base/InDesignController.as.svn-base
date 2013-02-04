package managers.platforms
{
	import com.adobe.csawlib.indesign.InDesign;
	import com.adobe.cshostadapter.*;
	import com.adobe.indesign.*;
	
	import flash.filesystem.File;
	import flash.net.FileReference;
	import flash.utils.getQualifiedClassName;
	import managers.AppModel;
	
	public class InDesignController
	{
		private static var app:Application = InDesign.app;
		private static var model:AppModel = AppModel.getInstance();
		private static var instance:InDesignController;
		public static function getInstance():InDesignController{
			if ( instance == null )
			{
				instance = new InDesignController;
			}
			return instance;			
		}
		public static function attach():void{
			IDScriptingEventAdapter.getInstance().addEventListener(Application.AFTER_SELECTION_CHANGED, handleIDEvent);
		}
		public static function detach():void 
		{
			try{
				IDScriptingEventAdapter.getInstance().removeEventListener(Application.AFTER_SELECTION_CHANGED, handleIDEvent);
			}
			catch(error:Error){}
		}
		//InDesign event handlers expect an event object, so we'll 
		//create a dummy handler to strip the event and call the generic
		//event handler.
		public static function handleIDEvent(event:Event):void 
		{
			handleEvent();
		}		

		public static function handleEvent():void 
		{
			if(!app.modalState){
				var result:Boolean = false;
				if(app.documents.length > 0)
				{
					//A document is open, so enable the Import File button.
					model.documentOpen = true;
					if(app.selection.length > 0){
						for(var counter:int = 0; counter < app.selection.length; counter++){
							switch(true){
								case app.selection[counter] is Rectangle:
								case app.selection[counter] is Oval:
								case app.selection[counter] is Polygon:
								case app.selection[counter] is GraphicLine:
								case app.selection[counter] is TextFrame:
								case app.selection[counter] is Group:
									//If the current export format is SWF, enable the Export Selected checkbox.
									if(model.formatName == "SWF"){
										result = true;
									}
									break;
							}
							if(result == true){
								break;
							}
						}
					}
				}
				else{
					model.documentOpen = false;
				}
			}
//			model.enableCheckbox = result;
		}

/*		
		public static function exportFile(file:Object):void
		{
			var format:ExportFormat;
			switch(model.formatName)
			{
				case "JPEG":
					//Set the export page range to the current page.
					app.jpegExportPreferences.jpegExportRange = ExportRangeOrAllPages.EXPORT_RANGE;
					app.jpegExportPreferences.pageString = app.activeWindow.activePage.name;
					format = ExportFormat.JPG;
					break;
				case "SWF":
					if(model.exportSelection == true){
						app.swfExportPreferences.pageRange = PageRange.SELECTED_ITEMS;
					}
					else{
						app.swfExportPreferences.pageRange = app.activeWindow.activePage.name;
					}
					format = ExportFormat.SWF;
					break;
				case "PDF":
					if(model.exportSelection == true){
						app.pdfExportPreferences.pageRange = PageRange.SELECTED_ITEMS;
					}
					else{
						app.pdfExportPreferences.pageRange = app.activeWindow.activePage.name;
					}
					format = ExportFormat.PDF_TYPE;
					break;
			}
			
			app.activeDocument.exportFile(format, file as File, false);
		}
		
		public static function importFile(file:Object):void
		{
			app.activeWindow.activePage.place(file);
		}
		
	*/
	}
}