import System.IO  
import Control.Monad
import System.Environment
import Data.List
import System.Directory
import System.Exit

main = do  
        args <- getArgs
        let filename = if (null args) then "test.cfg" else (head args)
        file_flag <- doesFileExist filename
        if  file_flag
            then do handle <- openFile filename ReadMode
                 contents <- hGetContents handle
                 hClose handle   
            else do putStr "ERR:F:\n"
                 exitFailure
        putStr contents
        let result = tokenize contents            
        putStr $ fst head result                 
tokenize :: String -> [(String, Int)]
tokenize s = [("test",1)]