; Note: The license below is based on the template at:
; http://opensource.org/licenses/BSD-3-Clause

; Copyright (C) 2020 Regents of the University of Texas
; All rights reserved.

; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are
; met:

; o Redistributions of source code must retain the above copyright
;   notice, this list of conditions and the following disclaimer.

; o Redistributions in binary form must reproduce the above copyright
;   notice, this list of conditions and the following disclaimer in the
;   documentation and/or other materials provided with the distribution.

; o Neither the name of the copyright holders nor the names of its
;   contributors may be used to endorse or promote products derived
;   from this software without specific prior written permission.

; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
; A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
; HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
; LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
; DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
; THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

; Original Author(s):
; Mertcan Temel         <mert@utexas.edu>

(in-package "RP")

(include-book "fnc-defs")

(local
 (include-book "projects/rp-rewriter/proofs/rp-equal-lemmas" :dir :system))

(local
 (include-book "projects/rp-rewriter/proofs/aux-function-lemmas" :dir :system))

(local
 (include-book "projects/rp-rewriter/proofs/eval-functions-lemmas" :dir :system))

(include-book "lemmas")
 

(include-book "summation-tree-meta-fncs")

(include-book "pp-flatten-meta-correct")

(include-book "sum-merge-fncs-correct")

(include-book "lemmas-2")
 

(local
 (fetch-new-events
  (include-book "arithmetic-5/top" :dir :system)
  use-arith-5
  :disabled t))

(local
 (in-theory (enable ex-from-rp-loose-is-ex-from-rp)))

(local
 (in-theory (enable rp-trans trans-list)))

(create-regular-eval-lemma c 4 mult-formula-checks)
(create-regular-eval-lemma s 3 mult-formula-checks)
(create-regular-eval-lemma c-res 3 mult-formula-checks)
(create-regular-eval-lemma and-list 2 mult-formula-checks)
(create-regular-eval-lemma -- 1 mult-formula-checks)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; get-max-min-val

(local
 (in-theory (disable (:DEFINITION ACL2::APPLY$-BADGEP)
                     (:REWRITE RP-TERM-LISTP-IS-TRUE-LISTP)
                     (:DEFINITION RP-TERM-LISTP)
                     (:DEFINITION RP-TERMP)
                     (:DEFINITION EX-FROM-RP)
                     (:REWRITE NOT-INCLUDE-RP)
                     (:LINEAR ACL2::APPLY$-BADGEP-PROPERTIES . 1))))

(defthm get-max-min-val-correct-lemma1
  (implies (and (lte (ifix a) (ifix b))
                (lte (ifix x) (ifix y))
                )
           (not (gt (sum a x)
                    (sum b y))))
  :hints (("Goal"
           :in-theory (e/d (rw-dir2
                            ifix
                            sum)
                           (rw-dir1
                            +-IS-SUM)))))

#|(defthmd rp-evlt-of-ex-from-rp-reverse
  (implies (syntaxp (atom term))
           (equal (rp-evlt term a)
                  (rp-evlt (ex-from-rp term) a))))||#

(defthmd minus-to---
  (implies (integerp term)
           (equal (- term)
                  (-- term)))
  :hints (("Goal"
           :in-theory (e/d (--) ()))))

(defthm gt-of-minues
  (and (equal (gt (-- a) (-- b))
              (gt (ifix b) (ifix a)))
       (equal (lte (-- a) (-- b))
              (lte (ifix b) (ifix a))))
  :hints (("Goal"
           :in-theory (e/d (-- rw-dir2
                               (:REWRITE ACL2::|(- (- x))|)
                               (:REWRITE ACL2::|(< (- x) (- y))|))
                           (rw-dir1)))))

(defthm get-max-min-val-correct-lemma2
  (implies (bitp term)
           (and (not (gt term 1))
                (not (gt 0 term)))))

(defthmd RP-TRANS-LST-of-consp
  (implies (consp lst)
           (equal (rp-trans-lst lst)
                  (cons (rp-trans (car lst))
                        (rp-trans-lst (cdr lst))))))

