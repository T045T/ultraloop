%{
#include <iostream>
#define YY_DECL extern "C" int yylex()
#include "ultrastar.tab.h"
using namespace std;
int triplet_count = 0;
%}

%x STRINGPARSE

%%
[\s];
^E		{ cout << "End" << endl; yylval.text = new std::string(yytext); return END; }
^#TITLE:	{ cout << "Title" << endl; yylval.text = new std::string(yytext); BEGIN(STRINGPARSE); return TITLE; }
^#ARTIST:	{cout << "Artist" << endl;  yylval.text = new std::string(yytext); BEGIN(STRINGPARSE); return ARTIST; }
^#MP3:		{cout << "MP3" << endl;  yylval.text = new std::string(yytext); BEGIN(STRINGPARSE); return MP3; }
^#GAP:		{cout << "Gap" << endl;  yylval.text = new std::string(yytext); return GAP; }
^#BPM:		{cout << "BPM" << endl;  yylval.text = new std::string(yytext); return BPM; }
^#GENRE:	{cout << "Genre" << endl;  yylval.text = new std::string(yytext); BEGIN(STRINGPARSE); return GENRE; }
^#EDITION:	{cout << "Edition" << endl;  yylval.text = new std::string(yytext); BEGIN(STRINGPARSE); return EDITION; }
^#COVER:	{cout << "Cover" << endl;  yylval.text = new std::string(yytext); BEGIN(STRINGPARSE); return COVER; }
^#VIDEO:	{cout << "Video" << endl;  yylval.text = new std::string(yytext); BEGIN(STRINGPARSE); return VIDEO; }
^#BACKGROUND:	{cout << "Background" << endl;  yylval.text = new std::string(yytext); BEGIN(STRINGPARSE); return BACKGROUND; }
^#RELATIVE:	{cout << "Relative" << endl;  yylval.text = new std::string(yytext); return RELATIVE; }


[0-9]+[,\.][0-9]+ {cout << "Float" << endl;  yylval.fl   = atof(yytext); return FLOAT; }
[0-9]+		{cout << "Int" << endl; if (triplet_count > 0 && --triplet_count == 0) BEGIN(STRINGPARSE);  yylval.num  = atoi(yytext); return INT; }
^[:*F]		{cout << "Line Start" << endl;  yylval.text = new std::string(yytext); triplet_count = 3; return LINESTART; }
^-		{cout << "Line Break" << endl;  yylval.text = new std::string(yytext); return LINEBREAK; }
YES		{cout << "True" << endl;  yylval.boolean = true; return BOOL; }
TRUE		{cout << "True" << endl;  yylval.boolean = true; return BOOL; }
NO		{cout << "False" << endl;  yylval.boolean = false; return BOOL; }
FALSE		{cout << "False" << endl;  yylval.boolean = false; return BOOL; }
<STRINGPARSE>.+$	{cout << "Just a string:" << yytext << endl;  yylval.text = new std::string(yytext); BEGIN(INITIAL); return STRING; }
. { cout << "default: " << yytext << endl; }

%%
