port module State exposing (initialState, update, subscriptions, mapData)

import Time exposing (Time, second)

import Types exposing (..)

port mapData : Location -> Cmd msg
port chargingData : List ChargingStation -> Cmd msg
port drones : List Drone -> Cmd msg

initialState : (Model, Cmd Msg)
initialState =
  ( model, Cmd.none )

model : Model
model =
  { map = startMap
  , chargingStations =
    [ {location = { lat = 48.858093, lng = 2.296604}, name = "Eifel Tower"}
    , {location = { lat = 48.846185, lng = 2.346708}, name = "Pantheon"}
    , {location = { lat = 48.864446, lng = 2.325283}, name = "Jardin des Tuileries"}
    ]
  , drones = 
    [ Drone "1" (Location 48.858093 2.296604)
    , Drone "2" (Location 48.858093 2.296604)
    , Drone "3" (Location 48.858093 2.296604)
    , Drone "4" (Location 48.858093 2.296604)
    , Drone "5" (Location 48.858093 2.296604)
    , Drone "6" (Location 48.846185 2.346708)
    , Drone "7" (Location 48.846185 2.346708)
    , Drone "8" (Location 48.846185 2.346708)
    , Drone "9" (Location 48.846185 2.346708)
    , Drone "10" (Location 48.846185 2.346708)
    ]
  , mapReady = False
  }

startMap : Location
startMap =
  { lat = 48.869317
  , lng = 2.30
  }

panMap : Location -> Float -> Float -> Location
panMap map dlat dlng =
  { map | lat = map.lat + dlat, lng = map.lng + dlng }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    PanMap dlat dlng ->
      let
        map = model.map
        newMap = panMap model.map dlat dlng
      in
        if model.mapReady then
          ( { model | map = newMap }, mapData newMap )
        else
          ( { model | map = newMap }, Cmd.none )

    Ready isReady ->
      ( { model | mapReady = isReady }, chargingData model.chargingStations )

    Tick time ->
      if model.mapReady then
        let
          updatedDrones = updateDrones model.drones model.chargingStations
        in
          ( { model | drones = updatedDrones }, drones updatedDrones )
      else
        ( model, Cmd.none )

updateDrones : List Drone -> List ChargingStation -> List Drone
updateDrones drones chargingStations =
  case drones of
    [] ->
      []
    drone::remaining ->
      [updateDrone drone chargingStations] ++ (updateDrones remaining chargingStations)

updateDrone : Drone -> List ChargingStation -> Drone
updateDrone drone chargingStations =
  { drone | location = (Location (drone.location.lat + 0.001) drone.location.lng) }

-- Subscriptions

port isReady : ( Bool -> msg ) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Time.every ( second / 1 ) Tick
    , isReady Ready
    ]

