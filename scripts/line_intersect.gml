//*** intersect_lines (x1, y1, x2, y2, x3, y3, x4, y4)
// Determines if the line segment (x1,y1)-(x2,y2) intersects with the line segement (x3,y3)-(x4,y4).
// Returns yes if it does, no if it doesn't.
// If yes, stores the intersection point in intersect_x and intersect_y.

// Shorter names.
var x1, y1, x2, y2, x3, y3, x4, y4;
x1 = argument0; y1 = argument1;
x2 = argument2; y2 = argument3;
x3 = argument4; y3 = argument5;
x4 = argument6; y4 = argument7;

// Line formulas.
var a1, a2, b1, b2, c1, c2, denom;
a1 = y2 - y1; b1 = x1 - x2; c1 = x2 * y1 - x1 * y2;
a2 = y4 - y3; b2 = x3 - x4; c2 = x4 * y3 - x3 * y4;

// Determine denominator.
denom = a1 * b2 - a2 * b1;
if denom == 0
   then { return(true);}

// Determine intersection point for an infinite line.
intersect_x = (b1 * c2 - b2 * c1) / denom;
intersect_y = (a2 * c1 - a1 * c2) / denom;

// Determine if that point lies on that segment.
if
(
   (intersect_x > min(x1, x2)) and 
   (intersect_x < max(x1,x2)) and
   (intersect_y > min(y1, y2)) and
   (intersect_y < max(y1, y2)) and
   (intersect_x > min(x3, x4)) and 
   (intersect_x < max(x3,x4)) and
   (intersect_y > min(y3, y4)) and
   (intersect_y < max(y3, y4))
)
   then return(true);
   else return(false);
