module Main exposing (..)

import Browser
import Http
import Task
import List
import Html  exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick, on)
import Json.Encode as E
import Json.Decode as D exposing (Decoder, field, bool, string, int)
import Json.Decode exposing (list, succeed)
import Task exposing (succeed)
import List.Extra
import Element exposing (Element, el, row, alignRight, fill, width, rgb255, spacing, centerY, padding)
import Element.Background as Background

-- MAIN

{-
TODO
* タスク名を編集する
-}
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
    , isCompleted: Bool
  }

type alias Model =
  { 
    tasks: List TodoTask
    , content: String
    , ids : List Int
  }

init : (Model, Cmd Msg)
init =
  (Model [] "" [],  getTodos)


-- UPDATE


type Msg
  = AddTodo
  | GotTodos (Result Http.Error (List TodoTask))
  | GotTodo (Result Http.Error (TodoTask))
  | GetTodos
  | UpdateContent String
  | UpdateTodoStatus Int
  | RemoveCompletedTodos
  | RemoveCompletedTasks (Result Http.Error (TodoTask))


run : msg -> Cmd msg
run m =
    Task.perform (always m) (Task.succeed ())

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    RemoveCompletedTasks res ->
      case res of
        _ ->
          ({ model | tasks = getUncompletedTasks model.tasks }, Cmd.none) 
    RemoveCompletedTodos ->
      let
        completedTasksIds = getCompletedTaskIds model.tasks
      in
        ({ model | ids = completedTasksIds }, removeTodoReq completedTasksIds) 
    UpdateTodoStatus id ->
      let
        targetTask  = List.Extra.find (getById id) model.tasks
      in
        case targetTask of
          Just task ->
            (model, (updateTodoReq task))
          Nothing ->
            (model, Cmd.none)
    AddTodo ->
        (model, addTodo model)
    UpdateContent newContent ->
      ({ model | content = newContent }, Cmd.none)
    GetTodos -> 
      (model, getTodos)
    GotTodos result ->
      case result of
        Ok todoTaskList ->   
          let
            gotTasks = List.take (List.length todoTaskList) todoTaskList
          in
          ({ model | tasks = gotTasks }
          , run (UpdateContent "") )
        _ ->
          (model, Cmd.none)
    GotTodo result ->
      case result of
        Ok todoTask -> 
          let
            isNew = isNewTask todoTask.id model.tasks
            currentTasks =  List.map (updateTodoTask todoTask) model.tasks 
            tasks = currentTasks ++ [TodoTask todoTask.id model.content False]
          in
            if isNew == True then
              ({ model | tasks = tasks }, run (UpdateContent ""))
            else
              ({ model | tasks = currentTasks }, run (UpdateContent ""))
        _ ->
          (model, Cmd.none)

getUncompletedTasks : List TodoTask -> List TodoTask
getUncompletedTasks tasks =
  let
    filter : TodoTask -> Bool
    filter task =
      if task.isCompleted == True then
        False
      else
        True
  in
    List.filter filter tasks
  

getCompletedTaskIds : List TodoTask -> List Int
getCompletedTaskIds tasks =
  let
    filterCompletedTask : TodoTask -> Maybe Int
    filterCompletedTask task =
      if task.isCompleted == True then
        Just task.id
      else
        Maybe.Nothing
  in
    List.filterMap filterCompletedTask tasks

isNewTask : Int -> List TodoTask -> Bool
isNewTask id tasks = 
  let
    target = List.Extra.find (getById id) tasks
  in
    case target of
      Just _ -> 
        False
      Nothing ->
        True

updateTodoTask : TodoTask -> TodoTask -> TodoTask
updateTodoTask todoTask task = 
  if (todoTask.id == task.id) then
    { task | isCompleted = todoTask.isCompleted}
  else
    task
  

-- HELPERS

getById: Int -> TodoTask -> Bool
getById id task =
  if task.id == id then True else False

todoDecoder : Decoder TodoTask
todoDecoder = 
  D.map3 TodoTask
      (field "id" int)
      (field "name" string)
      (field "is_completed" bool)

todoListDecoder : Decoder (List TodoTask)
todoListDecoder = 
  D.list todoDecoder


removeTodoReq : List Int -> Cmd Msg
removeTodoReq taskIds =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = "http://0.0.0.0:8000/todos/delete" 
        , expect = Http.expectJson RemoveCompletedTasks todoDecoder
        , body = Http.jsonBody <| E.list E.int taskIds
        , timeout = Nothing
        , tracker = Nothing
        }

updateTodoReq : TodoTask -> Cmd Msg
updateTodoReq task =
    Http.request
        { method = "PUT"
        , headers = []
        , url = "http://0.0.0.0:8000/todos/" ++ String.fromInt task.id
        , expect = Http.expectJson GotTodo todoDecoder
        , body = Http.jsonBody <| E.object [
          ("id", E.int 5)
          , ("name", E.string task.name)
          , ("is_completed", not task.isCompleted |> E.bool)
          ]
        , timeout = Nothing
        , tracker = Nothing
        }

getTodos : Cmd Msg
getTodos =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Content-Type" "application/json" ]
        , url = "http://0.0.0.0:8000/todos/"
        , expect = Http.expectJson GotTodos todoListDecoder
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }

addTodo  : Model -> Cmd Msg
addTodo model =
    Http.request
        { method = "POST"
        , headers = []
        , url = "http://0.0.0.0:8000/todos/"
        , expect = Http.expectJson GotTodo todoDecoder
        , body = Http.jsonBody <| E.object [("name", E.string model.content)]
        , timeout = Nothing
        , tracker = Nothing
        }

-- View
view : Model ->  Html Msg
view model =
  div [] [
    h1 [] [text "Elm de TODO"]
    , input [ 
        placeholder "タスク名を入力する"
        , value model.content
        , onInput UpdateContent
      ] []
    , button [ onClick AddTodo ] [ text "追加" ]
    , ul [style "padding" "0"] (taskListView model.tasks)
    , button [ onClick RemoveCompletedTodos ] [ text "完了したタスクを削除する" ]
  ]

taskListView : (List TodoTask) -> List (Html Msg)
taskListView tasks = 
  List.map taskView tasks

taskView : TodoTask -> Html Msg
taskView task =
  li [ style "list-style" "none"] [
    span [] [checkboxView task]
    , text task.name
    ]

checkboxView : TodoTask -> Html Msg
checkboxView task =
  if task.isCompleted then
    input [type_ "checkbox" , checked True, onClick (UpdateTodoStatus task.id)] []
  else
    input [type_ "checkbox", onClick (UpdateTodoStatus task.id)] []