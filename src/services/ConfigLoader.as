package services {
    import flash.events.Event;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.events.IOErrorEvent;
    import flash.events.EventDispatcher;

    import services.DataManager;

    public class ConfigLoader extends EventDispatcher {

        private static var _instance:ConfigLoader;

        // Singleton pattern
        public static function getInstance():ConfigLoader {
            if (!_instance)
                _instance = new ConfigLoader();

            return _instance;
        }

        public function ConfigLoader() {
            super();
        }

        public function start():void {
            loadDefaultConfig();
        }

        public function loadDefaultConfig():void {
            var loader:URLLoader = new URLLoader();

            loader.addEventListener(Event.COMPLETE, onDefaultConfigLoaded);

            loader.load(new URLRequest("../data/config.json"));
        }

        public function onDefaultConfigLoaded(e:Event):void {
            var loader:URLLoader = e.currentTarget as URLLoader;

            var config:Object = JSON.parse(loader.data);

            initializeData(config);

            // Dispatch an event to notify that the configuration has been loaded
            dispatchEvent(new Event(Event.COMPLETE));
        }

        private function getDefaultSettings():Object {
            return {
                audio: {
                    volume: 60,
                    music: true,
                    sound: true
                },
                game: {
                    backgroundType: "day",
                    birdType: "yellow",
                    pipeType: "green"
                }
            };
        }

        // if it's the first time the game is run, initialize the data with default settings
        private function initializeData(config:Object):void {
        
            var dm:DataManager =
                DataManager.getInstance();

            if (!dm.loadUsersFromStorage()) {
            
                var firstUser:Object = {
                    id:"1",
                    name:"Player 1",
                    highScore:0
                };

                dm.setUsers([firstUser]);

                dm.setCurrentUserId(firstUser.id);

                dm.setAllUserSettings({});

                dm.setCurrentSettings(mergeDefaults(config));

                dm.saveUsers();
                dm.saveCurrentUserId();
            }

            else {
            
                dm.loadCurrentUserId();
                dm.loadSettingsFromStorage();

                trace("Loaded From SharedObject");
            }
        }

        // Merge the default settings with the loaded configuration
        private function mergeDefaults(config:Object):Object {
            var defaults:Object = getDefaultSettings();

            if (!config.audio) config.audio = defaults.audio;
            if (!config.game) config.game = defaults.game;
            if (!config.ui) config.ui = defaults.ui;

            return config;
        }

        private function onUsersError(e:IOErrorEvent):void {
            trace("Users Load Error => " + e.text);
        }
    }     
}
