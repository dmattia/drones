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
    [ Drone "1" (Location 48.858093 2.296604) "Charging" (Job 0 startMap startMap) 0
    , Drone "2" (Location 48.858093 2.296604) "Charging" (Job 0 startMap startMap) 0
    , Drone "3" (Location 48.858093 2.296604) "Charging" (Job 0 startMap startMap) 0
    , Drone "4" (Location 48.858093 2.296604) "Charging" (Job 0 startMap startMap) 0
    , Drone "5" (Location 48.858093 2.296604) "Charging" (Job 0 startMap startMap) 0
    , Drone "6" (Location 48.846185 2.346708) "Charging" (Job 0 startMap startMap) 0
    , Drone "7" (Location 48.846185 2.346708) "Charging" (Job 0 startMap startMap) 0
    , Drone "8" (Location 48.846185 2.346708) "Charging" (Job 0 startMap startMap) 0
    , Drone "9" (Location 48.846185 2.346708) "Charging" (Job 0 startMap startMap) 0
    , Drone "10" (Location 48.846185 2.346708) "Charging" (Job 0 startMap startMap) 0
    ]
  , mapReady = False
  , jobs = []
  , time = 0
  , startTime = 0
  , speedup = 50
  }

startMap : Location
startMap =
  { lat = 48.8547673498851
  , lng = 2.336649703979452
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

    NewJobs newJobs ->
      ( { model | jobs = newJobs }, Cmd.none )

    Tick time ->
      if model.mapReady then
        let
          updatedDrones = updateDrones model.drones model.jobs model.chargingStations
        in
          ( { model | drones = updatedDrones, time = time }, drones updatedDrones )
      else
        ( { model | time = time, startTime = time }, Cmd.none )

    FetchSucceed newJobs ->
      ( { model | jobs = newJobs }, Cmd.none )

    FetchFail _ ->
      ( model, Cmd.none)

updateDrones : List Drone -> List Job -> List ChargingStation -> List Drone
updateDrones drones jobs chargingStations =
  case drones of
    [] ->
      []
    drone::remaining ->
      let
        updatedDrone = updateDrone drone jobs chargingStations
      in
        [updatedDrone] ++ (updateDrones remaining jobs chargingStations)

updateDrone : Drone -> List Job -> List ChargingStation -> Drone
updateDrone drone jobs chargingStations =
  case drone.status of
    "Charging" ->
      { drone | status = "Grounded", charge = 25 }
    "TakingOff" ->
      { drone | status = "ToStart", charge = drone.charge - 0.5 }
    "Grounded" ->
      case (List.head jobs) of
        Just job ->
          { drone | status = "TakingOff", currentJob = job }
        Nothing ->
          { drone | status = "Idle" }
    "ToStart" ->
      if (drone.location == drone.currentJob.start) then
        { drone | status = "ToEnd" }
      else 
        { drone 
          | location = moveTowards drone.location drone.currentJob.start 20
          , charge = drone.charge - 0.01 
        }
    "ToEnd" ->
      if (drone.location == drone.currentJob.end) then
        { drone | status = "Idle" }
      else
        { drone 
          | location = moveTowards drone.location drone.currentJob.end 20
          , charge = drone.charge - 0.01 
        }
    "Landing" ->
      { drone | status = "grounded" }
    "Idle" ->
      drone
    _ ->
      { drone | status = "Charging" }

moveTowards : Location -> Location -> Float -> Location
moveTowards start end meters =
  let
    distance = distanceBetween start end
    dlat = end.lat - start.lat
    dlng = end.lng - start.lng
  in
    if (meters >= distance) then
      end
    else
      Location (start.lat + ( meters / distance * dlat )) ( start.lng + ( meters / distance * dlng ) )

distanceBetween : Location -> Location -> Float
distanceBetween start end =
  let
    dlat = end.lat - start.lat
    dlng = end.lng - start.lng
  in
    ( sqrt ((dlat * dlat) + (dlng * dlng)) ) * 111319.5

-- Subscriptions

port isReady : ( Bool -> msg ) -> Sub msg
port jobs : ( List Job -> msg ) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Time.every ( second / model.speedup ) Tick
    , isReady Ready
    , jobs NewJobs
    ]

