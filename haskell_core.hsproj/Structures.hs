{-# LANGUAGE OverloadedStrings #-}

module Structures( Channel(..),
             newChannel,
             writeChannel,
             readChannel
) where

import JSON_Parser

import System.IO
import Control.Monad

-- concurrency
import Control.Exception
import Control.Concurrent


type Stream a = MVar (Item a)
data Item a   = Item a (Structures.Stream a)

data Channel a = Channel (MVar (Structures.Stream a)) (MVar (Structures.Stream a))

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
