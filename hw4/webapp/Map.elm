port module Clicker exposing (..)

import Html exposing (div, button, text)
import Html.App as App
import Html.Events exposing (onClick)
import Html.Attributes exposing (disabled, id)

type Msg 
  = PanMap Float Float

type alias Model =
  { map : Map
  }

type alias Map =
  { latitude : Float
  , longitude : Float
  , zoomLevel : Int
  }

port mapData : Map -> Cmd msg

main =
  App.program
    { init = (model, Cmd.none)
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none
    }
    
model =
  { map = startMap
  }

startMap =
  { latitude = 48.869317,
    longitude = 2.30,
    zoomLevel = 8
  }

valueButton caption action isDisabled =
  button [ disabled isDisabled, onClick action ] [ text caption ]

panMap : Map -> Float -> Float -> Map
panMap map dlat dlng =
  { map | latitude = map.latitude + dlat, longitude = map.longitude + dlng }

view model =
  div []
    [ button [ onClick (PanMap 0.05 0.00) ] [ text "Pan Up"]
    , button [ onClick (PanMap 0.00 0.05) ] [ text "Pan Right"]
    , button [ onClick (PanMap 0.00 -0.05) ] [ text "Pan Left"]
    , button [ onClick (PanMap -0.05 0.00) ] [ text "Pan Down"]
    , div [id "map" ] []
    ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    PanMap dlat dlng ->
      let
        map = model.map
        newMap = panMap map dlat dlng
      in 
        ( { model | map = newMap }, mapData newMap )
