module Hapyskell.Utils.Logging(
    logging
  ) 
where

import System.IO
import System.Posix


logFile = "/Users/alexisgallepe/Documents/HaPy-Skell/haskell-log.txt"

logging :: String -> IO ()
logging str = do
    print str
    withFile logFile AppendMode $ \h -> do
        hSetBuffering h (BlockBuffering Nothing)
        hPutStr h $ str ++ "\n"
