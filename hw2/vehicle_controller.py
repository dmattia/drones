from dronekit import VehicleMode, LocationGlobalRelative, connect
from functools import wraps
from time import sleep

import dronekit_sitl
import math

class VehicleController(object):
  """ Wrapper around dronekit vehicle object to make commands
      synchronous.
  """
  def require_altitude(min_altitude=10):
    """ Modifies a function to require a min_altitude.
        If min_altitude is not met, a warning is printed,
        but no error is thrown.
    """
    def decorator(function):
      @wraps(function)
      def inner(self, *args, **kwargs):
        try:
          altitude = self.vehicle.location.global_relative_frame.alt
          if altitude >= min_altitude:
            print "Altitude check cleared, current altitude is "\
                + str(altitude) + " meters"
            return function(self, *args, **kwargs)
          else:
            print "Could not run " + function.__name__
            print "The current altitude of " + str(altitude)\
                + " does not meet the requirement of " + str(min_altitude)
        except AttributeError:
          print "Could not find altitude of vehicle"  
        return lambda x: x
      return inner
    return decorator  

  def __init__(self, connection_string=None):
    self.sitl = None
    if connection_string is None:
      self.sitl = dronekit_sitl.start_default()
      self.connection_string = self.sitl.connection_string

    print "Connecting to vehicle on: " + connection_string
    self.vehicle = connect(connection_string, wait_ready=True)

  def __enter__(self):
    return self

  def __exit__(self, exc_type, exc_value, traceback):
    print "Cleaning up VehicleController object"
    self.vehicle.close()
    if self.sitl is not None:
      sitl.stop()
    print "Exiting"

  @property
  def location(self):
    """ Returns the current position of the vehicle
        as a LocationGlobal
    """
    return self.vehicle.location.global_frame

  @property
  def is_guided(self):
    return self.vehicle.mode.name == "GUIDED"

  def arm(self):
    """ Arms the vehicle
    """
    while not self.vehicle.is_armable:
      "Waiting for vehicle to arm"
      sleep(1)
    print "Vehicle is armable"
  
    self.vehicle.mode = VehicleMode("GUIDED")
    self.vehicle.armed = True
  
    while not self.vehicle.armed:
      print "Waiting for vehicle to arm"
      sleep(1)
    print "Vehicle is armed"

  def takeoff_to(self, targetAltitude):
    """ Arms a vehicle and rises to @targetAltitude above the ground
    """
    self.vehicle.simple_takeoff(targetAltitude)
    
    while self.vehicle.location.global_relative_frame.alt < targetAltitude * .95:
      print "Altitude: " + str(self.vehicle.location.global_relative_frame.alt)
      sleep(1)

  def get_distance_in_meters_to(self, destination):
    """ Estimates the difference between two points,
        does not take into account the curvature of the earth
    """
    dlat = destination.lat - self.location.lat
    dlong = destination.lon - self.location.lon
    return math.sqrt(dlat**2 + dlong**2) * 1.113195e5

  def is_close_to(self, location, max_meters=10):
    """ Returns if the vehicle is within @max_meters of @location
    """
    return self.get_distance_in_meters_to(location) < max_meters

  @require_altitude(40)
  def fly_to(self, destination, speed=10):
    """ Maintains altitude and flies to a new locationGlobal Point.

    Args:
      destination: A LocationGlobal indicating the destination coordinate.
    """
    self.vehicle.arispeed = speed
    self.vehicle.simple_goto(destination)

    while self.is_guided:
      if self.is_close_to(destination):
        print "Reached target"
        break
