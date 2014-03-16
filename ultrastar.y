%{
  #include <iostream>
  #include <sstream>
  #include <string.h>
  #include <fstream>
  #include <cstdio>
  #include "blitzloop_data.h"
  using namespace std;

  extern "C" int yylex();
  extern "C" int yyparse();
  extern "C" FILE *yyin;
  extern int line_num;
  // this needs to be set to something if you want to filter tildes and such! Defaults to empty string -> no characters are filtered
  extern string metaChars;
  
  // Variables to build Ultrastar data
  //! The last beat - needed to calculate the difference to current beat, which is what blitzloop uses
  int lastBeat = 0;
  //! the duration of the previous note - only needed for the last notes of each line, and very last one, since all others are determined by the difference to the previous note
  int lastDuration = 0;
  //! The lyrics line we're currently working on - each syllable will be added to this
  stringstream currentLyrics;
  //! The timing line we're currently working on
  stringstream currentTiming;
  //! the entire lyrics data block
  stringstream lyricsBlock;
  
  //! the meta data block
  stringstream metaBlock;
  //! the GAP value from the ultrastar file (defaults to 0)
  int gap = 0;
  //! bpm value - needs to be saved because we can't use it until we found the line count (mandatory, if -1 by the time we're done parsing, throw a fit)
  float bpm = -1.0;
  //! whether the offsets are relative - this will influence calculations, but only a little (optional tag, defaults to false)
  bool relative = false;
  //! the number of lines in the song (NOT the song file!)
  int lineCount = 0;
  Meta metaData;
  Song songInfo;
  Timing timingInfo;

  int lineStart = 0;
  //! set to true whenever a line end is found - the next syllable will set the line start for the next line
  bool newLine = false;
  //! used whenever we encounter a single ~ character -- these are UltraStar's syllable-joiners and should not show up in BlitzLoop output, so we hide the syllables and carry over their timing length to the next one
  int carry = 0;
  void appendLine() {
    currentLyrics << "$\n";
    currentTiming << " " << lastDuration + carry;
    carry = 0;
    lyricsBlock << currentLyrics.str() << currentTiming.str() << "\n\n";
    currentLyrics.str("");
    currentLyrics.clear();
    currentLyrics << "L: ";
    currentTiming.str("");
    currentTiming.clear();
    currentTiming << "@: ";
    newLine = true;
  }

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
%token <fl>   FRACTION
%token <text> END
%token <text> NOTETYPE
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
%token <text> LANGUAGE
%token <text> VIDEOGAP
%token <text> UNKNOWNTAG

%%

input: /* empty */
| song 
{
  // cout << "Finalizing output...\n" << endl; 
}
;

song: tags data END 
{
  // cout << "Tags and Data are done." << endl; 
  appendLine();
  lastBeat += lastDuration;
  
  // write song meta data to metaBlock stringstream - if any vital value is absent (string length == 0), throw error
  
  // [Meta] part
  if (metaData.title.length() == 0) yyerror("No Title!");  
  if (metaData.artist.length() == 0) yyerror("No Artist!");

  metaBlock << "[Meta]\n";
  metaBlock << "title=" << metaData.title << "\n";
  metaBlock << "artist=" << metaData.artist << "\n";
  if (metaData.album.length() == 0) {
    cout << "Warning: No Album!" << endl;
  } else {
    metaBlock << "album=" << metaData.album << "\n";
  }
  if (metaData.seenon.length() == 0) {
    cout << "Warning: No Edition/Seenon!" << endl;
  } else {
    metaBlock << "seenon=" << metaData.seenon << "\n";
    metaBlock << "seenon[l]=" << metaData.seenon << "\n";
  }
  if (metaData.genre.length() == 0) {
    cout << "Warning: No Genre!" << endl;
  } else {
    metaBlock << "genre[*]=" << metaData.genre << "\n";
  }
  if (metaData.lang.length() == 0) {
    cout << "Warning: No language! (Setting to English to avoid confusing blitzloop)" << endl;
    metaData.lang = "English";
  } else {
    metaBlock << "lang[*]=" << metaData.lang << "\n\n";
  }

  // [Song] part
  if (songInfo.audio.length() == 0) yyerror("No song file!");

  metaBlock << "[Song]\n";
  metaBlock << "audio=" << songInfo.audio << "\n";
  if (songInfo.video.length() == 0) {
    cout << "Warning: No video file!" << endl;
  } else {
    metaBlock << "video=" << songInfo.video << "\n";
  }
  if (songInfo.video_offset.length() == 0) {
    cout << "Warning: No video offset! Assuming 0" << endl;
    songInfo.video_offset = "0.0";
  }
  metaBlock << "video_offset=" << songInfo.video_offset << "\n";
  if (songInfo.cover.length() == 0) {
    cout << "Warning: No cover file!" << endl;
  } else {
    metaBlock << "cover=" << songInfo.cover << "\n\n";
  }

  // [Timing] part
  if (bpm < 0) {
    yyerror("No BPM given!");
  }
  if (relative) {
      lastBeat += lineStart;
  }
  timingInfo = UStoBLtiming(gap, bpm, lastBeat);
  metaBlock << "[Timing]\n";
  metaBlock << "@" << timingInfo.startTime << "=" << timingInfo.startCount << "\n";
  metaBlock << "@" << timingInfo.endTime << "=" << timingInfo.endCount << "\n\n";

  // Add prefab [Formats] [Styles] [Variants] block
  metaBlock << FormatsStylesVariantsDefault;

  //cout << metaBlock.str() << lyricsBlock.str() << endl;
}
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
| tags languageTag
| tags coverTag
| tags videogapTag
| tags unknown
;

unknown: UNKNOWNTAG STRING
{
    // Nothing!
    cout << "Warning: Tag " << *$1 << *$2 << " ignored." << endl;
};

titleTag: TITLE STRING 
{
  metaData.title = *$2; 
  // cout << "Title is " << metaData.title << endl; 
};
artistTag: ARTIST STRING 
{
  metaData.artist = *$2; 
  // cout << "Artist is " << metaData.artist << endl; 
};
mp3Tag: MP3 STRING 
{
  songInfo.audio = *$2;
  // cout << "Song file is " << songInfo.audio << endl;
};
gapTag: GAP INT 
{
  gap = $2;
  // cout << "gap is " << gap << endl;
};
bpmTag: BPM INT FRACTION 
{
  bpm = ((float) $2) + $3;
  // cout << "BPM is " << bpm << endl;
}
| BPM INT 
{
  bpm = $2;
  // cout << "BPM is " << bpm << endl;
}
;
genreTag: GENRE STRING 
{
 metaData.genre = *$2;
 // cout << "Genre is " << metaData.genre << endl;
};
editionTag: EDITION STRING 
{
  metaData.seenon = *$2;
  // cout << "Edition is " << metaData.seenon << endl;
};
videoTag: VIDEO STRING 
{
  songInfo.video = *$2;
  // cout << "Video file is " << songInfo.video << endl;
};
backgroundTag: BACKGROUND STRING /* blitzloop doesn't have static backgrounds yet */;
relativeTag: RELATIVE BOOL 
{
  relative = $2;
  if (relative) {
      // cout << "Song file is relative!" << endl;
  }
};
languageTag: LANGUAGE STRING 
{
  metaData.lang = *$2;
  // cout << "Language is " << metaData.lang << endl;
};
coverTag: COVER STRING 
{
  songInfo.cover = *$2;
  // cout << "Cover file at " << songInfo.cover << endl;
};
videogapTag : VIDEOGAP INT FRACTION 
{
  float value = ((float) $2) + $3;
  ostringstream tmp;
  tmp << value;
  songInfo.video_offset = tmp.str();
  // cout << "Video offset is " << songInfo.video_offset << endl;
}
| VIDEOGAP INT 
{
  float value = (float) $2;
  ostringstream tmp;
  tmp << value;
  songInfo.video_offset = tmp.str();
  // cout << "Video offset is " << songInfo.video_offset << endl;
}
;

data: /* empty */
| data NOTETYPE INT INT INT STRING 
{ 
  // cut off the leading space (there will always be one to separate the syllable from the last number)  
  const char* syllable = (*$6).c_str() + 1;

  // If the string is empty or contains just a single space, the lexer has removed one or more Tilde characters, so this line should be merged with the previous syllable
  bool isSpacer = $6->length() < 2;

  //since we can only calculate the duration for the previous note, don't append anything to currentTiming on new line
  if (newLine) {
    int start = $3;
    if (relative) {
      start += lineStart;
    }
    currentTiming << start << " ";
  } else 
  {
    if (isSpacer) {
      carry += $3 - lastBeat;
    } else {
      currentTiming << " " << ($3 - lastBeat) + carry;
      carry = 0;
    }
  }
  
  // if there's another space in front of the syllable, move it outside of the curly braces
  // (this doesn't account for trailing spaces, but they won't throw off the timing as much anyway)
  if (!isSpacer) {
    if (syllable[0] == ' ') {
      currentLyrics << " {" << syllable + 1 << "}";
    } else {
      currentLyrics << "{" << syllable << "}";
    }
  } else if (newLine) {
    // if there's a "spacer" character at the beginning of a line, print if, because carrying over line breaks is tedious...
    currentLyrics << "{~}";
  }

  lastBeat = $3;
  lastDuration = $4;
  newLine = false;
}
| data line_end 
{
  //cout << "appending line" << endl; 
  appendLine(); 
}
;

line_end : LINEBREAK INT INT 
{
  if (relative) {
    lineStart += $3;
  }
  //cout << "EOL: " << $2 << $3 << endl; 
}
| LINEBREAK INT 
{
  if (relative) {
    lineStart += $2;
  }
  //cout << "EOL: " << $2 << endl; 
}

%%

int main(int argc, char** argv) {
  if (argc < 3) { 
    cout << "Wrong number of arguments!\nUsage:\nultraloop ultrastar_in.txt blitzloop_out.txt [syllable_joiners]" << endl;
    return 1; 
  }
  FILE *myfile = fopen(argv[1], "r");
  if (!myfile) {
    cout << "Can't open input file!" << endl;
    return 1;
  }
  yyin = myfile;

  // Filter out tilde and dash by default
  metaChars = "~-";

  if (argc == 4) {
    metaChars = argv[3];
  }

  lyricsBlock << "[Lyrics]\n\n";
  currentLyrics << "L: ";
  currentTiming << "@: ";
  newLine = true;
  do {
    yyparse();
  } while(!feof(yyin));

  ofstream output(argv[2]);
  if (!output.good()) {
    cout << "Can't open output file - will print output to stdio" << endl;
  } else {
    output << metaBlock.str() << lyricsBlock.str() << endl;
    output.close();
    return 0;
  }
  
  cout << metaBlock.str() << lyricsBlock.str() << endl;
}


void yyerror(const char* s) {
  cout << "OHNOES! Error Message on line " << line_num + 1 << ": " << s << endl;
  exit(1);
}
