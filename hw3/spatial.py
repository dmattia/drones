""" Spatial Data Structures for working with dronekit python
"""

from dronekit import LocationGlobal, LocationGlobalRelative
from scipy.spatial import ConvexHull
from matplotlib.path import Path

import matplotlib.pyplot as plt
import numpy as np
import math

def get_distance_meters(aLocation1, aLocation2):
  dlat = aLocation2.lat - aLocation1.lat
  dlong = aLocation2.lon - aLocation1.lon
  return math.sqrt((dlat*dlat) + (dlong*dlong)) * 1.113195e5

def move_between_points(start_point, end_point, distance_to_move):
  """ Moves a maximum of @distance_to_move from the @start_point in the direction
      of @end_point. If @distance_to_move is larger than the distance between
      the two points, then the endpoint is returned.

      Returns: a LocationGlobal
  """
  total_dist = get_distance_meters(start_point, end_point)
  if distance_to_move > total_dist:
    return end_point
  x_change = (distance_to_move / total_dist) * (end_point.lat - start_point.lat)
  y_change = (distance_to_move / total_dist) * (end_point.lon - start_point.lon)
  return LocationGlobal(
    start_point.lat + x_change,
    start_point.lon + y_change
  )

class FlyableArea(object):
  """ A collection of LocationGlobal points that defines free space.
      All area contained between the Convex hull of all points is defined as flyable.

      I chose to use any arbitrary set of coordinates and not a rectangle because I will want
      non-rectangular spatial areas in the next homework.
  """
  def __init__(self, locationGlobals):
    self._location_globals = locationGlobals
    self._points = np.array([[loc.lat, loc.lon] for loc in locationGlobals])

  @property
  def area_in_meters(self):
    return self.hull.area * 1.113195e5

  @property
  def hull(self):
    hull = ConvexHull(self._points) 
    return hull

  @property
  def locations(self):
    return self._location_globals

  @property
  def num_points(self):
    return len(self.locations)

  @property
  def center(self):
    x_sum = 0
    y_sum = 0
    for point in self.locations:
      x_sum += point.lat
      y_sum += point.lon
    return LocationGlobal(x_sum / self.num_points, y_sum / self.num_points)

  @property
  def hull_vertices(self):
    """ Returns a list of LocationGlobal objects that make up the convexHull
    """
    vertices = []
    for verticy_index in self.hull.vertices:
      point = self._points[verticy_index]
      verticy = LocationGlobalRelative(point[1], point[0])
      vertices.append(verticy)
    return vertices

  def reduce_by_size(self, num_meters):
    """ Reduces a shape by @num_meters meters. It does this by moving every verticy on the
        convex hull of this shape @num_meters meters towards the center of this shape.

        Note: This only adds points on the convex hull to the returned value, not any interior points.
    """
    locations = []
    for verticy in self.hull_vertices:
      # Find a point that is @num_meters towards the center
      verticy = LocationGlobalRelative(verticy.lon, verticy.lat)
      new_point = move_between_points(verticy, self.center, num_meters) 
      locations.append(new_point)
    return FlyableArea(locations)
      
  def is_in_area(self, locationGlobal):
    """ Returns if a given locationGlobal is inside of this shape's convex hull.
    """
    point = np.array((locationGlobal.lat, locationGlobal.lon))
    hull_path = Path(self._points[self.hull.vertices])
    return hull_path.contains_point((locationGlobal.lat, locationGlobal.lon))

  def draw_hull(self):
    """ Draws, but does not display, all points along with an outlined
        convex hull. A call to plt.show() must be made to show this shape.
    """
    plt.plot(self._points[:,0], self._points[:,1], 'o')
    for simplex in self.hull.simplices:
      plt.plot(self._points[simplex, 0], self._points[simplex, 1], 'k-')

if __name__ == "__main__":
  right = -86.239092
  left = -86.240807
  top = 41.519441
  bottom = 41.518968

  # Create an area from some random points
  upper_left = LocationGlobal(left, top)
  upper_right = LocationGlobal(right, top)
  lower_left = LocationGlobal(left, bottom)
  lower_right = LocationGlobal(right, bottom)
  high = LocationGlobal((right + left) / 2, top + (top - bottom))
  low = LocationGlobal((right - left) / 3 + left, bottom - (top - bottom)) 
  flyable_area = FlyableArea([upper_left, upper_right, lower_left, lower_right, high, low])

  to_explore = flyable_area
  while to_explore.area_in_meters > 50:
    to_explore.draw_hull()
    to_explore = to_explore.reduce_by_size(10)

  plt.show()
