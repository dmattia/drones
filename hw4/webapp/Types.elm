module Types exposing (..)

import Time exposing (Time)

type Msg
  = PanMap Float Float
  | Tick Time
  | Ready Bool

type alias ChargingStation =
  { name : String,
    location : Location
  }

type alias Model =
  { map : Location
  , chargingStations : List ChargingStation
  , drones : List Drone
  , mapReady : Bool
  }

type alias Location =
  { lat : Float
  , lng : Float
  }

type alias Drone =
  { id : String
  , location: Location
  }
