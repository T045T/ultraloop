%{
  #include <iostream>
  #include <cstdio>
  using namespace std;

  extern "C" int yylex();
  extern "C" int yyparse();
  extern "C" FILE *yyin;
  
  void yyerror(const char* s);
%}

 %union{
   int num;
   float fl;
   std::string* text;
   bool boolean;
 }

%start input

%token <boolean> BOOL
%token <num>  INT
%token <text> STRING
%token <fl>   FLOAT
%token <text> END
%token <text> LINESTART
%token <text> LINEBREAK
%token <text> TITLE
%token <text> ARTIST
%token <text> MP3
%token <text> GAP
%token <text> BPM
%token <text> GENRE
%token <text> EDITION
%token <text> COVER
%token <text> VIDEO
%token <text> BACKGROUND
%token <text> RELATIVE

%%

input: /* empty */
| song { cout << "Song data:\n" << endl; }
;

song: tags data END { cout << "Song" << endl; }
;
tags: /* empty */
| tags titleTag
| tags artistTag
| tags mp3Tag
| tags gapTag
| tags bpmTag
| tags genreTag
| tags editionTag
| tags videoTag
| tags backgroundTag
| tags relativeTag
;

titleTag: TITLE STRING;
artistTag: ARTIST STRING;
mp3Tag: MP3 STRING;
gapTag: GAP INT;
bpmTag: BPM FLOAT;
genreTag: GENRE STRING;
editionTag: EDITION STRING;
videoTag: VIDEO STRING;
backgroundTag: BACKGROUND STRING;
relativeTag: RELATIVE BOOL;

data: /* empty */
| data LINEBREAK INT INT INT STRING { cout << "line: " << $2 << $3 << $4 << $5 << $6 << endl; }

%%

int main(int argc, char** argv) {
  if (argc != 2) { 
    cout << "Wrong number of arguments!" << endl;
    return 1; 
  }
  FILE *myfile = fopen(argv[1], "r");
  if (!myfile) {
    cout << "Can't open input file!" << endl;
    return 1;
  }
  yyin = myfile;
  do {
    yyparse();
  } while(!feof(yyin));
}


void yyerror(const char* s) {
  cout << "OHNOES! Error Message: " << s << endl;
  exit(1);
}
