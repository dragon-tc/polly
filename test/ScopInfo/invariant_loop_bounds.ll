; RUN: opt %loadPolly -polly-scops -analyze < %s | FileCheck %s
;
; CHECK:      Invariant Accesses: {
; CHECK-NEXT:         ReadAccess :=    [Reduction Type: NONE] [Scalar: 0]
; CHECK-NEXT:             [bounds2, bounds1, bounds0] -> { Stmt_for_cond[i0] -> MemRef_bounds[2] };
; CHECK-NEXT:         Execution Context: [bounds2, bounds1, bounds0] -> {  :  }
; CHECK-NEXT:         ReadAccess :=    [Reduction Type: NONE] [Scalar: 0]
; CHECK-NEXT:             [bounds2, bounds1, bounds0] -> { Stmt_for_cond_1[i0, i1] -> MemRef_bounds[1] };
; CHECK-NEXT:         Execution Context: [bounds2, bounds1, bounds0] -> {  : bounds2 >= 1 }
; CHECK-NEXT:         ReadAccess :=    [Reduction Type: NONE] [Scalar: 0]
; CHECK-NEXT:             [bounds2, bounds1, bounds0] -> { Stmt_for_cond_4[i0, i1, i2] -> MemRef_bounds[0] };
; CHECK-NEXT:         Execution Context: [bounds2, bounds1, bounds0] -> {  : bounds1 >= 1 and bounds2 >= 1 }
; CHECK-NEXT: }
;
; CHECK:      p0: %bounds2
; CHECK-NEXT: p1: %bounds1
; CHECK-NEXT: p2: %bounds0
;
; CHECK:      Statements {
; CHECK-NEXT:     Stmt_for_body_6
; CHECK-NEXT:         Domain :=
; CHECK-NEXT:             [bounds2, bounds1, bounds0] -> { Stmt_for_body_6[i0, i1, i2] : i0 >= 0 and i0 <= -1 + bounds2 and i1 >= 0 and i1 <= -1 + bounds1 and i2 >= 0 and i2 <= -1 + bounds0 };
; CHECK-NEXT:         Schedule :=
; CHECK-NEXT:             [bounds2, bounds1, bounds0] -> { Stmt_for_body_6[i0, i1, i2] -> [i0, i1, i2] };
; CHECK-NEXT:         ReadAccess :=    [Reduction Type: NONE] [Scalar: 0]
; CHECK-NEXT:             [bounds2, bounds1, bounds0] -> { Stmt_for_body_6[i0, i1, i2] -> MemRef_data[i0, i1, i2] };
; CHECK-NEXT:         MustWriteAccess :=    [Reduction Type: NONE] [Scalar: 0]
; CHECK-NEXT:             [bounds2, bounds1, bounds0] -> { Stmt_for_body_6[i0, i1, i2] -> MemRef_data[i0, i1, i2] };
; CHECK-NEXT: }
;
;    int bounds[3];
;    double data[1024][1024][1024];
;
;    void foo() {
;      int i, j, k;
;      for (k = 0; k < bounds[2]; k++)
;        for (j = 0; j < bounds[1]; j++)
;          for (i = 0; i < bounds[0]; i++)
;            data[k][j][i] += i + j + k;
;    }
;
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

@bounds = common global [3 x i32] zeroinitializer, align 4
@data = common global [1024 x [1024 x [1024 x double]]] zeroinitializer, align 16

define void @foo() {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.16, %entry
  %indvars.iv5 = phi i64 [ %indvars.iv.next6, %for.inc.16 ], [ 0, %entry ]
  %bounds2 = load i32, i32* getelementptr inbounds ([3 x i32], [3 x i32]* @bounds, i64 0, i64 2), align 4
  %tmp7 = sext i32 %bounds2 to i64
  %cmp = icmp slt i64 %indvars.iv5, %tmp7
  br i1 %cmp, label %for.body, label %for.end.18

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc.13, %for.body
  %indvars.iv3 = phi i64 [ %indvars.iv.next4, %for.inc.13 ], [ 0, %for.body ]
  %bounds1 = load i32, i32* getelementptr inbounds ([3 x i32], [3 x i32]* @bounds, i64 0, i64 1), align 4
  %tmp9 = sext i32 %bounds1 to i64
  %cmp2 = icmp slt i64 %indvars.iv3, %tmp9
  br i1 %cmp2, label %for.body.3, label %for.end.15

for.body.3:                                       ; preds = %for.cond.1
  br label %for.cond.4

for.cond.4:                                       ; preds = %for.inc, %for.body.3
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.inc ], [ 0, %for.body.3 ]
  %bounds0 = load i32, i32* getelementptr inbounds ([3 x i32], [3 x i32]* @bounds, i64 0, i64 0), align 4
  %tmp11 = sext i32 %bounds0 to i64
  %cmp5 = icmp slt i64 %indvars.iv, %tmp11
  br i1 %cmp5, label %for.body.6, label %for.end

for.body.6:                                       ; preds = %for.cond.4
  %tmp12 = add nsw i64 %indvars.iv, %indvars.iv3
  %tmp13 = add nsw i64 %tmp12, %indvars.iv5
  %tmp14 = trunc i64 %tmp13 to i32
  %conv = sitofp i32 %tmp14 to double
  %arrayidx11 = getelementptr inbounds [1024 x [1024 x [1024 x double]]], [1024 x [1024 x [1024 x double]]]* @data, i64 0, i64 %indvars.iv5, i64 %indvars.iv3, i64 %indvars.iv
  %tmp15 = load double, double* %arrayidx11, align 8
  %add12 = fadd double %tmp15, %conv
  store double %add12, double* %arrayidx11, align 8
  br label %for.inc

for.inc:                                          ; preds = %for.body.6
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  br label %for.cond.4

for.end:                                          ; preds = %for.cond.4
  br label %for.inc.13

for.inc.13:                                       ; preds = %for.end
  %indvars.iv.next4 = add nuw nsw i64 %indvars.iv3, 1
  br label %for.cond.1

for.end.15:                                       ; preds = %for.cond.1
  br label %for.inc.16

for.inc.16:                                       ; preds = %for.end.15
  %indvars.iv.next6 = add nuw nsw i64 %indvars.iv5, 1
  br label %for.cond

for.end.18:                                       ; preds = %for.cond
  ret void
}
