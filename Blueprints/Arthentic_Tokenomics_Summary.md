# Arthentic Tokenomics (ATHN) Summary

Source document is *Kelompok 1 Arthentic Blockchain* (mainly Chapter V "Tokenomics dan Rencana Jangka Panjang", plus related parts in Chapter IV and Chapter VI).

---

## 1. Quick Overview

Arthentic is a *phygital* authentication protocol. It binds a physical artwork (for example a painting) to a smart contract on the blockchain using an NFC NTAG 424 DNA chip, an optical "Genesis Feature Vector", and an ERC-721 NFT.

The project introduces one token, **Arthentic Token (ATHN)**. Its guiding principle is simple. The core product (authenticity verification, escrow trading, provenance) must keep working **without** any token. The token only exists to bind the parties who can write to the protocol and to give them an incentive to be honest.

| Key point | Summary |
| --- | --- |
| Token type | Utility token (not a public investment product) |
| Total supply | 1,000,000,000 ATHN, fixed |
| Network | Base (ERC-20), with Base Sepolia as testnet |
| Main roles | Staking collateral, governance, fee discount, operator incentives |
| End users | Artists, collectors, buyers, and the public do **not** need to hold ATHN |
| Public sale | **Not offered** in the early phase |
| Status | Proposed academic design, all numbers are initial proposals |

---

## 2. Token Identity

| Attribute | Value |
| --- | --- |
| Token name | Arthentic Token |
| Symbol | ATHN |
| Standard and network | ERC-20 on Base (OpenZeppelin ERC20, ERC20Permit, ERC20Votes). Testnet on Base Sepolia |
| Decimals | 18 |
| Total supply | 1,000,000,000 ATHN, fixed (no mint function after the initial issuance) |
| Function | Utility token for institutional staking collateral, governance, protocol fee discount, and Node operator incentives |
| Contract managed by | Safe multisig and timelock, with admin rights released gradually to governance |

**Note on the symbol.** The symbols ARTH and ARTX are already used by other projects, so they were not chosen. A short search found no token using ATHN, but this does not replace an official check. Before issuance, the symbol must be rechecked on CoinGecko, CoinMarketCap, and BaseScan. The real identity of a token is its contract address on Base, so a similar symbol is not a technical barrier, only a risk of user confusion.

---

## 3. Why the Token Is Needed (and What It Does Not Do)

| Problem | Why a token helps | Alternative without a token |
| --- | --- | --- |
| Malicious Verifiers and Conservators (risk R5), since genesis data authenticity depends on their honesty | Slashable stake gives fraud a real cost | Only accreditation and reputation, which is weak if a gallery loses nothing |
| Single Protocol Node (risk R2) | k-of-n Node operators must stake and receive rewards | One trusted operator, which is a single point of failure |
| Funding user gas fees (Paymaster) | Part of protocol fees flows to a treasury that funds gas | Team subsidy, which is not sustainable |
| Parameter changes and upgrades | Token holders take part in decisions through governance | A single admin, which means centralization |

**What the token does not do.** End users (artists, collectors, buyers, the public) are not required to buy or hold ATHN to verify, buy, or sell artworks. This protects the experience for non-crypto users and avoids making the token look like an entry requirement.

---

## 4. Token Utility

1. **Role staking collateral.** Galleries (Verifier), Conservators, and Node operators lock ATHN to keep their role active. Proven fraud, decided by governance, can lead to slashing of part of the stake.
2. **Discounted protocol fees.** Fees are paid in stablecoin or ETH. Paying with ATHN earns a discount (proposed at 20%).
3. **Governance.** ATHN holders (ERC20Votes) propose and vote on changes to fees, accreditation requirements, Paymaster quotas, and contract upgrades through a timelock.
4. **Operator incentives.** Node operators and stakers receive rewards from a pool funded by part of the protocol fees and an emission reserve.

---

## 5. Distribution and Vesting

All figures below are **initial proposals** to be calibrated with legal advisors and partners. TGE means Token Generation Event.

