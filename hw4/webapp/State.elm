port module State exposing (initialState, update, subscriptions, mapData)

import Time exposing (Time, second)

import Types exposing (..)

port mapData : Location -> Cmd msg
port chargingData : List ChargingStation -> Cmd msg

initialState : (Model, Cmd Msg)
initialState =
  ( model, Cmd.none )

model =
  { map = startMap
  , chargingStations =
      [ {location = { lat = 48.858093, lng = 2.296604}, name = "Eifel Tower"}
      , {location = { lat = 48.846185, lng = 2.346708}, name = "Pantheon"}
      , {location = { lat = 48.864446, lng = 2.325283}, name = "Jardin des Tuileries"}
      ]
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

    Ready isReady ->
      ( model, chargingData model.chargingStations )

    Tick time ->
      ( model, Cmd.none )

-- Subscriptions

port isReady : ( Bool -> msg ) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  --Time.every ( second / 1 ) Tick
  isReady Ready

