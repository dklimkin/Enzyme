; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --include-generated-funcs
; RUN: %opt < %s %loadEnzyme -enzyme -enzyme-lower-globals -enzyme-vectorize-at-leaf-nodes -mem2reg -sroa -simplifycfg -instsimplify -S | FileCheck %s

; Function Attrs: nounwind
declare <3 x double> @__enzyme_fwddiff(double (double)*, ...)

@global = external dso_local local_unnamed_addr global double, align 8

; Function Attrs: noinline norecurse nounwind readonly uwtable
define double @mulglobal(double %x) {
entry:
  %l1 = load double, double* @global, align 8
  %mul = fmul fast double %l1, %x
  store double %mul, double* @global, align 8
  %l2 = load double, double* @global, align 8
  %mul2 = fmul fast double %l2, %l2
  store double %mul2, double* @global, align 8
  %l3 = load double, double* @global, align 8
  ret double %l3
}

; Function Attrs: noinline nounwind uwtable
define <3 x double> @derivative(double %x) {
entry:
  %0 = tail call <3 x double> (double (double)*, ...) @__enzyme_fwddiff(double (double)* nonnull @mulglobal, metadata !"enzyme_width", i64 3, double %x, <3 x double> <double 1.0, double 2.0, double 3.0>)
  ret <3 x double> %0
}


; CHECK: define internal <3 x double> @fwddiffe3mulglobal(double %x, <3 x double> %"x'")
; CHECK-NEXT:  entry:
; CHECK-NEXT:   %global_local.0.copyload = load double, double* @global, align 8
; CHECK-NEXT:   %mul = fmul fast double %global_local.0.copyload, %x
; CHECK-NEXT:   %.splatinsert = insertelement <3 x double> poison, double %global_local.0.copyload, i32 0
; CHECK-NEXT:   %.splat = shufflevector <3 x double> %.splatinsert, <3 x double> poison, <3 x i32> zeroinitializer
; CHECK-NEXT:   %0 = fmul fast <3 x double> %"x'", %.splat
; CHECK-NEXT:   %mul2 = fmul fast double %mul, %mul
; CHECK-NEXT:   %.splatinsert3 = insertelement <3 x double> poison, double %mul, i32 0
; CHECK-NEXT:   %.splat4 = shufflevector <3 x double> %.splatinsert3, <3 x double> poison, <3 x i32> zeroinitializer
; CHECK-NEXT:   %.splatinsert5 = insertelement <3 x double> poison, double %mul, i32 0
; CHECK-NEXT:   %.splat6 = shufflevector <3 x double> %.splatinsert5, <3 x double> poison, <3 x i32> zeroinitializer
; CHECK-NEXT:   %1 = fmul fast <3 x double> %0, %.splat6
; CHECK-NEXT:   %2 = fmul fast <3 x double> %0, %.splat4
; CHECK-NEXT:   %3 = fadd fast <3 x double> %1, %2
; CHECK-NEXT:   store double %mul2, double* @global, align 8, !alias.scope !0, !noalias !3
; CHECK-NEXT:   ret <3 x double> %3
; CHECK-NEXT: }