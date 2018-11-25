# -*- coding: utf-8 -*-
"""
Created on Mon Nov 19 10:41:11 2018

@author: Ana Villanueva
"""

import numpy as np
import pylab as pl

with open('testonlyxdelay5.hex', 'r') as fp:
    hex_list = ["{:02x}".format(ord(c)) for c in fp.read()]
    print(hex_list)

x = []
y = []
z = []
mark =[]
#print(np.shape(hex_list)[0])
for i in range(np.shape(hex_list)[0]):
    #print(int(hex_list[i], 16))
    if int(hex_list[i] , 16) == 255 and int(hex_list[i-3] , 16) != 255 and int(hex_list[i-2] , 16) != 255 and int(hex_list[i-1] , 16) != 255:
        x_i = int(hex_list[i-3] , 16) *3/255        
        y_i = int(hex_list[i-2] , 16) *3/255
        z_i = int(hex_list[i-1] , 16) *3/255
        keyi = int(hex_list[i] , 16) *3/255
        x.append(x_i)
        y.append(y_i)
        z.append(z_i)
        mark.append(keyi)
  

newt = np.arange(0, np.shape(x)[0]*0.13, 0.13)
pl.plot(newt , x , '--')
pl.plot(newt , y , '--')
pl.plot(newt , z)
print(x)
print(y)
print(z)
print(newt)
print(mark)
#pl.ylim(0,50)
#pl.xlim(np.shape(newt)[0]-100, np.shape(newt)[0])
pl.xlabel('Time (s)')
pl.ylabel('acceleration (g)')
