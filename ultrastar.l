%{
#include <iostream>
#define YY_DECL extern "C" int yylex()
#include "ultrastar.tab.h"
  //#define DEBUG_LEXER
  using namespace std;
  int triplet_count = 0;
  int line_num = 0;
%}

%option noyywrap
%x STRINGPARSE

%%
[ \t];

\n { line_num++; };

^E {
#ifdef DEBUG_LEXER
  cout << "End" << endl;
#endif
  yylval.text = new std::string(yytext);
  return END;
 };

^#TITLE: {
#ifdef DEBUG_LEXER
  cout << "Title" << endl;
#endif
  yylval.text = new std::string(yytext);
  BEGIN(STRINGPARSE);
 return TITLE;
 };

^#ARTIST: {
#ifdef DEBUG_LEXER
  cout << "Artist" << endl;
#endif
  yylval.text = new std::string(yytext);
  BEGIN(STRINGPARSE);
return ARTIST;
 };

^#MP3: {
#ifdef DEBUG_LEXER
  cout << "MP3" << endl;
#endif
  yylval.text = new std::string(yytext);
  BEGIN(STRINGPARSE);
  return MP3;
 };

^#GAP: {
#ifdef DEBUG_LEXER
  cout << "Gap" << endl;
#endif
  yylval.text = new std::string(yytext);
  return GAP;
 };

^#BPM: {
#ifdef DEBUG_LEXER
  cout << "BPM" << endl;
#endif
  yylval.text = new std::string(yytext);
  return BPM;
 };

^#GENRE: {
#ifdef DEBUG_LEXER
  cout << "Genre" << endl;
#endif
  yylval.text = new std::string(yytext);
  BEGIN(STRINGPARSE);
  return GENRE;
 };

^#EDITION: {
#ifdef DEBUG_LEXER
  cout << "Edition" << endl;
#endif
  yylval.text = new std::string(yytext);
  BEGIN(STRINGPARSE);
  return EDITION;
 };

^#COVER: {
#ifdef DEBUG_LEXER
  cout << "Cover" << endl;
#endif
  yylval.text = new std::string(yytext);
  BEGIN(STRINGPARSE);
  return COVER;
 };

^#VIDEO: {
#ifdef DEBUG_LEXER
  cout << "Video" << endl;
#endif
  yylval.text = new std::string(yytext);
  BEGIN(STRINGPARSE);
  return VIDEO;
 };

^#BACKGROUND: {
#ifdef DEBUG_LEXER
  cout << "Background" << endl;
#endif
  yylval.text = new std::string(yytext);
  BEGIN(STRINGPARSE);
  return BACKGROUND;
 };

^#RELATIVE: {
#ifdef DEBUG_LEXER
  cout << "Relative" << endl;
#endif
  yylval.text = new std::string(yytext);
  return RELATIVE;
 };

^#LANGUAGE: {
#ifdef DEBUG_LEXER
  cout << "Language" << endl;
#endif
  yylval.text = new std::string(yytext);
  BEGIN(STRINGPARSE);
  return LANGUAGE;
 };

^#VIDEOGAP: {
#ifdef DEBUG_LEXER
  cout << "Video Gap" << endl;
#endif
  yylval.text = new std::string(yytext);
  return VIDEOGAP;
 };

^#[A-Z]+: {
#ifdef DEBUG_LEXER
  cout << "Unrecognized Tag" << endl;
#endif
  yylval.text = new std::string(yytext);
  BEGIN(STRINGPARSE);
  return UNKNOWNTAG;
 };

[,\.][0-9]+ {
#ifdef DEBUG_LEXER
  cout << "Fraction" << endl;
#endif
  // users may use decimal comma, but atof requires point
  yytext[0] = '.';
  yylval.fl   = atof(yytext);
  return FRACTION;
};

(-)?[0-9]+ {
#ifdef DEBUG_LEXER
  cout << "Int" << endl;
#endif
  if (triplet_count > 0 && --triplet_count == 0) {
    BEGIN(STRINGPARSE);
  }
  yylval.num  = atoi(yytext);
  return INT;
};

^[:*F] { yylval.text = new std::string(yytext); triplet_count = 3; return NOTETYPE; };
^-     { yylval.text = new std::string(yytext); return LINEBREAK; };
YES    { yylval.boolean = true; return BOOL; };
TRUE   { yylval.boolean = true; return BOOL; };
NO     { yylval.boolean = false; return BOOL; };
FALSE  { yylval.boolean = false; return BOOL; };

<STRINGPARSE>[^\r\n]+ {
#ifdef DEBUG_LEXER
  cout << "String" << endl;
#endif
  yylval.text = new std::string(yytext);
  BEGIN(INITIAL);
  return STRING;
 };

. {
#ifdef DEBUG_LEXER
  cout << "default: " << yytext << endl;
#endif
 };

%%
