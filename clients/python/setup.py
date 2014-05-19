from distutils.core import setup
from os.path import join as pjoin

setup(
    name='gfx.js',
    version='0.1dev',
    packages=['gfx'],
    scripts=[pjoin('bin','gfx-start'), pjoin('bin','gfx-stop')],
)
