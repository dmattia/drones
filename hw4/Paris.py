# Generates 100 jobs in the Paris area.
# Each job consists of starting coordinates and ending coordinates.
# In this test file we randomly generate the coordinates and then save them into a .json file for display in Google Maps.
import random
import UpdateJSON
from dronekit import LocationGlobalRelative

#Coordinates
right = 2.399188
left = 2.278953
top = 48.869317
bottom = 48.839458


#***********************************************************************************************************************
# Create a class to represent a delivery request
# Feel free to edit this class for the assignment but retain start and end coords.
#***********************************************************************************************************************
class deliveryRequest:
    startCoords = (0,0,0)
    endCoords = (0,0,0)
    jobID = ""
    def __init__(self,jobNum):
        self.jobID = jobNum
        self.startCoords = generateCoordinate()
        self.endCoords = generateCoordinate()
    def getStart(self):
        return LocationGlobalRelative(self.startCoords[0],self.startCoords[1],self.startCoords[2])
    def getEnd(self):
        return LocationGlobalRelative(self.endCoords[0],self.endCoords[1],self.endCoords[2])
    def getJobID(self):
        return self.jobID


#***********************************************************************************************************************
# Generate coordinates for the black box
#***********************************************************************************************************************
def generateCoordinate():
    mRight = right * 1000000
    mLeft = left*1000000
    mTop = top * 1000000
    mBottom = bottom * 1000000

    verticalRange = mTop-mBottom
    horizontalRange = mLeft-mRight

    # Create latitude
    i=0
    randNum = random.random()
    verticalOffSet = randNum* verticalRange
    newLatitude = (mBottom+verticalOffSet)/1000000
    
    # Create longitude
    randNum = random.random()
    horizontalOffSet = randNum* horizontalRange
    newLongitude = (mLeft-horizontalOffSet)/1000000

    return (newLatitude, newLongitude,0)

# Generate 100 jobs
deliveryJobs = []
for jobNum in range(0, 100):
    job = deliveryRequest(jobNum)
    deliveryJobs.append(job);  
    jobName = "Job" + str(job.getJobID())
    #Show starting coordinates.
    UpdateJSON.updateMapCoordinateData(jobName, job.getStart().lat, job.getStart().lon)
UpdateJSON.generateNewFile()


# You can turn this off
print "Sanity check: You can turn this off though"
print "Iterate through list of generated coordinates"
for job in deliveryJobs:
    print job.getJobID()
    print job.getStart()
    print job.getEnd()
    print
