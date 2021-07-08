import sys
import numpy as np
import nibabel as nib
import math
import argparse
import datetime

def dcbc(img, mask, radius):
    mask = mask.get_data().astype(bool)
    imgdata = img.get_data()
    
    voxsize = np.array(img.get_header().get_zooms()[0:3]).reshape(1,3)
    numvoxels = np.sum(mask)
    numtps = img.get_shape()[3]
    
    indices = np.transpose(np.nonzero(mask))
    
    imgts = imgdata[indices[:,0], indices[:,1], indices[:,2]]
    
    imgts = ((imgts - np.mean(imgts, axis=1).reshape((numvoxels, 1)))
             / np.std(imgts, axis=1).reshape((numvoxels,1)))
        
    result = np.zeros(mask.shape)
    
    for basevoxel in range(0, numvoxels):
        x,y,z = indices[basevoxel,:]
        
        if radius is None:
            subset = np.arange(numvoxels) != basevoxel
        else:
            distance = np.sum(np.square(((indices-indices[basevoxel,:]) * voxsize)), axis=1)
            if radius > 0:
                subset = distance > radius**2
            else:
                subset = distance <= radius**2
                subset[basevoxel] = False
        
        rvalues = np.dot(imgts, imgts[basevoxel].T) / numtps
        
        zvalues = np.arctanh(rvalues[subset])
                
        result[x,y,z] = np.nanmean(zvalues)

    return result

def dcbc_argparser():
    parser = argparse.ArgumentParser(
            description=('Computes distance-constrained brain connectivity '
            'value for each voxel in the provided mask.'))
    parser.add_argument('input', metavar='DATASET', help='Input rsfMRI dataset')
    parser.add_argument('-o', '--output', metavar='OUTPUT',
            help='Output filename', required=True)
    parser.add_argument('-m', '--mask', metavar='MASK', help='Voxel mask',
            required=True)
    parser.add_argument('-r', '--radius', metavar='RADIUS',
            help=('Radius. If not provided, the script computes global brain '
            'connectivity, i.e. it takes one voxel at a time, calculates '
            'its correlation voxel with every other voxel in the mask '
            '(itself excluded), converts these values to Fisher\'s z and '
            'averages them. '
            'If the radius is a negative value, the script computes local '
            'connectivity, i.e. it takes into account only voxels whose '
            'centers are within the absolute value of the  radius. If it '
            'is a positive value, '
            'it takes into account only voxels in the mask whose centers '
            'are further away than the given radius.'), type=float)
    return parser

def main():
    args = dcbc_argparser().parse_args()

    img = nib.load(args.input)
    mask = nib.load(args.mask)

    result = dcbc(img, mask, args.radius)

    nib.save(nib.Nifti1Image(result, img.get_affine()), args.output)

if __name__ == "__main__":
    main()
