%{
#include <iostream>
#define YY_DECL extern "C" int yylex()
#include "ultrastar.tab.h"
  //#define DEBUG_LEXER
  using namespace std;
  int triplet_count = 0;
  int line_num = 0;

  string metaChars = "";
  void debug_output(std::string output) {
    #ifdef DEBUG_LEXER
      cout << output << endl;
    #endif
  }

  void filter_string(string* input, string filterChars) {
    for (int i = 0; i < filterChars.length(); i++) {
      input->erase(remove(input->begin(), input->end(), filterChars.c_str()[i]), input->end());
    }
  }
%}

%option noyywrap
%x STRINGPARSE

%%
[ \t];

\n { line_num++; };

^E {
  debug_output("End");
  yylval.text = new std::string(yytext);
  return END;
 };

^#TITLE: {
  debug_output("Title");
  yylval.text = new std::string(yytext);
  BEGIN(STRINGPARSE);
 return TITLE;
 };

^#ARTIST: {
  debug_output("Artist");
  yylval.text = new std::string(yytext);
  BEGIN(STRINGPARSE);
return ARTIST;
 };

^#MP3: {
  debug_output("MP3");
  yylval.text = new std::string(yytext);
  BEGIN(STRINGPARSE);
  return MP3;
 };

^#GAP: {
  debug_output("Gap");
  yylval.text = new std::string(yytext);
  return GAP;
 };

^#BPM: {
  debug_output("BPM");
  yylval.text = new std::string(yytext);
  return BPM;
 };

^#GENRE: {
  debug_output("Genre");
  yylval.text = new std::string(yytext);
  BEGIN(STRINGPARSE);
  return GENRE;
 };

^#EDITION: {
  debug_output("Edition");
  yylval.text = new std::string(yytext);
  BEGIN(STRINGPARSE);
  return EDITION;
 };

^#COVER: {
  debug_output("Cover");
  yylval.text = new std::string(yytext);
  BEGIN(STRINGPARSE);
  return COVER;
 };

^#VIDEO: {
  debug_output("Video");
  yylval.text = new std::string(yytext);
  BEGIN(STRINGPARSE);
  return VIDEO;
 };

^#BACKGROUND: {
  debug_output("Background");
  yylval.text = new std::string(yytext);
  BEGIN(STRINGPARSE);
  return BACKGROUND;
 };

^#RELATIVE: {
  debug_output("Relative");
  yylval.text = new std::string(yytext);
  return RELATIVE;
 };

^#LANGUAGE: {
  debug_output("Language");
  yylval.text = new std::string(yytext);
  BEGIN(STRINGPARSE);
  return LANGUAGE;
 };

^#VIDEOGAP: {
  debug_output("Video Gap");
  yylval.text = new std::string(yytext);
  return VIDEOGAP;
 };

^#[A-Z]+: {
  debug_output("Unrecognized Tag");
  yylval.text = new std::string(yytext);
  BEGIN(STRINGPARSE);
  return UNKNOWNTAG;
 };

[,\.][0-9]+ {
  debug_output("Fraction");
  // users may use decimal comma, but atof requires point
  yytext[0] = '.';
  yylval.fl   = atof(yytext);
  return FRACTION;
};

(\ -)?[0-9]+ {
  debug_output("Int");
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
  debug_output("String");
  yylval.text = new std::string(yytext);
  filter_string(yylval.text, metaChars);
  BEGIN(INITIAL);
  return STRING;
 };

. {
  debug_output(yytext);
 };

%%
