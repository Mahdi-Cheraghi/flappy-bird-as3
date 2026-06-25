package ui {
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFieldType;
    import flash.text.TextFieldAutoSize;

    public class Tooltip extends TextField {
        public function Tooltip() {
            super();

            autoSize = TextFieldAutoSize.LEFT;

            width = 180;
            height = 44; 

            background = true;
            borderColor = 0x000000;
            border = true;

            var format:TextFormat = new TextFormat();
            format.font = "Arial";
            format.size = 12;
            format.color = 0x252525;
            format.align = "center";
            format.leftMargin = 8;
            format.rightMargin = 8;

            defaultTextFormat = format;
            selectable = false;
            type = TextFieldType.DYNAMIC;

            alpha = 0;
        }

        public function setText(value:String): void {
            text = value;
        }
    }
}