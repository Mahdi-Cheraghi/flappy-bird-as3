package modules
{
    import flash.events.Event;
    import flash.media.SoundMixer;

    import modules.BaseScreen;
    import model.ScreenNames;
    import services.ConfigLoader;

    public class LoadingScreen extends BaseScreen
    {
  
        private var checking:Boolean = false;
        private var transitioned:Boolean = false;

        public function LoadingScreen()
        {
            super();
            addEventListener(Event.ADDED_TO_STAGE, init);
        }

        private function init(e:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);

            if (checking) return;
            checking = true;


            trace("Loading screen page loaded");

            ConfigLoader.getInstance().addEventListener(Event.COMPLETE, onConfigReady);

            ConfigLoader.getInstance().start();
        }

        private function onConfigReady(e: Event):void {
            trace("All config loaded");
            
            ConfigLoader.getInstance().removeEventListener(Event.COMPLETE, onConfigReady);
            addEventListener(Event.ENTER_FRAME, checkLastFrame);
        }

        private function checkLastFrame(e:Event):void
        {
            if (transitioned) return;

            if (currentFrame == totalFrames)
            {
                transitioned = true;

                removeEventListener(Event.ENTER_FRAME, checkLastFrame);

                stop();

                openScreen(ScreenNames.INTRO);
            }
        }
    }
}