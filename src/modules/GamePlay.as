package modules {
    import flash.display.*;
    import flash.events.*;
    import flash.text.TextField;
    import fl.transitions.Tween;
    import fl.transitions.easing.Regular;
    import fl.transitions.TweenEvent;

    import modules.BaseScreen;
    import services.SoundManager;
    import services.DataManager;

    public class GamePlay extends BaseScreen {

        // Game physics variables setup
        private var velocityY: Number = 0;
        private var gravityY: Number = 1.0;
        private var jumpPower: Number = -11;
        private var groundY: Number = 687;
        private var ceilingY: Number = 21;
        private var pipeSpeed:Number = 3;
        private var pipeGap:Number = 300;
        private const PIPE_DISTANCE:Number = 300;

        private var currentInnerBird: MovieClip = null;
        private var isPlayingAnimation: Boolean = false;
        private var gameStarted:Boolean = false;
        private var gameOver:Boolean = false;
        var gotNewHighScore:Boolean = false;
        private var pipePassed1:Boolean = false;
        private var pipePassed2:Boolean = false;
        private var pipePassed3:Boolean = false;
        private var currentScore:int = 0;

        public var overlay: MovieClip;

        // UI elements for the game start modal
        public var flappyBirdText: MovieClip;
        public var getReadyText: MovieClip;
        public var tapIcon: MovieClip;

        // UI elements for the game over modal
        public var ground: MovieClip;
        public var topPipe1: MovieClip;
        public var bottomPipe1: MovieClip;
        public var topPipe2: MovieClip;
        public var bottomPipe2: MovieClip;
        public var topPipe3: MovieClip;
        public var bottomPipe3: MovieClip;
        public var mainBird: MovieClip;
        public var score: TextField;

        // UI elements for the game over modal
        public var medal: MovieClip;
        public var scoreResult: TextField;
        public var bestScore: TextField;
        public var okBtn: SimpleButton;
        public var gameOverText: MovieClip;
        public var gameOverCover: MovieClip;
        public var newRecord:MovieClip;

        public function GamePlay() {
            super();

            addEventListener(Event.ADDED_TO_STAGE, init);

            trace("Game play page loaded");
        }

        private function init(e: Event): void {
            removeEventListener(Event.ADDED_TO_STAGE, init);

            initOnGameStart();
            initOnGame();
            initOnGameOver();

            stopAllAnimations();

            initConfig();

            updateInnerBirdReference();

            onGameStart();
        }

        private function initConfig():void {
            var settings:Object = DataManager.getInstance().getCurrentSettings();

            if (!settings) return;

            applyBirdType(settings.game.birdType);
            applyPipeType(settings.game.pipeType);

            // load high score from DataManager and display it in the bestScore TextField
            loadHighScore();
        }

        private function onGameStart():void {
            gameStarted = false;
            gameOver = false;
            
            velocityY = 0;

            resetBirdPosition();

            showGameStartModal();
            showOverlay();

            hideGameModal();
            hideGameOverModal();

            setupGameStartListeners();
        }

        private function onGame(e:MouseEvent):void {
            stage.removeEventListener(MouseEvent.CLICK, onGame);
            
            gameStarted = true;

            hideOverlay();
            hideGameStartModal();
            showGameModal();
            
            velocityY = 0;

            setupGameListeners();

            currentScore = 0;
            score.text = "0";

            // Initialize pipe positions and reset their states
            topPipe1.x = 450;
            bottomPipe1.x = 450;

            topPipe2.x = topPipe1.x + PIPE_DISTANCE;
            bottomPipe2.x = topPipe2.x;

            topPipe3.x = topPipe2.x + PIPE_DISTANCE;
            bottomPipe3.x = topPipe3.x;

            // pipePassed flags are used to track if the bird has passed each pipe for scoring purposes
            pipePassed1 = false;
            pipePassed2 = false;
            pipePassed3 = false;
            
            addEventListener(Event.ENTER_FRAME, onPhysicsFrame);

            resetPipe(topPipe1, bottomPipe1);
            resetPipe(topPipe2, bottomPipe2);
            resetPipe(topPipe3, bottomPipe3);
        }

        private function onGameOver():void {
 
            scoreResult.text = String(currentScore);

            var user:Object = DataManager.getInstance().getCurrentUser();

            if (user) {

                var best:int = 0;

                if (user.hasOwnProperty("highScore")) {
                    best = int(user.highScore);
                }

                gotNewHighScore = false;

                if (currentScore > best) {
                    gotNewHighScore = true;
                    best = currentScore;
                    newRecord.visible = true;

                    DataManager.getInstance().updateUserHighScore(currentScore);

                } else {
                    newRecord.visible = false;
                }
                    
                bestScore.text = String(best);
            }

            // Determine the user's rank based on their score and display the appropriate medal if they are in the top 3
            var users:Array = DataManager.getInstance().getUsersSortedByScore();

            var rank:int = -1;

            if (!user || !users) return;

            for (var i:int = 0; i < users.length; i++) {
                if (users[i] && users[i].id == user.id) {
                    rank = i + 1;
                    break;
                }
            }

            medal.visible = false;

            if (rank == 1) {
                medal.visible = true;
                medal.gotoAndStop(1);
            }
            else if (rank == 2) {
                medal.visible = true;
                medal.gotoAndStop(2);
            }
            else if (rank == 3) {
                medal.visible = true;
                medal.gotoAndStop(3);
            }

            hideGameModal();
            showOverlay();
            showGameOverModal();

            setupGameOverListeners();
        }

        private function onMouseClick(e:MouseEvent):void {
            e.stopImmediatePropagation();
            
            if (gameOver) return;

            jumpUpBird();
            playFullAnimation();
            SoundManager.getInstance().jumpEffect();
        }

        private function onOkClick(e:MouseEvent):void {
            e.stopImmediatePropagation();

            // prevent duplicate handling by removing listener and disabling the button
            if (okBtn) {
                okBtn.removeEventListener(MouseEvent.CLICK, onOkClick);
                okBtn.mouseEnabled = false;
            }

            SoundManager.getInstance().mouseClickEffect();
            resetGame();
             
        }

        private function setupGameStartListeners():void {
            stage.removeEventListener(MouseEvent.CLICK, onGame);
            stage.addEventListener(MouseEvent.CLICK, onGame);
        }

        private function setupGameListeners():void {
            stage.removeEventListener(MouseEvent.CLICK, onMouseClick); 
            stage.addEventListener(MouseEvent.CLICK, onMouseClick); 
        }

        private function setupGameOverListeners():void {
            // ensure ok button is enabled and has a single click listener
            if (okBtn) {
                okBtn.mouseEnabled = true;
                okBtn.removeEventListener(MouseEvent.CLICK, onOkClick);
                okBtn.addEventListener(MouseEvent.CLICK, onOkClick);
            }

            okBtn.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
            okBtn.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);

            okBtn.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
            okBtn.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        }

        private function initOnGameStart():void {
            overlay = getChildByName("overlay") as MovieClip;
            flappyBirdText = getChildByName("flappy_bird_text") as MovieClip;
            getReadyText = getChildByName("get_ready_text") as MovieClip;
            tapIcon = getChildByName("tap_ico") as MovieClip;
        }

        private function initOnGame():void {
            ground = getChildByName("ground") as MovieClip;
            topPipe1 = getChildByName("topPipe1") as MovieClip;
            bottomPipe1 = getChildByName("bottomPipe1") as MovieClip;
            topPipe2 = getChildByName("topPipe2") as MovieClip;
            bottomPipe2 = getChildByName("bottomPipe2") as MovieClip;
            topPipe3 = getChildByName("topPipe3") as MovieClip;
            bottomPipe3 = getChildByName("bottomPipe3") as MovieClip;
            mainBird = getChildByName("bird") as MovieClip;
            score = getChildByName("score") as TextField;
        }

        private function initOnGameOver():void {
            overlay = getChildByName("overlay") as MovieClip;
            scoreResult = getChildByName("score_result") as TextField;
            bestScore = getChildByName("best_score") as TextField;
            medal = getChildByName("medal") as MovieClip;
            okBtn = getChildByName("ok_btn") as SimpleButton;
            gameOverText = getChildByName("game_over_text") as MovieClip;
            gameOverCover = getChildByName("game_over_cover") as MovieClip;
            newRecord = getChildByName("new_record") as MovieClip;
        }

        private function showGameStartModal():void {
            flappyBirdText.visible = true;
            getReadyText.visible = true;
            tapIcon.visible = true;

            bringToFront(overlay);
            bringToFront(flappyBirdText);
            bringToFront(getReadyText);
            bringToFront(tapIcon);
        }

        private function hideGameStartModal():void {
            flappyBirdText.visible = false;
            getReadyText.visible = false;
            tapIcon.visible = false;
        }

        private function showGameModal():void {
            score.visible = true;
        }

        private function hideGameModal():void {
            score.visible = false;
        }

        private function showGameOverModal():void {
            gameOverCover.visible = true;
            gameOverText.visible = true;
            scoreResult.visible = true;
            bestScore.visible = true;
            okBtn.visible = true;
            btn.visible = true;

            bringToFront(overlay);
            bringToFront(gameOverCover);
            bringToFront(gameOverText);
            bringToFront(scoreResult);
            bringToFront(bestScore);
            bringToFront(medal);
            bringToFront(okBtn);
            bringToFront(btn);
            bringToFront(newRecord);
        } 

        private function hideGameOverModal():void {
            gameOverCover.visible = false;
            gameOverText.visible = false;
            scoreResult.visible = false;
            bestScore.visible = false;
            medal.visible = false;
            okBtn.visible = false;
            btn.visible = false;
            newRecord.visible = false;
        }

        private function showOverlay():void {
            overlay.visible = true;
        }

        private function hideOverlay():void {
            overlay.visible = false;
        }

        private function stopAllAnimations():void {
            mainBird.stop();
            topPipe1.stop();
            bottomPipe1.stop();
            topPipe2.stop();
            bottomPipe2.stop();
            topPipe3.stop();
            bottomPipe3.stop();
            medal.stop();
        }

        private function bringToFront(target:DisplayObject):void {
            if (target && contains(target)) {
                setChildIndex(target, numChildren - 1);
            }
        }

        private function applyBirdType(type:String):void {
            switch(type) {
                case "red":
                    mainBird.gotoAndStop(1);
                    break;

                case "blue":
                    mainBird.gotoAndStop(2);
                    break;

                case "yellow":
                    mainBird.gotoAndStop(3);
                    break;
            }

            updateInnerBirdReference();
        }

        // Apply the selected pipe type to all pipe instances in the game
        private function applyPipeType(type:String):void {
            switch(type) {
                case "green":
                    topPipe1.gotoAndStop(1);
                    bottomPipe1.gotoAndStop(1);
                    topPipe2.gotoAndStop(1);
                    bottomPipe2.gotoAndStop(1);
                    topPipe3.gotoAndStop(1);
                    bottomPipe3.gotoAndStop(1);
                    break;

                case "red":
                    topPipe1.gotoAndStop(2);
                    bottomPipe1.gotoAndStop(2);
                    topPipe2.gotoAndStop(2);
                    bottomPipe2.gotoAndStop(2);
                    topPipe3.gotoAndStop(2);
                    bottomPipe3.gotoAndStop(2);
                    break;
            }
        }

        private function loadHighScore():void {
            var user:Object = DataManager.getInstance().getCurrentUser();

            if (!user) return;

            bestScore.text = String(user.highScore);
        }

        // Update the reference to the inner bird MovieClip based on the current main bird type
        private function updateInnerBirdReference(): void {
            if (mainBird != null) {
                currentInnerBird = mainBird.getChildAt(0) as MovieClip;

                if (currentInnerBird != null) {

                    currentInnerBird.stop();
                    currentInnerBird.gotoAndStop(1);
                    isPlayingAnimation = false;
                }
            }
        }

        private function jumpUpBird():void {
            velocityY = jumpPower;
        }

        private function jumpDownBird():void {
            velocityY += 5;
        }

        private function onPhysicsFrame(e:Event):void {
            if (mainBird == null) return;

            velocityY += gravityY;

            mainBird.y += velocityY;  

            movePipe(topPipe1, bottomPipe1);
            movePipe(topPipe2, bottomPipe2);
            movePipe(topPipe3, bottomPipe3);

           var birdBottom:Number = mainBird.y + 20;

           if (birdBottom >= getGroundTop() && !gameOver) {
                gameOver = true;

                removeEventListener(Event.ENTER_FRAME, onPhysicsFrame);

                hitGround();
           }

            if (mainBird.y <= ceilingY && !gameOver) {

                gameOver = true;
                removeEventListener(Event.ENTER_FRAME, onPhysicsFrame);

                hitCeiling();
            }  

            // Check for collisions between the main bird and any of the pipes
            if (
                mainBird.hitTestObject(topPipe1) ||
                mainBird.hitTestObject(bottomPipe1) ||

                mainBird.hitTestObject(topPipe2) ||
                mainBird.hitTestObject(bottomPipe2) ||

                mainBird.hitTestObject(topPipe3) ||
                mainBird.hitTestObject(bottomPipe3)
            ) {

                gameOver = true;

                removeEventListener(
                    Event.ENTER_FRAME,
                    onPhysicsFrame
                );

                if (velocityY <= 0) {
                    hitCeiling();
                } else {
                    hitGround();
                }

                return;
            } 

            checkScore();            
        }

        // Play the full animation of the current inner bird if it's not already playing
        private function playFullAnimation(): void {
            if (currentInnerBird != null && !isPlayingAnimation) {
                currentInnerBird.addEventListener(Event.ENTER_FRAME, onAnimationFrame);
                currentInnerBird.play();
                isPlayingAnimation = true;
            }
        }

        private function hitGround():void {
            removeEventListener(Event.ENTER_FRAME, onPhysicsFrame);

            stage.removeEventListener(MouseEvent.CLICK, onMouseClick);

            playGameOverEffect();
            
            // Animate the bird's for hitting the ground 
            var rotateTween:Tween =
                new Tween(
                    mainBird,
                    "rotation",
                    Regular.easeOut,
                    mainBird.rotation,
                    90, 0.4,
                    true
                );

            mainBird.y += 3;

            rotateTween.addEventListener(
                TweenEvent.MOTION_FINISH,
                onHitGroundFinished
            );
        }

        private function hitCeiling():void {

            stage.removeEventListener(MouseEvent.CLICK, onMouseClick);

            removeEventListener(Event.ENTER_FRAME, onPhysicsFrame)

            playGameOverEffect();

            var rotateTween:Tween =
                new Tween(
                    mainBird,
                    "rotation",
                    Regular.easeOut,
                    mainBird.rotation,
                    -90,
                    0.4,
                    true
                );

            rotateTween.addEventListener(
                TweenEvent.MOTION_FINISH,
                onCeilingRotateFinished
            );
        }

        private function getGroundTop():Number {
            return ground.y;
        }
        
        private function onHitGroundFinished(e:TweenEvent):void {
            onGameOver();
        }

        private function checkScore():void {

            if (!pipePassed1 &&
                topPipe1.x + topPipe1.width < mainBird.x) {

                pipePassed1 = true;

                currentScore++;

                score.text = String(currentScore);
            }

            if (!pipePassed2 &&
                topPipe2.x + topPipe2.width < mainBird.x) {

                pipePassed2 = true;

                currentScore++;

                score.text = String(currentScore);
            }

            if (!pipePassed3 &&
                topPipe3.x + topPipe3.width < mainBird.x) {

                pipePassed3 = true;

                currentScore++;

                score.text = String(currentScore);
            }

        }

        private function resetGame():void {
            removeEventListener(Event.ENTER_FRAME, onPhysicsFrame);

            stage.removeEventListener(MouseEvent.CLICK, onGame);
            stage.removeEventListener(MouseEvent.CLICK, onMouseClick);

            gameStarted = false;
            gameOver = false;

            velocityY = 0;

            resetBirdPosition();
            mainBird.rotation = 0;

            score.text = "0";

            hideGameModal();
            hideGameOverModal();

            showGameStartModal();
            showOverlay();

            setupGameStartListeners();
        }

        private function resetBirdPosition():void {
            mainBird.y = 340;
            mainBird.rotation = 0;
            velocityY = 0;
        }

        private function resetPipe(topPipe:MovieClip, bottomPipe:MovieClip):void {
            // Randomly determine the vertical position of the pipe gap within a specified range
            var minY:Number = 250;
            var maxY:Number = 550;

            var gap:Number = pipeGap;

            var centerY:Number = minY + Math.random() * (maxY - minY);

            bottomPipe.y = centerY + (gap / 2);
            topPipe.y = centerY - (gap / 2);

            topPipe.y -= topPipe.height;
        }

        private function onCeilingRotateFinished(e:TweenEvent):void {
            // Animate the bird falling down to the ground after hitting the ceiling
            var fallTween:Tween =
                new Tween(
                    mainBird,
                    "y",
                    Regular.easeIn,
                    mainBird.y,
                    getGroundTop() - mainBird.height,
                    0.9,
                    true
                );

            fallTween.addEventListener(
                TweenEvent.MOTION_FINISH,
                onHitGroundFinished
            );
        }

        // Handle the animation frame event for the current inner bird, stopping the animation when it reaches the last frame
        private function onAnimationFrame(e:Event): void {
            if (currentInnerBird != null) {
                if (currentInnerBird.currentFrame >= currentInnerBird.totalFrames) {
                    currentInnerBird.stop();
                    currentInnerBird.gotoAndStop(currentInnerBird.totalFrames);
                    isPlayingAnimation = false;
                    currentInnerBird.removeEventListener(Event.ENTER_FRAME, onAnimationFrame);
                }
            }
        }

        private function advanceMainBirdFrame(): void {
            if (mainBird != null) {
                if (isPlayingAnimation && currentInnerBird != null) {
                    currentInnerBird.stop();
                    currentInnerBird.removeEventListener(Event.ENTER_FRAME, onAnimationFrame);
                    isPlayingAnimation = false;
                }

                var nextFrame = mainBird.currentFrame + 1;
                if (nextFrame > mainBird.totalFrames) {
                    nextFrame = 1;
                }

                mainBird.gotoAndStop(nextFrame);

                updateInnerBirdReference();
            }
        }

        private function movePipe(topPipe:MovieClip, bottomPipe:MovieClip):void {

            topPipe.x -= pipeSpeed;
            bottomPipe.x -= pipeSpeed;

            if (topPipe.x < -topPipe.width) {

                var farthest:Number = Math.max(
                    topPipe1.x,
                    topPipe2.x,
                    topPipe3.x
                );

                topPipe.x = farthest + PIPE_DISTANCE;
                bottomPipe.x = topPipe.x;

                resetPipe(topPipe, bottomPipe);

                if (topPipe == topPipe1) 
                    pipePassed1 = false;

                if (topPipe == topPipe2) 
                    pipePassed2 = false;

                if (topPipe == topPipe3) 
                    pipePassed3 = false;
            }
        }

        private function playGameOverEffect(): void {
            SoundManager.getInstance().gameOverEffect();
        }
    }
}



