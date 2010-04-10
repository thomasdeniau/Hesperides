#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#ifdef DEBUG
  #include <time.h>
#endif
#include <ctype.h>
#include <locale.h>
#include <cmath>

#include "transcription.h"
#include "exception.h"

long atol(string s)
{
#ifdef SPY
	printf("atol(\"%s\")\n", s.c_str());
#endif
	return atol(s.c_str());
}

string ltoa(long n)
{
  int len;
  static string res;

  len = snprintf(0, 0, "%ld", n);
  res.resize(len);
  snprintf((char *)res.c_str(), len, "%ld", n);

  return res;
}

int pos(char c, char *str)
{
  char *p=strchr(str, c);

  if(p)
    return p-str;
  else
    return -1;
}

string trim(string s)
{
  unsigned int i,j;
  static string res;

	if (s.size() == 0) {
		return "";
	}

  for(i=0;(i<s.size())&&((s[i]==' ')||(s[i]=='\t'));i++);
  for(j=s.size()-1;(j>=i)&&((s[j]==' ')||(s[j]=='\t'));j--);

  if((s[j]==' ')||(s[j]=='\t'))
    return "";
  else
    return s.substr(i, j-i+1);
}

string ExtractFilePath(string s)
{
  string::size_type pos = s.find_last_of("/");
  
	if(pos!=string::npos)
    return s.substr(0,++pos);
  else
    return s;
}

string ExtractFileName(string s)
{
  string::size_type pos = s.find_last_of("/");

	if(pos!=string::npos)
    return s.substr(pos+1);
  else
    return s;
}

string AdjustChars(string str)
{
  for(unsigned int i=0; i<str.size(); i++)
    str[i]&=255;
  return str;
}

string dummy(string s)
{
  return s;
}

string lowercase(string s)
{
  for(unsigned int i=0;i<s.size();i++)
    s[i]=tolower(s[i]);

  return s;
}

int Ord(unsigned char c)
{
  return c&255;
}

CMode::CMode()
{
  version=0;
  for(int i=0;i<256;i++)
  {
    r2t.src[i] = new mylist<string>;
    t2r.src[i] = new mylist<string>;
    r2t.prev[i] = new mylist<string>;
    t2r.prev[i] = new mylist<string>;
    r2t.next[i] = new mylist<string>;
    t2r.next[i] = new mylist<string>;
    r2t.dest[i] = new mylist<string>;
    t2r.dest[i] = new mylist<string>;
    r2t.id[i] = new mylist<string>;
    t2r.id[i] = new mylist<string>;
  }
#ifdef SPY
  printf("CMode\n");
#endif
}

CMode::~CMode()
{
  for(int i=0;i<256;i++)
  {
    delete r2t.src[i];
    delete t2r.src[i];
    delete r2t.prev[i];
    delete t2r.prev[i];
    delete r2t.next[i];
    delete t2r.next[i];
    delete r2t.dest[i];
    delete t2r.dest[i];
    delete r2t.id[i];
    delete t2r.id[i];
  }
#ifdef SPY
  printf("~CMode\n");
#endif
}

CTranscription::CTranscription()
{
  equivs.add("#EDC");                           //a above
  equivs.add("$RFV");                           //e
  equivs.add("%TGB");                           //i
  equivs.add("^YHN");                           //o
  equivs.add("&UJM");                           //u
  equivs.add("8I_+|}\xa1\xa2\xa3\xa5\xc5\xc6"); //s (tengwa+curl)
  equivs.add("0p)P");                           //~ above
  equivs.add(";/:?");                           //~ below
  equivs.add("\xaa\xad\xaf\xb5");               //reverse triple over dot
  equivs.add("\xd4\xd5\xd6\xd7");               //double over dot
  equivs.add("\xd8\xd9\xda\xdb");               //chevron
  equivs.add("\xdc\xdd\xde\xdf");               //circumflex
  equivs.add("\xe0\xe1\xe2\xe3");               //reverse over curl
  equivs.add("\xe8\xe9\xea\xeb");               //over twist
  equivs.add("[{\xec\xee");                     //bar above
  equivs.add("\'\"\xed\xef");                   //bar below
  equivs.add(">\xd0\xd1\xd2\xd3");              //a below
  equivs.add("\xe4\xe5\xe6\xe7");               //under curl
  equivs.add("\xfc\xfd\xfe\xff");               //under accent
  equivs.add("\x83\x84\x85\x86");               //double under accent
  equivs.add("\x91\x92\x93\x94");               //under tail
  TreatNumbersSeparately=true;
  UseSmart=true;
  decimal=true;
  lsd=false;
  alert=false;
  stop=false;
  //set default locale
  setlocale(LC_ALL, "");
#ifdef SPY
  printf("CTranscription\n");
#endif
}

