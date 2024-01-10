; NOTE: Assertions have been autogenerated by utils/update_analyze_test_checks.py UTC_ARGS: --version 2
; RUN: opt -passes="print<cost-model>" 2>&1 -disable-output -mtriple=aarch64--linux-gnu < %s | FileCheck %s

; Verify the cost of bswap instructions.

target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"

declare i16 @llvm.bswap.i16(i16)
declare i32 @llvm.bswap.i32(i32)
declare i64 @llvm.bswap.i64(i64)

declare <4 x i16> @llvm.bswap.v4i16(<4 x i16>)
declare <8 x i16> @llvm.bswap.v8i16(<8 x i16>)
declare <16 x i16> @llvm.bswap.v16i16(<16 x i16>)
declare <2 x i32> @llvm.bswap.v2i32(<2 x i32>)
declare <4 x i32> @llvm.bswap.v4i32(<4 x i32>)
declare <8 x i32> @llvm.bswap.v8i32(<8 x i32>)
declare <2 x i64> @llvm.bswap.v2i64(<2 x i64>)
declare <4 x i64> @llvm.bswap.v4i64(<4 x i64>)
declare <3 x i32> @llvm.bswap.v3i32(<3 x i32>)
declare <4 x i48> @llvm.bswap.v4i48(<4 x i48>)

define void @scalar() {
; CHECK-LABEL: 'scalar'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %b16 = call i16 @llvm.bswap.i16(i16 undef)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %b32 = call i32 @llvm.bswap.i32(i32 undef)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %b64 = call i64 @llvm.bswap.i64(i64 undef)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret void
;
  %b16 = call i16 @llvm.bswap.i16(i16 undef)
  %b32 = call i32 @llvm.bswap.i32(i32 undef)
  %b64 = call i64 @llvm.bswap.i64(i64 undef)
  ret void
}

define void @neon() {
; CHECK-LABEL: 'neon'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %v4i16 = call <4 x i16> @llvm.bswap.v4i16(<4 x i16> undef)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %v8i16 = call <8 x i16> @llvm.bswap.v8i16(<8 x i16> undef)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %v16i16 = call <16 x i16> @llvm.bswap.v16i16(<16 x i16> undef)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %v2i32 = call <2 x i32> @llvm.bswap.v2i32(<2 x i32> undef)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %v4i32 = call <4 x i32> @llvm.bswap.v4i32(<4 x i32> undef)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %v8i32 = call <8 x i32> @llvm.bswap.v8i32(<8 x i32> undef)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %v2i64 = call <2 x i64> @llvm.bswap.v2i64(<2 x i64> undef)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %v4i64 = call <4 x i64> @llvm.bswap.v4i64(<4 x i64> undef)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %v3i32 = call <3 x i32> @llvm.bswap.v3i32(<3 x i32> undef)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 10 for instruction: %v4i48 = call <4 x i48> @llvm.bswap.v4i48(<4 x i48> undef)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret void
;
  %v4i16 = call <4 x i16> @llvm.bswap.v4i16(<4 x i16> undef)
  %v8i16 = call <8 x i16> @llvm.bswap.v8i16(<8 x i16> undef)
  %v16i16 = call <16 x i16> @llvm.bswap.v16i16(<16 x i16> undef)
  %v2i32 = call <2 x i32> @llvm.bswap.v2i32(<2 x i32> undef)
  %v4i32 = call <4 x i32> @llvm.bswap.v4i32(<4 x i32> undef)
  %v8i32 = call <8 x i32> @llvm.bswap.v8i32(<8 x i32> undef)
  %v2i64 = call <2 x i64> @llvm.bswap.v2i64(<2 x i64> undef)
  %v4i64 = call <4 x i64> @llvm.bswap.v4i64(<4 x i64> undef)

  %v3i32 = call <3 x i32> @llvm.bswap.v3i32(<3 x i32> undef)
  %v4i48 = call <4 x i48> @llvm.bswap.v4i48(<4 x i48> undef)
  ret void
}