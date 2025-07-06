# Harmoniq 🎵  
**The Decentralized Music Collaboration Hub**

Harmoniq is a smart contract-powered platform that connects musicians, enables secure composition sharing, supports band formations, and fosters musical endorsements — all within a privacy-respecting and verifiable network.

---

## 🚀 Features

- **Musician Profiles**:  
  Musicians can create public or private profiles with bios, instruments, and verification status.

- **Composition Sharing**:  
  Share musical compositions with flexible privacy controls (public, network-only, or private).

- **Band Formation Tracking**:  
  Record band participation with details like roles, join/leave dates, and descriptions.

- **Talent Endorsements**:  
  Public or private endorsements between musicians for specific talents.

- **Music Network Connections**:  
  Connect with fellow musicians through collaboration invites and accepted connections.

- **Verification & Privacy**:  
  Admin-verified profiles and data visibility determined by user-defined privacy levels.

---

## 🔐 Privacy Levels

- `PUBLIC (0)`: Viewable by everyone  
- `MUSIC-NETWORK (1)`: Only visible to verified music connections  
- `PRIVATE (2)`: Only visible to the owner

---

## 🛠️ Smart Contract Overview

Built on the Clarity smart contract language for Stacks blockchain, the core data structures include:

- `musician-profiles`
- `musical-compositions`
- `band-formations`
- `talent-endorsements`
- `music-connections`

### Key Public Functions

| Function | Purpose |
|---------|---------|
| `create-musician-profile` | Register a new musician profile |
| `add-musical-composition` | Add a new composition |
| `add-band-formation` | Record band participation |
| `endorse-musical-talent` | Endorse another musician's talent |
| `send-music-collaboration-invite` | Initiate a connection |
| `accept-music-collaboration-invite` | Accept an invitation |
| `verify-musician-profile` | Admin-only profile verification |
| `verify-musical-composition` | Admin-only composition verification |

---

## 🧩 Read-only Queries

| Function | Returns |
|---------|---------|
| `get-musician-profile` | Musician profile based on privacy |
| `get-musical-composition` | Composition details |
| `get-band-formation` | Band involvement info |
| `get-talent-endorsement` | Endorsement metadata |
| `is-music-connected` | True if two musicians are connected |
| `can-view-music-data` | Check access to protected data |

---

## 🧑‍💻 Deployment & Admin Controls

- **Initial Ownership**: Deployer of the contract is the default `contract-owner`
- **Admin Actions**: Only the owner can verify musicians or transfer contract ownership


## 🎧 Join the Movement

Create. Collaborate. Harmonize.  
**Harmoniq** — Empowering musicians, one block at a time.