(defthm IS-RP-BITP-implies
  (implies (IS-RP-BITP term)
           (CASE-MATCH TERM (('RP ''BITP &) T)))
  :rule-classes :forward-chaining
  :hints (("Goal"
           :in-theory (e/d (IS-RP-BITP) ()))))

(defthm get-max-min-val-correct-lemma3
  (and (implies (and (lte (ifix a) (ifix x)))
                (not (gt (f2 a)
                         (f2 x))))
       (implies (and (lte (ifix a) (ifix x))
                     (lte (ifix b) (ifix y)))
                (not (gt (f2 (sum a b))
                         (f2 (sum x y)))))
       (implies (and (lte (ifix a) (ifix x))
                     (lte (ifix b) (ifix y))
                     (lte (ifix c) (ifix z)))
                (not (gt (f2 (sum a b c))
                         (f2 (sum x y z))))))
  :hints (("Goal"
           :in-theory (e/d (rw-dir2
                            f2
                            sum
                            (:REWRITE ACL2::|(* a (/ a) b)|)
                            (:REWRITE ACL2::|(* x (+ y z))|)
                            (:REWRITE ACL2::|(* y x)|)
                            (:REWRITE ACL2::|(+ 0 x)|)
                            (:REWRITE ACL2::|(+ y x)|)
                            (:REWRITE ACL2::|(/ (/ x))|)
                            (:REWRITE ACL2::|(< (+ c/d x) y)|)
                            (:REWRITE ACL2::|(equal (/ x) c)|)
                            (:REWRITE ACL2::|(floor (if a b c) x)|)
                            (:REWRITE ACL2::|(floor x 2)| . 1)
                            (:REWRITE ACL2::DEFAULT-LESS-THAN-1)
                            (:REWRITE ACL2::DEFAULT-LESS-THAN-2)
                            (:REWRITE IFIX-OPENER)
                            (:REWRITE ACL2::SIMPLIFY-PRODUCTS-GATHER-EXPONENTS-<)
                            (:REWRITE ACL2::SIMPLIFY-TERMS-SUCH-AS-0-<-AX+BX-RATIONAL-COMMON)
                            (:REWRITE
                             ACL2::SIMPLIFY-TERMS-SUCH-AS-AX+BX-<-0-RATIONAL-COMMON))
                           (rw-dir1
                            (:DEFINITION NFIX)
                            (:DEFINITION FLOOR)
                            +-IS-SUM)))))

(defthm valid-sc-when-single-c-p
  (implies (and (SINGLE-C-P term)
                (valid-sc term a))
           (and (valid-sc (caddr term) a)
                (valid-sc (cadddr term) a)
                (valid-sc (car (cddddr term)) a)))
  :hints (("Goal"
           :expand ((VALID-SC TERM A)
                    (VALID-SC-SUBTERMS (CDDR TERM) A)
                    (VALID-SC-SUBTERMS (CDdDR TERM) A)
                    (VALID-SC-SUBTERMS (CDDDDR TERM) A)
                    (VALID-SC-SUBTERMS (CDR TERM) A))
           :in-theory (e/d (SINGLE-C-P is-rp)
                           (valid-sc valid-sc-subterms)))))

(defthm valid-sc-subterms-cons
  (implies (consp lst)
           (equal (valid-sc-subterms lst a)
                  (and (valid-sc (car lst) a)
                       (valid-sc-subterms (cdr lst) a)))))

(defthm valid-sc-when-list-instance
  (and (implies (and (valid-sc term a)
                     (case-match term
                       (('list . &) t)))
                (valid-sc-subterms (cdr term) a)))
  :hints (("Goal"
           :expand (valid-sc term a)
           :in-theory (e/d (valid-sc is-rp) ()))))

(defthm is-rp-bitp-implies-bitp-term
  (implies (and (VALID-SC TERM A)
                (IS-RP-BITP TERM))
           (and (INTEGERP (RP-EVLt (EX-FROM-RP TERM) A))
                (INTEGERP (RP-EVLt term A))
                (bitp (RP-EVLt (EX-FROM-RP TERM) A))
                (bitp (RP-EVLt term A))))
  :rule-classes :forward-chaining
  :hints (("Goal"
           :do-not-induct t
           :expand ((VALID-SC TERM A)
                    (CONTEXT-FROM-RP TERM NIL))
           :in-theory (e/d (is-rp IS-RP-BITP) (valid-sc)))))

(defthm drop-ex-from-rp-when-list
  (implies (equal (car term) 'list)
           (equal (ex-from-rp term)
                  term))
  :rule-classes :forward-chaining
  :hints (("Goal"
           :in-theory (e/d (ex-from-rp
                            is-rp)
                           ()))))
(std::defret-mutual
 get-max-min-val-correct
 (defret
   get-max-min-val-correct
   (implies (and valid
                 (rp-evl-meta-extract-global-facts :state state)
                 (valid-sc term a)
                 (mult-formula-checks state))
            (and (integerp (rp-evlt term a))
                 (<= (rp-evlt term a)
                     max-val)
                 (<= min-val
                     (rp-evlt term a))))
   :fn get-max-min-val)
 (defret
   get-max-min-val-lst-correct
   (implies (and valid
                 (rp-evl-meta-extract-global-facts :state state)
                 (valid-sc-subterms lst a)
                 (mult-formula-checks state))
            (and (<= (sum-list (rp-evlt-lst lst a))
                     max-val)
                 (<= min-val
                     (sum-list (rp-evlt-lst lst a)))))
   :fn get-max-min-val-lst)
 :mutual-recursion get-max-min-val
;:otf-flg t
 :hints (("Goal"
          :do-not-induct t
          :in-theory (e/d (get-max-min-val
                           RP-TRANS-LST-of-consp
                           RP-TRANS-LST
                           RP-TRANS
                           rp-evlt-of-ex-from-rp-reverse
                           minus-to---
                           get-max-min-val-lst)
                          (RP-EVLT-OF-EX-FROM-RP
                           (:REWRITE SUM-OF-NEGATED-ELEMENTS)
                           (:TYPE-PRESCRIPTION GT)
                           (:DEFINITION FLOOR)
                           (:TYPE-PRESCRIPTION O<)
                           (:TYPE-PRESCRIPTION VALID-SC)
                           (:TYPE-PRESCRIPTION MULT-FORMULA-CHECKS)
                           (:TYPE-PRESCRIPTION SINGLE-C-P$INLINE)
                           (:TYPE-PRESCRIPTION IS-RP-BITP)
                           (:TYPE-PRESCRIPTION VALID-SC-SUBTERMS)
                           (:REWRITE IS-IF-RP-TERMP)
                           (:REWRITE DEFAULT-CAR)
                           (:REWRITE DEFAULT-Cdr)
                           (:REWRITE IS-RP-PSEUDO-TERMP)
                           (:DEFINITION INCLUDE-FNC)
                           (:DEFINITION NONNEGATIVE-INTEGER-QUOTIENT)
                           (:REWRITE LTE-AND-GTE-IMPLIES)
                           (:REWRITE VALID-SC-EX-FROM-RP-2)
                           (:DEFINITION EVAL-AND-ALL)
                           (:DEFINITION NFIX)
                           (:REWRITE ACL2::O-P-O-INFP-CAR)
                           (:REWRITE DEFAULT-*-2)
                           (:REWRITE LT-TO-GT)
                           (:DEFINITION TRANS-LIST)
                           VALID-SC-SUBTERMS
;to-list*-sum-eval
;to-list*-sum-eval-2
                           valid-sc
                           bitp)))))

(local
 (in-theory (disable bitp)))

(defret
  is-c-bitp-traverse-correct
  (implies (and res
                (rp-evl-meta-extract-global-facts :state state)
                (valid-sc single-c a)
                (mult-formula-checks state))
           (bitp (rp-evlt single-c a)))
  :rule-classes (:rewrite)
  :fn is-c-bitp-traverse
  :hints (("Goal"
           :use ((:instance get-max-min-val-correct
                            (term single-c)))
           :in-theory (e/d (is-c-bitp-traverse
                            bitp
                            rw-dir2)
                           (get-max-min-val-correct
                            rw-dir1)))) )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; compress-s-c and decompress-s-c correct

(defthm is-rp-of-s-c-list
  (and (not (is-rp (cons 'c rest)))
       (not (is-rp (cons 'c-res rest)))
       (not (is-rp (cons '-- rest)))
       (not (is-rp (cons 'list rest)))
       (not (is-rp (cons 's rest))))
  :hints (("Goal"
           :in-theory (e/d (is-rp) ()))))

(defthm is-if-of-s-c-list
  (and (not (is-if (cons 'c rest)))
       (not (is-if (cons 'c-res rest)))
       (not (is-if (cons '-- rest)))
       (not (is-if (cons 'list rest)))
       (not (is-if (cons 's rest))))
  :hints (("Goal"
           :in-theory (e/d (is-if) ()))))

(defthmd rp-evlt-of-ex-from-rp-reverse-only-atom
  (and (implies (syntaxp (atom term))
                (EQUAL (RP-EVL (RP-TRANS TERM) A)
                       (RP-EVL (RP-TRANS (EX-FROM-RP TERM)) A)))
       (implies (syntaxp (consp term))
                (EQUAL (RP-EVL (RP-TRANS (EX-FROM-RP TERM)) A)
                       (RP-EVL (RP-TRANS term) A)))))

(defthm decompress-s-c-correct-lemma1
  (implies (valid-sc term a)
           (and (b* (((mv pp ?valid)
                      (|CASE-MATCH-('c & ''nil pp ''nil)| term)))
                  (valid-sc pp a))))
  :hints (("Goal"
           :in-theory (e/d (|CASE-MATCH-('c & ''nil pp ''nil)|)
                           ()))))

(DEFTHM
  VALID-SC-CAr-cddDDR
  (IMPLIES (AND (CONSP TERM)
                (NOT (EQUAL (CAR TERM) 'IF))
                (NOT (EQUAL (CAR TERM) 'RP))
                (NOT (EQUAL (CAR TERM) 'QUOTE))
                (CONSP (CDR TERM))
                (CONSP (CDDR TERM))
                (CONSP (CDDdR TERM))
                (CONSP (CDDddR TERM))
                (VALID-SC TERM A))
           (VALID-SC (CAR (cddDDR TERM)) A))
  :HINTS
  (("Goal" :IN-THEORY (E/D (EX-FROM-RP IS-IF IS-RP) NIL))))

(defthm equivalence-of-two-f2
  (implies (and (equal (ifix a)
                       (ifix b))
                (equal (ifix x)
                       (ifix y)))
           (equal (equal (f2 (sum a x))
                         (f2 (sum b y)))
                  t))
  :hints (("Goal"
           :in-theory (e/d (sum)
                           (+-IS-SUM)))))

(defthmd equivalence-of-two-f2-2
  (implies (and (equal (sum a b)
                       (ifix x))
                (equal (ifix c)
                       (ifix y)))
           (equal (equal (f2 (sum a b c))
                         (f2 (sum x y)))
                  t))
  :hints (("Goal"
           :in-theory (e/d (sum)
                           (+-IS-SUM)))))

(defret
  decompress-s-c-correct
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (valid-sc term a))
           (and (valid-sc res-term a)
                (valid-sc coughed-term a)
                (equal (sum (rp-evlt res-term a)
                            (sum-list (rp-evlt coughed-term a)))
                       (ifix (rp-evlt term a)))
                (equal (sum (rp-evlt res-term a)
                            (sum-list (rp-evlt coughed-term a))
                            other)
                       (sum (rp-evlt term a)
                            other))))
  :fn decompress-s-c
  :hints (("Goal"
           :do-not-induct t
           :induct (decompress-s-c term :limit limit)
           :in-theory (e/d (decompress-s-c
                            equivalence-of-two-f2-2
                            |CASE-MATCH-('s & pp ('list single-c))|
                            |CASE-MATCH-('c & ''nil pp ''nil)|
                            |CASE-MATCH-('c & ''nil pp ('list single-c))|
                            f2-of-times2-reverse
                            RP-TRANS-LST-of-consp
                            rp-evlt-of-ex-from-rp-reverse-only-atom
;rp-evlt-of-ex-from-rp-reverse
                            )
                           (rp-evlt-of-ex-from-rp
                            f2-of-times2
                            (:REWRITE ACL2::O-P-O-INFP-CAR)
                            (:TYPE-PRESCRIPTION VALID-SC)
                            (:REWRITE VALID-SC-WHEN-SINGLE-C-P)
                            (:REWRITE EVL-OF-EXTRACT-FROM-RP-2)
                            (:REWRITE EX-FROM-SYNP-LEMMA1)
                            (:REWRITE RP-EVL-OF-VARIABLE)
                            (:DEFINITION EVAL-AND-ALL)
                            (:REWRITE SUM-OF-NEGATED-ELEMENTS)
                            (:REWRITE DEFAULT-CDR)
                            (:DEFINITION INCLUDE-FNC)
                            (:REWRITE NOT-INCLUDE-RP-MEANS-VALID-SC)
                            (:DEFINITION INCLUDE-FNC-SUBTERMS)
                            (:REWRITE DEFAULT-CAR)

                            rp-termp
                            rp-trans-lst)))))

(defthm times2-of---
  (equal (times2 (-- x))
         (-- (times2 x)))
  :hints (("Goal"
           :in-theory (e/d (times2 -- sum)
                           (+-IS-SUM)))))

(defthm dummy-sum-lemma1
  (and (equal (equal (sum x y a)
                     (sum k l a m))
              (equal (sum x y)
                     (sum k l m)))
       (equal (equal (sum x y a)
                     (sum l a m))
              (equal (sum x y)
                     (sum l m)))

       (equal (equal (sum x y a)
                     (sum a l))
              (equal (sum x y)
                     (sum l))))
  :hints (("Goal"
           :in-theory (e/d () ()))))

(defthm sum-of-nil
  (and (equal (sum a nil)
              (ifix a))
       (equal (sum nil a)
              (ifix a)))
  :hints (("Goal"
           :in-theory (e/d (sum)
                           (+-IS-SUM)))))

(defthm times2-plus-minus
  (and (equal (sum (times2 x) (-- x))
              (sum x))
       (equal (sum (-- x) (times2 x))
              (sum x))
       (equal (sum (times2 x) (-- x) rest)
              (sum x rest))
       (equal (sum (-- x) (times2 x) rest)
              (sum x rest))

       (equal (sum (-- (times2 x)) x)
              (sum (-- x)))
       (equal (sum x (-- (times2 x)))
              (sum (-- x)))
       (equal (sum (-- (times2 x)) x rest)
              (sum (-- x) rest))
       (equal (sum x (-- (times2 x)) rest)
              (sum (-- x) rest)))
  :hints (("Goal"
           :in-theory (e/d (times2 sum --) (+-IS-SUM)))))

(defthm valid-sc-subterms-of-nil
  (VALID-SC-SUBTERMS NIL A))

(defthmd SUM-LIST-EVAL-when-consp
  (implies (consp lst)
           (equal (sum-list-eval lst a)
                  (SUM (RP-EVLT (CAR LST) A)
                       (SUM-LIST-EVAL (CDR LST) A)))))

(defret
  light-compress-s-c$pass-pp-lst-correct
  (and
   (implies (and (valid-sc-subterms pp1-lst a)
                 (valid-sc-subterms pp2-lst a))
            (and (valid-sc-subterms res-pp1-lst a)
                 (valid-sc-subterms res-pp2-lst a)))
   (implies (and (valid-sc-subterms pp1-lst a)
                 (valid-sc-subterms pp2-lst a)
                 (rp-evl-meta-extract-global-facts :state state)
                 (mult-formula-checks state))
            (equal (sum (times2 (sum-list-eval res-pp1-lst a))
                        (sum-list-eval res-pp2-lst a))
                   (sum (times2 (sum-list-eval pp1-lst a))
                        (sum-list-eval pp2-lst a)))))
  :fn light-compress-s-c$pass-pp-lst
  :hints (("Goal"
           :do-not-induct t
           :expand ((:free (x y)
                           (valid-sc (cons x y) a)))
           :induct (light-compress-s-c$pass-pp-lst pp1-lst pp2-lst)
           :in-theory (e/d (light-compress-s-c$pass-pp-lst
                            SUM-LIST-EVAL-when-consp
                            abs-term)
                           (rp-trans-lst
                            (:DEFINITION SUM-LIST-EVAL)
                            (:REWRITE VALID-SC-WHEN-LIST-INSTANCE)
                            (:REWRITE ACL2::O-P-O-INFP-CAR)
                            (:REWRITE DEFAULT-CAR)
                            (:REWRITE NOT-INCLUDE-RP-MEANS-VALID-SC)
                            (:DEFINITION VALID-SC-SUBTERMS)
                            (:REWRITE DEFAULT-CDR)
                            (:DEFINITION INCLUDE-FNC)
                            (:REWRITE SUM-OF-NEGATED-ELEMENTS)
                            (:TYPE-PRESCRIPTION --)
                            (:TYPE-PRESCRIPTION BINARY-SUM)
                            (:TYPE-PRESCRIPTION VALID-SC-SUBTERMS)
                            (:REWRITE NOT-INCLUDE-RP-MEANS-VALID-SC-LST)
                            (:DEFINITION INCLUDE-FNC-SUBTERMS)
                            (:TYPE-PRESCRIPTION VALID-SC)
                            (:TYPE-PRESCRIPTION INCLUDE-FNC-SUBTERMS)
                            (:TYPE-PRESCRIPTION INCLUDE-FNC)
                            (:TYPE-PRESCRIPTION SUM-LIST-EVAL)
                            (:REWRITE EX-FROM-SYNP-LEMMA1)
                            (:REWRITE
                             RP-TRANS-IS-TERM-WHEN-LIST-IS-ABSENT)
                            (:REWRITE RP-EVL-OF-VARIABLE)
                            (:REWRITE VALID-SC-WHEN-SINGLE-C-P)
                            (:REWRITE
                             REGULAR-RP-EVL-OF_S_WHEN_MULT-FORMULA-CHECKS)
                            (:REWRITE
                             REGULAR-RP-EVL-OF_IFIX_WHEN_MULT-FORMULA-CHECKS)
                            (:REWRITE
                             REGULAR-RP-EVL-OF_C_WHEN_MULT-FORMULA-CHECKS)
                            (:REWRITE
                             REGULAR-RP-EVL-OF_C-RES_WHEN_MULT-FORMULA-CHECKS)
                            (:REWRITE
                             REGULAR-RP-EVL-OF_BIT-OF_WHEN_MULT-FORMULA-CHECKS)
                            (:REWRITE ACL2::FN-CHECK-DEF-NOT-QUOTE)
                            (:DEFINITION RP-EQUAL)
                            ;;(:DEFINITION SUM-LIST-EVAL)
                            (:DEFINITION VALID-SC)
                            (:TYPE-PRESCRIPTION TIMES2)
                            (:REWRITE EVL-OF-EXTRACT-FROM-RP-2)

;(:DEFINITION SUM-LIST-EVAL)
                            rp-trans
                            eval-and-all
                            is-falist)))))

(defthm list-to-lst-correct
  (and (equal (valid-sc-subterms (list-to-lst term) a)
              (valid-sc term a))
       (implies (and (rp-evl-meta-extract-global-facts :state state)
                     (mult-formula-checks state))
                (equal (sum-list-eval (list-to-lst term) a)
                       (sum-list (rp-evlt term a)))))
  :hints (("Goal"
           :in-theory (e/d (list-to-lst
                            is-rp)
                           ()))))

(defret
  light-compress-s-c$pass-pp-correct
  (and
   (implies (and (valid-sc pp1 a)
                 (valid-sc pp2 a))
            (and (valid-sc res-pp1 a)
                 (valid-sc res-pp2 a)))
   (implies (and (valid-sc pp1 a)
                 (valid-sc pp2 a)
                 (rp-evl-meta-extract-global-facts :state state)
                 (mult-formula-checks state))
            (equal (sum (times2 (sum-list (rp-evlt res-pp1 a)))
                        (sum-list (rp-evlt res-pp2 a)))
                   (sum (times2 (sum-list (rp-evlt pp1 a)))
                        (sum-list (rp-evlt pp2 a))))))
  :fn light-compress-s-c$pass-pp
  :hints (("Goal"
           :in-theory (e/d (light-compress-s-c$pass-pp) ()))))

(defret
  light-compress-s-c$pass-pp-correct-2
  (and
   (implies (and (valid-sc pp1 a)
                 (valid-sc pp2 a))
            (and (valid-sc res-pp1 a)
                 (valid-sc res-pp2 a)))
   (implies (and (valid-sc pp1 a)
                 (valid-sc pp2 a)
                 (rp-evl-meta-extract-global-facts :state state)
                 (mult-formula-checks state))
            (equal (sum (times2 (sum-list (rp-evlt res-pp1 a)))
                        (sum-list (rp-evlt res-pp2 a))
                        other)
                   (sum (times2 (sum-list (rp-evlt pp1 a)))
                        (sum-list (rp-evlt pp2 a))
                        other))))
  :fn light-compress-s-c$pass-pp
  :hints (("Goal"
           :in-theory (e/d () ()))))

(defthm reduce-same-args-of-m2
  (and (equal (equal (m2 (sum a x))
                     (m2 (sum b x)))
              (equal (m2 (sum a))
                     (m2 (sum b))))
       (equal (equal (m2 (sum x a))
                     (m2 (sum x b)))
              (equal (m2 (sum a))
                     (m2 (sum b)))))
  :hints (("Goal"
           :in-theory (e/d (sum
                            m2
                            (:REWRITE ACL2::EQUAL-OF-PREDICATES-REWRITE)
                            (:REWRITE ACL2::|(* x (+ y z))|)
                            (:REWRITE ACL2::|(equal (if a b c) x)|)
                            (:REWRITE ACL2::|(mod x 2)| . 1)
                            (:REWRITE ACL2::SUM-IS-EVEN . 1))
                           (+-IS-SUM

                            MOD2-IS-M2)))))

(defthm reduce-same-args-of-m2-2
  (and (equal (equal (m2 (sum a m x))
                     (m2 (sum b n x)))
              (equal (m2 (sum a m))
                     (m2 (sum b n))))
       (equal (equal (m2 (sum a m x p))
                     (m2 (sum b n x q)))
              (equal (m2 (sum a m p))
                     (m2 (sum b n q)))))
  :hints (("Goal"
           :use ((:instance reduce-same-args-of-m2
                            (a (sum a m))
                            (b (sum b n)))
                 (:instance reduce-same-args-of-m2
                            (a (sum a m p))
                            (b (sum b n q))))
           :in-theory (e/d () (reduce-same-args-of-m2)))))

(defthm abs-term-of---
  (equal (abs-term `(-- ,x))
         (mv x t))
  :hints (("Goal"
           :in-theory (e/d (abs-term) ()))))

(defret
  ligth-compress-s-c$fix-pp-lst$for-s-correct
  (and
   (implies (valid-sc-subterms pp1-lst a)
            (valid-sc-subterms res-pp1-lst a))
   (implies (and (valid-sc-subterms pp1-lst a)
                 (rp-evl-meta-extract-global-facts :state state)
                 (mult-formula-checks state))
            (and (equal (m2 (sum (sum-list-eval res-pp1-lst a) rest))
                        (m2 (sum (sum-list-eval pp1-lst a) rest)))
                 (equal (m2 (sum-list-eval res-pp1-lst a))
                        (m2 (sum (sum-list-eval pp1-lst a))))
                 #|(equal (sum-list-eval (abs-lst res-pp1-lst) a)
                 (sum (sum-list-eval (abs-lst pp1-lst) a)))||#)))
  :fn ligth-compress-s-c$fix-pp-lst$for-s
  :hints (("Goal"
           :do-not-induct t
           :induct (ligth-compress-s-c$fix-pp-lst$for-s pp1-lst pp2-lst)
           :in-theory (e/d (ligth-compress-s-c$fix-pp-lst$for-s) ()))))

(defret
  light-compress-s-c$fix-pp$for-s-correct
  (and
   (implies (valid-sc pp1 a)
            (valid-sc res-pp1 a))
   (implies (and (valid-sc pp1 a)
                 (rp-evl-meta-extract-global-facts :state state)
                 (mult-formula-checks state))
            (and (equal (m2 (sum (sum-list (rp-evlt res-pp1 a)) rest))
                        (m2 (sum (sum-list (rp-evlt pp1 a)) rest)))
                 (equal (m2 (sum-list (rp-evlt res-pp1 a)))
                        (m2 (sum-list (rp-evlt pp1 a))))
                 #|(equal (sum-list-eval (abs-lst res-pp1-lst) a)
                 (sum (sum-list-eval (abs-lst pp1-lst) a)))||#)))
  :fn light-compress-s-c$fix-pp$for-s
  :hints (("Goal"
           :do-not-induct t
           :in-theory (e/d (light-compress-s-c$fix-pp$for-s) ()))))

(defthmd rp-evlt-of-ex-from-rp-reverse-only-atom-and-car
  (AND (IMPLIES (SYNTAXP (or (ATOM TERM)
                             (and (equal (car term) 'car)
                                  (not (include-fnc term 'ex-from-rp )))))
                (EQUAL (RP-EVL (RP-TRANS TERM) A)
                       (RP-EVL (RP-TRANS (EX-FROM-RP TERM))
                               A)))
       (IMPLIES (SYNTAXP (not (or (ATOM TERM)
                                  (and (equal (car term) 'car)
                                       (not (include-fnc term 'ex-from-rp ))))))
                (EQUAL (RP-EVL (RP-TRANS (EX-FROM-RP TERM)) A)
                       (RP-EVL (RP-TRANS TERM) A)))))

(defret light-compress-s-c-aux-correct
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (valid-sc pp a)
                (valid-sc c-arg a))
           (and (valid-sc pp-res a)
                (valid-sc c-arg-res a)
                (equal (sum (sum-list (rp-evlt pp-res a))
                            (sum-list (rp-evlt c-arg-res a)))
                       (sum (sum-list (rp-evlt pp a))
                            (sum-list (rp-evlt c-arg a))))))
  :fn light-compress-s-c-aux
  :hints (("Goal"
           :do-not-induct t
           :induct (light-compress-s-c-aux pp c-arg)
           :expand ((:free (x) (single-c-p x))
                    (:free (rest) (VALID-SC (cons 'c rest) a))
                    (:free (rest) (VALID-SC (cons 'list rest) a)))
           :in-theory (e/d (light-compress-s-c-aux
;RP-TRANS-LST-of-consp
                            f2-of-times2-reverse
;single-c-p
                            rp-evlt-of-ex-from-rp-reverse-only-atom)
                           (rp-evlt-of-ex-from-rp
                            ex-from-rp
                            f2-of-times2
                            valid-sc)))))

(defret light-compress-s-c-correct
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (force (valid-sc term a)))
           (and (equal (rp-evlt res-term a)
                       (rp-evlt term a))
                (valid-sc res-term a)))
  :fn light-COMPRESS-S-C
  :hints (("Goal"
           :do-not-induct t
           :expand ((:free (rest) (VALID-SC (cons 'c rest) a)))
           :in-theory (e/d (light-compress-s-C
                            rp-trans-lst-of-consp
                            rp-evlt-of-ex-from-rp-reverse-only-atom)
                           (ex-from-rp
                            rp-evlt-of-ex-from-rp
                            )))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; c-pattern2-reduce and create-c-instance lemmas

(defthm minus-of-sum
  (equal (-- (sum a b))
         (sum (-- a) (-- b)))
  :hints (("Goal"
           :in-theory (e/d (sum --)
                           (+-IS-SUM)))))

(defthm minus-of-minus
  (equal (-- (-- a))
         (ifix a))
  :hints (("Goal"
           :in-theory (e/d (--) ()))))

(defret negate-lst-aux-correct
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (valid-sc-subterms lst a))
           (and (valid-sc-subterms negated-lst a)
                (equal (sum-list-eval negated-lst a)
                       (-- (sum-list-eval lst a)))))
  :fn negate-lst-aux
  :hints (("Goal"
           :do-not-induct t
           :induct (negate-lst-aux lst)
           :in-theory (e/d (negate-lst-aux
                            rp-evlt-of-ex-from-rp-reverse-only-atom-and-car)
                           (rp-evlt-of-ex-from-rp)))))

(defret negate-lst-correct-
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (valid-sc-subterms lst a))
           (and (valid-sc-subterms negated-lst a)
                (equal (sum-list-eval negated-lst a)
                       (if enabled
                           (-- (sum-list-eval lst a))
                         (sum-list-eval lst a)))))
  :fn negate-lst
  :hints (("Goal"
           :do-not-induct t
           :in-theory (e/d (negate-lst
                            rp-evlt-of-ex-from-rp-reverse-only-atom-and-car)
                           (rp-evlt-of-ex-from-rp)))))

(defret negate-list-instance-correct
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (force (valid-sc term a)))
           (and (valid-sc res a)
                (equal (sum-list (rp-evlt res a))
                       (if enabled
                           (-- (sum-list (rp-evlt term a)))
                         (sum-list (rp-evlt term a))))))
  :fn negate-list-instance
  :hints (("Goal"
           :do-not-induct t
           :in-theory (e/d (negate-list-instance
                            NEGATE-LST)
                           ()))))

(defthmd f2-of-minus-reverse
  (equal (sum (-- a) (f2 (sum a b)))
         (f2 (sum (-- a) b))))

(defthm c-pattern2-reduce-correct-lemma
  (b* (((mv max min valid)
        (get-max-min-val term)))
    (implies (and valid
                  (rp-evl-meta-extract-global-facts :state state)
                  (mult-formula-checks state)
                  (valid-sc term a)
                  (equal max 0)
                  (equal min -1))
             (equal (f2 (rp-evlt term a))
                    (rp-evlt term a))))
  :hints (("Goal"
           :use ((:instance get-max-min-val-correct))
           :cases ((= (RP-EVLT TERM A) 0)
                   (= (RP-EVLT TERM A) -1))
           :in-theory (e/d (rw-dir2)
                           (get-max-min-val-correct
                            rw-dir1)))))

(defret c-pattern2-reduce-correct
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (valid-sc s a)
                (valid-sc pp a)
                (valid-sc c a))
           (and (valid-sc s-res a)
                (valid-sc pp-res a)
                (valid-sc c-res a)
                (equal (f2 (sum (sum-list (rp-evlt s-res a))
                                (sum-list (rp-evlt pp-res a))
                                (sum-list (rp-evlt c-res a))))
                       (f2 (sum (sum-list (rp-evlt s a))
                                (sum-list (rp-evlt pp a))
                                (sum-list (rp-evlt c a)))))))
  :fn c-pattern2-reduce
  :hints (("Goal"
           :do-not-induct t
           :use ((:instance decompress-s-c-correct
                            (term (CADR
                                   (CAR (CDDDDR (LIGHT-COMPRESS-S-C (LIST 'C
                                                                          ''0
                                                                          ''NIL
                                                                          (NEGATE-LIST-INSTANCE PP T)
                                                                          C))))))
                            (limit 1073741824)
                            (other (SUM-LIST (RP-EVLT PP A))))
                 (:instance pp-sum-merge-correct
                            (term1 pp)
                            (term2 (MV-NTH
                                    1
                                    (DECOMPRESS-S-C
                                     (CADR
                                      (CAR (CDDDDR (LIGHT-COMPRESS-S-C (LIST 'C
                                                                             ''0
                                                                             ''NIL
                                                                             (NEGATE-LIST-INSTANCE PP T)
                                                                             C)))))
                                     :LIMIT 1073741824))))
                 (:instance light-compress-s-c-correct
                            (term (LIST 'C
                                        ''0
                                        ''NIL
                                        (NEGATE-LIST-INSTANCE PP T)
                                        C)))
                 )
           :expand ((VALID-SC ''NIL A)
                    (:free (x) (valid-sc (cons 'c x) a)))
           ;;:case-split-limitations (10 1)
           :do-not '()
           :in-theory (e/d (c-pattern2-reduce
                            rp-trans-lst-of-consp
                            ;;f2-of-minus-reverse
                            )
                           (ex-from-rp
                            (:REWRITE ACL2::O-P-O-INFP-CAR)
                            (:TYPE-PRESCRIPTION BINARY-SUM)
                            (:TYPE-PRESCRIPTION VALID-SC)
                            (:REWRITE GET-MAX-MIN-VAL-CORRECT)
                            (:TYPE-PRESCRIPTION --)
                            (:DEFINITION TRANS-LIST)
                            (:REWRITE
                             REGULAR-RP-EVL-OF_C-RES_WHEN_MULT-FORMULA-CHECKS)
                            is-rp
;is-falist
                            ;;(:DEFINITION VALID-SC)
                            (:DEFINITION EVAL-AND-ALL)
                            (:REWRITE DEFAULT-CDR)
;(:DEFINITION RP-TRANS)
                            (:DEFINITION INCLUDE-FNC)
                            (:REWRITE NOT-INCLUDE-RP-MEANS-VALID-SC)
                            (:REWRITE DEFAULT-CAR)
                            (:TYPE-PRESCRIPTION O<)
                            ;;f2-of-minus
                            pp-sum-merge-correct
                            decompress-s-c-correct
                            light-compress-s-c-correct
                            )))))

(defthm rp-evlt-of-quoted
  (equal (rp-evlt (list 'quote x) a)
         x))

(defret create-c-instance-is-correct
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (valid-sc s a)
                (valid-sc pp a)
                (valid-sc c a))
           (and (equal (rp-evlt c-res a)
                       (f2 (sum (sum-list (rp-evlt s a))
                                (sum-list (rp-evlt pp a))
                                (sum-list (rp-evlt c a)))))
                (valid-sc c-res a)))
  :fn create-c-instance
  :hints (("Goal"
           :do-not-induct t
           :use ((:instance c-pattern2-reduce-correct))
           :expand ((:free (x) (valid-sc (cons 'c x) a))
                    (:free (x) (valid-sc (cons 'quote x) a)))
           :in-theory (e/d (create-c-instance
                            rp-trans-lst-of-consp)
                           (c-pattern2-reduce-correct
                            (:REWRITE SUM-OF-NEGATED-ELEMENTS)
                            (:REWRITE DEFAULT-CDR)
                            (:REWRITE DEFAULT-CAR)
                            (:TYPE-PRESCRIPTION VALID-SC)
                            (:DEFINITION TRANS-LIST)
                            (:REWRITE EX-FROM-SYNP-LEMMA1)
                            (:TYPE-PRESCRIPTION F2)
                            (:DEFINITION IS-SYNP$INLINE)
                            TO-LIST*-SUM-EVAL
                            (:TYPE-PRESCRIPTION TRANS-LIST)
                            (:REWRITE RP-EVL-OF-VARIABLE)
                            (:REWRITE
                             REGULAR-RP-EVL-OF_C-RES_WHEN_MULT-FORMULA-CHECKS)
;RP-TRANS
                            INCLUDE-FNC
                            RP-TRANS-LST
                            VALID-SC
                            )))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; create-s-instance and s-pattern3-reduce lemmas

(defthmd s-pattern3-reduce-correct-lemma
  (implies (and (<= val 0)
                (>= val -1))
           (equal (m2 val) (-- val)))
  :hints (("Goal"
           :cases ((= val 0)
                   (integerp val)
                   (= val -1))
           :in-theory (e/d (rw-dir2
                            (:REWRITE ACL2::|(- (- x))|)
                            (:REWRITE ACL2::|(equal (if a b c) x)|)
                            (:REWRITE ACL2::|(equal c (- x))|)
                            (:REWRITE ACL2::|(mod x 2)| . 1)
                            (:REWRITE ACL2::DEFAULT-LESS-THAN-1)
                            (:REWRITE ACL2::DEFAULT-LESS-THAN-2)
                            (:REWRITE IFIX-OPENER)
                            m2
                            ifix
                            --)
                           (rw-dir1
                            mod2-is-m2)))))

(defret s-pattern3-reduce-correct
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (valid-sc pp a)
                (valid-sc c a)
                reducedp)
           (and (equal (rp-evlt reduced a)
                       (m2 (sum (sum-list (rp-evlt pp a))
                                (sum-list (rp-evlt c a)))))))
  :fn s-pattern3-reduce
  :hints (("Goal"
           :do-not-induct t
           :expand (#|(LIGHT-COMPRESS-S-C (LIST 'S ''0 PP C))||#
                    (EX-FROM-RP (LIST 'S ''0 ''NIL C))
                    (VALID-SC (LIST 'S ''0 PP C) A))
           :use ((:instance
                  light-compress-s-c-correct
                  (term (LIST 'S ''0 PP C)))
                 (:instance
                  decompress-s-c-correct
                  (term (CADR (CADDDR (LIGHT-COMPRESS-S-C (LIST 'S ''0 PP
                                                                C)))))
                  (limit 1073741824))
                 (:instance get-max-min-val-correct
                            (term (CADR (CADDDR (LIGHT-COMPRESS-S-C (LIST 'S ''0 PP C))))))
                 (:instance
                  s-pattern3-reduce-correct-lemma
                  (val (RP-EVLT (CADR (CADDDR (LIGHT-COMPRESS-S-C (LIST 'S ''0 PP C))))
                                A))))
           :in-theory (e/d (s-pattern3-reduce
                            rp-trans-lst-of-consp
                            c-res
                            is-rp)
                           (light-compress-s-c-correct
                            s-pattern3-reduce-correct-lemma
                            get-max-min-val-correct
                            (:REWRITE DEFAULT-CDR)
                            (:TYPE-PRESCRIPTION O<)
                            (:REWRITE DEFAULT-CAR)
                            (:DEFINITION TRANS-LIST)
                            (:TYPE-PRESCRIPTION VALID-SC)
                            (:TYPE-PRESCRIPTION BINARY-SUM)
                            (:DEFINITION INCLUDE-FNC)
                            (:REWRITE EX-FROM-SYNP-LEMMA1)
                            (:DEFINITION IS-SYNP$INLINE)
                            (:REWRITE
                             RP-TRANS-IS-TERM-WHEN-LIST-IS-ABSENT)
                            (:REWRITE ACL2::O-P-O-INFP-CAR)
                            (:REWRITE SUM-OF-NEGATED-ELEMENTS)
                            (:TYPE-PRESCRIPTION RP-TRANS-LST)
                            (:TYPE-PRESCRIPTION --)
                            (:TYPE-PRESCRIPTION M2)
                            (:TYPE-PRESCRIPTION LTE)
                            (:TYPE-PRESCRIPTION MULT-FORMULA-CHECKS)

                            ;;(:DEFINITION RP-TRANS)

                            valid-sc
                            (:TYPE-PRESCRIPTION LIGHT-COMPRESS-S-C)
                            decompress-s-c-correct
                            ex-from-rp)))))

(local
 (defthm is-rp-of-bitp
   (is-rp `(rp 'bitp ,x))
   :hints (("Goal"
            :in-theory (e/d (is-rp) ())))))

(defret s-pattern3-reduce-correct-valid-sc
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (valid-sc pp a)
                (valid-sc c a)
                reducedp)
           (valid-sc reduced a))
  :fn s-pattern3-reduce
  :hints (("Goal"
           :use ((:instance s-pattern3-reduce-correct))
           :expand ((:free (x) (valid-sc (cons 'c-res x) a))
                    (:free (x) (valid-sc (cons 'list x) a))
                    (:free (x) (valid-sc (cons '-- x) a)))
           :in-theory (e/d (s-pattern3-reduce
                            valid-sc-single-step
                            is-rp
                            )
                           (s-pattern3-reduce-correct
                            valid-sc
                            )))))
(defthmd m2-of-bitp
  (implies (bitp x)
           (equal (m2 x)
                  x))
  :hints (("Goal"
           :in-theory (e/d (bitp) ()))))

(defret create-s-instance-correct
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (valid-sc pp a)
                (valid-sc c a))
           (and
            (equal (rp-evlt res a)
                   (m2 (sum (sum-list (rp-evlt pp a))
                            (sum-list (rp-evlt c a)))))
            (valid-sc res a)))
  :fn create-s-instance
  :hints (("Goal"
           :do-not-induct t
           :in-theory (e/d (create-s-instance
                            m2-of-bitp
                            valid-sc-single-step
                            rp-trans-lst-of-consp
                            is-rp)
                           (
                            INCLUDE-FNC)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; single-c-try-merge-params

(defret swap-c-lsts-correct
  (and
   (implies (and (rp-evl-meta-extract-global-facts :state state)
                 (mult-formula-checks state))
            (equal (sum (sum-list-eval res1 a)
                        (sum-list-eval res2 a))
                   (sum (sum-list-eval c1-lst a)
                        (sum-list-eval c2-lst a))))
   (implies (and (valid-sc-subterms c1-lst a)
                 (valid-sc-subterms c2-lst a))
            (and (valid-sc-subterms res1 a)
                 (valid-sc-subterms res2 a))))
  :fn swap-c-lsts
  :hints (("Goal"
           :in-theory (e/d (swap-c-lsts)
                           (valid-sc
                            valid-sc-subterms)))))

(defthm m2-of-rp-evlt-ex-from-rp/--
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state))
           (and (equal (m2 (sum (RP-EVLt (EX-FROM-RP/-- e) A)
                                other))
                       (m2 (sum (RP-EVLT e A)
                                other)))
                (equal (m2 (sum (RP-EVL (EX-FROM-RP/-- e) A)
                                other))
                       (m2 (sum (RP-EVL e A)
                                other)))))
  :hints (("Goal"
           :induct (EX-FROM-RP/-- e)
           :do-not-induct t
           :in-theory (e/d (EX-FROM-RP/-- is-rp --.p)
                           (EX-FROM-RP-LEMMA1)))))

(defthm light-s-of-s-fix-lst-correct-lemma1
  (implies (and (EQUAL (EX-FROM-RP/-- e) ''NIL)
                (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state))
           (EQUAL (M2 (RP-EVLT e A)) 0))
  :hints (("Goal"
           :induct (EX-FROM-RP/-- e)
           :do-not-induct t
           :in-theory (e/d (EX-FROM-RP/-- --.p is-rp) (EX-FROM-RP-LEMMA1)))))

(defthm m2-sums-equivalence
  (implies (and (equal (m2 x) (m2 y))
                (equal (m2 a) (m2 b)))
           (equal (m2 (sum x a))
                  (m2 (sum y b))))
  :hints (("Goal"
           :in-theory (e/d (m2 sum
                               (:REWRITE ACL2::|(* x (+ y z))|)
                               (:REWRITE ACL2::|(+ y x)|)
                               (:REWRITE ACL2::|(equal (if a b c) x)|)
                               (:REWRITE ACL2::|(mod x 2)| . 1)
                               (:REWRITE IFIX-OPENER)
                               (:REWRITE ACL2::SUM-IS-EVEN . 2))
                           (mod2-is-m2
                            +-IS-SUM)))))

(defthm m2-sums-dummy-lemma-1
  (implies (and (equal (m2 (sum x y)) (m2 z))
                (equal (m2 (sum k l)) (m2 (sum m n))))
           (equal (equal (m2 (sum x y k l))
                         (m2 (sum m z n)))
                  t))
  :hints (("Goal"
           :use ((:instance m2-sums-equivalence
                            (x (sum x y))
                            (y z)
                            (a (sum k l))
                            (b (sum m n))))
           :in-theory (e/d ( )
                           ()))))

(defret light-s-of-s-fix-lst-correct
  (and
   (implies (and (rp-evl-meta-extract-global-facts :state state)
                 (mult-formula-checks state))
            (equal (m2 (sum (sum-list-eval pp-res-lst a)
                            (sum-list-eval c-res-lst a)))
                   (m2 (sum (sum-list-eval s-lst a)
                            (sum-list-eval c-lst a))))))
  :fn light-s-of-s-fix-lst
  :hints (("Goal"
           :do-not-induct t
           :induct (light-s-of-s-fix-lst s-lst c-lst)
           :expand ((:free (x) (nth 3 x))
                    (:free (x) (nth 2 x))
                    (:free (x) (nth 1 x))
                    (:free (x) (nth 0 x)))
           :in-theory (e/d (light-s-of-s-fix-lst
                            is-rp)
                           (eval-and-all
                            rp-trans
                            RP-TRANS-IS-TERM-WHEN-LIST-IS-ABSENT
                            not-include-rp-means-valid-sc
                            not-include-rp-means-valid-sc-lst)))
          ("Subgoal *1/2"
           :use ((:instance m2-of-rp-evlt-ex-from-rp/--
                            (e (CAR S-LST))
                            (other (sum (SUM-LIST-EVAL (MV-NTH 0
                                                               (LIGHT-S-OF-S-FIX-LST (CDR S-LST)
                                                                                     C-LST))
                                                       A)
                                        (SUM-LIST-EVAL (MV-NTH 1
                                                               (LIGHT-S-OF-S-FIX-LST (CDR S-LST)
                                                                                     C-LST))
                                                       A))))))))

(defthm valid-sc-ex-from-rp/--
  (implies (valid-sc term a)
           (valid-sc (EX-FROM-RP/-- term) a))
  :hints (("Goal"
           :induct (EX-FROM-RP/-- term)
           :do-not-induct t
           :in-theory (e/d (EX-FROM-RP/--
                            valid-sc
                            valid-sc-single-step
                            )
                           ()))))

(defret light-s-of-s-fix-lst-correct-valid-sc-subterms
  (implies (and (valid-sc-subterms s-lst a)
                (valid-sc-subterms c-lst a)) ;
           (and (valid-sc-subterms pp-res-lst a) ;
                (valid-sc-subterms c-res-lst a)))
  :fn light-s-of-s-fix-lst
  :hints (("Goal"
           :do-not-induct t
           :induct (light-s-of-s-fix-lst s-lst c-lst)
           :expand ((:free (x) (nth 3 x))
                    (:free (x) (nth 2 x))
                    (:free (x) (nth 1 x))
                    (:free (x) (nth 0 x)))
           :in-theory (e/d (light-s-of-s-fix-lst
                            is-rp)
                           (eval-and-all
                            rp-trans
                            RP-TRANS-IS-TERM-WHEN-LIST-IS-ABSENT
                            not-include-rp-means-valid-sc
                            not-include-rp-means-valid-sc-lst)))))

(defthm m2-sums-dummy-lemma-2
  (implies (and (equal (m2 (sum x y)) (m2 (sum m n))))
           (equal (equal (m2 (sum x y a))
                         (m2 (sum m a n)))
                  t))
  :hints (("Goal"
           :in-theory (e/d ( )
                           (m2-sums-equivalence)))))

(defthm light-s-of-s-fix-correct-lemma
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (NOT (LIST-TO-LST S))
                (mult-formula-checks state))
           (equal (SUM-LIST (RP-EVLT S A))
                  0))
  :hints (("Goal"
           :in-theory (e/d (LIST-TO-LST) ()))))

(defret light-s-of-s-fix-correct
  (and
   (implies (and (rp-evl-meta-extract-global-facts :state state)
                 (mult-formula-checks state))
            (equal (m2 (sum (sum-list (rp-evlt pp-res a))
                            (sum-list-eval c-res-lst a)))
                   (m2 (sum (sum-list (rp-evlt s a))
                            (sum-list (rp-evlt pp a))
                            (sum-list-eval c-lst a)))))
   (implies (and (valid-sc s a)
                 (valid-sc pp a)
                 (valid-sc-subterms c-lst a))
            (and (valid-sc pp-res a)
                 (valid-sc-subterms c-res-lst a))))
  :fn light-s-of-s-fix
  :hints (("Goal"
           :do-not-induct t
           :use ((:instance light-s-of-s-fix-lst-correct
                            (s-lst (LIST-TO-LST S))))
           :in-theory (e/d (light-s-of-s-fix)
                           (light-s-of-s-fix-lst-correct)))))

#|(local
 (use-arith-5 t))||#

#|(defthm dummy-f2-lemma1
  (implies (equal (f2 a) (sum (f2 b) c))
           (equal (f2 (sum a x)) (sum (f2 (sum b x)) c)))
  :hints (("Goal"
           :in-theory (e/d (f2 rw-dir2 sum) (+-IS-SUM rw-dir1)))))||#

(defun f2x2 (args)
  (sum (-- (m2 args)) args))

#|(defthm dummy-clear-equals-from-sum-lemma
  (equal (equal (sum x1 x2 x3 x4 x5 x6 a) (sum y1 y2 y3 y4 y5 y6 a y7))
         (equal (sum x1 x2 x3 x4 x5 x6) (sum y1 y2 y3 y4 y5 y6 y7))))||#

;; (defthm dummy-sum-lemma
;;   (implies (equal (sum (m2 a) (-- (m2 b)) others) 0)
;;            (equal (sum (m2 (sum a) (-- (m2 b)) others) 0)

(defthmd single-c-try-merge-params-correct-dummy-lemma
  (implies (and (equal (sum a x y b) 0)
                (equal (sum x y) (sum x2 y2)))
           (equal (sum x2 a y2 b) 0)))

(defthmd move-sum-over-to-the-same-side
  (and (equal (equal (sum a b) (sum c))
              (equal (sum a b (-- c)) 0))
       (equal (equal (sum a b) (sum c d))
              (equal (sum a b (-- c) (-- d)) 0)))
  :hints (("Goal"
           :in-theory (e/d (sum ifix --) (+-IS-SUM)))))

(defthmd single-c-try-merge-params-correct-dummy-lemma-2
  (implies (equal (m2 (sum a b)) (m2 (sum x y z)))
           (equal (equal (sum (m2 (sum a b w))
                              (-- (m2 (sum x y z w))))
                         0)
                  t))
  :hints (("Goal"
           :use ((:instance m2-of-m2
                            (x (sum a b))
                            (y w)))
           :in-theory (e/d (-- (:REWRITE ACL2::|(- (- x))|)
                               (:REWRITE ACL2::|(integerp (- x))|)
                               (:REWRITE IFIX-OF-M2)
                               (:REWRITE IFIX-OPENER)
                               (:REWRITE INTEGERP-M2-F2-D2)
                               (:REWRITE S-FIX-PP-ARGS-AUX-CORRECT-DUMMY-LEMMA1)
                               (:REWRITE SUM-ASSOC)
                               (:REWRITE SUM-COMM-1)
                               (:REWRITE SUM-COMM-2)
                               (:REWRITE SUM-OF-NEGATED-ELEMENTS))
                           (+-IS-SUM m2-of-m2)))))

(defthmd m2-of-oddp
  (implies (and (oddp a)
                (case-split (integerp a))
                (syntaxp (atom a)))
           (equal (m2 (sum a b))
                  (m2 (sum 1 b))))
  :hints (("Goal"
           :in-theory (e/d (m2
                            --
                            sum
                            (:REWRITE ACL2::|(* a (/ a) b)|)
                            (:REWRITE ACL2::|(* x (+ y z))|)
                            (:REWRITE ACL2::|(* y x)|)
                            (:REWRITE ACL2::|(mod x 2)| . 1)
                            (:REWRITE ACL2::EVEN-AND-ODD-ALTERNATE)
                            (:REWRITE IFIX-OPENER)
                            (:REWRITE ACL2::SUM-IS-EVEN . 1))
                           (mod2-is-m2 +-IS-SUM)))))

(defthmd m2-of-evenp
  (implies (and (evenp a))
           (equal (m2 (sum a b))
                  (m2 b)))
  :hints (("Goal"
           :cases ((integerp a))
           :in-theory (e/d (m2
                            ifix
                            (:REWRITE ACL2::|(mod x 2)| . 1)
                            --
                            sum
                            )
                           (mod2-is-m2 +-IS-SUM)))))

(defthmd sum-of-not-integerp
  (implies (not (integerp a))
           (equal (sum a x1)
                  (ifix x1)))
  :hints (("Goal"
           :in-theory (e/d (ifix sum)
                           (+-IS-SUM)))))

(defthmd m2-of-sum-1-other
  (equal (m2 (sum 1 x1))
         (sum 1 (-- (m2 x1))))
  :hints (("Goal"
           :in-theory (e/d (m2
                            --
                            sum
                            (:REWRITE ACL2::|(* a (/ a) b)|)
                            (:REWRITE ACL2::|(* x (+ y z))|)
                            (:REWRITE ACL2::|(+ x (if a b c))|)
                            (:REWRITE ACL2::|(- (if a b c))|)
                            (:REWRITE ACL2::EVEN-AND-ODD-ALTERNATE)
                            (:REWRITE IFIX-OPENER)
                            (:REWRITE ACL2::|(mod x 2)| . 1))
                           (+-IS-SUM mod2-is-m2)))))

(defthmd cancel-m2-args
  (and (equal (sum (m2 (sum a x1))
                   (-- (m2 (sum a x2)))
                   x3)
              (if (or (evenp a)
                      (not (integerp a)))
                  (sum (m2 x1)
                       (-- (m2 x2))
                       x3)
                (sum (-- (m2 x1))
                     (m2 x2)
                     x3))))
  :hints (("Goal"
           :cases ((evenp a))
           :in-theory (e/d (m2-of-oddp
                            m2-of-sum-1-other
                            sum-of-not-integerp
                            m2-of-evenp)
                           (+-IS-SUM
                            mod2-is-m2
                            evenp)))))

#|(defthmd single-c-try-merge-params-correct-lemma-3
  (equal (sum (m2 (sum a b x1))
              (-- (m2 (sum x2 x3 a b x4)))
              x5)

         (sum (m2 x1)
              (-- (m2 (sum x2 x3 x4)))
              x5)))||#

(defret single-c-try-merge-params-aux-correct
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (VALID-SC S-ARG A)
                (VALID-SC pp-arg A)
                (valid-sc-subterms c-arg-lst A)
                (valid-sc-subterms s-lst A)
                success)
           (equal (f2x2 (sum (sum-list (rp-evlt s-arg a))
                             (sum-list (rp-evlt pp-arg a))
                             (sum-list-eval c-arg-lst a)
                             x))
                  (sum (f2x2 (sum (rp-evlt cur-s a) x))
                       (f2x2 (sum (sum-list (rp-evlt s-arg a))
                                  (sum-list (rp-evlt pp-arg a))
                                  (sum-list-eval c-arg-lst a))))))
  :fn single-c-try-merge-params-aux
  :hints (("Goal"
           :use ((:instance light-s-of-s-fix-correct
                            (s s-arg)
                            (pp pp-arg)
                            (c-lst c-arg-lst)))
           :do-not-induct t
           :in-theory (e/d (single-c-try-merge-params-aux
                            single-c-try-merge-params-correct-dummy-lemma
                            move-sum-over-to-the-same-side
                            single-c-try-merge-params-correct-dummy-lemma-2
;single-c-try-merge-params-correct-lemma-3
                            move-sum-over-to-the-same-side
                            rp-evlt-of-ex-from-rp-reverse-only-atom-and-car)
                           (rp-termp
                            valid-sc
                            eval-and-all
                            DUMMY-SUM-CANCEL-LEMMA1
                            rp-evlt-of-ex-from-rp

                            SUM-OF-NEGATED-ELEMENTS
                            light-s-of-s-fix-correct
                            include-fnc
                            evenp)))))

(define single-c-try-merge-params$for-proof  (s-lst other-s-lst c-hash-code s-arg pp-arg
                                                    c-arg-lst)
  :returns (mv (updated-s-lst)
               (success))
  :measure (acl2-count s-lst)
  :verify-guards nil
  (b* (((when (atom s-lst))
        (mv other-s-lst nil))
       ((when (single-c-try-merge-params-aux (car s-lst) c-hash-code
                                             s-arg pp-arg c-arg-lst))
        (mv (append other-s-lst (cdr s-lst)) t))
       ((mv rest-s-lst success)
        (single-c-try-merge-params$for-proof (cdr s-lst)
                                             (append other-s-lst (list (car s-lst)))
                                             c-hash-code s-arg pp-arg
                                             c-arg-lst))
       ((when success)
        (mv rest-s-lst t)))
    (mv (append other-s-lst s-lst) nil)))

(defthm single-c-try-merge-params$for-proof-lemma
  (implies (and (true-listp s-lst)
                (true-listp other-s-lst))
           (b* (((mv lst1 success1)
                 (single-c-try-merge-params$for-proof s-lst other-s-lst c-hash-code s-arg pp-arg
                                                      c-arg-lst))
                ((mv lst2 success2)
                 (single-c-try-merge-params s-lst c-hash-code s-arg pp-arg
                                            c-arg-lst)))
             (and (equal success1 success2)
                  (equal lst1 (append other-s-lst lst2)))))
  :hints (("Goal"
           :induct (single-c-try-merge-params$for-proof s-lst other-s-lst c-hash-code s-arg pp-arg
                                                        c-arg-lst)
           :do-not-induct t
           :in-theory (e/d (single-c-try-merge-params$for-proof
                            single-c-try-merge-params)
                           ()))))

(defthm sum-list-eval-of-append
  (equal (sum-list-eval (append x y) a)
         (sum (sum-list-eval x a)
              (sum-list-eval y a)))
  :hints (("Goal"
           :in-theory (e/d (sum-list-eval) ()))))

(defret single-c-try-merge-params$for-proofs-correct
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (VALID-SC S-ARG A)
                (VALID-SC pp-arg A)
                (valid-sc-subterms c-arg-lst A)
                (valid-sc-subterms s-lst A)
                (true-listp s-lst)
                success)
           (equal (f2x2 (sum (sum-list-eval updated-s-lst a)
                             (sum-list (rp-evlt s-arg a))
                             (sum-list (rp-evlt pp-arg a))
                             (sum-list-eval c-arg-lst a)
                             x))
                  (sum (f2x2 (sum (sum-list-eval s-lst a)
                                  (sum-list-eval other-s-lst a)
                                  x))
                       (f2x2 (sum (sum-list (rp-evlt s-arg a))
                                  (sum-list (rp-evlt pp-arg a))
                                  (sum-list-eval c-arg-lst a))))))
  :fn single-c-try-merge-params$for-proof
  :hints (("Goal"
           :do-not-induct t
           :induct (single-c-try-merge-params$for-proof s-lst other-s-lst c-hash-code s-arg pp-arg c-arg-lst)
           :in-theory (e/d (single-c-try-merge-params
                            single-c-try-merge-params$for-proof
                            single-c-try-merge-params-correct-dummy-lemma
                            single-c-try-merge-params-correct-dummy-lemma-2
                            move-sum-over-to-the-same-side
                            sum-of-not-integerp
                            rp-evlt-of-ex-from-rp-reverse-only-atom-and-car)
                           (rp-termp
                            single-c-try-merge-params-aux-correct
                            valid-sc
                            eval-and-all
                            DUMMY-SUM-CANCEL-LEMMA1
                            rp-evlt-of-ex-from-rp
                            single-c-try-merge-params$for-proof-lemma
                            SUM-OF-NEGATED-ELEMENTS
                            light-s-of-s-fix-correct
                            include-fnc
                            evenp)))
          ("Subgoal *1/2"
           :use ((:instance single-c-try-merge-params-aux-correct
                            (x (sum (SUM-LIST-EVAL OTHER-S-LST A)
                                    (SUM-LIST-EVAL (CDR S-LST) A)
                                    X))
                            (cur-s (car s-lst)))))))

(defret single-c-try-merge-params-correct
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (VALID-SC S-ARG A)
                (VALID-SC pp-arg A)
                (valid-sc-subterms c-arg-lst A)
                (valid-sc-subterms s-lst A)
                (true-listp s-lst)
                success)
           (equal (f2x2 (sum (sum-list-eval updated-s-lst a)
                             (sum-list (rp-evlt s-arg a))
                             (sum-list (rp-evlt pp-arg a))
                             (sum-list-eval c-arg-lst a)
                             x))
                  (sum (f2x2 (sum (sum-list-eval s-lst a)
                                  x))
                       (f2x2 (sum (sum-list (rp-evlt s-arg a))
                                  (sum-list (rp-evlt pp-arg a))
                                  (sum-list-eval c-arg-lst a))))))
  :fn single-c-try-merge-params
  :hints (("Goal"
           :use ((:instance single-c-try-merge-params$for-proofs-correct
                            (other-s-lst nil)))
           :in-theory (e/d ()
                           (single-c-try-merge-params$for-proofs-correct
                            (:DEFINITION TRUE-LISTP)
                            (:REWRITE VALID-SC-SUBTERMS-CONS)
                            valid-sc))
           :do-not-induct t)))

(defret single-c-try-merge-params-correct-2
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (VALID-SC S-ARG A)
                (VALID-SC pp-arg A)
                (valid-sc-subterms c-arg-lst A)
                (valid-sc-subterms s-lst A)
                (true-listp s-lst)
                success)
           (equal (f2 (sum (sum-list-eval updated-s-lst a)
                           (sum-list (rp-evlt s-arg a))
                           (sum-list (rp-evlt pp-arg a))
                           (sum-list-eval c-arg-lst a)
                           x))
                  (sum (f2 (sum (sum-list-eval s-lst a)
                                x))
                       (f2 (sum (sum-list (rp-evlt s-arg a))
                                (sum-list (rp-evlt pp-arg a))
                                (sum-list-eval c-arg-lst a))))))
  :fn single-c-try-merge-params
  :hints (("Goal"
           :use ((:instance single-c-try-merge-params-correct))
           :in-theory (e/d (sum-of-f2s
                            f2-to-d2)
                           (d2-to-f2
                            (:REWRITE SUM-OF-NEGATED-ELEMENTS)
                            (:DEFINITION VALID-SC)
                            (:REWRITE MINUS-OF-SUM)
                            eval-and-all
                            (:REWRITE D2-OF-MINUS))))))

(defret single-c-try-merge-params-correct-valid-sc
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (valid-sc-subterms s-lst A))
           (valid-sc-subterms updated-s-lst A))
  :fn single-c-try-merge-params
  :hints (("Goal"
           :do-not-induct t
           :induct (single-c-try-merge-params s-lst c-hash-code s-arg pp-arg c-arg-lst)
           :in-theory (e/d (single-c-try-merge-params)
                           ()))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; c-sum-merge

(defret get-c-args-correct
  (and (implies (and (rp-evl-meta-extract-global-facts :state state)
                     (mult-formula-checks state)
                     valid)
                (equal (f2 (sum (sum-list (rp-evlt s-args a))
                                (sum-list (rp-evlt pp-args a))
                                (sum-list-eval c-arg-lst a)))
                       (rp-evlt c a)))
       (implies (valid-sc c a)
                (and (valid-sc s-args a)
                     (valid-sc pp-args a)
                     (valid-sc-subterms c-arg-lst a))))
  :fn get-c-args
  :hints (("Goal"
           :expand (VALID-SC ''NIL A)
           :in-theory (e/d (get-c-args
                            rp-evlt-of-ex-from-rp-reverse-only-atom-and-car)
                           (valid-sc
                            eval-and-all
                            rp-evlt-of-ex-from-rp
                            NOT-INCLUDE-RP-MEANS-VALID-SC
                            NOT-INCLUDE-RP-MEANS-VALID-SC-LST
                            ex-from-rp
                            (:REWRITE RP-EVL-OF-IF-CALL))))))

(defret get-c-args-correct-valid-sc
  (and (implies (valid-sc c a)
                (and (valid-sc s-args a)
                     (valid-sc pp-args a)
                     (valid-sc-subterms c-arg-lst a))))
  :fn get-c-args
  :hints (("Goal"

           :in-theory (e/d (rp-evlt-of-ex-from-rp-reverse-only-atom-and-car)
                           (valid-sc
                            eval-and-all
                            rp-evlt-of-ex-from-rp
                            NOT-INCLUDE-RP-MEANS-VALID-SC
                            NOT-INCLUDE-RP-MEANS-VALID-SC-LST
                            ex-from-rp
                            (:REWRITE RP-EVL-OF-IF-CALL))))))

(defthmd rp-term-listp-of-cons
  (implies (consp x)
           (equal (rp-term-listp x)
                  (and
                   (rp-termp (car x))
                   (rp-term-listp (cdr x)))))
  :hints (("Goal"
           :expand (rp-term-listp x)
           :in-theory (e/d () ()))))

(defthm rp-term-listp-of-cons-2
  (implies (and (rp-term-listp x)
                (consp x))
           (and
            (rp-termp (car x))
            (rp-term-listp (cdr x))))
  :rule-classes :forward-chaining
  :hints (("Goal"
           :expand (rp-term-listp x)
           :in-theory (e/d () ()))))

(defthm valid-sc-subterms-cons-2
  (implies (and (valid-sc-subterms lst a)
                (consp lst))
           (and (valid-sc (car lst) a)
                (valid-sc-subterms (cdr lst) a)))
  :rule-classes :forward-chaining)

(defthm dummy-sum-reduce-common-1
  (equal (equal (sum x y z a)
                (sum p a q))
         (equal (sum x y z)
                (sum p q))))

(defthm valid-sc-subterms-of-consed
  (equal (VALID-SC-SUBTERMS (cons x y) A)
         (and (valid-sc x a)
              (valid-sc-subterms y a))))

(defthm valid-sc-subterms-of-consed-2
  (implies (and (valid-sc x a)
                (valid-sc-subterms y a))
           (VALID-SC-SUBTERMS (cons x y) A)))

(defthm rp-term-listp-of-consed
  (equal (rp-term-listp (cons x y))
         (and (rp-termp x)
              (rp-term-listp y)))
  :hints (("Goal"
           :expand (rp-term-listp (cons x y))
           :in-theory (e/d () ()))))

(defthm rp-term-listp-of-consed-2
  (implies (and (rp-termp x)
                (rp-term-listp y))
           (rp-term-listp (cons x y)))
  :hints (("Goal"
           :expand (rp-term-listp (cons x y))
           :in-theory (e/d () ()))))

(defthm valid-sc-subterms-of-single-list
  (equal (VALID-SC-SUBTERMS (list x) A)
         (valid-sc x a)))

(defthm rp-term-listp-of-single-list
  (iff (rp-term-listp (list x))
       (rp-termp x))
  :hints (("Goal"
           :expand (rp-term-listp (list x))
           :in-theory (e/d () ()))))

(defthm valid-sc-subterms-cdr
  (implies (and (consp term)
                (or (and (valid-sc term a)
                         (not (equal (car term) 'rp))
                         (not (equal (car term) 'quote))
                         (not (equal (car term) 'if)))
                    (valid-sc-subterms term a)))
           (valid-sc-subterms (cdr term) a))
  :hints (("Goal"
           :in-theory (e/d (valid-sc is-if is-rp) ()))))

(std::defretd
 get-c-args-correct-reverse-1
 (implies (and (rp-evl-meta-extract-global-facts :state state)
               (mult-formula-checks state)
               valid)
          (equal (rp-evlt c a)
                 (f2 (sum (sum-list (rp-evlt (caddr (ex-from-rp c)) a))
                          (sum-list (rp-evlt (cadddr (ex-from-rp c)) a))
                          (sum-list-eval (list-to-lst (car (cddddr (ex-from-rp c)))) a)))))
 :fn GET-C-ARGS
 :hints (("Goal"
          :use ((:instance get-c-args-correct))
          :in-theory (e/d (GET-C-ARGS
                           rp-evlt-of-ex-from-rp-reverse-only-atom)
                          (get-c-args-correct
                           rp-trans
                           rp-evlt-of-ex-from-rp)))))

(std::defretd
 get-c-args-correct-reverse-2
 (implies (and (rp-evl-meta-extract-global-facts :state state)
               (mult-formula-checks state)
               valid)
          (equal (rp-evlt c a)
                 (f2 (sum (sum-list (rp-evlt s-args a))
                          (sum-list (rp-evlt pp-args a))
                          (sum-list-eval c-arg-lst a)))))
 :fn GET-C-ARGS
 :hints (("Goal"
          :use ((:instance get-c-args-correct))
          :in-theory (e/d ()
                          (get-c-args-correct
                           rp-trans
                           rp-evlt-of-ex-from-rp)))))

(defthmd rp-term-listp-implies-true-listp
  (implies (rp-term-listp lst)
           (true-listp lst)))

(defthmd dummy-true-listp-lemma
  (implies (and (rp-termp single-c)
                (consp (MV-NTH 1 (GET-C-ARGS single-c)))
                (equal (car (MV-NTH 1 (GET-C-ARGS single-c)))
                       'list)
                (MV-NTH 4 (GET-C-ARGS single-c)))
           (RP-TERM-LISTP (CDR (MV-NTH 1 (GET-C-ARGS single-c)))))
  :hints (("Goal"
           :in-theory (e/d (GET-C-ARGS
;rp-termp-implies-true-listp
                            )
                           (ex-from-rp)))))

(defret-mutual
  c-sum-merge-correct-valid-sc
  (defret single-c-try-merge-correct-valid-sc
    (implies (and (rp-evl-meta-extract-global-facts :state state)
                  (mult-formula-checks state)
                  (valid-sc single-c1 a)
                  (valid-sc single-c2 a)
                  ;;(rp-termp single-c1)
                  ;;(rp-termp single-c2)
                  merge-success)
             (and
              (valid-sc coughed-s a)
              (valid-sc-subterms coughed-pp-lst a)
              (valid-sc-subterms produced-c-lst a)))
    :fn single-c-try-merge)
  (defret c-sum-merge-lst-aux-correct-valid-sc
    (implies (and (rp-evl-meta-extract-global-facts :state state)
                  (mult-formula-checks state)
                  (valid-sc single-c1 a)
                  (valid-sc-subterms c2-lst a)
                  ;;(rp-termp single-c1)
                  ;;(rp-term-listp c2-lst)
                  merge-success)
             (and
              (valid-sc coughed-s a)
              (valid-sc-subterms coughed-pp-lst a)
              (valid-sc-subterms produced-c-lst a)
              (valid-sc-subterms updated-c2-lst a)))
    :fn c-sum-merge-lst-aux)
  (defret c-sum-merge-lst-correct-valid-sc
    (implies (and (rp-evl-meta-extract-global-facts :state state)
                  (mult-formula-checks state)
                  (valid-sc single-c1 a)
                  (valid-sc-subterms c2-lst a)
                  ;;(rp-termp single-c1)
                  ;;(rp-term-listp c2-lst)
                  )
             (and
              (valid-sc coughed-s a)
              (valid-sc-subterms coughed-pp-lst a)
              (valid-sc-subterms new-c2-lst a)
              ))
    :fn c-sum-merge-lst)
  (defret c-sum-merge-lst-lst-correct-valid-sc
    (implies (and (rp-evl-meta-extract-global-facts :state state)
                  (mult-formula-checks state)
                  (valid-sc-subterms c1-lst a)
                  (valid-sc-subterms c2-lst a)
                  ;;(rp-term-listp c1-lst)
                  ;;(rp-term-listp c2-lst)
                  )
             (and
              (valid-sc coughed-s a)
              (valid-sc-subterms coughed-pp-lst a)
              (valid-sc-subterms updated-c2-lst a)
              ))
    :fn c-sum-merge-lst-lst)
  (defret c-sum-merge-correct-valid-sc
    (implies (and (rp-evl-meta-extract-global-facts :state state)
                  (mult-formula-checks state)
                  (valid-sc-subterms c1-lst a)
                  (valid-sc-subterms c2-lst a)
                  ;;(rp-term-listp c1-lst)
                  ;;;;(rp-term-listp c2-lst)
                  )
             (and
              (valid-sc coughed-s a)
              (valid-sc-subterms coughed-pp-lst a)
              (valid-sc-subterms c-merged-lst a)
              (valid-sc-subterms to-be-coughed-c-lst a)
              ))
    :fn c-sum-merge)
  (defret c-sum-merge-aux-correct-valid-sc
    (implies (and (rp-evl-meta-extract-global-facts :state state)
                  (mult-formula-checks state)
                  (valid-sc-subterms c1-lst a)
                  (valid-sc-subterms c2-lst a)
                  ;;(rp-term-listp c1-lst)
                  ;;(rp-term-listp c2-lst)
                  )
             (and
              (valid-sc coughed-s a)
              (valid-sc-subterms coughed-pp-lst a)
              (valid-sc-subterms c-merged-lst a)
              (valid-sc-subterms to-be-coughed-c-lst a)
              ))
    :fn c-sum-merge-aux)

  :hints (("Goal"
           :do-not-induct t
           :expand ((C-SUM-MERGE-LST SINGLE-C1 C2-LST)
                    (SINGLE-C-TRY-MERGE SINGLE-C1 SINGLE-C2)
                    (C-SUM-MERGE-LST-AUX SINGLE-C1 C2-LST)
                    (C-SUM-MERGE-AUX C1-LST C2-LST
                                     :CLEAN-C1-LST CLEAN-C1-LST)
                    (C-SUM-MERGE-LST ''0 C2-LST)
                    (C-SUM-MERGE-AUX C1-LST NIL
                                     :CLEAN-C1-LST NIL)
                    (C-SUM-MERGE-AUX C1-LST NIL
                                     :CLEAN-C1-LST CLEAN-C1-LST)
                    (C-SUM-MERGE-AUX NIL C2-LST
                                     :CLEAN-C1-LST CLEAN-C1-LST)
                    (C-SUM-MERGE C1-LST C2-LST
                                 :AUTO-SWAP AUTO-SWAP
                                 :CLEAN-C1-LST CLEAN-C1-LST)
                    (C-SUM-MERGE-LST-LST C1-LST C2-LST))
           :in-theory (e/d (sum-of-repeated-to-times2
                            rp-term-listp-of-cons-2

                            valid-sc-subterms-cons-2
                            rp-term-listp-of-consed-2
                            valid-sc-subterms-of-consed-2
                            get-c-args-correct-reverse-2
                            f2-of-times2-reverse
                            c-fix-arg-aux-correct-lemma)
                           (NOT-INCLUDE-RP-MEANS-VALID-SC

                            D2-OF-MINUS
                            SUM-OF-F2S

                            f2-of-times2

                            get-c-args-correct
                            (:REWRITE SUM-OF-NEGATED-ELEMENTS)
                            (:DEFINITION EVAL-AND-ALL)
                            (:REWRITE DEFAULT-CDR)
                            (:REWRITE MINUS-OF-SUM)
                            (:REWRITE EX-FROM-SYNP-LEMMA1)
                            (:DEFINITION IS-SYNP$INLINE)
                            (:REWRITE ACL2::O-P-O-INFP-CAR)
                            (:REWRITE
                             RP-TRANS-IS-TERM-WHEN-LIST-IS-ABSENT)
                            (:REWRITE VALID-SC-WHEN-LIST-INSTANCE)
                            (:DEFINITION INCLUDE-FNC)
                            rp-term-listp-of-cons
                            rp-term-listp-of-consed
                            valid-sc-subterms-of-consed
                            valid-sc-subterms-cons
                            (:DEFINITION TRANS-LIST)
                            (:REWRITE RP-EVL-OF-VARIABLE)
                            REWRITING-POSITIVE-LTE-GTE-GT-LT
                            NOT-INCLUDE-RP-MEANS-VALID-SC-LST
                            rp-termp
                            VALID-SC-SUBTERMS
                            rp-term-listp)))))

(defthmd c-sum-merge-correct-dummy-sum-lemma
  (implies (equal (sum x1 x2 x3 x4) a)
           (equal (sum x1 x2 x3 x4 b)
                  (sum a b))))

(defthm to-sum-list-eval-for-list-instances
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (consp term)
                (equal (car term) 'list))
           (equal (sum-list (rp-evlt term a))
                  (sum-list-eval (cdr term) a))))

(value-triple (hons-clear 't))

(defret-mutual
  c-sum-merge-correct
  (defret single-c-try-merge-correct
    (implies (and (rp-evl-meta-extract-global-facts :state state)
                  (mult-formula-checks state)
                  (valid-sc single-c1 a)
                  (valid-sc single-c2 a)
                  (rp-termp single-c1)
                  (rp-termp single-c2)
                  merge-success)
             (equal (sum (sum-list (rp-evlt coughed-s a))
                         (sum-list-eval coughed-pp-lst a)
                         (sum-list-eval produced-c-lst a))
                    (sum (rp-evlt single-c1 a)
                         (rp-evlt single-c2 a))))
    :fn single-c-try-merge)
  (defret c-sum-merge-lst-aux-correct
    (implies (and (rp-evl-meta-extract-global-facts :state state)
                  (mult-formula-checks state)
                  (valid-sc single-c1 a)
                  (valid-sc-subterms c2-lst a)
                  (rp-termp single-c1)
                  (rp-term-listp c2-lst)
                  merge-success)
             (equal (sum (sum-list (rp-evlt coughed-s a))
                         (sum-list-eval coughed-pp-lst a)
                         (sum-list-eval produced-c-lst a)
                         (sum-list-eval updated-c2-lst a))
                    (sum (rp-evlt single-c1 a)
                         (sum-list-eval c2-lst a))))
    :fn c-sum-merge-lst-aux)
  (defret c-sum-merge-lst-correct
    (implies (and (rp-evl-meta-extract-global-facts :state state)
                  (mult-formula-checks state)
                  (valid-sc single-c1 a)
                  (valid-sc-subterms c2-lst a)
                  (rp-termp single-c1)
                  (rp-term-listp c2-lst))
             (equal (sum (sum-list (rp-evlt coughed-s a))
                         (sum-list-eval coughed-pp-lst a)
                         (sum-list-eval new-c2-lst a))
                    (sum (rp-evlt single-c1 a)
                         (sum-list-eval c2-lst a))))
    :fn c-sum-merge-lst)
  (defret c-sum-merge-lst-lst-correct
    (implies (and (rp-evl-meta-extract-global-facts :state state)
                  (mult-formula-checks state)
                  (valid-sc-subterms c1-lst a)
                  (valid-sc-subterms c2-lst a)
                  (rp-term-listp c1-lst)
                  (rp-term-listp c2-lst))
             (equal (sum (sum-list (rp-evlt coughed-s a))
                         (sum-list-eval coughed-pp-lst a)
                         (sum-list-eval updated-c2-lst a))
                    (sum (sum-list-eval c1-lst a)
                         (sum-list-eval c2-lst a))))
    :fn c-sum-merge-lst-lst)
  (defret c-sum-merge-correct
    (implies (and (rp-evl-meta-extract-global-facts :state state)
                  (mult-formula-checks state)
                  (valid-sc-subterms c1-lst a)
                  (valid-sc-subterms c2-lst a)
                  (rp-term-listp c1-lst)
                  (rp-term-listp c2-lst))
             (equal (sum (sum-list (rp-evlt coughed-s a))
                         (sum-list-eval coughed-pp-lst a)
                         (sum-list-eval c-merged-lst a)
                         (sum-list-eval to-be-coughed-c-lst a)
                         (sum-list-eval to-be-coughed-c-lst a))
                    (sum (sum-list-eval c1-lst a)
                         (sum-list-eval c2-lst a))))
    :fn c-sum-merge)
  (defret c-sum-merge-aux-correct
    (implies (and (rp-evl-meta-extract-global-facts :state state)
                  (mult-formula-checks state)
                  (valid-sc-subterms c1-lst a)
                  (valid-sc-subterms c2-lst a)
                  (rp-term-listp c1-lst)
                  (rp-term-listp c2-lst))
             (equal (sum (sum-list (rp-evlt coughed-s a))
                         (sum-list-eval coughed-pp-lst a)
                         (sum-list-eval c-merged-lst a)
                         (sum-list-eval to-be-coughed-c-lst a)
                         (sum-list-eval to-be-coughed-c-lst a))
                    (sum (sum-list-eval c1-lst a)
                         (sum-list-eval c2-lst a))))
    :fn c-sum-merge-aux)

  :hints (("Goal"
           :do-not-induct t
           :expand ((C-SUM-MERGE-LST SINGLE-C1 C2-LST)
                    (SINGLE-C-TRY-MERGE SINGLE-C1 SINGLE-C2)
                    (C-SUM-MERGE-LST-AUX SINGLE-C1 C2-LST)
                    (C-SUM-MERGE-AUX C1-LST C2-LST
                                     :CLEAN-C1-LST CLEAN-C1-LST)
                    (C-SUM-MERGE-LST ''0 C2-LST)
                    (C-SUM-MERGE-AUX C1-LST NIL
                                     :CLEAN-C1-LST NIL)
                    (C-SUM-MERGE-AUX C1-LST NIL
                                     :CLEAN-C1-LST CLEAN-C1-LST)
                    (C-SUM-MERGE-AUX NIL C2-LST
                                     :CLEAN-C1-LST CLEAN-C1-LST)
                    (C-SUM-MERGE C1-LST C2-LST
                                 :AUTO-SWAP AUTO-SWAP
                                 :CLEAN-C1-LST CLEAN-C1-LST)
                    (C-SUM-MERGE-LST-LST C1-LST C2-LST))
           :in-theory (e/d (sum-of-repeated-to-times2
                            rp-term-listp-of-cons-2
                            c-sum-merge-correct-dummy-sum-lemma
                            valid-sc-subterms-cons-2
                            rp-term-listp-of-consed-2
                            valid-sc-subterms-of-consed-2
                            get-c-args-correct-reverse-2
                            f2-of-times2-reverse
                            dummy-true-listp-lemma
                            rp-term-listp-implies-true-listp
                            c-fix-arg-aux-correct-lemma)

                           (NOT-INCLUDE-RP-MEANS-VALID-SC
                            D2-OF-MINUS
                            SUM-OF-F2S
                            f2-of-times2
                            (:REWRITE DEFAULT-CAR)
                            (:REWRITE DUMMY-SUM-CANCEL-LEMMA1)
                            (:REWRITE
                             REGULAR-RP-EVL-OF_S_WHEN_MULT-FORMULA-CHECKS)
                            get-c-args-correct
                            (:REWRITE SUM-OF-NEGATED-ELEMENTS)
                            (:DEFINITION EVAL-AND-ALL)
                            (:REWRITE DEFAULT-CDR)
                            (:REWRITE MINUS-OF-SUM)
                            (:REWRITE EX-FROM-SYNP-LEMMA1)
                            (:DEFINITION IS-SYNP$INLINE)
                            (:REWRITE ACL2::O-P-O-INFP-CAR)
                            (:REWRITE
                             RP-TRANS-IS-TERM-WHEN-LIST-IS-ABSENT)
                            (:REWRITE VALID-SC-WHEN-LIST-INSTANCE)
                            (:DEFINITION INCLUDE-FNC)
                            rp-term-listp-of-cons
                            rp-term-listp-of-consed
                            valid-sc-subterms-of-consed
                            valid-sc-subterms-cons
                            (:DEFINITION TRANS-LIST)
                            (:REWRITE RP-EVL-OF-VARIABLE)
                            REWRITING-POSITIVE-LTE-GTE-GT-LT
                            NOT-INCLUDE-RP-MEANS-VALID-SC-LST
                            rp-termp
                            VALID-SC-SUBTERMS
                            single-c-try-merge-params-correct-2

                            rp-term-listp)))
          ("Subgoal *1/3"
           :use ((:instance single-c-try-merge-params-correct-2
                            (x (sum (SUM-LIST (RP-EVLT (MV-NTH 2 (GET-C-ARGS SINGLE-C2))
                                                       A))
                                    (SUM-LIST-EVAL (MV-NTH 3 (GET-C-ARGS SINGLE-C2))
                                                   A)))
                            (C-HASH-CODE (MV-NTH 0 (GET-C-ARGS SINGLE-C1)))
                            (s-lst (CDR (MV-NTH 1 (GET-C-ARGS SINGLE-C2))))
                            (s-arg (MV-NTH 1 (GET-C-ARGS SINGLE-C1)))
                            (pp-arg (MV-NTH 2 (GET-C-ARGS SINGLE-C1)))
                            (c-arg-lst (MV-NTH 3 (GET-C-ARGS SINGLE-C1))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; s-of-s-fix

;;;;;;;
(progn
  (define binary-m2-chain (a b)
    (m2 (sum a b)))

  (defmacro m2-chain (&rest rp::rst)
    (cond ((null rp::rst) 0)
          ((null (cdr rp::rst))
           (list 'm2 (car rp::rst)))
          (t (xxxjoin 'binary-m2-chain rp::rst))))

  (add-macro-fn m2-chain binary-m2-chain t)

  (defthmd m2-to-m2-chain
    (equal (m2 (sum a b))
           (m2-chain a b))
    :hints (("Goal"
             :in-theory (e/d (m2-chain) ()))))

  (defthm m2-chain-reorder
    (and (equal (m2-chain (sum a b) c)
                (m2-chain a b c))
         (equal (m2-chain a (sum b c))
                (m2-chain a b c))
         (equal (m2-chain (m2-chain a b) c)
                (m2-chain a b c)))
    :hints (("Goal"
             :in-theory (e/d (m2-chain) (m2-to-m2-chain)))))

  (defthm m2-chain-comm
    (and
     (implies (syntaxp (sum-comm-order a b))
              (equal  (m2-chain b a)
                      (m2-chain a b)))
     (implies (syntaxp (sum-comm-order a b))
              (equal  (m2-chain b a c)
                      (m2-chain a b c))))
    :rule-classes ((:rewrite :loop-stopper nil))
    :hints (("Goal"
             :in-theory (e/d (m2-chain) (m2-to-m2-chain)))))

  (defthm m2-chain-of-nil
    (and (equal (m2-chain nil a)
                (m2-chain a))
         (equal (m2-chain a nil)
                (m2-chain a)))
    :hints (("Goal"
             :in-theory (e/d (m2-chain) ()))))

  (defthm m2-of-m2-chain
    (equal (m2 (m2-chain a b))
           (m2-chain a b))
    :hints (("Goal"
             :in-theory (e/d (m2-chain) ()))))

  (defthm m2-chain-of-0
    (and (equal (m2-chain 0 a)
                (m2-chain a))
         (equal (m2-chain a 0)
                (m2-chain a)))
    :hints (("Goal"
             :in-theory (e/d (m2-chain) ())))))
;;;

(defthm equivalence-of-two-m2s-with-the-same-var-1
  (implies (and (equal (m2-chain x y) (m2-chain p q)))
           (equal (equal (m2-chain x y a)
                         (m2-chain p a q))
                  t)))

(defthmd m2-of-rp-evlt-of-ex-from-rp/--reverse
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (syntaxp (equal m '(car s-lst))))
           (equal (m2-chain (rp-evlt m a) y)
                  (m2-chain (rp-evlt (ex-from-rp/-- m) a) y)))
  :hints (("Goal"
           :induct (ex-from-rp/-- m)
           :do-not-induct t
           :in-theory (e/d (ex-from-rp/--
                            m2-chain
                            is-rp
                            --.p)
                           ()))))

(defthmd s-of-s-fix-lst-correct-dummy-lemma1
  (implies (and (equal (sum a b (times2 other))
                       x))
           (equal (m2-chain a b c)
                  (m2-chain x c)))
  :hints (("Goal"
           :in-theory (e/d (m2-chain) ()))))

#|(defthmd s-of-s-fix-lst-correct-dummy-lemma2
  (implies (and (equal (m2 big) (m2 small))
                (syntaxp (> (cons-count big)
                            (cons-count small))))
           (equal (m2-chain a big)
                  (m2-chain a small))))||#

(defthm
  c-sum-merge-correct-for-s
  (b* (((mv ?coughed-s ?coughed-pp-lst
            ?c-merged-lst ?to-be-coughed-c-lst)
        (c-sum-merge-fn c1-lst c2-lst auto-swap clean-c1-lst)))
    (implies
     (and (rp-evl-meta-extract-global-facts :state state)
          (mult-formula-checks state)
          (valid-sc-subterms c1-lst a)
          (valid-sc-subterms c2-lst a)
          (rp-term-listp c1-lst)
          (rp-term-listp c2-lst))
     (equal (m2-chain (sum-list (rp-evlt coughed-s a))
                      (sum-list-eval coughed-pp-lst a)
                      (sum-list-eval c-merged-lst a))
            (m2 (sum (sum-list-eval c1-lst a)
                     (sum-list-eval c2-lst a))))))
  :hints
  (("goal"
    :in-theory (e/d (s-of-s-fix-lst-correct-dummy-lemma1
                     m2-chain
                     sum-of-repeated-to-times2)
                    (c-sum-merge-correct))
    :use ((:instance c-sum-merge-correct)))))

(defret s-of-s-fix-lst-correct-valid-sc
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (valid-sc-subterms s-lst a)
                (valid-sc-subterms c-lst a)
                (rp-term-listp s-lst)
                (rp-term-listp c-lst))
           (and (valid-sc-subterms pp-res-lst a)
                (valid-sc-subterms c-res-lst a)))
  :fn s-of-s-fix-lst
  :hints (("Goal"
           :do-not-induct t
           :induct (s-of-s-fix-lst s-lst c-lst :limit limit)
           :expand ((S-OF-S-FIX-LST S-LST C-LST
                                    :LIMIT LIMIT))
           :in-theory (e/d (s-of-s-fix-lst
                            m2-to-m2-chain
                            (:induction S-OF-S-FIX-LST-FN)
                            m2-of-rp-evlt-of-ex-from-rp/--reverse
                            rp-trans-lst-of-consp
                            s-of-s-fix-lst-correct-dummy-lemma1
                            sum-of-repeated-to-times2)
                           (valid-sc
                            ;;(:DEFINITION SUM-LIST-EVAL)
                            (:TYPE-PRESCRIPTION BINARY-M2-CHAIN)
                            (:REWRITE ACL2::O-P-O-INFP-CAR)
                            (:REWRITE DEFAULT-CAR)
                            include-fnc
                            (:REWRITE SUM-OF-NEGATED-ELEMENTS)
                            (:REWRITE DEFAULT-CDR)
                            (:DEFINITION S-OF-S-FIX-LST-FN)
                            RP-TRANS-IS-TERM-WHEN-LIST-IS-ABSENT
                            not-include-rp-means-valid-sc
                            not-include-rp-means-valid-sc-lst
                            include-fnc-subterms
                            c-sum-merge-correct-for-s
                            c-sum-merge-correct
                            M2-OF-RP-EVLT-EX-FROM-RP/--)))))

;;;;
(defthmd SUM-LIST-EVAL-of-cons
  (implies (consp lst)
           (equal (sum-list-eval lst a)
                  (SUM (RP-EVLT (CAR LST) A)
                       (SUM-LIST-EVAL (CDR LST) A)))))

(defthmd SUM-LIST-EVAL-of-atom
  (implies (atom lst)
           (equal (sum-list-eval lst a)
                  0)))
;;;;;

(defret s-of-s-fix-lst-correct
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (valid-sc-subterms s-lst a)
                (valid-sc-subterms c-lst a)
                (rp-term-listp s-lst)
                (rp-term-listp c-lst))
           (and (equal (m2 (sum (sum-list-eval pp-res-lst a)
                                (sum-list-eval c-res-lst a)
                                x))
                       (m2 (sum (sum-list-eval s-lst a)
                                (sum-list-eval c-lst a)
                                x)))
                (equal (m2-chain (sum-list-eval pp-res-lst a)
                                 (sum-list-eval c-res-lst a)
                                 x)
                       (m2 (sum (sum-list-eval s-lst a)
                                (sum-list-eval c-lst a)
                                x)))))
  :fn s-of-s-fix-lst
  :hints (("Goal"
           :do-not-induct t
           :do-not '(preprocess)
           :induct (s-of-s-fix-lst s-lst c-lst :limit limit)
           :expand ((S-OF-S-FIX-LST S-LST C-LST
                                    :LIMIT LIMIT))
           :in-theory (e/d (s-of-s-fix-lst
                            SUM-LIST-EVAL-of-atom
                            m2-to-m2-chain
                            SUM-LIST-EVAL-of-cons
                            (:induction S-OF-S-FIX-LST-FN)
                            m2-of-rp-evlt-of-ex-from-rp/--reverse
                            rp-trans-lst-of-consp
                            s-of-s-fix-lst-correct-dummy-lemma1
                            sum-of-repeated-to-times2)
                           (valid-sc
                            (:TYPE-PRESCRIPTION RP-TRANS-LST)
                            (:DEFINITION TRANS-LIST)
                            (:REWRITE RP-EVL-OF-VARIABLE)
                            eval-and-all
                            valid-sc
                            (:DEFINITION VALID-SC-SUBTERMS)
                            (:REWRITE VALID-SC-SUBTERMS-CONS)
                            (:DEFINITION SUM-LIST-EVAL)
                            (:TYPE-PRESCRIPTION BINARY-M2-CHAIN)
                            (:REWRITE ACL2::O-P-O-INFP-CAR)
                            (:REWRITE DEFAULT-CAR)
                            include-fnc
                            (:REWRITE SUM-OF-NEGATED-ELEMENTS)
                            (:REWRITE DEFAULT-CDR)
                            (:DEFINITION S-OF-S-FIX-LST-FN)
                            RP-TRANS-IS-TERM-WHEN-LIST-IS-ABSENT
                            not-include-rp-means-valid-sc
                            not-include-rp-means-valid-sc-lst
                            include-fnc-subterms
                            c-sum-merge-correct-for-s
                            c-sum-merge-correct
                            M2-OF-RP-EVLT-EX-FROM-RP/--)))
          ("Subgoal *1/3"
           :use ((:instance c-sum-merge-correct-for-s
                            (c1-lst (LIST-TO-LST (CADDDR (EX-FROM-RP/-- (CAR
                                                                         S-LST)))))
                            (c2-lst (MV-NTH 1
                                            (S-OF-S-FIX-LST (CDR S-LST)
                                                            C-LST
                                                            :LIMIT (SUM LIMIT -1))))
                            (auto-swap t)
                            (clean-c1-lst nil))))
          ("Subgoal *1/4"
           :use ((:instance c-sum-merge-correct-for-s
                            (c1-lst (LIST-TO-LST (CADDDR (EX-FROM-RP/-- (CAR
                                                                         S-LST)))))
                            (c2-lst (MV-NTH 1
                                            (S-OF-S-FIX-LST (CDR S-LST)
                                                            C-LST
                                                            :LIMIT (SUM LIMIT -1))))
                            (auto-swap t)
                            (clean-c1-lst nil))))))

(defret s-of-s-fix-correct
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (valid-sc s a)
                (valid-sc pp a)
                (valid-sc-subterms c-lst a)
                (rp-termp s)
                (rp-termp pp)
                (rp-term-listp c-lst))
           (and (valid-sc pp-res a)
                (valid-sc-subterms c-res-lst a)
                (equal (m2 (sum (sum-list (rp-evlt pp-res a))
                                (sum-list-eval c-res-lst a)))
                       (m2 (sum (sum-list (rp-evlt s a))
                                (sum-list (rp-evlt pp a))
                                (sum-list-eval c-lst a))))
                (equal (m2-chain (sum-list (rp-evlt pp-res a))
                                 (sum-list-eval c-res-lst a))
                       (m2 (sum (sum-list (rp-evlt s a))
                                (sum-list (rp-evlt pp a))
                                (sum-list-eval c-lst a))))))
  :fn s-of-s-fix
  :hints (("Goal"
           :do-not-induct t
           :in-theory (e/d (s-of-s-fix
                            m2-to-m2-chain)
                           ()))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; good-4vec-term-p, 4vec->pp-term

(defthm 4vec->pp-term-valid-sc
  (implies (and (valid-sc term a))
           (valid-sc (4vec->pp-term term) a))
  :hints (("Goal"
           :do-not-induct t
           :induct (4vec->pp-term term)
           :expand ((:free (x) (valid-sc (cons 'bit-of x) a))
                    (:free (x) (valid-sc (cons 'binary-not x) a))
                    (:free (x) (valid-sc (cons 'binary-or x) a))
                    (:free (x) (valid-sc (cons 'binary-xor x) a))
                    (:free (x) (valid-sc (cons 'binary-and x) a))
                    (:free (x) (valid-sc (cons 'binary-? x) a)))
           :in-theory (e/d (is-rp
                            is-if
                            good-4vec-term-p
                            4vec->pp-term)
                           (pp-term-p
                            (:REWRITE VALID-SC-SUBTERMS-CDR)
                            (:DEFINITION VALID-SC)
                            (:REWRITE VALID-SC-WHEN-SINGLE-C-P)
                            (:DEFINITION RP-TRANS)
                            (:TYPE-PRESCRIPTION SINGLE-C-P$INLINE)
                            (:REWRITE NOT-INCLUDE-RP-MEANS-VALID-SC-LST)
                            (:DEFINITION TRANS-LIST)
                            (:TYPE-PRESCRIPTION INCLUDE-FNC-SUBTERMS)
                            (:REWRITE VALID-SC-WHEN-LIST-INSTANCE)
                            (:TYPE-PRESCRIPTION VALID-SC-SUBTERMS)
                            (:TYPE-PRESCRIPTION RP-TRANS-LST)
                            (:REWRITE ACL2::SYMBOL-LISTP-IMPLIES-SYMBOLP)
                            rp-trans

                            ;;(:REWRITE VALID-SC-LEMMA1)
                            (:DEFINITION INCLUDE-FNC-SUBTERMS)
                            (:LINEAR ACL2::APPLY$-BADGEP-PROPERTIES . 2)
                            (:REWRITE ACL2::FN-CHECK-DEF-NOT-QUOTE)
                            (:REWRITE VALID-SC-OF-EX-FROM-RP)
                            (:REWRITE DEFAULT-CDR)
                            (:REWRITE NOT-INCLUDE-RP-MEANS-VALID-SC)
                            (:TYPE-PRESCRIPTION INCLUDE-FNC)
                            (:REWRITE VALID-SC-SINGLE-STEP)
                            (:DEFINITION EVAL-AND-ALL)
                            (:DEFINITION EX-FROM-RP)
                            (:REWRITE DEFAULT-CAR)
                            (:REWRITE EVL-OF-EXTRACT-FROM-RP-2)
                            (:LINEAR ACL2::APPLY$-BADGEP-PROPERTIES . 1)
                            (:REWRITE ACL2::O-P-O-INFP-CAR)
                            (:DEFINITION ACL2::APPLY$-BADGEP)
                            (:REWRITE EX-FROM-SYNP-LEMMA1)
                            (:REWRITE ATOM-RP-TERMP-IS-SYMBOLP)
                            natp
                            rp-termp
                            include-fnc)))))

(local
 (in-theory (enable is-rp-implies-fc)))

(local
 (in-theory (disable (:REWRITE NOT-INCLUDE-RP-MEANS-VALID-SC))))

(local
 (defthmd is-rp-and-rp-evlt-dummy-lemma
   (implies (is-rp term)
            (equal (rp-evlt term a)
                   (rp-evlt (caddr term) a)))
   :hints (("Goal"
            :in-theory (e/d (is-rp) ())))))

(progn

  (local
   (create-regular-eval-lemma cons 2 mult-formula-checks))
  (local
   (create-regular-eval-lemma binary-not 1 mult-formula-checks))
  (local
   (create-regular-eval-lemma binary-xor 2 mult-formula-checks))
  (local
   (create-regular-eval-lemma binary-or 2 mult-formula-checks))
  (local
   (create-regular-eval-lemma binary-and 2 mult-formula-checks))
  (local
   (create-regular-eval-lemma binary-? 3 mult-formula-checks))

  (local
   (defthm pp-termp-is-bitp-lemma
     (implies (and (PP-HAS-BITP-RP TERM)
                   (rp-evl-meta-extract-global-facts :state state)
                   (VALID-SC TERM A)
                   (MULT-FORMULA-CHECKS STATE))
              (and (BITP (RP-EVLt TERM A))
                   (BITP (RP-EVLt (EX-FROM-RP TERM) A))))
     :otf-flg t
     :hints (("Goal"
              :induct (PP-HAS-BITP-RP TERM)
              :do-not-induct t
              :in-theory (e/d (is-if ;is-rp
                               valid-sc
                               is-rp-and-rp-evlt-dummy-lemma
                               is-rp-implies-fc
                               valid-sc-single-step
                               rp-trans-lst-of-consp
                               PP-HAS-BITP-RP)
                              (bitp
                               rp-trans
                               rp-trans-lst
                               NOT-INCLUDE-RP-MEANS-VALID-SC))))))

  (local
   (defthm pp-termp-is-bitp
     (implies (and (rp-evl-meta-extract-global-facts :state state)
                   (mult-formula-checks state)
                   (pp-term-p term)
                   (valid-sc term a))
              (bitp (rp-evlt term a)))
     :hints (("Goal"
              :do-not-induct t
              :expand ((PP-TERM-P TERM))
              :in-theory (e/d (pp-term-p
                               is-rp
                               rp-evlt-of-ex-from-rp-reverse-only-atom
                               is-if)
                              (bitp
                               (:DEFINITION VALID-SC)
                               (:DEFINITION EVAL-AND-ALL)
                               (:DEFINITION IS-RP$INLINE)
                               (:REWRITE DEFAULT-CDR)
                               (:REWRITE ACL2::O-P-O-INFP-CAR)
                               (:REWRITE NOT-INCLUDE-RP-MEANS-VALID-SC)
                               (:REWRITE EVL-OF-EXTRACT-FROM-RP-2)
                               PP-HAS-BITP-RP
                               rp-trans
                               pp-term-p
                               RP-TRANS-IS-TERM-WHEN-LIST-IS-ABSENT
                               rp-evlt-of-ex-from-rp
                               EX-FROM-RP-LEMMA1
                               rp-evlt-of-ex-from-rp))))))

  (local
   (defthm light-pp-termp-is-bitp
     (implies (and (rp-evl-meta-extract-global-facts :state state)
                   (mult-formula-checks state)
                   (LIGHT-PP-TERM-P term)
                   (valid-sc term a))
              (bitp (rp-evlt term a)))
     :hints (("Goal"
              :do-not-induct t
              :expand ((LIGHT-PP-TERM-P TERM))
              :in-theory (e/d (LIGHT-PP-TERM-p
                               is-rp
                               rp-evlt-of-ex-from-rp-reverse-only-atom
                               is-if)
                              (bitp
                               pp-term-p
                               RP-TRANS-IS-TERM-WHEN-LIST-IS-ABSENT
                               rp-evlt-of-ex-from-rp
                               EX-FROM-RP-LEMMA1
                               rp-evlt-of-ex-from-rp))))))

  (local
   (defthm PP-HAS-BITP-RP-EX-FROM-RP
     (not (PP-HAS-BITP-RP (EX-FROM-RP TERM)))
     :hints (("Goal"
              :induct (EX-FROM-RP TERM)
              :do-not-induct t
              :in-theory (e/d (EX-FROM-RP pp-has-bitp-rp
                                          is-rp) ())))))

  (local
   (defthm pp-termp-of-ex-from-rp
     (implies (pp-term-p (ex-from-rp term))
              (pp-term-p term))
     :hints (("Goal"
              :expand ((PP-TERM-P (EX-FROM-RP TERM))
                       (pp-term-p term))
              :do-not-induct t
              :in-theory (e/d (pp-term-p) ())))))

  (local
   (defthm LIGHT-PP-TERM-P-of-ex-from-rp
     (implies (LIGHT-PP-TERM-P (ex-from-rp term))
              (LIGHT-PP-TERM-P term))
     :hints (("Goal"
              :expand ((LIGHT-PP-TERM-P (EX-FROM-RP TERM))
                       (LIGHT-PP-TERM-P term))
              :do-not-induct t
              :in-theory (e/d (LIGHT-PP-TERM-P) ()))))))

(encapsulate
  nil
  (local
   (progn
     (create-regular-eval-lemma svl::bits 3 mult-formula-checks)
     (create-regular-eval-lemma svl::4vec-bitnot$ 2 mult-formula-checks)
     (create-regular-eval-lemma svl::4vec-bitand 2 mult-formula-checks)
     (create-regular-eval-lemma sv::4vec-bitxor 2 mult-formula-checks)
     (create-regular-eval-lemma svl::4vec-bitor 2 mult-formula-checks)
     (create-regular-eval-lemma svl::4vec-? 3 mult-formula-checks)

     (create-regular-eval-lemma sv::3vec-fix 1 mult-formula-checks)
     (create-regular-eval-lemma svl::4vec-?* 3 mult-formula-checks)))

  (local
   (create-regular-eval-lemma sv::4vec-fix$inline 1 mult-formula-checks))

  (encapsulate
    nil

    (local
     (include-book "centaur/bitops/ihsext-basics" :dir :system))

    (defthmd bits-is-bit-of
      (implies (and (natp start)
                    (integerp num)
                    (equal size 1))
               (equal (svl::bits num start size)
                      (bit-of num start)))
      :hints (("Goal"
               :in-theory (e/d (svl::bits
                                ACL2::BOOL->BIT
                                SV::4VEC-CONCAT
                                bit-of
                                SV::2VEC
                                rw-dir2
                                SV::4VEC
                                SV::4VEC-SHIFT-CORE
                                SV::4VEC-RSH
                                SV::4VEC->UPPER
                                SV::4VEC->LOWER
                                SV::4VEC-PART-SELECT
                                SV::4VEC-ZERO-EXT)
                               (SVL::4VEC-ZERO-EXT-IS-4VEC-CONCAT
                                +-IS-SUM
                                rw-dir1
                                FLOOR2-IF-F2
                                MOD2-IS-M2))))))

  (local
   (in-theory (e/d (bitp rw-dir2)
                   (rw-dir1))))

  (progn
    (local
     (defthm 4vec-bitnot$-is-not$
       (implies (bitp num)
                (equal (svl::4vec-bitnot$ 1 num)
                       (not$ num)))))
    (local
     (defthm 4vec-fix$-when-bitp
       (implies (bitp num)
                (equal (sv::4vec-fix num)
                       num))))

    (local
     (defthm 3vec-fix$-when-bitp
       (implies (bitp num)
                (equal (sv::3vec-fix num)
                       num))))

    (local
     (defthm 4vec-bitand-is-and$
       (implies (and (bitp num)
                     (bitp num2))
                (equal (svl::4vec-bitand num num2)
                       (and$ num num2)))))

    (local
     (defthm 4vec-bitor-is-or$
       (implies (and (bitp num)
                     (bitp num2))
                (equal (svl::4vec-bitor num num2)
                       (or$ num num2)))))

    (local
     (defthm 4vec-bitxor-is-binary-xor
       (implies (and (bitp num)
                     (bitp num2))
                (equal (sv::4vec-bitxor num num2)
                       (binary-xor num num2)))))

    (local
     (defthm 4vec-?-is-binary-?
       (implies (and (bitp num)
                     (bitp num2)
                     (bitp num3))
                (and (equal (svl::4vec-? num num2 num3)
                            (binary-? num num2 num3))
                     (equal (svl::4vec-?* num num2 num3)
                            (binary-? num num2 num3)))))))

  (local
   (defthm 4vec->pp-term-correct-bitp-lemma
     (implies (and (valid-sc term a)
                   (rp-evl-meta-extract-global-facts :state state)
                   (mult-formula-checks state)
                   (good-4vec-term-p term)
                   (equal (rp-evlt (4vec->pp-term term) a)
                          (rp-evlt term a)))
              (bitp (rp-evlt term a)))
     :hints (("Goal"
              :do-not-induct t
              :in-theory (e/d (4vec->pp-term) (bitp
                                               pp-term-p))))))

  (local
   (encapsulate
     nil

     (local
      (in-theory (e/d (valid-sc-single-step is-rp)
                      (bitp
                       rp-trans
                       rp-termp
                       not-include-rp-means-valid-sc
                       valid-sc
                       VALID-SC-EX-FROM-RP
                       VALID-SC-OF-EX-FROM-RP
                       rp-evl-of-variable))))

     (defthm 4vec->pp-term-correct-bitp-lemma-2
       (implies (and (valid-sc term a)
                     (rp-evl-meta-extract-global-facts :state state)
                     (mult-formula-checks state)
                     (good-4vec-term-p term)
                     (b* ((term (ex-from-rp term)))
                       (case-match term (('svl::bits & & &) t))))
                (and (integerp (rp-evl (rp-trans (caddr (cadr (ex-from-rp
                                                               term)))) a))
                     ))
       :otf-flg t
       :hints (("Subgoal 1"
                :expand ((VALID-SC (EX-FROM-RP TERM) A)
                         (GOOD-4VEC-TERM-P TERM)))
               ("Subgoal 2"
                :in-theory (e/d (VALID-SC-EX-FROM-RP)
                                ()))
               ("goal"
                :do-not-induct t
                ;;:in-theory (e/d (is-rp valid-sc-single-step) (valid-sc))
                :expand ((good-4vec-term-p term))
                :cases ((valid-sc (ex-from-rp term) a)))))))

  (local
   (encapsulate
     nil

     (local
      (in-theory (e/d (;valid-sc-single-step
                       is-rp)
                      (bitp
                       rp-trans
                       rp-termp
                       not-include-rp-means-valid-sc
                       valid-sc
                       4VEC->PP-TERM-CORRECT-BITP-LEMMA-2
                       VALID-SC-EX-FROM-RP
                       (:REWRITE DEFAULT-CDR)
                       (:REWRITE VALID-SC-CADR)
                       (:REWRITE EVL-OF-EXTRACT-FROM-RP-2)
                       (:DEFINITION VALID-SC)
                       (:DEFINITION IS-RP$INLINE)
                       (:REWRITE DEFAULT-CAR)
                       (:REWRITE ACL2::O-P-O-INFP-CAR)
                       (:REWRITE EX-FROM-SYNP-LEMMA1)
                       (:DEFINITION IS-SYNP$INLINE)
                       (:TYPE-PRESCRIPTION RP-TRANS-LST)
                       (:TYPE-PRESCRIPTION TRANS-LIST)
                       (:REWRITE VALID-SC-EX-FROM-RP-2)
                       (:DEFINITION EVAL-AND-ALL)
                       (:REWRITE ATOM-RP-TERMP-IS-SYMBOLP)
                       (:TYPE-PRESCRIPTION INCLUDE-FNC)
                       (:REWRITE
                        REGULAR-RP-EVL-OF_S_WHEN_MULT-FORMULA-CHECKS)
                       (:DEFINITION INCLUDE-FNC)
                       VALID-SC-OF-EX-FROM-RP
                       rp-evl-of-variable))))

     (defthm 4vec->pp-term-correct-bitp-lemma-3
       (implies (and (valid-sc term a)
                     (rp-evl-meta-extract-global-facts :state state)
                     (mult-formula-checks state)
                     (good-4vec-term-p term)
                     (b* ((term (ex-from-rp term)))
                       (case-match term (('svl::bits & & &) t))))
                (and (integerp (rp-evl (rp-trans (cadr (ex-from-rp term))) a)))
                )
       :otf-flg t
       :hints (("goal"
                :expand ((VALID-SC (EX-FROM-RP TERM) A)
                         (good-4vec-term-p term)
                         (rp-trans (CADR (EX-FROM-RP TERM)))
                         (GOOD-4VEC-TERM-P TERM))
                :use ((:instance 4vec->pp-term-correct-bitp-lemma-2
                                 (term term))
                      (:instance valid-sc-single-step
                                 (term (CADR (EX-FROM-RP TERM)))))
                :do-not-induct t
;:in-theory (e/d (is-rp valid-sc-single-step) (valid-sc))
;:cases ((valid-sc (ex-from-rp term) a))
                )))))

  (defthm rp-trans-of-quoted
    (implies (equal (car x) 'quote)
             (equal (rp-trans x)
                    x))
    :rule-classes :forward-chaining)

  (defthm quotep-implies
    (implies (quotep x)
             (equal (car x) 'quote))
    :rule-classes :forward-chaining)

  (value-triple (hons-clear t))

  (defthm 4vec->pp-term-correct
    (implies (and (valid-sc term a)
                  (rp-evl-meta-extract-global-facts :state state)
                  (mult-formula-checks state)
                  (good-4vec-term-p term))
             (equal (rp-evlt (4vec->pp-term term) a)
                    (rp-evlt term a)))
    :hints (("Goal"
             :do-not-induct t
             :induct (4vec->pp-term term)
             :expand ((:free (x) (nth 3 x))
                      (:free (x) (nth 2 x))
                      (:free (x) (nth 1 x))
                      (:free (x) (nth 0 x)))
             :in-theory (e/d (4vec->pp-term
                              rp-evlt-of-ex-from-rp-reverse-only-atom
                              bits-is-bit-of
                              is-rp
                              valid-sc-single-step
                              good-4vec-term-p
                              )
                             (pp-term-p
                              (:TYPE-PRESCRIPTION MULT-FORMULA-CHECKS)
                              (:DEFINITION IS-RP$INLINE)
                              (:REWRITE EVL-OF-EXTRACT-FROM-RP-2)
                              rp-trans
                              ;;is-rp
                              rp-termp
                              valid-sc
                              (:DEFINITION VALID-SC)
                              (:DEFINITION INCLUDE-FNC)
                              ;;(:REWRITE VALID-SC-LEMMA1)
                              (:REWRITE NOT-INCLUDE-RP-MEANS-VALID-SC)
                              (:DEFINITION ACL2::APPLY$-BADGEP)
                              (:LINEAR ACL2::APPLY$-BADGEP-PROPERTIES . 1)
                              (:DEFINITION EX-FROM-RP)
                              (:REWRITE DEFAULT-CDR)
                              (:DEFINITION SUBSETP-EQUAL)
                              (:DEFINITION MEMBER-EQUAL)
                              (:REWRITE PP-TERMP-OF-EX-FROM-RP)
                              (:LINEAR ACL2::APPLY$-BADGEP-PROPERTIES . 2)
                              (:REWRITE RP-TERM-LISTP-IS-TRUE-LISTP)
                              (:REWRITE NOT-INCLUDE-RP)
                              (:REWRITE
                               ACL2::MEMBER-EQUAL-NEWVAR-COMPONENTS-1)
                              (:REWRITE DEFAULT-CAR)
                              (:DEFINITION EVAL-AND-ALL)
                              (:DEFINITION RP-TERM-LISTP)
                              (:DEFINITION TRUE-LISTP)
                              (:REWRITE ACL2::O-P-O-INFP-CAR)
                              (:DEFINITION QUOTEP)
                              natp
                              bitp
                              rp-evlt-of-ex-from-rp))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; extract-new-sum-element, extract-new-sum-consed

(defthm sum-list-eval-of-repeat-quoted-1
  (implies (natp amount)
           (equal (sum-list-eval (repeat amount ''1) a)
                  amount))
  :hints (("Goal"
           :in-theory (e/d (repeat
                            sum-list-eval
                            rw-dir2)
                           (rw-dir1)))))

(defthm sum-list-eval-of-repeat-quoted-minus-1
  (implies (natp amount)
           (equal (sum-list-eval (repeat amount ''-1) a)
                  (- amount)))
  :hints (("Goal"
           :in-theory (e/d (repeat
                            sum-list-eval
                            rw-dir2)
                           (rw-dir1)))))

(defthmd rp-evlt-when-quotep
  (implies (quotep term)
           (equal (rp-evlt term a)
                  (cadr term))))

(defret extract-new-sum-element-correct
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state))
           (equal (sum-list-eval acc-res a)
                  (sum (rp-evlt term a)
                       (sum-list-eval acc a))))
  :fn extract-new-sum-element
  :hints (("Goal"
           :do-not-induct t
           :induct (extract-new-sum-element term acc)
           :in-theory (e/d (extract-new-sum-element
                            rp-evlt-when-quotep
                            rp-evlt-of-ex-from-rp-reverse-only-atom
                            rw-dir2)
                           (rw-dir1
                            rp-trans
                            RP-TRANS-IS-TERM-WHEN-LIST-IS-ABSENT
                            rp-evlt-of-ex-from-rp)))))

(defthm quote-listp-of-repeat
  (implies (natp amount)
           (and (quote-listp (repeat amount ''1))
                (quote-listp (repeat amount ''-1))))
  :hints (("Goal"
           :in-theory (e/d (repeat) ()))))

(defthmd quote-listp-implies-valid-sc-subterms
  (implies (quote-listp lst)
           (valid-sc-subterms lst a)))

(defthmd quote-listp-implies-valid-sc
  (implies (quote-listp lst)
           (valid-sc (car lst) a)))

(defret extract-new-sum-element-correct-valid-sc
  (implies (and (valid-sc term a)
                (valid-sc-subterms acc a))
           (valid-sc-subterms acc-res a))
  :fn extract-new-sum-element
  :otf-flg t
  :hints (("Goal"
           :do-not-induct t
           :induct (extract-new-sum-element term acc)
           :in-theory (e/d (extract-new-sum-element
                            quote-listp-implies-valid-sc
                            quote-listp-implies-valid-sc-subterms
                            rp-evlt-when-quotep
                            rp-evlt-of-ex-from-rp-reverse-only-atom
                            rw-dir2)
                           (rw-dir1
                            rp-trans
                            RP-TRANS-IS-TERM-WHEN-LIST-IS-ABSENT
                            rp-evlt-of-ex-from-rp)))))

;;;;;;

(defret extract-new-sum-consed-correct
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state))
           (equal (sum-list-eval acc-res a)
                  (sum-list (rp-evlt term a))))
  :fn extract-new-sum-consed
  :hints (("Goal"
           :do-not-induct t
           :expand (EXTRACT-NEW-SUM-CONSED TERM)
           :induct (extract-new-sum-consed term)
           :in-theory (e/d (extract-new-sum-consed
                            rp-evlt-of-ex-from-rp-reverse-only-atom)
                           (rp-evlt-of-ex-from-rp
                            rp-trans
                            RP-TRANS-IS-TERM-WHEN-LIST-IS-ABSENT
                            EVL-OF-EXTRACT-FROM-RP)))))

(defret extract-new-sum-consed-correct-valid-sc
  (implies (valid-sc term a)
           (valid-sc-subterms acc-res a))
  :fn extract-new-sum-consed
  :hints (("Goal"
           :do-not-induct t
           :expand (EXTRACT-NEW-SUM-CONSED TERM)
           :induct (extract-new-sum-consed term)
           :in-theory (e/d (extract-new-sum-consed
                            rp-evlt-of-ex-from-rp-reverse-only-atom)
                           (rp-evlt-of-ex-from-rp
                            rp-trans
                            RP-TRANS-IS-TERM-WHEN-LIST-IS-ABSENT
                            EVL-OF-EXTRACT-FROM-RP)))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; new-sum-merge-aux

(create-regular-eval-lemma sum-list 1 mult-formula-checks)

(defthm pp-flatten-correct-with-sum-list-eval
  (implies (and (mult-formula-checks state)
                (pp-term-p term)
                (booleanp sign)
                (valid-sc term a)
                (rp-evl-meta-extract-global-facts))
           (equal (sum-list-eval (pp-flatten term sign) a)
                  (if sign
                      (-- (rp-evlt term a))
                    (rp-evlt term a))))
  :hints (("Goal"
           :use ((:instance pp-flatten-correct))
           :in-theory (e/d () ()))))

(defthm dummy-sum-cancel-lemma2
  (equal (equal (sum x1 x2 x3 x4 x5 a)
                (sum y1 y2 a))
         (equal (sum x1 x2 x3 x4 x5)
                (sum y1 y2))))

(defret c-sum-merge-correct-with-rest
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (valid-sc-subterms c1-lst a)
                (valid-sc-subterms c2-lst a)
                (rp-term-listp c1-lst)
                (rp-term-listp c2-lst))
           (equal (sum (sum-list (rp-evlt coughed-s a))
                       (sum-list-eval coughed-pp-lst a)
                       (sum-list-eval c-merged-lst a)
                       (sum-list-eval to-be-coughed-c-lst a)
                       (sum-list-eval to-be-coughed-c-lst a)
                       rest)
                  (sum (sum-list-eval c1-lst a)
                       (sum-list-eval c2-lst a)
                       rest)))
  :fn c-sum-merge
  :hints (("Goal"
           :use ((:instance C-SUM-MERGE-CORRECT))
           :in-theory (e/d () (C-SUM-MERGE-CORRECT)))))


(defthm is-rp-of-cons
  (implies (and (syntaxp (quotep x))
                (not (equal x 'rp)))
           (not (is-rp (cons x y))))
  :hints (("Goal"
           :in-theory (e/d (is-rp) ()))))


(defthm valid-sc-of-cons-instance
  (equal (valid-sc `(cons ,x ,y) a)
         (and (valid-sc x a)
              (valid-sc y a)))
  :hints (("Goal"
           :in-theory (e/d (is-rp is-if) ()))))

(defthm valid-sc-of----instance
  (equal (valid-sc `(-- ,x) a)
         (and (valid-sc x a)))
  :hints (("Goal"
           :in-theory (e/d (is-rp is-if) ()))))

(defthm valid-sc-of-nil
  (VALID-SC ''NIL A))

(value-triple (hons-clear t))

(defret new-sum-merge-aux-correct
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (valid-sc-subterms sum-lst a)
                (rp-term-listp sum-lst))
           (and (valid-sc s a)
                (valid-sc-subterms pp-lst a)
                (valid-sc-subterms c-lst a)
                (valid-sc-subterms to-be-coughed-c-lst a)
                (equal (sum (sum-list (rp-evlt s a))
                            (sum-list-eval pp-lst a)
                            (sum-list-eval c-lst a)
                            (sum-list-eval to-be-coughed-c-lst a)
                            (sum-list-eval to-be-coughed-c-lst a))
                       (sum-list-eval sum-lst a))))
  :fn new-sum-merge-aux
  :hints (("Goal"
           :do-not-induct t
           :induct (new-sum-merge-aux sum-lst)
           :expand ((NEW-SUM-MERGE-AUX SUM-LST))
           :in-theory (e/d (new-sum-merge-aux
                            c-res
                            c-fix-arg-aux-correct-lemma
                            rp-evlt-of-ex-from-rp-reverse-only-atom-and-car
                            new-sum-merge-aux-dissect-term
                            new-sum-merge-aux-add-negated-coughed
                            (:induction NEW-SUM-MERGE-AUX)
                            sum-list-eval-of-cons
                            sum-list-eval-of-atom)
                           ((:REWRITE SUM-OF-NEGATED-ELEMENTS)
                            (:DEFINITION SUM-LIST-EVAL)
                            ;;(:REWRITE MINUS-OF-SUM)
                            (:TYPE-PRESCRIPTION RP-TERMP)

                            (:TYPE-PRESCRIPTION SUM-LIST-EVAL)
                            (:TYPE-PRESCRIPTION SINGLE-C-P$INLINE)
                            (:TYPE-PRESCRIPTION MULT-FORMULA-CHECKS)
                            (:TYPE-PRESCRIPTION SINGLE-S-P$INLINE)
                            (:REWRITE NOT-INCLUDE-RP-MEANS-VALID-SC-LST)
                            (:TYPE-PRESCRIPTION EX-FROM-SYNP)
                            (:TYPE-PRESCRIPTION SINGLE-C-RES-P$INLINE)
                            (:TYPE-PRESCRIPTION O<)
                            (:DEFINITION INCLUDE-FNC-SUBTERMS)
                            (:TYPE-PRESCRIPTION SUM-LIST-P$INLINE)
                            (:TYPE-PRESCRIPTION AND-LIST-P$INLINE)
                            (:REWRITE DEFAULT-CDR)
                            (:TYPE-PRESCRIPTION VALID-SC-SUBTERMS)
                            (:TYPE-PRESCRIPTION BINARY-SUM)
                            (:REWRITE DEFAULT-CAR)

                            (:REWRITE DUMMY-SUM-CANCEL-LEMMA1)
                            (:TYPE-PRESCRIPTION VALID-SC)
                            (:TYPE-PRESCRIPTION RP-TERM-LISTP)
                            (:DEFINITION NEW-SUM-MERGE-AUX)
                            (:REWRITE ACL2::O-P-O-INFP-CAR)
                            
                            rp-trans
                            rp-evlt-of-ex-from-rp
                            eval-and-all
                            rp-termp
                            rp-term-listp
                            valid-sc
                            VALID-SC-SUBTERMS
                            RP-TRANS-IS-TERM-WHEN-LIST-IS-ABSENT
                            (:REWRITE RP-EVL-OF-VARIABLE)
                            (:DEFINITION IS-FALIST))))))


(defret new-sum-merge-correct
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (valid-sc term a)
                (rp-termp term))
           (and (valid-sc s a)
                (valid-sc-subterms pp-lst a)
                (valid-sc-subterms c-lst a)
                (valid-sc-subterms to-be-coughed-c-lst a)
                (equal (sum (sum-list (rp-evlt s a))
                            (sum-list-eval pp-lst a)
                            (sum-list-eval c-lst a)
                            (sum-list-eval to-be-coughed-c-lst a)
                            (sum-list-eval to-be-coughed-c-lst a))
                       (sum-list (rp-evlt term a)))))
  :fn new-sum-merge
  :hints (("Goal"
           :do-not-induct t
           :in-theory (e/d (new-sum-merge) ())))) 



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; quarternaryp lemmas



(defthm f2-of-quarternaryp
  (implies (quarternaryp sum)
           (bitp (f2 sum)))
  :hints (("Goal"
           :in-theory (e/d (quarternaryp) ()))))



(defthm lte-of-the-same
  (not (gt a a))
  :hints (("Goal"
           :in-theory (e/d (rw-dir2)
                           (rw-dir1)))))


(defthmd quarternaryp-sum-aux-correct-dummy-lemma
  (not (LIGHT-PP-TERM-LIST-P (LIST (LIST 'SUM-LIST
                                         (CADR (EX-FROM-RP (CADR TERM)))))))
  :hints (("Goal"
           :in-theory (e/d (LIGHT-PP-TERM-LIST-P
                            PP-HAS-BITP-RP
                            EX-FROM-RP
                            is-rp
                            LIGHT-PP-TERM-P)
                           ()))))

(defthm LIGHT-PP-TERM-P-max-val
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (valid-sc term a)
                (LIGHT-PP-TERM-P term))
           (and (not (gt (rp-evlt term a)
                         1))
                (lte (rp-evlt term a)
                     1))))

(defthm LIGHT-PP-TERM-P-min-val
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (valid-sc term a)
                (LIGHT-PP-TERM-P term))
           (and (not (gt 0
                         (rp-evlt term a)))
                (lte 0
                     (rp-evlt term a)))))

(defthm lte-sum-lemma-1
  (implies (and (force (integerp a))
                (force (integerp b))
                (force (integerp x))
                (force (integerp y))
                (lte a b)
                (lte x y))
           (and (not (gt (sum a x)
                         (sum y b)))
                (not (gt (sum a x)
                         (sum b y)))))
  :hints (("Goal"
           :in-theory (e/d (sum
                            rw-dir2
                            ifix-opener)
                           (rw-dir1
                            +-IS-SUM)))))


(defthmd bitp-implies-integerp
  (implies (bitp x)
           (integerp x)))

(defthm LIGHT-PP-TERM-P-integerp
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (valid-sc term a)
                (LIGHT-PP-TERM-P term))
           (INTEGERP (RP-EVLT term A)))
  :hints (("Goal"
           :do-not-induct t
           :in-theory (e/d (LIGHT-PP-TERM-P
                            bitp-implies-integerp
                            rp-evlt-of-ex-from-rp-reverse-only-atom-and-car)
                           (rp-evlt-of-ex-from-rp)))))

(defthm LIGHT-PP-TERM-LIST-P-max-val
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (valid-sc-subterms lst a)
                (LIGHT-PP-TERM-LIST-P lst))
           (and (not (gt (SUM-LIST-EVAL lst a)
                         (len lst)))
                (lte (SUM-LIST-EVAL lst a)
                     (len lst))))
  :hints (("Goal"
           :induct (LIGHT-PP-TERM-LIST-P lst)
           :do-not-induct t
           :in-theory (e/d (LIGHT-PP-TERM-LIST-P) ()))))


(defthmd lte-dummy-lemma-1
  (implies (and (lte 0 a)
                (lte 0 b))
           (not (gt 0
                    (sum a b))))
  :hints (("Goal"
           :in-theory (e/d (rw-dir2 sum ifix)
                           (+-IS-SUM  rw-dir1)))))

(defthm LIGHT-PP-TERM-LIST-P-min-val
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (valid-sc-subterms lst a)
                (LIGHT-PP-TERM-LIST-P lst))
           (and (not (gt 0
                         (SUM-LIST-EVAL lst a)))
                (lte 0
                     (SUM-LIST-EVAL lst a))))
  :hints (("Goal"
           :induct (LIGHT-PP-TERM-LIST-P lst)
           :do-not-induct t
           :in-theory (e/d (LIGHT-PP-TERM-LIST-P
                            lte-dummy-lemma-1) ()))))


(defthm AND-LIST-P-max-val
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (AND-LIST-P term))
           (and (not (gt (rp-evlt term a)
                         1))
                (lte (rp-evlt term a)
                     1))))

(defthmd bitp-max-val
  (implies (bitp term)
           (and (not (gt term
                         1))
                (lte term
                     1))))

(defthmd bitp-min-val
  (implies (bitp term)
           (and (not (gt 0
                         term))
                (lte 0
                     term))))

(defthmd lte-implies-the-same
  (implies (lte a b)
           (not (gt a b)))
  :hints (("Goal"
           :in-theory (e/d (rw-dir2) (rw-dir1)))))

(defret quarternaryp-sum-aux-correct
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (valid-sc term a)
                valid)
           (and (<= (sum-list (rp-evlt term a))
                    res)
                (<= 0
                    (sum-list (rp-evlt term a)))))
  :fn quarternaryp-sum-aux
  :hints (("Goal"
           :do-not-induct t
           :induct (quarternaryp-sum-aux term)
           :in-theory (e/d (quarternaryp-sum-aux
                            lte-dummy-lemma-1
                            lte-implies-the-same
                            bitp-max-val
                            bitp-min-val
                            quarternaryp-sum-aux-correct-dummy-lemma
                            LIST-TO-LST
                            rp-evlt-of-ex-from-rp-reverse-only-atom-and-car)
                           (rp-evlt-of-ex-from-rp)))))

(defret quarternaryp-sum-aux-returns-natp
  (natp res)
  :fn quarternaryp-sum-aux
  :hints (("Goal"
           :do-not-induct t
           :induct (quarternaryp-sum-aux term)
           :in-theory (e/d (quarternaryp-sum-aux
                            rw-dir2)
                           (rw-dir1)))))

(defthm quarternaryp-sum-correct
    (implies (and (rp-evl-meta-extract-global-facts :state state)
                  (mult-formula-checks state)
                  (valid-sc term a)
                  (rp-termp term)
                  (quarternaryp-sum term))
             (quarternaryp (sum-list (rp-evlt term a))))
    :hints (("Goal"
             :use ((:instance quarternaryp-sum-aux-correct)
                   (:instance quarternaryp-sum-aux-returns-natp))
             :in-theory (e/d (quarternaryp-sum
                              quarternaryp
                              rw-dir2)
                             (natp
                              rw-dir1
                              quarternaryp-sum-aux-returns-natp
                              quarternaryp-sum-aux-correct
                              quarternaryp-sum-aux
                              REGULAR-RP-EVL-OF_C_WHEN_MULT-FORMULA-CHECKS
                              zp
                              REGULAR-RP-EVL-OF_C-RES_WHEN_MULT-FORMULA-CHECKS
                              rp-evlt-of-ex-from-rp
                              ex-from-rp-lemma1
                              RP-EVL-OF-VARIABLE
                              RP-TRANS-IS-TERM-WHEN-LIST-IS-ABSENT
                              ex-from-rp
                              ex-from-rp-loose
                              valid-sc
                              rp-termp)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; c-spec-meta-aux and s-spec-meta-aux


(defthm rp-evl-of-nil
  (equal (RP-EVL ''NIL A)
         nil))

(defret c-spec-meta-aux-correct
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (rp-termp arg-s)
                (rp-term-listp arg-pp-lst )
                (rp-term-listp arg-c-lst )
                (rp-term-listp to-be-coughed-c-lst )
                (valid-sc arg-s a)
                (valid-sc-subterms arg-pp-lst a)
                (valid-sc-subterms arg-c-lst a)
                (valid-sc-subterms to-be-coughed-c-lst a)
                (if quarternaryp
                    (quarternaryp 
                     (sum (sum-list (rp-evlt arg-s a))
                          (sum-list-eval arg-pp-lst a)
                          (sum-list-eval arg-c-lst a)
                          (sum-list-eval to-be-coughed-c-lst a)
                          (sum-list-eval to-be-coughed-c-lst a)))
                  t))
           (and (valid-sc res a)
                (equal (rp-evlt res a)
                       (f2 (sum (sum-list (rp-evlt arg-s a))
                                (sum-list-eval arg-pp-lst a)
                                (sum-list-eval arg-c-lst a)
                                (sum-list-eval to-be-coughed-c-lst a)
                                (sum-list-eval to-be-coughed-c-lst a))))))
  :fn c-spec-meta-aux
  :hints (("Goal"
           :do-not-induct t
           :use ((:instance c-fix-s-args-correct
                            (pp ARG-S)
                            (rest (sum (SUM-LIST-EVAL ARG-C-LST A)
                                       (SUM-LIST-EVAL ARG-PP-LST A))))
                 (:instance c-fix-pp-args-correct
                            (pp (CREATE-LIST-INSTANCE ARG-PP-LST))
                            (rest (sum (SUM-LIST-EVAL ARG-C-LST A)
                                       (SUM-LIST (RP-EVLT ARG-S A))))))
           :in-theory (e/d (c-spec-meta-aux
                            times2
                            valid-sc-single-step
                            f2-of-times2-reverse
                            rp-trans-lst-of-consp
                            c-res
                            sum-list-eval-of-atom
                            sum-list-eval-of-cons)
                           (f2-of-times2
                            (:REWRITE
                             RP-TRANS-IS-TERM-WHEN-LIST-IS-ABSENT)
                            (:TYPE-PRESCRIPTION RP-TERMP)
                            (:TYPE-PRESCRIPTION RP-TERM-LISTP)
                            (:TYPE-PRESCRIPTION O<)
                            (:DEFINITION EVAL-AND-ALL)
                            (:DEFINITION INCLUDE-FNC)
                            (:REWRITE NOT-INCLUDE-RP-MEANS-VALID-SC-LST)
                            (:REWRITE DEFAULT-CAR)
                            (:DEFINITION
                             INCLUDE-FNC-SUBTERMS)(:TYPE-PRESCRIPTION INCLUDE-FNC-SUBTERMS)
                             (:TYPE-PRESCRIPTION VALID-SC)
                            (:REWRITE SUM-OF-NEGATED-ELEMENTS)
                            (:REWRITE MINUS-OF-SUM)
                            (:REWRITE EX-FROM-SYNP-LEMMA1)
                            (:REWRITE DUMMY-SUM-CANCEL-LEMMA1)
                            (:REWRITE DEFAULT-CDR)
                            (:DEFINITION IS-SYNP$INLINE)
                            (:TYPE-PRESCRIPTION BINARY-SUM)
                            (:DEFINITION SUM-LIST-EVAL)
                            rp-trans
                            rp-trans-lst
                            rp-trans-of-quoted
                            RP-EVL-OF-QUOTE
                            c-fix-s-args-correct
                            c-fix-pp-args-correct
                            c-fix-pp-args-correct-2
                            c-fix-s-args-correct-2))))) 
                  



(defret s-spec-meta-aux-correct
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (rp-termp s)
                (rp-term-listp pp-lst)
                (rp-term-listp c-lst)
                (valid-sc s a)
                (valid-sc-subterms pp-lst a)
                (valid-sc-subterms c-lst a))
           (and (valid-sc res a)
                (equal (rp-evlt res a)
                       (m2 (sum (sum-list (rp-evlt s a))
                                (sum-list-eval pp-lst a)
                                (sum-list-eval c-lst a))))))
  :fn s-spec-meta-aux
  :hints (("Goal"
           :in-theory (e/d (s-spec-meta-aux) ()))))
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; s-c-spec-meta correct

(create-regular-eval-lemma c-s-spec 1 mult-formula-checks)
(create-regular-eval-lemma s-c-spec 1 mult-formula-checks)
(create-regular-eval-lemma c-spec 1 mult-formula-checks)
(create-regular-eval-lemma s-spec 1 mult-formula-checks)

(defthmd dummy-m2-lemma
  (implies (equal (sum x y z a a) m)
           (equal (equal (m2 (sum x y z))
                         (m2 m))
                  t))
  :hints (("Goal"
           :in-theory (e/d (sum-of-repeated-to-times2) ()))))
           

(defret s-c-spec-meta-correct
  (implies (and (rp-evl-meta-extract-global-facts :state state)
                (mult-formula-checks state)
                (rp-termp term)
                (valid-sc term a))
           (and (valid-sc res a)
                (equal (rp-evlt res a)
                       (rp-evlt term a))
                (dont-rw-syntaxp donw-rw)))
  :fn s-c-spec-meta
  :hints (("Goal"
           :use ((:instance new-sum-merge-correct
                            (term (CADR TERM))))
           :in-theory (e/d (s-c-spec-meta
                            dummy-m2-lemma)
                           (new-sum-merge-correct)))))
