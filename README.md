A quick summary how the algorithm is intended to work:

Split the whole 1x1 area into smaller areas until it is feasible find the shortest distance between points in this area and all its neighbouring areas through finding the distances between all points.  
To find the next area to split find the are with the most points in it out of all areas that still need to be split (all areas that contain more than 7 points in itself and all neighouring areas).

To split an area create 2 new areas that contain half of the original area and are as quadratic as possible (to achieve this I alternate between splitting vertically and splitting horizontally).