CTranscription::~CTranscription()
{
#ifdef SPY
  printf("~CTranscription\n");
#endif
}

int CTranscription::RomanHash(unsigned char c)
{
  return Ord(c);
}

int CTranscription::TengHash(unsigned char c)
{
   int n;

   for(unsigned int i=0;i<equivs.count();i++)
   {
     n=equivs[i].find(c);
     if(n>=0)
       return Ord(equivs[i][0]);
   }
   return Ord(c);
}

bool CTranscription::IsWhiteChar(unsigned char c)
{
  c&=255;
  switch(c)
  {
    case 9:
    case 10:
    case 13:
    case 32:
    case 255:
    case 0:
      return true;
    default:
      return false;
  }
}

bool CTranscription::IsTengAlphaNum(unsigned char c)
{
  c&=255;
  switch(c)
  {
    case 136:
    case 140:
    case 155:
    case 156:
    case 171:
    case 172:
    case 174:
    case 177:
    case 178:
    case 185:
    case 186:
    case 187:
    case 192:
    case 193:
    case 194:
    case 195:
    case 199:    
      return false;
    default:
      return true;
  }
}

bool CTranscription::IsTehta(unsigned char c)
{
  c&=255;
  switch(c)
  {
    case '#':
    case 'E':
    case 'D':
    case 'C':
    case '$':
    case 'R':
    case 'F':
    case 'V':
    case '%':
    case 'T':
    case 'G':
    case 'B':
    case '^':
    case 'Y':
    case 'H':
    case 'N':
    case '&':
    case 'U':
    case 'J':
    case 'M':
    case '(':
    case 'O':
    case 'L':
    case '>':
    case '0':
    case 'p':
    case ';':
    case '/':
    case '_':
    case '{':
    case '\"':
    case '+':
    case '}':
    case '|':
    case '[':
    case '\'':
    case 170:
    case 173:
    case 175:
    case 181:
    case 237:
    case 239:
    case 176:
    case 184:
    case 130:
    case 180:
    case 161:
    case 162:
    case 197:
    case 198:
    case 163:
    case 165:
      return true;
    default:
      if(((c>=212)&&(c<=227))||
         ((c>=232)&&(c<=236))||
         (c==238)||
         ((c>=200)&&(c<=211))||
         ((c>=228)&&(c<=231))||
         (c>=252)||
         ((c>=137)&&(c<=139))||
         (c==159)||
         ((c>=131)&&(c<=134))||
         ((c>=145)&&(c<=148)))
        return true;
      else
        return false;

  }
}

string CTranscription::dec2duodec(string val)
{
  int i;
  string numres="";

  cislo=atol(val);
  do
  {
    i=cislo%12; //0-9
    if(i<10)
      i+=0x30;
    else       //a-b
      i+=0x57;
    numres=(char)i+numres;
    cislo/=12;
  }while(cislo!=0);

  return numres;
}

string CTranscription::duodec2dec(string val)
{
  int i, n, digit;
  string res;

  n=0;
  for(i=val.size()-1;i>=0;i--)
  {
    if((val[i]>='0')&&(val[i]<='9'))
      digit=val[i]-'0';
    else
      digit=val[i]-'a'+10;
    n+=digit*(int)pow((float)12, (int)(val.size()-i-1));
  }
  res=ltoa(n);

  return res;
}

bool CTranscription::SmartCompare(string left, string right)
{
  unsigned int i,j,len1,n, m;
  bool b;

  if(!UseSmart)
    return left==right;
  else
  {
    len1=left.size();
    if(len1!=right.size())
      return false;
    for(i=0;i<len1;i++)
    {
      if(left[i]==right[i])
        continue;
      b=false;
      for(j=0;j<equivs.count();j++)
      {
        n=equivs[j].find(left[i]);
        m=equivs[j].find(right[i]);
        if((n>=0)&&(m>=0))
        {
          b=true;
          break;
        }
      }
      if(!b)
        return false;
    }//for i
    return true;
  }//else
}

