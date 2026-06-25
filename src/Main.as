package {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	
	import modules.BaseScreen; 
	import model.ScreenNames;

	public class Main extends BaseScreen {

		public var logoBtn: MovieClip;
		
		// Animation settings
		private var direction: Number = 1;
		private var speed: Number = 0.3;
		private var distance: Number = 5;
		private var originalY: Number;

		public function Main() {
			super();

			trace("Main.as loaded");

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e: Event): void {
			// This similar calibration for remove assign space not used
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			logoBtn = getChildByName("logo_btn") as MovieClip;

			if (!logoBtn) {
				trace("Error: logo_btn not found.");
				return;
			}

			logoBtn.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			logoBtn.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);

			originalY = logoBtn.y;

			addEventListener(Event.ENTER_FRAME, moveButton);
			logoBtn.addEventListener(MouseEvent.CLICK, onClick);
		}

		private function moveButton(e: Event): void {
			logoBtn.y -= speed * direction;

			if (logoBtn.y <= originalY - distance) direction = -1;
			if (logoBtn.y >= originalY) direction = 1;
		}

		private function onClick(e: MouseEvent): void {

			removeEventListener(Event.ENTER_FRAME, moveButton);

			logoBtn.removeEventListener(MouseEvent.CLICK, onClick);

			openScreen(ScreenNames.LOADINGSCREEN);
		}
	}
}