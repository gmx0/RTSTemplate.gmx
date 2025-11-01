//adapt with terrain collision scripts
///scr_calculateFlowField(ds_grid<obj_node>, obj_node)

var grid = argument0;
var target = argument1;
var width = ds_grid_width(grid);
var height = ds_grid_height(grid);

//reset the flowfield nodes
for (var xx=0;xx<width;++xx)
{
    for (var yy=0;yy<height;++yy)
    {
        var node = ds_grid_get(grid, xx, yy);
        node.visited = false;
        node.parent = undefined;
    }
}

//add first node to list and mark it as visited
var list = ds_list_create();
ds_list_add(list, target);
target.visited = true;


while (ds_list_size(list) > 0)
{
    //get the first node and remove it from the list
    var currentNode = ds_list_find_value(list, 0);
    ds_list_delete(list, 0);
    
    /*
        This is where you will most likely be modify the flowfield based on the type of behaviour you want.
        
        In this example I have set it up so we get the neighbouring nodes (left, right, top, bottom)
        added to the list. You can also include the diagonals, weights, remove certain directions,
        and anything that suits your needs. I am currently adding them in the above order, but you
        can randomize it to make it less predictable.
        
        Note that variables parent and visited are required.
        - Parent is the current node which points to the neighbour node we are about to add.
        - Visited means the node has already been added in the list, so we no longer process it.
          If we didn't have this, we would have an infinite while loop.
    */
    
    //add neighbouring nodes and mark them as visited and set the parent as the current node
    if (currentNode.x > 0)
    {
        var tmp = ds_grid_get(grid, currentNode.x-1, currentNode.y);
        if (!tmp.visited && tmp.walkable)
        {
            ds_list_add(list, tmp);
            tmp.parent = currentNode;
            tmp.visited = true;
        }
    }
    if (currentNode.x < width-1)
    {
        var tmp = ds_grid_get(grid, currentNode.x+1, currentNode.y);
        if (!tmp.visited && tmp.walkable)
        {
            ds_list_add(list, tmp);
            tmp.parent = currentNode;
            tmp.visited = true;
        }
    }
    if (currentNode.y > 0)
    {
        var tmp = ds_grid_get(grid, currentNode.x, currentNode.y-1);
        if (!tmp.visited && tmp.walkable)
        {
            ds_list_add(list, tmp);
            tmp.parent = currentNode;
            tmp.visited = true;
        }
    }
    if (currentNode.y < height-1)
    {
        var tmp = ds_grid_get(grid, currentNode.x, currentNode.y+1);
        if (!tmp.visited && tmp.walkable)
        {
            ds_list_add(list, tmp);
            tmp.parent = currentNode;
            tmp.visited = true;
        }
    }
}

ds_list_destroy(list);
