package;
import openfl.display.Sprite;
import voronoimap.graph.Center;

/**
 * ...
 * @author damrem
 */
class CenteredSprite extends Sprite
{
	public var center:Center;
	public function new(center:Center) 
	{
		super();
		this.center = center;
	}
	
}