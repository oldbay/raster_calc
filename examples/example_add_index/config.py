#!/usr/bin/python2
# -*- coding: utf-8 -*-

import importlib

# Import scripts for calculate raster
calc_methods = {
    "sarvi": importlib.import_module("sarvi_index"),
}
