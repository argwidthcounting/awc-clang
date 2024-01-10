; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 2
; RUN: opt -S -passes=early-cse -earlycse-debug-hash < %s | FileCheck %s
; NOTE: This file is testing the current implementation.  Some of
; the transforms used as negative tests below would be legal, but
; only if reached through a chain of logic which EarlyCSE is incapable
; of performing.  To say it differently, this file tests a conservative
; version of the memory model.  If we want to extend EarlyCSE to be more
; aggressive in the future, we may need to relax some of the negative tests.

; We can value forward across the fence since we can (semantically)
; reorder the following load before the fence.
define i32 @test(ptr %addr.i) {
; CHECK-LABEL: define i32 @test
; CHECK-SAME: (ptr [[ADDR_I:%.*]]) {
; CHECK-NEXT:    store i32 5, ptr [[ADDR_I]], align 4
; CHECK-NEXT:    fence release
; CHECK-NEXT:    ret i32 5
;
  store i32 5, ptr %addr.i, align 4
  fence release
  %a = load i32, ptr %addr.i, align 4
  ret i32 %a
}

; Same as above
define i32 @test2(ptr noalias %addr.i, ptr noalias %otheraddr) {
; CHECK-LABEL: define i32 @test2
; CHECK-SAME: (ptr noalias [[ADDR_I:%.*]], ptr noalias [[OTHERADDR:%.*]]) {
; CHECK-NEXT:    [[A:%.*]] = load i32, ptr [[ADDR_I]], align 4
; CHECK-NEXT:    fence release
; CHECK-NEXT:    ret i32 [[A]]
;
  %a = load i32, ptr %addr.i, align 4
  fence release
  %a2 = load i32, ptr %addr.i, align 4
  %res = sub i32 %a, %a2
  ret i32 %a
}

; We can not value forward across an acquire barrier since we might
; be syncronizing with another thread storing to the same variable
; followed by a release fence.  If this thread observed the release
; had happened, we must present a consistent view of memory at the
; fence.  Note that it would be legal to reorder '%a' after the fence
; and then remove '%a2'.  The current implementation doesn't know how
; to do this, but if it learned, this test will need revised.
define i32 @test3(ptr noalias %addr.i, ptr noalias %otheraddr) {
; CHECK-LABEL: define i32 @test3
; CHECK-SAME: (ptr noalias [[ADDR_I:%.*]], ptr noalias [[OTHERADDR:%.*]]) {
; CHECK-NEXT:    [[A:%.*]] = load i32, ptr [[ADDR_I]], align 4
; CHECK-NEXT:    fence acquire
; CHECK-NEXT:    [[A2:%.*]] = load i32, ptr [[ADDR_I]], align 4
; CHECK-NEXT:    [[RES:%.*]] = sub i32 [[A]], [[A2]]
; CHECK-NEXT:    ret i32 [[RES]]
;
  %a = load i32, ptr %addr.i, align 4
  fence acquire
  %a2 = load i32, ptr %addr.i, align 4
  %res = sub i32 %a, %a2
  ret i32 %res
}

; We can not dead store eliminate accross the fence.  We could in
; principal reorder the second store above the fence and then DSE either
; store, but this is beyond the simple last-store DSE which EarlyCSE
; implements.
define void @test4(ptr %addr.i) {
; CHECK-LABEL: define void @test4
; CHECK-SAME: (ptr [[ADDR_I:%.*]]) {
; CHECK-NEXT:    store i32 5, ptr [[ADDR_I]], align 4
; CHECK-NEXT:    fence release
; CHECK-NEXT:    store i32 5, ptr [[ADDR_I]], align 4
; CHECK-NEXT:    ret void
;
  store i32 5, ptr %addr.i, align 4
  fence release
  store i32 5, ptr %addr.i, align 4
  ret void
}

; We *could* DSE across this fence, but don't.  No other thread can
; observe the order of the acquire fence and the store.
define void @test5(ptr %addr.i) {
; CHECK-LABEL: define void @test5
; CHECK-SAME: (ptr [[ADDR_I:%.*]]) {
; CHECK-NEXT:    store i32 5, ptr [[ADDR_I]], align 4
; CHECK-NEXT:    fence acquire
; CHECK-NEXT:    store i32 5, ptr [[ADDR_I]], align 4
; CHECK-NEXT:    ret void
;
  store i32 5, ptr %addr.i, align 4
  fence acquire
  store i32 5, ptr %addr.i, align 4
  ret void
}