#Code in python to first remove the background from the videoself.
#Then this code does edge analysis on the image with the background subtracted


import numpy as np
import cv2 as cv

cap = cv.VideoCapture('vtest.avi')

fgbg = cv.bgsegm.createBackgroundSubtractorMOG()

edges = cv.Canny()

while(1):
    ret, frame = cap.read()
    fgmask = fgbg.apply(frame)
    cv.imshow('frame',fgmask)
    edge_show = edges(fgmask, 100, 200)

    plt.subplot(121),plt.imshow(img,cmap = 'gray')
    plt.title('Original Image'), plt.xticks([]), plt.yticks([])
    plt.subplot(122),plt.imshow(edges,cmap = 'gray')
    plt.title('Edge Image'), plt.xticks([]), plt.yticks([])

    plt.show()

    k = cv.waitKey(30) & 0xff
    if k == 27:
        break



cap.release()
cv.destroyAllWindows()

#Done
