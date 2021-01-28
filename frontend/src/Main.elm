module Main exposing (..)

import Browser
import Http
import Css exposing (rgb, solid, px, border3)
import Html  exposing (Html, div, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Html.Events exposing (onClick)
import Html.Events exposing (on)
import Json.Decode as D exposing (Decoder, field, bool, string, int)
import Json.Decode exposing (list, succeed)
import Task exposing (succeed)

-- MAIN

main : Program () Model Msg
main =
  Browser.element { init = \_ -> init, subscriptions = subscriptions , update = update, view = view}


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

-- MODEL

type alias TodoTask =
  {
    id: Int
    , name: String
    , isCompleted: TaskStatus
  }

type TaskStatus
    = New
    | Done

type alias Model =
  { 
    tasks: List TodoTask
    , content: String
  }

init : (Model, Cmd Msg)
init =
  (Model [] "" , getTodos)


-- UPDATE


type Msg
  = AddTodo
  | Change String
  -- | UpdateTask Int
  | GotTodo (Result Http.Error (List TodoTask))
  | GetTodos


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GetTodos -> 
      (model, getTodos)
    GotTodo result ->
      case result of
        Ok todoTaskList ->   
          let
            gotTasks = List.take 5 todoTaskList
          in
          ({
            model | tasks = gotTasks
          },
          Cmd.none)
        _ ->
          (model, Cmd.none)
    AddTodo ->
      let 
        newId = ( List.length model.tasks) + 1
        newTasks = model.tasks ++ [TodoTask newId model.content New]
      in
      ({ model | tasks = newTasks
      , content = ""}
      , Cmd.none)
    Change changeContent ->
      ({ model | content = changeContent }
      , Cmd.none)
    -- UpdateTask id ->
    --   let 
    --     newTasks = List.map (isDoneChecker id) model.tasks
    --   in
    --   ({ model | tasks = newTasks}
    --   , Cmd.none)

-- HELPERS

todoDecoder : Decoder TodoTask
todoDecoder = 
  D.map3 TodoTask
    (field "id" int)
    (field "name" string)
    -- TODO: field指定して直す
    (D.succeed New)

todoListDecoder : Decoder (List TodoTask)
todoListDecoder = 
  D.list todoDecoder

getTodos : Cmd Msg
getTodos =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "Accept" "application/json"
            , Http.header "Content-Type" "application/json"
            ]
        , url = "http://0.0.0.0:8000/todos/"
        , expect = Http.expectJson GotTodo todoListDecoder
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }

-- View
view : Model ->  Html Msg
view model =
  div [] [text "hello"]