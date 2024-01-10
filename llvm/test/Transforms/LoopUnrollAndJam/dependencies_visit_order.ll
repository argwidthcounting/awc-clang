; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes=loop-unroll-and-jam -allow-unroll-and-jam -unroll-and-jam-count=4 < %s -S | FileCheck %s

target datalayout = "e-m:e-p:32:32-i64:64-v128:64:128-a:0:32-n32-S64"

define void @test1() {
; CHECK-LABEL: @test1(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    br i1 false, label [[BB1_BB43_CRIT_EDGE_UNR_LCSSA:%.*]], label [[BB_NEW:%.*]]
; CHECK:       bb.new:
; CHECK-NEXT:    br label [[BB5_PREHEADER:%.*]]
; CHECK:       bb5.preheader:
; CHECK-NEXT:    [[I10:%.*]] = phi i16 [ 0, [[BB_NEW]] ], [ [[I42_3:%.*]], [[BB38:%.*]] ]
; CHECK-NEXT:    [[NITER:%.*]] = phi i16 [ 0, [[BB_NEW]] ], [ [[NITER_NEXT_3:%.*]], [[BB38]] ]
; CHECK-NEXT:    [[I4017:%.*]] = zext i16 [[I10]] to i64
; CHECK-NEXT:    [[I13_I:%.*]] = add nuw nsw i64 [[I4017]], 1
; CHECK-NEXT:    [[I42:%.*]] = trunc i64 [[I13_I]] to i16
; CHECK-NEXT:    [[I4017_1:%.*]] = zext i16 [[I42]] to i64
; CHECK-NEXT:    [[I13_I_1:%.*]] = add nuw nsw i64 [[I4017_1]], 1
; CHECK-NEXT:    [[I42_1:%.*]] = trunc i64 [[I13_I_1]] to i16
; CHECK-NEXT:    [[I4017_2:%.*]] = zext i16 [[I42_1]] to i64
; CHECK-NEXT:    [[I13_I_2:%.*]] = add nuw nsw i64 [[I4017_2]], 1
; CHECK-NEXT:    [[I42_2:%.*]] = trunc i64 [[I13_I_2]] to i16
; CHECK-NEXT:    [[I4017_3:%.*]] = zext i16 [[I42_2]] to i64
; CHECK-NEXT:    [[I13_I_3:%.*]] = add nuw nsw i64 [[I4017_3]], 1
; CHECK-NEXT:    [[I42_3]] = trunc i64 [[I13_I_3]] to i16
; CHECK-NEXT:    [[NITER_NEXT_3]] = add nuw i16 [[NITER]], 4
; CHECK-NEXT:    br label [[BB10_PREHEADER:%.*]]
; CHECK:       bb10.preheader:
; CHECK-NEXT:    br i1 true, label [[BB38]], label [[BB10_PREHEADER]]
; CHECK:       bb38:
; CHECK-NEXT:    [[NITER_NCMP_3:%.*]] = icmp eq i16 [[NITER_NEXT_3]], -28
; CHECK-NEXT:    br i1 [[NITER_NCMP_3]], label [[BB1_BB43_CRIT_EDGE_UNR_LCSSA_LOOPEXIT:%.*]], label [[BB5_PREHEADER]], !llvm.loop [[LOOP0:![0-9]+]]
; CHECK:       bb1.bb43_crit_edge.unr-lcssa.loopexit:
; CHECK-NEXT:    [[I10_UNR_PH:%.*]] = phi i16 [ [[I42_3]], [[BB38]] ]
; CHECK-NEXT:    br label [[BB1_BB43_CRIT_EDGE_UNR_LCSSA]]
; CHECK:       bb1.bb43_crit_edge.unr-lcssa:
; CHECK-NEXT:    [[I10_UNR:%.*]] = phi i16 [ 0, [[BB:%.*]] ], [ [[I10_UNR_PH]], [[BB1_BB43_CRIT_EDGE_UNR_LCSSA_LOOPEXIT]] ]
; CHECK-NEXT:    br i1 true, label [[BB5_PREHEADER_EPIL_PREHEADER:%.*]], label [[BB1_BB43_CRIT_EDGE:%.*]]
; CHECK:       bb5.preheader.epil.preheader:
; CHECK-NEXT:    br label [[BB5_PREHEADER_EPIL:%.*]]
; CHECK:       bb5.preheader.epil:
; CHECK-NEXT:    [[I10_EPIL:%.*]] = phi i16 [ [[I10_UNR]], [[BB5_PREHEADER_EPIL_PREHEADER]] ], [ [[I42_EPIL:%.*]], [[BB38_EPIL:%.*]] ]
; CHECK-NEXT:    [[EPIL_ITER:%.*]] = phi i16 [ 0, [[BB5_PREHEADER_EPIL_PREHEADER]] ], [ [[EPIL_ITER_NEXT:%.*]], [[BB38_EPIL]] ]
; CHECK-NEXT:    br label [[BB10_PREHEADER_EPIL:%.*]]
; CHECK:       bb10.preheader.epil:
; CHECK-NEXT:    br i1 true, label [[BB38_EPIL]], label [[BB10_PREHEADER_EPIL]]
; CHECK:       bb38.epil:
; CHECK-NEXT:    [[I4017_EPIL:%.*]] = zext i16 [[I10_EPIL]] to i64
; CHECK-NEXT:    [[I13_I_EPIL:%.*]] = add i64 [[I4017_EPIL]], 1
; CHECK-NEXT:    [[I14_I_EPIL:%.*]] = select i1 true, i64 [[I13_I_EPIL]], i64 [[I4017_EPIL]]
; CHECK-NEXT:    [[I42_EPIL]] = trunc i64 [[I14_I_EPIL]] to i16
; CHECK-NEXT:    [[I3_NOT_EPIL:%.*]] = icmp eq i16 [[I10_EPIL]], -27
; CHECK-NEXT:    [[EPIL_ITER_NEXT]] = add i16 [[EPIL_ITER]], 1
; CHECK-NEXT:    [[EPIL_ITER_CMP:%.*]] = icmp ne i16 [[EPIL_ITER_NEXT]], 2
; CHECK-NEXT:    br i1 [[EPIL_ITER_CMP]], label [[BB5_PREHEADER_EPIL]], label [[BB1_BB43_CRIT_EDGE_EPILOG_LCSSA:%.*]], !llvm.loop [[LOOP2:![0-9]+]]
; CHECK:       bb1.bb43_crit_edge.epilog-lcssa:
; CHECK-NEXT:    br label [[BB1_BB43_CRIT_EDGE]]
; CHECK:       bb1.bb43_crit_edge:
; CHECK-NEXT:    ret void
;
bb:
  br label %bb5.preheader

bb5.preheader:                                    ; preds = %bb38, %bb
  %i10 = phi i16 [ 0, %bb ], [ %i42, %bb38 ]
  br label %bb10.preheader

bb10.preheader:                                   ; preds = %bb10.preheader, %bb5.preheader
  br i1 true, label %bb38, label %bb10.preheader

bb38:                                             ; preds = %bb10.preheader
  %i4017 = zext i16 %i10 to i64
  %i13.i = add i64 %i4017, 1
  %i14.i = select i1 true, i64 %i13.i, i64 %i4017
  %i42 = trunc i64 %i14.i to i16
  %i3.not = icmp eq i16 %i10, -27
  br i1 %i3.not, label %bb1.bb43_crit_edge, label %bb5.preheader

bb1.bb43_crit_edge:                               ; preds = %bb38
  ret void
}