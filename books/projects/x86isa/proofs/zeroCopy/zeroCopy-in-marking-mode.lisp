;; AUTHOR:
;; Shilpi Goel <shigoel@cs.utexas.edu>

(in-package "X86ISA")

(include-book "../utilities/system-level-mode/symbolic-simulation-in-marking-mode")

(local (include-book "centaur/bitops/ihs-extensions" :dir :system))
(local (include-book "centaur/bitops/signed-byte-p" :dir :system))
(local (include-book "arithmetic/top-with-meta" :dir :system))
(local (include-book "centaur/gl/gl" :dir :system))

(local (in-theory (e/d () (disjoint-p-of-remove-duplicates-equal))))

;; ======================================================================

;; Introducing the system-level program:

;;  1 mov %cr3,%rax
;;  2 mov %rax,-0x18(%rsp)
;;  3 mov -0x18(%rsp),%rdx
;;  4 mov %rdi,%rax
;;  5 shr $0x24,%rax
;;  6 and $0xff8,%eax
;;  7 and $0xfffffffffffff000,%rdx
;;  8 or %rdx,%rax
;;  9 mov (%rax),%rax
;; 10 test $0x1,%al
;; 11 je 400780 <rewire_dst_to_src+0x100>
;; 12 shr $0xc,%rax
;; 13 movabs $0xffffffffff,%r8
;; 14 mov %rdi,%rcx
;; 15 and %r8,%rax
;; 16 shr $0x1b,%rcx
;; 17 and $0xff8,%ecx
;; 18 shl $0xc,%rax
;; 19 or %rcx,%rax
;; 20 mov (%rax),%rax
;; 21 mov %rax,%rcx
;; 22 and $0x81,%ecx
;; 23 cmp $0x81,%rcx
;; 24 jne 400780 <rewire_dst_to_src+0x100>
;; 25 mov %rsi,%rcx
;; 26 movabs $0xfffffc0000000,%r9
;; 27 shr $0x24,%rcx
;; 28 and %rax,%r9
;; 29 and $0xff8,%ecx
;; 30 or %rdx,%rcx
;; 31 mov (%rcx),%rax
;; 32 test $0x1,%al
;; 33 je 400780 <rewire_dst_to_src+0x100>
;; 34 shr $0xc,%rax
;; 35 mov %rsi,%rdx
;; 36 and %r8,%rax
;; 37 shr $0x1b,%rdx
;; 38 and $0xff8,%edx
;; 39 shl $0xc,%rax
;; 40 or %rdx,%rax
;; 41 movabs $0xfff000003fffffff,%rdx
;; 42 and (%rax),%rdx
;; 43 or %r9,%rdx
;; 44 mov %rdx,(%rax)
;; 45 mov %rdx,%rax
;; 46 and $0x81,%eax
;; 47 cmp $0x81,%rax
;; 48 jne 400780 <rewire_dst_to_src+0x100>
;; 49 movabs $0xfffffc0000000,%rax
;; 50 and $0x3fffffff,%esi
;; 51 and $0x3fffffff,%edi
;; 52 and %rax,%rdx
;; 53 or %r9,%rdi
;; 54 xor %eax,%eax
;; 55 or %rsi,%rdx
;; 56 cmp %rdx,%rdi
;; 57 sete %al
;; 58 retq
;; 59 nopw %cs:0x0(%rax,%rax,1)
;; 60 mov $0xffffffffffffffff,%rax
;; 61 retq
;; 62 nopl 0x0(%rax,%rax,1)

(defconst *rewire_dst_to_src*

  '(#xF #x20 #xD8 #x48 #x89 #x44 #x24 #xE8
        #x48 #x8B #x54 #x24 #xE8 #x48 #x89 #xF8
        #x48 #xC1 #xE8 #x24 #x25 #xF8 #xF #x0
        #x0 #x48 #x81 #xE2 #x0 #xF0 #xFF #xFF
        #x48 #x9 #xD0 #x48 #x8B #x0 #xA8 #x1
        #xF #x84 #xD2 #x0 #x0 #x0 #x48 #xC1 #xE8
        #xC #x49 #xB8 #xFF #xFF #xFF #xFF #xFF
        #x0 #x0 #x0 #x48 #x89 #xF9 #x4C #x21
        #xC0 #x48 #xC1 #xE9 #x1B #x81 #xE1 #xF8
        #xF #x0 #x0 #x48 #xC1 #xE0 #xC #x48 #x9
        #xC8 #x48 #x8B #x0 #x48 #x89 #xC1 #x81
        #xE1 #x81 #x0 #x0 #x0 #x48 #x81 #xF9
        #x81 #x0 #x0 #x0 #xF #x85 #x94 #x0 #x0
        #x0 #x48 #x89 #xF1 #x49 #xB9 #x0 #x0 #x0
        #xC0 #xFF #xFF #xF #x0 #x48 #xC1 #xE9
        #x24 #x49 #x21 #xC1 #x81 #xE1 #xF8 #xF
        #x0 #x0 #x48 #x9 #xD1 #x48 #x8B #x1 #xA8
        #x1 #x74 #x70 #x48 #xC1 #xE8 #xC #x48
        #x89 #xF2 #x4C #x21 #xC0 #x48 #xC1 #xEA
        #x1B #x81 #xE2 #xF8 #xF #x0 #x0 #x48
        #xC1 #xE0 #xC #x48 #x9 #xD0 #x48 #xBA
        #xFF #xFF #xFF #x3F #x0 #x0 #xF0 #xFF
        #x48 #x23 #x10 #x4C #x9 #xCA #x48 #x89
        #x10 #x48 #x89 #xD0 #x25 #x81 #x0 #x0
        #x0 #x48 #x3D #x81 #x0 #x0 #x0 #x75 #x32
        #x48 #xB8 #x0 #x0 #x0 #xC0 #xFF #xFF
        #xF #x0 #x81 #xE6 #xFF #xFF #xFF #x3F
        #x81 #xE7 #xFF #xFF #xFF #x3F #x48 #x21
        #xC2 #x4C #x9 #xCF #x31 #xC0 #x48 #x9
        #xF2 #x48 #x39 #xD7 #xF #x94 #xC0 #xC3
        #x66 #x2E #xF #x1F #x84 #x0 #x0 #x0 #x0
        #x0 #x48 #xC7 #xC0 #xFF #xFF #xFF #xFF
        #xC3 #xF #x1F #x84 #x0 #x0 #x0 #x0 #x0))

(defconst *rewire_dst_to_src-len* (len *rewire_dst_to_src*))

(defun rewire_dst_to_src-clk () 58)

;; ======================================================================

;; Control printing:
(acl2::add-untranslate-pattern-function
 (program-at (create-canonical-address-list 272 (xr :rip 0 x86))
             '(15 32 216 72 137 68 36 232 72 139 84 36 232
                  72 137 248 72 193 232 36 37 248 15 0 0
                  72 129 226 0 240 255 255 72 9 208 72 139
                  0 168 1 15 132 210 0 0 0 72 193 232 12
                  73 184 255 255 255 255 255 0 0 0 72 137
                  249 76 33 192 72 193 233 27 129 225 248
                  15 0 0 72 193 224 12 72 9 200 72 139 0
                  72 137 193 129 225 129 0 0 0 72 129 249
                  129 0 0 0 15 133 148 0 0 0 72 137 241
                  73 185 0 0 0 192 255 255 15 0 72 193 233
                  36 73 33 193 129 225 248 15 0 0 72 9 209
                  72 139 1 168 1 116 112 72 193 232 12 72
                  137 242 76 33 192 72 193 234 27 129 226
                  248 15 0 0 72 193 224 12 72 9 208 72 186
                  255 255 255 63 0 0 240 255 72 35 16 76
                  9 202 72 137 16 72 137 208 37 129 0 0 0
                  72 61 129 0 0 0 117 50 72 184 0 0 0 192
                  255 255 15 0 129 230 255 255 255 63 129
                  231 255 255 255 63 72 33 194 76 9 207
                  49 192 72 9 242 72 57 215 15 148 192 195
                  102 46 15 31 132 0 0 0 0 0 72 199 192
                  255 255 255 255 195 15 31 132 0 0 0 0 0)
             x86)
 (program-at (create-canonical-address-list (len *rewire_dst_to_src*) (xr :rip 0 x86))
             *rewire_dst_to_src*
             x86))

;; ======================================================================

;; Proof of rewire_dst_to_src effects theorem:

(defthm loghead-negative
  (implies (and (syntaxp (and (quotep n)
                              (< (cadr n) 0)))
                (< n 0)
                (integerp n))
           (equal (loghead n x) 0)))

(define pml4-table-base-addr (x86)
  :enabled t
  (ash (cr3-slice :cr3-pdb (ctri *cr3* x86)) 12)
  ///

  (defthm-usb n52p-of-pml4-table-base-addr
    :hyp (x86p x86)
    :bound 52
    :concl (pml4-table-base-addr x86))

  (defthm pml4-table-base-addr-and-mv-nth-1-wb
    (equal (pml4-table-base-addr (mv-nth 1 (wb addr-lst x86)))
           (pml4-table-base-addr x86))))

(defun-nx page-dir-ptr-table-base-addr (lin-addr x86)
  (ash (loghead 40 (logtail
                    12
                    (combine-bytes
                     (mv-nth 1 (rb
                                (create-canonical-address-list
                                 8
                                 (pml4-table-entry-addr
                                  lin-addr
                                  (pml4-table-base-addr x86)))
                                :r x86)))))
       12))

;; The following is really a consequence of keeping
;; page-dir-ptr-table-base-addr enabled.
(defthm unsigned-byte-p-52-of-left-shifting-a-40-bit-vector-by-12
  (implies (unsigned-byte-p 64 x)
           (unsigned-byte-p 52 (ash (loghead 40 (logtail 12 x)) 12))))

(defthm page-dir-ptr-table-base-addr-and-mv-nth-1-wb
  (implies (and
            ;; The physical addresses corresponding to the PML4TE are
            ;; disjoint from the physical addresses pertaining to the
            ;; write.
            (disjoint-p
             (mv-nth 1 (las-to-pas
                        (create-canonical-address-list
                         8
                         (pml4-table-entry-addr lin-addr (pml4-table-base-addr x86)))
                        :r (cpl x86) x86))
             (mv-nth 1 (las-to-pas (strip-cars addr-lst) :w (cpl x86) x86)))
            ;; The physical addresses corresponding to the PML4TE are
            ;; disjoint from the translation-governing addresses
            ;; pertaining to the PML4TE.
            (disjoint-p
             (mv-nth
              1
              (las-to-pas
               (create-canonical-address-list
                8
                (pml4-table-entry-addr lin-addr (pml4-table-base-addr x86)))
               :r (cpl x86) (double-rewrite x86)))
             (all-translation-governing-addresses
              (create-canonical-address-list
               8
               (pml4-table-entry-addr lin-addr (pml4-table-base-addr x86)))
              (double-rewrite x86)))
            ;; The physical addresses pertaining to the write are
            ;; disjoint from the translation-governing addresses
            ;; pertaining to the PML4TE.
            (disjoint-p
             (mv-nth 1 (las-to-pas (strip-cars addr-lst) :w (cpl x86) (double-rewrite x86)))
             (all-translation-governing-addresses
              (create-canonical-address-list
               8
               (pml4-table-entry-addr
                lin-addr
                (pml4-table-base-addr x86)))
              (double-rewrite x86)))
            ;; The physical addresses corresponding to the PML4TE are
            ;; disjoint from the translation-governing addresses
            ;; pertaining to the write.
;;; TODO: Why do we need this hyp.?
            (disjoint-p
             (mv-nth
              1
              (las-to-pas
               (create-canonical-address-list
                8
                (pml4-table-entry-addr lin-addr (pml4-table-base-addr x86)))
               :r (cpl x86)
               (double-rewrite x86)))
             (all-translation-governing-addresses
              (strip-cars addr-lst)
              (double-rewrite x86)))
            (not (mv-nth 0 (las-to-pas (strip-cars addr-lst) :w (cpl x86) x86)))
            (addr-byte-alistp addr-lst)
            (not (programmer-level-mode x86))
            (x86p x86))
           (equal (page-dir-ptr-table-base-addr lin-addr (mv-nth 1 (wb addr-lst x86)))
                  (page-dir-ptr-table-base-addr lin-addr x86)))
  :hints (("Goal" :do-not-induct t
           :in-theory (e/d* ()
                            (rewrite-rb-to-rb-alt
                             member-p-strip-cars-of-remove-duplicate-keys)))))

(def-gl-export pml4-table-entry-addr-to-C-program-optimized-form
  :hyp (and (canonical-address-p v-addr)
            (equal (logtail 40 cr3) 0) ;; MBZ
            (unsigned-byte-p 64 cr3))
  :concl (equal (pml4-table-entry-addr v-addr (ash (loghead 40 (logtail 12 cr3)) 12))
                (logior (logand -4096 (logext 64 cr3))
                        (logand 4088 (loghead 28 (logtail 36 v-addr)))))
  :g-bindings
  (gl::auto-bindings (:mix (:nat v-addr 64) (:nat cr3 64))))

(def-gl-export page-dir-ptr-table-entry-addr-to-C-program-optimized-form
  :hyp (and (canonical-address-p v-addr)
            (equal (loghead 12 base-addr) 0)
            (unsigned-byte-p 52 base-addr))
  :concl (equal (page-dir-ptr-table-entry-addr v-addr base-addr)
                (logior (logand 4088 (loghead 32 (logtail 27 v-addr)))
                        base-addr))
  :g-bindings
  (gl::auto-bindings (:mix (:nat v-addr 64) (:nat base-addr 64))))

(def-gl-export page-dir-ptr-table-entry-P=1-and-PS=1-zf-spec-helper-1
  :hyp (and (equal (part-select entry :low 7 :width 1) 1)
            (equal (part-select entry :low 0 :width 1) 1)
            (unsigned-byte-p 64 entry))
  :concl (equal (zf-spec (loghead 64 (+ -129 (logand 129 (loghead 32 entry))))) 1)
  :g-bindings
  (gl::auto-bindings (:nat entry 64)))

(def-gl-export page-dir-ptr-table-entry-P=1-and-PS=1-zf-spec-helper-2
  :hyp (and (equal (part-select source-entry :low 7 :width 1) 1)
            (equal (part-select source-entry :low 0 :width 1) 1)
            (equal (part-select destination-entry :low 7 :width 1) 1)
            (equal (part-select destination-entry :low 0 :width 1) 1)
            (unsigned-byte-p 64 source-entry)
            (unsigned-byte-p 64 destination-entry))
  :concl (equal (zf-spec
                 (loghead 64
                          (+
                           -129
                           (logand 129 (logior
                                        (loghead 30 destination-entry)
                                        (logand 3221225472 (loghead 32 source-entry)))))))
                1)
  :g-bindings
  (gl::auto-bindings (:mix (:nat destination-entry 64) (:nat source-entry 64))))

(def-gl-export page-dir-ptr-table-entry-P=1-and-PS=1-zf-spec-helper-3
  :hyp (and (unsigned-byte-p 64 source-entry)
            (unsigned-byte-p 64 destination-entry))
  :concl (equal
          (zf-spec
           (loghead 64 (+ (logand 4503598553628672 (logext 64 source-entry))
                          (- (logand 4503598553628672
                                     (logior (logand -4503598553628673 (logext 64 destination-entry))
                                             (logand 4503598553628672 (logext 64 source-entry))))))))
          1)
  :g-bindings
  (gl::auto-bindings (:mix (:nat destination-entry 64) (:nat source-entry 64))))

;; ======================================================================

;; Assumptions:

(defun-nx x86-state-okp (x86)
  (and
   (x86p x86)
   (equal (xr :ms 0 x86) nil)
   (equal (xr :fault 0 x86) nil)
   (not (alignment-checking-enabled-p x86))
   (not (programmer-level-mode x86))
   (page-structure-marking-mode x86)
   ;; Current Privilege Level == 0.
   (equal (cpl x86) 0)
   ;; CR3's reserved bits must be zero (MBZ).
   (equal (logtail 40 (ctri *cr3* x86)) 0)))

(defun-nx program-ok-p (x86)
  (and
   ;; Program addresses are canonical.
   (canonical-address-p (+ *rewire_dst_to_src-len* (xr :rip 0 x86)))
   ;; Program is located at linear address (rip x86) in the memory.
   (program-at (create-canonical-address-list *rewire_dst_to_src-len* (xr :rip 0 x86))
               *rewire_dst_to_src* x86)
   ;; No errors encountered while translating the linear addresses
   ;; where the program is located.
   (not (mv-nth 0 (las-to-pas
                   (create-canonical-address-list *rewire_dst_to_src-len* (xr :rip 0 x86))
                   :x (cpl x86) x86)))

   ;; The following preconditions were not required in the non-marking
   ;; mode.

   ;; Translation-governing addresses of the program are
   ;; disjoint from the physical addresses corresponding to
   ;; the program.
   (disjoint-p
    (all-translation-governing-addresses
     (create-canonical-address-list *rewire_dst_to_src-len* (xr :rip 0 x86))
     x86)
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list *rewire_dst_to_src-len* (xr :rip 0 x86))
               :x (cpl x86) x86)))
   ;; Physical addresses corresponding to the program are
   ;; disjoint from the paging physical addresses.
   (disjoint-p
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list *rewire_dst_to_src-len* (xr :rip 0 x86))
               :x (cpl x86) x86))
    (open-qword-paddr-list
     (gather-all-paging-structure-qword-addresses x86)))))

(defthmd x86-state-okp-and-program-ok-p-implies-program-alt
  (implies (and (x86-state-okp x86)
                (program-ok-p x86))
           (program-at-alt
            (create-canonical-address-list *rewire_dst_to_src-len* (xr :rip 0 x86))
            *rewire_dst_to_src* x86)))

(defun-nx stack-ok-p (x86)
  (and
   ;; Stack addresses are canonical.
   (canonical-address-p (+ -24 (xr :rgf *rsp* x86)))
   (canonical-address-p (+ 8 (xr :rgf *rsp* x86)))
   ;; Writing to stack: No errors encountered while translating the
   ;; linear addresses corresponding to the program stack.
   (not (mv-nth 0 (las-to-pas
                   (create-canonical-address-list 8 (+ -24 (xr :rgf *rsp* x86)))
                   :w (cpl x86) x86)))
   ;; Reading from stack: No errors encountered while translating the
   ;; linear addresses corresponding to the stack.
   (not (mv-nth 0 (las-to-pas
                   (create-canonical-address-list 8 (+ -24 (xr :rgf *rsp* x86)))
                   :r (cpl x86) x86)))
   ;; Reading from stack: The stack is located in a contiguous region
   ;; of memory --- no overlaps among physical addresses of the
   ;; stack.
   ;; I need this hypothesis so that the lemma
   ;; rb-wb-equal-in-system-level-non-marking-mode can fire.
   (no-duplicates-p
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list 8 (+ -24 (xr :rgf *rsp* x86)))
               :r (cpl x86) x86)))
   ;; Translation-governing addresses of the stack are disjoint from
   ;; the physical addresses of the stack.
   (disjoint-p
    (all-translation-governing-addresses
     (create-canonical-address-list 8 (+ -24 (xr :rgf *rsp* x86)))
     x86)
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list 8 (+ -24 (xr :rgf *rsp* x86)))
               :w (cpl x86) x86)))

   ;; The following preconditions were not required in the non-marking
   ;; mode.

   ;; Physical addresses corresponding to the stack are disjoint from
   ;; the paging physical addresses.
   (disjoint-p
    (mv-nth 1
            (las-to-pas (create-canonical-address-list
                         8 (+ -24 (xr :rgf *rsp* x86)))
                        :w (cpl x86)
                        x86))
    (open-qword-paddr-list
     (gather-all-paging-structure-qword-addresses x86)))))

(defun-nx source-addresses-ok-p (x86)
  (and
   ;; Source addresses are canonical.
   (canonical-address-p (xr :rgf *rdi* x86))
   (canonical-address-p (+ -1 *2^30* (xr :rgf *rdi* x86)))
   ;; Source address is 1G-aligned.
   (equal (loghead 30 (xr :rgf *rdi* x86)) 0)
   ;; No errors encountered while translating the source linear
   ;; addresses.
   (not (mv-nth 0 (las-to-pas
                   (create-canonical-address-list *2^30* (xr :rgf *rdi* x86))
                   :r (cpl x86) x86)))))

(defun-nx destination-addresses-ok-p (x86)
  (and
   ;; Destination addresses are canonical.
   (canonical-address-p (xr :rgf *rsi* x86))
   (canonical-address-p (+ -1 *2^30* (xr :rgf *rsi* x86)))
   ;; Destination address is 1G-aligned.
   (equal (loghead 30 (xr :rgf *rsi* x86)) 0)
   ;; No errors encountered while translating the destination
   ;; linear addresses.
   (not
    (mv-nth 0 (las-to-pas
               (create-canonical-address-list *2^30* (xr :rgf *rsi* x86))
               :r (cpl x86) x86)))))

(defun-nx source-PML4TE-ok-p (x86)
  (and
   ;; PML4TE linear addresses are canonical.
   (canonical-address-p
    (+ 7 (pml4-table-entry-addr (xr :rgf *rdi* x86) (pml4-table-base-addr x86))))
   ;; No errors encountered while translating the PML4TE linear addresses.
   (not (mv-nth 0 (las-to-pas
                   (create-canonical-address-list
                    8 (pml4-table-entry-addr (xr :rgf *rdi* x86) (pml4-table-base-addr x86)))
                   :r (cpl x86) x86)))
   ;; PML4TE has P = 1 (i.e., it is present).
   (equal
    (loghead
     1
     (logext
      64
      (combine-bytes
       (mv-nth
        1
        (rb
         (create-canonical-address-list
          8
          (pml4-table-entry-addr (xr :rgf *rdi* x86) (pml4-table-base-addr x86)))
         :r x86)))))
    1)))

