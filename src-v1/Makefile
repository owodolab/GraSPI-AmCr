all: graspi5phases


# graspi requires boost library, install and add to you path or explicitly provide the path here. 
# graspi at the time of release was tested with version boost_1_72_0
BOOSTLIB="/Users/olgawodo/Packages/boost_1_72_0"

COPT = -I${BOOSTLIB} -O3   #-g3 -DDEBUG

graspi5phases: main5phases.cpp graph_constructors.cpp
	g++ -o graspi5phases -Wno-deprecated ${COPT} main5phases.cpp graph_constructors.cpp


clean:
	rm -rf *.o graspi5phases