| Group | Share | Amount (ATHN) | Schedule (proposed) | Reason |
| --- | --- | --- | --- | --- |
| Ecosystem and incentives | 30% | 300,000,000 | Linear over 48 months from TGE | Pilot grants, operator rewards, gallery programs |
| Staking and security reserve | 15% | 150,000,000 | Linear over 60 months | Long-term staker and Node operator rewards |
| Treasury / DAO | 15% | 150,000,000 | 12-month cliff, linear over 36 months | Protocol operations, audits, bug bounty |
| Founding team | 15% | 150,000,000 | 12-month cliff, linear over 36 months | Align the team with the long term |
| Strategic investors | 10% | 100,000,000 | 6-month cliff, linear over 24 months | Opened only after the pilot and legal review |
| Community (early artists and collectors) | 5% | 50,000,000 | Linear over 24 months | Reward for early users |
| Launch liquidity | 5% | 50,000,000 | Available at TGE, liquidity locked for 12 months | Fair market without domination by one party |
| Advisors and gallery partners | 5% | 50,000,000 | 6-month cliff, linear over 24 months | Access to galleries and conservators |
| **Total** | **100%** | **1,000,000,000** | | |

**Circulating supply estimate from this schedule**

| Time | Approx. circulating supply |
| --- | --- |
| At TGE | ~5% |
| Month 12 | ~22% |
| Month 24 | ~52% |
| Month 36 | ~77% |
| Month 60 | 100% |

The team and treasury (30% combined) only begin to unlock after 12 months, so early sell pressure is low.

---

## 6. Value Flow and Supply Control

- **Supply source.** Only the initial distribution of 1 billion ATHN. There is no mint function, so there is no hidden inflation.
- **Protocol fee split (proposed).**
  - 40% to the treasury for operations and gas sponsorship
  - 30% to the staker and Node operator reward pool
  - 30% for burn
- **How the burn works.** Burn comes from ATHN paid as fees, not from automatic market buybacks, so the design does not promise any price effect.
- **Supply reducers.** Burn and slashing. Slashed stake is partly burned and partly sent to the treasury.
- **Control.** Changes to fee ratios and staking parameters can only happen through governance with a timelock.

---

## 7. Staking and Slashing Parameters (Initial Proposal)

| Role | Minimum stake | Slashing trigger (examples) | Maximum slash |
| --- | --- | --- | --- |
| Gallery / Verifier | 50,000 ATHN | Registering fake artworks, proven fraud in genesisMint | 50% (may come with role revocation) |
| Conservator | 20,000 ATHN | Falsifying reports or restoration history | 50% |
| Node operator (k-of-n) | 200,000 ATHN | Signing a false attestation, repeated downtime | 100% for false signing, gradual for downtime |

Additional rules

- Stake amounts are a starting point for discussion and must be calibrated against the value of protected artworks and the token price at launch.
- **Unbonding period** is proposed at 14 days, so operators cannot exit right before a penalty is applied.
- Slashing goes through a dispute process, in this order, report, evidence from on-chain events, governance review, then execution.

---

## 8. Protocol Revenue Projection and Feasibility

**Assumptions**

- Average artwork price is $1,500 and 10% of artworks are resold per year.
- Genesis fee is $3 per artwork.
- Protocol resale fee is 0.5% of the price (the 5% artist royalty is unchanged).
- Paid deep verification for institutions happens 4 times per artwork per year at $0.05 each.
- Gallery SaaS subscription is $50 per month.
- Sponsored gas cost is $0.30 per new artwork and $0.02 per verification (6 verifications per artwork per year).

**Projection (USD)**

| Scenario | Artworks (cumulative) | Genesis fee | Resale fee | Verification | Gallery SaaS | Revenue | Gas cost | Net |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Conservative, year 1 | 25 | $75 | $9 | $3 | $1,200 | $1,287 | $9 | $1,278 |
| Conservative, year 2 | 150 | $375 | $66 | $18 | $3,000 | $3,458 | $48 | $3,410 |
| Conservative, year 3 | 600 | $1,350 | $281 | $75 | $6,000 | $7,706 | $180 | $7,526 |
| Base, year 1 | 25 | $75 | $9 | $3 | $1,200 | $1,287 | $9 | $1,278 |
| Base, year 2 | 500 | $1,425 | $197 | $53 | $6,000 | $7,674 | $174 | $7,500 |
| Base, year 3 | 3,000 | $7,500 | $1,313 | $350 | $18,000 | $27,163 | $960 | $26,203 |
| Optimistic, year 1 | 50 | $150 | $19 | $5 | $1,800 | $1,974 | $18 | $1,956 |
| Optimistic, year 2 | 1,500 | $4,350 | $581 | $155 | $12,000 | $17,086 | $528 | $16,558 |
| Optimistic, year 3 | 10,000 | $25,500 | $4,313 | $1,150 | $36,000 | $66,963 | $3,240 | $63,723 |