(defun-nx source-PDPTE-ok-p (x86)
  (and
   ;; PDPTE linear addresses are canonical.
   (canonical-address-p
    (+ 7 (page-dir-ptr-table-entry-addr
          (xr :rgf *rdi* x86)
          (page-dir-ptr-table-base-addr (xr :rgf *rdi* x86) x86))))
   ;; No errors encountered while translating the PDPTE linear addresses.
   (not (mv-nth 0 (las-to-pas
                   (create-canonical-address-list
                    8
                    (page-dir-ptr-table-entry-addr
                     (xr :rgf *rdi* x86)
                     (page-dir-ptr-table-base-addr (xr :rgf *rdi* x86) x86)))
                   :r (cpl x86) x86)))
   ;; PDPTE does not have the P or PS bit cleared (i.e., the
   ;; entry is present and it points to a 1G page).
   (equal (part-select
           (combine-bytes
            (mv-nth 1
                    (rb
                     (create-canonical-address-list
                      8
                      (page-dir-ptr-table-entry-addr
                       (xr :rgf *rdi* x86)
                       (page-dir-ptr-table-base-addr (xr :rgf *rdi* x86) x86)))
                     :r x86)))
           :low 0 :width 1)
          1)
   (equal (part-select
           (combine-bytes
            (mv-nth 1
                    (rb
                     (create-canonical-address-list
                      8
                      (page-dir-ptr-table-entry-addr
                       (xr :rgf *rdi* x86)
                       (page-dir-ptr-table-base-addr (xr :rgf *rdi* x86) x86)))
                     :r x86)))
           :low 7 :width 1)
          1)))

(defun-nx destination-PML4TE-ok-p (x86)
  (and
   ;; PML4TE linear addresses are canonical.
   (canonical-address-p
    (+ 7 (pml4-table-entry-addr (xr :rgf *rsi* x86) (pml4-table-base-addr x86))))
   ;; No errors encountered while translating the PML4TE linear addresses.
   (not (mv-nth 0 (las-to-pas
                   (create-canonical-address-list
                    8 (pml4-table-entry-addr (xr :rgf *rsi* x86) (pml4-table-base-addr x86)))
                   :r (cpl x86) x86)))
   ;; PML4TE is has P = 1 (i.e., it is present).
   (equal
    (loghead
     1
     (logext
      64
      (combine-bytes
       (mv-nth
        1
        (rb
         (create-canonical-address-list
          8
          (pml4-table-entry-addr (xr :rgf *rsi* x86) (pml4-table-base-addr x86)))
         :r x86)))))
    1)))

(defun-nx destination-PDPTE-ok-p (x86)
  (and
   ;; PDPTE linear addresses are canonical.
   (canonical-address-p
    (page-dir-ptr-table-entry-addr
     (xr :rgf *rsi* x86)
     (page-dir-ptr-table-base-addr (xr :rgf *rsi* x86) x86)))
   (canonical-address-p
    (+ 7 (page-dir-ptr-table-entry-addr
          (xr :rgf *rsi* x86)
          (page-dir-ptr-table-base-addr (xr :rgf *rsi* x86) x86))))
   ;; No errors encountered while translating the PDPTE linear
   ;; addresses on behalf of a read.
   (not (mv-nth 0 (las-to-pas
                   (create-canonical-address-list
                    8
                    (page-dir-ptr-table-entry-addr
                     (xr :rgf *rsi* x86)
                     (page-dir-ptr-table-base-addr (xr :rgf *rsi* x86) x86)))
                   :r (cpl x86) x86)))
   ;; No errors encountered while translating the PDPTE linear
   ;; addresses on behalf of a write.
   (not (mv-nth 0 (las-to-pas
                   (create-canonical-address-list
                    8
                    (page-dir-ptr-table-entry-addr
                     (xr :rgf *rsi* x86)
                     (page-dir-ptr-table-base-addr (xr :rgf *rsi* x86) x86)))
                   :w (cpl x86) x86)))
   ;; Destination PDPTE does not have the P or PS bit cleared (i.e.,
   ;; the entry is present and it points to a 1G page).
   (equal (part-select
           (combine-bytes
            (mv-nth 1
                    (rb
                     (create-canonical-address-list
                      8
                      (page-dir-ptr-table-entry-addr
                       (xr :rgf *rsi* x86)
                       (page-dir-ptr-table-base-addr (xr :rgf *rsi* x86) x86)))
                     :r x86)))
           :low 0 :width 1)
          1)
   (equal (part-select
           (combine-bytes
            (mv-nth 1
                    (rb
                     (create-canonical-address-list
                      8
                      (page-dir-ptr-table-entry-addr
                       (xr :rgf *rsi* x86)
                       (page-dir-ptr-table-base-addr (xr :rgf *rsi* x86) x86)))
                     :r x86)))
           :low 7 :width 1)
          1)))

(defun-nx return-instruction-address-ok-p (x86)
  (and
   ;; Return address on the stack is canonical.
   (canonical-address-p
    (logext 64
            (combine-bytes
             (mv-nth 1
                     (rb (create-canonical-address-list 8 (xr :rgf *rsp* x86))
                         :r x86)))))
   ;; Reading from stack for the final ret instruction doesn't cause
   ;; errors.
   (not (mv-nth 0 (las-to-pas
                   (create-canonical-address-list 8 (xr :rgf *rsp* x86))
                   :r (cpl x86) x86)))))

(defun-nx program-and-stack-no-interfere-p (x86)
  (and
   ;; The physical addresses corresponding to the program and stack
   ;; are disjoint.
   (disjoint-p
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list *rewire_dst_to_src-len* (xr :rip 0 x86))
               :x (cpl x86) x86))
    (mv-nth 1
            (las-to-pas
             (create-canonical-address-list 8 (+ -24 (xr :rgf *rsp* x86)))
             :w (cpl x86) x86)))
   ;; Translation-governing addresses of the program are disjoint from
   ;; the physical addresses of the stack.
   (disjoint-p
    (all-translation-governing-addresses
     (create-canonical-address-list *rewire_dst_to_src-len* (xr :rip 0 x86))
     x86)
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list 8 (+ -24 (xr :rgf *rsp* x86)))
               :w (cpl x86) x86)))))

(defun-nx source-PML4TE-and-stack-no-intefere-p (x86)
  (and
   ;; The translation-governing addresses of PML4TE addresses are
   ;; disjoint from the physical addresses corresponding to the stack.
   (disjoint-p
    (all-translation-governing-addresses
     (create-canonical-address-list
      8 (pml4-table-entry-addr (xr :rgf *rdi* x86) (pml4-table-base-addr x86)))
     x86)
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list 8 (+ -24 (xr :rgf *rsp* x86))) :w (cpl x86) x86)))
   ;; The PML4TE physical addresses are disjoint from the
   ;; stack physical addresses.
   (disjoint-p
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list
                8
                (pml4-table-entry-addr (xr :rgf *rdi* x86) (pml4-table-base-addr x86)))
               :r (cpl x86) x86))
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list 8 (+ -24 (xr :rgf *rsp* x86))) :w (cpl x86) x86)))))

(defun-nx source-PDPTE-and-stack-no-interfere-p (x86)
  (and
   ;; The translation-governing addresses of PDPTE addresses are
   ;; disjoint from the physical addresses corresponding to the stack.
   (disjoint-p
    (all-translation-governing-addresses
     (create-canonical-address-list
      8
      (page-dir-ptr-table-entry-addr
       (xr :rgf *rdi* x86)
       (page-dir-ptr-table-base-addr (xr :rgf *rdi* x86) x86)))
     x86)
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list 8 (+ -24 (xr :rgf *rsp* x86))) :w (cpl x86) x86)))
   ;; The PDPTE physical addresses are disjoint from the stack
   ;; physical addresses.
   (disjoint-p
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list
                8
                (page-dir-ptr-table-entry-addr
                 (xr :rgf *rdi* x86)
                 (page-dir-ptr-table-base-addr (xr :rgf *rdi* x86) x86)))
               :r (cpl x86) x86))
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list 8 (+ -24 (xr :rgf *rsp* x86))) :w (cpl x86) x86)))))

(defun-nx destination-PML4TE-and-stack-no-interfere-p (x86)
  (and
   ;; The translation-governing addresses of PML4TE addresses are
   ;; disjoint from the physical addresses corresponding to the stack.
   (disjoint-p
    (all-translation-governing-addresses
     (create-canonical-address-list
      8 (pml4-table-entry-addr (xr :rgf *rsi* x86) (pml4-table-base-addr x86)))
     x86)
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list 8 (+ -24 (xr :rgf *rsp* x86))) :w (cpl x86) x86)))
   ;; The PML4TE physical addresses are disjoint from the stack
   ;; physical addresses.
   (disjoint-p
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list
                8
                (pml4-table-entry-addr (xr :rgf *rsi* x86) (pml4-table-base-addr x86)))
               :r (cpl x86) x86))
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list 8 (+ -24 (xr :rgf *rsp* x86))) :w (cpl x86) x86)))))

(defun-nx destination-PDPTE-and-stack-no-interfere-p (x86)
  (and
   ;; The translation-governing addresses of PDPTE addresses are
   ;; disjoint from the physical addresses corresponding to the stack.
   (disjoint-p
    (all-translation-governing-addresses
     (create-canonical-address-list
      8
      (page-dir-ptr-table-entry-addr
       (xr :rgf *rsi* x86)
       (page-dir-ptr-table-base-addr (xr :rgf *rsi* x86) x86)))
     x86)
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list 8 (+ -24 (xr :rgf *rsp* x86))) :w (cpl x86) x86)))
   ;; The destination PDPTE is disjoint from the stack.
   (disjoint-p
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list
                8
                (page-dir-ptr-table-entry-addr
                 (xr :rgf *rsi* x86)
                 (page-dir-ptr-table-base-addr (xr :rgf *rsi* x86) x86)))
               :r (cpl x86) x86))
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list 8 (+ -24 (xr :rgf *rsp* x86))) :w (cpl x86) x86)))))

(defun-nx destination-PDPTE-and-program-no-interfere-p (x86)
  ;; We need these assumptions because the destination PDPTE is
  ;; modified, and we need to make sure that this modification does
  ;; not affect the program in any way.
  (and
   ;; The physical addresses corresponding to the program are disjoint
   ;; from those of the PDPTE (on behalf of a write).
   (disjoint-p
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list *rewire_dst_to_src-len* (xr :rip 0 x86))
               :x (cpl x86) x86))
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list
                8
                (page-dir-ptr-table-entry-addr
                 (xr :rgf *rsi* x86)
                 (page-dir-ptr-table-base-addr (xr :rgf *rsi* x86) x86)))
               :w (cpl x86) x86)))

   ;; Translation-governing addresses of the program are disjoint from
   ;; the PDPTE physical addresses (on behalf of a write).
   (disjoint-p
    (all-translation-governing-addresses
     (create-canonical-address-list *rewire_dst_to_src-len* (xr :rip 0 x86))
     x86)
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list
                8
                (page-dir-ptr-table-entry-addr
                 (xr :rgf *rsi* x86)
                 (page-dir-ptr-table-base-addr (xr :rgf *rsi* x86) x86)))
               :w (cpl x86) x86)))))

(defun-nx ret-instruction-and-destination-PDPTE-no-interfere-p (x86)
  (and
   ;; The translation-governing addresses of the ret address are
   ;; disjoint from the destination PDPTE.
   (disjoint-p
    (all-translation-governing-addresses
     (create-canonical-address-list 8 (xr :rgf *rsp* x86)) x86)
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list
                8
                (page-dir-ptr-table-entry-addr
                 (xr :rgf *rsi* x86)
                 (page-dir-ptr-table-base-addr (xr :rgf *rsi* x86) x86)))
               :r (cpl x86) x86)))

   ;; The destination PDPTE is disjoint from the ret address
   ;; on the stack.
   (disjoint-p
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list 8 (xr :rgf *rsp* x86))
               :r (cpl x86) x86))
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list
                8
                (page-dir-ptr-table-entry-addr
                 (xr :rgf *rsi* x86)
                 (page-dir-ptr-table-base-addr (xr :rgf *rsi* x86) x86)))
               :r (cpl x86) x86)))))

(defun-nx return-address-and-stack-no-interfere-p (x86)
  (and
   ;; The ret address on the stack is disjoint from the rest of the
   ;; stack.
   (disjoint-p
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list 8 (xr :rgf *rsp* x86))
               :r (cpl x86) x86))
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list 8 (+ -24 (xr :rgf *rsp* x86))) :w (cpl x86) x86)))

   ;; The translation-governing addresses of the return address on the
   ;; stack are disjoint from the physical addresses of the rest of
   ;; the stack.
   (disjoint-p
    (all-translation-governing-addresses
     (create-canonical-address-list 8 (xr :rgf *rsp* x86)) x86)
    (mv-nth 1
            (las-to-pas (create-canonical-address-list 8 (+ -24 (xr :rgf *rsp* x86)))
                        :w (cpl x86) x86)))))

(defun-nx well-formedness-assumptions (x86)
  (and
   (x86-state-okp x86)
   (program-ok-p x86)
   (stack-ok-p x86)
   (source-addresses-ok-p x86)
   (destination-addresses-ok-p x86)
   (source-PML4TE-ok-p x86)
   (source-PDPTE-ok-p x86)
   (destination-PML4TE-ok-p x86)
   (destination-PDPTE-ok-p x86)
   (return-instruction-address-ok-p x86)))

(defun-nx non-interference-assumptions (x86)
  (and
   (program-and-stack-no-interfere-p x86)
   (source-PML4TE-and-stack-no-intefere-p x86)
   (source-PDPTE-and-stack-no-interfere-p x86)
   (destination-PML4TE-and-stack-no-interfere-p x86)
   (destination-PDPTE-and-stack-no-interfere-p x86)
   (destination-PDPTE-and-program-no-interfere-p x86)
   (ret-instruction-and-destination-PDPTE-no-interfere-p x86)
   (return-address-and-stack-no-interfere-p x86)))

(defun-nx rewire_dst_to_src-assumptions (x86)
  (and (well-formedness-assumptions x86)
       (non-interference-assumptions x86)))

;; ======================================================================

