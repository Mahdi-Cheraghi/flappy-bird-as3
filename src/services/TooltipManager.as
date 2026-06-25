package services {
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.utils.Dictionary;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import ui.Tooltip;

    public class TooltipManager {
        private static var _instance:TooltipManager;

        private var container:DisplayObjectContainer;
        private var tooltip:Tooltip;
        private var target:DisplayObject;
        private var tooltips:Dictionary = new Dictionary(true);
        private var offsetX:int = 20;
        private var offsetY:int = 20;
        private var isShowing:Boolean = false;

        // Singleton pattern 
        public static function getInstance(container:DisplayObjectContainer):TooltipManager {
            if (!_instance && container)
                _instance = new TooltipManager(container);
            else if (_instance && container)
                _instance.container = container;

            return _instance;
        }

        public function TooltipManager(container:DisplayObjectContainer) {
            this.container = container;
        }

        // Auto bind tooltip to a button with text
        public function register(btn:DisplayObject, text:String):void {
            if (!btn) return;

            if (tooltips[btn] != null) {
                return;
            }

            tooltips[btn] = text;

            btn.addEventListener(MouseEvent.ROLL_OVER, onOver);
            btn.addEventListener(MouseEvent.ROLL_OUT, onOut);
        }
        
        private function onOver(e:MouseEvent):void {
            target = e.currentTarget as DisplayObject;

            if (!tooltip) {
                tooltip = new Tooltip();
                container.addChild(tooltip);
            }

            tooltip.setText(tooltips[target]);

            tooltip.alpha = 0;
            
            container.removeEventListener(Event.ENTER_FRAME, fadeOut);

            isShowing = true;

            container.addEventListener(Event.ENTER_FRAME, updatePosition);

            show();
        }

        private function onOut(e:MouseEvent):void {
            isShowing = false;
            hide();
        }

        // Smart position update 
        private function updatePosition(e:Event):void {
            if (!tooltip || !target) return;

            var tx:Number = container.mouseX + offsetX;
            var ty:Number = container.mouseY + offsetY;

            if (tx + tooltip.width > container.stage.stageWidth)
                tx = container.stage.stageWidth - tooltip.width - 5;

            if (ty + tooltip.height > container.stage.stageHeight)
                ty = container.stage.stageHeight - tooltip.height - 5;

            tooltip.x = tx;
            tooltip.y = ty;
        }

        private function show():void {
            container.removeEventListener(Event.ENTER_FRAME, fadeIn);
            container.addEventListener(Event.ENTER_FRAME, fadeIn);
        }

        private function fadeIn(e:Event):void {
            if (!isShowing || !tooltip) return;

            tooltip.alpha += 0.15;
            if (tooltip.alpha >= 1) {
                tooltip.alpha = 1;
                container.removeEventListener(Event.ENTER_FRAME, fadeIn);
            }
        }

        private function hide():void {
            container.removeEventListener(Event.ENTER_FRAME, updatePosition);
            container.addEventListener(Event.ENTER_FRAME, fadeOut);
        }

        private function fadeOut(e:Event):void {
            if (isShowing) return;

            if (!tooltip) return;

            tooltip.alpha -= 0.15;

            if (tooltip.alpha <= 0) {
                tooltip.alpha = 0;

                container.removeEventListener(Event.ENTER_FRAME, fadeOut);
                container.removeEventListener(Event.ENTER_FRAME, updatePosition);

                if (container.contains(tooltip)) {
                    container.removeChild(tooltip);
                }

                tooltip = null;

                target = null;
            }
        }
    }
}