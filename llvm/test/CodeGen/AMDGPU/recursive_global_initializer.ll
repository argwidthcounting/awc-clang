; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --check-globals --version 2
; RUN: opt -mtriple=amdgcn-amd-amdhsa -amdgpu-attributor -S %s | FileCheck %s

%struct.foo = type { %struct.pluto, ptr, i64 }
%struct.pluto = type { [512 x i8], ptr }

@global.2 = internal addrspace(1) global %struct.foo { %struct.pluto zeroinitializer, ptr addrspacecast (ptr addrspace(1) @global.2 to ptr), i64 0 }

;.
; CHECK: @[[GLOBAL_2:[a-zA-Z0-9_$"\\.-]+]] = internal addrspace(1) global [[STRUCT_FOO:%.*]] { [[STRUCT_PLUTO:%.*]] zeroinitializer, ptr addrspacecast (ptr addrspace(1) @global.2 to ptr), i64 0 }
;.
define void @hoge()  {
; CHECK-LABEL: define void @hoge
; CHECK-SAME: () #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:    [[LOAD:%.*]] = load i64, ptr addrspace(1) getelementptr inbounds ([[STRUCT_FOO:%.*]], ptr addrspace(1) @global.2, i64 0, i32 2), align 8
; CHECK-NEXT:    ret void
;
  %load = load i64, ptr addrspace(1) getelementptr inbounds (%struct.foo, ptr addrspace(1) @global.2, i64 0, i32 2), align 8
  ret void
}
;.
; CHECK: attributes #[[ATTR0]] = { "amdgpu-no-completion-action" "amdgpu-no-default-queue" "amdgpu-no-dispatch-id" "amdgpu-no-dispatch-ptr" "amdgpu-no-heap-ptr" "amdgpu-no-hostcall-ptr" "amdgpu-no-implicitarg-ptr" "amdgpu-no-lds-kernel-id" "amdgpu-no-multigrid-sync-arg" "amdgpu-no-queue-ptr" "amdgpu-no-workgroup-id-x" "amdgpu-no-workgroup-id-y" "amdgpu-no-workgroup-id-z" "amdgpu-no-workitem-id-x" "amdgpu-no-workitem-id-y" "amdgpu-no-workitem-id-z" "amdgpu-waves-per-eu"="4,10" "uniform-work-group-size"="false" }
;.