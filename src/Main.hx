package;

import openfl.display.Sprite;
import openfl.Lib;

/**
 * ...
 * @author damrem
 */
class Main extends Sprite 
{

	public function new() 
	{
		super();
		
		// Assets:
		// openfl.Assets.getBitmapData("img/assetname.jpg");
		addChild(new TreeXprmnt());
	}

}