char CTranscription::GetTengwarDigit(char c)
{
  c&=255;
  return c-'0'+240;
}

char CTranscription::GetRomanDigit(char c)
{
  c&=255;
  return c-240+'0';
}

bool CTranscription::GetNextEntry(char *&b, SOneWayMode mode, int (CTranscription::*HashF)(unsigned char X))
{
  unsigned int hash;
	std::string::size_type j;
  string str;

#ifdef SPY
  printf("CTranscription::GetNextEntry\n");
#endif
  for(; b[0]==' '; b++);
  hash=(this->*HashF)(b[0]);
#ifdef SPY
  printf("Hash: %u\n", hash);
#endif
  j=string(b).find('\t');
  if(j==0)//src consisted just of spaces
    hash=32;
	else if(j==string::npos)
    return false;
  str=AdjustChars(trim(string(b).substr(0,j)));
#ifdef SPY
  printf("Src: %s\n", str.c_str());
#endif
  mode.src[hash]->add(matchcase(str));
  b=strchr(b, '\t')+1;
  if(!b)
    throw EUnknownFormat("Unknown file format");
  j=string(b).find('\t');
  str=AdjustChars(trim(string(b).substr(0,j)));
#ifdef SPY
  printf("\tDest: %s\n", str.c_str());
#endif
  mode.dest[hash]->add(str);
  b=strchr(b, '\t')+1;
  if(!b)
    throw EUnknownFormat("Unknown file format");
  j=string(b).find('\t');
  str=AdjustChars(trim(string(b).substr(0,j)));
#ifdef SPY
  printf("\tNext: %s\n", str.c_str());
#endif
  mode.next[hash]->add(matchcase(str));
  b=strchr(b, '\t')+1;
  if(!b)
    throw EUnknownFormat("Unknown file format");
  j=string(b).find('\t');
  str=AdjustChars(trim(string(b).substr(0,j)));
#ifdef SPY
  printf("\tPrev: %s\n", str.c_str());
#endif
  mode.prev[hash]->add(str);
  b=strchr(b, '\t')+1;
  if(!b)
    throw EUnknownFormat("Unknown file format");
  j=string(b).find('\t');
  str=AdjustChars(trim(string(b).substr(0,j)));
#ifdef SPY
  printf("\tID: %s\n", str.c_str());
#endif
  mode.id[hash]->add(str);
  b=strchr(b, '\t')+1;
  if(!b)
    throw EUnknownFormat("Unknown file format");

  return true;
}

