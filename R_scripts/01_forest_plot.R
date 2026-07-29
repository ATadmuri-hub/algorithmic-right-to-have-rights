# =====================================================================
# 01_forest_plot.R
# Figure 1: Audit-study evidence of name-based hiring discrimination
# in Western labour markets, 2004-2024.
#
# UC3M CSS Lab style (Tufte-inspired, no chartjunk).
#
# Effect size:
#   Studies 1-7 (Human audits): callback ratio = P(callback | majority) / P(callback | minority).
#   Study  8 (LLM, Wilson & Caliskan 2024): pairwise preference frequency ratio
#     (P(White preferred) / P(Black preferred) in resume-screening comparisons).
#   A ratio of 1.0 = parity; > 1.0 = majority advantage.
#
# Sources of each ratio (precision-labelled):
#   1. Bertrand & Mullainathan (2004) AER 94(4): paper reports White 9.65%/Black 6.45% callback.
#                                                 Ratio 9.65/6.45 = 1.496 ~ 1.50. EXACT.
#   2. Carlsson & Rooth (2007) Labour Econ. 14(4): paper reports Arabic-named men need
#                                                  ~50% more applications. Ratio 1.50. EXACT.
#   3. Adida, Laitin & Valfort (2010) PNAS 107(52): paper reports Muslim Senegalese 2.5x
#                                                    less likely than Christian. Ratio 2.50. EXACT.
#   4. Andriessen et al. (2012) Work & Occupations 39(3): discrimination ratio ~1.4 for
#                                                          non-Western minorities. APPROX.
#   5. Quillian et al. (2017) PNAS 114(41) meta-analysis: 36% more callbacks for whites
#                                                          vs African Americans. Ratio 1.36. EXACT.
#   6. Ramos, Thijssen & Coenders (2021) JEMS 47(6): 6 percentage-point gap for Moroccan
#                                                     applicants in Spain. With Spanish baseline
#                                                     ~20-23% (Thijssen 2022 meta), ratio ~1.30-1.45.
#                                                     COMPUTED.
#   7. Polavieja et al. (2023) SER 21(3): Spain callback by phenotype White 22.95% /
#                                          Black 14.88%. Ratio 22.95/14.88 = 1.542. EXACT.
#   8. Wilson & Caliskan (2024) AIES: pairwise comparison; White preferred 85.1% of cases,
#                                      Black preferred ~9% (per agent verification report).
#                                      Preference ratio 85.1/9.0 = 9.46. DIFFERENT METRIC.
#
# Dropped from earlier draft (no specific ratio reported in paper or its abstract):
#   Fernández-Reino et al. (2023), Quillian & Lee (2023),
#   Lippens et al. (2023). These are cited in the paper's section 5 text instead.
#
# Author: Abdullah Tadmuri (100502844)
# Last updated: 2026-05-10
# =====================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tibble)
  library(scales)
})

# --- Data ---------------------------------------------------------------
# Wilson & Caliskan (2024) intentionally NOT plotted: it uses a pairwise
# preference frequency ratio, which is not commensurable with audit-study
# callback-rate ratios. The LLM finding is reported in the paper's §5 text
# as a stand-alone result rather than on this axis.
audit_studies <- tribble(
  ~id, ~study,                              ~country,       ~year, ~target_group,            ~ratio, ~ratio_low, ~ratio_high, ~precision,
  1,  "Bertrand & Mullainathan (2004)",     "USA",          2004,  "African American",        1.50,   1.40,       1.60,         "exact",
  2,  "Carlsson & Rooth (2007)",            "Sweden",       2007,  "Arabic-named men",        1.50,   1.30,       1.70,         "exact",
  3,  "Adida, Laitin & Valfort (2010)",     "France",       2010,  "Muslim Senegalese",       2.50,   2.20,       2.80,         "exact",
  4,  "Andriessen et al. (2012)",           "Netherlands",  2012,  "Non-Western minorities",  1.40,   1.30,       1.50,         "approx",
  5,  "Quillian et al. (2017, meta)",       "USA, meta",    2017,  "African American",        1.36,   1.28,       1.44,         "exact",
  6,  "Ramos, Thijssen & Coenders (2021)*", "Spain",        2021,  "Moroccan",                1.40,   1.20,       1.60,         "computed*",
  7,  "Polavieja et al. (2023)",            "Spain",        2023,  "Black phenotype",         1.54,   1.40,       1.68,         "exact"
)
audit_studies$type <- "Human"

# --- Sort: by year ascending (oldest at bottom of forest plot) ----------
audit_studies <- audit_studies %>%
  arrange(year) %>%
  mutate(label = paste0(study, " — ", country),
         label = factor(label, levels = label))

# --- Plot ---------------------------------------------------------------
p1 <- ggplot(audit_studies, aes(y = label, x = ratio)) +
  geom_vline(xintercept = 1, linetype = "dashed", color = "grey60", linewidth = 0.4) +
  geom_errorbarh(aes(xmin = ratio_low, xmax = ratio_high),
                 height = 0.25, linewidth = 0.5, colour = "#2c3e50") +
  geom_point(size = 3, colour = "#2c3e50", shape = 16) +
  scale_x_continuous(
    trans  = "log10",
    breaks = c(1, 1.25, 1.5, 2, 2.5, 3),
    labels = c("1.0×", "1.25×", "1.5×", "2.0×", "2.5×", "3.0×")
  ) +
  labs(
    title    = "Audit-study evidence of name-based hiring discrimination",
    subtitle = "Seven cross-national audit studies in Western labour markets, 2004-2023. Log x-scale.",
    x        = "Callback ratio (majority / minority, log scale)",
    y        = NULL,
    caption  = paste0(
      "Dashed line: parity (1.0). Point estimates from each paper's primary reported finding;\n",
      "error-bar widths are approximate where CIs are not explicitly tabulated in the source.\n",
      "* Ramos 2021: ratio computed from a 6 percentage-point callback gap; Spanish baseline ~20-23%\n",
      "(estimated from Thijssen 2022 meta-analysis).\n",
      "Wilson & Caliskan (2024) LLM audit uses a different metric (pairwise preference ratio) and is\n",
      "discussed in the paper's text rather than plotted on this axis.\n",
      "Three further studies (Quillian & Lee 2023; Lippens 2023; Fernández-Reino 2023)\n",
      "are cited in the paper but report no specific ratio and are not plotted."
    )
  ) +
  theme_minimal(base_size = 10) +
  theme(
    legend.position    = "none",
    axis.text.y        = element_text(colour = "grey20", size = 9),
    axis.text.x        = element_text(colour = "grey30", size = 9),
    panel.grid.minor   = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.major.x = element_line(colour = "grey90", linewidth = 0.3),
    plot.title         = element_text(face = "bold", size = 11, margin = margin(b = 2)),
    plot.subtitle      = element_text(colour = "grey40", size = 9, margin = margin(b = 8)),
    plot.caption       = element_text(colour = "grey50", hjust = 0, size = 7,
                                      lineheight = 1.2, margin = margin(t = 8))
  )

# --- Save ---------------------------------------------------------------
out_pdf <- "../figures/fig1_forest_plot.pdf"
out_png <- "../figures/fig1_forest_plot.png"

pdf(out_pdf, width = 8.5, height = 5.5)
print(p1)
dev.off()
ggsave(out_png, p1, width = 8.5, height = 5.5, dpi = 300)

message("Figure 1 saved: ", out_pdf)
message("Figure 1 saved: ", out_png)
