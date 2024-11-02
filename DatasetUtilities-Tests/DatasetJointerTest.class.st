Class {
	#name : #DatasetJointerTest,
	#superclass : #TestCase,
	#category : #'DatasetUtilities-Tests'
}

{ #category : #tests }
DatasetJointerTest >> datasetViewH [

	^ (DatasetView
		   name: 'H'
		   source: (CSV2DictionaryStream
				    source: self hCSVDataset readStream
				    filteredHeaders: #( a b c )) contents
		   keyBlock: [ :entry | entry at: 'a' ])
		  columns: #( 'b' );
		  yourself
]

{ #category : #tests }
DatasetJointerTest >> datasetViewK [

	^ (DatasetView
		   name: 'K'
		   source:
			   ((CSV2DictionaryStream source: self kCSVDataset readStream) 
				    filteredHeaders: #( a r s t )) contents
		   keyBlock: [ :entry | entry at: 'a' ])
		  columns: #( 'r' 't' );
		  yourself
]

{ #category : #tests }
DatasetJointerTest >> datasetViewKFull [

	^ (DatasetView
		   name: 'K'
		   source:
			   ((CSV2DictionaryStream source: self kCSVDataset readStream) 
				    filteredHeaders: #( a r s t )) contents
		   keyBlock: [ :entry | entry at: 'a' ])
		  columns: #( 'r' 't' 's' );
		  yourself
]

{ #category : #tests }
DatasetJointerTest >> datasetViewQ [

	^ (DatasetView
		   name: 'Q'
		   source:
			   ((CSV2DictionaryStream source: self qCSVDataset readStream) 
				    filteredHeaders: #( a rr ss t_t )) contents
		   keyBlock: [ :entry | entry at: 'a' ])
		  columns: #( 'rr' 't_t' );
		  yourself
]

{ #category : #'as yet unclassified' }
DatasetJointerTest >> expectedCSV [
^ 'H.b,key,K.r,K.t
b1,a1,r1, t1
 b2, a2, r2,t2
b3,a3,r3,t3'
]

{ #category : #'as yet unclassified' }
DatasetJointerTest >> expectedJson [
^ '[
	{
		"H.b" : "b1",
		"key" : "''a1''",
		"K.r" : "r1",
		"K.t" : "t1"
	},
	{
		"H.b" : "b2",
		"key" : "''a2''",
		"K.r" : "r2",
		"K.t" : "t2"
	},
	{
		"H.b" : "b3",
		"key" : "''a3''",
		"K.r" : "r3",
		"K.t" : "t3"
	}
]'
]

{ #category : #tests }
DatasetJointerTest >> hCSVDataset [
^
'a,b,c
a1,b1,c1
a2,b2,c2
a3,b3,c3'
]

{ #category : #tests }
DatasetJointerTest >> kCSVDataset [
^
'a,r,s,t
a1,r1,s1,t1
a2,r2,s2,t2
a3,r3,s3,t3'
]

{ #category : #tests }
DatasetJointerTest >> qCSVDataset [
^
'a,rr,ss,t_t
a1,r1,s1,t1
a2,r2,s2,t2
a3,r3,s3,t3
a4,r4,s4,t4'
]

{ #category : #tests }
DatasetJointerTest >> testTwoCompleteDatasets [

	| viewH viewK join |
	
	viewH := self datasetViewH.


	viewK := self datasetViewK.

	join := (DatasetJoiner new dsView1: viewH dsView2: viewK) join.
	self should: [ join size = 3 ].
	self should: [ join keys = #( 'a1' 'a2' 'a3' ) ].

	self should: [ (join at: 'a1') keys size = 4 ].
	self should: [ (join at: 'a1') keys = #( 'H.b' 'key' 'K.r' 'K.t' ) ]
]

{ #category : #tests }
DatasetJointerTest >> testTwoCompleteDatasetsAsCSV [

	| viewH viewK csv join expectedJoin |
	viewH := self datasetViewH.


	viewK := self datasetViewK.

	csv := (DatasetJoiner new dsView1: viewH dsView2: viewK) joinAsCsv.

	self should: [ 
		(join := NeoCSVReader on: csv readStream) next
		=
		(expectedJoin := NeoCSVReader on: self expectedCSV readStream) next ].

	self should: [ 
		(join := NeoCSVReader on: csv readStream) next
		=
		(expectedJoin := NeoCSVReader on: self expectedCSV readStream) next ].
	self should: [ 
		(join := NeoCSVReader on: csv readStream) next
		=
		(expectedJoin := NeoCSVReader on: self expectedCSV readStream) next ]
]

{ #category : #tests }
DatasetJointerTest >> testTwoCompleteDatasetsAsJson [

	| viewH viewK json |
	viewH := self datasetViewH.


	viewK := self datasetViewK.

	json := (DatasetJoiner new dsView1: viewH dsView2: viewK) joinAsJson.
	
	self should: [ 
		(NeoJSONReader on: json readStream) next size
		= (NeoJSONReader on: self expectedJson readStream) next size]
]

{ #category : #tests }
DatasetJointerTest >> testTwoCompleteNoMatchRowDatasets [

	| viewH viewQ join |
	
	viewH := self datasetViewH.


	viewQ := self datasetViewQ.

	join := (DatasetJoiner new dsView1: viewH dsView2: viewQ) join.
	self should: [ join size = 3 ].
	self should: [ join keys = #( 'a1' 'a2' 'a3' ) ].

	self should: [ (join at: 'a1') keys size = 4 ].
	self should: [ (join at: 'a1') keys = #( 'H.b' 'key' 'Q.rr' 'Q.t_t' ) ]
]

{ #category : #tests }
DatasetJointerTest >> testTwoIncompleteDatasets [

	| viewQ viewK join |
	
	viewQ := self datasetViewQ.


	viewK := self datasetViewKFull .

	join := (DatasetJoiner new dsView1: viewQ dsView2: viewK) join.
	self should: [ join size = 4 ].
	self should: [ join keys = #( 'a1' 'a2' 'a3' 'a4') ].

	self should: [ (join at: 'a1') keys size = 6 ].
	self should: [ (join at: 'a1') keys asSet = #( 'Q.t_t' 'Q.rr' 'key' 'K.r' 'K.t' 'K.s')asSet ].
	
]
