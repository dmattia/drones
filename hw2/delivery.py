from argparse import ArgumentParser
from vehicle_controller import VehicleController
from dronekit import LocationGlobal

parser = ArgumentParser(description="Command vehicles")
parser.add_argument('--connect', help='Vehicle Connection String Target.')
args = parser.parse_args()

with VehicleController(args.connect) as vehicle_controller:
  vehicle_controller.arm()
  vehicle_controller.takeoff_to(100)
  vehicle_controller.fly_to(LocationGlobal(41.7, -86.237771, 100), speed=15)
