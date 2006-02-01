/*
    Copyright (c) 1998--2006 Benhur Stein
    
    This file is part of Paje.

    Paje is free software; you can redistribute it and/or modify it under
    the terms of the GNU Lesser General Public License as published by the
    Free Software Foundation; either version 2 of the License, or (at your
    option) any later version.

    Paje is distributed in the hope that it will be useful, but WITHOUT ANY
    WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
    FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
    for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Paje; if not, write to the Free Software Foundation, Inc.,
	51 Franklin Street, Fifth Floor, Boston, MA 02111 USA.
*/


//////////////////////////////////////////////////
/*      Author: Geovani Ricardo Wiedenhoft      */
/*      Email: grw@inf.ufsm.br                  */
//////////////////////////////////////////////////



package org.lsc.JRastro;

import java.io.*;

public class Instru {

    public Instru() {

    }

native static void func_init(Object obj, Thread th);

    public static void ObjectInit(Object obj) {
      Thread th = Thread.currentThread();
      func_init(obj, th);
    }

native static void func_newArray(Object obj, Thread th);

    public static void NewArray(Object obj) {
      Thread th = Thread.currentThread();
      func_newArray(obj, th);
    }

native static void func(Object obj, Thread th, int mnum);

    public static void CallSite(Object obj, int mnum) {
      Thread th = Thread.currentThread();
      func(obj, th, mnum);

    }

native static void func_entry(Thread th, int mnum);

    public static void CallStaticSite(int mnum) {
      Thread th = Thread.currentThread();
      func_entry(th, mnum);

    }

native static void func_exit(Thread th);

    public static void ReturnSite() {
      Thread th = Thread.currentThread();
      func_exit(th);

    }

}

