package services {
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;
    import flash.net.URLRequest;

    public class SoundManager {

        private static var instance:SoundManager;

        private var channel:SoundChannel;
        private var soundEnabled:Boolean = true;
        private var volume:Number = 1.0;
        private var lastClickTime:Number = 0;
        private static const CLICK_DEBOUNCE_MS:Number = 250;

        private var mouseClick:Sound;
        private var jump:Sound;
        private var gameOver:Sound;

        // Private constructor to enforce singleton pattern
        public function SoundManager(enforcer:SingletonEnforcer) {

            mouseClick = new Sound(new URLRequest("../assets/sound/mouse_click.mp3"));
            jump       = new Sound(new URLRequest("../assets/sound/jump.mp3"));
            gameOver   = new Sound(new URLRequest("../assets/sound/game_over.mp3"));
        }

        // Singleton pattern 
        public static function getInstance():SoundManager {
            if (!instance) {
                instance = new SoundManager(new SingletonEnforcer());
            }
            return instance;
        }

        public function loadFromSettings():void {
            var settings:Object = DataManager.getInstance().getCurrentSettings();

            if (settings && settings.audio) {
                soundEnabled = settings.audio.sound;
                volume = settings.audio.volume / 100;
            }
        }

        private function play(sound:Sound):void {
            if (!soundEnabled) return;

            channel = sound.play();
            applyVolume();
        }

        private function applyVolume():void {
            if (channel) {
                channel.soundTransform = new SoundTransform(volume);
            }
        }

        public function mouseClickEffect():void {
            var now:Number = new Date().time;
            if (now - lastClickTime < CLICK_DEBOUNCE_MS) {
                return;
            }
            lastClickTime = now;
            play(mouseClick);
        }

        public function jumpEffect():void {
            play(jump);
        }

        public function gameOverEffect():void {
            play(gameOver);
        }

        public function enableSounds():void {
            soundEnabled = true;
        }

        public function disableSounds():void {
            soundEnabled = false;

            if (channel) {
                channel.stop();
                channel = null;
            }
        }

        public function isSoundEnabled():Boolean {
            return soundEnabled;
        }

        public function setVolume(value:Number):void {
            // Ensure volume is between 0 and 1
            volume = Math.max(0, Math.min(1, value));
            applyVolume();
        }

        public function syncWithSettings():void {
            loadFromSettings();
        }
    }
}

internal class SingletonEnforcer {}