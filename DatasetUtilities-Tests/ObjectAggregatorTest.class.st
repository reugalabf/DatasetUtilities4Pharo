Class {
	#name : #ObjectAggregatorTest,
	#superclass : #TestCase,
	#category : #'DatasetUtilities-Tests'
}

{ #category : #tests }
ObjectAggregatorTest >> testHourlyMultiMappings [
	| col agregator |
	col := (NeoJSONReader on: self threeEntriesJson readStream) 
		       nextListAs: FlareSenseDevelopment.

	self should: [ col size = 3 ].



	agregator := ObjectAggregator new.
	agregator
		keyAspect: #when;
		hourly;
		addAverageMappingFor: #hum;
		addSumMappingFor: #tem;
		addMaxMappingFor: #wind_ws_gust;
		addMinMappingFor: #temperature_ws.
	(agregator aggregate: col) .

	self should: [ col size = 3 ].
	self should: [ 
		col first when printString = '2023-11-28T13:03:38.897+00:00' ]
]

{ #category : #tests }
ObjectAggregatorTest >> testHourlyMultiMappingsReification [
	| col agregator rsp aggregated |
	rsp := FlareSenseRawEndpointClient new transformJSONFrom:
		       self twoRawEntriesJson readStream.

	col := (NeoJSONReader on: rsp readStream) nextListAs:
		       FlareSenseDevelopment.

	self should: [ col size = 3 ].
	self should: [ 
		col first when printString = '2023-11-28T13:03:38.897+00:00' ].
	agregator := ObjectAggregator new.
	agregator
		keyAspect: #when;
		hourly;
		addAverageMappingFor: #hum;
		addSumMappingFor: #tem;
		addMaxMappingFor: #wind_ws_gust;
		addMinMappingFor: #temperature_ws.

	aggregated := agregator aggregate: col.
	self should: [ aggregated size = 1 ].
	self should: [ 
		(aggregated first value at: 'when') = '2023-11-28T13:00:00+00:00' ].
	self should: [ (aggregated first value at: #hum) = 70.5 ]
]

{ #category : #tests }
ObjectAggregatorTest >> testHourlyMultiMappingsToCSV [

	| col agregator csv array |
	col := (NeoJSONReader on: self threeEntriesJson readStream) 
		       nextListAs: FlareSenseDevelopment.

	self should: [ col size = 3 ].


	agregator := ObjectAggregator new.
	agregator
		keyAspect: #when;
		hourly;
		addAverageMappingFor: #hum;
		addSumMappingFor: #tem;
		addMaxMappingFor: #wind_ws_gust;
		addMinMappingFor: #temperature_ws.



	csv := agregator aggregateCSV: col.
	
	array := (NeoCSVReader on: csv readStream) upToEnd.

	self should: [ array size = 3 ].
	self should: [ array first first = 'key' ].
	self should: [ ((array at: 2) at: 2) = '70.0' ]
]

{ #category : #tests }
ObjectAggregatorTest >> testHourlyMultiMappingsToJSON [

	| col agregator  json dicts |
	col := (NeoJSONReader on: self threeEntriesJson readStream) 
		       nextListAs: FlareSenseDevelopment.

	self should: [ col size = 3 ].

	agregator := ObjectAggregator new.
	json := agregator
		        keyAspect: #when;
		        hourly;
		        addAverageMappingFor: #hum;
		        addSumMappingFor: #tem;
		        addMaxMappingFor: #wind_ws_gust;
		        addMinMappingFor: #temperature_ws;
		        aggregateJSON: col.

	dicts := NeoJSONReader fromString: json.
	self should: [ dicts size = 2 ].
	self should: [ 
		(dicts first at: 'when') = '2023-11-28T13:00:00+00:00' ]
]

{ #category : #tests }
ObjectAggregatorTest >> testMultiMappingsFilter [

	| col agregator rsp aggregated |
	rsp := FlareSenseRawEndpointClient new transformJSONFrom:
		       self twoRawEntriesJson readStream.

	col := (NeoJSONReader on: rsp readStream) nextListAs:
		       FlareSenseDevelopment.

	self should: [ col size = 3 ].
	self should: [ 
		col first when printString = '2023-11-28T13:03:38.897+00:00' ].
	agregator := ObjectAggregator new.
	agregator
		afterDateandTime: (DateAndTime fromString: '2023-11-28T13:03:38.897Z') ;
		keyAspect: #when;
		addAverageMappingFor: #hum;
		addSumMappingFor: #tem;
		addMaxMappingFor: #wind_ws_gust;
		addMinMappingFor: #temperature_ws.


	aggregated := agregator aggregate: col.
	self should: [ aggregated size = 2 ].
	self should: [ 
		(aggregated first value at: 'when')
		= '2023-11-28T13:08:45.393+00:00' ].
	self should: [ (aggregated first value at: #hum) = 66.7 ]
]

{ #category : #tests }
ObjectAggregatorTest >> testMultiMappingsFilterHourly [

	| col agregator rsp aggregated |
	rsp := FlareSenseRawEndpointClient new transformJSONFrom:
		       self twoRawEntriesJson readStream.

	col := (NeoJSONReader on: rsp readStream) nextListAs:
		       FlareSenseDevelopment.

	self should: [ col size = 3 ].
	self should: [ 
		col first when printString = '2023-11-28T13:03:38.897+00:00' ].
	agregator := ObjectAggregator new.
	agregator
		afterDateandTime:  (DateAndTime fromString: '2023-11-28T12:03:38.897Z') ;
		keyAspect: #when;
		hourly;
		addAverageMappingFor: #hum;
		addSumMappingFor: #tem;
		addMaxMappingFor: #wind_ws_gust;
		addMinMappingFor: #temperature_ws.
	"		hourly;"

	aggregated := agregator  aggregate: col.
	self should: [ aggregated size = 1 ].
	self should: [ 
		(aggregated first value at: 'when')
		= '2023-11-28T13:00:00+00:00' ].
	self should: [ (aggregated first value at: #hum) asInteger = 70 ]
]

{ #category : #tests }
ObjectAggregatorTest >> testMultiMappingsReification [

	| col agregator rsp aggregated |
	rsp := FlareSenseRawEndpointClient new transformJSONFrom:
		       self twoRawEntriesJson readStream.

	col := (NeoJSONReader on: rsp readStream) nextListAs:
		       FlareSenseDevelopment.

	self should: [ col size = 3 ].
	self should: [ 
		col first when printString = '2023-11-28T13:03:38.897+00:00' ].
	agregator := ObjectAggregator new.
	agregator
		keyAspect: #when;
		addAverageMappingFor: #hum;
		addSumMappingFor: #tem;
		addMaxMappingFor: #wind_ws_gust;
		addMinMappingFor: #temperature_ws.
	"		hourly;"

	aggregated := agregator aggregate: col.

	self should: [ aggregated size = 3 ].
	self should: [ 
		(aggregated first value at: 'when') = '2023-11-28T13:03:38.897+00:00' ].
	self should: [ (aggregated first value at: #hum) = 73.3 ]
]

{ #category : #tests }
ObjectAggregatorTest >> testSplitDate [

	| col agregator rsp aggregated |
	rsp := FlareSenseRawEndpointClient new transformJSONFrom:
		       self twoRawEntriesJson readStream.

	col := (NeoJSONReader on: rsp readStream) nextListAs:
		       FlareSenseDevelopment.

	self should: [ col size = 3 ].
	self should: [ 
		col first when printString = '2023-11-28T13:03:38.897+00:00' ].
	agregator := ObjectAggregator new.
	agregator
		afterDateandTime: (DateAndTime fromString: '2023-11-28T13:03:38.897Z') ;
		keyAspect: #when;
		addDateMappingFor: #when;
		addTimeMappingFor: #when;
		addAverageMappingFor: #hum;
		addSumMappingFor: #tem;
		addMaxMappingFor: #wind_ws_gust;
		addMinMappingFor: #temperature_ws.


	aggregated := agregator aggregate: col.


	self should: [ aggregated size = 2 ].
	self should: [ 
		(aggregated first value at: 'when')
		= '2023-11-28T13:08:45.393+00:00' ].
	self should: [ (aggregated first value at: #hum) = 66.7 ]
]

{ #category : #tests }
ObjectAggregatorTest >> testTwoBlocksHourlyMappings [

	"25.3,""hum"":73.3,"

	| col agregator aggregated |
	col := (NeoJSONReader on: self threeEntriesJson readStream) 
		       nextListAs: FlareSenseDevelopment.

	self should: [ col size = 3 ].

	agregator := ObjectAggregator new.
	agregator
		keyAspect: #when;
		hourly;
		addAverageMappingFor: #hum;
		addBlockMapping: [ :row | (row at: #hum) < 71 ] as: #block1;
		addBlockMapping: [ :row | (row at: #hum) > 71 ] as: #block2.


	aggregated := agregator aggregate: col.

	self should: [ aggregated size = 2 ].
	self should: [ (aggregated first value at: #block1) = true ].
	self should: [ (aggregated first value at: #block2) = false ]
]

{ #category : #private }
ObjectAggregatorTest >> threeEntriesJson [
^ '[{"wind_ws_gust":36,"when":"2023-11-28T13:03:38.897Z","timeDeltaM":30,"humidity_ws":69.4,"nodeId":"3c610528e00c","wind_wspeed_s":17.8,"tem":25.3,"hum":73.3,"pressure_ws":1012,"raing":0,"temperature_ws":25.3,"fw":"Miramar-sep2022","wind_direction_ws":0.6},{"wind_ws_gust":11.6,"when":"2023-11-28T13:38:45.393Z","timeDeltaM":30,"humidity_ws":65.5,"nodeId":"3c610528e00c","wind_wspeed_s":4.4,"tem":28.1,"hum":66.7,"pressure_ws":1011.9,"raing":0,"temperature_ws":26.8,"fw":"Miramar-sep2022","wind_direction_ws":0},{"wind_ws_gust":28.8,"when":"2023-11-28T14:08:45.393+00:00","timeDeltaM":30,"humidity_ws":66.3,"nodeId":"3c610528e00c","wind_wspeed_s":14.4,"tem":26.1,"hum":71.6,"pressure_ws":1011.7,"raing":0,"temperature_ws":26.5,"fw":"Miramar-sep2022","wind_direction_ws":1.2}]'
]

{ #category : #private }
ObjectAggregatorTest >> twoMultiRawEntriesJson [
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
ObjectAggregatorTest >> twoRawEntriesJson [
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
