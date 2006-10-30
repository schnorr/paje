#include "CStringCallBacks.h"
#include <Foundation/NSString.h>

static unsigned cstring_hash(NSMapTable *t, const void *p)
{
    const char *s = p;
    unsigned h = 0;
    int c;
    while ((c = *s++) != 0) {
        h = (h << 27) ^ c ^ (h >> 5);
    }
    return h;
}

static BOOL cstring_isEqual(NSMapTable *t, const void *p1, const void *p2)
{
    const char *s1 = p1;
    const char *s2 = p2;
    return strcmp(s1, s2) == 0;
}

static void cstring_retain(NSMapTable *t, const void *p)
{
}

static void cstring_release(NSMapTable *t, void *p)
{
    free(p);
}

static NSString *cstring_describe(NSMapTable *t, const void *p)
{
    const char *s = p;
    return [NSString stringWithCString:s];
}

NSMapTableKeyCallBacks CStringMapKeyCallBacks = {
    cstring_hash,
    cstring_isEqual,
    cstring_retain,
    cstring_release,
    cstring_describe
};

NSHashTableCallBacks CStringHashCallBacks = {
    cstring_hash,
    cstring_isEqual,
    cstring_retain,
    cstring_release,
    cstring_describe
};
