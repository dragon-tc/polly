//===--------------- polly/DragonTC.h - The DragonTC global option flag *- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// Introduce an option category for Polly.
//
//===----------------------------------------------------------------------===//

#ifndef POLLY_DRAGONTC_H
#define POLLY DRAGONTC_H

using namespace llvm;
using namespace polly;

static cl::opt<bool> DragonTCOptimizations(
    "dragontc-enable-polly-optimizations",
    cl::desc("Enable all options used by DragonTC."),
    cl::Hidden, cl::init(false), cl::ZeroOrMore, cl::cat(PollyCategory));

#endif
