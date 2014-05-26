{ Charles Effinger }
{ This program will build and probe a k-d tree given proper input. }
program kdTree(input, output);

const
{ The constant DIMENSIONS represents the amount of dimensions for the k-d tree.
  The constant BUCKET_SIZE represents the size of the buckets for the leaves of
  the k-d tree. }      
	DIMENSIONS = 3;  
	BUCKET_SIZE = 10;
type
{ kDPoint represents an individual point in the set DIMENSION space. }
	kDPoint = array[0 .. DIMENSIONS-1] of real;
{ kDNodePointer is just a pointer to kDNode record. }	
	kDNodePointer = ^kDNode;
{ kDNode represents an individual node in the k-d tree. The node can either be 
  a leaf or not. If it is not a leaf, it will hold the dimension and value that 
  the node compare on. It's left pointer points to a node that will house any 
  k-d points less than or equal to value within the dimension of the node. The 
  right pointer points to a node that will house k-d points greater than the 
  value within the dimension of the node. If the node is a leaf, it will have 
  the indices of the nodes array where the bucket data lives for the leaf. }
	kDNode = record
		case leaf : boolean of 
			true: (
				bucketStart, bucketStop : integer;
			);
			false: (
				dim : integer;
				value : real;
				left, right : kDNodePointer;
			)
	end; 
{ kDArray is a dynamic multi-dimensional array that can hold 'x' amount of 
  kDPoints. } 	
	kDArray = array of kDPoint;
var 
{ The nodes array will hold the initial k-dimensional data given. }	
	nodes : kDArray;
{ The head pointer points to the head node of the k-d tree. }	
	head : kDNodePointer;
{ the probes array will hold the k-dimensional probe data. }	
	probes : kDArray;

{ This procedure will insert 'count' k-d nodes into the given array. } 
procedure initializeKDPoints(var count : integer; var currArray : kDArray );
var
	dimIndex, index : integer;
begin
{ Dynamically set the length of the array to 'count'. }	
	setLength(currArray, count);
{ Loop through each index of the array and populate with a k-d point. }	
	for index := 0 to count-1 do
	begin
		for dimIndex := 0 to DIMENSIONS-1 do
			read(input, currArray[index, dimIndex]);
	end;
end;


{ This function will determine the best dimension of the current k-d nodes to
  split. }
function findBestDim(min : integer; max : integer) : integer;
var
	dimIndex, index, bestDim : integer;
{ The lowVals and highVals array store the current lowest and highest point for
  each dimension for the given range (min to max). }	
	lowVals, highVals : array[0 .. DIMENSIONS-1] of real;
