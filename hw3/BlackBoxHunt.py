from argparse import ArgumentParser
from vehicle_controller import VehicleController
from dronekit import LocationGlobal
from HideBlackBox import hideBlackBox, distanceToBlackBox, get_distance_metres
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

  vehicle_height = 20
  
  # Create the flying zone
  right = -86.239092
  left = -86.240807
  top = 41.519441
  bottom = 41.518968

  upper_left = LocationGlobal(left, top)
  upper_right = LocationGlobal(right, top)
  lower_left = LocationGlobal(left, bottom)
  lower_right = LocationGlobal(right, bottom)

  flyable_area = FlyableArea([upper_left, upper_right, lower_left, lower_right])

  # Start the copter controller
  with VehicleController(args.connect) as vehicle_controller:
    vehicle_controller.arm()
    vehicle_controller.takeoff_to(vehicle_height)

    def found_box():
      dist = get_distance_metres(vehicle_controller.location, hiddenLocation)
      print "Distance from box in meters: " + str(dist)
      return dist <= 5

    vehicle_controller.add_end_condition(found_box)
    to_explore = flyable_area.reduce_by_size(num_meters=5)
    while to_explore.area_in_meters > 5 and not vehicle_controller.end_conditions_met:
      vehicle_controller.follow_path(to_explore.hull_vertices)
      to_explore = to_explore.reduce_by_size(num_meters=10)

    print "Found the box"
