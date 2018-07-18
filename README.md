# OpenPhysicsTracker

Hello world ,

This repo contains some brief code that I wrote when I was working with Prof Sabyasachi Bhattacharya on a self organizing system research project at TIFR.

The goal is to be able to detect and track objects in the frame, to gain insights into the system behaviour.

The original dataset will not be available due to certain IP reasons, however I'll create a new one and attach it to this repo.

## Object_Tracking_MATLAB.m

Ths extracts the objects and implements a kalman filter to do the same. This is pretty high level code in matlab.

## Multiple-object-tracking.py

This is the code in python to first remove the background from the videoself.
Then this code does edge analysis on the image with the background subtracted.
