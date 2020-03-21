#-*- coding: UTF-8
from __future__ import print_function
import clr
import System
import System.IO
dllname=r"""Autho.dll""" ;
clr.AddReferenceToFileAndPath( dllname   )
import  Autho

Autho.mainEntry()