//adapt with terrain collision scripts

var grid = obj_flowfield.grid;
var gridSize = obj_flowfield.gridSize;
var targetNode = obj_flowfield.targetNode;
var xx = x div gridSize;
var yy = y div gridSize;

//these two are the most important ones
var currentNode = ds_grid_get(grid, xx, yy);
var parentNode = currentNode.parent;

//everyhing below here is so we get our thing centered on the grid

if (currentNode == targetNode) //if the thing reaches its goal, move it to the center
{
    var xx = currentNode.x * gridSize + gridSize/2;
    var yy = currentNode.y * gridSize + gridSize/2;
    if (distance_to_point(xx,yy) < 0.1)
    {
        spd = 0;    
    }   
}
else if (parentNode != undefined) //if it hasn't reached the goal, move it along the middle of the grid
{
    var x1 = currentNode.x * gridSize + gridSize/2;
    var y1 = currentNode.y * gridSize + gridSize/2;
    var x2 = parentNode.x * gridSize + gridSize/2;
    var y2 = parentNode.y * gridSize + gridSize/2;
    
    spd = 4;
    if (distance_to_point(x1,y1) < 0.1)
    {
        dir = point_direction(x1,y1,x2,y2);   
    }
}
else //the goal is unreachable
{
    spd = 0;
}

//move it in the direction of the flowfield
x += lengthdir_x(spd, dir);
y += lengthdir_y(spd, dir);
