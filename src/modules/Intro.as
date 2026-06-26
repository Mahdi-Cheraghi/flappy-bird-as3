package modules {
    import flash.events.*;
    import flash.display.*;
    import flash.display.SimpleButton;
    import flash.utils.Dictionary;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    import flash.display.InteractiveObject;

    import model.ScreenNames;
    import modules.BaseScreen;
    import services.DataManager;
    import services.MusicManager;
    import services.SoundManager;

    public class Intro extends BaseScreen {
		private static var instanceCounter:int = 0;

        private var initialized:Boolean = false;
        private var uiReady:Boolean = false;
        private var buttonsInitialized:Boolean = false;
        private var lockUI:Boolean = false;
        private var currentBackBtnName:String;

        public var userGuideBtn:MovieClip;
        public var startBtn:SimpleButton;
        public var rankingBtn:SimpleButton;
        public var settingsBtn:MovieClip;
        public var userPanelBtn:MovieClip;
        public var infoBtn:MovieClip;
        public var githubBtn:SimpleButton;
        public var linkedinBtn:SimpleButton;
        public var telegramBtn:SimpleButton;
        public var twitterBtn:SimpleButton;

        public function Intro() {
            trace("Intro.as loaded");

			trace("Constructor => " + this);

            addEventListener(Event.ADDED_TO_STAGE, init);
            
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
        }

        private function init(e:Event):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);

            if (initialized) return;
            initialized = true;

			instanceCounter++;

    		trace("Instance => " + this);

            hiddenObject();
            MusicManager.getInstance().playMusic();

            addEventListener(Event.ENTER_FRAME, waitForUIReady);
        }

        private function initUIComponents():void {
            userGuideBtn = getChildByName("user_guide_btn") as MovieClip;
            infoBtn = getChildByName("info_btn") as MovieClip;
            settingsBtn = getChildByName("settings_btn") as MovieClip;
            userPanelBtn = getChildByName("users_panel_btn") as MovieClip;
            startBtn = getChildByName("start_btn") as SimpleButton;
            rankingBtn = getChildByName("ranking_btn") as SimpleButton;
        }

        private function waitForUIReady(e:Event):void {
            if (!stage) return;

            var start:DisplayObject = getChildByName("start_btn");
            var info:DisplayObject = getChildByName("info_btn");
            var guide:DisplayObject = getChildByName("user_guide_btn");

            if (start && info && guide &&
                start.stage && info.stage && guide.stage) {
                removeEventListener(Event.ENTER_FRAME, waitForUIReady);

                uiReady = true;

                initUIComponents();

                updateIconFrame(userGuideBtn);
                updateIconFrame(infoBtn);
                updateIconFrame(settingsBtn);
                updateIconFrame(userPanelBtn);

                keepLookingForButtons();

                onClickTooltip();
            }
        }

        private function onClickTooltip():void {
            registerTooltips(userGuideBtn, "User Guide");
            registerTooltips(infoBtn, "Info");
            registerTooltips(settingsBtn, "Settings");
            registerTooltips(userPanelBtn, "Account");

            registerTooltips(startBtn, "Play Game");
            registerTooltips(rankingBtn, "Ranking");
        }

        private function hiddenObject():void {
            var hiddenLabels:Array = [
                "info_label",
                "ok_btn_in_info",
                "user_guide_label",
                "ok_btn_in_user_guide",
                "github_btn",
                "linkedin_btn",
                "telegram_btn",
                "twitter_btn"
            ];

            for each (var name:String in hiddenLabels) {
                var obj:DisplayObject = getChildByName(name);
                if (obj) obj.visible = false;
            }
        }

        private function keepLookingForButtons():void {
            if (!uiReady || buttonsInitialized) return;

            var introButtons:Array = [
                "user_guide_btn", 
                "info_btn", 
            ];

            var sceneButtons:Array = [
                "start_btn",
                "ranking_btn",
                "settings_btn", 
                "users_panel_btn"
            ];

            var allReady:Boolean = true;

            for each (var n:String in introButtons.concat(sceneButtons)) {
                if (!getChildByName(n)) {
                    allReady = false;
                    break;
                }
            }

            if (!allReady) return;

            buttonsInitialized = true;


            for each (var introBtn:String in introButtons) {
                var b1:InteractiveObject = getChildByName(introBtn) as InteractiveObject;

                if (b1) {
                    b1.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			        b1.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
                    b1.addEventListener(MouseEvent.CLICK, showLabel);
                }
            }

            for each (var sceneBtn:String in sceneButtons) {
                var b2:InteractiveObject = getChildByName(sceneBtn) as InteractiveObject;

                if (b2) {
                    b2.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			        b2.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
                    b2.addEventListener(MouseEvent.CLICK, onClickButton);
                }
            }
        }

        private function disableAllButtons(except:String):void {
            var all:Array = [
                "user_guide_btn",
                "info_btn",
                "start_btn",
                "ranking_btn",
                "settings_btn",
                "users_panel_btn"
            ];

            for each (var n:String in all) {
                var b:InteractiveObject = getChildByName(n) as InteractiveObject;

                if (!b) continue;

                if (n == except) continue;

                b.mouseEnabled = false;
            }
        }

        private function enableAllButtons():void {
            var all:Array = [
                "user_guide_btn",
                "info_btn",
                "start_btn",
                "ranking_btn",
                "settings_btn",
                "users_panel_btn"
            ];

            for each (var n:String in all) {
                var b:InteractiveObject = getChildByName(n) as InteractiveObject;

                if (!b) continue;

                b.mouseEnabled = true;
            }
        }

        private function showLabel(e:MouseEvent):void {
            if (lockUI) return;

            var btn:InteractiveObject = e.currentTarget as InteractiveObject;
            var name:String = btn.name;

            if (name == "info_btn") {
                disableAllButtons("ok_btn_in_info");
                lockUI = true;

                var infoLabel:DisplayObject = getChildByName("info_label");
                if (infoLabel) infoLabel.visible = true;

                var allInfoBtn:Array = [
                    "ok_btn_in_info",
                    "github_btn",
                    "linkedin_btn",
                    "telegram_btn",
                    "twitter_btn"
                ]

                for each (var j:String in allInfoBtn) {
                    var infoBtn:SimpleButton = getChildByName(j) as SimpleButton;
                    if (infoBtn) infoBtn.visible = true;
                }

                currentBackBtnName = "ok_btn_in_info";
                socialMedia();
            }
            else if (name == "user_guide_btn") {
                disableAllButtons("ok_btn_in_user_guide");
                lockUI = true;

                var guideLabel:DisplayObject = getChildByName("user_guide_label");
                if (guideLabel) guideLabel.visible = true;

                var guideBtn:SimpleButton = getChildByName("ok_btn_in_user_guide") as SimpleButton;
                if (guideBtn) guideBtn.visible = true;

                currentBackBtnName = "ok_btn_in_user_guide";
            }

            SoundManager.getInstance().mouseClickEffect();
            setupSceneBackBtn();
        }

        private function setupSceneBackBtn():void {
            addEventListener(Event.ENTER_FRAME, findBackBtn);
        }

        private function findBackBtn(e:Event):void {
            var btn:SimpleButton = getChildByName(currentBackBtnName) as SimpleButton;

            if (btn) {
                btn.removeEventListener(MouseEvent.CLICK, goBackToIntro);
                btn.addEventListener(MouseEvent.CLICK, goBackToIntro);
                removeEventListener(Event.ENTER_FRAME, findBackBtn);
            }
        }

        private function goBackToIntro(e:MouseEvent):void {
            SoundManager.getInstance().mouseClickEffect();
            hiddenObject();

            lockUI = false;

            enableAllButtons();
        }
        

        private var buttonLinks:Dictionary = new Dictionary(true);

        private function socialMedia():void {
            var socialBtn:Object = {
                github_btn: "https://github.com/Mahdi-Cheraghi",
                linkedin_btn: "https://www.linkedin.com/in/mahdicheraghi/",
                telegram_btn: "https://t.me/mahdicheraghi_info",
                twitter_btn: "https://x.com/MahdiCheraghi_"
            }

            for (var btnName:String in socialBtn) {

                var url:String = socialBtn[btnName];
                var btn:SimpleButton = getChildByName(btnName) as SimpleButton;
    
                if (btn) {
                    buttonLinks[btn] = url;
                    btn.addEventListener(MouseEvent.CLICK, onClickSocial);
                }
            }
        }

        private function onClickSocial(e:MouseEvent):void {
            var url:String = buttonLinks[e.currentTarget];
            navigateToURL(new URLRequest(url), "_blank");
            SoundManager.getInstance().mouseClickEffect();
        }

        private function onClickButton(e:MouseEvent):void {
            e.stopImmediatePropagation();
            e.stopPropagation();

            var btn:InteractiveObject = e.currentTarget as InteractiveObject;
            var name:String = btn.name;

            btn.removeEventListener(MouseEvent.CLICK, onClickButton);

            switch (name) {
                case "start_btn":
                    openScreen(ScreenNames.GAMEPLAY);
                    break;

                case "ranking_btn":
                    openScreen(ScreenNames.RANKING);
                    break;

                case "settings_btn":
                    openScreen(ScreenNames.SETTINGS);
                    break;

                case "users_panel_btn":
                    openScreen(ScreenNames.ACCOUNT);
                    break;
            }
            // play click sound only once per button press
            SoundManager.getInstance().mouseClickEffect();
        }

		private function onRemoved(e:Event):void {
            removeEventListener(Event.ENTER_FRAME, waitForUIReady);

            var allButtons:Array = [
                "user_guide_btn",
                "info_btn",
                "start_btn",
                "ranking_btn",
                "settings_btn",
                "users_panel_btn",
                "ok_btn_in_info",
                "ok_btn_in_user_guide",
                "github_btn",
                "linkedin_btn",
                "telegram_btn",
                "twitter_btn"
            ];

            for each (var btnName:String in allButtons) {
                var btn:InteractiveObject = getChildByName(btnName) as InteractiveObject;
                if (btn) {
                    btn.removeEventListener(MouseEvent.CLICK, showLabel);
                    btn.removeEventListener(MouseEvent.CLICK, onClickButton);
                    btn.removeEventListener(MouseEvent.CLICK, goBackToIntro);
                    btn.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
                    btn.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
                }
            }

            for (var target:Object in buttonLinks) {
                if (target is InteractiveObject) {
                    InteractiveObject(target).removeEventListener(MouseEvent.CLICK, onClickSocial);
                }
            }

            buttonLinks = new Dictionary(true);
		}

        private function updateIconFrame(btn:MovieClip):void {
            if (!btn) return;

            var theme:String = DataManager.getInstance().getBackgroundType();

            if (theme == 'day') {
                btn.gotoAndStop(1);
            } else {
                btn.gotoAndStop(2);
            }
        }
    }
}