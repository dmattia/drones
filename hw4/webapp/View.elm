module View exposing (rootView)

import Html exposing (div, button, text, h3)
import Html.Events exposing (onClick)
import Html.Attributes exposing (id, class)

import Types exposing (..)

panButton dlat dlng caption =
  button [ onClick (PanMap dlat dlng), class "btn col s3 waves-effect green white-text" ] [ text caption ]

rootView model =
  div [ class "container row" ]
    [ h3 [ class "center" ] [ text "Drone Job Delivery" ]
    , div [id "map" ] []
    , panButton 0.05 0.00 "Pan Up"
    , panButton -0.05 0.00 "Pan Down"
    , panButton 0.00 -0.05 "Pan Left"
    , panButton 0.00 0.05 "Pan Right"
    ]
