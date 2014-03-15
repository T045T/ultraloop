#ifndef BLITZLOOP_DATA_H
#define BLITZLOOP_DATA_H

struct Meta {
  std::string title;
  std::string artist;
  std::string album;
  std::string seenon;
  std::string genre;
  std::string lang;
};

struct Song {
  std::string audio;
  std::string video;
  std::string video_offset;
  std::string cover;
};

struct Timing {
  float startTime;
  int startCount;
  float endTime;
  int endCount;
};

/**
 * gap is in MS, BPM is, well, BPM, endCount is the number of the last beat
 * TODO: Last beat the same as last syllable start or end? Assuming from marcans files it's somewhere behind
 * Timing.endCount 
 */
Timing UStoBLtiming(int gap, float bpm, int endBeat) {
  Timing result;
  result.startTime = ((float) gap) / 1000.f;
  result.startCount = 0;
  float secondsPerBeat = 60.f / bpm;
  result.endTime = result.startTime + ((float) endBeat) * secondsPerBeat;
  result.endCount = endBeat;
  return result;
}
std::string FormatsStylesVariantsDefault = "[Formats]\nL=Latin\n\n[Styles]\n{latin}\nfont=TakaoPGothic.ttf\nsize=11\noutline_width=0.3\nborder_width=0.8\ncolors=ffffff,12309A,000000\ncolors_on=12309A,ffffff,000000\n\n[Variants]\n{latin}\nname=latin\ntags=L\nstyle=latin\n\n";

#endif
