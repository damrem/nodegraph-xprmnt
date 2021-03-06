package;
import de.polygonal.ai.pathfinding.AStar;
import de.polygonal.ds.ArrayList;
import de.polygonal.ds.Graph;
import de.polygonal.ds.GraphNode;
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
	var astar:AStar;
	
	var branch:Graph<Center>;
	var selectedCenter:Center;
	var interactiveLayer:Sprite;
	
	public function new() 
	{
		super();
		var stg = Lib.current.stage;
		var bg = new Sprite();
		bg.graphics.beginFill(0xffffff);
		bg.alpha = 0.1;
		bg.graphics.drawRect(0, 0, stg.stageWidth, stg.stageHeight);
		
		astar = new AStar(terrain);
		
		scene = new Sprite();
		interactiveLayer = new Sprite();
		
		addChild(scene);
		addChild(bg);
		addChild(interactiveLayer);
		
		tree = new Graph<Center>();
		terrain = new Graph<Center>();
		branch = new Graph<Center>();
		
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
			c.node = new GraphNode<Center>(terrain, c);
			terrain.addNode(c.node);
		}
		
		for (e in map.edges)
		{
			
			var n0 = terrain.findNode(e.d0);
			var n1= terrain.findNode(e.d1);
			terrain.addMutualArc(n0, n1, e.d0.distanceTo(e.d1));
		}
		
		graphics.lineStyle(1, 0xff0000, 0.1);
		for (n0 in terrain.nodeIterator())
		{
			//trace("n0", n0.val.point);
			var p0 = n0.val.point;
			
			for (neighbor in n0.val.neighbors)
			{
				//trace("neighbor", neighbor);
				var p1 = neighbor.point;
				graphics.moveTo(p0.x, p0.y);
				graphics.lineTo(p1.x, p1.y);
			}
			
		}
		graphics.lineStyle(0, 0, 0);
		
		/*
		graphics.beginFill(0x00ff00);
		for (n0 in terrain.nodeIterator())
		{	
			var p0 = n0.val.point;
			
			
			graphics.drawRect(p0.x-0.5, p0.y-0.5, 1, 1);
			
		}
		graphics.endFill();
		*/
		
		
		
		
		
		
		
		
		//addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(Event.ENTER_FRAME, update);
		addEventListener(MouseEvent.MOUSE_MOVE, onMove);
		addEventListener(MouseEvent.CLICK, toggleSelection);
		addBranch();
	}
	
	private function toggleSelection(e:MouseEvent):Void 
	{
		//trace(e.target, e.currentTarget);
		var centeredSprite:CenteredSprite;// = e.target;
		if (Type.getClass(e.target) == CenteredSprite)
		{
			selectedCenter = cast(e.target, CenteredSprite).center;
			//var center = centeredSprite.center;			
			var node = tree.findNode(selectedCenter);
		}
		else
		{
			selectedCenter = null;
		}
		
	}
	
	private function onMove(e:MouseEvent):Void 
	{
		trace("onMove", e.localX, e.localY);
		//trace(Lib.getTimer());
		
		branch.clear(true);
		//trace(Lib.getTimer());
		
		var closestTerrainCenter = getClosestTerrainCenter(new Point(e.stageX, e.stageY));
		//trace(Lib.getTimer());
		
		var terrainNode = terrain.findNode(closestTerrainCenter);
		//trace(Lib.getTimer());
		
		var shortestPathToTree = getShortestPathToTree(closestTerrainCenter);
		//trace(Lib.getTimer());
		
		if (shortestPathToTree == null)
		{
			var branchNode = new GraphNode<Center>(tree, closestTerrainCenter);
			branch.addNode(branchNode);
			return;
		}
		//trace(Lib.getTimer());
		//trace(shortestPathToTree.size());
		for (center in shortestPathToTree)
		{
			if (branch.findNode(center) == null)
			{
				var branchNode = new GraphNode<Center>(branch, center);
				branch.addNode(branchNode);
			}
		}
		//trace(Lib.getTimer());
		
		for (i in 0...shortestPathToTree.size-1)
		{
			var node0 = branch.findNode(shortestPathToTree.get(i));
			var node1 = branch.findNode(shortestPathToTree.get(i + 1));
			if (node0!=null&&node1!=null&&!node0.isMutuallyConnected(node1))
			{
				
				branch.addMutualArc(node0, node1, node0.val.distanceTo(node1.val));
			}
		}
		trace(Lib.getTimer());
		
	}
	
	function createTerrain()
	{
		
	}
	
	
	function drawGraph(graph:Graph<Center>, color:Int)
	{
		for (node in graph.nodeIterator())
		{
			node.val.sprite.x = node.val.point.x;
			node.val.sprite.y = node.val.point.y;
			node.val.sprite.alpha = selectedCenter == node.val?1:0.25;
			interactiveLayer.addChild(node.val.sprite);
			//trace(node.val.zone.width, node.val.zone.height);
			//scene.graphics.beginFill(color, 0.25);
			//scene.graphics.lineStyle(0, 0, 0);
			//scene.graphics.drawCircle(node.val.point.x, node.val.point.y, 5);
			//scene.graphics.endFill();
			
			for (target in graph.nodeIterator())
			{
				if (node == target)
				{
					continue;
				}
				if (node.isMutuallyConnected(target))
				{
					scene.graphics.lineStyle(2, color);
					scene.graphics.moveTo(node.val.point.x, node.val.point.y);
					scene.graphics.lineTo(target.val.point.x, target.val.point.y);
				}
			}
		}
	}
	
	
	
	private function update(e:Event):Void 
	{
		scene.graphics.clear();
		interactiveLayer.removeChildren();
		drawGraph(tree, 0xff0000);
		drawGraph(branch, 0xffff00);
		
	}
	
	private function onClick(e:MouseEvent):Void 
	{
		/*if (selectedTreeNode == null)
		{
			selectTreeNode(getClosestTreeNode());
		}
		else
		{*/
			addBranch(e);
		//}
	}
	
	function addBranch(e:MouseEvent=null)
	{
		var point = e == null ? new Point(Lib.current.stage.stageWidth / 2, Lib.current.stage.stageHeight / 2) : new Point(e.stageX, e.stageY);
		var closestTerrainCenter = getClosestTerrainCenter(point);
		var terrainNode = terrain.findNode(closestTerrainCenter);
		
		var shortestPathToTree = getShortestPathToTree(closestTerrainCenter);
		
		//	start exception
		if (shortestPathToTree == null)
		{
			var treeNode = new GraphNode<Center>(tree, closestTerrainCenter);
			tree.addNode(treeNode);
			return;
		}
		
		for (center in shortestPathToTree)
		{
			if (tree.findNode(center) == null)
			{
				var treeNode = new GraphNode<Center>(tree, center);
				tree.addNode(treeNode);
			}
		}
		
		for (i in 0...shortestPathToTree.size-1)
		{
			var node0 = tree.findNode(shortestPathToTree.get(i));
			var node1 = tree.findNode(shortestPathToTree.get(i + 1));
			if (!node0.isMutuallyConnected(node1))
			{
				
				tree.addMutualArc(node0, node1, node0.val.distanceTo(node1.val));
			}
		}
		
	}
	
	
	
	function getShortestPathToTree(terrainCenter:Center):ArrayList<Center>
	{
		//var pathsByTreeNode:Map<ArrayList<Center>, Center> = new Map<ArrayList<Center>, Center>();
		var paths:Array<ArrayList<Center>> = [];
		
		for (treeCenter in tree)
		{
			var path = new ArrayList<Center>();
			astar.find(terrain, terrainCenter, treeCenter, path);
			paths.push(path);
			//pathsByTreeNode.set(path, treeCenter);
		}
		paths.sort(function(da0:ArrayList<Center>, da1:ArrayList<Center>):Int
		{
			return Std.int((getPathDistance(da0) - getPathDistance(da1))*1000);
		});
		
		//terrain.
		if (paths.length == 0)	return null;
		//if (paths.length == 1) return paths[0];
		return paths[0];
	}
	
	function getPathDistance(da:ArrayList<Center>):Float
	{
		var distance:Float = 0;
		for (i in 0 ... da.size-1)
		{
			distance+= da.get(i).distanceTo(da.get(i + 1));
		}
		return distance;
	}
	
	function getClosestTreeNode(from:GraphNode<Center>):GraphNode<Center>
	{
		var pathsByTreeNode:Map<ArrayList<Center>, Center> = new Map<ArrayList<Center>, Center>();
		
		var paths:Array<ArrayList<Center>>=[];
		for (treeCenter in tree)
		{
			var path=new ArrayList<Center>();
			astar.find(terrain, from.val, treeCenter, path);
			paths.push(path);
			pathsByTreeNode.set(path, treeCenter);
		}
		paths.sort(function(da0:ArrayList<Center>, da1:ArrayList<Center>):Int
		{
			return da1.size - da0.size;
		});
		//terrain.
		return pathsByTreeNode.get(paths[0]).node;
	}
	
	function getClosestTerrainCenter(from:Point):Center
	{
		var closestCenter = terrain.getNodeList().val;
		for (center in terrain.iterator())
		{
			if (Point.distance(from, center.point) < Point.distance(from, closestCenter.point))
			{
				closestCenter = center;
			}
		}
		return closestCenter;
		
		
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