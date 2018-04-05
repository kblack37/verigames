package display
{
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	
	public class ImageStateButton extends BasicButton
	{
		private var m_stateCount:uint;
		private var m_ups:Vector.<DisplayObject>;
		private var m_overs:Vector.<DisplayObject>;
		private var m_downs:Vector.<DisplayObject>;
		
		public function ImageStateButton(ups:Vector.<DisplayObject>, overs:Vector.<DisplayObject>, downs:Vector.<DisplayObject>)
		{
			m_stateCount = ups.length;
			
			var obj:DisplayObject;
			
			m_ups = ups;
			var up:Sprite = new Sprite();
			for each (obj in m_ups) {
				up.addChild(obj);
			}
			
			m_overs = overs;
			var over:Sprite = new Sprite();
			for each (obj in m_overs) {
				over.addChild(obj);
			}
			
			m_downs = downs;
			var down:Sprite = new Sprite();
			for each (obj in m_downs) {
				down.addChild(obj);
			}
			
			setState(0);
			
			super(up, over, down);
		}
		
		protected function setState(st:uint):void
		{
			for (var ii:uint = 0; ii < m_stateCount; ++ ii) {
				var visible:Boolean = (st == ii);
				
				m_ups[ii].visible = visible;
				m_overs[ii].visible = visible;
				m_downs[ii].visible = visible;
			}
		}
	}
}
