Class {
	#name : #DictionaryAggregatorTest,
	#superclass : #DatasetAggregatorTest,
	#category : #'DatasetUtilities-Tests'
}

{ #category : #tests }
DictionaryAggregatorTest >> getCollectionToAggregate [

	^ (NeoJSONReader on: self threeEntriesJson readStream) next collect: [ 
		  :each | 
		  each at: #when put: (DateAndTime fromString: (each at: #when)).
		  each ]
]

{ #category : #tests }
DictionaryAggregatorTest >> testHourlyMultiMappings [

	| col agregator |
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
	agregator aggregate: col.

	self should: [ col size = 3 ].
	self should: [ 
		((col first at: #when) printString) = '2023-11-28T13:03:38.897+00:00' ]
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
