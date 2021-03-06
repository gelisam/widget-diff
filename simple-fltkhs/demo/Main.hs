{-# LANGUAGE OverloadedStrings, RecordWildCards, RecursiveDo #-}
module Main where

import Control.Monad.IO.Class
import Data.IORef
import Data.Text

import SimpleFLTK


data AppState = AppState
  { appStateGoingUp :: Bool
  , appStateCount   :: Int
  }
  deriving Show

toggleDirection :: AppState -> AppState
toggleDirection appState@AppState{..} = appState
                                      { appStateGoingUp = not appStateGoingUp }

bumpCount :: AppState -> AppState
bumpCount appState@AppState{..} = appState
                                { appStateCount = if appStateGoingUp
                                                  then appStateCount + 1
                                                  else appStateCount - 1
                                }


data AppRefs = AppRefs
  { appRefsAppState        :: IORef AppState
  , appRefsDirectionButton :: ButtonRef
  , appRefsCountButton     :: ButtonRef
  }

refresh :: AppRefs -> SimpleFLTK ()
refresh appRefs = do
  AppState{..} <- liftIO $ readIORef (appRefsAppState appRefs)
  setButtonLabel (appRefsDirectionButton appRefs) $ if appStateGoingUp then "^" else "v"
  setButtonLabel (appRefsCountButton     appRefs) $ pack . show $ appStateCount

directionButtonCallback :: AppRefs -> SimpleFLTK ()
directionButtonCallback appRefs = do
  liftIO $ modifyIORef (appRefsAppState appRefs) toggleDirection
  refresh appRefs

countButtonCallback :: AppRefs -> SimpleFLTK ()
countButtonCallback appRefs = do
  liftIO $ modifyIORef (appRefsAppState appRefs) bumpCount
  refresh appRefs


main :: IO ()
main = runSimpleFLTK (Size (Width 130) (Height 90)) $ mdo
  appRefs <- AppRefs <$> liftIO (newIORef (AppState True 0))
                     <*> newButton (Rectangle (Position (X 30) (Y 30))
                                              (Size (Width 30) (Height 30)))
                                   "^"
                                   (directionButtonCallback appRefs)
                     <*> newButton (Rectangle (Position (X 70) (Y 30))
                                              (Size (Width 30) (Height 30)))
                                   "0"
                                   (countButtonCallback appRefs)
  pure ()
