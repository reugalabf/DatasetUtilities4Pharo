Class {
	#name : #DictionaryAggregatorTest,
	#superclass : #DatasetAggregatorTest,
	#category : #'DatasetUtilities-Tests'
}

{ #category : #tests }
DictionaryAggregatorTest >> getCollection3ToAggregateWithAppends [

	^ (NeoJSONReader on: self threeEntriesWithOneMultiValue readStream) next collect: [ 
		  :each | 
		  each at: #when put: (DateAndTime fromString: (each at: #when)).
		  each ]
]

{ #category : #tests }
DictionaryAggregatorTest >> getCollectionToAggregate [

	^ (NeoJSONReader on: self threeEntriesJson readStream) next collect: [ 
		  :each | 
		  each at: #when put: (DateAndTime fromString: (each at: #when)).
		  each ]
]

{ #category : #tests }
DictionaryAggregatorTest >> getCollectionToAggregateWithAppends [

	^ (NeoJSONReader on: self twoEntriesWithOneMultiValue readStream) next collect: [ 
		  :each | 
		  each at: #when put: (DateAndTime fromString: (each at: #when)).
		  each ]
]

{ #category : #tests }
DictionaryAggregatorTest >> testHourlyAppendMappings [

	| col agregator agregated|
	col := self getCollectionToAggregateWithAppends.

	self should: [ col size = 2 ].



	agregator := DictionaryAggregator new.
	agregator
		keyAspect: #when;
		hourly;
		addAppendMappingFor: #lqi_315;
		addBlockMapping: [ :row | (row at: #lqi_315) average  ] as: #avg_315
		";
		addSumMappingFor: #tem;
		addMaxMappingFor: #wind_ws_gust;
		addMinMappingFor: #temperature_ws".
	agregated := agregator aggregate: col.

	self should: [ agregated size = 1 ].
	self should: [ 
		((agregated  first value at: #when) ) = '2025-03-31T22:00:00+00:00' ].

	
	self should: [ 
		((agregated first value at: #lqi_315) notNil )].

	self should: [ 
		((agregated first value at: #lqi_315) size = 40 )]	.
			self should: [ 
		((agregated first value at: #avg_315) notNil )]	


]

{ #category : #tests }
DictionaryAggregatorTest >> testHourlyAppendMappingsIntoDataset [

	| col agregator agregated dtView|
	col := self getCollectionToAggregateWithAppends.

	self should: [ col size = 2 ].



	agregator := DictionaryAggregator new.
	agregator
		keyAspect: #when;
		hourly;
		addAppendMappingFor: #lqi_315;
		addBlockMapping: [ :row | (row at: #lqi_315) average  ] as: #avg_315
		";
		addSumMappingFor: #tem;
		addMaxMappingFor: #wind_ws_gust;
		addMinMappingFor: #temperature_ws".
	agregated := agregator aggregate: col.

	self should: [ agregated size = 1 ].
	self should: [ 
		((agregated  first value at: #when) ) = '2025-03-31T22:00:00+00:00' ].

	
	self should: [ 
		((agregated first value at: #lqi_315) notNil )].

	self should: [ 
		((agregated first value at: #lqi_315) size = 40 )]	.
			self should: [ 
		((agregated first value at: #avg_315) notNil )]	.
		
dtView :=
(DatasetView
		   name: 'avg_315'
		   source: (agregated collect:[:each| each value])
		   keyBlock: [ :entry | entry at: 'when' ])
		  columns: #( 'avg_315' 'when' ).
		
	 
	self should:[(dtView asDictionarySource first at: #avg_315) = (79/2)]
]

{ #category : #tests }
DictionaryAggregatorTest >> testHourlyMultiMappings [

	| col agregator result|
	col := self getCollectionToAggregate.

	self should: [ col size = 3 ].



	agregator := DictionaryAggregator new.
	agregator
		keyAspect: #when;
		hourly;
		addAverageMappingFor: #hum;
		addSumMappingFor: #tem;
		addMaxMappingFor: #wind_ws_gust;
		addMinMappingFor: #temperature_ws.
	result := agregator aggregate: col.

	self should: [ result size = 2 ].
	self should: [ 
		((result first value at: #when) ) = ('2023-11-28T13:00:00+00:00') ].
	self should: [ 
		((result first value at: #hum) notNil )]
]

{ #category : #tests }
DictionaryAggregatorTest >> testMultiMappingsFilter [

	| col agregator rsp aggregated |
	 col := self getCollectionToAggregate.


	self should: [ col size = 3 ].
	self should: [ 
		((col first at: #when) printString) = '2023-11-28T13:03:38.897+00:00' ].
	agregator := DictionaryAggregator new.
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
		= '2023-11-28T13:38:45.393+00:00' ].
	self should: [ (aggregated first value at: #hum) = 66.7 ]
]

{ #category : #tests }
DictionaryAggregatorTest >> testTwoHourlyAppendMappingsIntoDataset [

	| col agregator agregated dtView|
	col := self getCollection3ToAggregateWithAppends.

	self should: [ col size = 3 ].



	agregator := DictionaryAggregator new.
	agregator
		keyAspect: #when;
		hourly;
		addAppendMappingFor: #lqi_315;
		addBlockMapping: [ :row | self halt. (row at: #lqi_315) sum -> (row at: #lqi_315) size   ] as: #avg_315
		";
		addSumMappingFor: #tem;
		addMaxMappingFor: #wind_ws_gust;
		addMinMappingFor: #temperature_ws".
	agregated := agregator aggregate: col.

	self should: [ agregated size = 2 ].
	self should: [ 
		((agregated  first value at: #when) ) = '2025-03-31T22:00:00+00:00' ].

	self should: [ 
		((agregated  last value at: #when) ) = '2025-03-31T23:00:00+00:00' ].
	
	self should: [ 
		((agregated first value at: #lqi_315) notNil )].

	self should: [ 
		((agregated first value at: #lqi_315) size = 40 )]	.
			self should: [ 
		((agregated first value at: #avg_315) notNil )]	.
		
dtView :=
(DatasetView
		   name: 'avg_315'
		   source: (agregated collect:[:each| each value])
		   keyBlock: [ :entry | entry at: 'when' ])
		  columns: #( 'avg_315' 'when' ).
		
	 
	self should:[(dtView asDictionarySource first at: #avg_315) = (793/20)].
	self should:[(dtView asDictionarySource last at: #avg_315) = (79/2)]
]

{ #category : #'as yet unclassified' }
DictionaryAggregatorTest >> threeEntriesWithOneMultiValue [
^'[{
"fw": "Miramar-Apr2024",
"lqi_315": [
39,
40,
40,
39,
41,
40,
40,
39,
39,
38,
39,
40,
40,
39,
41,
40,
40,
39,
39,
38
],
"lqi_433": [
39,
40,
40,
39,
41,
40,
40,
39,
39,
38,
39,
40,
40,
39,
40,
40,
40,
39,
0,
0
],
"lqi_868": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"lqi_915": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"nodeId": "a4cf1245c424",
"response_time_315": [
4,
4,
4,
4,
4,
4,
4,
4,
4,
4,
3,
4,
4,
4,
4,
4,
4,
4,
4,
4
],
"response_time_433": [
5,
4,
4,
4,
4,
4,
4,
4,
4,
4,
5,
4,
4,
4,
4,
4,
4,
4,
0,
0
],
"response_time_868": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"response_time_915": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"rssi_315": [
-83,
-83,
-82,
-83,
-83,
-83,
-83,
-82,
-84,
-83,
-83,
-84,
-83,
-83,
-83,
-83,
-84,
-82,
-83,
-83
],
"rssi_433": [
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
0,
0
],
"rssi_868": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"rssi_915": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"timeDeltaM": 30,
"when": "2025-03-31T22:07:06.352Z"
},
{
"fw": "Miramar-Apr2024",
"lqi_315": [
39,
40,
40,
39,
41,
40,
40,
39,
39,
38,
39,
40,
40,
39,
41,
40,
40,
39,
39,
38
],
"lqi_433": [
39,
40,
40,
39,
41,
40,
40,
39,
39,
38,
39,
40,
40,
39,
40,
40,
40,
39,
0,
0
],
"lqi_868": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"lqi_915": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"nodeId": "a4cf1245c424",
"response_time_315": [
4,
4,
4,
4,
4,
4,
4,
4,
4,
4,
3,
4,
4,
4,
4,
4,
4,
4,
4,
4
],
"response_time_433": [
5,
4,
4,
4,
4,
4,
4,
4,
4,
4,
5,
4,
4,
4,
4,
4,
4,
4,
0,
0
],
"response_time_868": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"response_time_915": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"rssi_315": [
-83,
-83,
-82,
-83,
-83,
-83,
-83,
-82,
-84,
-83,
-83,
-84,
-83,
-83,
-83,
-83,
-84,
-82,
-83,
-83
],
"rssi_433": [
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
0,
0
],
"rssi_868": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"rssi_915": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"timeDeltaM": 30,
"when": "2025-03-31T23:47:06.352Z"
},
{
"fw": "Miramar-Apr2024",
"lqi_315": [
39,
40,
40,
39,
41,
40,
40,
39,
40,
38,
39,
40,
40,
40,
41,
40,
40,
40,
40,
40
],
"lqi_433": [
39,
40,
40,
39,
41,
40,
40,
39,
39,
38,
39,
40,
40,
39,
40,
40,
40,
39,
0,
0
],
"lqi_868": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"lqi_915": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"nodeId": "a4cf1245c424",
"response_time_315": [
4,
4,
4,
4,
4,
4,
4,
4,
4,
4,
3,
4,
4,
4,
4,
4,
4,
4,
4,
4
],
"response_time_433": [
5,
4,
4,
4,
4,
4,
4,
4,
4,
4,
5,
4,
4,
4,
4,
4,
4,
4,
0,
0
],
"response_time_868": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"response_time_915": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"rssi_315": [
-83,
-83,
-82,
-83,
-83,
-83,
-83,
-82,
-84,
-83,
-83,
-84,
-83,
-83,
-83,
-83,
-84,
-82,
-83,
-83
],
"rssi_433": [
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
0,
0
],
"rssi_868": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"rssi_915": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"timeDeltaM": 30,
"when": "2025-03-31T22:47:06.352Z"
}	]'
]

{ #category : #'as yet unclassified' }
DictionaryAggregatorTest >> twoEntriesWithOneMultiValue [
^'[{
"fw": "Miramar-Apr2024",
"lqi_315": [
39,
40,
40,
39,
41,
40,
40,
39,
39,
38,
39,
40,
40,
39,
41,
40,
40,
39,
39,
38
],
"lqi_433": [
39,
40,
40,
39,
41,
40,
40,
39,
39,
38,
39,
40,
40,
39,
40,
40,
40,
39,
0,
0
],
"lqi_868": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"lqi_915": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"nodeId": "a4cf1245c424",
"response_time_315": [
4,
4,
4,
4,
4,
4,
4,
4,
4,
4,
3,
4,
4,
4,
4,
4,
4,
4,
4,
4
],
"response_time_433": [
5,
4,
4,
4,
4,
4,
4,
4,
4,
4,
5,
4,
4,
4,
4,
4,
4,
4,
0,
0
],
"response_time_868": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"response_time_915": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"rssi_315": [
-83,
-83,
-82,
-83,
-83,
-83,
-83,
-82,
-84,
-83,
-83,
-84,
-83,
-83,
-83,
-83,
-84,
-82,
-83,
-83
],
"rssi_433": [
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
0,
0
],
"rssi_868": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"rssi_915": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"timeDeltaM": 30,
"when": "2025-03-31T22:07:06.352Z"
},
{
"fw": "Miramar-Apr2024",
"lqi_315": [
39,
40,
40,
39,
41,
40,
40,
39,
39,
38,
39,
40,
40,
39,
41,
40,
40,
39,
39,
38
],
"lqi_433": [
39,
40,
40,
39,
41,
40,
40,
39,
39,
38,
39,
40,
40,
39,
40,
40,
40,
39,
0,
0
],
"lqi_868": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"lqi_915": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"nodeId": "a4cf1245c424",
"response_time_315": [
4,
4,
4,
4,
4,
4,
4,
4,
4,
4,
3,
4,
4,
4,
4,
4,
4,
4,
4,
4
],
"response_time_433": [
5,
4,
4,
4,
4,
4,
4,
4,
4,
4,
5,
4,
4,
4,
4,
4,
4,
4,
0,
0
],
"response_time_868": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"response_time_915": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"rssi_315": [
-83,
-83,
-82,
-83,
-83,
-83,
-83,
-82,
-84,
-83,
-83,
-84,
-83,
-83,
-83,
-83,
-84,
-82,
-83,
-83
],
"rssi_433": [
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
-61,
0,
0
],
"rssi_868": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"rssi_915": [
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
],
"timeDeltaM": 30,
"when": "2025-03-31T22:47:06.352Z"
}	]'
]
