module Types exposing (..)

type Msg
  = PanMap Float Float

type alias Model =
  { map : Map
  }

type alias Map =
  { lat : Float
  , lng : Float
  }
