# =====================================================================
# 02_language_composition.R
# Figure 2: Language composition of two LLM-substrate corpora.
#
# Left panel:  Common Crawl 2026 (CC-MAIN-2026-17) — page-count basis
# Right panel: GPT-3 training corpus (Brown et al., 2020) — word-count basis
#
# IMPORTANT: All percentages below are verified directly from primary
# sources (web-fetched 2026-05-10):
#   - CC: https://commoncrawl.github.io/cc-crawl-statistics/plots/languages
#   - GPT-3: https://raw.githubusercontent.com/openai/gpt-3/master/dataset_statistics/languages_by_word_count.csv
#
# The two corpora are NOT directly comparable in unit (pages vs words),
# but they are both substrates of the LLM ecosystem; the figure shows
# share-of-substrate side by side, not a quantitative equivalence.
#
# Author: Abdullah Tadmuri (100502844)
# Last updated: 2026-05-10
# =====================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tibble)
  library(scales)
  library(patchwork)
})

# --- Data: Common Crawl CC-MAIN-2026-17 (verified) -------------------
cc_data <- tribble(
  ~language,    ~pct,
  "English",     41.02,
  "Russian",      6.53,
  "German",       5.90,
  "Japanese",     5.16,
  "Chinese",      4.86,
  "French",       4.76,
  "Spanish",      4.73,
  "Portuguese",   2.51,
  "Italian",      2.33,
  "Polish",       2.09,
  "Dutch",        1.84,
  "Turkish",      1.30,
  "Arabic",       0.66,
  "Other (~150)", 16.31  # residual after the 13 above
) %>% mutate(
  source = "Common Crawl 2026 (CC-MAIN-2026-17)",
  highlight = ifelse(language %in% c("English", "Arabic"), "highlight", "other")
)

# --- Data: GPT-3 (Brown et al. 2020 published dataset card) ---------
# Source: languages_by_word_count.csv in openai/gpt-3 repo, verified row-by-row
gpt3_data <- tribble(
  ~language,    ~pct,
  "English",    92.65,
  "Russian",     0.19,
  "German",      1.47,
  "Japanese",    0.11,
  "Chinese",     0.10,
  "French",      1.82,
  "Spanish",     0.77,
  "Portuguese",  0.52,
  "Italian",     0.61,
  "Polish",      0.16,
  "Dutch",       0.34,
  "Turkish",     0.06,
  "Arabic",      0.03,
  "Other",       1.17  # residual; includes Romanian, Finnish, Danish, Swedish, Norwegian etc.
) %>% mutate(
  source = "GPT-3 training corpus (Brown et al. 2020)",
  highlight = ifelse(language %in% c("English", "Arabic"), "highlight", "other")
)

# --- Consistent ordering across both panels --------------------------
lang_order <- c("English", "Russian", "German", "Japanese", "Chinese", "French",
                "Spanish", "Portuguese", "Italian", "Polish", "Dutch", "Turkish",
                "Arabic", "Other (~150)", "Other")

cc_data   <- cc_data   %>% mutate(language = factor(language, levels = rev(lang_order)))
gpt3_data <- gpt3_data %>% mutate(language = factor(language, levels = rev(lang_order)))

# --- Plot helper -----------------------------------------------------
# breaks: explicit tick positions so ggplot doesn't auto-extend past 100% on the GPT-3 panel.
make_panel <- function(d, title_text, x_max, x_breaks) {
  ggplot(d, aes(y = language, x = pct, fill = highlight)) +
    geom_col(width = 0.7) +
    geom_text(aes(label = sprintf("%.2f%%", pct)),
              hjust = -0.15, size = 2.7, colour = "grey30") +
    scale_fill_manual(values = c("highlight" = "#c0392b", "other" = "#7f8c8d"),
                      guide = "none") +
    scale_x_continuous(expand = expansion(mult = c(0, 0.20)),
                       limits = c(0, x_max),
                       breaks = x_breaks,
                       labels = function(x) paste0(x, "%")) +
    labs(title = title_text, x = NULL, y = NULL) +
    theme_minimal(base_size = 10) +
    theme(
      panel.grid.minor   = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.grid.major.x = element_line(colour = "grey92", linewidth = 0.3),
      axis.text.y        = element_text(size = 8),
      axis.text.x        = element_text(size = 8, colour = "grey40"),
      plot.title         = element_text(face = "bold", size = 10)
    )
}

p_cc   <- make_panel(cc_data,   "Common Crawl 2026 (CC-MAIN-2026-17)",
                     x_max = 50,
                     x_breaks = c(0, 10, 20, 30, 40, 50))
p_gpt3 <- make_panel(gpt3_data, "GPT-3 training corpus (Brown et al. 2020)",
                     x_max = 100,
                     x_breaks = c(0, 25, 50, 75, 100))

# --- Combine ---------------------------------------------------------
p2 <- (p_cc | p_gpt3) +
  plot_annotation(
    title    = "Language composition of two LLM-substrate corpora",
    subtitle = "Arabic share <1% in both. English-to-Arabic ratio: 62:1 in Common Crawl, 3,088:1 in GPT-3.\nComposition of GPT-4, Claude, and Llama 3 is not publicly disclosed.",
    caption  = paste0(
      "Sources: Common Crawl statistics, snapshot CC-MAIN-2026-17 (commoncrawl.github.io, page-count basis).\n",
      "GPT-3: languages_by_word_count.csv in openai/gpt-3 repo (Brown et al. 2020), word-count basis.\n",
      "The two corpora use different units (pages vs words) and different x-axis scales; panels are not\n",
      "visually comparable bar-for-bar. Long-tail languages aggregated into 'Other'. Highlight: English and Arabic.",
      ""
    ),
    theme = theme(
      plot.title    = element_text(face = "bold", size = 12),
      plot.subtitle = element_text(colour = "grey40", size = 9, margin = margin(b = 8)),
      plot.caption  = element_text(colour = "grey50", hjust = 0, size = 7,
                                   lineheight = 1.2, margin = margin(t = 8))
    )
  )

# --- Save ------------------------------------------------------------
out_pdf <- "../figures/fig2_language_composition.pdf"
out_png <- "../figures/fig2_language_composition.png"

pdf(out_pdf, width = 9.0, height = 5.5)
print(p2)
dev.off()
ggsave(out_png, p2, width = 9.0, height = 5.5, dpi = 300)

message("Figure 2 saved: ", out_pdf)
message("Figure 2 saved: ", out_png)
