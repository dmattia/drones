module View exposing (rootView)

import Html exposing (div, button, text, h3, h5)
import Html.Events exposing (onClick)
import Html.Attributes exposing (id, class)

import Types exposing (..)

panButton : Float -> Float -> String -> Html.Html Msg
panButton dlat dlng caption =
  button [ onClick (PanMap dlat dlng), class "btn col s3 waves-effect green white-text" ] [ text caption ]

jobView : Job -> Html.Html Msg
jobView job =
  div [] [ text (toString job) ]

droneView : Drone -> Html.Html Msg
droneView drone =
  div [] [ text (droneDescription drone) ]

droneDescription : Drone -> String
droneDescription drone =
  "Drone " ++ (toString drone.id) 
  ++ " is currently " ++ drone.status 
  ++ " with charge " ++ (toString (round drone.charge))
  ++ " on flight number " ++ (toString drone.flightNumber)

getTimeElapsedString : Model -> String
getTimeElapsedString model =
  toString (floor ( model.speedup * (model.time - model.startTime) / 1000))

rootView : Model -> Html.Html Msg
rootView model =
  div [ class "container row" ]
    [ h3 [ class "center" ] [ text "Drone Job Delivery" ]
    , div [ class "row" ]
      [ button [ onClick DecreaseSpeedup, class "btn btn-large waves-effect col s3" ] [ text "-" ]
      , h5 [ class "center col s6" ] [ text ("Speedup: " ++ (toString model.speedup)) ]
      , button [ onClick IncreaseSpeedup, class "btn btn-large waves-effect col s3" ] [ text "+" ]
      ]
    , h5 [ class "center" ] [ text ("Time Elapsed: " ++ (getTimeElapsedString model) ++ "s") ]
    , div [id "map" ] []
    , panButton 0.01 0.00 "Pan Up"
    , panButton -0.01 0.00 "Pan Down"
    , panButton 0.00 -0.01 "Pan Left"
    , panButton 0.00 0.01 "Pan Right"
    , div [] 
      [ h3 [ class "center" ] [ text "Drones" ]
      , div [] ( List.map droneView model.drones )
      ]
    , div [] 
      [ h3 [ class "center" ] [ text "Unclaimed Jobs" ]
      , div [] ( List.map jobView model.jobs )
      ]
    ]
