PFLAGS = -g -vwnh
GOAL = kdtree 
DATA = test.txt

$(GOAL): kdtree.pas
	fpc $(PFLAGS) -o$@ $^ 

test: $(GOAL)
	./$(GOAL) < $(DATA) 

clean:
	rm -f $(GOAL)
