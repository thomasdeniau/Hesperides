#ifndef transcriptionH
#define transcriptionH

//#if HAVE_STRING
  #include <string>
//#else
//  #error Cannot compile Narmacil: string class not supported
//#endif

#include "mylist.h"

#define ENGINEVER "Narmacil/2.1.2"
#define NON_ALPHA_NUM 13
#define VERSION2TAG string("<TMF2>")

//using std::list;
using std::string;

long atol(string s);
string ltoa(long n);

string ExtractFilePath(string s);
string ExtractFileName(string s);

typedef struct
{
  mylist<string> *src[256], *next[256], *prev[256], *dest[256], *id[256];
} SOneWayMode;

class CMode
{
  public:
    int version;
    string text, path, comment;
    bool casesens;
    SOneWayMode r2t, t2r;
    CMode();
    ~CMode();
};

class CTranscription;

class CTranscription
{
  private:
    long int cislo;
    bool stop, UseSmart, TreatNumbersSeparately, alert, lsd, decimal, digits;
    mylist<string> equivs;
    CMode mode, mode2;
    int RomanHash(unsigned char c);
    int TengHash(unsigned char c);
    bool IsWhiteChar(unsigned char c);
    bool IsTengAlphaNum(unsigned char c);
    bool IsTehta(unsigned char c);
    string dec2duodec(string val);
    string duodec2dec(string val);
    string(*matchcase)(string s);
    bool SmartCompare(string left, string right);
    char GetTengwarDigit(char c);
    char GetRomanDigit(char c);
    bool GetNextEntry(char *&b, SOneWayMode mode, int (CTranscription::*HashF)(unsigned char X));
    void AutoReverse();
    void Optimize(SOneWayMode m);
  public:
    CTranscription();
    ~CTranscription();
    const char *Roman2Tengwar(const char *str);
    const char *Tengwar2Roman(const char *p);
    void LoadMode(const char *filename);
    bool GetLSD(){return lsd;}
    void SetLSD(bool value){lsd=value;}
    bool GetDecimal(){return decimal;}
    void SetDecimal(bool value){decimal=value;}
    bool GetDigits(){return digits;}
    void SetDigits(bool value){digits=value;}
    bool GetAlert(){return alert;}
    void SetAlert(bool value){alert=value;}
    bool GetSmart(){return UseSmart;}
    void SetSmart(bool value){UseSmart=value;}
    bool GetSeparateNums(){return TreatNumbersSeparately;}
    void SetSeparateNums(bool value){TreatNumbersSeparately=value;}
    const char *GetModeName(){return mode.text.c_str();}
    const char *GetModePath(){return mode.path.c_str();}
    const char *GetModeComment(){return mode.comment.c_str();}
    bool GetModeCaseSensitivity(){return mode.casesens;}
    int GetModeVersion(){return mode.version;}
    const char *GetVersion(){return ENGINEVER;}
};

#endif
