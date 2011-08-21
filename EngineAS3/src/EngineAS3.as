package
{
	import utils.debug.Console;
	import utils.map.IResizeDisplayObject;
	import utils.map.MapContainer;
	import utils.map.MapLoaderInterface;
	import utils.map.MapManager;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	public class EngineAS3 extends Sprite
	{
		private var mapManager:MapManager;
		private var mapContainer:MapContainer;
		public function EngineAS3()
		{
			this.addEventListener(Event.ADDED_TO_STAGE,addToStage);
		}
		private function addToStage(event:Event):void{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE,onStageResize);
			initMap();
		}
		private function initMap():void{
			mapContainer = new MapContainer;
			this.addChild(mapContainer);
			mapManager = new MapManager(stage,mapContainer);
			mapManager.initMap("CJ301");
			this.addChild(Console.getInstance());
			
		}
		private function onStageResize(event:Event):void{
			for(var i:int;i<this.numChildren;i++){
				var obj:Object = this.getChildAt(i);
				if(obj is IResizeDisplayObject){
					obj.resize(); 
				}
			}
		}
	}
}