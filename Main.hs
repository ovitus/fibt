module Main where

import Data.List
import Data.Time
import Data.Time.Clock.POSIX
import Options.Applicative

data Fib = 
    FibRetracement 
      { ra :: Double
      , rb :: Double
      }
  | TrendBasedFibExtension 
      { ea :: Double 
      , eb :: Double 
      , ec :: Double 
      }
  | TrendBasedFibTime 
      { ta :: LocalTime 
      , tb :: LocalTime 
      , tc :: LocalTime 
      , tzi :: TimeZone 
      , tzo :: TimeZone
      }

data Options = Options 
  { fib :: Fib 
  , ratios :: [Double]
  , iteration :: Double
  , csv :: Bool
  }

--ratio iteration
ri :: Fractional b => [Double] -> Double -> [b]
ri r i = map realToFrac . sort $ [x+y | x <-r, y <-[0,1..i]] where

--fib formulas
fr :: Fib -> [Double] -> Double -> [Double]
fr (FibRetracement a b) r i = fr' a b (ri r i) where
  fr' a b (r:rs) = b + (a - b) * r : fr' a b rs
  fr' a b [] = []

tbfe :: Fib -> [Double] -> Double -> [Double]
tbfe (TrendBasedFibExtension a b c) r i = tbfe' a b c (ri r i) where
  tbfe' a b c (r:rs) = c + (b - a) * r : tbfe' a b c rs
  tbfe' a b c [] = []

tbft :: Fib -> [Double] -> Double -> [LocalTime]
tbft (TrendBasedFibTime a b c tzi tzo) r i = tbft' a b c (ri r i) where
  tbft' a b c (r:rs) = (ul tzo . pu) ((up . lu tzi) c + ((up . lu tzi) b - (up . lu tzi) a) * r) : tbft' a b c rs
  tbft' a b c [] = []
  lu = localTimeToUTC
  pu = posixSecondsToUTCTime
  ul = utcToLocalTime
  up = utcTimeToPOSIXSeconds

--precise ratios
_382 :: Double
_382 = 2 / (3 + sqrt 5)
_618 :: Double
_618 = 2 / (1 + sqrt 5)

p :: Parser Options
p = Options <$> (fr <|> tbfe <|> tbft) <*> r <*> i <*> csv where
  fr = FibRetracement <$> a <*> b where
    a = option auto (long "ra" <> help "Fib Retracement: point A" <> metavar "<val>")
    b = option auto (long "rb" <> help "Fib Retracement: point B" <> metavar "<val>")
  tbfe = TrendBasedFibExtension <$> a <*> b <*> c where
    a = option auto (long "ea" <> help "Trend-Based Fib Extension: point A" <> metavar "<val>")
    b = option auto (long "eb" <> help "Trend-Based Fib Extension: point B" <> metavar "<val>")
    c = option auto (long "ec" <> help "Trend-Based Fib Extension: point C" <> metavar "<val>")
  tbft = TrendBasedFibTime <$> a <*> b <*> c <*> tzi <*> tzo where
    a = option auto (long "ta" <> help "Trend-Based Fib Time: point A (yyyy-mm-dd hh:mm:ss)" <> metavar "<time>")
    b = option auto (long "tb" <> help "Trend-Based Fib Time: point B (yyyy-mm-dd hh:mm:ss)" <> metavar "<time>")
    c = option auto (long "tc" <> help "Trend-Based Fib Time: point C (yyyy-mm-dd hh:mm:ss)" <> metavar "<time>")
    tzi = option auto (long "tzi" <> help "Trend-Based Fib Time: time zone input" <> showDefault <> value (read "UTC" :: TimeZone) <> metavar "<TZ>")
    tzo = option auto (long "tzo" <> help "Trend-Based Fib Time: time zone output" <> showDefault <> value (read "UTC" :: TimeZone) <> metavar "<TZ>")
  r = option auto (long "r" <> short 'r' <> help "List of Fibonacci ratios. Ex: [0,0.236,0.382,0.5,0.618,0.786]" <> showDefault <> value [0,_382,_618] <> metavar "<ratios>")
  i = option auto (long "i" <> short 'i' <> help "Iteration" <> showDefault <> value 3 <> metavar "<num>")
  csv = switch (long "csv" <> help "CSV output")

--formatter
f :: Bool -> [Char] -> [Char] -> [Char]
f csv x y
  | csv /= True && length x /= 5 = x ++ "   " ++ y
  | csv /= True = x ++ " " ++ y
  | otherwise = x ++ "," ++ y

--round to decimal point
rd :: (RealFrac a1, Integral b, Fractional a2) => b -> a1 -> a2
rd dp n = (fromInteger . round $ n * 10 ^ dp) / 10 ^ dp

io :: Options -> IO ()
io (Options (FibRetracement a b) r i csv) = do
  if csv then putStrLn "RATIO,VALUE" else putStrLn "RATIO VALUE"
  mapM_ putStrLn $ 
    if a < b then io' else reverse io' where 
      io' = zipWith (f csv)
        (map (show . rd 3) $ ri r i) $
         map (show . rd 2) $ fr (FibRetracement a b) r i
io (Options (TrendBasedFibExtension a b c) r i csv) = do
  if csv then putStrLn "RATIO,VALUE" else putStrLn "RATIO VALUE"
  mapM_ putStrLn $ 
    if a < b then reverse io' else io' where 
      io' = zipWith (f csv)
        (map (show . rd 3) $ ri r i) $
         map (show . rd 2) $ tbfe (TrendBasedFibExtension a b c) r i
io (Options (TrendBasedFibTime a b c tzi tzo) r i csv) = do 
  if csv then putStrLn "RATIO,TIME" else putStrLn "RATIO TIME"
  mapM_ putStrLn $ 
    zipWith (f csv)
      (map (show . rd 3) $ ri r i) $
       map ((++ " " ++ (show tzo)) . take 19 . show) $ tbft (TrendBasedFibTime a b c tzi tzo) r i

main :: IO ()
main = execParser (info (helper <*> p) (fullDesc <> progDesc "fibt - Fibonacci time and other predictive indicators" <> header "Fibt 1.0")) >>= \x -> io x
