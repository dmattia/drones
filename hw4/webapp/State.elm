port module State exposing (initialState, update, mapData)

import Types exposing (..)

port mapData : Map -> Cmd msg

initialState : (Model, Cmd Msg)
initialState =
  ( model, mapData model.map )

model =
  { map = startMap
  }

startMap =
  { lat = 48.869317
  , lng = 2.30
  }

panMap map dlat dlng =
  { map | lat = map.lat + dlat, lng = map.lng + dlng }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    PanMap dlat dlng ->
      let
        map = model.map
        newMap = panMap map dlat dlng
      in
        ( { model | map = newMap }, mapData newMap )