void CTranscription::AutoReverse()
{
	unsigned int i,j,l;
	std::string::size_type k;
	int hash;
	char c;
	string s;
	bool found;
	
#ifdef SPY
	printf("CTranscription::AutoReverse\n");
#endif
	for(i=0;i<256;i++)
		for(j=0;j<mode.r2t.src[i]->count();j++)
			//everything that does NOT have next and prev filled out
			if(((*mode.r2t.prev[i])[j].size()==0)&&
			   ((*mode.r2t.next[i])[j].size()==0)&&
			   ((*mode.r2t.dest[i])[j].size()!=0))
			{
				c=(*mode.r2t.dest[i])[j][0];
				hash=TengHash(c);
				mode.t2r.src[hash]->add((*mode.r2t.dest[i])[j]);
				mode.t2r.dest[hash]->add((*mode.r2t.src[i])[j]);
				mode.t2r.prev[hash]->add("");
				mode.t2r.next[hash]->add("");
				//find last tengwa in dest and find corresponding letter in src
				//and place it into id
				c=0;
				for(k=(*mode.r2t.dest[i])[j].size()-1;k>=0;k--)
					if(!IsTehta((*mode.r2t.dest[i])[j][k]))
					{
						c=(*mode.r2t.dest[i])[j][k];
						break;
					}
						found=false;
				for(k=0;k<256;k++)
				{
					for(l=0;l<mode.r2t.src[k]->count();l++)
						if(((*mode.r2t.dest[k])[l]==string(1,c))&&
						   ((*mode.r2t.prev[k])[l].size()==0)&&
						   ((*mode.r2t.next[k])[l].size()==0))
						{
							mode.t2r.id[hash]->add((*mode.r2t.src[k])[l]);
							found=true;
							break;
						}
							if(found)
								break;
				}
				if(!found)
					mode.t2r.id[hash]->add((*mode.r2t.src[i])[j]);
			}
				for(i=0;i<256;i++)
					for(j=0;j<mode.r2t.src[i]->count();j++)
						//everything that does have prev and doe NOT have next filled out
						if(((*mode.r2t.prev[i])[j].size()!=0)&&
						   ((*mode.r2t.next[i])[j].size()==0)&&
						   ((*mode.r2t.dest[i])[j].size()!=0))
						{
							c=(*mode.r2t.prev[i])[j][0];
							hash=TengHash(c);
							//choose from what starts with my letter
							//I want just the letter itself, not the longer words
							for(k=0;k<mode.t2r.src[hash]->count();k++)
								if((*mode.t2r.src[hash])[k]==string(1,c))
								{
									s=(*mode.t2r.dest[hash])[k];
									break;
								}
									c=(*mode.r2t.dest[i])[j][0];
							hash=TengHash(c);
							mode.t2r.src[hash]->add((*mode.r2t.dest[i])[j]);
							mode.t2r.dest[hash]->add((*mode.r2t.src[i])[j]);
							mode.t2r.prev[hash]->add(s);
							mode.t2r.next[hash]->add("");
							//find last tengwa in dest and find corresponding letter in src
							//and place it into id
							c=0;
							for(k=(*mode.r2t.dest[i])[j].size()-1;k>=0;k--)
								if(!IsTehta((*mode.r2t.dest[i])[j][k]))
								{
									c=(*mode.r2t.dest[i])[j][k];
									break;
								}
									found=false;
							for(k=0;k<256;k++)
							{
								for(l=0;l<mode.r2t.src[k]->count();l++)
									if(((*mode.r2t.dest[k])[l]==string(1,c))&&
									   ((*mode.r2t.prev[k])[l].size()==0)&&
									   ((*mode.r2t.next[k])[l].size()==0))
									{
										mode.t2r.id[hash]->add((*mode.r2t.src[k])[l]);
										found=true;
										break;
									}
										if(found)
											break;
							}
							if(!found)
								mode.t2r.id[hash]->add((*mode.r2t.src[i])[j]);
						}
							//erase the duplicate fields that might have emerged
							for(i=0;i<256;i++)
								for(j=0;j<mode.t2r.src[i]->count();j++)
									for(k=mode.t2r.src[i]->count()-1; k>j; k--)
										if(((*mode.t2r.src[i])[k]==(*mode.t2r.src[i])[j])&&
										   ((*mode.t2r.prev[i])[k]==(*mode.t2r.prev[i])[j]))
										{
											mode.t2r.src[i]->remove(k);
											mode.t2r.dest[i]->remove(k);
											mode.t2r.next[i]->remove(k);
											mode.t2r.prev[i]->remove(k);
											mode.t2r.id[i]->remove(k);
										}
}

void CTranscription::Optimize(SOneWayMode m)
{
  unsigned int i,j,k;

#ifdef SPY
  printf("CTranscription::Optimize\n");
#endif
  //sort: longest to shortest
  for(i=0;i<256;i++)
    for(j=0;j<m.src[i]->count();j++)
      for(k=j-1;k>=0;k--)
        if((*m.src[i])[k].size()<(*m.src[i])[k+1].size())
        {
          m.src[i]->exchange(k, k+1);
          m.prev[i]->exchange(k, k+1);
          m.next[i]->exchange(k, k+1);
          m.dest[i]->exchange(k, k+1);
          m.id[i]->exchange(k, k+1);
        }
        else
          break;
}

