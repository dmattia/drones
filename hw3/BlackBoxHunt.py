from argparse import ArgumentParser
from vehicle_controller import VehicleController
from dronekit import LocationGlobal
from HideBlackBox import hideBlackBox, distanceToBlackBox
from spatial import FlyableArea

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

  vehicle_height = 100
  
  # Create the flying zone
  right = -86.239092
  left = -86.240807
  top = 41.519441
  bottom = 41.518968

  upper_left = LocationGlobal(left, top)
  upper_right = LocationGlobal(right, top)
  lower_left = LocationGlobal(left, bottom)
  lower_right = LocationGlobal(right, bottom)

  flyableArea = FlyableArea([upper_left, upper_right, lower_left, lower_right])

  # Start the copter controller
  with VehicleController(args.connect) as vehicle_controller:
    print distanceToBlackBox(vehicle_controller.location, hiddenLocation)
    vehicle_controller.arm()
    vehicle_controller.takeoff_to(vehicle_height)

    vehicle_controller.explore(flyableArea)
