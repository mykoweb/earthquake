EARTHQUAKE
==========

## Description

Using a CSV with Earthquake data downloaded from the USGS, this Ruby program finds the first 10 cities and states with an earthquake that was felt in Los Angeles in a given date range.

## Installation

```sh
# Make sure you have bundler installed
> cd earthquake
> bundle install
```

## Usage

First, you need to `cd` into the `earthquake` directory. Then start `irb` and run the following commands:

```ruby
> e = Earthquake.new
> e.compile_data_from_csv './all_month.csv'

# find_earthquakes_felt_in_la(start_date = '', end_date = '')
# start_date and end_date should be strings in the format YYYY-MM-DD
# No args defaults to 30 days ago to today.
> e.find_earthquakes_felt_in_la
Time                      Place                            Magnitude  Distance from LA
2017-01-19T01:13:24.840Z  Devore, CA                       0.88       48
2017-01-19T02:30:19.210Z  Santa Clarita, CA                0.86       24
2017-01-19T02:36:20.030Z  Yucca Valley, CA                 1.27       104
2017-01-19T03:13:43.520Z  Rancho Cucamonga, CA             0.87       37
2017-01-19T06:43:40.310Z  Yorba Linda, CA                  1.27       28
2017-01-19T09:43:43.180Z  Yucaipa, CA                      0.96       72
2017-01-19T11:51:34.450Z  Primo Tapia, B.C.                1.94       159
2017-01-19T13:58:46.620Z  Morongo Valley, CA               1.44       91
2017-01-19T20:03:09.240Z  Colton, CA                       0.85       54
2017-01-19T23:52:46.960Z  Pine Mountain Club, CA           1.55       75
```

## Tests

You can run tests with `rspec`.

Licence
=======

See [LICENCE](https://github.com/mykoweb/earthquake/blob/master/LICENSE)
