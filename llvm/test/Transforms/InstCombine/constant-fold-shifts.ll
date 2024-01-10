; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -passes=instcombine < %s | FileCheck %s

@A = external constant i32

; OSS-Fuzz #14169
; https://bugs.chromium.org/p/oss-fuzz/issues/detail?id=14169
define void @ossfuzz_14169_test1(ptr %a0) {
; CHECK-LABEL: @ossfuzz_14169_test1(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    store ptr undef, ptr undef, align 8
; CHECK-NEXT:    ret void
;
bb:
  %B = ptrtoint ptr @A to i64
  %C = icmp sge i64 %B, 0
  %X = select i1 %C, i712 0, i712 1
  %B9 = lshr i712 %X, 146783911423364576743092537299333564210980159306769991919205685720763064069663027716481187399048043939495936
  %G5 = getelementptr i64, ptr undef, i712 %B9
  store ptr %G5, ptr undef
  ret void
}

define void @ossfuzz_14169_test2(ptr %a0) {
; CHECK-LABEL: @ossfuzz_14169_test2(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    store ptr undef, ptr undef, align 8
; CHECK-NEXT:    ret void
;
bb:
  %B = ptrtoint ptr @A to i64
  %C = icmp sge i64 %B, 0
  %X = select i1 %C, i712 0, i712 1
  %B9 = shl i712 %X, 146783911423364576743092537299333564210980159306769991919205685720763064069663027716481187399048043939495936
  %G5 = getelementptr i64, ptr undef, i712 %B9
  store ptr %G5, ptr undef
  ret void
}