package ru.stablex.ui.layouts;

import flash.display.DisplayObject;
import ru.stablex.ui.misc.SizeTools;
import ru.stablex.ui.widgets.Widget;
import ru.stablex.ui.widgets.Box; // To acces static method _objHeight



/**
* Row layout.
*
*/
class Row extends Layout{
    //Setter for padding left, right, top, bottom.
    public var padding (never,set_padding) : Float;
    //padding left
    public var paddingLeft   : Float = 0;
    //padding right
    public var paddingRight  : Float = 0;
    //padding top
    public var paddingTop    : Float = 0;
    //padding bottom
    public var paddingBottom : Float = 0;
    //Distance between children
    public var cellPadding : Float = 0;
    //Set children widget size according to row size
    public var fit(null, set_fit) : Bool;
    public var fitWidth : Bool = true;
    public var fitHeight : Bool = true;
    // Horizontal alignment (center,left,right)
    public var hAlign : String = "left";

    /**
    * Rows sizes.
    *  - positive numbers greater than 1 define row height in pixels;
    *  - positive numbers between 0 and 1 define row height in % (0.1 for 10%, 0.65 for 65%, etc.);
    *  - negative numbers mean columns will share free space left after using previous rules.
    *  - zero means, the column will take the space of the containing widget
    * E.g. [150, -2, -1, 0.3] means: first child will be 150 pixels height, last
    * child will be 30% height, the second and third children will take left space,
    * and second will take 2/3 of left space, while third will take 1/3.
    */
    public var rows : Array<Float>;

/*******************************************************************************
*       STATIC METHODS
*******************************************************************************/


/*******************************************************************************
*       INSTANCE METHODS
*******************************************************************************/

    /**
    * Position children of provided widget according to layout logic
    *
    */
    override public function arrangeChildren(holder:Widget) : Void {
        if( this.rows == null || this.rows.length == 0 ) return;

        //calc absolute values {
            var arows     : Array<Float> = [];
            var height    : Float = holder.h - this.paddingTop - this.paddingBottom - (this.rows.length - 1) * this.cellPadding;
            var negParts  : Float = 0;
            var freeSpace : Float = height;

            //calc absolute and % values
            for(i in 0...this.rows.length){
                if( this.rows[i] > 1 ){
                    freeSpace -= arows[i] = this.rows[i];
                }else if( this.rows[i] < 0 ){
                    negParts += arows[i] = this.rows[i];
                }else if (this.rows[i] == 0) {
                  freeSpace -= arows[i] = SizeTools.height(holder.getChildAt(i));
                }else{
                    freeSpace -= arows[i] = height * this.rows[i];
                }
            }

            //calc negative values
            for(i in 0...arows.length){
                if( arows[i] < 0 ){
                    arows[i] = freeSpace * arows[i] / negParts;
                }
            }
        //}

        //set holder's children parameters
        var child : DisplayObject;
        var top  : Float = this.paddingTop;
        for(i in 0...arows.length){
            if( holder.numChildren <= i ) break;
            child = holder.getChildAt(i);

            //position
            if( Std.is(child, Widget) ){
                cast(child, Widget).top = top;
                switch(hAlign) {
                    case "left":   cast(child, Widget).left  = paddingLeft;
                    case "right":  cast(child, Widget).right = paddingRight;
                    case "center": cast(child, Widget).left  = paddingLeft + (holder.w - paddingLeft - paddingRight - cast(child,Widget).w)/2.0;
                }
            }else{
                child.x = this.paddingLeft;
                switch(hAlign) {
                    case "left":   child.y  = paddingLeft;
                    case "right":  child.y  = paddingRight - child.width;
                    case "center": child.y  = paddingLeft + (holder.w - paddingLeft - paddingRight - child.width)/2.0;
                }
            }

            //size
            if( this.fitHeight && Std.is(child, Widget) ){
                cast(child, Widget).resize(fitWidth?(holder.w - this.paddingLeft - this.paddingRight):cast(child,Widget).w, arows[i]);
            }

            top += arows[i] + this.cellPadding;
        }//for()
    }//function arrangeChildren()

/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/

    /**
      * Setter `fit`.
      *
      */
    @:noCompletion private function set_fit (fit:Bool) : Bool {
      fitWidth = fit;
      fitHeight = fit;
      return fit;
    }//function set_fit

    /**
    * Setter `padding`.
    *
    */
    @:noCompletion private function set_padding (padding:Float) : Float {
        return this.paddingLeft = this.paddingRight = this.paddingTop = this.paddingBottom = padding;
    }//function set_padding
}//class Row