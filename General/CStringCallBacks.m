#include "CStringCallBacks.h"
#include <Foundation/NSString.h>
#include <string.h> // for strcmp
#include <stdlib.h> // for free

static NSUInteger cstring_hash(NSMapTable *t, const void *p)
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

static NSUInteger cstring_hash2 (NSHashTable *t, const void *p)
{
    return cstring_hash ((NSMapTable*)t, p);
}

static BOOL cstring_isEqual2(NSHashTable *t, const void *p1, const void *p2)
{
    return cstring_isEqual((NSMapTable*)t, p1, p2);
}

static void cstring_retain2(NSHashTable *t, const void *p)
{
    cstring_retain((NSMapTable*)t, p);
}

static void cstring_release2(NSHashTable *t, void *p)
{
    cstring_release((NSMapTable*)t, p);
}

static NSString *cstring_describe2(NSHashTable *t, const void *p)
{
    return cstring_describe((NSMapTable*)t, p);
}

NSMapTableKeyCallBacks CStringMapKeyCallBacks = {
    cstring_hash,
    cstring_isEqual,
    cstring_retain,
    cstring_release,
    cstring_describe
};

NSHashTableCallBacks CStringHashCallBacks = {
    cstring_hash2,
    cstring_isEqual2,
    cstring_retain2,
    cstring_release2,
    cstring_describe2
};
