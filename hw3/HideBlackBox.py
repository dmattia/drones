import random
import math

#Coordinates
right = -86239092
left = -86240807
top = 41519441
bottom = 41518968

#***********************************************************************************************************************
# Generate coordinates for the black box
#***********************************************************************************************************************
def hideBlackBox():

    verticalRange = top-bottom
    horizontalRange = left-right

    # Create latitude
    i=0
    randNum = random.random()
    verticalOffSet = randNum* verticalRange
    newLatitude = (bottom+verticalOffSet)/1000000
    newLatitude = '%.6f'%(newLatitude)
    
    # Create longitude
    randNum = random.random()
    horizontalOffSet = randNum* horizontalRange
    newLongitude = (left-horizontalOffSet)/1000000
    newLongitude = '%.6f'%(newLongitude)

    return (newLatitude, newLongitude, 0)

#***********************************************************************************************************************
# Compute distance between two locations
#***********************************************************************************************************************
def get_distance_metres(aLocation1, aLocation2):
    dlat = aLocation2.lat - aLocation1.lat
    dlong = aLocation2.lon - aLocation1.lon
    return math.sqrt((dlat*dlat) + (dlong*dlong)) * 1.113195e5

#***********************************************************************************************************************
# Check if in proximity or at coordinates
#***********************************************************************************************************************
def distanceToBlackBox(currentLocation, hiddenLocation):
    distance= get_distance_metres(currentLocation,hiddenLocation)
    if distance <= 5:
    	 return distance
    else:
    	 return -1
