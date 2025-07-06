;; Music Collaboration Hub Contract

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-MUSICIAN-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-ENDORSED (err u102))
(define-constant ERR-INVALID-PRIVACY-LEVEL (err u103))
(define-constant ERR-COMPOSITION-NOT-FOUND (err u104))

;; Privacy levels
(define-constant PRIVACY-PUBLIC u0)
(define-constant PRIVACY-MUSIC-NETWORK u1)
(define-constant PRIVACY-PRIVATE u2)

;; Data structures
(define-map musician-profiles
  principal
  {
    musician-name: (string-ascii 50),
    bio: (string-ascii 500),
    instruments: (string-ascii 200),
    privacy-level: uint,
    joined-at: uint,
    is-verified: bool
  })

(define-map musical-compositions
  { musician: principal, composition-id: uint }
  {
    composition-title: (string-ascii 100),
    genre: (string-ascii 100),
    creation-date: uint,
    duration: (optional uint),
    composition-notes: (string-ascii 500),
    privacy-level: uint
  })

(define-map band-formations
  { musician: principal, formation-id: uint }
  {
    band-name: (string-ascii 100),
    role: (string-ascii 100),
    join-date: uint,
    leave-date: (optional uint),
    band-description: (string-ascii 500),
    privacy-level: uint,
    is-verified: bool
  })

(define-map talent-endorsements
  { endorser: principal, endorsee: principal, talent: (string-ascii 50) }
  {
    endorsement-note: (string-ascii 200),
    timestamp: uint,
    is-public: bool
  })

(define-map music-connections
  { musician1: principal, musician2: principal }
  {
    status: (string-ascii 20), ;; "pending", "accepted", "blocked"
    initiated-by: principal,
    timestamp: uint
  })

;; Counters for unique IDs
(define-data-var composition-id-counter uint u0)
(define-data-var formation-id-counter uint u0)

;; Contract owner
(define-data-var contract-owner principal tx-sender)

;; Musician profile management functions
(define-public (create-musician-profile (musician-name (string-ascii 50)) (bio (string-ascii 500)) (instruments (string-ascii 200)) (privacy-level uint))
  (begin
    (asserts! (<= privacy-level PRIVACY-PRIVATE) ERR-INVALID-PRIVACY-LEVEL)
    (ok (map-set musician-profiles tx-sender {
      musician-name: musician-name,
      bio: bio,
      instruments: instruments,
      privacy-level: privacy-level,
      joined-at: block-height,
      is-verified: false
    }))))

(define-public (update-musician-profile (musician-name (string-ascii 50)) (bio (string-ascii 500)) (instruments (string-ascii 200)) (privacy-level uint))
  (begin
    (asserts! (<= privacy-level PRIVACY-PRIVATE) ERR-INVALID-PRIVACY-LEVEL)
    (asserts! (is-some (map-get? musician-profiles tx-sender)) ERR-MUSICIAN-NOT-FOUND)
    (ok (map-set musician-profiles tx-sender {
      musician-name: musician-name,
      bio: bio,
      instruments: instruments,
      privacy-level: privacy-level,
      joined-at: (default-to block-height (get joined-at (map-get? musician-profiles tx-sender))),
      is-verified: (default-to false (get is-verified (map-get? musician-profiles tx-sender)))
    }))))

;; Musical composition functions
(define-public (add-musical-composition (composition-title (string-ascii 100)) (genre (string-ascii 100)) (creation-date uint) (duration (optional uint)) (composition-notes (string-ascii 500)) (privacy-level uint))
  (let ((composition-id (+ (var-get composition-id-counter) u1)))
    (begin
      (asserts! (<= privacy-level PRIVACY-PRIVATE) ERR-INVALID-PRIVACY-LEVEL)
      (asserts! (is-some (map-get? musician-profiles tx-sender)) ERR-MUSICIAN-NOT-FOUND)
      (var-set composition-id-counter composition-id)
      (ok (map-set musical-compositions { musician: tx-sender, composition-id: composition-id } {
        composition-title: composition-title,
        genre: genre,
        creation-date: creation-date,
        duration: duration,
        composition-notes: composition-notes,
        privacy-level: privacy-level
      })))))

;; Band formation functions
(define-public (add-band-formation (band-name (string-ascii 100)) (role (string-ascii 100)) (join-date uint) (leave-date (optional uint)) (band-description (string-ascii 500)) (privacy-level uint))
  (let ((formation-id (+ (var-get formation-id-counter) u1)))
    (begin
      (asserts! (<= privacy-level PRIVACY-PRIVATE) ERR-INVALID-PRIVACY-LEVEL)
      (asserts! (is-some (map-get? musician-profiles tx-sender)) ERR-MUSICIAN-NOT-FOUND)
      (var-set formation-id-counter formation-id)
      (ok (map-set band-formations { musician: tx-sender, formation-id: formation-id } {
        band-name: band-name,
        role: role,
        join-date: join-date,
        leave-date: leave-date,
        band-description: band-description,
        privacy-level: privacy-level,
        is-verified: false
      })))))

