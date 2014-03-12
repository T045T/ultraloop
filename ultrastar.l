%{
#include <iostream>
#define YY_DECL extern "C" int yylex()
#include "ultrastar.tab.h"

%}
%%
[\s];
^E		{ yylval.text = new std::string(yytext); return END; }
^(#)TITLE:	{ yylval.text = new std::string(yytext); return TITLE; }
^(#)ARTIST:	{ yylval.text = new std::string(yytext); return ARTIST; }
^(#)MP3:		{ yylval.text = new std::string(yytext); return MP3; }
^(#)GAP:		{ yylval.text = new std::string(yytext); return GAP; }
^(#)BPM:		{ yylval.text = new std::string(yytext); return BPM; }
^(#)GENRE:	{ yylval.text = new std::string(yytext); return GENRE; }
^(#)EDITION:	{ yylval.text = new std::string(yytext); return EDITION; }
^(#)COVER:	{ yylval.text = new std::string(yytext); return COVER; }
^(#)VIDEO:	{ yylval.text = new std::string(yytext); return VIDEO; }
^(#)BACKGROUND:	{ yylval.text = new std::string(yytext); return BACKGROUND; }
^(#)RELATIVE:	{ yylval.text = new std::string(yytext); return RELATIVE; }


[0-9]+[,\.][0-9]+ { yylval.fl   = atof(yytext); return FLOAT; }
[0-9]+		{ yylval.num  = atoi(yytext); return INT; }
^[:*F]		{ yylval.text = new std::string(yytext); return LINESTART; }
^-		{ yylval.text = new std::string(yytext); return LINEBREAK; }
.		{ yylval.text = new std::string(yytext); return STRING; }
YES		{ yylval.boolean = true; return BOOL; }
TRUE		{ yylval.boolean = true; return BOOL; }
NO		{ yylval.boolean = false; return BOOL; }
FALSE		{ yylval.boolean = false; return BOOL; }

%%
