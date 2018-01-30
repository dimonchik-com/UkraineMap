package
{	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.Shape;
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.plugins.*;
	import flash.text.*;
import flash.utils.getTimer;

	public class PanZoomMap extends Sprite
	{
		
		private var mapImg;	// source image (map)
		private var mapWidth;	// width of source image
		private var mapHeight;
		private var size:Rectangle;	// size of viewable area
		private var masky:Shape = new Shape();	// mask for the viewable area
		
		private var panContainer:Sprite = new Sprite();		// PAN this container
		private var zoomContainer:Sprite = new Sprite();	// SCALE this container
		
		public var minZoom;		// minimum zoom level (scale), where the map just fits in the viewable area
		public var zoomAmount;	// current scale
		
		private var dragLimits:Rectangle;	// the boundaries in which the map can be panned, which changes with scale
		
		private var infos:String = new String();
		public var eart:Array = new Array();
		
		public var hope:Array = new Array();
		public var notoch:Array = new Array();
		var myText:TextField = new TextField();
		var time	: Number = getTimer();
		/*
			Функция для создания массива всех стран
			name:String - название страны
		*/
		public function created(nam, ...val) {
			var time:Object = new Object(); // создание объекта
			time.nam=nam; // имя страны
		      var timearray:Array = new Array();  // создание массива		
			  for each (var i:* in val) { // перебор всех соседей
				timearray.push(i); // запись в массив всех соседий
			  }
			time.sosedi=timearray; // запись всей информации о стране в массив
			hope.push(time); // запись страны в глобальный массив
		}
		

		

		public function PanZoomMap(src,w,h,Container):void
		{		   
		    created("UA_ZK","UA_LV","UA_IF");
			created("UA_LV","UA_ZK","UA_IF","UA_TP","UA_VO","UA_RV");
			created("UA_TP", "UA_CV", "UA_KM", "UA_RV", "UA_LV", "UA_IF");
			created("UA_IF","UA_ZK", "UA_LV", "UA_TP", "UA_CV");
			created("UA_RV", "UA_ZT", "UA_KM", "UA_TP", "UA_LV","UA_VO");
			created("UA_VO","UA_LV","UA_RV");
			created("UA_CV","UA_IF","UA_TP","UA_KM","UA_VI");
		    created("UA_KM","UA_CV","UA_TP","UA_RV","UA_ZT","UA_VI");
		    created("UA_ZT","UA_RV","UA_KM","UA_VI","UA_KV");
			created("UA_VI","UA_CV","UA_KM","UA_ZT","UA_KV","UA_CK","UA_KH","UA_OD");
			created("UA_KV","UA_ZT","UA_VI","UA_CK","UA_CH","UA_PL"); 
			created("UA_PL","UA_SM","UA_KK","UA_DP","UA_KH","UA_CK","UA_KV","UA_CH");
			created("UA_DT","UA_ZP","UA_DP","UA_KK","UA_LH");
			created("UA_KK","UA_SM","UA_PL","UA_DP","UA_DT","UA_LH");
			
			mapImg = src;
			mapWidth = src.width;
			mapHeight = src.height;
			size = new Rectangle(0,0,w,h);
			
			Container.x=-370;
			Container.y=-170;
			panContainer.addChild(Container);
			// map goes in the pan container
			panContainer.addChild(mapImg);

			mapImg.x = -mapWidth/2;
			mapImg.y = -mapHeight/2;
			
			// panContainer goes inside zoomContainer
			zoomContainer.addChild(panContainer);
		    //zoomContainer is centered within those whole thing
			zoomContainer.x = size.width/2;
			zoomContainer.y = size.height/2;
			
			// draw the mask so we can't see the map beyond the viewable area
			masky.graphics.beginFill(0);
			masky.graphics.drawRect(size.x,size.y,size.width,size.height);
			zoomContainer.mask = masky;
			
			addChild(zoomContainer);
			addChild(masky);
			
			panContainer.addEventListener(MouseEvent.CLICK,info);
			panContainer.addEventListener(MouseEvent.MOUSE_DOWN,startPan);
			
			minZoom = Math.min(size.height/mapHeight,size.width/mapWidth);	// zoom level at which the map will fit in the viewer
			zoomTo(minZoom);
		}
		
		public function info(e:Event){
			namer=e.target;
		//trace(infos=infos+'"'+namer.name+'",');
			if(infos.length!=0){
				
				//trace("This just result "+findputch(infos,namer.name)); //нахождение пути из одной страны в другую
				var texts:TEXTN=new TEXTN();
				
				
				zoomContainer.addChild(texts);
				time = getTimer();
				var sfsd:*=findputch(infos,namer.name);
				
				
				myText.text = (getTimer() - time)+" "+sfsd;
				myText.width=400;
				myText.x=-370;
				myText.y=100;
				zoomContainer.addChild(myText);
				//trace(notoch);
							//for each (var two:* in resultat) {
								
								//TweenLite.to(mapImg.getChildByName(two), .5, {tint:0xB7C1E0});
							//}
							notoch.splice(0,notoch.length);
				/*for each (var i:* in eart) {
					for each (var one:* in i.bord) {
						var tmp:Array = one.split(" ");
						if(tmp[tmp.length-1]==namer.name){
							for each (var two:* in tmp) {
								
								TweenLite.to(mapImg.getChildByName(two), .5, {tint:0xB7C1E0});
							}
						}
					}
				}*/
			} else {
				infos=namer.name;
			}
			
		}
		
		// enable/disable click-and-drag panning
		public function set (pan:Boolean):void 
		{
			
			if (pan){
				if (!panContainer.hasEventListener(MouseEvent.MOUSE_DOWN)) panContainer.addEventListener(MouseEvent.MOUSE_DOWN,startPan);
			} else {
				if (panContainer.hasEventListener(MouseEvent.MOUSE_DOWN)) panContainer.removeEventListener(MouseEvent.MOUSE_DOWN,startPan);
			}
		}
		public function get allowPanning():Boolean
		{
			if (panContainer.hasEventListener(MouseEvent.MOUSE_DOWN)) return true;
			else return false;
		}
		
		/* 	To zoom to a specified scale, change the scale of zoomContainer. It grows or shrinks around the origin
			point, which never moves in this case. No matter where panContainer is positioned within zoomContainer,
			when the zoom changes the same point will remain the center.
		*/
		public function zoomTo(scale):void
		{
			if(scale<6.5) {
				if (scale >= minZoom){
					//zoomAmount = zoomContainer.scaleX = zoomContainer.scaleY = scale;
				} else {
					zoomAmount = zoomContainer.scaleX = zoomContainer.scaleY = minZoom;
				}
					zoomAmount = scale;
					TweenLite.to(zoomContainer, 1, {scaleX:scale, scaleY:scale});
				// Panning limits change when the scale changes
				getLimits();
				checkBounds();
			}
		}
		
		/* 	To pan to a point, move the panContainer inside zoomContainer. In this case we provide coordinates
			in the context of the map itself, which have to be converted to the context of zoomContainer (since the
			map might be scaled).
		*/
		public function panTo(pt:Point /* in the coordinate space of mapImg */):void
		{
			var containerPt:Point = panContainer.globalToLocal(mapImg.localToGlobal(pt));
			panContainer.x = -containerPt.x;
			panContainer.y = -containerPt.y;
			checkBounds();	// make sure it didn't move out of bounds
		}
		
		// Click and drag panning
		private function startPan(e:MouseEvent):void
		{
			
			panContainer.startDrag(false,dragLimits);
			stage.addEventListener(MouseEvent.MOUSE_UP,stopPan);
			stage.addEventListener(Event.MOUSE_LEAVE,stopPan);
		}
		private function stopPan(e:MouseEvent):void
		{
			panContainer.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP,stopPan);
			stage.removeEventListener(Event.MOUSE_LEAVE,stopPan);
		}
		
		// If panContainer has gone out of bounds, move it back. This can happen when it's moved or when scale changes.
		private function checkBounds():void
		{
			if (panContainer.x < dragLimits.left) {
				panContainer.x = this.dragLimits.left;
			}
			if (panContainer.y < this.dragLimits.top) {
				panContainer.y = this.dragLimits.top;
			}
			if (panContainer.x > dragLimits.right) {
				panContainer.x = dragLimits.right;
			}
			if (panContainer.y > dragLimits.bottom) {
				panContainer.y = dragLimits.bottom;
			}
		}
		
		/* Calculate the panning boundaries based on scale.
			The leftmost limit, for example, in stage coordiantes, is:
				leftLimit = viewerWidth/2 - mapWidth/2
			But we need the limit in the coordinates of zoomContainer. The above is actually like this:
				globalLeftLimit = viewerWidth/2 - globalMapWidth/2
			Which equals
				globalLeftLimit = viewerWidth/2 - zoomAmount*mapWidth/2
			To get the local coordinates of the left limit, divide by zoom amount. So, divide both sides of the equation by zoomAmount:
				globalLeftLimit/zoomAmount = (viewerWidth/2)/zoomAmount - mapWidth/2
			Or,
				leftLimit = (viewerWidth/2)/zoomAmount - mapWidth/2
				
			The other sides are done similarly.
		*/
		private function getLimits() {
			var left = (size.width/2)/(zoomAmount) - (mapWidth/2);
			if (left > 0) {
				left=0;
			}
			var top = (size.height/2)/(zoomAmount) - (mapHeight/2);
			if (top > 0) {
				top=0;
			}
			var right = (mapWidth/2) - (size.width/2)/(zoomAmount);
			if (right < 0) {
				right=0;
			}
			var bottom = (mapHeight/2) - (size.height/2)/(zoomAmount);
			if (bottom < 0) {
				bottom=0;
			}
			dragLimits = new Rectangle(left, top, (right-left), (bottom-top));
		}
	}
}