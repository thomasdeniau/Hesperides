#ifndef exceptionH
#define exceptionH

#include <string>
#include <exception>

using std::string;
using std::exception;

class EPatternNotFound: public exception
{
  private:
    string str;
  public:
    EPatternNotFound(const string &what):str(what){}
    const char *what()
    {
      return str.c_str();
    }
    virtual ~EPatternNotFound() throw() {}
};

class EUnknownFormat: public exception
{
  private:
    string str;
  public:
    EUnknownFormat(const string &what):str(what){}
    const char *what()
    {
      return str.c_str();
    }
    virtual ~EUnknownFormat() throw() {}
};

class EConvertError: public exception
{
  private:
    string str;
  public:
    EConvertError(const string &what):str(what){}
    const char *what()
    {
      return str.c_str();
    }
    virtual ~EConvertError() throw() {}
};

class EAbort: public exception
{
  private:
    string str;
  public:
    EAbort(const string &what):str(what){}
    const char *what()
    {
      return str.c_str();
    }
    virtual ~EAbort() throw() {}
};

class EFileNotFound: public exception
{
  private:
    string str;
  public:
    EFileNotFound(const string &what):str(what){}
    const char *what()
    {
      return str.c_str();
    }
    virtual ~EFileNotFound() throw() {}
};

#endif
