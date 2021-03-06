from dronekit import VehicleMode, LocationGlobalRelative, connect
from functools import wraps
from time import sleep
from math import sqrt

import dronekit_sitl

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
          if self.altitude >= min_altitude:
            print "Altitude check cleared, current altitude is "\
                + str(self.altitude) + " meters"
            return function(self, *args, **kwargs)
          else:
            print "Could not run " + function.__name__
            print "The current altitude of " + str(self.altitude)\
                + " does not meet the requirement of " + str(min_altitude)
        except AttributeError:
          print "Could not find altitude of vehicle"  
        return lambda x: x
      return inner
    return decorator  

  def __init__(self, connection_string=None):
    self.sitl = None
    self.connection_string = connection_string
    self.end_conditions = []

    if self.connection_string is None:
      self.sitl = dronekit_sitl.start_default()
      self.connection_string = self.sitl.connection_string()

    print "Connecting to vehicle on: " + self.connection_string
    self.vehicle = connect(self.connection_string, wait_ready=True)

    self.vehicle.add_attribute_listener('mode', self.mode_change_callback)

  def __enter__(self):
    return self

  def __exit__(self, exc_type, exc_value, traceback):
    if self.vehicle.mode.name != "RTL" and self.vehicle.mode.name != "LAND":
      print "Returning to Launch"
      self.set_mode("RTL")

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
  def altitude(self):
    return self.vehicle.location.global_relative_frame.alt

  @property
  def end_conditions_met(self):
    """ Returns True if any end condition returns true
    """
    for end_condition in self.end_conditions:
      if end_condition():
        return True
    return False

  def add_end_condition(self, new_end_condition):
    self.end_conditions.append(new_end_condition)

  def set_mode(self, mode_name):
    self.vehicle.mode = VehicleMode(mode_name)

  def arm(self):
    """ Arms the vehicle
    """
    while not self.vehicle.is_armable:
      print "Waiting for vehicle to become armable"
      sleep(1)
    print "Vehicle is armable"
  
    self.set_mode("GUIDED")
    self.vehicle.armed = True
  
    while not self.vehicle.armed:
      print "Waiting for vehicle to arm"
      sleep(1)
    print "Vehicle is armed"

  def takeoff_to(self, targetAltitude):
    """ Arms a vehicle and rises to @targetAltitude above the ground
    """
    print "Taking off"
    self.vehicle.simple_takeoff(targetAltitude)
    
    while self.altitude < targetAltitude * .95:
      print "Altitude: " + str(self.altitude)
      sleep(3)
    print "Reached desired altitude. Current altitude is: " + str(self.altitude)
  
  def get_distance_in_meters_to(self, destination):
    """ Estimates the difference between two points,
        does not take into account the curvature of the earth
    """
    dlat = destination.lat - self.location.lat
    dlong = destination.lon - self.location.lon
    return sqrt(dlat**2 + dlong**2) * 1.113195e5

  def is_close_to(self, location, max_meters=5):
    """ Returns if the vehicle is within @max_meters of @location
    """
    return self.get_distance_in_meters_to(location) < max_meters

  def follow_path(self, locationGlobals):
    """ Follows a path, maintaining altitude
    """
    for location in locationGlobals:
      if not self.end_conditions_met:
        print "Flying to location: " + str(location)
        self.fly_to(location, speed=15)

  @require_altitude(10)
  def fly_to(self, destination, speed=15):
    """ Maintains altitude and flies to a new locationGlobal Point.

    Args:
      destination: A LocationGlobal indicating the destination coordinate.
    """
    if destination.alt is None:
      destination.alt = self.altitude
    self.vehicle.arispeed = speed
    self.vehicle.simple_goto(destination)

    while not self.is_close_to(destination) and not self.end_conditions_met:
      #print "Remaining: " + str(self.get_distance_in_meters_to(destination))
      #print "Altitude: " + str(self.altitude)
      sleep(0.2)

    if self.is_close_to(destination):
      print "Reached destination"
    else:
      self.set_mode("LAND")
      print "An end condition was reached. Stopping"

  def mode_change_callback(self, *args, **kwargs):
    acceptable_modes = ["GUIDED", "LAND", "RTL"]
    print "Vehicle Mode Updated. New Value: " + self.vehicle.mode.name
    if self.vehicle.mode.name not in acceptable_modes:
      print "Exiting, vehicle is no longer in acceptable mode"
      self.__exit__(None, None, None)
