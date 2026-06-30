all: graspi5phases


# graspi requires boost library, install and add to you path or explicitly provide the path here. 
# graspi at the time of release was tested with version boost_1_72_0
# To compile Graspi: go to folder "/src" and type "make -B graspi5phases" 
# BOOSTLIB="/data-er/y.ameslon/StructureAndPerformance/GraSPI/GraSPI-AmCr/boost_1_88_0"
BOOSTLIB="/home-nbg/o.ronsin/Science/Models/Graspi/GraSPI-AmCr/boost_1_90_0"

COPT = -I${BOOSTLIB} #-g3 -DDEBUG

graspi5phases: main5phases.cpp graph_constructors.cpp
	g++ -o graspi5phases -Wno-deprecated ${COPT} main5phases.cpp graph_constructors.cpp


clean:
	rm -rf *.o graspi5phases
