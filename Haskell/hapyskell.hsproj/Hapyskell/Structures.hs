{-# LANGUAGE OverloadedStrings #-}

module Hapyskell.Structures( Channel(..),
             newChannel,
             writeChannel,
             readChannel
) where

import Hapyskell.Utils.JSON

import System.IO
import Control.Monad

-- concurrency
import Control.Exception
import Control.Concurrent


type Stream a = MVar (Item a)
data Item a   = Item a (Hapyskell.Structures.Stream a)

data Channel a = Channel (MVar (Hapyskell.Structures.Stream a)) (MVar (Hapyskell.Structures.Stream a))

newChannel :: IO (Channel (Maybe Command))
newChannel = do
  hole  <- newEmptyMVar
  readVar  <- newMVar hole
  writeVar <- newMVar hole
  return (Channel readVar writeVar)

writeChannel :: Channel (Maybe Command) -> (Maybe Command) -> IO ()
writeChannel (Channel _ writeVar) val = do
  newHole <- newEmptyMVar
  oldHole <- takeMVar writeVar
  putMVar oldHole (Item val newHole)
  putMVar writeVar newHole

readChannel :: Channel (Maybe Command) -> IO (Maybe Command)
readChannel (Channel readVar _) = do
  stream <- takeMVar readVar
  Item val tail <- takeMVar stream
  putMVar readVar tail
  return val
