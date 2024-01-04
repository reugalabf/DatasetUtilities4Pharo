Class {
	#name : #DatasetJointerTest,
	#superclass : #TestCase,
	#category : #'DatasetUtilities-Tests'
}

{ #category : #tests }
DatasetJointerTest >> datasetViewH [

	^ (DatasetView
		   name: 'H'
		   source:
			   ((CSV2JSONStream source: self hCSVDataset readStream) 
				    nextListAs: nil)
		   keyBlock: [ :entry | entry at: 'a' ])
		  columns: #( 'b' );
		  yourself
]

{ #category : #tests }
DatasetJointerTest >> datasetViewK [

	^ (DatasetView
		   name: 'K'
		   source:
			   ((CSV2JSONStream source: self kCSVDataset readStream) 
				    nextListAs: nil)
		   keyBlock: [ :entry | entry at: 'a' ])
		  columns: #( 'r' 't' );
		  yourself
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
