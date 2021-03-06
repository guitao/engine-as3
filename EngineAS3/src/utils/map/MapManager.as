package utils.map
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import org.ijelly.findPath.Cell;
	import org.ijelly.findPath.NavMesh;
	import org.ijelly.geom.Block;
	import org.ijelly.geom.Triangle;
	import org.ijelly.geom.Vector2f;
	import org.osmf.events.TimeEvent;
	
	import utils.debug.Console;
	import utils.load.LoadInfo;
	import utils.load.LoadManager;

	public class MapManager extends EventDispatcher
	{
		private var _baseUrl:String = 'file:///D:/My%20Documents/map/';
		/*file:///C:/Documents%20and%20Settings/Administrator/My%20Documents/map/CJ301/CJ301.navmap*/
		/*file:///D:/My%20Documents/map/CJ301/CJ301.mapedit*/
		private var _mapName:String = 'CJ301';
		private var stage:Stage;
		private var _mapContainer:MapContainer;
		private var _mapdataDIC:Object;
		
		private var _loadListDIC:Object;
		
		private var _mapWidth:int;
		private var _mapHeight:int;
		private var _picw:int
		private var _pich:int; 
		
		private var _loadNum:int;
		private var _allNum:int;
		private var _currentPoint:String;
		
		public var pathServer:PathServer;
		
		public function MapManager(stage:Stage,mapContainer:MapContainer)
		{
			this.stage = stage;
			this._mapContainer = mapContainer;
			this._mapContainer.mapManager = this;
			pathServer = new PathServer;
			pathServer.debug = mapContainer.debug;
		}
		public function initMap(mapName:String):void{
			this._mapName = mapName;
			
			var loadList:Vector.<LoadInfo> = new Vector.<LoadInfo>;
			var mapdataUrl:String = _baseUrl + _mapName + "/" + _mapName + ".navtile";
			var loadInfo:LoadInfo = new LoadInfo(mapdataUrl,LoadInfo.XML,onLoadmapData,true);
			loadList.push(loadInfo);
			
			var miniMapUrl:String = _baseUrl + _mapName + "/minimap/" + _mapName + ".jpg";
			loadInfo = new LoadInfo(miniMapUrl,LoadInfo.BITMAP,onLoadMiniMap,true);
			loadList.push(loadInfo);
			
			stage.addChild(MapLoaderInterface.getInstance());
			LoadManager.getInstance().addListLoad(loadList,onMapLoaded);
			
			_mapdataDIC = new Object;
		}
		
		private function onLoadmapData(xml:XML):void{
			this._mapWidth = xml.@mapwidth;
			this._mapHeight = xml.@mapheight;
			this._pich = xml.@pich;
			this._picw = xml.@picw;
			pathServer.initMapdata(xml);
		}
		
		private function onLoadMiniMap(bitmap:Bitmap):void{
			_mapContainer.mapBitmap = bitmap;
		}
		
		private function onMapLoaded(event:Event):void{
			stage.removeChild(MapLoaderInterface.getInstance());
			_mapContainer.setMapWH(this._mapWidth,this._mapHeight);
			initListDIC();
			this.dispatchEvent(new Event(Event.INIT));
		}
		private function initListDIC():void{
			if(_loadListDIC == null)
				_loadListDIC = new Object;
			var w:int = Math.ceil(_mapWidth/300);
			var h:int = Math.ceil(_mapHeight/300);
			_allNum = w*h;
			for(var i:int=0;i<w;i++){
				for(var j:int=0;j<h;j++){
					var key:String = i + "_" + j;
					_loadListDIC[key] = false;
				}
			}
			
		}
		
		private function onLoadAll():void{
			for(var i:int=0;i<10;i++){
				for(var j:int=0;j<6;j++){
					var key:String = i + "_" + j + ".jpg";
					var url:String = _baseUrl + _mapName + "/newimg/" + key;
					var loadInfo:LoadInfo = new LoadInfo(url,LoadInfo.BITMAP,refreshBitmap,false,new Point(i,j));
					LoadManager.getInstance().addSingleLoad(loadInfo);
				}
			}
		}
		public function onLoadkey(xpos:Number,ypos:Number,wNum:int,hNum:int):void{
			if(_loadNum >= _allNum){
				//Console.getInstance().show("加载全部完成");
				return;
			}
			var key:String;
			var beginX:int = xpos/300;
			var beginY:int = ypos/300;
			
			key = beginX + "_" + beginY;
			
			/*if(_currentPoint != key){
				Console.getInstance().show("加载");
				_currentPoint = key;
			}else{
				Console.getInstance().show("空闲");
				return;
			}*/
			
			for(var i:int=0;i<wNum;i++){
				for(var j:int=0;j<hNum;j++){
					key = (i+beginX) + "_" + (j+beginY);
					if(!_loadListDIC.hasOwnProperty(key) || _loadListDIC[key]){
						continue;
					}
					var url:String = _baseUrl + _mapName + "/newimg/" + key + ".jpg";
					_loadListDIC[key] = true;
					_loadNum++;
					if(_loadNum == 49){
						Console.getInstance().show("complete");
					}
					var loadInfo:LoadInfo = new LoadInfo(url,LoadInfo.BITMAP,refreshBitmap,false,new Point(i+beginX,j+beginY));
					LoadManager.getInstance().addSingleLoad(loadInfo);
				}
			}
			
		}
		
		private function refreshBitmap(bitmap:Bitmap,p:Point):void{
			var bitmapdata:BitmapData = _mapContainer.mapBitmap.bitmapData;
			var newbitmapdata:BitmapData = bitmap.bitmapData;
			var rec:Rectangle = new Rectangle(0,0,300,300);
			var newp:Point = new Point(p.x * 300,p.y * 300);
			bitmapdata.copyPixels(newbitmapdata,rec,newp);
		}
		
	}
}