(encapsulate
  ()

  (local
   (in-theory (e/d (las-to-pas-subset-p member-p subset-p)
                   (disjoint-p-of-open-qword-paddr-list-and-remove-duplicates-equal
                    not-disjoint-p-of-open-qword-paddr-list-and-remove-duplicates-equal
                    member-p-of-open-qword-paddr-list-and-remove-duplicates-equal
                    not-member-p-of-open-qword-paddr-list-and-remove-duplicates-equal
                    xlate-equiv-memory-and-xr-mem-from-rest-of-memory))))

  (defthm xr-fault-ia32e-la-to-pa
    (implies (not (mv-nth 0 (ia32e-la-to-pa lin-addr r-w-x cpl x86)))
             (equal (xr :fault index (mv-nth 2 (ia32e-la-to-pa lin-addr r-w-x cpl x86)))
                    (xr :fault index x86)))
    :hints (("Goal" :in-theory (e/d* (ia32e-la-to-pa
                                      ia32e-la-to-pa-pml4-table
                                      ia32e-la-to-pa-page-dir-ptr-table
                                      ia32e-la-to-pa-page-directory
                                      ia32e-la-to-pa-page-table)
                                     (force
                                      (force)
                                      (:definition not)
                                      (:meta acl2::mv-nth-cons-meta))))))

  (defthm xr-fault-rb-alt-state-in-system-level-mode
    (equal (xr :fault index (mv-nth 2 (rb-alt l-addrs r-w-x x86)))
           (xr :fault index x86))
    :hints (("Goal" :in-theory (e/d* (rb-alt las-to-pas)
                                     (rewrite-rb-to-rb-alt
                                      force (force))))))

  (defthm xr-fault-and-get-prefixes
    (implies (not (mv-nth 0 (las-to-pas
                             (create-canonical-address-list cnt start-rip)
                             :x (cpl x86) x86)))
             (equal (xr :fault index (mv-nth 2 (get-prefixes start-rip prefixes cnt x86)))
                    (xr :fault index x86)))
    :hints (("Goal"
             :induct (get-prefixes start-rip prefixes cnt x86)
             :in-theory (e/d* (get-prefixes rm08)
                              (rm08-to-rb
                               not force (force))))))

  (defthm xr-fault-and-get-prefixes-alt
    (equal (xr :fault index (mv-nth 2 (get-prefixes-alt start-rip prefixes cnt x86)))
           (xr :fault index x86))
    :hints (("Goal" :in-theory (e/d* (get-prefixes-alt)
                                     (rewrite-get-prefixes-to-get-prefixes-alt
                                      not force (force))))))

  (defthm rb-alt-xw-values-in-system-level-mode
    (implies (and (not (programmer-level-mode x86))
                  (not (equal fld :mem))
                  (not (equal fld :rflags))
                  (not (equal fld :ctr))
                  (not (equal fld :seg-visible))
                  (not (equal fld :msr))
                  (not (equal fld :fault))
                  (not (equal fld :programmer-level-mode))
                  (not (equal fld :page-structure-marking-mode)))
             (and (equal (mv-nth 0 (rb-alt addr r-w-x (xw fld index value x86)))
                         (mv-nth 0 (rb-alt addr r-w-x x86)))
                  (equal (mv-nth 1 (rb-alt addr r-w-x (xw fld index value x86)))
                         (mv-nth 1 (rb-alt addr r-w-x x86)))))
    :hints (("Goal" :in-theory (e/d* (rb-alt) (rewrite-rb-to-rb-alt force (force))))))

  (defthm rb-alt-xw-rflags-not-ac-values-in-system-level-mode
    (implies (and (not (programmer-level-mode x86))
                  (equal (rflags-slice :ac value)
                         (rflags-slice :ac (rflags x86))))
             (and (equal (mv-nth 0 (rb-alt addr r-w-x (xw :rflags 0 value x86)))
                         (mv-nth 0 (rb-alt addr r-w-x x86)))
                  (equal (mv-nth 1 (rb-alt addr r-w-x (xw :rflags 0 value x86)))
                         (mv-nth 1 (rb-alt addr r-w-x x86)))))
    :hints (("Goal" :in-theory (e/d* (rb-alt) (force (force) rewrite-rb-to-rb-alt)))))

  (defthm rb-alt-xw-state-in-system-level-mode
    (implies (and (not (programmer-level-mode x86))
                  (not (equal fld :mem))
                  (not (equal fld :rflags))
                  (not (equal fld :ctr))
                  (not (equal fld :seg-visible))
                  (not (equal fld :msr))
                  (not (equal fld :fault))
                  (not (equal fld :programmer-level-mode))
                  (not (equal fld :page-structure-marking-mode)))
             (equal (mv-nth 2 (rb-alt addr r-w-x (xw fld index value x86)))
                    (xw fld index value (mv-nth 2 (rb-alt addr r-w-x x86)))))
    :hints (("Goal" :in-theory (e/d* (rb-alt) (rewrite-rb-to-rb-alt force (force))))))

  (defthm rb-alt-xw-rflags-not-ac-state-in-system-level-mode
    (implies (and (not (programmer-level-mode x86))
                  (equal (rflags-slice :ac value)
                         (rflags-slice :ac (rflags x86))))
             (equal (mv-nth 2 (rb-alt addr r-w-x (xw :rflags 0 value x86)))
                    (xw :rflags 0 value (mv-nth 2 (rb-alt addr r-w-x x86)))))
    :hints (("Goal" :in-theory (e/d* (rb-alt) (rewrite-rb-to-rb-alt force (force))))))

  (defthm gather-all-paging-structure-qword-addresses-!flgi
    (equal (gather-all-paging-structure-qword-addresses (!flgi index val x86))
           (gather-all-paging-structure-qword-addresses (double-rewrite x86)))
    :hints (("Goal" :in-theory (e/d* (!flgi) (force (force))))))

  (defthm rb-alt-values-and-!flgi-in-system-level-mode
    (implies (and (not (equal index *ac*))
                  (not (programmer-level-mode x86))
                  (x86p x86))
             (and (equal (mv-nth 0 (rb-alt l-addrs r-w-x (!flgi index value x86)))
                         (mv-nth 0 (rb-alt l-addrs r-w-x x86)))
                  (equal (mv-nth 1 (rb-alt l-addrs r-w-x (!flgi index value x86)))
                         (mv-nth 1 (rb-alt l-addrs r-w-x x86)))))
    :hints (("Goal" :do-not-induct t
             :in-theory (e/d* (rb-alt) (rewrite-rb-to-rb-alt force (force))))))

  (defthm rb-and-!flgi-state-in-system-level-mode
    (implies (and (not (equal index *ac*))
                  (not (programmer-level-mode x86))
                  (x86p x86))
             (equal (mv-nth 2 (rb lin-addr r-w-x (!flgi index value x86)))
                    (!flgi index value (mv-nth 2 (rb lin-addr r-w-x x86)))))
    :hints (("Goal"
             :do-not-induct t
             :cases ((equal index *iopl*))
             :use ((:instance rflags-slice-ac-simplify
                              (index index)
                              (rflags (xr :rflags 0 x86)))
                   (:instance rb-xw-rflags-not-ac-state-in-system-level-mode
                              (addr lin-addr)
                              (value (logior (loghead 32 (ash (loghead 1 value) (nfix index)))
                                             (logand (xr :rflags 0 x86)
                                                     (loghead 32 (lognot (expt 2 (nfix index))))))))
                   (:instance rb-xw-rflags-not-ac-state-in-system-level-mode
                              (addr lin-addr)
                              (value (logior (ash (loghead 2 value) 12)
                                             (logand 4294955007 (xr :rflags 0 x86))))))
             :in-theory (e/d* (!flgi-open-to-xw-rflags)
                              (rewrite-rb-to-rb-alt force (force))))))

  (defthm rb-alt-and-!flgi-state-in-system-level-mode
    (implies (and (not (equal index *ac*))
                  (not (programmer-level-mode x86))
                  (x86p x86))
             (equal (mv-nth 2 (rb-alt lin-addr r-w-x (!flgi index value x86)))
                    (!flgi index value (mv-nth 2 (rb-alt lin-addr r-w-x x86)))))
    :hints (("Goal"
             :do-not-induct t
             :in-theory (e/d* (rb-alt)
                              (rewrite-rb-to-rb-alt force (force))))))

  (defthm get-prefixes-xw-values-in-system-level-mode
    (implies (and (not (programmer-level-mode x86))
                  (not (equal fld :mem))
                  (not (equal fld :rflags))
                  (not (equal fld :ctr))
                  (not (equal fld :seg-visible))
                  (not (equal fld :msr))
                  (not (equal fld :fault))
                  (not (equal fld :programmer-level-mode))
                  (not (equal fld :page-structure-marking-mode)))
             (and (equal (mv-nth 0 (get-prefixes start-rip prefixes cnt (xw fld index value x86)))
                         (mv-nth 0 (get-prefixes start-rip prefixes cnt x86)))
                  (equal (mv-nth 1 (get-prefixes start-rip prefixes cnt (xw fld index value x86)))
                         (mv-nth 1 (get-prefixes start-rip prefixes cnt x86)))))
    :hints (("Goal"
             :induct (get-prefixes start-rip prefixes cnt x86)
             :expand (get-prefixes start-rip prefixes cnt (xw fld index value x86))
             :in-theory (e/d* (get-prefixes)
                              (rewrite-get-prefixes-to-get-prefixes-alt
                               force (force))))))

  (defthm get-prefixes-xw-state-in-system-level-mode
    (implies (and (not (programmer-level-mode x86))
                  (not (equal fld :mem))
                  (not (equal fld :rflags))
                  (not (equal fld :ctr))
                  (not (equal fld :seg-visible))
                  (not (equal fld :msr))
                  (not (equal fld :fault))
                  (not (equal fld :programmer-level-mode))
                  (not (equal fld :page-structure-marking-mode)))
             (equal (mv-nth 2 (get-prefixes start-rip prefixes cnt (xw fld index value x86)))
                    (xw fld index value (mv-nth 2 (get-prefixes start-rip prefixes cnt x86)))))
    :hints (("Goal"
             :induct (get-prefixes start-rip prefixes cnt x86)
             :expand (get-prefixes start-rip prefixes cnt (xw fld index value x86))
             :in-theory (e/d* (get-prefixes)
                              (rewrite-get-prefixes-to-get-prefixes-alt
                               force (force))))))

  (defthm get-prefixes-alt-xw-values-in-system-level-mode
    (implies (and (not (programmer-level-mode x86))
                  (not (equal fld :mem))
                  (not (equal fld :rflags))
                  (not (equal fld :ctr))
                  (not (equal fld :seg-visible))
                  (not (equal fld :msr))
                  (not (equal fld :fault))
                  (not (equal fld :programmer-level-mode))
                  (not (equal fld :page-structure-marking-mode)))
             (and (equal (mv-nth 0 (get-prefixes-alt start-rip prefixes cnt (xw fld index value x86)))
                         (mv-nth 0 (get-prefixes-alt start-rip prefixes cnt x86)))
                  (equal (mv-nth 1 (get-prefixes-alt start-rip prefixes cnt (xw fld index value x86)))
                         (mv-nth 1 (get-prefixes-alt start-rip prefixes cnt x86)))))
    :hints (("Goal"
             :in-theory (e/d* (get-prefixes-alt)
                              (rewrite-get-prefixes-to-get-prefixes-alt
                               force (force))))))

  (defthm get-prefixes-alt-xw-state-in-system-level-mode
    (implies (and (not (programmer-level-mode x86))
                  (not (equal fld :mem))
                  (not (equal fld :rflags))
                  (not (equal fld :ctr))
                  (not (equal fld :seg-visible))
                  (not (equal fld :msr))
                  (not (equal fld :fault))
                  (not (equal fld :programmer-level-mode))
                  (not (equal fld :page-structure-marking-mode)))
             (equal (mv-nth 2 (get-prefixes-alt start-rip prefixes cnt (xw fld index value x86)))
                    (xw fld index value (mv-nth 2 (get-prefixes-alt start-rip prefixes cnt x86)))))
    :hints (("Goal"
             :in-theory (e/d* (get-prefixes-alt)
                              (rewrite-get-prefixes-to-get-prefixes-alt
                               force (force))))))

  (defthm get-prefixes-xw-rflags-not-ac-state-in-system-level-mode
    (implies (and (not (programmer-level-mode x86))
                  (equal (rflags-slice :ac value)
                         (rflags-slice :ac (rflags x86))))
             (equal (mv-nth 2 (get-prefixes start-rip prefixes cnt (xw :rflags 0 value x86)))
                    (xw :rflags 0 value (mv-nth 2 (get-prefixes start-rip prefixes cnt x86)))))
    :hints (("Goal"
             :induct (get-prefixes start-rip prefixes cnt x86)
             :expand (get-prefixes start-rip prefixes cnt (xw :rflags 0 value x86))
             :in-theory (e/d* (get-prefixes)
                              (rewrite-get-prefixes-to-get-prefixes-alt
                               force (force))))))

  (defthm get-prefixes-and-!flgi-state-in-system-level-mode
    (implies (and (not (equal index *ac*))
                  (not (programmer-level-mode x86))
                  (x86p x86))
             (equal (mv-nth 2 (get-prefixes start-rip prefixes cnt (!flgi index value x86)))
                    (!flgi index value (mv-nth 2 (get-prefixes start-rip prefixes cnt x86)))))
    :hints (("Goal"
             :do-not-induct t
             :cases ((equal index *iopl*))
             :use ((:instance rflags-slice-ac-simplify
                              (index index)
                              (rflags (xr :rflags 0 x86)))
                   (:instance get-prefixes-xw-rflags-not-ac-state-in-system-level-mode
                              (value (logior (loghead 32 (ash (loghead 1 value) (nfix index)))
                                             (logand (xr :rflags 0 x86)
                                                     (loghead 32 (lognot (expt 2 (nfix index))))))))
                   (:instance get-prefixes-xw-rflags-not-ac-state-in-system-level-mode
                              (value (logior (ash (loghead 2 value) 12)
                                             (logand 4294955007 (xr :rflags 0 x86))))))
             :in-theory (e/d* (!flgi-open-to-xw-rflags
                               !flgi)
                              (rewrite-get-prefixes-to-get-prefixes-alt force (force))))))

  (defthm get-prefixes-xw-rflags-not-ac-values-in-system-level-mode
    (implies (and (not (programmer-level-mode x86))
                  (equal (rflags-slice :ac value)
                         (rflags-slice :ac (rflags x86))))
             (and
              (equal (mv-nth 0 (get-prefixes start-rip prefixes cnt (xw :rflags 0 value x86)))
                     (mv-nth 0 (get-prefixes start-rip prefixes cnt x86)))
              (equal (mv-nth 1 (get-prefixes start-rip prefixes cnt (xw :rflags 0 value x86)))
                     (mv-nth 1 (get-prefixes start-rip prefixes cnt x86)))))
    :hints (("Goal"
             :induct (get-prefixes start-rip prefixes cnt x86)
             :expand (get-prefixes start-rip prefixes cnt (xw :rflags 0 value x86))
             :in-theory (e/d* (get-prefixes)
                              (rewrite-get-prefixes-to-get-prefixes-alt
                               force (force))))))

  (defthm get-prefixes-values-and-!flgi-in-system-level-mode
    (implies (and (not (equal index *ac*))
                  (not (programmer-level-mode x86))
                  (x86p x86))
             (and (equal (mv-nth 0 (get-prefixes start-rip prefixes cnt (!flgi index value x86)))
                         (mv-nth 0 (get-prefixes start-rip prefixes cnt x86)))
                  (equal (mv-nth 1 (get-prefixes start-rip prefixes cnt (!flgi index value x86)))
                         (mv-nth 1 (get-prefixes start-rip prefixes cnt x86)))))
    :hints (("Goal"
             :do-not-induct t
             :cases ((equal index *iopl*))
             :use ((:instance rflags-slice-ac-simplify
                              (index index)
                              (rflags (xr :rflags 0 x86)))
                   (:instance get-prefixes-xw-rflags-not-ac-values-in-system-level-mode
                              (value (logior (loghead 32 (ash (loghead 1 value) (nfix index)))
                                             (logand (xr :rflags 0 x86)
                                                     (loghead 32 (lognot (expt 2 (nfix index))))))))
                   (:instance get-prefixes-xw-rflags-not-ac-values-in-system-level-mode
                              (value (logior (ash (loghead 2 value) 12)
                                             (logand 4294955007 (xr :rflags 0 x86))))))
             :in-theory (e/d* (!flgi-open-to-xw-rflags
                               !flgi)
                              (get-prefixes-xw-rflags-not-ac-values-in-system-level-mode
                               rewrite-get-prefixes-to-get-prefixes-alt
                               force (force))))))

  (defthm get-prefixes-alt-values-and-!flgi-in-system-level-mode
    (implies (and (not (equal index *ac*))
                  (x86p x86))
             (and (equal (mv-nth 0 (get-prefixes-alt start-rip prefixes cnt (!flgi index value x86)))
                         (mv-nth 0 (get-prefixes-alt start-rip prefixes cnt x86)))
                  (equal (mv-nth 1 (get-prefixes-alt start-rip prefixes cnt (!flgi index value x86)))
                         (mv-nth 1 (get-prefixes-alt start-rip prefixes cnt x86)))))
    :hints (("Goal"
             :do-not-induct t
             :in-theory (e/d* (get-prefixes-alt)
                              (rewrite-get-prefixes-to-get-prefixes-alt
                               force (force))))))

  (defthm get-prefixes-alt-and-!flgi-state-in-system-level-mode
    (implies (and (not (equal index *ac*))
                  (not (programmer-level-mode x86))
                  (x86p x86))
             (equal (mv-nth 2 (get-prefixes-alt start-rip prefixes cnt (!flgi index value x86)))
                    (!flgi index value (mv-nth 2 (get-prefixes-alt start-rip prefixes cnt x86)))))
    :hints (("Goal"
             :do-not-induct t
             :in-theory (e/d* (get-prefixes-alt)
                              (rewrite-get-prefixes-to-get-prefixes-alt
                               force (force))))))

  (defthm flgi-and-mv-nth-2-rb-alt
    (equal (flgi index (mv-nth 2 (rb-alt l-addrs r-w-x x86)))
           (flgi index x86))
    :hints (("Goal" :in-theory (e/d* (flgi) ()))))

  (defthm alignment-checking-enabled-p-and-mv-nth-2-rb-alt
    (equal (alignment-checking-enabled-p (mv-nth 2 (rb-alt l-addrs r-w-x x86)))
           (alignment-checking-enabled-p x86))
    :hints (("Goal" :in-theory (e/d* (alignment-checking-enabled-p) ()))))

  (defthm flgi-and-mv-nth-2-get-prefixes-alt
    (equal (flgi index (mv-nth 2 (get-prefixes-alt start-rip prefixes cnt x86)))
           (flgi index x86))
    :hints (("Goal" :in-theory (e/d* (flgi) ()))))

  (defthm alignment-checking-enabled-p-and-mv-nth-2-get-prefixes-alt
    (equal (alignment-checking-enabled-p (mv-nth 2 (get-prefixes-alt start-rip prefixes cnt x86)))
           (alignment-checking-enabled-p x86))
    :hints (("Goal" :in-theory (e/d* (alignment-checking-enabled-p) ()))))

  (defthm mv-nth-1-wb-and-!flgi-commute-in-marking-mode
    ;; Subsumes MV-NTH-1-WB-AND-!FLGI-COMMUTE
    (implies (not (equal index *ac*))
             (equal (mv-nth 1 (wb addr-lst (!flgi index val x86)))
                    (!flgi index val (mv-nth 1 (wb addr-lst x86)))))
    :hints (("Goal" :in-theory (e/d* (!flgi rflags-slice-ac-simplify
                                            !flgi-open-to-xw-rflags)
                                     (force (force))))))

  (defthm xr-fault-las-to-pas
    (implies (not (mv-nth 0 (las-to-pas l-addrs r-w-x cpl (double-rewrite x86))))
             (equal (xr :fault 0
                        (mv-nth 2 (las-to-pas l-addrs r-w-x cpl x86)))
                    (xr :fault 0 x86)))
    :hints (("Goal" :in-theory (e/d* (las-to-pas) (force (force))))))

  (defthm xr-fault-wb-in-system-level-marking-mode
    (implies
     (not (mv-nth 0 (las-to-pas (strip-cars addr-lst)
                                :w (loghead 2 (xr :seg-visible 1 x86))
                                (double-rewrite x86))))
     (equal (xr :fault 0 (mv-nth 1 (wb addr-lst x86)))
            (xr :fault 0 x86)))
    :hints
    (("Goal"
      :do-not-induct t
      :in-theory (e/d* (wb)
                       (member-p-strip-cars-of-remove-duplicate-keys
                        (:meta acl2::mv-nth-cons-meta)
                        force (force)))))))

(def-ruleset rewire_dst_to_src-disable
  '((:type-prescription natp-pml4-table-entry-addr)
    (:rewrite acl2::consp-when-member-equal-of-atom-listp)
    (:rewrite ia32e-la-to-pa-xw-state)
    (:rewrite r-w-x-is-irrelevant-for-mv-nth-1-ia32e-la-to-pa-when-no-errors)
    (:linear adding-7-to-pml4-table-entry-addr)
    (:linear *physical-address-size*p-pml4-table-entry-addr)
    (:rewrite las-to-pas-xw-state)
    (:rewrite acl2::equal-of-booleans-rewrite)
    (:rewrite loghead-unequal)
    (:rewrite negative-logand-to-positive-logand-with-integerp-x)
    (:definition combine-bytes)
    (:rewrite |(logand -4096 base-addr) = base-addr when low 12 bits are 0|)
    (:rewrite xr-ia32e-la-to-pa)
    (:rewrite acl2::nfix-when-not-natp)
    (:rewrite acl2::nfix-when-natp)
    (:rewrite constant-upper-bound-of-logior-for-naturals)
    (:linear combine-bytes-size-for-rm64-programmer-level-mode)
    (:rewrite acl2::natp-when-integerp)
    (:rewrite acl2::natp-when-gte-0)
    (:rewrite 4k-aligned-physical-address-helper)
    (:rewrite bitops::signed-byte-p-of-logtail)
    (:linear adding-7-to-page-dir-ptr-table-entry-addr)
    (:linear *physical-address-size*p-page-dir-ptr-table-entry-addr)
    (:type-prescription adding-7-to-pml4-table-entry-addr)
    (:type-prescription adding-7-to-page-dir-ptr-table-entry-addr)
    (:rewrite acl2::signed-byte-p-logext)
    (:type-prescription booleanp)
    (:rewrite loghead-64-n64-to-i64-canonical-address)
    (:type-prescription pml4-table-base-addr)
    (:rewrite get-prefixes-opener-lemma-group-4-prefix)
    (:rewrite get-prefixes-opener-lemma-group-3-prefix)
    (:rewrite get-prefixes-opener-lemma-group-2-prefix)
    (:rewrite get-prefixes-opener-lemma-group-1-prefix)
    (:rewrite get-prefixes-alt-opener-lemma-group-4-prefix-in-marking-mode)
    (:rewrite get-prefixes-alt-opener-lemma-group-3-prefix-in-marking-mode)
    (:rewrite get-prefixes-alt-opener-lemma-group-2-prefix-in-marking-mode)
    (:rewrite get-prefixes-alt-opener-lemma-group-1-prefix-in-marking-mode)
    (:definition member-p)
    (:linear unsigned-byte-p-of-combine-bytes)
    (:type-prescription acl2::|x < y  =>  0 < -x+y|)
    (:rewrite default-+-2)
    (:rewrite acl2::natp-rw)
    (:rewrite ia32e-la-to-pa-lower-12-bits)
    (:rewrite default-+-1)
    (:rewrite acl2::ash-0)
    (:rewrite acl2::zip-open)
    (:rewrite loghead-of-non-integerp)
    (:type-prescription addr-byte-alistp-create-addr-bytes-alist)
    (:rewrite canonical-address-p-limits-thm-3)
    (:rewrite canonical-address-p-limits-thm-2)
    (:rewrite zf-spec-thm)
    (:linear acl2::loghead-upper-bound)
    (:linear bitops::logior-<-0-linear-2)
    (:linear size-of-combine-bytes)
    (:rewrite disjoint-p-subset-p)
    (:definition binary-append)
    (:definition create-addr-bytes-alist)
    (:rewrite member-p-of-subset-is-member-p-of-superset)
    (:linear rgfi-is-i64p . 1)
    (:rewrite member-p-cdr)
    (:rewrite bitops::unsigned-byte-p-when-unsigned-byte-p-less)
    (:rewrite acl2::difference-unsigned-byte-p)
    (:linear rgfi-is-i64p . 2)
    (:rewrite acl2::append-when-not-consp)
    (:linear rip-is-i48p . 2)
    (:linear rip-is-i48p . 1)
    (:type-prescription byte-ify)
    (:rewrite acl2::ifix-when-not-integerp)
    (:rewrite bitops::basic-unsigned-byte-p-of-+)
    (:rewrite disjoint-p-append-1)
    (:rewrite default-<-1)
    (:rewrite default-car)
    (:rewrite default-cdr)
    (:meta acl2::cancel_plus-lessp-correct)
    (:rewrite wb-not-consp-addr-lst)
    (:definition nthcdr)
    (:rewrite subset-p-cdr-y)
    (:rewrite ia32e-la-to-pa-lower-12-bits-value-of-address-when-error)
    (:rewrite default-<-2)
    (:type-prescription n52p-mv-nth-1-ia32e-la-to-pa)
    (:meta acl2::cancel_plus-equal-correct)
    (:definition nth)
    (:rewrite consp-create-addr-bytes-alist)
    (:rewrite subset-p-reflexive)
    (:meta acl2::cancel_times-equal-correct)
    (:rewrite set::sets-are-true-lists)
    (:linear rflags-is-n32p)
    (:rewrite consp-byte-ify)
    (:definition true-listp)
    (:type-prescription rflags-is-n32p)
    (:rewrite cdr-append-is-append-cdr)
    (:type-prescription bitops::logtail-natp)
    (:rewrite subset-p-cdr-x)
    (:rewrite bitops::logbitp-nonzero-of-bit)
    (:rewrite set::nonempty-means-set)
    (:type-prescription xw)
    (:type-prescription consp-create-addr-bytes-alist-in-terms-of-len)
    (:type-prescription consp-create-addr-bytes-alist)
    (:type-prescription natp-combine-bytes)
    (:type-prescription true-listp)
    (:rewrite unsigned-byte-p-of-logtail)
    (:rewrite bitops::logbitp-when-bitmaskp)
    (:type-prescription all-translation-governing-addresses)
    (:type-prescription set::setp-type)
    (:type-prescription set::empty-type)
    (:rewrite acl2::equal-constant-+)
    (:definition byte-listp)
    (:rewrite unsigned-byte-p-of-ash)
    (:rewrite bitops::normalize-logbitp-when-mods-equal)
    (:rewrite bitops::logbitp-of-negative-const)
    (:rewrite bitops::logbitp-of-mask)
    (:rewrite bitops::logbitp-of-const)
    (:rewrite greater-logbitp-of-unsigned-byte-p . 1)
    (:meta bitops::open-logbitp-of-const-lite-meta)
    (:rewrite rb-returns-byte-listp)
    (:rewrite car-of-append)
    (:type-prescription rb-returns-true-listp)
    (:rewrite bitops::signed-byte-p-when-unsigned-byte-p-smaller)
    (:rewrite bitops::signed-byte-p-when-signed-byte-p-smaller)
    (:type-prescription consp-append)
    (:type-prescription bitops::logand-natp-type-2)
    (:definition acons)
    (:rewrite unsigned-byte-p-of-combine-bytes)
    (:rewrite unsigned-byte-p-of-logior)
    (:type-prescription natp)
    (:rewrite set::in-set)
    (:type-prescription acl2::logtail-type)
    (:rewrite acl2::member-of-cons)
    (:type-prescription true-listp-create-addr-bytes-alist)
    (:type-prescription rb-returns-byte-listp)
    (:rewrite rationalp-implies-acl2-numberp)
    (:type-prescription bitops::ash-natp-type)
    (:type-prescription combine-bytes)
    (:definition n08p$inline)
    (:definition len)
    (:rewrite xr-and-ia32e-la-to-pa-page-directory-in-non-marking-mode)
    (:rewrite bitops::logsquash-of-loghead-zero)
    (:rewrite default-unary-minus)
    (:rewrite len-of-rb-in-programmer-level-mode)
    (:type-prescription acl2::true-listp-append)
    (:linear bitops::upper-bound-of-logand . 2)
    (:rewrite weed-out-irrelevant-logand-when-first-operand-constant)
    (:rewrite logand-redundant)
    (:linear ash-monotone-2)
    (:linear bitops::logand->=-0-linear-2)
    (:linear bitops::upper-bound-of-logand . 1)
    (:linear bitops::logand->=-0-linear-1)
    (:linear mv-nth-1-idiv-spec)
    (:linear mv-nth-1-div-spec)
    (:rewrite unsigned-byte-p-of-logand-2)
    (:linear acl2::expt->-1)
    (:rewrite acl2::unsigned-byte-p-loghead)
    (:type-prescription zip)
    (:linear bitops::logand-<-0-linear)
    (:rewrite bitops::logior-fold-consts)
    (:linear <=-logior)
    (:linear member-p-pos-value)
    (:linear member-p-pos-1-value)
    (:linear bitops::logior->=-0-linear)
    (:rewrite no-duplicates-p-and-append)
    (:rewrite acl2::subsetp-member . 2)
    (:rewrite acl2::subsetp-member . 1)
    (:type-prescription wr32$inline)
    (:rewrite unsigned-byte-p-of-logand-1)
    (:rewrite subset-p-cons-member-p-lemma)
    (:rewrite member-p-of-not-a-consp)
    (:rewrite get-prefixes-opener-lemma-zero-cnt)
    (:rewrite acl2::expt-with-violated-guards)
    (:rewrite bitops::basic-signed-byte-p-of-+)
    (:type-prescription ash)
    (:linear acl2::expt-is-increasing-for-base>1)
    (:definition member-equal)
    (:linear bitops::logior-<-0-linear-1)
    (:linear bitops::upper-bound-of-logior-for-naturals)
    (:linear bitops::expt-2-lower-bound-by-logbitp)
    open-qword-paddr-list
    cdr-create-canonical-address-list
    subset-p-cons-2
    (:definition addr-range)
    (:rewrite las-to-pas-subset-p-with-l-addrs-from-bind-free)
    (:rewrite loghead-negative)
    (:rewrite member-p-cons)
    (:rewrite consp-of-create-canonical-address-list)
    (:rewrite car-create-canonical-address-list)
    (:type-prescription gather-all-paging-structure-qword-addresses)
    (:rewrite neg-addr-range=nil)
    (:definition no-duplicates-p)
    (:rewrite not-member-p-of-remove-duplicates-equal)
    (:rewrite acl2::remove-duplicates-equal-when-atom)
    (:rewrite consp-mv-nth-1-las-to-pas)
    (:rewrite subset-p-of-nil)
    (:rewrite cdr-mv-nth-1-las-to-pas)
    (:rewrite
     mv-nth-0-ia32e-la-to-pa-member-of-mv-nth-1-las-to-pas-if-lin-addr-member-p)
    (:rewrite get-prefixes-alt-opener-lemma-zero-cnt)
    (:rewrite member-p-of-nil)
    (:type-prescription bitops::part-select-width-low$inline)
    (:rewrite acl2::alistp-when-hons-duplicity-alist-p)
    (:rewrite
     mv-nth-1-ia32e-la-to-pa-member-of-mv-nth-1-las-to-pas-if-lin-addr-member-p)
    (:rewrite car-mv-nth-1-las-to-pas)
    (:rewrite acl2::zp-when-integerp)
    (:type-prescription acl2::hons-duplicity-alist-p)
    (:type-prescription consp-mv-nth-1-las-to-pas)
    (:rewrite gl::nonnil-symbol-listp-true-listp)
    (:rewrite subset-p-two-create-canonical-address-lists-same-base-address)
    (:type-prescription !flgi)
    (:rewrite ia32e-la-to-pa-in-programmer-level-mode)
    (:rewrite acl2::zp-when-gt-0)
    (:rewrite acl2::logtail-identity)
    (:type-prescription acl2::nonnil-symbol-listp)
    (:rewrite acl2::hons-duplicity-alist-p-when-not-consp)
    (:rewrite acl2::consp-of-car-when-atom-listp)
    (:rewrite not-member-p-when-disjoint-p-rewrite)
    (:rewrite no-duplicates-p-member-p-with-append)
    (:rewrite acl2::logext-identity)
    (:rewrite member-p-and-mult-8-qword-paddr-listp)
    (:rewrite cdr-canonical-address-listp)
    (:rewrite x86-run-halted)
    x86-fetch-decode-execute-opener
    member-p-strip-cars-of-remove-duplicate-keys
    not-disjoint-p-of-open-qword-paddr-list-and-remove-duplicates-equal
    disjoint-p-of-open-qword-paddr-list-and-remove-duplicates-equal
    not-member-p-of-open-qword-paddr-list-and-remove-duplicates-equal
    member-p-of-open-qword-paddr-list-and-remove-duplicates-equal
    mv-nth-1-ia32e-la-to-pa-when-error
    mv-nth-1-las-to-pas-when-error
    bitops::logand-with-negated-bitmask
    disjoint-p-of-open-qword-paddr-list-and-remove-duplicates-equal
    not-disjoint-p-of-open-qword-paddr-list-and-remove-duplicates-equal
    member-p-of-open-qword-paddr-list-and-remove-duplicates-equal
    not-member-p-of-open-qword-paddr-list-and-remove-duplicates-equal
    xlate-equiv-memory-and-xr-mem-from-rest-of-memory
    disjointness-of-all-translation-governing-addresses-from-all-translation-governing-addresses-subset-p
    member-p-of-remove-duplicates-equal
    unsigned-byte-p))

