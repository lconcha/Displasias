#!/usr/bin/env python 

import argparse
import amico

parser = argparse.ArgumentParser()
parser.add_argument('dwi')
parser.add_argument('bvec')
parser.add_argument('bval')
parser.add_argument('mask')
parser.add_argument('outdir')
args = parser.parse_args()


dwi  = args.dwi
bvec = args.bvec
bval = args.bval
mask = args.mask
outdir = args.outdir


print('Will run NODDI-AMICO with the following files:')
print( f'  + DWI     : { dwi }' )
print( f'  + bval    : { bval }' )
print( f'  + bvec    : { bvec }' )
print( f'  + mask    : { mask }' )
print( f'  + outbase : { outdir }' )


amico.setup()
ae = amico.Evaluation()
scheme = amico.util.fsl2scheme(bval,bvec,"/tmp/scheme.txt")
print( f'  + scheme  : { scheme }' )
ae.load_data(dwi, scheme, mask_filename=mask, b0_thr=0)
ae.set_model('NODDI')
ae.set_config('OUTPUT_path',outdir)

ae.generate_kernels()
ae.load_kernels()
ae.fit()
ae.save_results()
