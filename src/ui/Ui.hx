package ui;

import script.HscriptFunction;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;
import peote.ui.event.PointerType;
import peote.view.PeoteView;
import peote.view.Color;
import peote.view.UniformFloat;

import peote.text.Font;

import peote.ui.PeoteUIDisplay;
import peote.ui.style.RoundBorderStyle;
import peote.ui.style.BoxStyle;
import peote.ui.interactive.UISlider;
import peote.ui.config.ResizeType;
import peote.ui.event.WheelEvent;

import ui.interactive.UIAreaList;


class Ui
{
	var peoteView:PeoteView;

	public static var font:Font<UiFontStyle>;
	public static var fontStyleBG = UiFontStyle.createById(0);
	public static var fontStyleFG = UiFontStyle.createById(1);

	public static var styleBG = RoundBorderStyle.createById(0, 0x000000ff);
	public static var styleFG = RoundBorderStyle.createById(1, 0x556610ff);
	public static var selectionStyle = BoxStyle.createById(0, Color.GREY3);
	public static var cursorStyle = BoxStyle.createById(1, 0xaa2211ff);


	public var onInit:Void->Void;
	public var onRun:Void->Void;

	public var logArea:LogArea;
	public var codeArea:CodeArea;

	public function new(
		peoteView:PeoteView,
		onInit:Void->Void,
		onRun:Void->Void
	)
	{
		this.peoteView = peoteView;
		this.onInit = onInit;
		this.onRun = onRun;

		// load font for UI
		new Font<UiFontStyle>("assets/hack_ascii_small.json").load( onFontLoaded );
	}

	public function onFontLoaded(font:Font<UiFontStyle>)
	{
		Ui.font = font;

		// -------------------------------------------------------
		// --- PeoteUIDisplay with styles in Layer-Depth-Order ---
		// -------------------------------------------------------
		
		var peoteUiDisplay = new PeoteUIDisplay(0, 0, peoteView.width, peoteView.height, 0x00000000,
			[ styleBG, styleFG, selectionStyle, fontStyleBG, fontStyleFG, cursorStyle ]
		);
		peoteView.addDisplay(peoteUiDisplay);
		
		
		// --- code Area ------------------

		codeArea = new CodeArea(onRun);
		peoteUiDisplay.add(codeArea);
		// to let drag the area
		codeArea.setDragArea(0, 0, peoteUiDisplay.width, peoteUiDisplay.height);
		codeArea.updateLayout();


		// --- log Area ----------------

		logArea = new LogArea();
		peoteUiDisplay.add(logArea);
		// to let drag the area
		logArea.setDragArea(0, 0, peoteUiDisplay.width, peoteUiDisplay.height);
		logArea.updateLayout();


		// --- object Area ----------------

		var objArea = new UIAreaList(500,0,200,300, 0,
		// {
			//backgroundStyle:null
		// }
		);
		peoteUiDisplay.add(objArea);
		objArea.updateLayout();



		// -----------------------------------
		PeoteUIDisplay.registerEvents(peoteView.window);
		onInit();
	}
	



}

