package com.randomMap 
{
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Yonny Zohar
	 */
	public class Region 
	{
		
		public var id:int;
		public var nodes:Array;
		public var nodesDict:Dictionary;
		
		public function Region(id:int) 
		{
			this.id = id;
			nodes = new Array();
			nodesDict = new Dictionary();
		}
		
		public function addNode( node:RandomNode ):void {
			nodes.push(node);
			nodesDict[ node.id ] = node;
		}
		
	}

}
