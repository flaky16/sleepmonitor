# -*- coding: utf-8 -*-
"""
Created on Mon Nov 19 10:41:11 2018

@author: Ana Villanueva
"""

import numpy as np
import pylab as pl
#while True:
with open('testonlyxdelay5.hex', 'r') as fp:
    hex_list = ["{:02x}".format(ord(c)) for c in fp.read()]
    print(hex_list)

x = []
y = []
z = []
#t = []
mark =[]
#print(np.shape(hex_list)[0])
for i in range(np.shape(hex_list)[0]):
    #print(int(hex_list[i], 16))
    if int(hex_list[i] , 16) == 255 and int(hex_list[i-3] , 16) != 255 and int(hex_list[i-2] , 16) != 255 and int(hex_list[i-1] , 16) != 255:
        x_i = int(hex_list[i-3] , 16)
        y_i = int(hex_list[i-2] , 16)
        z_i = int(hex_list[i-1] , 16)#-28 
        #t_i = int(hex_list[i-1] , 16)
        keyi = int(hex_list[i] , 16)
        x.append(x_i)
        y.append(y_i)
        z.append(z_i)
       # t.append(t_i)
        mark.append(keyi)
        
# =============================================================================
# for i in np.linspace(90 , 193 , 104):
#     print(i)
#     i = int(i)
#     print(hex_list[i])
#     x_i = int( hex_list[5*i+3] , 16)
#     y_i = int( hex_list[5*i+4] , 16)
#     z_i = int( hex_list[5*i+5] , 16)
#     t_i = int( hex_list[5*i+6] , 16)-14
#     mark_i = int( hex_list[5*i+7] , 16)
#     x.append(x_i)
#     y.append(y_i)
#     z.append(z_i)
#     t.append(t_i)
#     mark.append(mark_i)
# =============================================================================
    
#newx = np.linspace(0,3*9.8,5000)
#for i in range(np.shape(x)[0]):
    #newx[x[i]] = newx[i]

newt = np.arange(0, np.shape(x)[0]*1.05, 1.05)
pl.plot(newt , x , '--')
pl.plot(newt , y , '--')
pl.plot(newt , z)
print(x)
print(y)
print(z)
print(newt)
print(mark)
pl.ylim(0,50)
pl.xlim(np.shape(newt)[0]-100, np.shape(newt)[0])
pl.xlabel('Time (s)')
pl.ylabel('Voltage (mV)')