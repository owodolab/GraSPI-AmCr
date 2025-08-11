from skimage.measure import label 
import scipy.io
import numpy as np
import os

def CC(namefile):
    pathfolder = '/data-er/y.ameslon/StructureAndPerformance/GraSPI/GraSPI-AmCr/examples/5phaseMorphologies/HIERN-pipeline/Tempfiles/'
    exten = '.mat'
    filemat = os.path.join(pathfolder, namefile + exten)
    
    # Load the mat file
    mat = scipy.io.loadmat(filemat)
    
    # Extract your data (replace 'your_variable_name' with the actual variable name in your .mat file)
    twoLayersUp = mat['twoLayersUp']  # You need to specify the correct key
    
    # Apply connected components labeling
    labeledImage = label(twoLayersUp, connectivity=2) 
    
    # Save the result
    savefile = filemat
    scipy.io.savemat(savefile, {'labeledImage': labeledImage})

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        CC(sys.argv[1])
    else:
        print("Please provide a filename")
    