module Types exposing (..)

import Time exposing (Time)
import Http

type Msg
  = PanMap Float Float
  | Tick Time
  | Ready Bool
  | FetchSucceed (List Job)
  | FetchFail Http.Error
  | NewJobs (List Job)

type alias ChargingStation =
  { name : String,
    location : Location
  }

type alias Model =
  { map : Location
  , chargingStations : List ChargingStation
  , drones : List Drone
  , mapReady : Bool
  , jobs : List Job
  , time : Float
  , startTime : Float
  , speedup : Float
  }

type alias Location =
  { lat : Float
  , lng : Float
  }

type alias Job =
  { id : Int
  , start : Location
  , end : Location
  }

type alias Drone =
  { id : String
  , location : Location
  , status : String
  , currentJob : Job
  , charge : Float
  }
