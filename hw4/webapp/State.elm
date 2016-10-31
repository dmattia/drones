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
  , speedup = 200
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
          (updatedDrones, updatedJobs) = updateDrones model.drones model.jobs model.chargingStations
          startTime = if (model.startTime == 0) then time else model.startTime
        in
          ( { model | drones = updatedDrones, time = time, startTime = startTime, jobs = updatedJobs }, drones updatedDrones )
      else
        ( { model | time = time, startTime = time }, Cmd.none )

sortByMinimumCosts : Drone -> List ChargingStation -> List Job -> List Job
sortByMinimumCosts drone chargingStations jobs =
  case jobs of
    [] ->
        []
    pivot :: rest ->
        let
          cost = calculateMinimumCost drone chargingStations
          (lower, higher)  = List.partition (\job -> (cost job) <= (cost pivot)) rest
          --lower  = List.filter (\job -> (cost job) <= (cost pivot)) rest
          --higher  = List.filter (\job -> (cost job) > (cost pivot)) rest
        in
             (sortByMinimumCosts drone chargingStations lower)
          ++ [pivot]
          ++ (sortByMinimumCosts drone chargingStations higher)

updateDrones : List Drone -> List Job -> List ChargingStation -> (List Drone, List Job)
updateDrones drones jobs chargingStations =
  -- Returns the updated list of drones, along with an updated list of jobs
  case drones of
    [] ->
      ([], jobs)
    drone::remainingDrones ->
      let
        (updatedDrone, newJob) = updateDrone drone jobs chargingStations
      in
        case newJob of
          Just takenJob ->
            let
              remainingJobs = (List.filter (\job -> job.id /= takenJob.id) jobs)
              (otherDrones, leftoverJobs) = (updateDrones remainingDrones remainingJobs chargingStations)
            in
              ([updatedDrone] ++ otherDrones, leftoverJobs)
          Nothing ->
            let
              (otherDrones, leftoverJobs) = (updateDrones remainingDrones jobs chargingStations)
            in
              ([updatedDrone] ++ otherDrones, leftoverJobs)

calculateMinimumCost : Drone -> List ChargingStation -> Job -> Float
calculateMinimumCost drone chargingStations job =
  -- Finds the cost of a given drone doing a job and then going to the closest charging station
  let
    toJob = distanceBetween drone.location job.start
    jobDistance = distanceBetween job.start job.end
    chargeLocations = List.map .location chargingStations
    distancesToChargingStations = List.map (distanceBetween job.end) chargeLocations
    costPerMeter = 0.001
  in
    case (List.minimum distancesToChargingStations) of
      Just jobToChargingStation ->
        ( toJob + jobDistance + jobToChargingStation ) * 0.001
      Nothing ->  
        Debug.crash "You must give a valid list of charging stations"

findJob : Drone -> List Job -> List ChargingStation -> Maybe Job
findJob drone jobs chargingStations =
  let
    sortedJobs = sortByMinimumCosts drone chargingStations jobs
  in
    List.head sortedJobs

findNearestChargingStation : Drone -> List ChargingStation -> Maybe ChargingStation
findNearestChargingStation drone chargingStations =
  case chargingStations of
    [] ->
      Nothing
    cs :: cs' ->
      let
        closestFromRest = findNearestChargingStation drone cs'
      in
        case closestFromRest of
          Just chargingStation ->
            if (distanceBetween cs.location drone.location) < (distanceBetween chargingStation.location drone.location) then
              Just cs
            else
              Just chargingStation
          Nothing ->
            Just cs

updateDrone : Drone -> List Job -> List ChargingStation -> (Drone, Maybe Job)
updateDrone drone jobs chargingStations =
  -- Returns the drone after updating it, along with any new job the drone picked up
  case drone.status of
    "Charging" ->
      ({ drone | status = "Grounded", charge = 25 }, Nothing)
    "TakingOff" ->
      ({ drone | status = "ToStart", charge = drone.charge - 0.5 }, Nothing)
    "Grounded" ->
      case ( findJob drone jobs chargingStations ) of
        Just job ->
          if ((calculateMinimumCost drone chargingStations job) < drone.charge) then
            ({ drone | status = "TakingOff", currentJob = job }, Just job)
          else
            -- Not enough battery to complete this job
            ({ drone | status = "ToCharger" }, Nothing)
        Nothing ->
          ({ drone | status = "Idle" }, Nothing)
    "ToCharger" ->
      case (findNearestChargingStation drone chargingStations) of
        Just chargingStation ->
          if (drone.location == chargingStation.location) then
            ({ drone | status = "Charging" }, Nothing)
          else
            ({ drone | location = moveTowards drone.location chargingStation.location 20 }, Nothing)
        Nothing ->
          Debug.crash "You must initialize at least one charging station"
    "ToStart" ->
      if (drone.location == drone.currentJob.start) then
        ({ drone | status = "ToEnd" }, Nothing)
      else 
        ({ drone 
          | location = moveTowards drone.location drone.currentJob.start 20
          , charge = drone.charge - 0.02 
        }, Nothing)
    "ToEnd" ->
      if (drone.location == drone.currentJob.end) then
        ({ drone | status = "Idle" }, Nothing)
      else
        ({ drone 
          | location = moveTowards drone.location drone.currentJob.end 20
          , charge = drone.charge - 0.02 
        }, Nothing)
    "Landing" ->
      ({ drone | status = "grounded" }, Nothing)
    "Idle" ->
      --(drone, Nothing)
      case ( findJob drone jobs chargingStations ) of
        Just job ->
          if ((calculateMinimumCost drone chargingStations job) < drone.charge) then
            ({ drone | status = "ToStart", currentJob = job }, Just job)
          else
            -- Not enough battery to complete this job
            ({ drone | status = "ToCharger" }, Nothing)
        Nothing ->
          ({ drone | status = "Idle" }, Nothing)
    _ ->
      ({ drone | status = "Idle" }, Nothing)

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

