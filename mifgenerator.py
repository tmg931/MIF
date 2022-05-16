import cv2
from PIL import Image

#Convert image to 320x480 and grayscale
image = Image.open("GeslerHeadshot.jpg")
image = image.resize((320,480))
image = image.convert('L')
image = image.save('grayscale.jpg')

#Canny edge detection
newimage = cv2.imread("grayscale.jpg", 0)
canny = cv2.Canny(newimage, 60, 80)

#Concat. the grayscale image and canny image
outputimage = cv2.hconcat([newimage,canny])
cv2.imwrite('output.jpg', outputimage)

#Generate MIF header
f = open("Headshot.mif", "w")
f.write("depth= 307200;\nwidth = 8;\naddress_radix = dec;\ndata_radix = dec;\ncontent\nbegin\n")

#Generates the data part of the MIF
counter = 0
for i in range(480):
    for j in range(640):
        f.write(str(counter) + ":" + str(outputimage[i,j]) + ";\n") 
        counter = counter + 1
f.write("end;\n")
f.close()
