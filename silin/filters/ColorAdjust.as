
/*
 
  The MIT License, 
 
  Copyright (c) 2011. silin (http://silin.su#AS3)
 
*/
package  silin.filters
{

	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	/**
	 * ColorMatrixFilter с методами установоки расхожих параметров цветности <br>
	 * 
	 * @author silin
	 */
	public class ColorAdjust
	{
		
		// RGB to Luminance conversion constants 
		private static const R_LUM:Number = 0.212671;
		private static const G_LUM:Number = 0.715160;
		private static const B_LUM:Number = 0.072169;
		//че-то они разные в разных источниках.., надо бы разобраться
		/*
		private static var R_LUM:Number = 0.3086;
		private static var G_LUM:Number = 0.6094;
		private static var B_LUM:Number = 0.0820;
		*/
		
		/*
		private static var R_LUM:Number = 0.3;
		private static var G_LUM:Number = 0.59;
		private static var B_LUM:Number = 0.11;
		*/
		//режимы модификации _filter.matrix concat или создание нового							
		public static const ADD:String = "add";
		public static const CLEAR:String = "clear";
									
									
		private var _clearMode:Boolean;
		private var _filter:ColorMatrixFilter;
		private var _brightness:Number=0;
		private var _contrast:Number=0;
		private var _hue:Number=0;
		private var _saturation:Number=1;
		private var _alpha:Number=1;
		private var _tintAmount:Number = 0.35;
		private var _tintColor:Number = 0;
		private var _threshold:Number = 0;
		
		private var _colorizeColor:Number;
		private var _colorizeAmount:Number;
		
		/**
		 * constructor
		 * @param	mode	режим изменения параметров ADD | CLEAR (добавление или обновление)
		 */
		function ColorAdjust ( mode:String = ADD )
		{
			
			_filter = new ColorMatrixFilter();
			this.mode = mode;
			reset();
		}
		
		
		/**
		 * сброс параметров
		 */
		public function reset():void
		{
			_filter.matrix=[	1, 0, 0, 0, 0,
								0, 1, 0, 0, 0,
								0, 0, 1, 0, 0,
								0, 0, 0, 1, 0];
		}
		/**
		 * 
		 * @param	rgb		24-битный цвет подкраски
		 * @param	amount	величина подкраски, 0..1
		 */
		public function colorize ( rgb:Number, amount:Number=1):void
		{
			_colorizeColor = rgb;
			_colorizeAmount = amount;
			
			var r:Number = ( ( rgb >> 16 ) & 0xff ) / 255;
			var g:Number = ( ( rgb >> 8  ) & 0xff ) / 255;
			var b:Number = (   rgb         & 0xff ) / 255;
			
			var inv_amount:Number = 1 - amount;
			
			var mtrx:Array =  [ inv_amount + amount*r*R_LUM, amount*r*G_LUM,  amount*r*B_LUM, 0, 0,
								amount*g*R_LUM, inv_amount + amount*g*G_LUM, amount*g*B_LUM, 0, 0,
								amount*b*R_LUM,amount*b*G_LUM, inv_amount + amount*b*B_LUM, 0, 0,
								0, 0, 0, 1, 0 ];
		
			setMatrix(mtrx);
		}
		/**
		 * 
		 * @param	rgb		24-битный цвет оттенка
		 * @param	amount	величина,  0..1
		 */
		public function tint ( rgb:Number, amount:Number=0.35):void
		{
			_tintAmount = amount;
			_tintColor = rgb;
			
			var r:Number =  ( rgb >> 16 ) & 0xff;
			var g:Number =  ( rgb >> 8  ) & 0xff;
			var b:Number =    rgb         & 0xff;
			
			var inv_amount:Number = 1 - amount;
			
			var mtrx:Array =  [ inv_amount, 0, 0, 0, r * amount,
								0, inv_amount, 0, 0, g * amount,
								0, 0, inv_amount, 0, b * amount,
								0, 0, 0, 1, 0 ];
								
			setMatrix(mtrx);
		}
		/**
		 * инвертирует цвета
		 */
		public function invert():void
		{
			var mtrx:Array =  [ -1, 0, 0, 0, 255,
								0, -1, 0, 0, 255,
								0,  0, -1, 0, 255,
								0, 0, 0, 1, 0];
			
			setMatrix(mtrx);
		}
		/**
		 * установка оттенков сепии
		 */
		public function sepia():void
		{
			var mtrx:Array = [	0.3930000066757202, 0.7689999938011169, 0.1889999955892563, 0, 0, 
								0.3490000069141388, 0.6859999895095825, 0.1679999977350235, 0, 0, 
								0.2720000147819519, 0.5339999794960022, 0.1309999972581863, 0, 0, 
								0, 0, 0, 1,	0];
			setMatrix(mtrx);
		}
		
		
		private function concat(mtrx:Array):void
		{
			
			var temp:Array = [];
			var i:int = 0;
			var matrix:Array = _filter.matrix;
			for (var y:int = 0; y < 4; y++ )
			{
				
				for (var x:int = 0; x < 5; x++ )
				{
					temp[i + x] = 	mtrx[i    ] * matrix[x] + 
									mtrx[i+1] * matrix[x +  5] + 
									mtrx[i+2] * matrix[x + 10] + 
									mtrx[i+3] * matrix[x + 15] +
									(x == 4 ? mtrx[i+4] : 0);
				}
				i+=5;
			}
			_filter.matrix = temp;
			
		}
		
		private function setMatrix(mtrx:Array):void
		{
			if (_clearMode)
			{
				_filter.matrix = mtrx;
			}else
			{
				concat(mtrx);
			}
		}
		////////////////////////////
		public function get filter():flash.filters.ColorMatrixFilter { return _filter; }
		
		/**
		 * brightness, -1..1
		 */
		public function get brightness():Number { return _brightness; }
		
		public function set brightness(value:Number):void 
		{
			_brightness = value;
			var mtrx:Array = [	1, 0, 0, 0, 255*value,
								0, 1, 0, 0, 255*value,
								0, 0, 1, 0, 255*value,
								0, 0, 0, 1, 0 ];
							
			setMatrix(mtrx);
			
		}
		
		/**
		 * contrast, -1..1
		 */
		public function get contrast():Number { return _contrast; }
		
		public function set contrast(value:Number):void 
		{
			_contrast = value;
			value += 1;
			var mtrx:Array = [	value, 0, 0, 0, 128 * (1 - value),
								0, value, 0, 0, 128 * (1 - value),
								0, 0, value, 0, 128 * (1 - value),
								0, 0, 0, 1, 0];
			
			setMatrix(mtrx);
		}
		/**
		 * hue, 0..360
		 */
		public function get hue():Number { return _hue; }
		
		public function set hue(value:Number):void 
		{
			_hue = value;
			var angle:Number = value * Math.PI / 180;
				
			var c:Number = Math.cos( angle );
			var s:Number = Math.sin( angle );
			
			var f1:Number = 0.213;
			var f2:Number = 0.715;
			var f3:Number = 0.072;
			
			var mtrx:Array = [	(f1 + (c * (1 - f1))) + (s * ( -f1)), (f2 + (c * ( -f2))) + (s * ( -f2)), (f3 + (c * ( -f3))) + (s * (1 - f3)), 0, 0, (f1 + (c * ( -f1))) + (s * 0.143), (f2 + (c * (1 - f2))) + (s * 0.14), (f3 + (c * ( -f3))) + (s * -0.283), 0, 0, (f1 + (c * ( -f1))) + (s * ( -(1 - f1))), (f2 + (c * ( -f2))) + (s * f2), (f3 + (c * (1 - f3))) + (s * f3), 
								0, 0, 0, 0, 
								0, 1, 0, 0, 
								0, 0, 0, 1];
							
			setMatrix(mtrx);
		}
		/**
		 * saturation, 0..1
		 */
		public function get saturation():Number { return _saturation; }
		
		public function set saturation(value:Number):void 
		{
			
			_saturation = value;
			var amount:Number = 1 - value;
			
			var irlum:Number = amount * R_LUM;
			var iglum:Number = amount * G_LUM;
			var iblum:Number = amount * B_LUM;
			
			var mtrx:Array = [	irlum + value, iglum, iblum, 0, 0,
								irlum, iglum + value, iblum, 0, 0,
								irlum, iglum, iblum + value, 0, 0,
								0, 0, 0, 1, 0 ];
									
			setMatrix(mtrx);
		}
		/**
		 * threshold, 0..1
		 */
		public function get threshold():Number { return _threshold;}
		public function set threshold( value:Number ):void
		{
			_threshold = value;
			var mtrx:Array =  [	R_LUM * 256, G_LUM * 256, B_LUM * 256, 0,  -256 * value, 
			
								R_LUM * 256, G_LUM * 256,B_LUM * 256, 0,  -256 * value, 
										
								R_LUM * 256, G_LUM * 256, B_LUM * 256, 0,  -256 * value, 
									
								0, 0, 0, 1, 0]; 
										
			setMatrix(mtrx);
		}
		
		/**
		 * режим изменения матрицы при установке новых значений: CLEAR | ADD <br>
		 * абсолютные величины или конкатенция с текущием состоянием
		 */
		public function get mode():String { return _clearMode==CLEAR ? CLEAR : ADD; }
		
		public function set mode(value:String):void 
		{
			_clearMode = (value == CLEAR);
		}
		/**
		 * alpha, 0..1
		 */
		public function get alpha():Number { return _alpha; }
		public function set alpha(value:Number):void 
		{
			_alpha = value;
			var mtrx:Array =  [ 1, 0, 0, 0, 0,
							 0, 1, 0, 0, 0,
							 0, 0, 1, 0, 0,
							 0, 0, 0, value, 0 ];
			setMatrix(mtrx);
		}
		/**
		 * микширование по каналам 
		 * параметры: R|G|B|A (1|2|4|8)
		 * @param	r, 1..15
		 * @param	g, 1..15
		 * @param	b, 1..15
		 * @param	a, 1..15
		 */
		public function setChannels (r:int, g:int=0, b:int=0, a:int=0 ):void
		{
			var rf:Number =((r & 1) == 1 ? 1:0) + ((r & 2) == 2 ? 1:0) + ((r & 4) == 4 ? 1:0) + ((r & 8) == 8 ? 1:0); 
			if (rf > 0) rf = 1 / rf;
			var gf:Number =((g & 1) == 1 ? 1:0) + ((g & 2) == 2 ? 1:0) + ((g & 4) == 4 ? 1:0) + ((g & 8) == 8 ? 1:0); 
			if (gf > 0) gf = 1 / gf;
			var bf:Number =((b & 1) == 1 ? 1:0) + ((b & 2) == 2 ? 1:0) + ((b & 4) == 4 ? 1:0) + ((b & 8) == 8 ? 1:0); 
			if (bf > 0) bf = 1 / bf;
			var af:Number =((a & 1) == 1 ? 1:0) + ((a & 2) == 2 ? 1:0) + ((a & 4) == 4 ? 1:0) + ((a & 8) == 8 ? 1:0); 
			if (af > 0) af = 1 / af;
			
			var mtrx:Array =  [
				(r & 1) == 1 ? rf:0, (r & 2) == 2 ? rf:0, (r & 4) == 4 ? rf:0, (r & 8) == 8 ? rf:0, 0,
				(g & 1) == 1 ? gf:0, (g & 2) == 2 ? gf:0, (g & 4) == 4 ? gf:0, (g & 8) == 8 ? gf:0, 0,
				(b & 1) == 1 ? bf:0, (b & 2) == 2 ? bf:0, (b & 4) == 4 ? bf:0, (b & 8) == 8 ? bf:0, 0,
				(a & 1) == 1 ? af:0, (a & 2) == 2 ? af:0, (a & 4) == 4 ? af:0, (a & 8) == 8 ? af:0, 0
			];
			
			setMatrix(mtrx);
			
		}
		
		
		
		/*
		//не пригодились нигде
		//TINT
		public function get tintAmount():Number { return _tintAmount; }
		
		public function set tintAmount(value:Number):void 
		{
			_tintAmount = value;
			tint(_tintColor, _tintAmount);
			
		}
		
		public function get tintColor():Number { return _tintColor; }
		
		public function set tintColor(value:Number):void 
		{
			_tintColor = value;
			tint(_tintColor, _tintAmount);
		}
		
		//COLORIZE
		public function get colorizeColor():Number { return _colorizeColor; }
		
		public function set colorizeColor(value:Number):void 
		{
			_colorizeColor = value;
			colorize(_colorizeColor, _colorizeAmount);
		}
		
		public function get colorizeAmount():Number { return _colorizeAmount; }
		
		public function set colorizeAmount(value:Number):void 
		{
			_colorizeAmount = value;
			colorize(_colorizeColor, _colorizeAmount);
		}
		
		
		
	
		public function randomize( amount:Number=1 ):void
		{
			
			
			var inv_amount:Number = 1 - amount;
			
			var r1:Number = inv_amount +  amount * ( Math.random() - Math.random() );
			var g1:Number = amount     * ( Math.random() - Math.random() );
			var b1:Number = amount     * ( Math.random() - Math.random() );
			
			var o1:Number = amount * 255 * (Math.random() - Math.random());
			
			var r2:Number = amount     * ( Math.random() - Math.random() );
			var g2:Number = inv_amount +  amount * ( Math.random() - Math.random() );
			var b2:Number = amount     * ( Math.random() - Math.random() );
			
			var o2:Number = amount * 255 * (Math.random() - Math.random());
			
			
			var r3:Number = amount     * ( Math.random() - Math.random() );
			var g3:Number = amount     * ( Math.random() - Math.random() );
			var b3:Number = inv_amount +  amount * ( Math.random() - Math.random() );
			
			var o3:Number = amount * 255 * (Math.random() - Math.random());
			
			var mtrx:Array =  [	r1, g1, b1, 0, o1, 
										r2 ,g2, b2, 0, o2, 
										r3, g3, b3, 0, o3, 
										0 ,  0,  0, 1, 0 ]; 
			
			setMatrix(mtrx);
		}
		
		
		
		*/

		
	}
}