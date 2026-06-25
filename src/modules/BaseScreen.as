package modules {
    import flash.display.MovieClip;
    import flash.display.Loader;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.SimpleButton;
    import flash.text.*;
    import flash.events.*;
    import flash.ui.Mouse;
    import flash.net.URLRequest;

    import services.TooltipManager;
    import services.DataManager;
    import services.MusicManager;
    import services.SoundManager;
    import model.ScreenNames;

    public class BaseScreen extends MovieClip {
        protected var loader:Loader;
        protected var currentSWF:String;
        protected  var btn:SimpleButton;
        protected var topTitle:TextField;
        protected var screenHost:DisplayObjectContainer;

        private var isLoaded:Boolean = false;
        private var tooltip: TooltipManager;
        
        public function BaseScreen() {
            super();

            addEventListener(Event.ADDED_TO_STAGE, onBaseAdded);
            addEventListener(Event.REMOVED_FROM_STAGE, onBaseRemoved);
        }

        private function onBaseAdded(e:Event):void {
            removeEventListener(Event.ADDED_TO_STAGE, onBaseAdded);

            menuBtn();
            initTopTitle();
            applyBackgroundTheme();

            // Load audio settings from DataManager in initialization
            MusicManager.getInstance().loadFromSettings();
            SoundManager.getInstance().loadFromSettings();
        }

        private function onBaseRemoved(e:Event):void {
            removeEventListener(Event.REMOVED_FROM_STAGE, onBaseRemoved);
            cleanupLoader();
        }

        protected function initTopTitle():void {
            topTitle = getChildByName("top_tile") as TextField;
        }

        protected function registerTooltips(target:DisplayObject, text:String):void {
            TooltipManager.getInstance(this).register(target, text);
        }

        protected function openScreen(name:String):void {
            var targetHost:DisplayObjectContainer = null;

            if (parent is Loader) {
                var parentLoader:Loader = parent as Loader;
                targetHost = parentLoader.parent as DisplayObjectContainer;

                if (targetHost && targetHost.contains(parentLoader)) {
                    targetHost.removeChild(parentLoader);
                }
            }

            if (!targetHost && parent is DisplayObjectContainer) {
                targetHost = parent as DisplayObjectContainer;
                if (targetHost.contains(this)) {
                    targetHost.removeChild(this);
                }
            }

            if (!targetHost && stage) {
                targetHost = stage as DisplayObjectContainer;
            }

            screenHost = targetHost || this;
            loadSWF(name);
        }

        protected function menuBtn():void { 
            btn = getChildByName("menu_btn") as SimpleButton;

            if (btn) {
                btn.removeEventListener(MouseEvent.CLICK, backToIntroFile);
                btn.addEventListener(MouseEvent.CLICK, backToIntroFile);
            } 
        }

        protected function onMouseOver(e:MouseEvent):void {
            Mouse.cursor = "button";
        }

        protected function onMouseOut(e:MouseEvent):void {
            Mouse.cursor = "auto";
        }

        protected function backToIntroFile(e:MouseEvent): void {
            e.stopImmediatePropagation();

            // disable menu button after click to prevent duplicate handling
            try {
                if (btn) {
                    btn.removeEventListener(MouseEvent.CLICK, backToIntroFile);
                    btn.mouseEnabled = false;
                }
            } catch (err:Error) {}

            SoundManager.getInstance().mouseClickEffect();
            openScreen(ScreenNames.INTRO)
        }

        protected function applyBackgroundTheme():void {

            var bg:MovieClip = getChildByName("bg") as MovieClip;

            if (!bg) {

                return;
            }

            var type:String = DataManager.getInstance().getBackgroundType();

            switch (type) {
                case "day":
                    bg.gotoAndStop(1);
                    topTitleStyle(0x000000);
                    break;
                
                case "night":
                    bg.gotoAndStop(2);
                    topTitleStyle(0xFFFFFF);
                    break;
                
                default:
                    trace("type is Unknown " + type);
                    break;
            }
        }

        protected function topTitleStyle(color:Number):void {
            if (!topTitle) {
                return;
            }

            var format:TextFormat = new TextFormat();
            format.color = color;

            topTitle.defaultTextFormat = format;
            topTitle.setTextFormat(format);
        }

        protected function loadSWF(name:String):void {
            if (!screenHost) {
                screenHost = stage || parent || this;
            }

            cleanupLoader();

            currentSWF = name;
            isLoaded = false;

            loader = new Loader();

            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
            loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);

            loader.load(new URLRequest(name + ".swf"));
        }

        // Cleans up the SWF loader
        protected function cleanupLoader():void {
            if (!loader) return;

            try {
                loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaded);
                loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
                loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);

                loader.unloadAndStop(true);
            } catch (e:Error) {}

            if (screenHost && screenHost.contains(loader)) {
                screenHost.removeChild(loader);
            } else if (contains(loader)) {
                removeChild(loader);
            }

            loader = null;
            screenHost = null;
        }

        protected function onSWFReady(content:DisplayObject):void {}

        private function onLoaded(e:Event):void {
            if (isLoaded) return;
            isLoaded = true;

            if (screenHost) {
                screenHost.addChild(loader);
            } else {
                addChild(loader);
            }

            onSWFReady(loader.content);
        }

        private function onError(e:IOErrorEvent):void {
            trace("SWF load error: " + e.text);
        }

        private function onProgress(e:ProgressEvent):void {
            var percent:Number = (e.bytesLoaded / e.bytesTotal) * 100;
            trace("Loading: " + percent.toFixed(2) + "%");
        }

        public function destroy():void {
            cleanupLoader();

            if (parent) {
                parent.removeChild(this);
            }
        }
    }
}