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
- [ ] Swift compiler adapter
- [ ] clang adapter
- [ ] linker adapter
- [ ] resource compiler integration
- [ ] subprocess-free execution strategy for iOS

## 0.5 — Packaging/signing
- [ ] app bundle assembly
- [ ] entitlements
- [ ] code signing through XKit-compatible primitives
- [ ] IPA export

## 1.0
- [ ] Build a minimal SwiftUI app entirely inside an iOS application
- [ ] Sign/export the resulting IPA
- [ ] documented host-app integration API