const char *CTranscription::Roman2Tengwar(const char *str)
{
	string temp, cislo;
	static string res;
	unsigned int i, j, l;
	int hash;
	const char *p, *p2, *pend, *pp;
	char prev, next;
	bool letterfound;
#ifdef DEBUG
	int tstart, tstop;
#endif
	int len;
	string testentry, str2;
	unsigned int entrylen;
	
#ifdef SPY
	fprintf(stderr,"CTranscription::Roman2Tengwar\n");
#endif
	p2=str;
	len=strlen(str);
#ifdef DEBUG
	tstart=time(NULL);
#endif
	res="";
	prev=NON_ALPHA_NUM;
	if(!mode.casesens)
	{
		str2=lowercase(str);
		p=str2.c_str();
	}
	else
		p=p2;
	pend=p+len;
	while(p<pend)
	{
		temp="";
		//bile znaky zkopirujeme beze zmeny
		while(Ord(p[0])<=32)
		{
			res+=p[0];
			prev=NON_ALPHA_NUM;
			p++;
			p2++;
			if(p>=pend)
				break;
		}
		if(p>=pend)
			break;
		//predelani cisel
		if(TreatNumbersSeparately)
		{
			pp=p;
			cislo="";
			while((Ord(pp[0])>=Ord('0'))&&(Ord(pp[0])<=Ord('9')))
			{
				cislo+=pp[0];
				pp++;
			}
			l=pp-p;
			p+=l;
			p2+=l;
			if(cislo!="")
			{
				if(!decimal)
					cislo=dec2duodec(cislo);
				for(j=cislo.size()-1;j>=0;j--)
				{
					temp+=GetTengwarDigit(cislo[j]);
					if((lsd)&&(j==cislo.size()-1))//least sign. digit
					{
						if((cislo[j]=='0')||(cislo[j]=='4')||(cislo[j]=='7')||(cislo[j]=='8')||(cislo[j]=='a')||(cislo[j]=='b'))
							temp+='\x99';//153
						else
							temp+='\x98';//152
					}
					else if(digits)
					{
						if(decimal)
						{
							if((cislo[j]=='0')||(cislo[j]=='1')||(cislo[j]=='7')||(cislo[j]=='9'))
								temp+='T';
							else if((cislo[j]=='4')||(cislo[j]=='8'))
								temp+='G';
							else//2,3,5,6
								temp+='%';
						}
						else//duodecimal
						{
							if((cislo[j]=='3')||(cislo[j]=='5')||(cislo[j]=='6')||(cislo[j]=='9'))
								temp+='\xc8';//200
							else//0,1,2,4,7,8,10,11
								temp+='\xc9';//201
						}
					}//if digits
				}
				res+=temp;
#ifdef KYLIX
				Application.ProcessMessages();
#endif
				if(stop)
					throw EAbort("");
				continue;
			}//if cislo
		}//if tns
		letterfound=false;
		hash=Ord(p[0]);
		for(i=0;i<mode.r2t.src[hash]->count();i++)
		{
			entrylen=(*mode.r2t.src[hash])[i].size();
			testentry="";
			for(j=0;j<entrylen;j++)
				testentry+=p[j];
			if((*mode.r2t.src[hash])[i]==testentry)
			{
				l=(*mode.r2t.src[hash])[i].size();
				if((*mode.r2t.next[hash])[i]!="")
				{
					next=(*mode.r2t.next[hash])[i][0];
					if((*mode.r2t.next[hash])[i][0]==NON_ALPHA_NUM)
					{
						if((p+l<pend)&&(isalnum((p+l)[0])))
							continue;
					}
					else if((p+l>=pend)||((p+l)[0]!=next))
						continue;
				}
				if((*mode.r2t.prev[hash])[i]!="")
				{
					if(((*mode.r2t.prev[hash])[i][0]==NON_ALPHA_NUM)&&(isalnum(prev)))
						continue;
					else if((*mode.r2t.prev[hash])[i][0]!=prev)
						continue;
				}
				temp=(*mode.r2t.dest[hash])[i];
				letterfound=true;
				if((*mode.r2t.id[hash])[i].size()>0)
					prev=(*mode.r2t.id[hash])[i][0];
				else
					prev=NON_ALPHA_NUM;
				p+=l;
				p2+=l;
				break;
			}
		}
		if(!letterfound)
			if(alert)
			{
				for(i=0;!IsWhiteChar(p[i]);i++);
				throw EPatternNotFound(string(p2).substr(0,i).c_str());
			}
				else
				{
					temp='\xae';//'?'
					p++;
					p2++;
				}
				res+=temp;
#ifdef KYLIX
		Application.ProcessMessages();
#endif
		if(stop)
			throw EAbort("");
	}
	
#ifdef DEBUG
	tstop=time(NULL);
	fprintf(stderr,"%d bytes: %d ms\n",len,tstop-tstart);
#endif
	
	return res.c_str();
}

