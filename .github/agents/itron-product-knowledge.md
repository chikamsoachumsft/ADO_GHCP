# Itron Product & Documentation Reference

> **This file is a compact knowledge map for Copilot agents.** It lists Itron's product taxonomy, key technical terms, and documentation URLs. Agents should use this to orient themselves, then fetch specific doc pages when they need deeper technical detail.

## Documentation Portal

- **Main portal**: https://docs.itrontotal.com/Content/LandingPageHome.html
- **Field Tools Help**: https://docs.itrontotal.com/FieldTools/Content/Topics/Welcome.htm
- **Product Catalog**: https://na.itron.com/solutions/product-catalog

### Documentation Areas (docs.itrontotal.com)

| Area | What It Covers |
|------|---------------|
| Common APIs | Shared API interfaces across Itron products |
| Data Products | Data collection, aggregation, analytics pipelines |
| Distributed Intelligence (DI) Applications | Edge computing apps running on endpoints |
| Distributed Intelligence (DI) for Administrators | Admin tools for DI management |
| Distributed Intelligence (DI) for Developers | DI SDK, app development, deployment |
| Field Deployment Manager (FDM) | Large-scale endpoint deployment orchestration |
| Field Tools | Mobile/desktop tools for endpoint configuration, programming, diagnostics |
| Gas Distribution Safety | Gas leak detection, pressure monitoring, safety systems |
| High Performance Ping | Network reachability and endpoint health checking |
| IntelliFLEX Software | Legacy AMR/AMI management platform |
| Itron Analytics Platform | Cloud analytics, dashboards, reporting |
| Itron Enterprise Edition (IEE) MDM | Meter Data Management — data collection, validation, estimation |
| Itron Intelligent Edge OS (IEOS) | Operating system running on Gen5/GenX edge devices |
| Market Transaction Suite (MTS) | Energy market settlement, billing, scheduling |
| MetrixIDR Software | Revenue assurance, energy theft detection |
| Operations Optimizer | Workforce management, outage management, grid operations |
| Temetra Analysis | Load research, rate analysis, demand forecasting |
| Water Meters & Telemetry Modules | Water metering hardware and communication modules |

## Product Taxonomy

### Measurement & Sensing

**Electricity Meters & Modules**
- OpenWay CENTRON — residential poly-phase electricity meters (mesh & cellular variants)
- OpenWay CENTRON Cellular LTE-M — cellular direct-connect electricity meter
- Solar Meter — net metering / solar production measurement
- GenX Cellular 500S — next-gen cellular electricity endpoint
- Gen 5 Cellular endpoints — current-gen cellular electricity endpoints

**Gas Meters & Modules**
- 2.4GZ OpenWay Gas Module — RF mesh gas communication module
- Gas IMU 500T — gas interval metering unit
- Gas IMU Configurator — programming tool for gas IMUs
- GenX Cellular 500G — next-gen cellular gas endpoint
- Gen 5 Cellular 500G — current-gen cellular gas endpoint

**Water Meters & Modules**
- Water telemetry modules — communication add-ons for water meters
- GenX Cellular 500W — next-gen cellular water endpoint
- Gen 5 Cellular 500W — current-gen cellular water endpoint

**Sensing & Control**
- Load Control Configurator (LCC) — demand response device programming
- Outage Detection System (ODS) — real-time outage monitoring

### Networks & Operations

**Network Infrastructure & Management**
- Edge Gateway — field area network gateway/router
- OpenWay Mesh Range Extender — extends RF mesh coverage
- Network Center — network monitoring and management
- Antennas — network infrastructure antennas
- GridScape Network Manager — grid network management platform
- Gridscape Configuration Server — network device configuration

**Grid Management**
- Grid Edge Essentials — grid analytics and management
- Critical Operations Protector (COP) for AMI — grid security/reliability
- Critical Operations Protector for DR — demand response protection

**Operations Management**
- Operations Optimizer — workforce & outage management
- Field Deployment Manager (FDM) — large-scale deployment orchestration

