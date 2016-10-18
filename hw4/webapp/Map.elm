port module Clicker exposing (..)

import Html exposing (div, button, text)
import Html.App as App
import Html.Events exposing (onClick)
import Html.Attributes exposing (disabled)

type Msg 
  = Increment Int
  | Decrement Int

type alias Model =
  { value : Int
  , min : Int
  , max : Int
  }

port value : Int -> Cmd msg

main =
  App.program
    { init = (model, Cmd.none)
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
    
model =
  { value = 0
  , min = 0
  , max = 20
  }

valueButton caption action isDisabled =
  button [ disabled isDisabled, onClick action ] [ text caption ]

pluralize : String -> String -> Int -> String
pluralize singular plural count =
  if count == 1 then
    singular
  else
    plural

view model =
  let
    extender = pluralize "thing" "things" model.value
    caption = toString model.value ++ " " ++ extender
  in
    div []
      [ valueButton "-" (Decrement 10) (model.value <= model.min)
      , div [] [ text caption ]
      , valueButton "+" (Increment 2) (model.value >= model.max)
      ]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Increment quantity ->
      let
        newValue = Basics.min model.max (model.value + quantity)
      in
        ( { model | value = newValue }, value newValue )

    Decrement quantity ->
      let
        newValue = Basics.max model.min (model.value - quantity)
      in
        ( { model | value = newValue }, value newValue )

port suggestions : (Int -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  suggestions Decrement
