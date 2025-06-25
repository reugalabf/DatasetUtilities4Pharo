"
.csvfile --> CSV2Dictionary --aDictionary--> DictionaryAggregator --anotherDictionary --> DatasetView --aDatasetView-->|
                                                                                                                       |Joiner --joined:Dictionary/CSV/JSON 
.csvfile --> CSV2Dictionary --aDictionary--> DictionaryAggregator --anotherDictionary --> DatasetView --aDatasetView-->|


"
Class {
	#name : #CompletePipe,
	#superclass : #TestCase,
	#category : #'DatasetUtilities-Tests'
}
