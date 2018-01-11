from setuptools import setup, find_packages
from os.path import join, dirname

setup(
    name='raster_calc',
    version='0.4',
    packages=find_packages(),
    long_description=open(join(dirname(__file__), 'README')).read(),
    entry_points={
        'console_scripts':
        ['raster_calc = raster_calc.util:run']
    },
    install_requires=[
        'raster_tools',
        'numpy'
    ]
)
