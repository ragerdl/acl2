(JAVA::HEX-DIGITP-OF-CHAR-CODE (12 12 (:REWRITE DEFAULT-<-2))
                               (12 12 (:REWRITE DEFAULT-<-1))
                               (2 2 (:REWRITE DEFAULT-CHAR-CODE)))
(JAVA::HEX-DIGIT-LISTP-OF-CHARS=>NATS
     (35 10
         (:REWRITE JAVA::HEX-DIGIT-LISTP-WHEN-NOT-CONSP))
     (30 5
         (:REWRITE STR::HEX-DIGIT-LISTP-OF-CDR-WHEN-HEX-DIGIT-LISTP))
     (20 20
         (:REWRITE JAVA::HEX-DIGIT-LISTP-WHEN-SUBSETP-EQUAL))
     (18 3
         (:REWRITE STR::HEX-DIGITP-OF-CAR-WHEN-HEX-DIGIT-LISTP))
     (15 15 (:REWRITE DEFAULT-CDR))
     (15 5
         (:REWRITE STR::HEX-DIGITP-WHEN-NONZERO-HEX-DIGITP))
     (10 10
         (:TYPE-PRESCRIPTION STR::NONZERO-HEX-DIGITP$INLINE))
     (10 10 (:REWRITE DEFAULT-CAR))
     (8 8 (:REWRITE CONSP-OF-CHARS=>NATS))
     (8 8
        (:REWRITE CHARS=>NATS-OF-MAKE-CHARACTER-LIST-CHARS-NORMALIZE-CONST))
     (7 7 (:REWRITE DEFAULT-CHAR-CODE))
     (1 1 (:REWRITE SUBSETP-TRANS2))
     (1 1 (:REWRITE SUBSETP-TRANS)))
