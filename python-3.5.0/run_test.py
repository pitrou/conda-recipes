import platform
import sys
import subprocess

armv6 = bool(platform.machine() == 'armv6l')
if sys.platform == 'darwin':
    osx105 = b'10.5.' in subprocess.check_output('sw_vers')
else:
    osx105 = False

print('sys.version:', sys.version)
print('sys.platform:', sys.platform)
print('sys.abiflags:', sys.abiflags)
print('tuple.__itemsize__:', tuple.__itemsize__)
if sys.platform == 'win32':
    assert 'MSC v.1600' in sys.version
print('sys.maxunicode:', sys.maxunicode)
print('platform.architecture:', platform.architecture())
print('platform.python_version:', platform.python_version())
sys.gettotalrefcount()  # Ensure ref tracking enabled

import _bisect
import _codecs_cn
import _codecs_hk
import _codecs_iso2022
import _codecs_jp
import _codecs_kr
import _codecs_tw
import _collections
import _csv
import _ctypes
import _ctypes_test
import _elementtree
import _functools
import _hashlib
import _heapq
import _io
import _json
import _locale
import _lsprof
import _multibytecodec
import _multiprocessing
import _random
import _socket
import _sqlite3
import _ssl
import _struct
import _testcapi
import array
import audioop
import binascii
import bz2
import cmath
import datetime
import itertools
import math
import mmap
import operator
import parser
import pyexpat
import select
import time
import unicodedata
import zlib
from os import urandom

if sys.platform != 'win32':
    import _curses
    import _curses_panel
    import crypt
    import fcntl
    import grp
    import nis
    #import readline
    import resource
    import syslog
    import termios

if not (armv6 or osx105):
    import tkinter
    import turtle
    import _tkinter
    print('TK_VERSION: %s' % _tkinter.TK_VERSION)
    print('TCL_VERSION: %s' % _tkinter.TCL_VERSION)
    TCLTK_VER = '8.6' if sys.platform == 'win32' else '8.5'
    assert _tkinter.TK_VERSION == _tkinter.TCL_VERSION == TCLTK_VER

if sys.version_info >= (3, 3):
    import _decimal

import ssl
print('OPENSSL_VERSION:', ssl.OPENSSL_VERSION)
if sys.platform != 'win32':
    assert '1.0.1h' in ssl.OPENSSL_VERSION
