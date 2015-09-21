package pixi.display;

import flump.DisplayObjectKey;
import flump.library.MovieSymbol;
import flump.MoviePlayer;
import flump.IFlumpMovie;
import flump.library.Layer;
import flump.library.Keyframe;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.math.Point;


class FlumpMovie extends Container implements IFlumpMovie{

	public var player:MoviePlayer;
	public var layers = new Map<Layer, PixiLayer>();
	public var movieChildren = new Map<DisplayObjectKey, DisplayObject>();
	public var displaying = new Map<Layer, DisplayObjectKey>();

	private var factory:FlumpFactory;


	public function new(symbol:MovieSymbol, flumpFactory:FlumpFactory){
		super();
		factory = flumpFactory;
		player = new MoviePlayer(symbol, this);
	}

	/////////////////////////////////////////////////////
	//
	//   Setup
	//
	/////////////////////////////////////////////////////

	public function beginSetup():Void{
	}

	
	public function createLayer(layer:Layer):Void{
		layers[layer] = new PixiLayer();
		addChild(layers[layer]);
	}
	

	public function endSetup():Void{

	}


	public function getChildMovie(keyframe:Keyframe):MoviePlayer{
		ensureChildExists(keyframe);
		var movie:FlumpMovie = cast movieChildren[keyframe.displayKey];
		return movie.player;
	}


	private function ensureChildExists(keyframe:Keyframe){
		if(movieChildren.exists(keyframe.displayKey) == false){
			movieChildren[keyframe.displayKey] = factory.createDisplayObject(keyframe.symbolId);
		}
	}


	/////////////////////////////////////////////////////
	//
	//   Render
	//
	/////////////////////////////////////////////////////

	public function startRender():Void{
	}


	public function renderFrame(keyframe:Keyframe, x:Float, y:Float, scaleX:Float, scaleY:Float, skewX:Float, skewY:Float):Void{
		var layer = layers[keyframe.layer];
		
		ensureChildExists(keyframe);

		if(displaying[keyframe.layer] != keyframe.displayKey){
			if(displaying.exists(keyframe.layer)) layer.removeChild( movieChildren[ displaying[keyframe.layer] ] );
			displaying[keyframe.layer] = keyframe.displayKey;
			if(displaying[keyframe.layer] != null) layer.addChild(movieChildren[keyframe.displayKey]);
		}

		layer.x = x;
		layer.y = y;
		layer.scale.x = scaleX;
		layer.scale.y = scaleY;
		layer.skew.x = skewX;
		layer.skew.y = skewY;
		layer.pivot.x = keyframe.pivot.x;
		layer.pivot.y = keyframe.pivot.y;
	}



	public function renderMovieFrame(keyframe:Keyframe, x:Float, y:Float, scaleX:Float, scaleY:Float, skewX:Float, skewY:Float):MoviePlayer{
		renderFrame(keyframe, x, y, scaleX, scaleY, skewX, skewY);
		var movie:FlumpMovie = cast movieChildren[keyframe.displayKey];
		return movie.player;
	}

	
	public function renderEmptyFrame(keyframe:Keyframe):Void{
		var layerContainer = layers[keyframe.layer];
		if(displaying.exists(keyframe.layer)){
			layerContainer.removeChild( movieChildren[ displaying[keyframe.layer] ] );
			displaying.remove(keyframe.layer);
		}
	}
	

	public function completeRender():Void{

	}

}