begin
{ Loop through the entire range. }	
	for index := 0 to max-min do
	begin
{ For each dimension of each index, compare its value with the current highest 
  and lowest value of that dimension. If one of these tests succeeds, replace
  that extreme with the current value. If this is the first pass (index = 0), 
  initialize the highest and lowest values with this index's data. }  		
		for dimIndex := 0 to DIMENSIONS-1 do
		begin
			if index = 0 then
			begin
				highVals[dimIndex] := nodes[index, dimIndex];
				lowVals[dimIndex] := nodes[index, dimIndex];
			end
			else if nodes[index, dimIndex] < lowVals[dimIndex] then
				lowVals[dimIndex] := nodes[index, dimIndex]
			else if nodes[index, dimIndex] > highVals[dimIndex] then
				highVals[dimIndex] := nodes[index, dimIndex];
		end;
	end;
{ Initialize the best dimension to 0. }	
	bestDim := 0;
{ Loop through each dimension. }	
	for dimIndex := 0 to DIMENSIONS-1 do
{ If the range of the current dimension is greater than the current best
  dimension's range, make it the new best dimension. Ties are settled by keeping
  the lower dimension. } 	
	begin	
		 if abs(highVals[dimIndex] - lowVals[dimIndex]) > 
			abs(highVals[bestDim] - lowVals[bestDim]) then
			bestDim := dimIndex
	end;
{ Return the best dimension. }
	findBestDim := bestDim;
end;

{ This function will finds the median of the array nodes for the given dimension
  and span. It uses the selection algorithm to find the median (kth value.) It
  will select a random pivot, then semi-sort the data around that pivot. If the
  pivot was the kth value, the function will return. Otherwise, it will recurse 
  over the sub-array where the pivot must exist. }
function findMedian(dim : integer; min : integer; max : integer;  
	k : integer) : integer;
var
	pivot, index, dimIndex, smallCtr, largeCtr, equalCtr : integer;
	pivotVal : real;
	small, large, equal : array of kDPoint;
begin
{ Dynamically size the sub arrays. }	
	setLength(small, max-min+1);
	setLength(large, max-min+1);
	setLength(equal, max-min+1); 
{ Choose a random pivot value within the range (max-min). } 	
	pivot := random(max-min) + min;
{ Initialize the counter variables to 0. These variables keep track of how many
  values have been placed into the sub-arrays. } 	
	smallCtr := 0;
	largeCtr := 0; 
	equalCtr := 0;
{ Retrieve the actual pivot value from the random pivot and dimension currently 
  being sorted. }	
	pivotVal := nodes[pivot, dim];
{ Loop through the entire range. } 	
	for index := min to max do
	begin
{ If the current value of the dimension of the node is smaller than the pivot 
  value, then place it in the small array. If it is larger than the pivot value,
  place it in large array. Otherwise, place it in the equal array. Increase the
  correct counter variable once the node has been sorted. }  		
		if nodes[index, dim] < pivotVal then
		begin	
			small[smallCtr] := nodes[index];
			smallCtr := smallCtr + 1
		end		
		else if nodes[index, dim] > pivotVal then
		begin	
			large[largeCtr] := nodes[index];
			largeCtr := largeCtr + 1
		end
		else
		begin
			equal[equalCtr] := nodes[index];
			equalCtr := equalCtr + 1
		end	
	end;
	
{ Reorder the nodes array by replacing the current range of the nodes array with
  the small, equal, and large arrays in that order. }	
	for index := 0 to smallCtr-1 do
		for dimIndex := 0 to DIMENSIONS-1 do
			nodes[index+min, dimIndex] := small[index, dimIndex];
	for index := 0 to equalCtr-1 do
		for dimIndex := 0 to DIMENSIONS-1 do
			nodes[index+min+smallCtr, dimIndex] 
			 := equal[index, dimIndex];
	for index := 0 to largeCtr-1 do 
		for dimIndex := 0 to DIMENSIONS-1 do
			nodes[index+min+smallCtr+equalCtr, dimIndex] 
			 := large[index, dimIndex];
{ The sub-arrays are no longer needed, so free their memory. }  	
	setLength(small, 0);
	setLength(equal, 0);
	setLength(large, 0);	
{ If the small and equal arrays had exactly k values or the equal array had more 
  elements than both the small and large array, we have found the median and can 
  return it. }	
	if (smallCtr + equalCtr = k) or ((equalCtr > smallCtr) and 
	 (equalCtr > largeCtr)) then	
		findMedian := smallCtr+equalCtr+min-1 
{ Else, if the small and equal arrays had less than k values, recurse on 
  the large part of the nodes array. Update k so that is correct in the frame of
  the large array.  }	
	else if smallCtr + equalCtr < k then
		findMedian :=  findMedian(dim, min+smallCtr+equalCtr, max,
		 k-smallCtr-equalCtr)
{ Otherwise, the small and equal arrays had more than k values than k. Recurse 
  on the small and equal part of the nodes array. No update of k is needed. }	
	else
		findMedian :=  findMedian(dim, min, max-largeCtr, k);
end;

{ This function will determine which k-d values go into the leaves of the tree. }
function makeKDNodes(min : integer; max : integer) : kDNodePointer;
var
	bestDim, k, medianIndex: integer;
	median : real;
	tmpNode : kDNodePointer;
begin
{ Make a new pointer to a kDNode type. }	
	new(tmpNode);
	with tmpNode^ do
	begin
{ Compare the range of the node with the bucket size to determine if it is a 
  node or a leaf. }		
		leaf := max - min < BUCKET_SIZE;
		case leaf of 
{ If the range of the current node is less than or equal to the bucket size, 
  then the node is a leaf and the bucket bounds need to be set. }		
			true: begin
				bucketStart := min;
				bucketStop := max; 
			end;
{ If the range is of the current node is greater than the bucket size, we do
  not have a leaf. Create a new node to split the data. }
			false: begin
{ Find the best dimension to split the data on. }				
				bestDim := findBestDim(min, max);
{ Determine what the kth value needs to be for the data to be split evenly.
  The name k is used to match the pseudo-code of the Selection algorithm. }			
				k := (max+2-min) div 2;
{ Find the median value for the current range and the best dimension. }				
				medianIndex := findMedian(bestDim, min, max, k);				
				median := nodes[medianIndex, bestDim];	
{ Set the dimension variable of the node to the dimension used to split. }				
				dim := bestDim;
{ Set the value variable of the node to the median value. }				
				value := median;
{ Recursively call makeKDNodes to find the left and right pointers of the node
  based on the pivot index determined. } 				
				left := makeKDNodes(min, medianIndex);
				right := makeKDNodes(medianIndex+1, max);	
			end;
		end; 	
{ Return the node or leaf. }	
	makeKDNodes := tmpNode;	
	end;	 
end;

{ This procedure will build the k-d tree. }
procedure buildKDTree();
var
	nodeCount : integer;
begin
{ Get the node count from the user. }	
	write(output, 'What is the node count? ');
	read(input, nodeCount);
{ The node count must be at least 1. If this is not true, keep asking for a node
  count. }	
	while nodeCount < 1 do
	begin
        	write(output, 'Please give a node count > 0:  ');
        	read(input, nodeCount);
	end;
{ Read nodeCount k-d points into the nodes array. }	
	initializeKDPoints(nodeCount, nodes);		
{ Seed the random number generator to the system clock to ensure randomness. }	
	randomize();
{ Begin construction of the k-d tree by setting the head node to cover the 
  entire range of data. Once this initial call has return, the entire tree will
  be built. }	
	head := makeKDNodes(0, nodeCount-1); 
end;

{ This procedure will print the bucket given by the kDNodePointer. }
procedure printBucket(var currNode : kDNodePointer);
var
	index, dimIndex : integer;
begin
	with currNode^ do
	begin
		writeln(output, 'Bucket: ');
{ For each index of the current node, print each dimension data value. }		
		for index := bucketStart to bucketStop do
		begin
			for dimIndex := 0 to DIMENSIONS-1 do
				write(output, nodes[index, dimIndex]:5:1, ' '); 
		writeln(output);
		end;		
	end;
end;

{ This procedure will print the probe given. }
procedure printProbe(var currProbe : kDPoint);
var
	dimIndex : integer;
begin
	writeln(output);
	writeln(output, 'Probe: ');
{ For each dimension of the given probe, print the data value. }	
	for dimIndex := 0 to DIMENSIONS-1 do
		write(output, currProbe[dimIndex]:5:1, ' ');  
	writeln(output);
end;

{ This procedure will find the closest bucket for the given kDPoint. }
procedure findBucket(var currProbe : kDPoint);
var	 
	currNode : kDNodePointer;
begin
{ Initialize the current node to the head node. }	
	currNode := head;
{ Check the current node to make sure it is not a leaf. If it is a leaf, it will
  break out of the loop. }		
	while not(currNode^.leaf) do 
	begin	
{ Compare the probe's value at the dimension given by the node with the node's 
  value. If the probe is larger, step to the right of the node by using its 
  right pointer. Otherwise, it is smaller than or equal to the node's value and
  can step to the left of the node using the left pointer. }	
		if currProbe[currNode^.dim] > currNode^.value then
			currNode := currNode^.right
		else
			currNode := currNode^.left;
	end;	
{ Once the loop has broken, the proper leaf has been found. Print the probe and
  the leaf. } 
	printProbe(currProbe);
	printBucket(currNode);
end;


{ This procedure will probe the k-d tree. }
procedure probeKDTree();
var
	probeCount, index : integer;
begin
{ Get the probe count from the user. }	
	write(output, 'What is the probe count? ');
	read(input, probeCount);
{ The probe count must be at least 1. If this is not true, keep asking for a 
  probe count. }	
	while probeCount < 1 do
	begin
		write(output, 'Please give a probe count > 0: ');
		read(input, probeCount);
	end; 
{ Read in every k-d probe into the probes array. }	
	initializeKDPoints(probeCount, probes);
{ For each probe, find the bucket where it would be if it were a node. } 	
	for index := 0 to probeCount - 1 do
		findBucket(probes[index]);
end;

{ This function will free all of the memory in the k-d tree. It will initially
  start with the head node. }
function freeTreeMemory(currPointer : kDNodePointer):kDNodePointer;
begin	
	with currPointer^ do
{ If the current node is not a leaf, continue with the function. This should
  only catch if there is only one node in the tree.  }	
	if not(leaf) then
	begin
{ Check the left pointer of the node. }		
		case left^.leaf of 	
{ If it is a leaf, free its memory. }			
			true:
				dispose(left);
{ Otherwise, recursively call the function with the left pointer as the new 
  pointer. }				
			false:
				left := freeTreeMemory(left);
		end;
{ Check the right pointer of the node. }
		case right^.leaf of
{ If it is a leaf, free its memory. }			
			true: 
				dispose(right);
{ Otherwise, recursively call the function with the right pointer as the new
  pointer. }			
			false:
				right := freeTreeMemory(right);		
		end;		
	end;
{ Once this point has been reached, all the children of the current node have 
  been freed. Free the current node's memory and return it. }	
	dispose(currPointer);
	freeTreeMemory := currPointer;
end;


{ The main procedure will call the proper procedures in order to build and probe
  the k-d tree. } 
begin { main }
{ Build the k-d tree. }	
	buildKDTree();
{ Probe the k-d tree. }	
	probeKDTree();
{ The program has accomplished its goal. The memory of the nodes and probes 
   array can be freed now. } 	
	setLength(nodes, 0);
	setLength(probes, 0); 
{ The tree also needs to free its memory. }
	head := freeTreeMemory(head);
end .   
