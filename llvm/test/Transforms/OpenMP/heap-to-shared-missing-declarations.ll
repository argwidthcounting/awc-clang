; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --check-attributes --check-globals
; REQUIRES: amdgpu-registered-target
; RUN: opt -mtriple=amdgcn-amd-amdhsa -S -passes=openmp-opt < %s | FileCheck %s

define internal void @outlined0() {
; CHECK: Function Attrs: nounwind
; CHECK-LABEL: define {{[^@]+}}@outlined0
; CHECK-SAME: () #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:  bb:
; CHECK-NEXT:    call void @func() #[[ATTR1:[0-9]+]]
; CHECK-NEXT:    [[I:%.*]] = call i32 @__kmpc_get_hardware_num_threads_in_block() #[[ATTR0]]
; CHECK-NEXT:    ret void
;
bb:
  call void @func()
  %i = call i32 @__kmpc_get_hardware_num_threads_in_block()
  ret void
}

define internal void @func() {
; CHECK: Function Attrs: nosync nounwind
; CHECK-LABEL: define {{[^@]+}}@func
; CHECK-SAME: () #[[ATTR1]] {
; CHECK-NEXT:  bb:
; CHECK-NEXT:    [[I:%.*]] = load ptr, ptr null, align 4294967296
; CHECK-NEXT:    store i64 0, ptr [[I]], align 8
; CHECK-NEXT:    ret void
;
bb:
  %i = load ptr, ptr addrspacecast (ptr addrspace(5) null to ptr), align 4294967296
  store i64 0, ptr %i, align 8
  ret void
}

define internal void @outlined1() {
; CHECK: Function Attrs: nosync nounwind
; CHECK-LABEL: define {{[^@]+}}@outlined1
; CHECK-SAME: () #[[ATTR1]] {
; CHECK-NEXT:  bb:
; CHECK-NEXT:    [[I:%.*]] = icmp sle i32 1, 0
; CHECK-NEXT:    br i1 [[I]], label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       common.ret:
; CHECK-NEXT:    ret void
; CHECK:       bb1:
; CHECK-NEXT:    call void @func() #[[ATTR1]]
; CHECK-NEXT:    br label [[COMMON_RET:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    call void @__kmpc_free_shared(ptr null, i64 0) #[[ATTR0]]
; CHECK-NEXT:    br label [[COMMON_RET]]
;
bb:
  %i = icmp sle i32 1, 0
  br i1 %i, label %bb1, label %bb2

common.ret:                                       ; preds = %bb2, %bb1
  ret void

bb1:                                              ; preds = %bb
  call void @func()
  br label %common.ret

bb2:                                              ; preds = %bb
  call void @__kmpc_free_shared(ptr null, i64 0)
  br label %common.ret
}

define void @user() {
; CHECK-LABEL: define {{[^@]+}}@user() {
; CHECK-NEXT:    call void @outlined0() #[[ATTR0]]
; CHECK-NEXT:    call void @outlined1() #[[ATTR1]]
; CHECK-NEXT:    ret void
;
  call void @outlined0()
  call void @outlined1()
  ret void
}

declare i32 @__kmpc_get_hardware_num_threads_in_block()
declare void @__kmpc_free_shared(ptr, i64)

!llvm.module.flags = !{!0, !1}

!0 = !{i32 7, !"openmp", i32 50}
!1 = !{i32 7, !"openmp-device", i32 50}
;.
; CHECK: attributes #[[ATTR0]] = { nounwind }
; CHECK: attributes #[[ATTR1]] = { nosync nounwind }
;.
; CHECK: [[META0:![0-9]+]] = !{i32 7, !"openmp", i32 50}
; CHECK: [[META1:![0-9]+]] = !{i32 7, !"openmp-device", i32 50}
;.