;; (verify
;;  (MV-NTH
;;   '0
;;   (LAS-TO-PAS
;;    (CREATE-CANONICAL-ADDRESS-LIST '8
;;                                   (BINARY-+ '-24 (XR ':RGF '4 X86)))
;;    ':W
;;    '0
;;    (MV-NTH
;;     '2
;;     (RB-ALT
;;      (CONS (BINARY-+ '7 (XR ':RIP '0 X86))
;;            'NIL)
;;      ':X
;;      (MV-NTH
;;       '2
;;       (RB-ALT
;;        (CONS (BINARY-+ '6 (XR ':RIP '0 X86))
;;              'NIL)
;;        ':X
;;        (MV-NTH
;;         '2
;;         (RB-ALT
;;          (CONS (BINARY-+ '5 (XR ':RIP '0 X86))
;;                'NIL)
;;          ':X
;;          (MV-NTH
;;           '2
;;           (RB-ALT
;;            (CONS (BINARY-+ '4 (XR ':RIP '0 X86))
;;                  'NIL)
;;            ':X
;;            (MV-NTH
;;             '2
;;             (GET-PREFIXES-ALT
;;              (BINARY-+ '3 (XR ':RIP '0 X86))
;;              '0
;;              '5
;;              (MV-NTH
;;               '2
;;               (RB-ALT
;;                (CONS (BINARY-+ '2 (XR ':RIP '0 X86))
;;                      'NIL)
;;                ':X
;;                (MV-NTH
;;                 '2
;;                 (RB-ALT (CONS (BINARY-+ '1 (XR ':RIP '0 X86))
;;                               'NIL)
;;                         ':X
;;                         (MV-NTH '2
;;                                 (GET-PREFIXES-ALT (XR ':RIP '0 X86)
;;                                                   '0
;;                                                   '5
;;                                                   X86)))))))))))))))))))

(in-theory
 ;; For the effects theorem:
 (e/d* (instruction-decoding-and-spec-rules
        shr-spec
        shr-spec-64
        sal/shl-spec
        sal/shl-spec-64
        gpr-and-spec-1
        gpr-and-spec-4
        gpr-and-spec-8
        gpr-sub-spec-8
        gpr-or-spec-8
        gpr-xor-spec-4
        jcc/cmovcc/setcc-spec
        top-level-opcode-execute
        two-byte-opcode-decode-and-execute
        x86-operand-from-modr/m-and-sib-bytes
        x86-effective-addr
        x86-effective-addr-from-sib
        x86-operand-to-reg/mem
        rr08 rr32 rr64 wr08 wr32 wr64
        rim08 rim32 rim64
        !flgi-undefined
        write-user-rflags

        pos
        las-to-pas-subset-p
        member-p
        subset-p

        rb-wb-equal-in-system-level-mode
        las-to-pas-subset-p)

       (rewire_dst_to_src-disable
        ;; !!! rb-alt-in-terms-of-rb-alt-subset-p-in-system-level-mode
        ;; !!! is good enough for now...
        combine-bytes-rb-alt-in-terms-of-rb-alt-subset-p-in-system-level-mode)))

#||

(encapsulate
  ()
  (defthm mv-nth-0-rb-and-xw-mem-in-system-level-mode
    (implies (and (disjoint-p
                   (list index)
                   (all-translation-governing-addresses l-addrs (double-rewrite x86)))
                  (canonical-address-listp l-addrs)
                  (physical-address-p index))
             (equal (mv-nth 0 (rb l-addrs r-w-x (xw :mem index value x86)))
                    (mv-nth 0 (rb l-addrs r-w-x x86))))
    :hints (("Goal" :in-theory (e/d* (rb
                                      disjoint-p
                                      las-to-pas)
                                     (rewrite-rb-to-rb-alt
                                      force (force))))))

  (defthm read-from-physical-memory-xw-mem
    (implies (disjoint-p (list index) p-addrs)
             (equal (read-from-physical-memory p-addrs (xw :mem index value x86))
                    (read-from-physical-memory p-addrs x86)))
    :hints (("Goal" :in-theory (e/d* (read-from-physical-memory
                                      disjoint-p
                                      member-p)
                                     ()))))

  (defthm mv-nth-1-rb-and-xw-mem-in-system-level-mode
    (implies (and
              (disjoint-p
               (list index)
               (all-translation-governing-addresses l-addrs (double-rewrite x86)))
              (disjoint-p
               (list index)
               (mv-nth 1 (las-to-pas l-addrs r-w-x (cpl x86) (double-rewrite x86))))
              (disjoint-p
               (all-translation-governing-addresses l-addrs (double-rewrite x86))
               (mv-nth 1 (las-to-pas l-addrs r-w-x (cpl x86) (double-rewrite x86))))
              (canonical-address-listp l-addrs)
              (physical-address-p index)
              (not (programmer-level-mode x86)))
             (equal (mv-nth 1 (rb l-addrs r-w-x (xw :mem index value x86)))
                    (mv-nth 1 (rb l-addrs r-w-x x86))))
    :hints (("Goal" :in-theory (e/d* (rb
                                      disjoint-p
                                      las-to-pas)
                                     (rewrite-rb-to-rb-alt
                                      xlate-equiv-memory-and-xr-mem-from-rest-of-memory
                                      force (force))))))

  (local
   (defthm get-prefixes-xw-mem-values-in-system-level-mode-helper-1
     (implies (and (not (zp cnt))
                   (canonical-address-p start-rip)
                   (canonical-address-p (+ cnt start-rip)))
              (canonical-address-p (+ 1 start-rip)))
     :hints (("Goal" :in-theory (e/d* (canonical-address-p
                                       signed-byte-p)
                                      ())))))


  (defthm get-prefixes-xw-mem-values-in-system-level-mode-helper-2
    (implies
     (and
      (disjoint-p
       (all-translation-governing-addresses (list start-rip) x86)
       (mv-nth 1 (las-to-pas (list start-rip) :x (cpl x86) x86)))
      (not (member-p index (mv-nth 1 (las-to-pas (list start-rip) :x (cpl x86) x86))))
      (not (member-p index (all-translation-governing-addresses (list start-rip) x86)))
      (canonical-address-p start-rip)
      (unsigned-byte-p 52 index)
      (unsigned-byte-p 8 value)
      (not (xr :programmer-level-mode 0 x86))
      (x86p x86))
     (and
      (equal (mv-nth 0 (get-prefixes start-rip prefixes 1 (xw :mem index value x86)))
             (mv-nth 0 (get-prefixes start-rip prefixes 1 x86)))
      (equal (mv-nth 1 (get-prefixes start-rip prefixes 1 (xw :mem index value x86)))
             (mv-nth 1 (get-prefixes start-rip prefixes 1 x86)))))
    :hints
    (("goal"
      :do-not '(preprocess)
      :expand
      ((get-prefixes start-rip prefixes 1 x86)
       (get-prefixes start-rip prefixes 1 (xw :mem index value x86)))
      :in-theory
      (e/d*
       (get-prefixes disjoint-p disjoint-p-append-1)
       (rewrite-get-prefixes-to-get-prefixes-alt
        rewrite-rb-to-rb-alt
        acl2::zp-open
        force (force))))))

  (local (in-theory (e/d* (disjoint-p-cons-1 member-p-of-nil) ())))

  (local
   (defthm get-prefixes-xw-mem-values-in-system-level-mode
     ;; TODO: Ugh, this is ugly. Need to fix the ugly subgoal hints soon.
     (implies
      (and
       (disjoint-p
        (mv-nth 1 (las-to-pas
                   (create-canonical-address-list cnt start-rip)
                   :x (cpl x86) x86))
        (open-qword-paddr-list
         (gather-all-paging-structure-qword-addresses x86)))

       (disjoint-p
        (all-translation-governing-addresses
         (create-canonical-address-list cnt start-rip) (double-rewrite x86))
        (mv-nth 1 (las-to-pas
                   (create-canonical-address-list cnt start-rip)
                   :x (cpl x86) (double-rewrite x86))))
       (disjoint-p
        (list index)
        (mv-nth 1 (las-to-pas (create-canonical-address-list cnt start-rip)
                              :x (cpl x86) (double-rewrite x86))))
       (disjoint-p
        (list index)
        (all-translation-governing-addresses
         (create-canonical-address-list cnt start-rip) (double-rewrite x86)))

       (not (mv-nth 0 (las-to-pas (create-canonical-address-list cnt start-rip) :x (cpl x86) x86)))

       (posp cnt)
       (canonical-address-p start-rip)
       (canonical-address-p (+ cnt start-rip))
       (physical-address-p index)
       (unsigned-byte-p 8 value)
       (not (programmer-level-mode x86))
       (page-structure-marking-mode x86)
       (x86p x86))
      (and
       (equal (mv-nth 0 (get-prefixes start-rip prefixes cnt (xw :mem index value x86)))
              (mv-nth 0 (get-prefixes start-rip prefixes cnt x86)))
       (equal (mv-nth 1 (get-prefixes start-rip prefixes cnt (xw :mem index value x86)))
              (mv-nth 1 (get-prefixes start-rip prefixes cnt x86)))))
     :hints
     (("Goal"
       :do-not '(preprocess)
       :induct (get-prefixes-two-x86-induct-hint
                start-rip prefixes cnt x86 (xw :mem index value x86))
       :in-theory (e/d* (get-prefixes)
                        (get-prefixes-opener-lemma-group-1-prefix-in-marking-mode
                         get-prefixes-opener-lemma-group-2-prefix-in-marking-mode
                         get-prefixes-opener-lemma-group-3-prefix-in-marking-mode
                         get-prefixes-opener-lemma-group-4-prefix-in-marking-mode
                         get-prefixes-opener-lemma-no-prefix-byte
                         get-prefixes-opener-lemma-zero-cnt
                         rewrite-get-prefixes-to-get-prefixes-alt
                         rewrite-rb-to-rb-alt
                         create-canonical-address-list
                         xlate-equiv-memory-and-two-get-prefixes-values
                         xlate-equiv-memory-and-xr-mem-from-rest-of-memory)))
      ("Subgoal *1/15.16" :do-not-induct t
       :expand ((get-prefixes start-rip prefixes cnt (xw :mem index value x86)))
       :in-theory (e/d* (get-prefixes disjoint-p disjoint-p-append-1)
                        (rewrite-get-prefixes-to-get-prefixes-alt
                         create-canonical-address-list
                         rewrite-rb-to-rb-alt
                         acl2::zp-open)))
      ("Subgoal *1/15.15" :do-not-induct t
       :expand ((get-prefixes start-rip prefixes cnt (xw :mem index value x86)))
       :in-theory (e/d* (get-prefixes disjoint-p disjoint-p-append-1)
                        (rewrite-get-prefixes-to-get-prefixes-alt
                         create-canonical-address-list
                         rewrite-rb-to-rb-alt
                         acl2::zp-open)))
      ("Subgoal *1/15.2" :do-not-induct t
       :expand ((get-prefixes start-rip prefixes cnt (xw :mem index value x86)))
       :in-theory (e/d* (get-prefixes disjoint-p disjoint-p-append-1)
                        (rewrite-get-prefixes-to-get-prefixes-alt
                         create-canonical-address-list
                         rewrite-rb-to-rb-alt
                         acl2::zp-open)))
      ("Subgoal *1/15.1" :do-not-induct t
       :expand ((get-prefixes start-rip prefixes cnt (xw :mem index value x86)))
       :in-theory (e/d* (get-prefixes disjoint-p disjoint-p-append-1)
                        (rewrite-get-prefixes-to-get-prefixes-alt
                         create-canonical-address-list
                         rewrite-rb-to-rb-alt
                         acl2::zp-open)))
      ("Subgoal *1/12.16" :do-not-induct t
       :expand ((get-prefixes start-rip prefixes cnt (xw :mem index value x86)))
       :in-theory (e/d* (get-prefixes disjoint-p disjoint-p-append-1)
                        (rewrite-get-prefixes-to-get-prefixes-alt
                         create-canonical-address-list
                         rewrite-rb-to-rb-alt
                         acl2::zp-open)))
      ("Subgoal *1/12.15" :do-not-induct t
       :expand ((get-prefixes start-rip prefixes cnt (xw :mem index value x86)))
       :in-theory (e/d* (get-prefixes disjoint-p disjoint-p-append-1)
                        (rewrite-get-prefixes-to-get-prefixes-alt
                         create-canonical-address-list
                         rewrite-rb-to-rb-alt
                         acl2::zp-open)))
      ("Subgoal *1/12.2" :do-not-induct t
       :expand ((get-prefixes start-rip prefixes cnt (xw :mem index value x86)))
       :in-theory (e/d* (get-prefixes disjoint-p disjoint-p-append-1)
                        (rewrite-get-prefixes-to-get-prefixes-alt
                         create-canonical-address-list
                         rewrite-rb-to-rb-alt
                         acl2::zp-open)))
      ("Subgoal *1/12.1" :do-not-induct t
       :expand ((get-prefixes start-rip prefixes cnt (xw :mem index value x86)))
       :in-theory (e/d* (get-prefixes disjoint-p disjoint-p-append-1)
                        (rewrite-get-prefixes-to-get-prefixes-alt
                         create-canonical-address-list
                         rewrite-rb-to-rb-alt
                         acl2::zp-open)))
      ("Subgoal *1/9.16" :do-not-induct t
       :expand ((get-prefixes start-rip prefixes cnt (xw :mem index value x86)))
       :in-theory (e/d* (get-prefixes disjoint-p disjoint-p-append-1)
                        (rewrite-get-prefixes-to-get-prefixes-alt
                         create-canonical-address-list
                         rewrite-rb-to-rb-alt
                         acl2::zp-open)))
      ("Subgoal *1/9.15" :do-not-induct t
       :expand ((get-prefixes start-rip prefixes cnt (xw :mem index value x86)))
       :in-theory (e/d* (get-prefixes disjoint-p disjoint-p-append-1)
                        (rewrite-get-prefixes-to-get-prefixes-alt
                         create-canonical-address-list
                         rewrite-rb-to-rb-alt
                         acl2::zp-open)))
      ("Subgoal *1/9.2" :do-not-induct t
       :expand ((get-prefixes start-rip prefixes cnt (xw :mem index value x86)))
       :in-theory (e/d* (get-prefixes disjoint-p disjoint-p-append-1)
                        (rewrite-get-prefixes-to-get-prefixes-alt
                         create-canonical-address-list
                         rewrite-rb-to-rb-alt
                         acl2::zp-open)))
      ("Subgoal *1/9.1" :do-not-induct t
       :expand ((get-prefixes start-rip prefixes cnt (xw :mem index value x86)))
       :in-theory (e/d* (get-prefixes disjoint-p disjoint-p-append-1)
                        (rewrite-get-prefixes-to-get-prefixes-alt
                         create-canonical-address-list
                         rewrite-rb-to-rb-alt
                         acl2::zp-open)))
      ("Subgoal *1/6.16" :do-not-induct t
       :expand ((get-prefixes start-rip prefixes cnt (xw :mem index value x86)))
       :in-theory (e/d* (get-prefixes disjoint-p disjoint-p-append-1)
                        (rewrite-get-prefixes-to-get-prefixes-alt
                         create-canonical-address-list
                         rewrite-rb-to-rb-alt
                         acl2::zp-open)))
      ("Subgoal *1/6.15" :do-not-induct t
       :expand ((get-prefixes start-rip prefixes cnt (xw :mem index value x86)))
       :in-theory (e/d* (get-prefixes disjoint-p disjoint-p-append-1)
                        (rewrite-get-prefixes-to-get-prefixes-alt
                         create-canonical-address-list
                         rewrite-rb-to-rb-alt
                         acl2::zp-open)))
      ("Subgoal *1/6.2" :do-not-induct t
       :expand ((get-prefixes start-rip prefixes cnt (xw :mem index value x86)))
       :in-theory (e/d* (get-prefixes disjoint-p disjoint-p-append-1)
                        (rewrite-get-prefixes-to-get-prefixes-alt
                         create-canonical-address-list
                         rewrite-rb-to-rb-alt
                         acl2::zp-open)))
      ("Subgoal *1/6.1" :do-not-induct t
       :expand ((get-prefixes start-rip prefixes cnt (xw :mem index value x86)))
       :in-theory (e/d* (get-prefixes disjoint-p disjoint-p-append-1)
                        (rewrite-get-prefixes-to-get-prefixes-alt
                         create-canonical-address-list
                         rewrite-rb-to-rb-alt
                         acl2::zp-open))))))

  (defthm get-prefixes-and-write-to-physical-memory
    (implies
     (and (disjoint-p
           (mv-nth 1 (las-to-pas
                      (create-canonical-address-list cnt start-rip)
                      :x (cpl x86) x86))
           (open-qword-paddr-list
            (gather-all-paging-structure-qword-addresses x86)))
          (disjoint-p
           (all-translation-governing-addresses
            (create-canonical-address-list cnt start-rip) (double-rewrite x86))
           (mv-nth 1
                   (las-to-pas (create-canonical-address-list cnt start-rip)
                               :x (cpl x86) (double-rewrite x86))))
          (disjoint-p p-addrs
                      (mv-nth
                       1
                       (las-to-pas (create-canonical-address-list cnt start-rip)
                                   :x (cpl x86) (double-rewrite x86))))
          (disjoint-p p-addrs
                      (open-qword-paddr-list
                       (gather-all-paging-structure-qword-addresses x86)))
          ;; TODO: !!! The prev. hyp should imply this one.
          (disjoint-p p-addrs
                      (all-translation-governing-addresses
                       (create-canonical-address-list cnt start-rip)
                       (double-rewrite x86)))
          (not (mv-nth 0 (las-to-pas (create-canonical-address-list cnt start-rip)
                                     :x (cpl x86) x86)))
          (posp cnt)
          (canonical-address-p start-rip)
          (canonical-address-p (+ cnt start-rip))
          (physical-address-listp p-addrs)
          (byte-listp bytes)
          (equal (len p-addrs) (len bytes))
          (not (programmer-level-mode x86))
          (page-structure-marking-mode x86)
          (x86p x86))
     (and
      (equal
       (mv-nth 0 (get-prefixes start-rip prefixes cnt
                               (write-to-physical-memory p-addrs bytes x86)))
       (mv-nth 0 (get-prefixes start-rip prefixes cnt x86)))
      (equal
       (mv-nth 1 (get-prefixes start-rip prefixes cnt
                               (write-to-physical-memory p-addrs bytes x86)))
       (mv-nth 1 (get-prefixes start-rip prefixes cnt x86)))))
    :hints (("Goal"
             :induct (cons (write-to-physical-memory p-addrs bytes x86)
                           (byte-listp bytes))
             :in-theory (e/d* (get-prefixes
                               disjoint-p
                               member-p
                               write-to-physical-memory
                               byte-listp
                               n08p len)
                              (rewrite-get-prefixes-to-get-prefixes-alt
                               xlate-equiv-memory-and-two-get-prefixes-values)))))

  (defthm gather-all-paging-structure-qword-addresses-and-write-to-physical-memory-disjoint
    (implies
     (and (disjoint-p p-addrs
                      (open-qword-paddr-list
                       (gather-all-paging-structure-qword-addresses x86)))
          (physical-address-listp p-addrs))
     (equal
      (gather-all-paging-structure-qword-addresses (write-to-physical-memory p-addrs bytes x86))
      (gather-all-paging-structure-qword-addresses x86)))
    :hints (("Goal" :in-theory (e/d* (write-to-physical-memory
                                      byte-listp
                                      n08p
                                      len)
                                     ()))))

  (defthm get-prefixes-alt-and-write-to-physical-memory
    (implies
     (and
      ;; I really shouldn't need this first hyp.
      (disjoint-p
       (all-translation-governing-addresses
        (create-canonical-address-list cnt start-rip)
        (double-rewrite x86))
       (mv-nth 1
               (las-to-pas (create-canonical-address-list cnt start-rip)
                           :x (cpl x86) (double-rewrite x86))))
      (disjoint-p p-addrs
                  (mv-nth 1
                          (las-to-pas (create-canonical-address-list cnt start-rip)
                                      :x (cpl x86) (double-rewrite x86))))
      (disjoint-p p-addrs
                  (open-qword-paddr-list
                   (gather-all-paging-structure-qword-addresses (double-rewrite x86))))
      (disjoint-p p-addrs
                  (all-translation-governing-addresses
                   (create-canonical-address-list cnt start-rip)
                   (double-rewrite x86)))
      (posp cnt)
      (canonical-address-p (+ cnt start-rip))
      (physical-address-listp p-addrs)
      (byte-listp bytes)
      (equal (len p-addrs) (len bytes))
      (x86p x86))
     (and
      (equal
       (mv-nth 0 (get-prefixes-alt start-rip prefixes cnt (write-to-physical-memory p-addrs bytes x86)))
       (mv-nth 0 (get-prefixes-alt start-rip prefixes cnt x86)))
      (equal
       (mv-nth 1 (get-prefixes-alt start-rip prefixes cnt (write-to-physical-memory p-addrs bytes x86)))
       (mv-nth 1 (get-prefixes-alt start-rip prefixes cnt x86)))))
    :hints
    (("Goal"
      :do-not-induct t
      :use ((:instance get-prefixes-and-write-to-physical-memory))
      :in-theory
      (e/d*
       (get-prefixes-alt)
       (rewrite-rb-to-rb-alt
        rewrite-get-prefixes-to-get-prefixes-alt
        get-prefixes-and-write-to-physical-memory
        xlate-equiv-memory-and-two-get-prefixes-values
        mv-nth-1-rb-and-xlate-equiv-memory-disjoint-from-paging-structures
        force (force))))))

  (defthm get-prefixes-alt-values-and-wb-in-system-level-marking-mode
    (implies
     (and
      ;; I shouldn't need this hyp.
      (disjoint-p
       (all-translation-governing-addresses
        (create-canonical-address-list cnt start-rip) (double-rewrite x86))
       (mv-nth 1
               (las-to-pas (create-canonical-address-list cnt start-rip)
                           :x (cpl x86) (double-rewrite x86))))
      (disjoint-p
       (mv-nth 1 (las-to-pas (strip-cars addr-lst) :w (cpl x86) (double-rewrite x86)))
       (mv-nth 1
               (las-to-pas (create-canonical-address-list cnt start-rip)
                           :x (cpl x86) (double-rewrite x86))))
      (disjoint-p (mv-nth 1 (las-to-pas (strip-cars addr-lst) :w (cpl x86) (double-rewrite x86)))
                  (open-qword-paddr-list
                   (gather-all-paging-structure-qword-addresses (double-rewrite x86))))
      (disjoint-p
       (all-translation-governing-addresses
        (create-canonical-address-list cnt start-rip) (double-rewrite x86))
       (mv-nth 1 (las-to-pas (strip-cars addr-lst) :w (cpl x86) (double-rewrite x86))))
      (posp cnt)
      (canonical-address-p (+ cnt start-rip))
      (addr-byte-alistp addr-lst)
      (not (programmer-level-mode x86))
      (x86p x86))
     (and
      (equal
       (mv-nth 0 (get-prefixes-alt start-rip prefixes cnt (mv-nth 1 (wb addr-lst x86))))
       (mv-nth 0 (get-prefixes-alt start-rip prefixes cnt x86)))
      (equal
       (mv-nth 1 (get-prefixes-alt start-rip prefixes cnt (mv-nth 1 (wb addr-lst x86))))
       (mv-nth 1 (get-prefixes-alt start-rip prefixes cnt x86)))))
    :hints (("Goal"
             :do-not-induct t
             :in-theory (e/d* (las-to-pas wb disjoint-p-commutative)
                              (rewrite-get-prefixes-to-get-prefixes-alt
                               xlate-equiv-memory-and-two-get-prefixes-values
                               xlate-equiv-memory-and-xr-mem-from-rest-of-memory))))))


(i-am-here)


;; For mv-nth 0 get-prefixes-alt...
;; (acl2::why get-prefixes-alt-opener-lemma-no-prefix-byte)
;; (acl2::why combine-bytes-rb-alt-in-terms-of-rb-alt-subset-p-in-system-level-mode)

;; (acl2::why x86-run-opener-not-ms-not-zp-n)
;; (acl2::why x86-fetch-decode-execute-opener-in-marking-mode)
;; (acl2::why get-prefixes-opener-lemma-no-prefix-byte)
;; (acl2::why xlate-equiv-memory-and-mv-nth-2-get-prefixes) ;; For mv-nth-0-rb-and-xlate-equiv-memory
;; (acl2::why mv-nth-2-rb-and-xlate-equiv-memory)
;; (acl2::why ia32e-la-to-pa-values-and-mv-nth-1-wb)
;; (acl2::why rb-in-terms-of-nth-and-pos-in-system-level-mode)
;; (acl2::why combine-bytes-rb-in-terms-of-rb-subset-p-in-system-level-mode)
;; (acl2::why program-at-wb-disjoint)
;; (acl2::why rb-wb-disjoint-in-system-level-mode)
;; (acl2::why disjointness-of-translation-governing-addresses-from-all-translation-governing-addresses)
;; (acl2::why la-to-pas-values-and-mv-nth-1-wb-disjoint-from-xlation-gov-addrs)
;; (acl2::why mv-nth-0-rb-and-mv-nth-0-las-to-pas-in-system-level-mode)
;; (acl2::why mv-nth-1-rb-and-xlate-equiv-memory-disjoint-from-paging-structures)
;; (acl2::why combine-bytes-rb-in-terms-of-rb-subset-p-in-system-level-mode)
;; (acl2::why xlate-equiv-memory-and-mv-nth-2-get-prefixes)
;; (acl2::why mv-nth-2-rb-and-xlate-equiv-memory)
;; (acl2::why get-prefixes-alt-opener-lemma-no-prefix-byte)
;; (acl2::why combine-bytes-rb-alt-in-terms-of-rb-alt-subset-p-in-system-level-mode)

;; Argh, ACL2's default ancestors-check is killing me --- it prevents
;; x86-fetch-decode-execute from opening up (because the first hyp of
;; get-prefixes-alt-opener-lemma-no-prefix-byte is judged more
;; complicated than its ancestors --- why?). So I'm going to use Sol's
;; trivial ancestors-check version.
(local (include-book "tools/trivial-ancestors-check" :dir :system))
(local (acl2::use-trivial-ancestors-check))

(defthm rewire_dst_to_src-effects
  ;; !!! Note: no double-rewrites in the first three hypotheses...
  (implies
   (and
    (x86-state-okp x86)
    (program-ok-p x86)
    (stack-ok-p x86)
    (program-and-stack-no-interfere-p x86)
    ;; !! TODO: I can use
    ;; !! x86-state-okp-and-program-ok-p-implies-program-alt to make
    ;; !! this hyp go away later.
    (program-at-alt
     (create-canonical-address-list *rewire_dst_to_src-len* (xr :rip 0 x86))
     *rewire_dst_to_src*
     (double-rewrite x86))


    ;; I need to be able to infer the following from
    ;; (program-and-stack-no-interfere-p x86) for relieving the hyps
    ;; of get-prefixes-alt-values-and-wb-in-system-level-marking-mode.
    (DISJOINT-P
     (ALL-TRANSLATION-GOVERNING-ADDRESSES
      (CREATE-CANONICAL-ADDRESS-LIST '5
                                     (BINARY-+ '8 (XR ':RIP '0 X86)))
      X86)
     (MV-NTH
      '1
      (LAS-TO-PAS (CREATE-CANONICAL-ADDRESS-LIST '5
                                                 (BINARY-+ '8 (XR ':RIP '0 X86)))
                  ':X
                  (ACL2::LOGHEAD$INLINE '2
                                        (XR ':SEG-VISIBLE '1 X86))
                  X86)))

    (DISJOINT-P
     (MV-NTH
      '1
      (LAS-TO-PAS
       (CREATE-CANONICAL-ADDRESS-LIST '8
                                      (BINARY-+ '-24 (XR ':RGF '4 X86)))
       ':W
       '0
       X86))
     (MV-NTH
      '1
      (LAS-TO-PAS (CREATE-CANONICAL-ADDRESS-LIST '5
                                                 (BINARY-+ '8 (XR ':RIP '0 X86)))
                  ':X
                  '0
                  X86)))


    (DISJOINT-P
     (ALL-TRANSLATION-GOVERNING-ADDRESSES
      (CREATE-CANONICAL-ADDRESS-LIST '5
                                     (BINARY-+ '8 (XR ':RIP '0 X86)))
      X86)
     (MV-NTH
      '1
      (LAS-TO-PAS
       (CREATE-CANONICAL-ADDRESS-LIST '8
                                      (BINARY-+ '-24 (XR ':RGF '4 X86)))
       ':W
       '0
       X86))))

   (equal (x86-run 3 x86) ;; (rewire_dst_to_src-clk)
          xxxx))
  :hints (("Goal"
           :do-not '(preprocess)
           :do-not-induct t)))

;; ======================================================================

(encapsulate
  ()

  (def-gl-export rb-and-rm-low-64-for-direct-map-helper
    :hyp (and (n08p a) (n08p b) (n08p c) (n08p d)
              (n08p e) (n08p f) (n08p g) (n08p h))
    :concl (equal (logior a (ash b 8)
                          (ash (logior c (ash d 8)) 16)
                          (ash (logior e (ash (logior f (ash (logior g (ash h 8)) 8)) 8)) 32))
                  (logior a
                          (ash (logior b
                                       (ash (logior c
                                                    (ash
                                                     (logior d
                                                             (ash
                                                              (logior
                                                               e
                                                               (ash
                                                                (logior
                                                                 f
                                                                 (ash (logior g (ash h 8)) 8))
                                                                8)) 8)) 8)) 8)) 8)))
    :g-bindings
    (gl::auto-bindings
     (:mix (:nat a 8) (:nat b 8) (:nat c 8) (:nat d 8)
           (:nat e 8) (:nat f 8) (:nat g 8) (:nat h 8))))

  (defthm rb-and-rm-low-64-for-direct-map
    (implies (and
              (equal
               (mv-nth
                1
                (las-to-pas
                 (create-canonical-address-list 8 direct-mapped-addr)
                 r-w-x (cpl x86) x86))
               (addr-range 8 direct-mapped-addr))
              (not (page-structure-marking-mode x86))
              (not (programmer-level-mode x86))
              (x86p x86))
             (equal (combine-bytes
                     (mv-nth
                      1
                      (rb (create-canonical-address-list 8 direct-mapped-addr) r-w-x x86)))
                    (rm-low-64 direct-mapped-addr x86)))
    :hints (("Goal" :in-theory (e/d* (rb
                                      rm-low-64
                                      rm-low-32
                                      read-from-physical-memory
                                      rb-and-rm-low-64-for-direct-map-helper)
                                     ()))))

  (in-theory (e/d () (rb-and-rm-low-64-for-direct-map-helper))))

(defthm ia32e-la-to-pa-page-dir-ptr-table-values-1G-pages-and-write-to-page-dir-ptr-table-entry-addr
  (b* ((p-addrs (addr-range 8 (page-dir-ptr-table-entry-addr lin-addr base-addr)))
       (page-dir-ptr-table-entry (combine-bytes
                                  (mv-nth 1
                                          (rb
                                           (create-canonical-address-list
                                            8
                                            (page-dir-ptr-table-entry-addr lin-addr base-addr))
                                           :r x86))))
       (value (combine-bytes bytes)))
    (implies (and
              ;; page-dir-ptr-table-entry-addr is directly mapped.
              (equal
               (mv-nth
                1
                (las-to-pas
                 (create-canonical-address-list 8 (page-dir-ptr-table-entry-addr lin-addr base-addr))
                 :r (cpl x86) x86))
               p-addrs)
              (not (mv-nth 0 (ia32e-la-to-pa-page-dir-ptr-table
                              lin-addr base-addr u/s-acc r/w-acc x/d-acc
                              wp smep smap ac nxe r-w-x cpl x86)))
              (equal (page-present page-dir-ptr-table-entry)
                     (page-present value))
              (equal (page-read-write page-dir-ptr-table-entry)
                     (page-read-write value))
              (equal (page-user-supervisor page-dir-ptr-table-entry)
                     (page-user-supervisor value))
              (equal (page-execute-disable page-dir-ptr-table-entry)
                     (page-execute-disable value))
              (equal (page-size page-dir-ptr-table-entry)
                     (page-size value))
              ;; 1 G pages
              (equal (page-size page-dir-ptr-table-entry) 1)
              (equal (part-select page-dir-ptr-table-entry :low 13 :high 29)
                     (part-select value :low 13 :high 29))
              (equal (len bytes) (len p-addrs))
              (byte-listp bytes)
              (canonical-address-p lin-addr)
              (physical-address-p base-addr)
              (equal (loghead 12 base-addr) 0)
              (not (page-structure-marking-mode x86))
              (not (programmer-level-mode x86))
              (x86p x86))
             ;; ia32e-la-to-pa-page-dir-ptr-table returns the physical
             ;; address corresponding to "lin-addr" after the PDPTE
             ;; corresponding to this "lin-addr" has been modified ---
             ;; the new PDPTE is "value".
             (and (equal
                   (mv-nth 0 (ia32e-la-to-pa-page-dir-ptr-table
                              lin-addr base-addr u/s-acc r/w-acc x/d-acc
                              wp smep smap ac nxe r-w-x cpl
                              (write-to-physical-memory p-addrs bytes x86)))
                   nil)
                  (equal (mv-nth 1 (ia32e-la-to-pa-page-dir-ptr-table
                                    lin-addr base-addr u/s-acc r/w-acc x/d-acc
                                    wp smep smap ac nxe r-w-x cpl
                                    (write-to-physical-memory p-addrs bytes x86)))
                         (logior (loghead 30 lin-addr)
                                 (ash (loghead 22 (logtail 30 value)) 30))))))
  :hints (("Goal"
           :do-not-induct t
           :in-theory (e/d* (disjoint-p
                             member-p
                             ia32e-la-to-pa-page-dir-ptr-table)
                            (wb
                             bitops::logand-with-negated-bitmask
                             (:meta acl2::mv-nth-cons-meta)
                             force (force))))))

(defthm ia32e-la-to-pa-pml4-table-values-1G-pages-and-write-to-page-dir-ptr-table-entry-addr
  (b* ((pml4-table-entry-addr (pml4-table-entry-addr lin-addr base-addr))
       (pml4-table-entry (combine-bytes
                          (mv-nth 1 (rb (create-canonical-address-list 8 pml4-table-entry-addr) :r x86))))
       (page-dir-ptr-table-base-addr (ash (loghead 40 (logtail 12 pml4-table-entry)) 12))
       (page-dir-ptr-table-entry-addr (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr))
       (page-dir-ptr-table-entry
        (combine-bytes
         (mv-nth 1 (rb (create-canonical-address-list 8 page-dir-ptr-table-entry-addr) :r x86))))
       (p-addrs (addr-range 8 page-dir-ptr-table-entry-addr))
       (value (combine-bytes bytes)))
    (implies (and
              ;; PML4E and PDPTE are direct mapped.
              (equal
               (mv-nth
                1
                (las-to-pas
                 (create-canonical-address-list 8 pml4-table-entry-addr)
                 :r (cpl x86) x86))
               (addr-range 8 pml4-table-entry-addr))
              (equal
               (mv-nth
                1
                (las-to-pas
                 (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
                 :r (cpl x86) x86))
               p-addrs)
              (disjoint-p (addr-range 8 pml4-table-entry-addr)
                          (addr-range 8 page-dir-ptr-table-entry-addr))
              (not (mv-nth 0 (ia32e-la-to-pa-pml4-table lin-addr base-addr wp smep smap ac nxe r-w-x cpl x86)))

              (equal (page-present page-dir-ptr-table-entry)
                     (page-present value))
              (equal (page-read-write page-dir-ptr-table-entry)
                     (page-read-write value))
              (equal (page-user-supervisor page-dir-ptr-table-entry)
                     (page-user-supervisor value))
              (equal (page-execute-disable page-dir-ptr-table-entry)
                     (page-execute-disable value))
              (equal (page-size page-dir-ptr-table-entry)
                     (page-size value))
              ;; 1 G pages
              (equal (page-size page-dir-ptr-table-entry) 1)
              (equal (part-select page-dir-ptr-table-entry :low 13 :high 29)
                     (part-select value :low 13 :high 29))
              (equal (len bytes) (len p-addrs))
              (byte-listp bytes)
              (canonical-address-p lin-addr)
              (physical-address-p base-addr)
              (equal (loghead 12 base-addr) 0)
              (not (programmer-level-mode x86))
              (not (page-structure-marking-mode x86))
              (x86p x86))
             ;; ia32e-la-to-pa-pml4-table returns the physical address
             ;; corresponding to "lin-addr" after the PDPTE
             ;; corresponding to this "lin-addr" has been modified ---
             ;; the new PDPTE is "value".
             (and (equal
                   (mv-nth 0 (ia32e-la-to-pa-pml4-table
                              lin-addr base-addr wp smep smap ac nxe r-w-x cpl
                              (write-to-physical-memory p-addrs bytes x86)))
                   nil)
                  (equal (mv-nth 1 (ia32e-la-to-pa-pml4-table
                                    lin-addr base-addr wp smep smap ac nxe r-w-x cpl
                                    (write-to-physical-memory p-addrs bytes x86)))
                         (logior (loghead 30 lin-addr)
                                 (ash (loghead 22 (logtail 30 value)) 30))))))
  :hints (("Goal"
           :do-not-induct t
           :in-theory (e/d* (disjoint-p
                             member-p
                             ia32e-la-to-pa-pml4-table)
                            (page-dir-ptr-table-entry-addr-to-c-program-optimized-form
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form-gl
                             bitops::logand-with-negated-bitmask
                             (:meta acl2::mv-nth-cons-meta)
                             force (force))))))

(defthm ia32e-la-to-pa-values-1G-pages-and-write-to-page-dir-ptr-table-entry-addr
  (b* ((pml4-table-base-addr (pml4-table-base-addr x86))
       (pml4-table-entry-addr (pml4-table-entry-addr lin-addr pml4-table-base-addr))
       (pml4-table-entry
        (combine-bytes
         (mv-nth 1 (rb (create-canonical-address-list 8 pml4-table-entry-addr) :r x86))))
       (page-dir-ptr-table-base-addr (ash (loghead 40 (logtail 12 pml4-table-entry)) 12))
       (page-dir-ptr-table-entry-addr (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr))
       (page-dir-ptr-table-entry
        (combine-bytes
         (mv-nth 1 (rb (create-canonical-address-list 8 page-dir-ptr-table-entry-addr) :r x86))))
       (p-addrs (addr-range 8 page-dir-ptr-table-entry-addr))
       (value (combine-bytes bytes)))
    (implies (and
              ;; PML4E and PDPTE are direct mapped.
              (equal
               (mv-nth
                1
                (las-to-pas
                 (create-canonical-address-list 8 pml4-table-entry-addr)
                 :r (cpl x86) x86))
               (addr-range 8 pml4-table-entry-addr))
              (equal
               (mv-nth
                1
                (las-to-pas
                 (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
                 :r (cpl x86) x86))
               p-addrs)
              (disjoint-p (addr-range 8 pml4-table-entry-addr)
                          (addr-range 8 page-dir-ptr-table-entry-addr))
              (not (mv-nth 0 (ia32e-la-to-pa lin-addr r-w-x cpl x86)))
              (equal (page-present page-dir-ptr-table-entry)
                     (page-present value))
              (equal (page-read-write page-dir-ptr-table-entry)
                     (page-read-write value))
              (equal (page-user-supervisor page-dir-ptr-table-entry)
                     (page-user-supervisor value))
              (equal (page-execute-disable page-dir-ptr-table-entry)
                     (page-execute-disable value))
              (equal (page-size page-dir-ptr-table-entry)
                     (page-size value))
              ;; 1 G pages
              (equal (page-size page-dir-ptr-table-entry) 1)
              (equal (part-select page-dir-ptr-table-entry :low 13 :high 29)
                     (part-select value :low 13 :high 29))
              (equal (len bytes) (len p-addrs))
              (byte-listp bytes)
              (canonical-address-p lin-addr)
              (not (programmer-level-mode x86))
              (not (page-structure-marking-mode x86))
              (x86p x86))
             ;; ia32e-la-to-pa returns the physical address
             ;; corresponding to "lin-addr" after the PDPTE
             ;; corresponding to this "lin-addr" has been modified ---
             ;; the new PDPTE is "value".
             (and
              (equal (mv-nth 0 (ia32e-la-to-pa lin-addr r-w-x cpl (write-to-physical-memory p-addrs bytes x86)))
                     nil)
              (equal (mv-nth 1 (ia32e-la-to-pa lin-addr r-w-x cpl (write-to-physical-memory p-addrs bytes x86)))
                     (logior (loghead 30 lin-addr) (ash (loghead 22 (logtail 30 value)) 30))))))
  :hints (("Goal"
           :use ((:instance
                  ia32e-la-to-pa-pml4-table-values-1G-pages-and-write-to-page-dir-ptr-table-entry-addr
                  (base-addr (ash (cr3-slice :cr3-pdb (ctri *cr3* x86)) 12))
                  (wp (cr0-slice :cr0-wp (n32 (ctri *cr0* x86))))
                  (smep (loghead 1 (bool->bit (logbitp 20 (xr :ctr *cr4* x86)))))
                  (smap 0)
                  (ac (bool->bit (logbitp 18 (xr :rflags 0 x86))))
                  (nxe (loghead 1 (bool->bit (logbitp 11 (xr :msr *ia32_efer-idx* x86)))))
                  (r-w-x r-w-x)
                  (cpl cpl)
                  (x86 x86)))
           :do-not-induct t
           :in-theory (e/d* (disjoint-p
                             member-p
                             ia32e-la-to-pa)
                            (ia32e-la-to-pa-pml4-table-values-1G-pages-and-write-to-page-dir-ptr-table-entry-addr
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form-gl
                             bitops::logand-with-negated-bitmask
                             (:meta acl2::mv-nth-cons-meta)
                             not
                             force (force))))))

(defthm ia32e-la-to-pa-values-1G-pages-and-wb-to-page-dir-ptr-table-entry-addr
  (implies
   (and
    (equal pml4-table-base-addr (pml4-table-base-addr x86))
    (equal pml4-table-entry-addr (pml4-table-entry-addr lin-addr pml4-table-base-addr))
    (equal pml4-table-entry
           (combine-bytes
            (mv-nth 1 (rb (create-canonical-address-list 8 pml4-table-entry-addr) :r x86))))
    (equal page-dir-ptr-table-base-addr (ash (loghead 40 (logtail 12 pml4-table-entry)) 12))
    (equal page-dir-ptr-table-entry-addr (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr))
    (equal page-dir-ptr-table-entry
           (combine-bytes
            (mv-nth 1 (rb (create-canonical-address-list 8 page-dir-ptr-table-entry-addr) :r x86))))
    ;; PML4E and PDPTE are direct mapped.
    (equal
     (mv-nth
      1
      (las-to-pas
       (create-canonical-address-list 8 pml4-table-entry-addr)
       :r (cpl x86) x86))
     (addr-range 8 pml4-table-entry-addr))
    (equal
     (mv-nth
      1
      (las-to-pas
       (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
       :r (cpl x86) x86))
     (addr-range 8 page-dir-ptr-table-entry-addr))
    (equal (mv-nth 1 (las-to-pas (strip-cars addr-lst) :w (cpl x86) x86))
           (addr-range 8 page-dir-ptr-table-entry-addr))
    (disjoint-p
     (addr-range 8 (pml4-table-entry-addr lin-addr pml4-table-base-addr))
     (addr-range 8 (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr)))
    (not (mv-nth 0 (ia32e-la-to-pa lin-addr r-w-x cpl x86)))
    (equal (page-present page-dir-ptr-table-entry)
           (page-present (combine-bytes (strip-cdrs addr-lst))))
    (equal (page-read-write page-dir-ptr-table-entry)
           (page-read-write (combine-bytes (strip-cdrs addr-lst))))
    (equal (page-user-supervisor page-dir-ptr-table-entry)
           (page-user-supervisor (combine-bytes (strip-cdrs addr-lst))))
    (equal (page-execute-disable page-dir-ptr-table-entry)
           (page-execute-disable (combine-bytes (strip-cdrs addr-lst))))
    (equal (page-size page-dir-ptr-table-entry)
           (page-size (combine-bytes (strip-cdrs addr-lst))))
    (equal (page-size page-dir-ptr-table-entry) 1)
    (equal (part-select page-dir-ptr-table-entry :low 13 :high 29)
           (part-select (combine-bytes (strip-cdrs addr-lst)) :low 13 :high 29))
    (addr-byte-alistp addr-lst)
    (equal (len addr-lst) 8)
    (canonical-address-p lin-addr)
    (not (programmer-level-mode x86))
    (not (page-structure-marking-mode x86))
    (x86p x86))
   ;; ia32e-la-to-pa returns the physical address
   ;; corresponding to "lin-addr" after the PDPTE
   ;; corresponding to this "lin-addr" has been modified ---
   ;; the new PDPTE is "value".
   (and
    (equal (mv-nth 0 (ia32e-la-to-pa lin-addr r-w-x cpl (mv-nth 1 (wb addr-lst x86))))
           nil)
    (equal (mv-nth 1 (ia32e-la-to-pa lin-addr r-w-x cpl (mv-nth 1 (wb addr-lst x86))))
           (logior (loghead 30 lin-addr) (ash (loghead
                                               22
                                               (logtail 30 (combine-bytes (strip-cdrs addr-lst)))) 30)))))
  :hints (("Goal"
           :use ((:instance ia32e-la-to-pa-values-1G-pages-and-write-to-page-dir-ptr-table-entry-addr
                            (bytes (strip-cdrs addr-lst))))
           :do-not-induct t
           :in-theory (e/d* (disjoint-p
                             member-p
                             wb)
                            (ia32e-la-to-pa-values-1G-pages-and-write-to-page-dir-ptr-table-entry-addr
                             member-p-strip-cars-of-remove-duplicate-keys
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form-gl
                             bitops::logand-with-negated-bitmask
                             (:meta acl2::mv-nth-cons-meta)
                             not
                             force (force))))))

(def-gl-export same-pml4-table-entry-addr-for-n-+-lin-addrs
  :hyp (and (physical-address-p pml4-table-base-addr)
            (canonical-address-p lin-addr)
            (unsigned-byte-p 30 n)
            ;; 1G aligned linear address
            (equal (loghead 30 lin-addr) 0))
  :concl (equal (pml4-table-entry-addr (+ n lin-addr) pml4-table-base-addr)
                (pml4-table-entry-addr lin-addr pml4-table-base-addr))
  :g-bindings
  (gl::auto-bindings
   (:mix (:nat pml4-table-base-addr 64) (:nat lin-addr 64) (:nat n 64))))

(def-gl-export same-pdp-table-entry-addr-for-n-+-lin-addrs
  :hyp (and (unsigned-byte-p 30 n)
            (physical-address-p page-dir-ptr-table-base-addr)
            (canonical-address-p lin-addr)
            ;; 1G aligned linear address
            (equal (loghead 30 lin-addr) 0))
  :concl (equal (page-dir-ptr-table-entry-addr
                 (+ n lin-addr) page-dir-ptr-table-base-addr)
                (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr))
  :g-bindings
  (gl::auto-bindings
   (:mix (:nat page-dir-ptr-table-base-addr 64) (:nat lin-addr 64) (:nat n 64))))

(def-gl-export loghead-30-of-1G-aligned-lin-addr-+-n-1
  :hyp (and (canonical-address-p lin-addr)
            (canonical-address-p (+ n lin-addr))
            (equal (loghead 30 lin-addr) 0)
            (unsigned-byte-p 30 n))
  :concl (equal (loghead 30 (+ n lin-addr)) n)
  :g-bindings (gl::auto-bindings (:mix (:nat lin-addr 64) (:nat n 64))))

(def-gl-export loghead-30-of-1G-aligned-lin-addr-+-n-2
  :hyp (and (equal (loghead 30 (+ n lin-addr)) n)
            (canonical-address-p (+ n lin-addr))
            (canonical-address-p lin-addr)
            (unsigned-byte-p 30 n))
  :concl (equal (loghead 30 lin-addr) 0)
  :g-bindings (gl::auto-bindings (:mix (:nat lin-addr 64) (:nat n 64))))

(def-gl-export logior-to-+-for-ash-x-30
  :hyp (and (unsigned-byte-p 22 x)
            (unsigned-byte-p 30 n))
  :concl (equal (logior n (ash x 30)) (+ n (ash x 30)))
  :g-bindings
  (gl::auto-bindings (:mix (:nat n 64) (:nat x 64))))

(defthm mv-nth-0-ia32e-la-to-pa-page-dir-ptr-table-for-same-1G-page
  (implies
   (and
    (equal page-dir-ptr-table-entry-addr (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr))
    (equal page-dir-ptr-table-entry
           (combine-bytes
            (mv-nth 1 (rb (create-canonical-address-list 8 page-dir-ptr-table-entry-addr) :r x86))))
    ;; PDPTE is direct mapped.
    (equal
     (mv-nth
      1
      (las-to-pas
       (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
       :r (cpl x86) x86))
     (addr-range 8 page-dir-ptr-table-entry-addr))
    (equal (page-size page-dir-ptr-table-entry) 1)
    (not (mv-nth 0 (ia32e-la-to-pa-page-dir-ptr-table
                    lin-addr page-dir-ptr-table-base-addr u/s-acc r/w-acc x/d-acc
                    wp smep smap ac nxe r-w-x cpl x86)))
    (canonical-address-p lin-addr)
    (canonical-address-p (+ n lin-addr))
    ;; (equal (loghead 30 lin-addr) 0)
    (equal (loghead 30 (+ n lin-addr)) n)
    (unsigned-byte-p 30 n)
    (physical-address-p page-dir-ptr-table-base-addr)
    (equal (loghead 12 page-dir-ptr-table-base-addr) 0)
    (not (page-structure-marking-mode x86))
    (x86p x86))
   (equal (mv-nth 0
                  (ia32e-la-to-pa-page-dir-ptr-table
                   (+ n lin-addr) page-dir-ptr-table-base-addr u/s-acc r/w-acc x/d-acc
                   wp smep smap ac nxe r-w-x cpl x86))
          nil))
  :hints (("Goal" :in-theory (e/d* (ia32e-la-to-pa-page-dir-ptr-table)
                                   (commutativity-of-+
                                    not
                                    page-dir-ptr-table-entry-addr-to-c-program-optimized-form
                                    page-dir-ptr-table-entry-addr-to-c-program-optimized-form-gl
                                    bitops::logand-with-negated-bitmask)))))

(defthm mv-nth-0-ia32e-la-to-pa-pml4-table-for-same-1G-page
  (implies
   (and
    (equal pml4-table-entry-addr (pml4-table-entry-addr lin-addr pml4-table-base-addr))
    (equal pml4-table-entry
           (combine-bytes
            (mv-nth 1 (rb (create-canonical-address-list 8 pml4-table-entry-addr) :r x86))))
    (equal page-dir-ptr-table-base-addr (ash (loghead 40 (logtail 12 pml4-table-entry)) 12))
    (equal page-dir-ptr-table-entry-addr (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr))
    (equal page-dir-ptr-table-entry
           (combine-bytes
            (mv-nth 1 (rb (create-canonical-address-list 8 page-dir-ptr-table-entry-addr) :r x86))))
    ;; PML4E and PDPTE are direct mapped.
    (equal
     (mv-nth
      1
      (las-to-pas
       (create-canonical-address-list 8 pml4-table-entry-addr)
       :r (cpl x86) x86))
     (addr-range 8 pml4-table-entry-addr))
    (equal
     (mv-nth
      1
      (las-to-pas
       (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
       :r (cpl x86) x86))
     (addr-range 8 page-dir-ptr-table-entry-addr))
    (equal (page-size page-dir-ptr-table-entry) 1)
    (not (mv-nth 0 (ia32e-la-to-pa-pml4-table
                    lin-addr pml4-table-base-addr
                    wp smep smap ac nxe r-w-x cpl x86)))
    (canonical-address-p lin-addr)
    (canonical-address-p (+ n lin-addr))
    ;; (equal (loghead 30 lin-addr) 0)
    (equal (loghead 30 (+ n lin-addr)) n)
    (unsigned-byte-p 30 n)
    (physical-address-p pml4-table-base-addr)
    (equal (loghead 12 pml4-table-base-addr) 0)
    (not (page-structure-marking-mode x86))
    (x86p x86))
   (equal (mv-nth 0
                  (ia32e-la-to-pa-pml4-table
                   (+ n lin-addr) pml4-table-base-addr
                   wp smep smap ac nxe r-w-x cpl x86))
          nil))
  :hints (("Goal"
           :in-theory (e/d* (ia32e-la-to-pa-pml4-table)
                            (commutativity-of-+
                             not
                             pml4-table-entry-addr-to-c-program-optimized-form
                             pml4-table-entry-addr-to-c-program-optimized-form-gl
                             bitops::logand-with-negated-bitmask)))))

(defthm mv-nth-0-ia32e-la-to-pa-for-same-1G-page
  (implies
   (and
    (equal pml4-table-base-addr (pml4-table-base-addr x86))
    (equal pml4-table-entry-addr (pml4-table-entry-addr lin-addr pml4-table-base-addr))
    (equal pml4-table-entry
           (combine-bytes
            (mv-nth 1
                    (rb (create-canonical-address-list 8 pml4-table-entry-addr)
                        :r x86))))
    (equal page-dir-ptr-table-base-addr (ash (loghead 40 (logtail 12 pml4-table-entry)) 12))
    (equal page-dir-ptr-table-entry-addr
           (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr))
    (equal page-dir-ptr-table-entry
           (combine-bytes
            (mv-nth 1 (rb (create-canonical-address-list 8 page-dir-ptr-table-entry-addr) :r x86))))
    (equal
     (mv-nth 1 (las-to-pas (create-canonical-address-list 8 pml4-table-entry-addr) :r (cpl x86) x86))
     (addr-range 8 pml4-table-entry-addr))
    (equal
     (mv-nth 1
             (las-to-pas
              (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
              :r (cpl x86) x86))
     (addr-range 8 page-dir-ptr-table-entry-addr))
    (equal (page-size page-dir-ptr-table-entry) 1)
    (not (mv-nth 0 (ia32e-la-to-pa lin-addr r-w-x cpl x86)))
    (canonical-address-p lin-addr)
    (canonical-address-p (+ n lin-addr))
    (equal (loghead 30 (+ n lin-addr)) n)
    (unsigned-byte-p 30 n)
    (not (page-structure-marking-mode x86))
    (x86p x86))
   (equal (mv-nth 0 (ia32e-la-to-pa (+ n lin-addr) r-w-x cpl x86))
          nil))
  :hints (("Goal"
           :in-theory (e/d* (ia32e-la-to-pa)
                            (commutativity-of-+
                             not
                             pml4-table-entry-addr-to-c-program-optimized-form
                             pml4-table-entry-addr-to-c-program-optimized-form-gl
                             bitops::logand-with-negated-bitmask)))))

(define create-canonical-address-list-alt (iteration count lin-addr)
  :enabled t
  :measure (nfix (- count iteration))
  :guard (and (natp count)
              (natp iteration)
              (<= iteration count)
              (integerp lin-addr))
  :long "An alternative way of creating canonical address lists, this
  function also gives a different induction scheme that may be
  preferable to the one suggested by @(see
  create-canonical-address-list)"
  (if (zp (- count iteration))
      nil
    (if (canonical-address-p (+ iteration lin-addr))
        (cons
         (+ iteration lin-addr)
         (create-canonical-address-list-alt (+ 1 iteration) count lin-addr))
      nil))
  ///
  (defthmd create-canonical-address-list-alt-is-create-canonical-address-list
    (equal (create-canonical-address-list-alt iteration count lin-addr)
           (create-canonical-address-list (- count iteration) (+ iteration lin-addr)))))

(def-gl-export open-mv-nth-0-las-to-pas-for-same-1G-page-general-1
  :hyp (and (< iteration m)
            (canonical-address-p lin-addr)
            (canonical-address-p (+ -1 lin-addr m))
            (integerp m)
            (<= m 1073741824)
            (natp iteration)
            (equal (loghead 30 lin-addr) 0))
  :concl (equal (loghead 30 (+ iteration lin-addr)) iteration)
  :g-bindings (gl::auto-bindings (:mix (:nat lin-addr 64) (:nat iteration 64) (:nat m 64))))

(def-gl-export open-mv-nth-0-las-to-pas-for-same-1G-page-general-2
  :hyp (and (< iteration m)
            (integerp m)
            (<= m 1073741824)
            (natp iteration))
  :concl (unsigned-byte-p 30 iteration)
  :g-bindings (gl::auto-bindings (:mix (:nat iteration 64) (:nat m 64))))

(defthmd open-mv-nth-0-las-to-pas-for-same-1G-page-general
  (implies
   (and
    (equal pml4-table-base-addr (pml4-table-base-addr x86))
    (equal pml4-table-entry-addr (pml4-table-entry-addr lin-addr pml4-table-base-addr))
    (equal pml4-table-entry
           (combine-bytes
            (mv-nth 1 (rb (create-canonical-address-list 8 pml4-table-entry-addr) :r x86))))
    (equal page-dir-ptr-table-base-addr (ash (loghead 40 (logtail 12 pml4-table-entry)) 12))
    (equal page-dir-ptr-table-entry-addr
           (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr))
    (equal page-dir-ptr-table-entry
           (combine-bytes
            (mv-nth
             1
             (rb (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
                 :r x86))))
    (equal
     (mv-nth
      1
      (las-to-pas (create-canonical-address-list 8 pml4-table-entry-addr)
                  :r (cpl x86) x86))
     (addr-range 8 pml4-table-entry-addr))
    (equal
     (mv-nth
      1
      (las-to-pas
       (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
       :r (cpl x86) x86))
     (addr-range 8 page-dir-ptr-table-entry-addr))
    (equal (page-size page-dir-ptr-table-entry) 1)
    (not (mv-nth 0 (ia32e-la-to-pa lin-addr r-w-x cpl x86)))
    (canonical-address-p lin-addr)
    (natp m)
    (<= m *2^30*)
    (natp iteration)
    (equal (loghead 30 lin-addr) 0)
    (not (page-structure-marking-mode x86))
    (x86p x86))
   (equal (mv-nth 0 (las-to-pas
                     (create-canonical-address-list-alt iteration m lin-addr)
                     r-w-x cpl x86))
          nil))
  :hints (("Goal"
           :induct (create-canonical-address-list-alt iteration m lin-addr)
           :in-theory (e/d* (las-to-pas
                             mv-nth-0-ia32e-la-to-pa-for-same-1G-page
                             open-mv-nth-0-las-to-pas-for-same-1G-page-general-1
                             open-mv-nth-0-las-to-pas-for-same-1G-page-general-2
                             ;; open-mv-nth-0-las-to-pas
                             )
                            (not
                             pml4-table-base-addr
                             pml4-table-entry-addr
                             page-dir-ptr-table-entry-addr
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form-gl)))))

(defthm open-mv-nth-0-las-to-pas-for-same-1G-page
  (implies
   (and
    (equal pml4-table-base-addr (pml4-table-base-addr x86))
    (equal pml4-table-entry-addr (pml4-table-entry-addr lin-addr pml4-table-base-addr))
    (equal pml4-table-entry
           (combine-bytes
            (mv-nth 1 (rb (create-canonical-address-list 8 pml4-table-entry-addr) :r x86))))
    (equal page-dir-ptr-table-base-addr (ash (loghead 40 (logtail 12 pml4-table-entry)) 12))
    (equal page-dir-ptr-table-entry-addr
           (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr))
    (equal page-dir-ptr-table-entry
           (combine-bytes
            (mv-nth
             1
             (rb (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
                 :r x86))))
    (equal
     (mv-nth
      1
      (las-to-pas (create-canonical-address-list 8 pml4-table-entry-addr)
                  :r (cpl x86) x86))
     (addr-range 8 pml4-table-entry-addr))
    (equal
     (mv-nth
      1
      (las-to-pas
       (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
       :r (cpl x86) x86))
     (addr-range 8 page-dir-ptr-table-entry-addr))
    (equal (page-size page-dir-ptr-table-entry) 1)
    (not (mv-nth 0 (ia32e-la-to-pa lin-addr r-w-x cpl x86)))
    (canonical-address-p lin-addr)
    (equal (loghead 30 lin-addr) 0)
    (not (page-structure-marking-mode x86))
    (x86p x86))
   (equal (mv-nth 0 (las-to-pas (create-canonical-address-list *2^30* lin-addr)
                                r-w-x cpl x86))
          nil))
  :hints (("Goal"
           :use ((:instance open-mv-nth-0-las-to-pas-for-same-1G-page-general
                            (iteration 0)
                            (m *2^30*)))
           :in-theory (e/d* (create-canonical-address-list-alt-is-create-canonical-address-list)
                            (las-to-pas
                             ;; open-mv-nth-0-las-to-pas
                             mv-nth-0-ia32e-la-to-pa-for-same-1G-page
                             not
                             pml4-table-base-addr
                             pml4-table-entry-addr
                             page-dir-ptr-table-entry-addr
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form-gl)))))

(defthm mv-nth-1-ia32e-la-to-pa-page-dir-ptr-table-for-same-1G-page
  (implies
   (and
    (equal page-dir-ptr-table-entry-addr
           (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr))
    (equal page-dir-ptr-table-entry
           (combine-bytes
            (mv-nth 1 (rb (create-canonical-address-list 8 page-dir-ptr-table-entry-addr) :r x86))))
    ;; PDPTE is direct mapped.
    (equal
     (mv-nth
      1
      (las-to-pas
       (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
       :r (cpl x86) x86))
     (addr-range 8 page-dir-ptr-table-entry-addr))
    (equal (page-size page-dir-ptr-table-entry) 1)
    (not (mv-nth 0 (ia32e-la-to-pa-page-dir-ptr-table
                    lin-addr page-dir-ptr-table-base-addr u/s-acc r/w-acc x/d-acc
                    wp smep smap ac nxe r-w-x cpl x86)))
    (canonical-address-p lin-addr)
    (canonical-address-p (+ n lin-addr))
    ;; (equal (loghead 30 lin-addr) 0)
    (equal (loghead 30 (+ n lin-addr)) n)
    (unsigned-byte-p 30 n)
    (physical-address-p page-dir-ptr-table-base-addr)
    (equal (loghead 12 page-dir-ptr-table-base-addr) 0)
    (not (page-structure-marking-mode x86))
    (x86p x86))
   (equal (mv-nth 1
                  (ia32e-la-to-pa-page-dir-ptr-table
                   (+ n lin-addr) page-dir-ptr-table-base-addr u/s-acc r/w-acc x/d-acc
                   wp smep smap ac nxe r-w-x cpl x86))
          (+ n
             (ash
              (loghead 22
                       (logtail 30
                                (rm-low-64
                                 (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr)
                                 x86)))
              30))))
  :hints (("Goal" :in-theory (e/d* (ia32e-la-to-pa-page-dir-ptr-table)
                                   (commutativity-of-+
                                    not
                                    page-dir-ptr-table-entry-addr-to-c-program-optimized-form
                                    page-dir-ptr-table-entry-addr-to-c-program-optimized-form-gl
                                    bitops::logand-with-negated-bitmask)))))

(defthm mv-nth-1-ia32e-la-to-pa-pml4-table-for-same-1G-page
  (implies
   (and
    (equal pml4-table-entry-addr (pml4-table-entry-addr lin-addr pml4-table-base-addr))
    (equal pml4-table-entry
           (combine-bytes
            (mv-nth 1 (rb (create-canonical-address-list 8 pml4-table-entry-addr) :r x86))))
    (equal page-dir-ptr-table-base-addr (ash (loghead 40 (logtail 12 pml4-table-entry)) 12))
    (equal page-dir-ptr-table-entry-addr (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr))
    (equal page-dir-ptr-table-entry
           (combine-bytes
            (mv-nth 1 (rb (create-canonical-address-list 8 page-dir-ptr-table-entry-addr) :r x86))))
    ;; PML4E and PDPTE are direct mapped.
    (equal
     (mv-nth
      1
      (las-to-pas
       (create-canonical-address-list 8 pml4-table-entry-addr)
       :r (cpl x86) x86))
     (addr-range 8 pml4-table-entry-addr))
    (equal
     (mv-nth
      1
      (las-to-pas
       (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
       :r (cpl x86) x86))
     (addr-range 8 page-dir-ptr-table-entry-addr))
    (equal (page-size page-dir-ptr-table-entry) 1)
    (not (mv-nth 0 (ia32e-la-to-pa-pml4-table
                    lin-addr pml4-table-base-addr
                    wp smep smap ac nxe r-w-x cpl x86)))
    (canonical-address-p lin-addr)
    (canonical-address-p (+ n lin-addr))
    ;; (equal (loghead 30 lin-addr) 0)
    (equal (loghead 30 (+ n lin-addr)) n)
    (unsigned-byte-p 30 n)
    (physical-address-p pml4-table-base-addr)
    (equal (loghead 12 pml4-table-base-addr) 0)
    (not (page-structure-marking-mode x86))
    (x86p x86))
   (equal (mv-nth 1
                  (ia32e-la-to-pa-pml4-table
                   (+ n lin-addr) pml4-table-base-addr
                   wp smep smap ac nxe r-w-x cpl x86))
          (+ n
             (ash
              (loghead 22
                       (logtail 30
                                (rm-low-64
                                 (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr)
                                 x86)))
              30))))
  :hints (("Goal"
           :in-theory (e/d* (ia32e-la-to-pa-pml4-table)
                            (commutativity-of-+
                             not
                             pml4-table-entry-addr-to-c-program-optimized-form
                             pml4-table-entry-addr-to-c-program-optimized-form-gl
                             bitops::logand-with-negated-bitmask)))))

(defthm mv-nth-1-ia32e-la-to-pa-for-same-1G-page
  (implies
   (and
    (equal pml4-table-base-addr (pml4-table-base-addr x86))
    (equal pml4-table-entry-addr (pml4-table-entry-addr lin-addr pml4-table-base-addr))
    (equal pml4-table-entry
           (combine-bytes
            (mv-nth 1
                    (rb (create-canonical-address-list 8 pml4-table-entry-addr)
                        :r x86))))
    (equal page-dir-ptr-table-base-addr
           (ash (loghead 40 (logtail 12 pml4-table-entry))
                12))
    (equal page-dir-ptr-table-entry-addr
           (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr))
    (equal page-dir-ptr-table-entry
           (combine-bytes (mv-nth 1 (rb (create-canonical-address-list 8 page-dir-ptr-table-entry-addr) :r x86))))
    (equal
     (mv-nth 1 (las-to-pas (create-canonical-address-list 8 pml4-table-entry-addr) :r (cpl x86) x86))
     (addr-range 8 pml4-table-entry-addr))
    (equal
     (mv-nth 1
             (las-to-pas
              (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
              :r (cpl x86) x86))
     (addr-range 8 page-dir-ptr-table-entry-addr))
    (equal (page-size page-dir-ptr-table-entry) 1)
    (not (mv-nth 0 (ia32e-la-to-pa lin-addr r-w-x cpl x86)))
    (canonical-address-p lin-addr)
    (canonical-address-p (+ n lin-addr))
    (equal (loghead 30 (+ n lin-addr)) n)
    (unsigned-byte-p 30 n)
    (not (page-structure-marking-mode x86))
    (x86p x86))
   (equal (mv-nth 1 (ia32e-la-to-pa (+ n lin-addr) r-w-x cpl x86))
          (+ n
             (ash
              (loghead 22
                       (logtail 30
                                (rm-low-64
                                 (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr)
                                 x86)))
              30))))
  :hints (("Goal"
           :in-theory (e/d* (ia32e-la-to-pa)
                            (commutativity-of-+
                             not
                             pml4-table-entry-addr-to-c-program-optimized-form
                             pml4-table-entry-addr-to-c-program-optimized-form-gl
                             bitops::logand-with-negated-bitmask)))))

(def-gl-export open-mv-nth-1-las-to-pas-for-same-1G-page-general-1
  :hyp (and (< iteration m)
            (canonical-address-p lin-addr)
            (canonical-address-p (+ -1 lin-addr m))
            (integerp m)
            (<= m 1073741824)
            (natp iteration)
            (equal (loghead 30 lin-addr) 0))
  :concl (canonical-address-p (+ iteration lin-addr))
  :g-bindings (gl::auto-bindings (:mix (:nat lin-addr 64) (:nat iteration 64) (:nat m 64))))

(defthmd open-mv-nth-1-las-to-pas-for-same-1G-page-general
  (implies
   (and
    (equal pml4-table-base-addr (pml4-table-base-addr x86))
    (equal pml4-table-entry-addr (pml4-table-entry-addr lin-addr pml4-table-base-addr))
    (equal pml4-table-entry
           (combine-bytes
            (mv-nth 1 (rb (create-canonical-address-list 8 pml4-table-entry-addr) :r x86))))
    (equal page-dir-ptr-table-base-addr (ash (loghead 40 (logtail 12 pml4-table-entry)) 12))
    (equal page-dir-ptr-table-entry-addr
           (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr))
    (equal page-dir-ptr-table-entry
           (combine-bytes
            (mv-nth
             1
             (rb (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
                 :r x86))))
    (equal
     (mv-nth
      1
      (las-to-pas (create-canonical-address-list 8 pml4-table-entry-addr)
                  :r (cpl x86) x86))
     (addr-range 8 pml4-table-entry-addr))
    (equal
     (mv-nth
      1
      (las-to-pas
       (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
       :r (cpl x86) x86))
     (addr-range 8 page-dir-ptr-table-entry-addr))
    (equal (page-size page-dir-ptr-table-entry) 1)
    (not (mv-nth 0 (ia32e-la-to-pa lin-addr r-w-x cpl x86)))
    (canonical-address-p lin-addr)
    (canonical-address-p (+ -1 lin-addr m))
    (natp m)
    (<= m *2^30*)
    (natp iteration)
    (equal (loghead 30 lin-addr) 0)
    (not (page-structure-marking-mode x86))
    (x86p x86))
   (equal (mv-nth 1 (las-to-pas
                     (create-canonical-address-list-alt iteration m lin-addr)
                     r-w-x cpl x86))
          (addr-range
           (+ (- iteration) m)
           (+ iteration
              (ash
               (loghead 22
                        (logtail 30
                                 (rm-low-64
                                  (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr)
                                  x86)))
               30)))))
  :hints (("Goal"
           :induct (create-canonical-address-list-alt iteration m lin-addr)
           :in-theory (e/d* (las-to-pas
                             open-mv-nth-1-las-to-pas-for-same-1G-page-general-1
                             open-mv-nth-0-las-to-pas-for-same-1G-page-general-1
                             open-mv-nth-0-las-to-pas-for-same-1G-page-general-2
                             open-mv-nth-0-las-to-pas-for-same-1G-page-general
                             ;; open-mv-nth-1-las-to-pas
                             mv-nth-1-ia32e-la-to-pa-for-same-1G-page)
                            (not
                             pml4-table-base-addr
                             pml4-table-entry-addr
                             page-dir-ptr-table-entry-addr
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form-gl)))))

(def-gl-export open-mv-nth-1-las-to-pas-for-same-1G-page-general-2
  :hyp (and (canonical-address-p lin-addr)
            (equal (loghead 30 lin-addr) 0))
  :concl (canonical-address-p (+ -1 *2^30* lin-addr))
  :g-bindings (gl::auto-bindings (:mix (:nat lin-addr 64))))

(defthm open-mv-nth-1-las-to-pas-for-same-1G-page
  (implies
   (and
    (equal pml4-table-base-addr (pml4-table-base-addr x86))
    (equal pml4-table-entry-addr (pml4-table-entry-addr lin-addr pml4-table-base-addr))
    (equal pml4-table-entry
           (combine-bytes
            (mv-nth 1 (rb (create-canonical-address-list 8 pml4-table-entry-addr) :r x86))))
    (equal page-dir-ptr-table-base-addr (ash (loghead 40 (logtail 12 pml4-table-entry)) 12))
    (equal page-dir-ptr-table-entry-addr
           (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr))
    (equal page-dir-ptr-table-entry
           (combine-bytes
            (mv-nth
             1
             (rb (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
                 :r x86))))
    (equal
     (mv-nth
      1
      (las-to-pas (create-canonical-address-list 8 pml4-table-entry-addr)
                  :r (cpl x86) x86))
     (addr-range 8 pml4-table-entry-addr))
    (equal
     (mv-nth
      1
      (las-to-pas
       (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
       :r (cpl x86) x86))
     (addr-range 8 page-dir-ptr-table-entry-addr))
    (equal (page-size page-dir-ptr-table-entry) 1)
    (not (mv-nth 0 (ia32e-la-to-pa lin-addr r-w-x cpl x86)))
    (canonical-address-p lin-addr)
    (equal (loghead 30 lin-addr) 0)
    (not (page-structure-marking-mode x86))
    (x86p x86))
   (equal (mv-nth 1 (las-to-pas
                     (create-canonical-address-list *2^30* lin-addr)
                     r-w-x cpl x86))
          (addr-range
           *2^30*
           (ash
            (loghead 22
                     (logtail 30
                              (rm-low-64
                               (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr)
                               x86)))
            30))))
  :hints (("Goal"
           :use ((:instance open-mv-nth-1-las-to-pas-for-same-1G-page-general
                            (iteration 0)
                            (m *2^30*))
                 (:instance open-mv-nth-1-las-to-pas-for-same-1G-page-general-2))
           :in-theory (e/d* (create-canonical-address-list-alt-is-create-canonical-address-list)
                            (open-mv-nth-1-las-to-pas-for-same-1G-page-general-2
                             las-to-pas
                             ;; open-mv-nth-0-las-to-pas
                             mv-nth-0-ia32e-la-to-pa-for-same-1G-page
                             not
                             pml4-table-base-addr
                             pml4-table-entry-addr
                             page-dir-ptr-table-entry-addr
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form-gl)))))

(defthmd las-to-pas-values-1G-pages-and-wb-to-page-dir-ptr-table-entry-addr-general
  (implies
   (and
    (equal pml4-table-base-addr (pml4-table-base-addr x86))
    (equal pml4-table-entry-addr (pml4-table-entry-addr lin-addr pml4-table-base-addr))
    (equal pml4-table-entry
           (combine-bytes
            (mv-nth 1
                    (rb (create-canonical-address-list 8 pml4-table-entry-addr)
                        :r x86))))
    (equal page-dir-ptr-table-base-addr
           (ash (loghead 40 (logtail 12 pml4-table-entry))
                12))
    (equal page-dir-ptr-table-entry-addr
           (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr))
    (equal page-dir-ptr-table-entry
           (combine-bytes
            (mv-nth
             1
             (rb (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
                 :r x86))))
    (equal
     (mv-nth
      1
      (las-to-pas (create-canonical-address-list 8 pml4-table-entry-addr)
                  :r (cpl x86)
                  x86))
     (addr-range 8 pml4-table-entry-addr))
    (equal
     (mv-nth
      1
      (las-to-pas
       (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
       :r (cpl x86)
       x86))
     (addr-range 8 page-dir-ptr-table-entry-addr))
    (equal (mv-nth 1 (las-to-pas (strip-cars addr-lst) :w (cpl x86) x86))
           (addr-range 8 page-dir-ptr-table-entry-addr))
    (disjoint-p
     (addr-range 8 (pml4-table-entry-addr lin-addr pml4-table-base-addr))
     (addr-range 8 (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr)))
    (not (mv-nth 0 (ia32e-la-to-pa lin-addr r-w-x cpl x86)))
    (equal (page-present page-dir-ptr-table-entry)
           (page-present (combine-bytes (strip-cdrs addr-lst))))
    (equal (page-read-write page-dir-ptr-table-entry)
           (page-read-write (combine-bytes (strip-cdrs addr-lst))))
    (equal (page-user-supervisor page-dir-ptr-table-entry)
           (page-user-supervisor (combine-bytes (strip-cdrs addr-lst))))
    (equal (page-execute-disable page-dir-ptr-table-entry)
           (page-execute-disable (combine-bytes (strip-cdrs addr-lst))))
    (equal (page-size page-dir-ptr-table-entry)
           (page-size (combine-bytes (strip-cdrs addr-lst))))
    (equal (page-size page-dir-ptr-table-entry) 1)
    (equal (part-select page-dir-ptr-table-entry :low 13 :high 29)
           (part-select (combine-bytes (strip-cdrs addr-lst)) :low 13 :high 29))
    (addr-byte-alistp addr-lst)
    (equal (len addr-lst) 8)
    (canonical-address-p lin-addr)
    (canonical-address-p (+ -1 lin-addr m))
    (natp m)
    (<= m *2^30*)
    (natp iteration)
    (equal (loghead 30 lin-addr) 0)
    (not (programmer-level-mode x86))
    (not (page-structure-marking-mode x86))
    (x86p x86))
   ;; las-to-pas returns the physical addresses corresponding to
   ;; linear addresses after the PDPTE corresponding to these linear
   ;; addresses have been modified --- the new PDPTE is (combine-bytes
   ;; (strip-cdrs addr-lst)).
   (and
    (equal (mv-nth 0 (las-to-pas
                      (create-canonical-address-list-alt iteration m lin-addr)
                      r-w-x cpl (mv-nth 1 (wb addr-lst x86))))
           nil)
    (equal (mv-nth 1 (las-to-pas
                      (create-canonical-address-list-alt iteration m lin-addr)
                      r-w-x cpl (mv-nth 1 (wb addr-lst x86))))
           (addr-range
            (+ (- iteration) m)
            (+ iteration
               (ash (loghead 22 (logtail 30 (combine-bytes (strip-cdrs addr-lst)))) 30))))))
  :hints (("Goal"
           :do-not '(preprocess)
           :induct (create-canonical-address-list-alt iteration m lin-addr)
           :in-theory (e/d*
                       (disjoint-p
                        member-p
                        las-to-pas
                        open-mv-nth-1-las-to-pas-for-same-1G-page-general-1
                        open-mv-nth-0-las-to-pas-for-same-1G-page-general-1
                        open-mv-nth-0-las-to-pas-for-same-1G-page-general-2
                        open-mv-nth-0-las-to-pas-for-same-1G-page-general
                        mv-nth-0-ia32e-la-to-pa-for-same-1G-page
                        mv-nth-1-ia32e-la-to-pa-for-same-1G-page)
                       (mv-nth-0-ia32e-la-to-pa-member-of-mv-nth-1-las-to-pas-if-lin-addr-member-p-in-non-marking-mode
                        member-p-strip-cars-of-remove-duplicate-keys
                        page-dir-ptr-table-entry-addr-to-c-program-optimized-form
                        page-dir-ptr-table-entry-addr-to-c-program-optimized-form-gl
                        bitops::logand-with-negated-bitmask
                        force (force)
                        not)))))

(defthm las-to-pas-values-1G-pages-and-wb-to-page-dir-ptr-table-entry-addr
  (implies
   (and
    (equal pml4-table-base-addr (pml4-table-base-addr x86))
    (equal pml4-table-entry-addr (pml4-table-entry-addr lin-addr pml4-table-base-addr))
    (equal pml4-table-entry
           (combine-bytes
            (mv-nth 1
                    (rb (create-canonical-address-list 8 pml4-table-entry-addr)
                        :r x86))))
    (equal page-dir-ptr-table-base-addr
           (ash (loghead 40 (logtail 12 pml4-table-entry)) 12))
    (equal page-dir-ptr-table-entry-addr
           (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr))
    (equal page-dir-ptr-table-entry
           (combine-bytes
            (mv-nth
             1
             (rb (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
                 :r x86))))
    (equal
     (mv-nth
      1
      (las-to-pas (create-canonical-address-list 8 pml4-table-entry-addr)
                  :r (cpl x86)
                  x86))
     (addr-range 8 pml4-table-entry-addr))
    (equal
     (mv-nth
      1
      (las-to-pas
       (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
       :r (cpl x86)
       x86))
     (addr-range 8 page-dir-ptr-table-entry-addr))
    (equal (mv-nth 1 (las-to-pas (strip-cars addr-lst) :w (cpl x86) x86))
           (addr-range 8 page-dir-ptr-table-entry-addr))
    (disjoint-p
     (addr-range 8 (pml4-table-entry-addr lin-addr pml4-table-base-addr))
     (addr-range 8 (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr)))
    (not (mv-nth 0 (ia32e-la-to-pa lin-addr r-w-x cpl x86)))
    (equal (page-present page-dir-ptr-table-entry)
           (page-present (combine-bytes (strip-cdrs addr-lst))))
    (equal (page-read-write page-dir-ptr-table-entry)
           (page-read-write (combine-bytes (strip-cdrs addr-lst))))
    (equal (page-user-supervisor page-dir-ptr-table-entry)
           (page-user-supervisor (combine-bytes (strip-cdrs addr-lst))))
    (equal (page-execute-disable page-dir-ptr-table-entry)
           (page-execute-disable (combine-bytes (strip-cdrs addr-lst))))
    (equal (page-size page-dir-ptr-table-entry)
           (page-size (combine-bytes (strip-cdrs addr-lst))))
    (equal (page-size page-dir-ptr-table-entry) 1)
    (equal (part-select page-dir-ptr-table-entry :low 13 :high 29)
           (part-select (combine-bytes (strip-cdrs addr-lst)) :low 13 :high 29))
    (addr-byte-alistp addr-lst)
    (equal (len addr-lst) 8)
    (canonical-address-p lin-addr)
    (equal (loghead 30 lin-addr) 0)
    (not (programmer-level-mode x86))
    (not (page-structure-marking-mode x86))
    (x86p x86))
   ;; las-to-pas returns the physical addresses corresponding to
   ;; linear addresses after the PDPTE corresponding to these linear
   ;; addresses have been modified --- the new PDPTE is (combine-bytes
   ;; (strip-cdrs addr-lst)).
   (and
    (equal (mv-nth 0 (las-to-pas
                      (create-canonical-address-list *2^30* lin-addr)
                      r-w-x cpl (mv-nth 1 (wb addr-lst x86))))
           nil)
    (equal (mv-nth 1 (las-to-pas
                      (create-canonical-address-list *2^30* lin-addr)
                      r-w-x cpl (mv-nth 1 (wb addr-lst x86))))
           (addr-range *2^30* (ash (loghead 22 (logtail 30 (combine-bytes (strip-cdrs addr-lst)))) 30)))))
  :hints (("Goal"
           :do-not '(preprocess)
           :do-not-induct t
           :use ((:instance las-to-pas-values-1G-pages-and-wb-to-page-dir-ptr-table-entry-addr-general
                            (m *2^30*)
                            (iteration 0))
                 (:instance open-mv-nth-1-las-to-pas-for-same-1G-page-general-2))
           :in-theory (e/d* (create-canonical-address-list-alt-is-create-canonical-address-list)
                            (member-p-strip-cars-of-remove-duplicate-keys
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form-gl
                             bitops::logand-with-negated-bitmask
                             force (force)
                             not)))))

(defthm read-from-physical-memory-and-wb-with-modified-1G-page-map-in-system-level-non-marking-mode
  (b* ((cpl (cpl x86))
       (pml4-table-base-addr (pml4-table-base-addr x86))
       (pml4-table-entry-addr (pml4-table-entry-addr lin-addr pml4-table-base-addr))
       (page-dir-ptr-table-base-addr
        (page-dir-ptr-table-base-addr lin-addr x86))
       (page-dir-ptr-table-entry-addr
        (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr))
       (page-dir-ptr-table-entry
        (combine-bytes
         (mv-nth 1 (rb (create-canonical-address-list 8 page-dir-ptr-table-entry-addr) :r x86))))
       (bytes (strip-cdrs addr-lst))
       (value (combine-bytes bytes)))
    (implies
     (and
      ;; PML4E and PDPTE are direct mapped.
      (equal
       (mv-nth
        1
        (las-to-pas
         (create-canonical-address-list 8 pml4-table-entry-addr)
         :r (cpl x86) x86))
       (addr-range 8 pml4-table-entry-addr))
      (equal
       (mv-nth
        1
        (las-to-pas
         (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
         :r (cpl x86) x86))
       (addr-range 8 page-dir-ptr-table-entry-addr))
      (equal (mv-nth 1 (las-to-pas (strip-cars addr-lst) :w cpl x86))
             (addr-range 8 page-dir-ptr-table-entry-addr))
      ;; The physical addresses pointed to by the new PDPTE (i.e.,
      ;; containing "value") are disjoint from the physical addresses
      ;; corresponding to the PDPTE itself.
      (disjoint-p
       (addr-range *2^30* (ash (loghead 22 (logtail 30 value)) 30))
       (addr-range 8 page-dir-ptr-table-entry-addr))
      (disjoint-p
       (addr-range 8 (pml4-table-entry-addr lin-addr pml4-table-base-addr))
       (addr-range 8 (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr)))
      (not (mv-nth 0 (las-to-pas (strip-cars addr-lst) :w cpl x86)))
      (equal (page-present page-dir-ptr-table-entry)
             (page-present value))
      (equal (page-read-write page-dir-ptr-table-entry)
             (page-read-write value))
      (equal (page-user-supervisor page-dir-ptr-table-entry)
             (page-user-supervisor value))
      (equal (page-execute-disable page-dir-ptr-table-entry)
             (page-execute-disable value))
      (equal (page-size page-dir-ptr-table-entry)
             (page-size value))
      (equal (page-size page-dir-ptr-table-entry) 1)
      (equal (part-select page-dir-ptr-table-entry :low 13 :high 29)
             (part-select value :low 13 :high 29))
      (addr-byte-alistp addr-lst)
      (equal (len addr-lst) 8)
      (canonical-address-p lin-addr)
      (canonical-address-p (+ -1 *2^30* lin-addr))
      ;; 1G-aligned linear address
      (equal (loghead 30 lin-addr) 0)
      (not (programmer-level-mode x86))
      (not (page-structure-marking-mode x86))
      (x86p x86))
     (equal (read-from-physical-memory
             (addr-range *2^30* (ash (loghead 22 (logtail 30 value)) 30))
             (mv-nth 1 (wb addr-lst x86)))
            (read-from-physical-memory
             (addr-range *2^30* (ash (loghead 22 (logtail 30 value)) 30))
             x86))))
  :hints (("Goal"
           :do-not-induct t
           :do-not '(preprocess)
           :in-theory (e/d* (disjoint-p
                             member-p
                             wb
                             page-dir-ptr-table-entry-addr
                             pml4-table-entry-addr)
                            (read-from-physical-memory
                             member-p-strip-cars-of-remove-duplicate-keys
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form-gl
                             bitops::logand-with-negated-bitmask
                             force (force)
                             not
                             rewire_dst_to_src-disable)))))

(defthm rb-wb-equal-with-modified-1G-page-map-in-system-level-non-marking-mode
  (implies
   (and
    (equal pml4-table-base-addr (pml4-table-base-addr x86))
    (equal pml4-table-entry-addr (pml4-table-entry-addr lin-addr pml4-table-base-addr))
    (equal pml4-table-entry
           (combine-bytes
            (mv-nth 1
                    (rb (create-canonical-address-list 8 pml4-table-entry-addr)
                        :r x86))))
    (equal page-dir-ptr-table-base-addr
           (ash (loghead 40 (logtail 12 pml4-table-entry)) 12))
    (equal page-dir-ptr-table-entry-addr
           (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr))
    (equal page-dir-ptr-table-entry
           (combine-bytes
            (mv-nth
             1
             (rb (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
                 :r x86))))
    (equal
     (mv-nth
      1
      (las-to-pas (create-canonical-address-list 8 pml4-table-entry-addr)
                  :r (cpl x86)
                  x86))
     (addr-range 8 pml4-table-entry-addr))
    (equal
     (mv-nth
      1
      (las-to-pas
       (create-canonical-address-list 8 page-dir-ptr-table-entry-addr)
       :r (cpl x86)
       x86))
     (addr-range 8 page-dir-ptr-table-entry-addr))
    (equal (mv-nth 1 (las-to-pas (strip-cars addr-lst) :w (cpl x86) x86))
           (addr-range 8 page-dir-ptr-table-entry-addr))
    (disjoint-p
     (addr-range 8 (pml4-table-entry-addr lin-addr pml4-table-base-addr))
     (addr-range 8 (page-dir-ptr-table-entry-addr lin-addr page-dir-ptr-table-base-addr)))
    (disjoint-p
     (addr-range *2^30* (ash (loghead 22 (logtail 30 (combine-bytes (strip-cdrs addr-lst)))) 30))
     (mv-nth 1 (las-to-pas (strip-cars addr-lst) :w (cpl x86) x86)))
;;;
    (not (mv-nth 0 (ia32e-la-to-pa lin-addr r-w-x (cpl x86) x86)))
;;;
    (not (mv-nth 0 (las-to-pas (strip-cars addr-lst) :w (cpl x86) x86)))
    (not (mv-nth 0 (las-to-pas (create-canonical-address-list *2^30* lin-addr)
                               r-w-x (cpl x86) x86)))
    (equal (page-present page-dir-ptr-table-entry)
           (page-present (combine-bytes (strip-cdrs addr-lst))))
    (equal (page-read-write page-dir-ptr-table-entry)
           (page-read-write (combine-bytes (strip-cdrs addr-lst))))
    (equal (page-user-supervisor page-dir-ptr-table-entry)
           (page-user-supervisor (combine-bytes (strip-cdrs addr-lst))))
    (equal (page-execute-disable page-dir-ptr-table-entry)
           (page-execute-disable (combine-bytes (strip-cdrs addr-lst))))
    (equal (page-size page-dir-ptr-table-entry)
           (page-size (combine-bytes (strip-cdrs addr-lst))))
    (equal (page-size page-dir-ptr-table-entry) 1)
    (equal (part-select page-dir-ptr-table-entry :low 13 :high 29)
           (part-select (combine-bytes (strip-cdrs addr-lst)) :low 13 :high 29))
    (addr-byte-alistp addr-lst)
    (equal (len addr-lst) 8)
    (canonical-address-p lin-addr)
    (equal (loghead 30 lin-addr) 0)
    (not (programmer-level-mode x86))
    (not (page-structure-marking-mode x86))
    (x86p x86))
   (and (equal (mv-nth 0 (rb (create-canonical-address-list *2^30* lin-addr)
                             r-w-x (mv-nth 1 (wb addr-lst x86)))) nil)
        (equal (mv-nth 1 (rb (create-canonical-address-list *2^30* lin-addr)
                             r-w-x (mv-nth 1 (wb addr-lst x86))))
               (read-from-physical-memory
                (addr-range *2^30* (ash (loghead 22 (logtail 30 (combine-bytes (strip-cdrs addr-lst)))) 30))
                x86))))
  :hints (("Goal"
           :use
           ((:instance read-from-physical-memory-and-wb-with-modified-1G-page-map-in-system-level-non-marking-mode)
            (:instance open-mv-nth-1-las-to-pas-for-same-1G-page-general-2))
           :do-not-induct t
           :do-not '(preprocess)
           :in-theory (e/d* (rb disjoint-p member-p)
                            (read-from-physical-memory
                             read-from-physical-memory-and-wb-with-modified-1G-page-map-in-system-level-non-marking-mode
                             wb
                             member-p-strip-cars-of-remove-duplicate-keys
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form-gl
                             bitops::logand-with-negated-bitmask
                             force (force)
                             not)))))

(def-gl-export entry-attributes-unchanged-when-destination-PDPTE-modified
  :hyp (and (unsigned-byte-p 64 dest-pdpte)
            (unsigned-byte-p 64 src-pdpte))
  :concl (and
          (equal (page-present (logior (logand 18442240475155922943 dest-pdpte)
                                       (logand 4503598553628672 src-pdpte)))
                 (page-present dest-pdpte))
          (equal (page-read-write (logior (logand 18442240475155922943 dest-pdpte)
                                          (logand 4503598553628672 src-pdpte)))
                 (page-read-write dest-pdpte))
          (equal (page-user-supervisor (logior (logand 18442240475155922943 dest-pdpte)
                                               (logand 4503598553628672 src-pdpte)))
                 (page-user-supervisor dest-pdpte))
          (equal (page-execute-disable (logior (logand 18442240475155922943 dest-pdpte)
                                               (logand 4503598553628672 src-pdpte)))
                 (page-execute-disable dest-pdpte))
          (equal (page-size (logior (logand 18442240475155922943 dest-pdpte)
                                    (logand 4503598553628672 src-pdpte)))
                 (page-size dest-pdpte)))
  :g-bindings
  (gl::auto-bindings (:mix (:nat src-pdpte 64) (:nat dest-pdpte 64))))

(defthm rb-of-1G-in-terms-of-read-from-physical-memory
  (implies (and (not (programmer-level-mode x86))
                (not (page-structure-marking-mode x86)))
           (equal
            (mv-nth 1 (rb (create-canonical-address-list *2^30* (xr :rgf *rdi* x86)) :r x86))
            (read-from-physical-memory
             (mv-nth 1 (las-to-pas
                        (create-canonical-address-list *2^30* (xr :rgf *rdi* x86))
                        :r (cpl x86) x86))
             x86)))
  :hints (("Goal"
           :do-not '(preprocess)
           :do-not-induct t
           :in-theory (e/d* (rb-wb-equal-in-system-level-non-marking-mode
                             pos member-p subset-p
                             page-size
                             rb)

                            (rewire_dst_to_src-clk
                             (rewire_dst_to_src-clk)

                             pml4-table-base-addr
                             page-dir-ptr-table-base-addr
                             pml4-table-entry-addr
                             page-dir-ptr-table-entry-addr

                             pml4-table-entry-addr-to-c-program-optimized-form
                             pml4-table-entry-addr-to-c-program-optimized-form-gl
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form-gl

                             not
                             bitops::logand-with-negated-bitmask
                             unsigned-byte-p
                             force (force))))))

;; ----------------------------------------------------------------------

(defun-nx direct-map-p (x86)
  ;; Direct map for paging structures, specifically source and
  ;; destination PML4E and PDPTE.
  (and
   ;; Source:
   (equal (mv-nth 1 (las-to-pas
                     (create-canonical-address-list
                      8
                      (pml4-table-entry-addr (xr :rgf *rdi* x86) (pml4-table-base-addr x86)))
                     :r (cpl x86) x86))
          (addr-range
           8
           (pml4-table-entry-addr (xr :rgf *rdi* x86) (pml4-table-base-addr x86))))

   (equal
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list
                8
                (page-dir-ptr-table-entry-addr
                 (xr :rgf *rdi* x86)
                 (page-dir-ptr-table-base-addr (xr :rgf *rdi* x86) x86)))
               :r 0 x86))
    (addr-range
     8
     (page-dir-ptr-table-entry-addr
      (xr :rgf *rdi* x86)
      (page-dir-ptr-table-base-addr (xr :rgf *rdi* x86) x86))))

   ;; Destination:
   (equal
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list
                8
                (pml4-table-entry-addr (xr :rgf *rsi* x86) (pml4-table-base-addr x86)))
               :r (cpl x86) x86))
    (addr-range
     8
     (pml4-table-entry-addr (xr :rgf *rsi* x86) (pml4-table-base-addr x86))))

   (equal
    (mv-nth 1 (las-to-pas
               (create-canonical-address-list
                8
                (page-dir-ptr-table-entry-addr
                 (xr :rgf *rsi* x86)
                 (page-dir-ptr-table-base-addr (xr :rgf *rsi* x86) x86)))
               :r 0 x86))
    (addr-range
     8
     (page-dir-ptr-table-entry-addr
      (xr :rgf *rsi* x86)
      (page-dir-ptr-table-base-addr (xr :rgf *rsi* x86) x86))))))

(defun-nx source-physical-addresses-and-destination-PDPTE-no-interfere-p (x86)
  ;; The source physical addresses are disjoint from the the physical
  ;; addresses of the destination PDPTE.
  (disjoint-p
   (addr-range *2^30*
               (ash (loghead 22 (logtail 30
                                         (rm-low-64
                                          (page-dir-ptr-table-entry-addr
                                           (xr :rgf *rdi* x86)
                                           (page-dir-ptr-table-base-addr (xr :rgf *rdi* x86) x86))
                                          x86)))
                    30))
   (addr-range 8
               (page-dir-ptr-table-entry-addr
                (xr :rgf *rsi* x86)
                (page-dir-ptr-table-base-addr (xr :rgf *rsi* x86) x86)))))

(defun-nx destination-PML4E-and-destination-PDPTE-no-interfere-p (x86)
  (disjoint-p
   (addr-range 8 (pml4-table-entry-addr (xr :rgf *rsi* x86) (pml4-table-base-addr x86)))
   (addr-range 8 (page-dir-ptr-table-entry-addr
                  (xr :rgf *rsi* x86)
                  (page-dir-ptr-table-base-addr (xr :rgf *rsi* x86) x86)))))

(defun-nx destination-translation-governing-addresses-and-stack-no-interfere-p (x86)
  ;; The translation-governing addresses of the destination are disjoint
  ;; from the physical addresses corresponding to the stack.
  (disjoint-p
   (all-translation-governing-addresses
    (create-canonical-address-list *2^30* (xr :rgf *rsi* x86)) x86)
   (mv-nth 1 (las-to-pas
              (create-canonical-address-list
               8 (+ -24 (xr :rgf *rsp* x86))) :w (cpl x86) x86))))

(defun-nx source-addresses-and-stack-no-interfere-p (x86)
  ;; The source addresses are disjoint from the physical addresses
  ;; corresponding to the stack.
  (disjoint-p
   (addr-range
    *2^30*
    (ash
     (loghead
      22
      (logtail
       30
       (rm-low-64 (page-dir-ptr-table-entry-addr
                   (xr :rgf *rdi* x86)
                   (page-dir-ptr-table-base-addr (xr :rgf *rdi* x86) x86))
                  x86)))
     30))
   (mv-nth
    1
    (las-to-pas (create-canonical-address-list 8 (+ -24 (xr :rgf *rsp* x86)))
                :w (cpl x86) x86))))

(defun-nx more-non-interference-assumptions (x86)
  (and (source-physical-addresses-and-destination-PDPTE-no-interfere-p x86)
       (destination-PML4E-and-destination-PDPTE-no-interfere-p x86)
       (destination-translation-governing-addresses-and-stack-no-interfere-p x86)
       (source-addresses-and-stack-no-interfere-p x86)))

;; ----------------------------------------------------------------------

(defthm rewire_dst_to_src-after-the-copy-source-p-addrs-open
  (implies (and (equal cpl (cpl x86))
                (rewire_dst_to_src-assumptions x86)
                (direct-map-p x86))

           (equal
            (mv-nth 1 (las-to-pas (create-canonical-address-list
                                   *2^30* (xr :rgf *rdi* x86)) :r cpl x86))
            (addr-range *2^30*
                        (ash (loghead 22
                                      (logtail 30
                                               (rm-low-64
                                                (page-dir-ptr-table-entry-addr
                                                 (xr :rgf *rdi* x86)
                                                 (page-dir-ptr-table-base-addr (xr :rgf *rdi* x86) x86))
                                                x86)))
                             30))))
  :hints (("Goal"
           :use ((:instance las-to-pas-values-1G-pages-and-wb-to-page-dir-ptr-table-entry-addr-general
                            (lin-addr (xr :rgf *rdi* x86))
                            (r-w-x :r)
                            (cpl (cpl x86))))
           :do-not '(preprocess)
           :do-not-induct t
           :in-theory (e/d* (page-dir-ptr-table-base-addr
                             pml4-table-base-addr
                             pos
                             page-size)
                            (rewire_dst_to_src-clk
                             (rewire_dst_to_src-clk)
                             addr-range
                             (addr-range)
                             pml4-table-entry-addr
                             natp-pml4-table-entry-addr
                             page-dir-ptr-table-entry-addr
                             pml4-table-entry-addr-to-c-program-optimized-form
                             pml4-table-entry-addr-to-c-program-optimized-form-gl
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form-gl
                             disjointness-of-all-translation-governing-addresses-from-all-translation-governing-addresses-subset-p
                             acl2::consp-when-member-equal-of-atom-listp
                             r-w-x-is-irrelevant-for-mv-nth-1-ia32e-la-to-pa-when-no-errors
                             ia32e-la-to-pa-xw-state
                             (:linear adding-7-to-pml4-table-entry-addr)
                             (:linear *physical-address-size*p-pml4-table-entry-addr)
                             (:rewrite las-to-pas-xw-state)
                             (:rewrite acl2::equal-of-booleans-rewrite)
                             (:rewrite loghead-unequal)
                             (:rewrite negative-logand-to-positive-logand-with-integerp-x)
                             (:definition combine-bytes)
                             (:rewrite |(logand -4096 base-addr) = base-addr when low 12 bits are 0|)
                             not
                             unsigned-byte-p-of-combine-bytes
                             unsigned-byte-p-of-logtail
                             disjoint-p-subset-p
                             acl2::loghead-identity
                             acl2::ash-0
                             acl2::zip-open
                             acl2::logtail-identity
                             bitops::logand-with-negated-bitmask
                             member-p-strip-cars-of-remove-duplicate-keys
                             unsigned-byte-p
                             force (force))))))

(defthm rewire_dst_to_src-after-the-copy-destination==source
  (implies (and (rewire_dst_to_src-assumptions x86)
                (direct-map-p x86)
                (more-non-interference-assumptions x86))
           (equal
            ;; Destination, after the copy:
            (mv-nth 1 (rb  (create-canonical-address-list *2^30* (xr :rgf *rsi* x86))
                           :r (x86-run (rewire_dst_to_src-clk) x86)))
            ;; Source, before the copy:
            (mv-nth 1 (rb (create-canonical-address-list *2^30* (xr :rgf *rdi* x86))
                          :r x86))))
  :hints (("Goal"
           :do-not '(preprocess)
           :do-not-induct t
           :in-theory (e/d* (rb-wb-equal-in-system-level-non-marking-mode
                             pos
                             page-dir-ptr-table-base-addr
                             page-size)

                            (rewire_dst_to_src-clk
                             (rewire_dst_to_src-clk)
                             (addr-range)
                             addr-range

                             pml4-table-base-addr
                             ;; page-dir-ptr-table-base-addr
                             pml4-table-entry-addr
                             page-dir-ptr-table-entry-addr

                             pml4-table-entry-addr-to-c-program-optimized-form
                             pml4-table-entry-addr-to-c-program-optimized-form-gl
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form
                             page-dir-ptr-table-entry-addr-to-c-program-optimized-form-gl

                             disjointness-of-all-translation-governing-addresses-from-all-translation-governing-addresses-subset-p
                             acl2::consp-when-member-equal-of-atom-listp
                             r-w-x-is-irrelevant-for-mv-nth-1-ia32e-la-to-pa-when-no-errors
                             ia32e-la-to-pa-xw-state
                             (:linear adding-7-to-pml4-table-entry-addr)
                             (:linear *physical-address-size*p-pml4-table-entry-addr)
                             (:rewrite las-to-pas-xw-state)
                             (:rewrite acl2::equal-of-booleans-rewrite)
                             (:rewrite loghead-unequal)
                             (:rewrite negative-logand-to-positive-logand-with-integerp-x)
                             (:definition combine-bytes)
                             (:rewrite |(logand -4096 base-addr) = base-addr when low 12 bits are 0|)
                             member-p-strip-cars-of-remove-duplicate-keys
                             not
                             bitops::logand-with-negated-bitmask
                             unsigned-byte-p
                             force (force))))))

;; ======================================================================

||#
