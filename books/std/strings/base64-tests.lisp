; ACL2 String Library
; Copyright (C) 2009-2013 Centaur Technology
;
; Contact:
;   Centaur Technology Formal Verification Group
;   7600-C N. Capital of Texas Highway, Suite 300, Austin, TX 78731, USA.
;   http://www.centtech.com/
;
; License: (An MIT/X11-style license)
;
;   Permission is hereby granted, free of charge, to any person obtaining a
;   copy of this software and associated documentation files (the "Software"),
;   to deal in the Software without restriction, including without limitation
;   the rights to use, copy, modify, merge, publish, distribute, sublicense,
;   and/or sell copies of the Software, and to permit persons to whom the
;   Software is furnished to do so, subject to the following conditions:
;
;   The above copyright notice and this permission notice shall be included in
;   all copies or substantial portions of the Software.
;
;   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;   DEALINGS IN THE SOFTWARE.
;
; Original author: Jared Davis <jared@centtech.com>

(in-package "STR")
(include-book "base64")
(include-book "std/testing/assert-bang" :dir :system)


;; Test vectors from RFC 4648, Section 10.

(assert! (equal (base64-encode "") ""))
(assert! (equal (base64-encode "f") "Zg=="))
(assert! (equal (base64-encode "fo") "Zm8="))
(assert! (equal (base64-encode "foo") "Zm9v"))
(assert! (equal (base64-encode "foob") "Zm9vYg=="))
(assert! (equal (base64-encode "fooba") "Zm9vYmE="))
(assert! (equal (base64-encode "foobar") "Zm9vYmFy"))

(define base64-decode-easy ((x stringp))
  (b* (((mv ok orig) (base64-decode x))
       ((unless ok)
        (raise "Whoops")
        ""))
    orig))

(assert! (equal "" (base64-decode-easy "")))
(assert! (equal "f" (base64-decode-easy "Zg==")))
(assert! (equal "fo" (base64-decode-easy "Zm8=")))
(assert! (equal "foo" (base64-decode-easy "Zm9v")))
(assert! (equal "foob" (base64-decode-easy "Zm9vYg==")))
(assert! (equal "fooba" (base64-decode-easy "Zm9vYmE=")))
(assert! (equal "foobar" (base64-decode-easy "Zm9vYmFy")))
