Class {
	#name : #ObjectAggregatorTest,
	#superclass : #DatasetAggregatorTest,
	#category : #'DatasetUtilities-Tests'
}

{ #category : #tests }
ObjectAggregatorTest >> getCollectionToAggregate [

	^ (NeoJSONReader on: self threeEntriesJson readStream) nextListAs:
		  FlareSenseDevelopment
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
	col := self getCollectionToAggregate.

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

	| col agregator json dicts |
	col := self getCollectionToAggregate.

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
	self should: [ (aggregated first value at: #hum) asInteger = 70 ].
	self should: [ (aggregated last value at: #tem)  = 79.5 ]	

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
	col := self getCollectionToAggregate.

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
