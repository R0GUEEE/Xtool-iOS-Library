# Roadmap

## 0.1 — XKit bridge
- [x] SwiftPM library
- [x] iOS 17+ deployment target
- [x] XKit dependency
- [x] runtime capability model
- [x] build backend protocol

## 0.2 — Project model
- [x] Parse `xtool.yml`
- [x] Swift package workspace discovery
- [x] app metadata model compatible with Xtool schema v1
- [x] build log/event stream
- [ ] package target/product inspection
- [ ] editable project configuration writer

## 0.3 — Embedded SDK
- [x] SDK bundle format
- [x] SDK installer/importer
- [x] storage validation
- [x] version compatibility checks
- [x] SDK manifest with tool/component hashes
- [ ] archive importer for .zip/.tar payloads
- [ ] SDK selection policy
- [ ] disk-space preflight

## 0.4 — Native compiler backend
- [x] Swift compiler adapter
- [x] clang adapter
- [x] linker adapter
- [x] resource compiler integration
- [x] subprocess-free execution API for iOS
- [x] explicit compile/link build plans
- [x] embedded Swift/LLVM bridge API
- [ ] concrete native Swift frontend bridge implementation
- [ ] concrete native Clang/LLD bridge implementation

## 0.5 — Packaging/signing
- [x] app bundle assembly
- [x] entitlements
- [x] code signing through XKit-compatible primitives
- [x] IPA export
- [x] subprocess-free pure Swift ZIP writer
- [x] provisioning/profile generation through XKit DeveloperServices

## 1.0
- [ ] Build a minimal SwiftUI app entirely inside an iOS application
- [ ] Sign/export the resulting IPA
- [ ] documented host-app integration API
