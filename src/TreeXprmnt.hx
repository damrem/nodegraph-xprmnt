package;
import de.polygonal.ds.Graph;
import de.polygonal.ds.GraphNode;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.Lib;

/**
 * ...
 * @author damrem
 */
class TreeXprmnt extends Sprite
{
	var tree:Graph<Point>;
	var scene:Sprite;
	public function new() 
	{
		super();
		var stg = Lib.current.stage;
		var bg = new Sprite();
		bg.graphics.beginFill(0xffffff);
		bg.alpha = 0.1;
		bg.graphics.drawRect(0, 0, stg.stageWidth, stg.stageHeight);
		
		scene = new Sprite();
		
		addChild(scene);
		
		addChild(bg);
		tree = new Graph<Point>();
		
		var grid = new Array<Point>();
		for (i in 0...1000)
		{
			grid.push(new Point(Math.random() * stg.stageWidth, Math.random() * stg.stageHeight));
		}
		
		var map = new voronoimap.Map({width:stg.stageWidth, height:stg.stageHeight});
		
		
		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(Event.ENTER_FRAME, update);
	}
	
	private function update(e:Event):Void 
	{
		scene.graphics.clear();
		for (node in tree.nodeIterator())
		{
			scene.graphics.beginFill(0xff0000);
			scene.graphics.lineStyle(0, 0, 0);
			scene.graphics.drawCircle(node.val.x, node.val.y, 5);
			scene.graphics.endFill();
			
			for (target in tree.nodeIterator())
			{
				if (node == target)
				{
					continue;
				}
				if (node.isMutuallyConnected(target))
				{
					scene.graphics.lineStyle(2, 0xff0000);
					scene.graphics.moveTo(node.val.x, node.val.y);
					scene.graphics.lineTo(target.val.x, target.val.y);
				}
			}
		}
		
	}
	
	private function onClick(e:MouseEvent):Void 
	{
		var node = new GraphNode<Point>(tree, new Point(e.localX, e.localY));
		tree.addNode(node);
		
		var closest = getClosestNode(node);
		if (closest != null)
		{
			tree.addMutualArc(node, closest);
		}
	}
	
	function getClosestNode(from:GraphNode<Point>):GraphNode<Point>
	{
		/*
		var closest:GraphNode<Point>=tree.getNodeList();
		if (closest == null || tree.size() == 1)
		{
			return null;
		}
		*/
		var closest:GraphNode<Point> = tree.getNodeList();
		for (node in tree.nodeIterator())
		{
			if (closest == from && node != from)
			{
				closest = node;
			}
			if (node != from && Point.distance(from.val, node.val) < Point.distance(from.val, closest.val))
			{
				closest = node;
			}
		}
		
		if (closest == from)
		{
			return null;
		}
		
		return closest;
	}
	
	 
	
}