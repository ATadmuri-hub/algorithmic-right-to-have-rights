# The Algorithmic Right to Have Rights

**Arendt, the EU AI Act, and the Limits of Bias-Mitigation in Multicultural Labour Markets**

Abdullah Tadmuri · Universidad Carlos III de Madrid · May 2026

Final paper for *Social and Ethical Issues of Big Data and AI*, MSc in Computational Social
Science (UC3M). Awarded Matrícula de Honor.

---

## Summary

The EU AI Act (Regulation 2024/1689) anchors fundamental-rights protection in a bias-mitigation
regime: data governance (Art. 10), human oversight (Art. 14), Fundamental Rights Impact Assessment
(Art. 27), and a right to explanation (Art. 86). This paper argues that the regime rests on a
universalist gesture, the reduction of fairness to group-statistical equality, and that the gesture
fails along two homologous axes.

**Internally**, the Chouldechova and Kleinberg-Mullainathan-Raghavan impossibility theorem proves
that no classifier can jointly satisfy independence, separation and sufficiency when subgroup base
rates differ. The choice among the three is political, not technical, and Article 10 cannot tell a
deployer which to satisfy.

**Externally**, Arendt's analysis of the "right to have rights" (1951) shows that the polity
producing those base rates has already excluded the populations whose protection the regime most
needs to demonstrate.

The two failures are not independent. They are two expressions of one operationalisation error.
Article 111's deferral of large-scale migration-AI enforcement to 31 December 2030 makes that
deferral textual.

The paper does not argue that the AI Act should be abandoned, nor that algorithmic governance is
inherently incompatible with justice. It argues that bias-mitigation, as currently operationalised,
cannot deliver what its rhetoric promises.

## Method

A convergent mixed-methods design:

- Textual analysis of Arendt (1951) and Regulation 2024/1689
- Synthesis of seven cross-national hiring-audit studies, 2004 to 2023, plus a 2024 LLM-side audit
- An empirical fairness-impossibility demonstration on the COMPAS dataset
- Three autoethnographic vignettes, licensed by Ellis et al. (2011) and following
  Costanza-Chock (2018), which triangulate the argument rather than anchor it

## Figures

| Figure | Script | What it shows |
|---|---|---|
| 1. Forest plot | `R_scripts/01_forest_plot.R` | Callback ratios from seven cross-national name-based hiring audit studies (2004 to 2023), majority over minority, log scale |
| 2. Language composition | `R_scripts/02_language_composition.R` | Language shares of two LLM-substrate corpora. Common Crawl 2026 is 41% English and 0.66% Arabic; the GPT-3 training corpus is 93% English |
| 3. Impossibility demonstration | `R_scripts/03_impossibility_demo.R` | Independence, separation and sufficiency parity ratios across 31 classification thresholds on COMPAS, against the 4/5ths-rule band |

## Reproducing

The R scripts are self-contained. Figure 3 uses the COMPAS data bundled with the `fairmodels`
package (originally released by ProPublica); Figures 1 and 2 use effect sizes and corpus statistics
transcribed from the cited primary sources, documented inline in each script. No external data
download is required.

```r
install.packages(c("fairmodels", "dplyr", "ggplot2", "tidyr",
                   "tibble", "scales", "patchwork"))

source("R_scripts/01_forest_plot.R")
source("R_scripts/02_language_composition.R")
source("R_scripts/03_impossibility_demo.R")
```

Figure 3 sets `set.seed(77)` and filters COMPAS to the African-American and Caucasian subgroups
(n = 5,278), fitting a single logistic regression of two-year recidivism on prior offences, age
band, misdemeanour status, sex and ethnicity, then sweeping thresholds from 0.20 to 0.80 in steps
of 0.02.

To rebuild the PDF (requires a TeX distribution with `latexmk`, `natbib` and `apalike`):

```bash
./compile.sh
```

## Sources

The bibliography holds 37 entries. Every citation was checked against its primary source in a
verification pass on 16 May 2026: no fabricated sources, all quotations verbatim, the
impossibility-theorem mathematics checked line by line, and the Arendt page numbers pinned to the
1973 Harcourt Brace Jovanovich edition (new edition with added prefaces) and triangulated against
independent scholarly citations of that same edition.

## Citation

```bibtex
@misc{tadmuri2026arendt,
  author = {Tadmuri, Abdullah},
  title  = {The Algorithmic Right to Have Rights: Arendt, the {EU} {AI} Act,
            and the Limits of Bias-Mitigation in Multicultural Labour Markets},
  year   = {2026},
  school = {Universidad Carlos III de Madrid},
  note   = {MSc in Computational Social Science, final paper},
  url    = {https://github.com/ATadmuri-hub/algorithmic-right-to-have-rights}
}
```

## License

The R scripts and build tooling are released under the MIT License (see `LICENSE`). The paper text
and figures are released under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/): reuse
freely with attribution. The UC3M logo is the property of Universidad Carlos III de Madrid and is
included only so the document compiles.
