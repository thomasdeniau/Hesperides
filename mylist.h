#ifndef mylistH
#define mylistH

template<class T>
class mynode
{
  public:
    T item;
    mynode *next;
    mynode():next(NULL){}
    mynode(T obj)
    {
      next=NULL;
      item=obj;
    }
};

template<class T>
class mylist
{
  private:
    unsigned int capacity;
    mynode<T> *head, *tail;
  public:
    mylist();
    ~mylist();
    T operator[](int n);
    unsigned int count();
    void add(T s);
    void remove(int n);
    void clear();
    int find(T s);
    void exchange(int n1, int n2);
};

template<class T>
mylist<T>::mylist()
{
  capacity=0;
  head=tail=NULL;
#ifdef SPY
  printf("mylist\n");
#endif
}

template<class T>
mylist<T>::~mylist()
{
  clear();
#ifdef SPY
  printf("~mylist\n");
#endif
}

template<class T>
T mylist<T>::operator[](int n)
{
  mynode<T> *location;
  int i;

  for(i=0, location=head; (i<n)&&(location!=NULL); i++, location=location->next);

  return location->item;
}

template<class T>
unsigned int mylist<T>::count()
{
  return capacity;
}

template<class T>
void mylist<T>::add(T s)
{
  mynode<T> *node = new mynode<T>(s);
  if(tail)
    tail->next=node;
  else
  {
    head=node;
  }
  tail=node;
  capacity++;
}

template<class T>
void mylist<T>::remove(int n)
{
  mynode<T> *location, *prev;
  int i;

  prev=NULL;
  for(i=0, location=head; (i<n)&&(location!=NULL); i++, location=location->next)
    prev=location;
  if(location)
  {
    if(prev)
    {
      prev->next=location->next;
      if(tail==location)
        tail=prev;
      delete location;
    }
    else
    {
      head=location->next;
      if(tail==location)
        tail=head;
      delete location;
    }
    capacity--;
  }
}

template<class T>
void mylist<T>::clear()
{
  mynode<T> *node, *old;
  node=head;
  if(node)
  {
    for(unsigned int i=0;i<capacity;i++)
    {
      old=node;
      node=node->next;
      delete old;
      if(node==NULL)
        break;
    }
    tail=NULL;
    head=NULL;
    capacity=0;
  }
}

template<class T>
int mylist<T>::find(T s)
{
  mynode<T> *location;
  int i, found=-1;

  for(i=0, location=head; location!=NULL; i++, location=location->next)
    if(location->item==s)
    {
      found=i;
      break;
    }

  return found;
}

template<class T>
void mylist<T>::exchange(int n1, int n2)
{
  T tmp;

  tmp=(*this)[n1];
  (*this)[n1]=(*this)[n2];
  (*this)[n2]=tmp;
}

#ifdef SPY
template<class T>
class pok
{
  private:
  mylist<T> x;
  public:
  pok(){printf("pok\n");}
  ~pok(){printf("~pok\n");}
};
#endif

#endif
