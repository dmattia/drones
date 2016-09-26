"""
  File Name: Deliveries.py
  Author: David Mattia
  Python Version: 2.7
  Description: This file contains two parts:
    1) The DeliverySpot class, explained in its docstring.
    2) Executable code for when this file is ran. This code reads in text from
       a file, parses it into DeliverySpot objects, computes the shortest path
       from the base to all other spots and back to the base, and moves a
       copter drone along this path. 
"""

from argparse import ArgumentParser
from vehicle_controller import VehicleController
from dronekit import LocationGlobal
from itertools import permutations
from math import sqrt
import re

class DeliverySpot(object):
  """ A location to deliver an item to.
      Represents one line from the input text files.

      Each line should be in the order:
      Person Name, Location Name, Order type, latitude, longitude
  """
  def __init__(self, line):
    """ Read in a line and store line contents into variables
    """
    raw_args = re.compile(", *").split(line.strip())
    try:
      self.name = raw_args[0]
      self.location_name = raw_args[1]
      self.pizza_type = raw_args[2]
      self.latitude = float(raw_args[3])
      self.longitude = float(raw_args[4])
    except IndexError:
      print "Could not understand: " + line
      exit(1)
    except TypeError:
      print "Ensure latitude and longitude are represented as floats"
      exit(1)

  def distance_to_in_meters(self, other):
    """ Returns the distance to another DeliverySpot in meters.
    """
    dlat = other.latitude - self.latitude
    dlong = other.longitude - self.longitude
    return sqrt(dlat**2 + dlong**2) * 1.113195e5

  def __str__(self):
    """ toString method for printing
    """
    return self.location_name

def find_path_distance_meters(path):
  """ Takes in a path, a list of DeliverySpots,
      And returns the distance in meters to
      travel along that complete path.
  """
  path_length = 0
  for i in xrange(len(path)-1):
    path_length += path[i].distance_to_in_meters(path[i+1])
  return path_length

if __name__ == "__main__":
  # Parse arguments
  parser = ArgumentParser(description="Command vehicles")
  parser.add_argument('--connect', help='Vehicle Connection String Target.')
  args = parser.parse_args()
  
  # Read in lines from file
  with open("SouthBendDelivery.txt", "r") as pizzaFile:
    lines = pizzaFile.readlines()
  
  # Create DeliverySpot objects for each line
  delivery_locs = map(DeliverySpot, lines)
  home = delivery_locs[0]
  to_deliver_to = delivery_locs[1:]

  # Find all possible paths
  possible_paths = [[home] + list(path) + [home] for path in permutations(to_deliver_to)]

  # Find the path length for each path
  path_lengths = map(find_path_distance_meters, possible_paths)

  # Create a list of tuple of type (path_list, path_distance)
  zipped = zip(possible_paths, path_lengths)

  # Find the tuple with the shortest path length
  min_tuple = min(zipped, key = lambda x: x[1])

  # Get the path from this tuple
  shortest_path = min_tuple[0]

  # Print shortest path
  print "Flight location order:"
  print "\n".join(str(spot) for spot in shortest_path)
    
  # Execute flight path
  with VehicleController(args.connect) as vehicle_controller:
    vehicle_height = 100
    vehicle_controller.arm()
    vehicle_controller.takeoff_to(vehicle_height)

    # Fly to each spot in the path
    for spot in shortest_path:
      print "Delivering to " + spot.name + " @ " + spot.location_name
      loc = LocationGlobal(spot.latitude, spot.longitude, vehicle_height)
      vehicle_controller.fly_to(loc, speed=100)