const char *CTranscription::Tengwar2Roman(const char *str)
{
  string temp, cislo;
  static string res;
  unsigned int i, j, l;
  int hash;
  const char *p, *p2, *pend, *pp;
  char next;
  string prev;
  bool letterfound;
#ifdef DEBUG
  int tstart, tstop;
#endif
  int len;
  string testentry;
  unsigned int entrylen;

#ifdef SPY
  printf("CTranscription::Tengwar2Roman\n");
#endif
  len=strlen(str);
#ifdef DEBUG
  tstart=time(NULL);
#endif
  p=str;
/*R2T only
  p2:=AllocMem(Length(p));
  origp2:=p2;
  if(p2<>nil)then
    StrCopy(p2,p);
*/
  res="";
  prev=NON_ALPHA_NUM;
/*R2T
  if not Mode.casesens then
    p:=PChar(AnsiLowerCase(p));
*/
  pend=p+len;
  while(p<pend)
  {
    temp="";
    //bile znaky zkopirujeme beze zmeny
    while(Ord(p[0])<=32)
    {
      res+=p[0];
      prev=NON_ALPHA_NUM;
      p++;
      p2++;
    }
    if(p>=pend)
      break;
    //predelani cisel
    if(TreatNumbersSeparately)
    {
      pp=p;
      cislo="";
      while((((pp[0]=='%')||(pp[0]=='T')||(pp[0]=='G')||(pp[0]=='B')||
              ((Ord(pp[0])>=152)&&(Ord(pp[0])<=153))||
              ((Ord(pp[0])>=168)&&(Ord(pp[0])<=169))||
              ((Ord(pp[0])>=200)&&(Ord(pp[0])<=203))
//            )&&(Ord(prev)>=240)&&(Ord(prev)<=251))||
             )&&(Ord(prev[prev.size()])>=240)&&(Ord(prev[prev.size()])<=251))||
            ((Ord(pp[0])>=240)&&(Ord(pp[0])<=251)))
      {
        cislo+=pp[0];
        prev=pp[0];
        pp++;
      }
      l=pp-p;
      p+=l;
      p2+=l;
      if(cislo!="")
      {
        for(j=cislo.size();j>=1;j--)
          temp+=GetRomanDigit(cislo[j]);
        if(!decimal)
          temp=duodec2dec(temp);
        res+=temp;
#ifdef KYLIX
        Application.ProcessMessages();
#endif
        if(stop)
          throw EAbort("");
        continue;
      }
    }
    letterfound=false;
    hash=TengHash(p[0]);//Ord(p[0]);
    for(i=0;i<mode.t2r.src[hash]->count();i++)
    {
      entrylen=(*mode.t2r.src[hash])[i].size();
      testentry="";
      for(j=0;j<entrylen;j++)
        testentry+=p[j];
      if(SmartCompare((*mode.t2r.src[hash])[i],testentry))
      {
        l=(*mode.t2r.src[hash])[i].size();
        if((*mode.t2r.next[hash])[i]!="")
        {
          next=(*mode.t2r.next[hash])[i][0];
          if((*mode.t2r.next[hash])[i][0]==NON_ALPHA_NUM)
          {
            if((p+l<pend)&&(IsTengAlphaNum((p+l)[0])))
              continue;
          }
          else if((p+l>=pend)||((p+l)[0]!=next))
            continue;
        }
        if((*mode.t2r.prev[hash])[i]!="")
        {
          if(((*mode.t2r.prev[hash])[i][0]==NON_ALPHA_NUM)&&(IsTengAlphaNum(prev[prev.size()])))
            continue;
          else if((*mode.t2r.prev[hash])[i]!=prev)
            continue;
        }
        temp=(*mode.t2r.dest[hash])[i];
        letterfound=true;
        if((*mode.t2r.id[hash])[i].size()>0)
//          prev:=Mode.t2r.ID[hash][i][1]//Mode.tengwar[i][Length(Mode.tengwar[i])]
          prev=(*mode.t2r.id[hash])[i];
        else
          prev=NON_ALPHA_NUM;
        p+=l;
        p2+=l;
        break;
      }
    }
    if(!letterfound)
      if(alert)
      {
        for(i=0;!IsWhiteChar(p[i]);i++);
        throw EPatternNotFound(string(p).substr(0,i).c_str());
      }
      else
      {
        temp="?";
        p++;
        p2++;
      }
    res+=temp;
#ifdef KYLIX
    Application.ProcessMessages();
#endif    
    if(stop)
      throw EAbort("");
  }//while
//  showmessage(res);
/*R2T
  FreeMem(origp2);
*/
#ifdef DEBUG
  tstop=time(NULL);
  fprintf(stderr,"%d bytes: %d ms\n",len,tstop-tstart);
#endif

  return res.c_str();
}

