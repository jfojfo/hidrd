dnl
dnl lib/usage/all.c template.
dnl
dnl Copyright (C) 2010 Nikolai Kondrashov
dnl
dnl This file is part of hidrd.
dnl
dnl Hidrd is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; either version 2 of the License, or
dnl (at your option) any later version.
dnl
dnl Hidrd is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
dnl GNU General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with hidrd; if not, write to the Free Software
dnl Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
dnl
dnl
include(`m4/hidrd/util.m4')dnl
dnl
`/** @file
 * @brief HID report descriptor - all usages
 *
 * vim:nomodifiable
 *
 * ************* DO NOT EDIT ***************
 * This file is autogenerated from page.c.m4
 * *****************************************
 *
 * Copyright (C) 2010 Nikolai Kondrashov
 *
 * This file is part of hidrd.
 *
 * Hidrd is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Hidrd is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with hidrd; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 * @author Nikolai Kondrashov <spbnick@gmail.com>
 *
 * @(#) $Id: page.c 103 2010-01-18 21:04:26Z spb_nick $
 */

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "hidrd/usage/all.h"

typedef struct usage_desc {
    hidrd_usage             usage;
    hidrd_usage_type_set    type_set;
#ifdef HIDRD_WITH_TOKENS
    const char             *token;
#endif
#ifdef HIDRD_WITH_NAMES
    const char             *name;
#endif
} usage_desc;

#ifdef HIDRD_WITH_TOKENS
#define _U_TOKEN(_token)    .token = _token,
#else
#define _U_TOKEN(_token)
#endif

#ifdef HIDRD_WITH_NAMES
#define _U_NAME(_name)      .name = _name,
#else
#define _U_NAME(_name)
#endif

static const usage_desc desc_list[] = {

#define _U(_TOKEN, _token, _name, _type_set) \
    {.usage = HIDRD_USAGE_##_TOKEN,             \
     .type_set  = _type_set,                    \
     _U_TOKEN(#_token) _U_NAME(_name)}

    _U(UNDEFINED, undefined, "undefined", HIDRD_USAGE_TYPE_SET_EMPTY),

'dnl
pushdef(`TYPE_SET_ITER',
`ifelse(len(`$1'), 0, `',
`HIDRD_USAGE_TYPE_`'uppercase($1)`'dnl
ifelse(len(`$2'), 0, `', ` | TYPE_SET_ITER(shift($@))')')')dnl
pushdef(`TYPE_SET',
`ifelse(len(`$1'), 0, `HIDRD_USAGE_TYPE_SET_EMPTY', `TYPE_SET_ITER($@)')')dnl
dnl
pushdef(`PAGE',
`ifelse(eval(PAGE_ID_NUM(`$2') > 0), 1,
`    /*
     * capitalize_first($3)
     */
#define _PU(_TOKEN, _token, _name, _type_set) \
    _U(uppercase($2)_##_TOKEN, $2_##_token, _name, _type_set)

pushdef(`ID',
`    _PU(uppercase($'`2), $'`2, "$'`4",
        TYPE_SET($'`3)),
')dnl
sinclude(`db/usage/id_$2.m4')dnl
popdef(`ID')dnl
#undef _PU
')')dnl
include(`db/usage/page.m4')dnl
popdef(`PAGE')dnl
popdef(`TYPE_SET')dnl
popdef(`TYPE_SET_ITER')dnl
`
#undef _U

};

#undef _U_NAME
#undef _U_TOKEN

static const size_t desc_num = sizeof(desc_list) / sizeof(*desc_list);


static const usage_desc *
lookup_desc_by_num(hidrd_usage usage)
{
    size_t  i;

    assert(hidrd_usage_valid(usage));

    for (i = 0; i < desc_num; i++)
        if (desc_list[i].usage == usage)
            return &desc_list[i];

    return NULL;
}


char *
hidrd_usage_to_hex(hidrd_usage usage)
{
    char   *hex;

    assert(hidrd_usage_valid(usage));

    if (asprintf(&hex,
                 ((usage <= UINT8_MAX)
                      ? "%.2X"
                      : ((usage <= UINT16_MAX)
                          ? "%.4X"
                          : "%.8X")),
                 (uint32_t)usage) < 0)
        return NULL;

    return hex;
}


bool
hidrd_usage_from_hex(hidrd_usage *pusage, const char *hex)
{
    uint32_t    usage;

    assert(hex != NULL);

    if (sscanf(hex, "%X", &usage) != 1)
        return false;

    if (pusage != NULL)
        *pusage = usage;

    return true;
}


#ifdef HIDRD_WITH_TOKENS

const char *
hidrd_usage_to_token(hidrd_usage usage)
{
    const usage_desc    *desc;

    assert(hidrd_usage_valid(usage));
    desc = lookup_desc_by_num(usage);

    return (desc != NULL) ? desc->token : NULL;
}


char *
hidrd_usage_to_token_or_hex(hidrd_usage usage)
{
    const char         *token;

    assert(hidrd_usage_valid(usage));

    token = hidrd_usage_to_token(usage);

    return (token != NULL) ? strdup(token) : hidrd_usage_to_hex(usage);
}


bool
hidrd_usage_from_token(hidrd_usage *pusage, const char *token)
{
    const usage_desc    *desc;

    assert(token != NULL);

    for (desc = desc_list; desc->usage != HIDRD_USAGE_PAGE_INVALID; desc++)
        if (strcasecmp(desc->token, token) == 0)
        {
            if (pusage != NULL)
                *pusage = desc->usage;
            return true;
        }

    return false;
}


bool
hidrd_usage_from_token_or_hex(hidrd_usage *pusage, const char *token_or_hex)
{
    assert(token_or_hex != NULL);

    return hidrd_usage_from_token(pusage, token_or_hex) ||
           hidrd_usage_from_hex(pusage, token_or_hex);
}


#endif /* HIDRD_WITH_TOKENS */

#ifdef HIDRD_WITH_NAMES

const char *
hidrd_usage_name(hidrd_usage usage)
{
    const usage_desc   *desc;

    assert(hidrd_usage_valid(usage));

    desc = lookup_desc_by_num(usage);

    return (desc != NULL) ? desc->name : NULL;
}

#ifdef HIDRD_WITH_TOKENS

char *
hidrd_usage_desc(hidrd_usage usage)
{
    char               *result      = NULL;
    const usage_desc   *desc;
    const char         *token;
    const char         *name;
    char               *str         = NULL;
    char               *new_str     = NULL;

    assert(hidrd_usage_valid(usage));

    desc = lookup_desc_by_num(usage);
    if (desc == NULL)
    {
        token = NULL;
        name = NULL;
    }
    else
    {
        token = desc->token;
        name = desc->name;
    }

    if (token != NULL)
        str = hidrd_usage_to_hex(usage);
    else
        str = strdup("");

'changequote([,])[
#define MAP(_token, _name) \
    do {                                                    \
        if (!hidrd_usage_##_token(usage))                   \
            break;                                          \
                                                            \
        if (asprintf(&new_str,                              \
                     ((*str == '\0') ? "%s%s" : "%s, %s"),  \
                     str, _name) < 0)                       \
            goto cleanup;                                   \
                                                            \
        free(str);                                          \
        str = new_str;                                      \
        new_str = NULL;                                     \
    } while (0)

    MAP(top_level, "top-level");

    if (name == NULL)
    {
        result = str;
        str = NULL;
    }
    else if (*str == '\0')
        result = strdup(name);
    else if (asprintf(&result, "%s (%s)", name, str) < 0)
        goto cleanup;
]changequote(`,')`

cleanup:

    free(new_str);
    free(str);

    return result;
}

#endif /* HIDRD_WITH_TOKENS */


#endif /* HIDRD_WITH_NAMES */

'dnl
