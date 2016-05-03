package;
import de.polygonal.ds.Graph;
import de.polygonal.ds.GraphNode;
import haxe.ds.Vector;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.Lib;
import voronoimap.graph.Center;

/**
 * ...
 * @author damrem
 */
class TreeXprmnt extends Sprite
{
	var tree:Graph<Center>;
	var terrain:Graph<Center>;
	var scene:Sprite;
	var map:voronoimap.Map;
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
		tree = new Graph<Center>();
		terrain = new Graph<Center>();
		
		map = new voronoimap.Map( { width:stg.stageWidth, height:stg.stageHeight } );
		//map.go0PlacePoints(100);
		for (i in 0...1000)
		{
			map.points.push(new Point(Math.random() * stg.stageWidth, Math.random() * stg.stageHeight));
		}
		
		
		map.go1ImprovePoints(8);
		for (i in 0...8)
		{
			map.improveCorners();
		}
		map.go2BuildGraph();
		
		graphics.lineStyle(0, 0, 0);
		
		
		
		for (c in map.centers)
		{
			c.graphNode = new GraphNode<Center>(terrain, c);
			terrain.addNode(c.graphNode);
		}
		
		for (e in map.edges)
		{
			
			var n0 = terrain.findNode(e.d0);
			var n1= terrain.findNode(e.d1);
			terrain.addMutualArc(n0, n1);
		}
		
		graphics.lineStyle(1, 0xff0000, 0.1);
		for (n0 in terrain.nodeIterator())
		{
			trace("n0", n0.val.point);
			var p0 = n0.val.point;
			
			for (neighbor in n0.val.neighbors)
			{
				trace("neighbor", neighbor);
				var p1 = neighbor.point;
				graphics.moveTo(p0.x, p0.y);
				graphics.lineTo(p1.x, p1.y);
			}
			
		}
		graphics.lineStyle(0, 0, 0);
		
		
		graphics.beginFill(0x00ff00);
		for (n0 in terrain.nodeIterator())
		{	
			var p0 = n0.val.point;
			
			
			graphics.drawRect(p0.x-0.5, p0.y-0.5, 1, 1);
			
		}
		graphics.endFill();
		
		
		
		
		
		
		
		
		
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
			scene.graphics.drawCircle(node.val.point.x, node.val.point.y, 5);
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
					scene.graphics.moveTo(node.val.point.x, node.val.point.y);
					scene.graphics.lineTo(target.val.point.x, target.val.point.y);
				}
			}
		}
		
	}
	
	private function onClick(e:MouseEvent):Void 
	{
		trace(getClosestCenter(new Point(e.localX, e.localY)).point);
		
		
		/*
		var closestNode = getClosestNodeFromPoint(new Point(e.localX, e.localY));
		
		var node = new GraphNode<Center>(tree, new Point(e.localX, e.localY));
		tree.addNode(node);
		
		var closest = getClosestNode(node);
		if (closest != null)
		{
			tree.addMutualArc(node, closest);
		}
		*/
	}
	
	function getClosestCenter(from:Point):Center
	{
		var sortedCenters = map.centers.copy();
		sortedCenters.sort(function(ca:Center, cb:Center):Int
		{
			return Std.int(10*(Point.distance(from, new Point(ca.point.x, ca.point.y)) - Point.distance(from, new Point(cb.point.x, cb.point.y))));
		});
		return sortedCenters[0];
	}
	
	/*
	function getClosestNode(from:Point):GraphNode<Center>
	{
		var closest:GraphNode<Center> = tree.getNodeList();
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
	*/
	 
	
}