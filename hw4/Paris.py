# Generates 100 jobs in the Paris area.
# Each job consists of starting coordinates and ending coordinates.
# In this test file we randomly generate the coordinates and then save them into a .json file for display in Google Maps.
import random

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
        return {
          "lat": self.startCoords[0],
          "lng": self.startCoords[1],
        }
    def getEnd(self):
        return {
          "lat": self.endCoords[0],
          "lng": self.endCoords[1],
        }
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

#*********************************
# Creates 100 jobs in json format
#*********************************
def getJson():
  deliveryJobs = [deliveryRequest(x) for x in range(0, 100)]
  jobDict = {}
  for job in deliveryJobs:
    jobDict["Job" + str(job.getJobID())] = {
      "id": job.getJobID(),
      "start": job.getStart(),
      "end": job.getEnd(),
    }
  return jobDict

if __name__ == "__main__":
  print(getJson())