void CTranscription::LoadMode(const char *filename)
{
  int i, l, entries, r2tentries, t2rentries, head;
  FILE *f;
  char *b, *origb=0;
  bool version1;

#ifdef SPY
  printf("CTranscription::LoadMode\n");
#endif
  try
  {
    f=fopen(filename, "r");
	if(!f)
	  throw EFileNotFound("Cannot load "+string(filename));
    fseek(f, 0, SEEK_END);
    l=ftell(f);
    fseek(f, 0, SEEK_SET);
    b=(char *)malloc(l+1);
    origb=b;
    fread(b, l, 1, f);
    b[l]=0;
    fclose(f);

    for(i=0;i<256;i++)
    {
      mode.r2t.src[i]->clear();
      mode.r2t.dest[i]->clear();
      mode.r2t.prev[i]->clear();
      mode.r2t.next[i]->clear();
      mode.r2t.id[i]->clear();
      mode.t2r.src[i]->clear();
      mode.t2r.dest[i]->clear();
      mode.t2r.prev[i]->clear();
      mode.t2r.next[i]->clear();
      mode.t2r.id[i]->clear();
    }

    mode.path=ExtractFilePath(filename);
    mode.text=ExtractFileName(filename);
#ifdef SPY
    printf("%s\n", filename);
    printf("%d bytes\n", l);
//    printf("%s\n", b);
#endif
    if(string(b).substr(0,VERSION2TAG.size())==VERSION2TAG)
      version1=false;
    else
      version1=true;
    mode.version = version1 ? 1 : 2;
    if(!version1)
    {
      try
      {
        head=VERSION2TAG.size();
        b+=head;
        i=string(b).find('\t')+1;
        head+=i;
        b+=i;
        i=string(b).find('\t')+1;
        head+=i;
        r2tentries=atol(string(b).substr(0,i-1).c_str());
#ifdef SPY
        printf("%d r2t\n", r2tentries);
#endif
        if(!r2tentries)
          throw EConvertError("");
        b+=i;
        i=string(b).find('\t')+1;
        head+=i;
        t2rentries=atol(string(b).substr(0,i-1).c_str());
#ifdef SPY
        printf("%d t2r\n", t2rentries);
#endif
        b+=i;
      }catch(const EConvertError &) { throw EUnknownFormat("Unknown file format"); }
    }
    i=string(b).find('\t')+1;
    mode.comment=string(b).substr(0,i-1);
    if((b[i]!='0')&&(b[i]!='1'))
      throw EUnknownFormat("Unknown file format");
    mode.casesens=b[i]=='1';
    if(!mode.casesens)
      matchcase=&lowercase;
    else
      matchcase=&dummy;
    if(version1)
      i=72;
    else
      i=72-head;
    b+=i;
    entries=0;
#ifdef SPY
    printf("R2T Entries:\n");
#endif
    do
    {
#ifdef SPY
      printf("%d. ", entries+1);
#endif
      if(!GetNextEntry(b, mode.r2t, &CTranscription::RomanHash))
        break;
      entries++;
    }while((b-origb<l)&&((version1)||(entries!=r2tentries)));
    matchcase=&dummy;//unwanted for reverse transcription
    if(!version1)
    {
      if(entries!=r2tentries)
        throw EUnknownFormat("Unknown file format");
      entries=0;
#ifdef SPY
      printf("T2R Entries:\n");
#endif
      do
      {
#ifdef SPY
        printf("%d. ", entries+1);
#endif
        if(!GetNextEntry(b, mode.t2r, &CTranscription::TengHash))
          break;
        entries++;
      }while((b-origb<l)&&(entries!=t2rentries));
      if(entries!=t2rentries)
        throw EUnknownFormat("Unknown file format");
    }
    else//version1
      AutoReverse();
    Optimize(mode.r2t);
    Optimize(mode.t2r);
  }catch(exception &e)
  {
    if(origb)
      free(origb);
    throw e;
  }
  if(origb)
    free(origb);
}

