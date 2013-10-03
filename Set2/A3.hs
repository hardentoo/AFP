{-# LANGUAGE MultiParamTypeClasses, FlexibleInstances #-}
module A3 where
import Control.Monad.State
import Data.List

type Dict = [(String, Int)]
data StateMonadPlus s a = StateMonadPlus ((s, Dict) -> Either String (a, s, Dict))


instance Monad (StateMonadPlus s) where
    -- (>>=) :: StateMonadPlus s a -> (a -> StateMonadPlus s a) -> StateMonadPlus s a
    m >>= k = StateMonadPlus (\(s, d) -> f (runStateMonadPlus m (s, incDict "bind" d)))
      where
        f (Left s') = Left s'
        f (Right (a, s', d)) = runStateMonadPlus (k a) (s', d)

    -- return :: a -> StateMonadPlus s a
    return a = StateMonadPlus (\(s, d) -> Right (a, s, (incDict "return" d)))


instance MonadState s (StateMonadPlus s) where
    -- get :: StateMonadPlus s s
    get = StateMonadPlus (\(s, d) -> Right (s, s, d))

    -- put :: s -> StateMonadPlus s ()
    put s = StateMonadPlus (\(_, d) -> Right ((), s, d))


instance Show (StateMonadPlus s String) where
    -- show :: StateMonadPlus s String -> String
    show (StateMonadPlus f) = g (f (undefined, [])) where
        g (Right (a, _, _)) = show a



-- This function should count the number of binds (>>=)
-- and returns (and other primitive functions) that have been encountered,
-- including the call to diagnostics at hand.
diagnostics :: StateMonadPlus s String
diagnostics = StateMonadPlus (\(s, d) ->
              let d'       = incDict "diagnostics" d
                  f (k, v) = k ++ "=" ++ (show v)
                  showd    = "[" ++ (intercalate ", " (map f d')) ++ "]"
              in Right (showd, s, d'))

-- Increment dictionary value for given key
incDict :: String -> Dict -> Dict
incDict key []                      = [(key, 1)]
incDict key ((k, v):xs) | k == key  = (k, v + 1):xs
                        | otherwise = (k, v):incDict key xs

-- Secondly, provide a function annotate that
-- allows a user to annotate a computation with a given label.
-- The functions for
-- Features 2 and 3, as well as get and put,
-- should also be part of the diagnosis.
annotate :: String -> StateMonadPlus s a -> StateMonadPlus s a
annotate key m = StateMonadPlus (\(s, d) ->
                 let  Right (a, s', d) = runStateMonadPlus m (s, d)
                      d'               = incDict key d
                 in Right (a, s', d'))

-- Running the monad.
-- Given a computation in the StateMonadPlus and an initial
-- state, runStateMonadPlus returns either an error message
-- if the computation failed, or
-- the result of the computation and the final state.
runStateMonadPlus :: StateMonadPlus s a -> (s, Dict) -> Either String (a, s, Dict)
runStateMonadPlus (StateMonadPlus f) = f


-- Testing
test = do
    return 3 >> return 4
    return 5
    diagnostics

test2 = do
    annotate "A" (return 3 >> return 4)
    return 5
    diagnostics
