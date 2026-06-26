package modules {
	import flash.display.*;
	import flash.events.*;
	import flash.utils.Timer;
	import flash.text.*;

	import modules.BaseScreen;
	import services.DataManager;
	import services.SoundManager;
	import services.MusicManager;

	public class Settings extends BaseScreen {

		public var alertText:TextField;
		public var musicToggle: MovieClip;
		public var soundToggle: MovieClip; 
		public var backgroundButton: MovieClip;
		public var birdColorToggle: MovieClip;
		public var pipeColorToggle: MovieClip;
		public var volumeVar: TextField;
		public var incrementVolumeBtn: SimpleButton;
		public var decrementVolumeBtn: SimpleButton;
		public var resetBtn: SimpleButton;

		private var resetAccept:Boolean = false;
		private var alertTimer:Timer;

		public function Settings() {
			super();

			addEventListener(Event.ADDED_TO_STAGE, init);

			trace("Settings.as loaded");
		}

		private function init (e: Event): void {
			removeEventListener(Event.ADDED_TO_STAGE, init);

			initUIComponents();
			loadSettings();
			initAlert();
			stopAllAnimations();
			setupUIListeners();
		}

		// Load settings from DataManager and apply them to the UI components
		private function loadSettings():void {
			var dm:DataManager = DataManager.getInstance();
			var settings:Object = dm.getCurrentSettings();

			if (!settings) return;

			applySettings(settings);
		}

		private function initUIComponents():void {
			musicToggle = getChildByName("music_toggle") as MovieClip;
			backgroundButton = getChildByName("background_toggle") as MovieClip;
			soundToggle = getChildByName("sound_toggle") as MovieClip;
			birdColorToggle = getChildByName("bird_color_toggle") as MovieClip;
			pipeColorToggle = getChildByName("pipe_color_toggle") as MovieClip;
			volumeVar = getChildByName("volume_value") as TextField;
			incrementVolumeBtn = getChildByName("plus_btn") as SimpleButton;
			decrementVolumeBtn = getChildByName("minus_btn") as SimpleButton;
			resetBtn = getChildByName("reset_btn") as SimpleButton;

			// mouse over and mouse out event listeners for UI components to provide visual feedback
			musicToggle.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			musicToggle.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			backgroundButton.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			backgroundButton.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			soundToggle.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			soundToggle.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			birdColorToggle.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			birdColorToggle.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			pipeColorToggle.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			pipeColorToggle.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			volumeVar.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			volumeVar.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}

		private function initAlert():void {
			alertText = getChildByName("alert_text") as TextField;

			hideAlert();
		}

		// Stop all animations for the UI components to ensure they are in a consistent state
		private function stopAllAnimations():void {
			musicToggle.stop();
			soundToggle.stop();
			backgroundButton.stop();
			birdColorToggle.stop();
			pipeColorToggle.stop();
		}

		private function setupUIListeners():void {
			musicToggle.addEventListener(MouseEvent.CLICK, onClickIcon);
			soundToggle.addEventListener(MouseEvent.CLICK, onClickIcon);
			backgroundButton.addEventListener(MouseEvent.CLICK, onClickIcon);
			birdColorToggle.addEventListener(MouseEvent.CLICK, onClickIcon);
			pipeColorToggle.addEventListener(MouseEvent.CLICK, onClickIcon);
			incrementVolumeBtn.addEventListener(MouseEvent.CLICK, onClickIcon);
			decrementVolumeBtn.addEventListener(MouseEvent.CLICK, onClickIcon);
			resetBtn.addEventListener(MouseEvent.CLICK, onClickIcon);
		}

		private function onClickIcon(e:MouseEvent):void {

			var btnMC:MovieClip = e.currentTarget as MovieClip;
			var btnName:String = e.currentTarget.name;

			if (btnMC) {

				if (btnMC.currentFrame == btnMC.totalFrames) {
					btnMC.gotoAndStop(1);
				} else {
					btnMC.gotoAndStop(btnMC.currentFrame + 1);
				}

				switch(btnName) {

					case "music_toggle":

						if (btnMC.currentFrame == 1)
							enableMusic();
						else
							disableMusic();

						break;

					case "sound_toggle":

						if (btnMC.currentFrame == 1)
							enableSound();
						else
							disableSound();

						break;

					case "background_toggle":

						if (btnMC.currentFrame == 1)
							enableDayBackground();
						else
							enableNightBackground();

						break;

					case "bird_color_toggle":

						switch(btnMC.currentFrame) {

							case 1:
								setBirdType("blue");
								break;

							case 2:
								setBirdType("red");
								break;

							case 3:
								setBirdType("yellow");
								break;
						}

						break;

					case "pipe_color_toggle":

						if (btnMC.currentFrame == 1)
							setPipeType("green");
						else
							setPipeType("red");

						break;

				}
			}

			switch(btnName) {

				case "plus_btn":
					incrementVolume();
					break;

				case "minus_btn":
					decrementVolume();
					break;

				case "reset_btn":
					resetSettings();
					break;
			}

			if (btnName != "plus_btn" && btnName != "minus_btn") {
				playSoundEffect();
			}
		}
	
		private function alertAction(msg:String):void {
			alertStyle();

			alertText.text = "";
			alertText.text = msg;

			showAlert();
		}

		private function alertStyle():void {

			alertText.autoSize = TextFieldAutoSize.CENTER;

			alertText.background = true;
			alertText.backgroundColor = 0x10b222;
			
			alertText.textColor = 0xFFFFFF;
		}

		private function showAlert():void {
			if (!alertText) return;

			alertText.visible = true;
			
			if (alertTimer) {
				alertTimer.stop();
				alertTimer.reset();
			} else {
				alertTimer = new Timer(4000, 1); // milliseconds, repeatCount
				alertTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onAlertTimerComplete);
			}

			alertTimer.start();
		}

		private function onAlertTimerComplete(e:TimerEvent):void {
			hideAlert();
		}

		private function hideAlert(e:MouseEvent = null) {
			alertText.visible = false;
		}

		private function enableMusic():void {

			var dm:DataManager = DataManager.getInstance();
			var settings:Object = dm.getCurrentSettings();

			if (!settings.audio) settings.audio = {};

			settings.audio.music = true;

			dm.setCurrentSettings(settings);

			MusicManager.getInstance().enableMusic();
		}

		private function disableMusic():void {

			var dm:DataManager = DataManager.getInstance();
			var settings:Object = dm.getCurrentSettings();
			
			if (!settings.audio) settings.audio = {};
			
			settings.audio.music = false; 
			
			dm.setCurrentSettings(settings);

			MusicManager.getInstance().disableMusic();
		}

		private function enableSound():void {

			var dm:DataManager = DataManager.getInstance();
			var settings:Object = dm.getCurrentSettings();
			
			if (!settings.audio) settings.audio = {};
			
			settings.audio.sound = true;
			
			dm.setCurrentSettings(settings);

			SoundManager.getInstance().enableSounds();
		}

		private function disableSound():void {

			var dm:DataManager = DataManager.getInstance();
			var settings:Object = dm.getCurrentSettings();
			
			if (!settings.audio) settings.audio = {};
			
			settings.audio.sound = false; 
			
			dm.setCurrentSettings(settings);

			SoundManager.getInstance().disableSounds();
		}

		private function incrementVolume(): void {

			playSoundEffect();

			var currentVolume: int = int(volumeVar.text);
			var vol:Number = currentVolume / 100;

			if (currentVolume < 100) {
				currentVolume += 10;
				volumeVar.text = String(currentVolume);

				var dm:DataManager = DataManager.getInstance();
				var settings:Object = dm.getCurrentSettings();

				if (!settings.audio) settings.audio = {};
				settings.audio.volume = currentVolume;

				dm.setCurrentSettings(settings);

				MusicManager.getInstance().setVolume(vol);
				SoundManager.getInstance().setVolume(vol);
			}
		} 

		private function decrementVolume(): void {

			playSoundEffect();

			var currentVolume: int = int(volumeVar.text);
			var vol:Number = currentVolume / 100;

			if (currentVolume > 0) {
				currentVolume -= 10;
				volumeVar.text = String(currentVolume);

				var dm:DataManager = DataManager.getInstance();
				var settings:Object = dm.getCurrentSettings();

				if (!settings.audio) settings.audio = {};
				settings.audio.volume = currentVolume;

				dm.setCurrentSettings(settings);

				MusicManager.getInstance().setVolume(settings.audio.volume / 100);
				SoundManager.getInstance().setVolume(settings.audio.volume / 100);
			}
		}

		private function enableDayBackground():void {

			var dm:DataManager = DataManager.getInstance();
			var settings:Object = dm.getCurrentSettings();

			if (!settings.game)
				settings.game = {};

			settings.game.backgroundType = "day";

			dm.setCurrentSettings(settings);

			applyBackgroundTheme();
		}

		private function enableNightBackground():void {

			var dm:DataManager = DataManager.getInstance();
			var settings:Object = dm.getCurrentSettings();

			if (!settings.game)
				settings.game = {};

			settings.game.backgroundType = "night";

			dm.setCurrentSettings(settings);

			applyBackgroundTheme();
		}

		private function setBirdType(type:String):void {

			var dm:DataManager = DataManager.getInstance();
			var settings:Object = dm.getCurrentSettings();

			if (!settings.game)
				settings.game = {};

			settings.game.birdType = type;

			dm.setCurrentSettings(settings);
		}

		private function setPipeType(type:String):void {

			var dm:DataManager = DataManager.getInstance();
			var settings:Object = dm.getCurrentSettings();

			if (!settings.game)
				settings.game = {};

			settings.game.pipeType = type;

			dm.setCurrentSettings(settings);
		}

		// Reset all settings to their default values and apply them to the UI components
		private function resetSettings():void {
			var dm:DataManager = DataManager.getInstance();

			var defaultSettings:Object = ({
				audio: { volume: 50, music: true, sound: true},
				game: {
					backgroundType: "day",
					birdType: "yellow",
					pipeType: "green"
				}
			});

			dm.setCurrentSettings(defaultSettings);

			applySettings(dm.getCurrentSettings());
			applyBackgroundTheme();
			alertAction("Reset settings successfully");
		}

		private function applySettings(settings:Object):void {
			if (!settings) return;

			MusicManager.getInstance().syncWithSettings();
			SoundManager.getInstance().syncWithSettings();

			if (settings.audio) {
				if (settings.audio.volume != null) {
					volumeVar.text = String(settings.audio.volume);
					var vol:Number = settings.audio.volume / 100;
					MusicManager.getInstance().setVolume(vol);
					SoundManager.getInstance().setVolume(vol);
				}

				if (settings.audio.music) {
					musicToggle.gotoAndStop(1);
					MusicManager.getInstance().enableMusic();
				} else {
					musicToggle.gotoAndStop(2);
					MusicManager.getInstance().disableMusic();
				}

				if (settings.audio.sound) {
					soundToggle.gotoAndStop(1);
					SoundManager.getInstance().enableSounds();
				} else {
					soundToggle.gotoAndStop(2);
					SoundManager.getInstance().disableSounds();
				}
			}

			if (settings.game) {
				if (settings.game.backgroundType == "day") {
					backgroundButton.gotoAndStop(1);
				} else {
					backgroundButton.gotoAndStop(2);
				}

				switch (settings.game.birdType) {
					case "blue":
						birdColorToggle.gotoAndStop(1);
						break;

					case "red":
						birdColorToggle.gotoAndStop(2);
						break;

					case "yellow":
						birdColorToggle.gotoAndStop(3);
						break;
				}

				switch (settings.game.pipeType) {
					case "green":
						pipeColorToggle.gotoAndStop(1);
						break;

					case "red":
						pipeColorToggle.gotoAndStop(2);
						break;
				}
			}
		}

		private function playSoundEffect(): void {
			SoundManager.getInstance().mouseClickEffect();
		}
	}
}

