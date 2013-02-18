package views
{
	import flash.events.Event;
	
	import managers.data.PublishingItem;
	
	import mx.collections.ArrayCollection;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridGroupItemRenderer;
	
	public class GroupedItemRenderer extends AdvancedDataGridGroupItemRenderer
	{
		public function GroupedItemRenderer()
		{
			super();
		}
		
		override public function set data(value:Object):void
		{
			// TODO Auto Generated method stub
			super.data = value;
			trace(value);
			if (!value) return;
			if (!value.name) return;
			if (!value.pathToPublish) return;
			if (value is PublishingItem) return;

			value.pathToPublish = value.name;
			
			for (var i:int = 0; i < value.children.length; i++) {
				const it:PublishingItem = ((value.children as ArrayCollection).getItemAt(i) as PublishingItem);
				it.pathToPublish = value.pathToPublish;
			}
		}
		

	}
}