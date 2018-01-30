package 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.Graphics;
	import silin.filters.FlagMap;
	import PanZoomTest;
	import PanZoomMap;
	
	/**
	 * ...
	 * @author silin
	 */
	public class Ukraine extends Sprite 
	{
		private var _flagBody:img;
		private var _flagMap:FlagMap;
		public var Container:img = new img();;
		public var all:Sprite=new Sprite();
		
		public function Ukraine():void 
		{
			 //init(0.010,100,0);
			 
			 all.addChild(Container);
			 
			 var dfsdf= new PanZoomTest(all);
			 addChild(dfsdf);
			 
			 var sdfds:String=new String();
		}
		
		private function init(one,two,three):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.align = StageAlign.TOP_LEFT;
			// entry point
			_flagBody = new img();

			_flagBody.x = 3;
			_flagBody.y = 2;
			
			_flagMap = new FlagMap(_flagBody.width, _flagBody.height, one, two, true);
			//_flagMap = new FlagMap(_flagBody.width, _flagBody.height, 0, 35, true);
			_flagMap.offset=0.01;
			
			var shade:Sprite = _flagMap.getShade();
			shade.y = 3;
			shade.x = 3;

			
			
			render(null);
			while(Container.numChildren) Container.removeChildAt(0);
			Container.addChild(_flagBody);
			Container.addChild(shade);
			Container.addEventListener(Event.ENTER_FRAME, render);
			
		}
		
		private function offsetHandler(evnt:Event):void 
		{
			_flagMap.offset = _offsetSlider.value;
		}
		

		private function sizeHandler(evnt:Event):void
		{
			_flagMap.cellSize = _sizeSlider.value;
		}
		
		private function scaleHandler(evnt:Event):void
		{
			_flagMap.scale = _scaleSlider.value;
		}
		
		private function render(evnt:Event):void 
		{
			
			_flagMap.render();
			_flagBody.filters = [_flagMap.filter];
			
		}
		
	}
	
}