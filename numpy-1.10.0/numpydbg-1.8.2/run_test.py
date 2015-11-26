import sys
import platform
import numpy

#if platform.machine() != 'armv6l':
    #import numpy.core._dotblas

import numpy.core.multiarray
import numpy.core.multiarray_tests
import numpy.core.scalarmath
import numpy.core.umath
import numpy.core.umath_tests
import numpy.fft.fftpack_lite
import numpy.lib._compiled_base
import numpy.linalg.lapack_lite
import numpy.numarray._capi
import numpy.random.mtrand

#from numpy.fft import using_mklfft

sys.gettotalrefcount()

if sys.platform == 'win32' and sys.version_info[0] == 3:
    print('Not running numpy tests Windows on Py3k')
else:
    numpy.test()

try:
    print('MKL: %r' % numpy.__mkl_version__)
except AttributeError:
    print('NO MKL')

#print('USING MKLFFT: %s' % using_mklfft)
