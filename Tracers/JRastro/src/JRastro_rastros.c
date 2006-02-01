/*
    Copyright (c) 1998--2006 Benhur Stein
    
    This file is part of Paj�.

    Paj� is free software; you can redistribute it and/or modify it under
    the terms of the GNU Lesser General Public License as published by the
    Free Software Foundation; either version 2 of the License, or (at your
    option) any later version.

    Paj� is distributed in the hope that it will be useful, but WITHOUT ANY
    WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
    FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
    for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Paj�; if not, write to the Free Software Foundation, Inc.,
	51 Franklin Street, Fifth Floor, Boston, MA 02111 USA.
*/



/* Do not edit. File generated by rastro_generate. */

#include "JRastro_rastros.h"

void rst_event_i_ptr(rst_buffer_t *ptr, u_int16_t type, u_int32_t i0)
{
	rst_startevent(ptr, type<<18|0x27000);
	RST_PUT(ptr, u_int32_t, i0);
	rst_endevent(ptr);
}

void rst_event_ii_ptr(rst_buffer_t *ptr, u_int16_t type, u_int32_t i0, u_int32_t i1)
{
	rst_startevent(ptr, type<<18|0x27700);
	RST_PUT(ptr, u_int32_t, i0);
	RST_PUT(ptr, u_int32_t, i1);
	rst_endevent(ptr);
}

void rst_event_is_ptr(rst_buffer_t *ptr, u_int16_t type, u_int32_t i0, u_int8_t *s0)
{
	rst_startevent(ptr, type<<18|0x27100);
	RST_PUT(ptr, u_int32_t, i0);
	RST_PUT_STR(ptr, s0);
	rst_endevent(ptr);
}

void rst_event_isii_ptr(rst_buffer_t *ptr, u_int16_t type, u_int32_t i0, u_int8_t *s0, u_int32_t i1, u_int32_t i2)
{
	rst_startevent(ptr, type<<18|0x27771);
	RST_PUT(ptr, u_int32_t, i0);
	RST_PUT(ptr, u_int32_t, i1);
	RST_PUT(ptr, u_int32_t, i2);
	RST_PUT_STR(ptr, s0);
	rst_endevent(ptr);
}

void rst_event_isiii_ptr(rst_buffer_t *ptr, u_int16_t type, u_int32_t i0, u_int8_t *s0, u_int32_t i1, u_int32_t i2, u_int32_t i3)
{
	rst_startevent(ptr, type<<18|0x7777);
	RST_PUT(ptr, u_int32_t, 0x21000000);
	RST_PUT(ptr, u_int32_t, i0);
	RST_PUT(ptr, u_int32_t, i1);
	RST_PUT(ptr, u_int32_t, i2);
	RST_PUT(ptr, u_int32_t, i3);
	RST_PUT_STR(ptr, s0);
	rst_endevent(ptr);
}

void rst_event_liis_ptr(rst_buffer_t *ptr, u_int16_t type, u_int64_t l0, u_int32_t i0, u_int32_t i1, u_int8_t *s0)
{
	rst_startevent(ptr, type<<18|0x24771);
	RST_PUT(ptr, u_int64_t, l0);
	RST_PUT(ptr, u_int32_t, i0);
	RST_PUT(ptr, u_int32_t, i1);
	RST_PUT_STR(ptr, s0);
	rst_endevent(ptr);
}

void rst_event_lis_ptr(rst_buffer_t *ptr, u_int16_t type, u_int64_t l0, u_int32_t i0, u_int8_t *s0)
{
	rst_startevent(ptr, type<<18|0x24710);
	RST_PUT(ptr, u_int64_t, l0);
	RST_PUT(ptr, u_int32_t, i0);
	RST_PUT_STR(ptr, s0);
	rst_endevent(ptr);
}

