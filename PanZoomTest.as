package{
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import flash.geom.ColorTransform;
	import flash.display.InteractiveObject;
	import flash.events.Graphics;
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.plugins.*;
	import com.jumpeye.flashEff2.symbol.intersectingStripes.FESIntersectingStripes;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.geom.ColorTransform;
	public class PanZoomTest extends Sprite
	{
		var pz:PanZoomMap; // скласс с картой
		var mapImg:Uk = new Uk(); // добавляемая карта
		var zoomPlus:Sprite = new Sprite();
		var zoomMinus:Sprite = new Sprite();
		var toop:Sprite=new Sprite();
		var viewerWidth = 747;
		var viewerHeight = 343;
		
		// for zoom box example
		var box = new Shape();
		var clickPt:Point;
		var boxInterval;
		
		public function PanZoomTest(Container):void
		{
			var city:town=new town();
			city.x=339.95;
			city.y=244.10;
			//city.buttonMode=true;
			city.name="city";
			city.addEventListener(MouseEvent.MOUSE_OVER, clicktown);
			city.addEventListener(MouseEvent.MOUSE_OUT, clicktownout);
			mapImg.addChild(city);
			
			
			toop.graphics.beginFill(0X000000);
			toop.graphics.drawRoundRect(0,0,85,16,9);
			toop.graphics.endFill();
			toop.x=350;
			toop.y=230;
			var theTextField:TextField = new TextField();
			theTextField.textColor =0XFFFFFF;
			
			var format1:TextFormat = new TextFormat();
			format1.font="Arial";
			format1.size=12;
			theTextField.setTextFormat(format1);
			
			theTextField.htmlText="Всего работ 50";
			theTextField.y=-1;
			theTextField.x=3;
			toop.addChild(theTextField);
			toop.mouseEnabled=false;
			toop.visible=false;
			mapImg.addChild(toop);
			
			var cdgdfg:* = mapImg.getChildAt(26);
			var newColorTransform:ColorTransform = cdgdfg.transform.colorTransform;
			newColorTransform.color = 0X17478F;
			cdgdfg.transform.colorTransform=newColorTransform;
			//mapImg.removeChild(cdgdfg);
			TweenPlugin.activate([TintPlugin]);
			mapImg.addEventListener(MouseEvent.MOUSE_OVER, clickregion);
			mapImg.addEventListener(MouseEvent.MOUSE_OUT, clickregionout);
			pz = new PanZoomMap(mapImg,viewerWidth,viewerHeight,Container);	// create the PanZoomMap using the map and specified size
			pz.x =  0;
			pz.y = 0;
			addChild(pz);
			pz.addEventListener(MouseEvent.MOUSE_WHEEL, _zoom);
			
		}
		
		public function clicktown(evnt:MouseEvent){
			TweenLite.to(mapImg.getChildByName("UA_OD"), .5, {tint:0xB7C1E0});
			toop.visible=true;
		}
		
		public function clicktownout(evnt:MouseEvent){
			TweenLite.to(mapImg.getChildByName("UA_OD"), .5, {tint:0xF5F6FB});
			toop.visible=false;
		}
		
		public function clickregion(evnt:MouseEvent):void  {
			var tar:*=evnt.target;
			var className: String = flash.utils.getQualifiedClassName(tar);
			if(tar.name!="city") {
				if(className!="flash.text::TextField") {
					if(tar.name!="borders" && tar.name!="nottoch") {
						if(tar.numChildren>=2) {
							//TweenLite.to(mapImg.getChildByName(tar.name), .5, {tint:0xB7C1E0});
							tar.getChildAt(1).mouseEnabled  =false;
						} else {
							//TweenLite.to(mapImg.getChildByName(tar.name), .5, {tint:0xB7C1E0});
						}
					}
				} else {
					tar.mouseEnabled=false;
				}
			}
		}
		
		public function clickregionout(evnt:MouseEvent):void  {
			var tar:*=evnt.target;
			var className: String = flash. utils . getQualifiedClassName(tar);
			if(className!="flash.text::TextField" && tar.name!="city") {
				if(tar.name!="borders" && tar.name!="nottoch") {
					//TweenLite.to(mapImg.getChildByName(tar.name), .5, {tint:0xF5F6FB});
				}
			}
	
		}
		
		function zoomIn()
		{
			pz.zoomTo(pz.zoomAmount*2);
		}
		
		function zoomOut()
		{
			if (pz.zoomAmount/2 >= pz.minZoom) pz.zoomTo(pz.zoomAmount/2);
			else pz.zoomTo(pz.minZoom);
		}
		
		// start drawing a zoom box from the click location
		function startBox(e){
			clickPt = new Point(stage.mouseX,stage.mouseY);
			box.x = clickPt.x;
			box.y = clickPt.y;
			box.width = box.height = 1;
			addChild(box);
			boxInterval = setInterval(sizeBox,50);
			stage.addEventListener(MouseEvent.MOUSE_UP,stopBox);
		}
		// zoom box follows the mouse
		function sizeBox(){
			box.width = Math.abs(stage.mouseX - clickPt.x);
			if (stage.mouseX < clickPt.x) box.x = stage.mouseX;
			else box.x = clickPt.x;
			box.height = Math.abs(stage.mouseY - clickPt.y);
			if (stage.mouseY < clickPt.y) box.y = stage.mouseY;
			else box.y = clickPt.y;
		}
		
		// Here's the basic functionality of the zoom box.
		function stopBox(e){
			clearInterval(boxInterval);
			stage.removeEventListener(MouseEvent.MOUSE_UP,stopBox);
			// center of box in map coordinates
			var where = mapImg.globalToLocal(new Point(box.x + box.width/2,box.y + box.height/2));
			var scale;
			// viewer size divided by box size
			//	e.g., if the box is half the width of the viewer, the scale has to be doubled for the area under the box to match the area of the viewer
			if (box.width > box.height){
				scale = viewerWidth*pz.zoomAmount/box.width;
			} else {
				scale = viewerHeight*pz.zoomAmount/box.height;
			}
			pz.zoomTo(scale);	// zoom to the calculated scale
			pz.panTo(where);	// pan to the box center
			removeChild(box);
		}
		public function _zoom(mouse:MouseEvent):void {
			if(mouse.delta>0) {
				zoomIn();
			} else {
				zoomOut();
			}
		}
	}
}