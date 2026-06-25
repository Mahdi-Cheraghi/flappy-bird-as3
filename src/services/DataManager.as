package services {
    import flash.net.SharedObject;

    public class DataManager {
        private static var _instance:DataManager;

        private var _so:SharedObject;
        private var _currentUserId:String;
        private var _currentSettings:Object;
        private var _users:Array;
        private var _allUserSettings:Object;

        // Singleton pattern
        public static function getInstance():DataManager {
            if (!_instance)
                _instance = new DataManager();

            return _instance;
        }

        public function DataManager() {
            _so = SharedObject.getLocal("flappyBirdData", "/");
        }

        public function setUsers(data:Array):void {
            _users = data;
        }

        public function getUsers():Array {
            return _users;
        }

        public function getCurrentUser():Object {
            if (!_users || !_currentUserId) return null;

            for each (var user:Object in _users) {
                if (user.id == _currentUserId) {
                    return user;
                }
            }

            return null;
        }

        public function addUser(user:Object): void {
             if (!_users) {
                 _users = [];
             }

             _users.push(user);

             trace("user added");
             trace("total users =", _users.length);

             saveUsers();
        }

        public function updateUserName(userId:String, newName:String):void {
            for (var i:int = 0; i < _users.length; i++) {

                if (_users[i].id == userId) {

                    _users[i].name = newName;
                    saveUsers();
                    break;
                }
            }
        }

        public function setCurrentUserId(id:String):void {
            _currentUserId = id;

            if (!_allUserSettings) {
                _allUserSettings = _so.data.userSettings || {};
            }

            if (_currentUserId && _allUserSettings[_currentUserId]) {
                _currentSettings = _allUserSettings[_currentUserId];
            } else {
                _currentSettings = {};
            }

            _so.data.currentUserId = id;
            _so.flush();
        }

        public function get currentUserId():String {
            return _currentUserId;
        }

        public function removeUser(userId:String):void {
            for (var i:int = 0; i < _users.length; i++) {

                if (_users[i].id == userId) {

                    _users.splice(i, 1);
                    saveUsers();
                    break;
                }
            }
        }

        public function setCurrentSettings(data:Object):void {
            _currentSettings = data;

            if (!_allUserSettings) {
                _allUserSettings = {};
            }

            if (_currentUserId) {
                _allUserSettings[_currentUserId] = data;
            }

            _so.data.userSettings = _allUserSettings;
            _so.flush();
        }

        public function getCurrentSettings():Object {
            if (!_currentSettings) {
                _currentSettings = {};
            }
            return _currentSettings;
        }

        public function setAllUserSettings(data:Object):void {
            _allUserSettings = data;
        }

        public function getUserSettings(userId:String):Object {
            if (_allUserSettings && _allUserSettings[userId])
                return _allUserSettings[userId];

            return {};
        }

        public function saveUsers():void {
            _so.data.users = _users;
            _so.flush();
        }

        public function saveCurrentUserId():void {
            _so.data.currentUserId = _currentUserId;
            _so.flush();
        }

        public function loadCurrentUserId():Boolean {
            if (_so.data.currentUserId) {
                _currentUserId = _so.data.currentUserId;

                return true;
            }

            return false;
        }

        // Load users from SharedObject storage
        public function loadUsersFromStorage():Boolean {
            if (_so.data.users) {
                _users = _so.data.users;
                return true;
            }

            return false;
        }

        public function loadSettingsFromStorage():Boolean {
            if (_so.data.userSettings) {
                _allUserSettings = _so.data.userSettings;

                if (!_currentUserId) {
                    loadCurrentUserId();
                }

                if (_currentUserId && _allUserSettings[_currentUserId]) {
                    _currentSettings = _allUserSettings[_currentUserId];
                } else {
                    _currentSettings = {};
                }

                return true;
            }

            return false;
        }

        public function updateUserHighScore(score:int):void {

            if (!_users || !_currentUserId)
                return;

            for (var i:int = 0; i < _users.length; i++) {

                if (_users[i].id == _currentUserId) {

                    _users[i].highScore = score;

                    saveUsers();

                    break;
                }
            }
        }

        public function getBackgroundType():String {
            if (_currentSettings &&
                _currentSettings.game &&
                _currentSettings.game.backgroundType)
            {
                return _currentSettings.game.backgroundType;
            }

            return "night";
        }

        public function updateVolume(v:int):void {
            if (!_currentSettings.audio) _currentSettings.audio = {};
            _currentSettings.audio.volume = v;

            // Save the updated settings to the SharedObject
            if (_currentUserId) {
                _allUserSettings[_currentUserId] = _currentSettings;
                _so.data.userSettings = _allUserSettings;
                _so.flush();
            }
        }

        public function getUsersSortedByScore():Array {
            var arr:Array = _users.concat();

            arr.sortOn(
                "highScore",
                Array.NUMERIC | Array.DESCENDING
            );

            return arr;
        }
    }
}