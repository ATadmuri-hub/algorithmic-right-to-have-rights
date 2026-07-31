# Addendum: the Digital Omnibus on AI (added 31 July 2026)

The paper was submitted on 22 May 2026 and analyses Regulation (EU) 2024/1689 as enacted. The
legal timeline has since been amended. This note records what changed, what it does to the
argument, and what it leaves untouched. The paper itself is left as submitted.

## What changed

The **Digital Omnibus on AI** amends the AI Act's application dates. EU institutions reached a
provisional political agreement on 6 May 2026; the European Parliament adopted the package on
16 June 2026 and the Council on 29 June 2026, with entry into force in July 2026.

| Obligation | Original date | Amended date |
|---|---|---|
| Stand-alone high-risk systems (Annex III) | 2 August 2026 | **2 December 2027** |
| High-risk AI embedded in regulated products (Annex I) | 2 August 2027 | **2 August 2028** |
| Transparency obligations (Art. 50) | 2 August 2026 | unchanged |
| Prohibitions, GPAI, AI literacy | already applicable | unchanged |
| **Large-scale IT systems for migration, asylum and borders (Annex X, Art. 111)** | 31 December 2030 | **unchanged** |

## What this does to Section 7

Section 7 reads Article 111's deferral of the Annex X border and migration systems as singular:
the rest of the bias-mitigation regime applying from 2 August 2026 while migration systems alone
receive four additional years. **That framing no longer holds.** Annex III standalone high-risk
systems, which include recruitment and candidate evaluation under point 4 and credit scoring
under point 5(b), have themselves been deferred to 2 December 2027.

The asymmetry survives but narrows. The gap between when the hiring rules bind and when the
border systems must comply falls from roughly four years and four months to roughly three years.
Migration and asylum infrastructure remains the last category in the regulation to be brought
into compliance, and it remains the only one whose deadline the Omnibus did not touch. The
claim the paper should now make is comparative rather than exclusive: migration systems are not
uniquely deferred, they are deferred longest, and they were not revisited when everything around
them was.

## What is untouched

The paper's two load-bearing arguments do not depend on the timeline.

- **The internal critique.** The Chouldechova and Kleinberg-Mullainathan-Raghavan impossibility
  result is a theorem. No amendment to an application date affects it. The COMPAS demonstration
  in `R_scripts/03_impossibility_demo.R` reproduces identically.
- **The external critique.** The audit-study record (Section 5), the LLM substrate finding
  (Figure 2), and the Arendtian polity-precondition argument (Section 2) are unaffected.
- **Article 10.** The representativeness requirement and the critique of it stand; deferring the
  date on which it binds does not change what it asks for or the mathematics of delivering it.

If anything, a deferral of the hiring rules by nineteen months is a further instance of the
pattern Section 7 names rather than a refutation of it. That is a claim the paper did not make
and could not have made, and it is offered here as an observation, not as a repair.

## Sources

- European Commission, AI Act Service Desk, implementation timeline:
  https://ai-act-service-desk.ec.europa.eu/en/ai-act/timeline/timeline-implementation-eu-ai-act
- Freshfields, *The final Digital Omnibus on AI: key amendments to the AI Act*
- Gibson Dunn, *EU AI Act Omnibus Agreement: postponed high-risk deadlines and other key changes*
- Article 111 and Annex X, Regulation (EU) 2024/1689
