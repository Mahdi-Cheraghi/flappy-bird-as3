package services {
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;
    import flash.net.URLRequest;

    public class MusicManager {

        private static var instance:MusicManager;

        private var bgMusic:Sound;
        private var channel:SoundChannel;
        private var musicEnabled:Boolean = true;
        private var volume:Number = 1.0;
        private var position:Number = 0;
        private var isPlaying:Boolean = false;

        public function MusicManager(enforcer:SingletonEnforcer) {

            bgMusic = new Sound(
                new URLRequest("../assets/sound/background.mp3")
            );

            loadFromSettings();
        }

        // singleton pattern
        public static function getInstance():MusicManager {
            if (!instance) {
                instance = new MusicManager(new SingletonEnforcer());
            }
            return instance;
        }

        public function loadFromSettings():void {
            var settings:Object = DataManager.getInstance().getCurrentSettings();

            if (settings && settings.audio) {
                musicEnabled = settings.audio.music;
                volume = settings.audio.volume / 100;
            }
        }

        public function syncWithSettings():void {
            loadFromSettings();
        }

        public function playMusic():void {
            if (!musicEnabled) return;

            if (channel) return;

            channel = bgMusic.play(position, int.MAX_VALUE);

            applyVolume();

            isPlaying = true;
        }

        public function pauseMusic():void {
            musicEnabled = false;

            if (channel) {
                position = channel.position;
                channel.stop();
                channel = null;
            }

            isPlaying = false;
        }

        public function resumeMusic():void {
            musicEnabled = true;

            if (channel) return;

            channel = bgMusic.play(position, int.MAX_VALUE);
            applyVolume();

            isPlaying = true;
        }

        public function enableMusic():void {
            musicEnabled = true;
            resumeMusic();
        }

        public function disableMusic():void {
            pauseMusic();
        }

        public function isMusicEnabled():Boolean {
            return musicEnabled;
        }


        public function setVolume(value:Number):void {
            volume = Math.max(0, Math.min(1, value));
            applyVolume();
        }

        private function applyVolume():void {
            if (channel) {
                channel.soundTransform = new SoundTransform(volume);
            }
        }

        public function restartMusic():void {
            // Reset the position to the beginning of the track
            position = 0;
        
            if (channel) {
                channel.stop();
                channel = null;
            }

            playMusic();
        }
    }
}

internal class SingletonEnforcer {}