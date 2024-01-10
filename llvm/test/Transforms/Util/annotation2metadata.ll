; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes='annotation2metadata' -pass-remarks-analysis='annotation-remarks' -S %s | FileCheck %s

@.str = private unnamed_addr constant [10 x i8] c"_remarks1\00", section "llvm.metadata"
@.str.1 = private unnamed_addr constant [6 x i8] c"ann.c\00", section "llvm.metadata"
@.str.2 = private unnamed_addr constant [10 x i8] c"_remarks2\00", section "llvm.metadata"
@llvm.global.annotations = appending global [8 x { ptr, ptr, ptr, i32 }] [
    { ptr, ptr, ptr, i32 } { ptr @test1, ptr @.str, ptr @.str.1, i32 2 },
    { ptr, ptr, ptr, i32 } { ptr @test1, ptr @.str.2, ptr @.str.1, i32 2 },
    { ptr, ptr, ptr, i32 } { ptr @test3, ptr @.str, ptr undef, i32 4 }, ; Invalid entry, make sure we do not crash.
    { ptr, ptr, ptr, i32 } { ptr @test3, ptr undef, ptr @.str.1, i32 4 }, ; Invalid entry, make sure we do not crash.
    { ptr, ptr, ptr, i32 } { ptr undef, ptr @.str, ptr @.str.1, i32 4 }, ; Invalid entry, make sure we do not crash.
    { ptr, ptr, ptr, i32 } { ptr undef, ptr undef, ptr @.str.1, i32 4 }, ; Invalid entry, make sure we do not crash.
    { ptr, ptr, ptr, i32 } { ptr undef, ptr undef, ptr undef, i32 300 },  ; Invalid entry, make sure we do not crash.
    { ptr, ptr, ptr, i32 } { ptr @test3, ptr @.str, ptr @.str.1, i32 4 }
    ], section "llvm.metadata"



define void @test1(ptr %a) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A_ADDR:%.*]] = alloca ptr, align 8, !annotation [[GROUP1:!.+]]
; CHECK-NEXT:    store ptr [[A:%.*]], ptr [[A_ADDR]], align 8, !annotation [[GROUP1]]
; CHECK-NEXT:    ret void, !annotation [[GROUP1]]
;
entry:
  %a.addr = alloca ptr, align 8
  store ptr %a, ptr %a.addr, align 8
  ret void
}

define void @test2(ptr %a) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A_ADDR:%.*]] = alloca ptr, align 8
; CHECK-NEXT:    store ptr [[A:%.*]], ptr [[A_ADDR]], align 8
; CHECK-NEXT:    ret void
;
entry:
  %a.addr = alloca ptr, align 8
  store ptr %a, ptr %a.addr, align 8
  ret void
}

define void @test3(ptr %a) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A_ADDR:%.*]] = alloca ptr, align 8, !annotation [[GROUP2:!.+]]
; CHECK-NEXT:    store ptr [[A:%.*]], ptr [[A_ADDR]], align 8, !annotation [[GROUP2]]
; CHECK-NEXT:    ret void, !annotation [[GROUP2]]
;
entry:
  %a.addr = alloca ptr, align 8
  store ptr %a, ptr %a.addr, align 8
  ret void
}

; CHECK:      [[GROUP1]] = !{!"_remarks1", !"_remarks2"}
; CHECK-NEXT: [[GROUP2]] = !{!"_remarks1"}