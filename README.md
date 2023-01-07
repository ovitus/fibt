# fibt

A recreation of the Fibonacci indicators for use outside of Tradingview and other charting tools. 
Included are Fib Retracement, Trend-Based Fib Extension, and Trend-Based Fib Time.

Example:
```
fibt --ta "2017-12-01 00:00:00" --tb "2018-12-01 00:00:00" --tc "2021-04-01 00:00:00"
RATIO TIME                                                            
0.0   2021-04-01 00:00:00 UTC                                         
0.382 2021-08-18 10:01:20 UTC                                         
0.618 2021-11-12 13:58:39 UTC                                         
1.0   2022-04-01 00:00:00 UTC                                         
1.382 2022-08-18 10:01:20 UTC                                         
1.618 2022-11-12 13:58:39 UTC                                         
2.0   2023-04-01 00:00:00 UTC                                                                                                                
2.382 2023-08-18 10:01:20 UTC                                                                                                                
2.618 2023-11-12 13:58:39 UTC                                                                                                                
3.0   2024-03-31 00:00:00 UTC                                                                                                                
3.382 2024-08-17 10:01:20 UTC                                                                                                                
3.618 2024-11-11 13:58:39 UTC
```
-h,--help to show all available options.

Ideas for future improvement:
* Broader time frame option to show just the weekly open day (Monday) for each ratio, as they tend to be more pivotal.
