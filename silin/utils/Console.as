/*
 
  The MIT License, 
 
  Copyright (c) 2011. silin (http://silin.su#AS3)
 
*/
package silin.utils 
{
	
	import flash.display.*;
	import flash.external.*;
	import flash.text.*;
	/**
	 * отладочная утилита; <br/>
	 * лог в тектфилд и/или консоль FireBug и/или стандартный трейс; <br/>
	 * для вывода в текстфилд необходим  вызов Console.register() 
	 * @author silin
	 */
	public class Console
	{
		
		public static const TRACE:int = 1;
		public static const PANEL:int = 2;
		public static const FIREBUG:int = 4;
		/**
		 * получатели вывода: Console.TRACE | Console.PANEL | Console.FIREBUG
		 */
		private static var _output:int = PANEL;
		/**
		 * формат текста
		 */
		public static var format:TextFormat = new TextFormat("_sans", 11, 0x404040);
		
		private static var _win:Window;
		
		/**
		 * не конструктор, экземпляры не создаем
		 */
		public function Console()
		{
			throw(new Error("Console is a static class and should not be instantiated."))
		}

		public static function clear():void
		{
			_win.tf.text = "";
		}
		/**
		 * выодит arg в консоль FireBug, тектфилд или стандартный трейс<br/>
		 * в зависимости от состояния output<br/>
		 * если mark truе, выделят красным
		 * @param	arg
		 * @param	mark
		 */
		public static function log(arg:Object, mark:Boolean=false, clr:int=-1):void
		{
			if (!output) 
			{
				return;
			}
			
			//дублируем в trace
			if (output & TRACE) 
			{
				trace(arg);
			}
			
			var str:String = arg ? arg.toString() : "";
			//вывод в тестфилд
			if (_win && (output & PANEL))
			{
				var b:int = _win.tf.text.length;
				_win.tf.appendText(str + "\n");
				var e:int = _win.tf.text.length;
				_win.tf.scrollV = _win.tf.maxScrollV;
				var fmt:TextFormat = new TextFormat(format.font, format.size, format.color);
				if (mark)
				{
					fmt.color = clr > -1 ? clr:0xC00000;
				}
				_win.tf.setTextFormat(fmt, b, e);
			}
			
			//вывод в консоль FireBug
			if (ExternalInterface.available && (output & FIREBUG))
			{
				if (mark)
				{
					ExternalInterface.call( 'function(val){ console.warn(val);}', str);
				}else
				{
					ExternalInterface.call( 'function(val){ console.log(val);}', str)
				}
			}
		}
		
		
		/**
		 * привязка к stage, нужна для вывода в пвнель;<br/>
		 * здесь же задаем размеры панели
		 * @param	stage
		 * @param	width
		 * @param	height
		 */
		public static function register(stage:Stage, width:Number = 240, height:Number = 320):void
		{
			if (_win) return;
			
			_win = new Window(width, height);
			stage.addChild(_win);
			Console.align = StageAlign.TOP_RIGHT;
			output |= PANEL;//включаем вывод в тектфилд 
			
		}
		
		
		/**
		 * куда выводить лог:  TRACE | PANEL | FIREBUG
		 */
		static public function get output():int { return _output; }
		static public function set output(value:int):void 
		{
			_output = value;
			//прячем окно, если нет вывода в текстфилд
			if (_win)
			{
				_win.visible = Boolean(_output & PANEL);
			}
			
			
		}
		/**
		 * текст шапки
		 */
		static public function get caption():String { return _win.caption.text; }
		static public function set caption(value:String):void 
		{
			_win.caption.text = value;
		}
		
		
		/**
		 * размещение панели (TR,TL,BR,BL)
		 */
		public static function set align(value:String):void 
		{
			if(_win)
			switch(value)
			{
				case StageAlign.BOTTOM_LEFT:
				{
					_win.y = _win.stage.stageHeight - _win.height - 1;
				}
				break;
				case StageAlign.TOP_RIGHT:
				{
					
					_win.x = _win.stage.stageWidth - _win.width - 1;
				}
				break;
				case StageAlign.BOTTOM_RIGHT: 
				{
					_win.y = _win.stage.stageHeight - _win.height - 1;
					_win.x = _win.stage.stageWidth - _win.width - 1;
				}
				break;
				default: {
					_win.x = 1;
					_win.y = 1;
				}
				
			}
		}
		
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
import flash.display.*;
import flash.events.*;
import flash.text.*;
import flash.ui.*;
import silin.utils.*;
class Window extends Sprite
{
	
	public const barHeight:Number = 20;
	public var tf:TextField = new TextField();
	public const caption:TextField = new TextField();
	
	private const grip:Sprite = new Sprite();
	private const minimazeButton:Sprite = new Sprite();
	private const body:Sprite = new Sprite();
	
	public function Window(width:Number, height:Number)
	{
		x = 10;
		y = 10;
		
		
		body.graphics.clear();
		body.graphics.lineStyle(0, 0x808080);
		body.graphics.beginFill(0xFFFFFF, 0.75);
		body.graphics.drawRect(0, 0, width, height);
		body.graphics.endFill();
		
		grip.graphics.lineStyle(0, 0x808080);
		grip.graphics.beginFill(0xEEEEEE);
		grip.graphics.drawRect(0, 0, width, barHeight);
		grip.graphics.endFill();
		grip.buttonMode = true;
		
		
		
		minimazeButton.buttonMode = true;
		minimazeButton.x = width - barHeight;
		
		minimazeButton.graphics.lineStyle(0, 0x808080);
		minimazeButton.graphics.beginFill(0xDDDDDD);
		minimazeButton.graphics.drawRect(0, 0, barHeight, barHeight);
		minimazeButton.graphics.endFill();
		
		minimazeButton.graphics.beginFill(0xC0C0C0);
		minimazeButton.graphics.drawRect(4, 4, barHeight - 8, 4);
		
		
		
		tf.width = width;
		tf.height = height-barHeight;
		tf.y = barHeight;
		tf.multiline = true;
		
		caption.width = width - barHeight;
		caption.height = barHeight;
		caption.selectable = false;
		var fmt:TextFormat = new TextFormat("_sans", 11, 0x000000);
		fmt.align = TextFormatAlign.LEFT;
		caption.defaultTextFormat = fmt;
		caption.text = "output";
		caption.mouseEnabled = false;
		grip.addChild(caption);
		
		
		addChild(body);
		addChild(tf);
		addChild(grip);
		grip.addChild(minimazeButton);
		
		grip.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		minimazeButton.addEventListener(MouseEvent.CLICK, onCloseButClick);
		
		var consolMenu:ContextMenu = new ContextMenu();
		
		var clearItem:ContextMenuItem = new ContextMenuItem("clear output");
		clearItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onClearItem);
		consolMenu.hideBuiltInItems();
		consolMenu.customItems = [clearItem];
		grip.contextMenu = consolMenu;
		
	}
	
	private function onClearItem(event:ContextMenuEvent):void 
	{
		Console.clear();
	}
	
	
	
	private function onCloseButClick(evnt:MouseEvent):void 
	{
		tf.visible = !tf.visible;
		body.visible = tf.visible;
		minimazeButton.graphics.clear();
		minimazeButton.graphics.lineStyle(0, 0x808080);
		minimazeButton.graphics.beginFill(0xDDDDDD);
		minimazeButton.graphics.drawRect(0, 0, barHeight, barHeight);
		minimazeButton.graphics.endFill();
		
		minimazeButton.graphics.beginFill(0xC0C0C0);
		minimazeButton.graphics.drawRect(4, 4, barHeight - 8, body.visible ? 4: barHeight - 8);
		
		
	}
	
	private function onMouseDown(evnt:MouseEvent):void 
	{
		startDrag();
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		parent.addChild(this);
	}
	
	private function onMouseUp(evnt:MouseEvent):void 
	{
		stopDrag();
		stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	}
}