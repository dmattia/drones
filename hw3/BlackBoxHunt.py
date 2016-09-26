from argparse import ArgumentParser
from vehicle_controller import VehicleController
from dronekit import LocationGlobal
from HideBlackBox import hideBlackBox, distanceToBlackBox

if __name__ == "__main__":
  # Parse arguments
  parser = ArgumentParser(description="Command vehicles")
  parser.add_argument('--connect',
    help='Vehicle Connection String Target.',
    default='127.0.0.1:14551')
  args = parser.parse_args()

  # Setup black box
  hiddenCoords = hideBlackBox()
  hiddenLocation = LocationGlobal(
    float(hiddenCoords[0]),
    float(hiddenCoords[1]),
    float(hiddenCoords[2]))
  print "Hidden Location: " + str(hiddenLocation)

  vehicle_height = 11
  
  with VehicleController(args.connect) as vehicle_controller:
    print distanceToBlackBox(vehicle_controller.location, hiddenLocation)
    vehicle_controller.arm()
    vehicle_controller.takeoff_to(vehicle_height)
