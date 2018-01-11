grammar Wordnet;
@header {
    package org.wordnet.parser;
    import java.util.*;
    import org.wornet.model.*;
}

wordnet:'{'nwordline '(' ngloss ')' '}';

nwordline locals[List words,List nwordClusters,List npointers]
@init{
	$words = new ArrayList();
	$nwordClusters = new ArrayList();
	$npointers = new ArrayList();
}:(
	tword=nword{
	WordModel model = new WordModel( $tword.word,$tword.marker,$tword.lex_id);
	$words.add(model);	
	} |twordcluster=nwordcluster{
		$nwordClusters.add($twordcluster.nwordPointerModel);
	}|tpointer=npointer{
		NPointerModel pointerModel = new NPointerModel($tpointer.tfile_name,$tpointer.tpointerWords,$tpointer.trelationship);
	    $npointers.add(pointerModel);
	}|nframes)+;

//Addings the word ,marker lex_id to extract word properties
nword returns[String word,String marker,String lex_id] : word_def_context=word_def { $word = $word_def_context.word; $marker= $word_def_context.marker; $lex_id = $word_def_context.lex_id; }  ',' ;

//Addings the word ,marker lex_id to extract word_def properties
word_def returns[String word,String marker,String lex_id] : word_=WORD { $word = $word_.getText();} ( '(' marker_=WORD { $marker = $marker_.getText();}')')? (lex_id_=NUM { $lex_id = $lex_id_.getText();})?;

nwordcluster returns[NWordPointerModel nwordPointerModel]
@init{
	$nwordPointerModel = new NWordPointerModel();
}
:'[' tword=nword{
	WordModel word = new WordModel( $tword.word,$tword.marker,$tword.lex_id);
	$nwordPointerModel.setWordModel(word);
} (tpointer=npointer{
	NPointerModel pointerModel = new NPointerModel($tpointer.tfile_name,$tpointer.tpointerWords,$tpointer.trelationship);
	$nwordPointerModel.addNPointerModel(pointerModel);
})* nframes*']';

npointer returns[String tfile_name,List tpointerWords,String trelationship]:
(file_name=word_def{$tfile_name = $file_name.word; } ':')? 
pointerword=npointerword{ $tpointerWords=$pointerword.words;} ',' 
relationship=POINTERSYMBOL {$trelationship=$relationship.getText();} ;

npointerword returns[List words]
@init{
	$words = new ArrayList();
}: first=word_def{ $words.add($first.word); } ('^' other=word_def { $words.add($other.word);})*;
//ngloss: (WORD|NUM|POINTERSYMBOL|ALL_CHARS)*;
ngloss: (.)*?;
nframes: 'frames:' NUM+;


//ALL_CHARS:[!#$%^&*()_}{\[\]=|\\";:<>?/,~`];
WORD : ([a-zA-Z-._']|NUMWORD)+;
NUMWORD :[0-9]+'"';
NUM : [0-9]+;
POINTERSYMBOL:[+@];
WS: (' ' |'\n' |'\r' )+ {skip();} ;