**Honest conclusion from the document**

- At pilot scale up to a few thousand artworks, protocol revenue is small (base scenario year 3 is about $27,163).
- Most revenue comes from gallery subscriptions, not per-transaction fees.
- Therefore, **token value must not be promised as coming from transaction volume** in the early phase.
- Sustainability should rest on (1) institutional subscriptions, (2) grants and pilot funding, and (3) small per-artwork fees.
- The token acts as a collateral and governance mechanism.

---

## 9. Long-Term Roadmap (Token and Protocol)

| Phase | Period | Content | Gate to continue |
| --- | --- | --- | --- |
| Phase 0 (Validation) | Nov 2026 to Oct 2027 | Protocol on testnet, then limited mainnet pilot. ATHN on testnet only for staking simulation. No public sale. | End-to-end demo, measured optical tests, legal review done, security review |
| Phase 1 (Limited utility token) | 2027 to 2028 | ATHN issued on mainnet only for staking by pilot galleries and conservators. Fees discounted with ATHN. | Legal statement on token status, a few active galleries at minimum, audit of token and staking contracts |
| Phase 2 (Decentralization) | 2028 to 2029 | k-of-n Node operators with stake, on-chain governance with timelock, admin rights released gradually. | More than one independent operator, tested dispute mechanism |
| Phase 3 (Expansion) | 2029 onward | ERC-1155 editions for edition-based works, art insurance and auction house integration, multi-chain study based on an exit plan. | Institutional partner demand, evaluation of cost and network security |

### Token-related items in the 12-month roadmap (Chapter VI)

| Quarter | Token, Legal, and Compliance milestone |
| --- | --- |
| Q1 (Nov 2026 to Jan 2027) | Legal consultation (OJK, UU PDP), token on testnet only |
| Q2 (Feb to Apr 2027) | Choose an e-KYC vendor, privacy policy |
| Q3 (May to Jul 2027) | Verifier staking on testnet, tokenomics simulation |
| Q4 (Aug to Oct 2027) | Decision on mainnet token (utility, no public sale) |

Related month 1 action items include finalizing the ATHN token spec and staking parameters, and drafting Tokenomics v1 with a question list for legal advisors (success indicator is approval by all members).

What is **deliberately not promised within 12 months** is public token sale, full Node decentralization, and multi-network support.

---

## 10. Tokenomics Risks and Mitigation

| Risk | Mitigation |
| --- | --- |
| Legal status of the token (crypto asset oversight by OJK) | Utility token, no public sale in early phase, legal consultation before Phase 1 |
| Speculation dominating function | Core product needs no token, long vesting, no promise of returns |
| Ownership concentration | Team cliff and vesting, voting weight cap per address, role stakes spread across many institutions |
| Thin liquidity and price manipulation | Initial liquidity locked for 12 months, no automatic buyback |
| Stake value too low to deter fraud on expensive artworks | Minimum stake calibrated to artwork value, high-value roles use insurance or extra stake |
| Sybil (many fake gallery accounts) | e-KYC/KYB and stake per institution (section 4.4) |
| Crypto regulation changes (roadmap risk) | Token on testnet only in year 1, legal consultation |

---

## 11. Legal and Compliance Context

- Crypto asset trading oversight in Indonesia moved from Bappebti to OJK on 10 January 2025 (POJK 27 Tahun 2024). This is why ATHN is designed as a utility token and is not offered to the public in the early phase.
- KYC data processing follows UU Nomor 27 Tahun 2022 on Personal Data Protection. On-chain data contains no personal data.
- **Disclaimer in the document.** This is an academic design for a university assignment. It is not an offer, an investment solicitation, or financial or legal advice. Real implementation requires legal counsel and licensed e-KYC providers.

---

## 12. Key Takeaways

1. ATHN is a **fixed-supply utility token** (1 billion) with no minting after launch.
2. It is **not required for end users**. It is for institutions (galleries, conservators, Node operators) who need skin in the game.
3. Value comes from **collateral, governance, and fee discounts**, not from promised price appreciation.
4. **Long vesting** (up to 60 months) and cliffs for team and treasury reduce early sell pressure.
5. Fee split of **40% treasury, 30% rewards, 30% burn**, with no automatic buyback.
6. Revenue is small at pilot scale and driven by **gallery SaaS**, so the token must not be sold as a revenue-sharing product.
7. Rollout is **gated**. Testnet first, limited utility token second, decentralization later, with legal review before each major step.
