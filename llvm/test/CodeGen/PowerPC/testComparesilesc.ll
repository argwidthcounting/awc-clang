; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs -mtriple=powerpc64-unknown-linux-gnu -O2 \
; RUN:   -ppc-gpr-icmps=all -ppc-asm-full-reg-names -mcpu=pwr8 < %s | FileCheck %s --check-prefix=CHECK-BE \
; RUN:   --implicit-check-not cmpw --implicit-check-not cmpd --implicit-check-not cmpl
; RUN: llc -verify-machineinstrs -mtriple=powerpc64le-unknown-linux-gnu -O2 \
; RUN:   -ppc-gpr-icmps=all -ppc-asm-full-reg-names -mcpu=pwr8 < %s | FileCheck %s --check-prefix=CHECK-LE \
; RUN:   --implicit-check-not cmpw --implicit-check-not cmpd --implicit-check-not cmpl
@glob = dso_local local_unnamed_addr global i8 0, align 1

define dso_local signext i32 @test_ilesc(i8 signext %a, i8 signext %b) {
; CHECK-LABEL: test_ilesc:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sub r3, r4, r3
; CHECK-NEXT:    rldicl r3, r3, 1, 63
; CHECK-NEXT:    xori r3, r3, 1
; CHECK-NEXT:    blr
; CHECK-BE-LABEL: test_ilesc:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    sub r3, r4, r3
; CHECK-BE-NEXT:    rldicl r3, r3, 1, 63
; CHECK-BE-NEXT:    xori r3, r3, 1
; CHECK-BE-NEXT:    blr
;
; CHECK-LE-LABEL: test_ilesc:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    sub r3, r4, r3
; CHECK-LE-NEXT:    rldicl r3, r3, 1, 63
; CHECK-LE-NEXT:    xori r3, r3, 1
; CHECK-LE-NEXT:    blr
entry:
  %cmp = icmp sle i8 %a, %b
  %conv2 = zext i1 %cmp to i32
  ret i32 %conv2
}

define dso_local signext i32 @test_ilesc_sext(i8 signext %a, i8 signext %b) {
; CHECK-LABEL: test_ilesc_sext:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sub r3, r4, r3
; CHECK-NEXT:    rldicl r3, r3, 1, 63
; CHECK-NEXT:    addi r3, r3, -1
; CHECK-NEXT:    blr
; CHECK-BE-LABEL: test_ilesc_sext:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    sub r3, r4, r3
; CHECK-BE-NEXT:    rldicl r3, r3, 1, 63
; CHECK-BE-NEXT:    addi r3, r3, -1
; CHECK-BE-NEXT:    blr
;
; CHECK-LE-LABEL: test_ilesc_sext:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    sub r3, r4, r3
; CHECK-LE-NEXT:    rldicl r3, r3, 1, 63
; CHECK-LE-NEXT:    addi r3, r3, -1
; CHECK-LE-NEXT:    blr
entry:
  %cmp = icmp sle i8 %a, %b
  %sub = sext i1 %cmp to i32
  ret i32 %sub
}

define dso_local void @test_ilesc_store(i8 signext %a, i8 signext %b) {
; CHECK-LABEL: test_ilesc_store:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sub r3, r4, r3
; CHECK-NEXT:    addis r5, r2, glob@toc@ha
; CHECK-NEXT:    rldicl r3, r3, 1, 63
; CHECK-NEXT:    xori r3, r3, 1
; CHECK-NEXT:    stb r3, glob@toc@l(r5)
; CHECK-NEXT:    blr
; CHECK-BE-LABEL: test_ilesc_store:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    sub r3, r4, r3
; CHECK-BE-NEXT:    addis r5, r2, glob@toc@ha
; CHECK-BE-NEXT:    rldicl r3, r3, 1, 63
; CHECK-BE-NEXT:    xori r3, r3, 1
; CHECK-BE-NEXT:    stb r3, glob@toc@l(r5)
; CHECK-BE-NEXT:    blr
;
; CHECK-LE-LABEL: test_ilesc_store:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    sub r3, r4, r3
; CHECK-LE-NEXT:    addis r5, r2, glob@toc@ha
; CHECK-LE-NEXT:    rldicl r3, r3, 1, 63
; CHECK-LE-NEXT:    xori r3, r3, 1
; CHECK-LE-NEXT:    stb r3, glob@toc@l(r5)
; CHECK-LE-NEXT:    blr
entry:
  %cmp = icmp sle i8 %a, %b
  %conv3 = zext i1 %cmp to i8
  store i8 %conv3, ptr @glob, align 1
  ret void
}

define dso_local void @test_ilesc_sext_store(i8 signext %a, i8 signext %b) {
; CHECK-LABEL: test_ilesc_sext_store:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sub r3, r4, r3
; CHECK-NEXT:    addis r5, r2, glob@toc@ha
; CHECK-NEXT:    rldicl r3, r3, 1, 63
; CHECK-NEXT:    addi r3, r3, -1
; CHECK-NEXT:    stb r3, glob@toc@l(r5)
; CHECK-NEXT:    blr
; CHECK-BE-LABEL: test_ilesc_sext_store:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    sub r3, r4, r3
; CHECK-BE-NEXT:    addis r5, r2, glob@toc@ha
; CHECK-BE-NEXT:    rldicl r3, r3, 1, 63
; CHECK-BE-NEXT:    addi r3, r3, -1
; CHECK-BE-NEXT:    stb r3, glob@toc@l(r5)
; CHECK-BE-NEXT:    blr
;
; CHECK-LE-LABEL: test_ilesc_sext_store:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    sub r3, r4, r3
; CHECK-LE-NEXT:    addis r5, r2, glob@toc@ha
; CHECK-LE-NEXT:    rldicl r3, r3, 1, 63
; CHECK-LE-NEXT:    addi r3, r3, -1
; CHECK-LE-NEXT:    stb r3, glob@toc@l(r5)
; CHECK-LE-NEXT:    blr
entry:
  %cmp = icmp sle i8 %a, %b
  %conv3 = sext i1 %cmp to i8
  store i8 %conv3, ptr @glob, align 1
  ret void
}