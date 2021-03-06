(|(+ (+ x y) z)|)
(|(+ 0 x)|)
(|(+ x 0)| (3 3
              (:REWRITE RATIONALP-IMPLIES-ACL2-NUMBERP))
           (2 1 (:REWRITE DEFAULT-+-1))
           (1 1 (:REWRITE DEFAULT-+-2)))
(|(+ c (+ d x))|)
(|(- (- x))|)
(|(- (+ x y))|)
(|(* (* x y) z)|)
(|(* 1 x)|)
(|(* x 1)| (3 3
              (:REWRITE RATIONALP-IMPLIES-ACL2-NUMBERP))
           (2 1 (:REWRITE DEFAULT-*-1))
           (1 1 (:REWRITE DEFAULT-*-2)))
(|(* 0 x)|)
(|(* x 0)|)
(|(* -1 x)| (2 2
               (:REWRITE RATIONALP-IMPLIES-ACL2-NUMBERP)))
(|(* x -1)| (2 2
               (:REWRITE RATIONALP-IMPLIES-ACL2-NUMBERP)))
(|(* c (* d x))|)
(|(/ (/ x))|)
(|(/ (* x y))|)
(|(* x (+ y z))| (7 5 (:REWRITE DEFAULT-*-2))
                 (6 5 (:REWRITE DEFAULT-*-1))
                 (5 5
                    (:REWRITE RATIONALP-IMPLIES-ACL2-NUMBERP))
                 (4 3 (:REWRITE DEFAULT-+-2))
                 (4 3 (:REWRITE DEFAULT-+-1)))
(|(* (+ x y) z)| (10 7 (:REWRITE DEFAULT-*-2))
                 (10 7 (:REWRITE DEFAULT-*-1))
                 (8 8
                    (:REWRITE RATIONALP-IMPLIES-ACL2-NUMBERP))
                 (4 3 (:REWRITE DEFAULT-+-2))
                 (4 3 (:REWRITE DEFAULT-+-1)))
(|(* x (- y))|)
(|(* (- x) y)|)
(|(- (* c x))|)
(|(/ (- x))|)
(|(equal (/ x) 0)|)
(|(equal (- x) 0)|)
(|(equal (/ x) (/ y))|)
(|(equal (- x) (- y))|)
(|(< (/ x) 0)| (2 2 (:REWRITE DEFAULT-<-2))
               (2 2 (:REWRITE DEFAULT-<-1))
               (1 1 (:REWRITE DEFAULT-UNARY-/)))
(|(< 0 (/ x))| (2 2 (:REWRITE DEFAULT-<-2))
               (2 2 (:REWRITE DEFAULT-<-1))
               (1 1 (:REWRITE DEFAULT-UNARY-/)))
(|(< (- x) 0)| (3 2 (:REWRITE DEFAULT-<-2))
               (2 2
                  (:REWRITE RATIONALP-IMPLIES-ACL2-NUMBERP))
               (2 2 (:REWRITE DEFAULT-<-1)))
(|(< 0 (- x))| (3 2 (:REWRITE DEFAULT-<-1))
               (2 2
                  (:REWRITE RATIONALP-IMPLIES-ACL2-NUMBERP))
               (2 2 (:REWRITE DEFAULT-<-2)))
(|(< (- x) (- y))| (8 8
                      (:REWRITE RATIONALP-IMPLIES-ACL2-NUMBERP)))
(|(+ (if x y z) w)|)
(|(+ w (if x y z))|)
(|(- (if x y z))|)
(|(* (if x y z) w)|)
(|(* w (if x y z))|)
(|(/ (if x y z))|)
(|(expt (if x y z) w)|
     (9 9
        (:TYPE-PRESCRIPTION RATIONALP-EXPT-TYPE-PRESCRIPTION))
     (9 9
        (:TYPE-PRESCRIPTION EXPT-TYPE-PRESCRIPTION-RATIONALP))
     (9 9
        (:TYPE-PRESCRIPTION EXPT-TYPE-PRESCRIPTION-POSITIVE-2))
     (9 9
        (:TYPE-PRESCRIPTION EXPT-TYPE-PRESCRIPTION-POSITIVE-1))
     (9 9
        (:TYPE-PRESCRIPTION EXPT-TYPE-PRESCRIPTION-NONZERO))
     (9 9
        (:TYPE-PRESCRIPTION EXPT-TYPE-PRESCRIPTION-NON-ZERO-BASE))
     (9 9
        (:TYPE-PRESCRIPTION EXPT-TYPE-PRESCRIPTION-INTEGERP)))
(|(expt w (if x y z))|
     (9 9
        (:TYPE-PRESCRIPTION RATIONALP-EXPT-TYPE-PRESCRIPTION))
     (9 9
        (:TYPE-PRESCRIPTION EXPT-TYPE-PRESCRIPTION-RATIONALP))
     (9 9
        (:TYPE-PRESCRIPTION EXPT-TYPE-PRESCRIPTION-POSITIVE-2))
     (9 9
        (:TYPE-PRESCRIPTION EXPT-TYPE-PRESCRIPTION-POSITIVE-1))
     (9 9
        (:TYPE-PRESCRIPTION EXPT-TYPE-PRESCRIPTION-NONZERO))
     (9 9
        (:TYPE-PRESCRIPTION EXPT-TYPE-PRESCRIPTION-NON-ZERO-BASE))
     (9 9
        (:TYPE-PRESCRIPTION EXPT-TYPE-PRESCRIPTION-INTEGERP)))
(|(equal w (if x y z))|)
(|(equal (if x y z) w)|)
(|(< w (if x y z))|)
(|(< (if x y z) w)|)