**Mobile Meter Reading**
- Field Service Unit (FSU) — handheld/mobile meter reading device

### Software & Services

**Field Tools Suite** (most relevant to agent work)
- Field Tools — endpoint programming, configuration, diagnostics
- Bridge Configurator — network bridge setup
- Communications Module Utility (CMU) — module diagnostics
- Meter Program Configurator (MPC) — meter programming profiles
- Gas IMU Configurator — gas module programming

**Data Management**
- IEE Meter Data Management — head-end data collection & validation
- MV-90 xi — large C&I meter data collection
- MVLT xi — load profile translation
- MV-PBS — meter data processing
- MV-WEB — web-based meter data access
- OpenWay Reporting System — AMI data reporting
- Mlogonline — meter log management

**Analytics & Intelligence**
- Itron Analytics Platform — cloud dashboards and reporting
- Temetra Analysis — load research & rate analysis
- MetrixIDR — revenue protection & theft detection
- Distributed Intelligence (DI) — edge computing on endpoints

**Security**
- KeySafe — cryptographic key management for AMI networks
- Cisco Connected Grid Device Manager — grid device security management

**Market Operations**
- Market Transaction Suite (MTS) — energy market settlement

## Key Technical Terms (Glossary)

| Term | Meaning |
|------|---------|
| AMI | Advanced Metering Infrastructure — two-way communication network |
| AMR | Automatic Meter Reading — one-way drive-by/walk-by reading |
| CAT-M1 (LTE-M) | Low-power cellular IoT protocol for meters |
| CI (Configuration Item) | An engineering team/component in Itron's org structure |
| DI | Distributed Intelligence — edge computing on endpoints |
| Endpoint | A smart meter or communication module in the field |
| FOTA | Firmware Over The Air — remote firmware updates |
| FDM | Field Deployment Manager — mass deployment orchestration |
| FSU | Field Service Unit — handheld meter reading device |
| GenX | Next-generation product family (500S, 500G, 500W) |
| Gen 5 | Current-generation product family |
| IEOS | Itron Intelligent Edge Operating System |
| IEE | Itron Enterprise Edition — head-end/MDM platform |
| IMEI | International Mobile Equipment Identity — cellular device ID |
| MDM | Meter Data Management |
| MRS | Marketing Requirement Specification |
| ODS | Outage Detection System |
| OpenWay | Itron's AMI platform brand name |
| PCOMP | Programmable component (firmware module on endpoint) |
| PI | Program Increment — Itron's agile planning cadence |
| PTCRB | Cellular device certification body |
| TAC | Type Allocation Code — first 8 digits of IMEI |
| Tunnelat | CLI UART pass-through command for modem AT commands |

## Carrier & Network Quick Reference

| Carrier | Technology | Key Bands |
|---------|-----------|-----------|
| AT&T | CAT-M1 (LTE-M) | Band 2 (1900 MHz), Band 4 (AWS), Band 12 (700 MHz) |
| Verizon | CAT-M1 (LTE-M) | Band 4 (AWS), Band 13 (700 MHz) |
| T-Mobile | CAT-M1 (LTE-M) | Band 2, Band 4, Band 71 (600 MHz) |
| Rogers | LTE | Various Canadian LTE bands |

## How Agents Should Use This

1. **Orienting**: Use the product taxonomy above to understand what product family or tool the user is talking about.
2. **Quick answers**: Use the glossary and carrier reference for terminology and specs.
3. **Deep dives**: When you need specific technical details not covered here (e.g., exact AT commands, Field Tools UI screens, API specs, IEOS configuration), ask the user to provide the relevant section. The docs site (`docs.itrontotal.com`) uses JavaScript rendering and cannot be fetched at runtime.
4. **Product catalog**: For product specs, the user can check `na.itron.com/products/[product-slug]`.
5. **Reference files**: If the team adds markdown files to `.github/agents/itron-reference/`, check those for pre-extracted documentation on specific topics.