(define-public (verify-musical-composition (musician principal) (composition-id uint))
  (let ((composition (map-get? musical-compositions { musician: musician, composition-id: composition-id })))
    (begin
      (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
      (asserts! (is-some composition) ERR-COMPOSITION-NOT-FOUND)
      (ok true))))

;; Talent endorsement functions
(define-public (endorse-musical-talent (endorsee principal) (talent (string-ascii 50)) (endorsement-note (string-ascii 200)) (is-public bool))
  (begin
    (asserts! (is-some (map-get? musician-profiles tx-sender)) ERR-MUSICIAN-NOT-FOUND)
    (asserts! (is-some (map-get? musician-profiles endorsee)) ERR-MUSICIAN-NOT-FOUND)
    (asserts! (is-none (map-get? talent-endorsements { endorser: tx-sender, endorsee: endorsee, talent: talent })) ERR-ALREADY-ENDORSED)
    (ok (map-set talent-endorsements { endorser: tx-sender, endorsee: endorsee, talent: talent } {
      endorsement-note: endorsement-note,
      timestamp: block-height,
      is-public: is-public
    }))))

;; Music connection functions
(define-public (send-music-collaboration-invite (to-musician principal))
  (begin
    (asserts! (is-some (map-get? musician-profiles tx-sender)) ERR-MUSICIAN-NOT-FOUND)
    (asserts! (is-some (map-get? musician-profiles to-musician)) ERR-MUSICIAN-NOT-FOUND)
    (ok (map-set music-connections { musician1: tx-sender, musician2: to-musician } {
      status: "pending",
      initiated-by: tx-sender,
      timestamp: block-height
    }))))

(define-public (accept-music-collaboration-invite (from-musician principal))
  (let ((connection (map-get? music-connections { musician1: from-musician, musician2: tx-sender })))
    (begin
      (asserts! (is-some connection) ERR-MUSICIAN-NOT-FOUND)
      (asserts! (is-eq (get status (unwrap-panic connection)) "pending") ERR-NOT-AUTHORIZED)
      (ok (map-set music-connections { musician1: from-musician, musician2: tx-sender }
        (merge (unwrap-panic connection) { status: "accepted" }))))))

;; Read-only functions with privacy controls
(define-read-only (get-musician-profile (musician principal))
  (let ((profile (map-get? musician-profiles musician)))
    (if (is-some profile)
      (let ((profile-data (unwrap-panic profile)))
        (if (or (is-eq (get privacy-level profile-data) PRIVACY-PUBLIC)
                (is-eq musician tx-sender)
                (is-music-connected musician tx-sender))
          profile
          none))
      none)))

(define-read-only (get-musical-composition (musician principal) (composition-id uint))
  (let ((composition (map-get? musical-compositions { musician: musician, composition-id: composition-id })))
    (if (is-some composition)
      (let ((composition-data (unwrap-panic composition)))
        (if (can-view-music-data musician (get privacy-level composition-data))
          composition
          none))
      none)))

(define-read-only (get-band-formation (musician principal) (formation-id uint))
  (let ((formation (map-get? band-formations { musician: musician, formation-id: formation-id })))
    (if (is-some formation)
      (let ((formation-data (unwrap-panic formation)))
        (if (can-view-music-data musician (get privacy-level formation-data))
          formation
          none))
      none)))

(define-read-only (get-talent-endorsement (endorser principal) (endorsee principal) (talent (string-ascii 50)))
  (let ((endorsement (map-get? talent-endorsements { endorser: endorser, endorsee: endorsee, talent: talent })))
    (if (is-some endorsement)
      (let ((endorsement-data (unwrap-panic endorsement)))
        (if (or (get is-public endorsement-data)
                (is-eq endorsee tx-sender)
                (is-music-connected endorsee tx-sender))
          endorsement
          none))
      none)))

;; Helper functions
(define-read-only (is-music-connected (musician1 principal) (musician2 principal))
  (or (is-eq (get status (default-to { status: "none", initiated-by: musician1, timestamp: u0 } 
                          (map-get? music-connections { musician1: musician1, musician2: musician2 }))) "accepted")
      (is-eq (get status (default-to { status: "none", initiated-by: musician2, timestamp: u0 } 
                          (map-get? music-connections { musician1: musician2, musician2: musician1 }))) "accepted")))

(define-read-only (can-view-music-data (data-owner principal) (privacy-level uint))
  (or (is-eq privacy-level PRIVACY-PUBLIC)
      (is-eq data-owner tx-sender)
      (and (is-eq privacy-level PRIVACY-MUSIC-NETWORK) (is-music-connected data-owner tx-sender))))

;; Admin functions
(define-public (verify-musician-profile (musician principal))
  (let ((profile (map-get? musician-profiles musician)))
    (begin
      (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
      (asserts! (is-some profile) ERR-MUSICIAN-NOT-FOUND)
      (ok (map-set musician-profiles musician
        (merge (unwrap-panic profile) { is-verified: true }))))))

(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (ok (var-set contract-owner new-owner))))