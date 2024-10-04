Class {
	#name : #DatasetAggregatorTest,
	#superclass : #TestCase,
	#category : #'DatasetUtilities-Tests'
}

{ #category : #tests }
DatasetAggregatorTest >> getCollectionToAggregate [

	^ (NeoJSONReader on: self threeEntriesJson readStream) nextListAs:
		  FlareSenseDevelopment
]

{ #category : #private }
DatasetAggregatorTest >> threeEntriesJson [
^ '[{"wind_ws_gust":36,"when":"2023-11-28T13:03:38.897Z","timeDeltaM":30,"humidity_ws":69.4,"nodeId":"3c610528e00c","wind_wspeed_s":17.8,"tem":25.3,"hum":73.3,"pressure_ws":1012,"raing":0,"temperature_ws":25.3,"fw":"Miramar-sep2022","wind_direction_ws":0.6},{"wind_ws_gust":11.6,"when":"2023-11-28T13:38:45.393Z","timeDeltaM":30,"humidity_ws":65.5,"nodeId":"3c610528e00c","wind_wspeed_s":4.4,"tem":28.1,"hum":66.7,"pressure_ws":1011.9,"raing":0,"temperature_ws":26.8,"fw":"Miramar-sep2022","wind_direction_ws":0},{"wind_ws_gust":28.8,"when":"2023-11-28T14:08:45.393+00:00","timeDeltaM":30,"humidity_ws":66.3,"nodeId":"3c610528e00c","wind_wspeed_s":14.4,"tem":26.1,"hum":71.6,"pressure_ws":1011.7,"raing":0,"temperature_ws":26.5,"fw":"Miramar-sep2022","wind_direction_ws":1.2}]'
]

{ #category : #private }
DatasetAggregatorTest >> twoMultiRawEntriesJson [
^ '[{
"fw": "Miramar-sep2022",
"hum": [
30,
40,
80
],
"humidity_ws": [
80,
70,
60
],
"nodeId": "3c610528e00c",
"pressure_ws": [
1012
],
"raing": [
0
],
"tem": [
25.3
],
"temperature_ws": [
25.3
],
"timeDeltaM": 30,
"when": "2023-11-28T13:03:38.897Z",
"wind_direction_ws": [
0.6
],
"wind_ws_gust": [
36
],
"wind_wspeed_s": [
17.8
]
},
{
"fw": "Miramar-sep2022",
"hum": [
50,
80
],
"humidity_ws": [
80,70
],
"nodeId": "3c610528e00c",
"pressure_ws": [
1011.9,
1011.7
],
"raing": [
0,
0
],
"tem": [
28.1,
26.1
],
"temperature_ws": [
26.8,
26.5
],
"timeDeltaM": 30,
"when": "2023-11-28T14:05:45.393Z",
"wind_direction_ws": [
0,
1.2
],
"wind_ws_gust": [
11.6,
28.8
],
"wind_wspeed_s": [
4.4,
14.4
]
}
]'
]

{ #category : #private }
DatasetAggregatorTest >> twoRawEntriesJson [
^ '[{
"fw": "Miramar-sep2022",
"hum": [
73.3
],
"humidity_ws": [
69.4
],
"nodeId": "3c610528e00c",
"pressure_ws": [
1012
],
"raing": [
0
],
"tem": [
25.3
],
"temperature_ws": [
25.3
],
"timeDeltaM": 30,
"when": "2023-11-28T13:03:38.897Z",
"wind_direction_ws": [
0.6
],
"wind_ws_gust": [
36
],
"wind_wspeed_s": [
17.8
]
},
{
"fw": "Miramar-sep2022",
"hum": [
66.7,
71.6
],
"humidity_ws": [
65.5,
66.3
],
"nodeId": "3c610528e00c",
"pressure_ws": [
1011.9,
1011.7
],
"raing": [
0,
0
],
"tem": [
28.1,
26.1
],
"temperature_ws": [
26.8,
26.5
],
"timeDeltaM": 30,
"when": "2023-11-28T13:38:45.393Z",
"wind_direction_ws": [
0,
1.2
],
"wind_ws_gust": [
11.6,
28.8
],
"wind_wspeed_s": [
4.4,
14.4
]
}
]'
]
