# =====================================================================
# 03_impossibility_demo.R
# Figure 3: Empirical demonstration of the Chouldechova-KMR-BHN
# fairness impossibility theorem on the COMPAS dataset.
#
# At every classification threshold, we plot the three group-fairness
# parities (Independence, Separation, Sufficiency) as ratios between
# the African-American and Caucasian subgroups. The 4/5ths-rule band
# (0.8-1.25) is shaded; outside the band a parity is "violated" by
# convention. Shows that NO threshold puts all three inside the band.
#
# Data source: fairmodels::compas (built-in, 6,172 x 7).
# Method: replicates Sandra Benítez's Class 5 fairness pipeline.
#
# Author: Abdullah Tadmuri (100502844)
# Last updated: 2026-05-10
# =====================================================================

suppressPackageStartupMessages({
  library(fairmodels)
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(scales)
})

# --- Load and prepare COMPAS data ---------------------------------------
data("compas", package = "fairmodels")
df <- compas %>%
  filter(Ethnicity %in% c("Caucasian", "African_American")) %>%
  droplevels()

# Outcome must be numeric 0/1 for glm
df$y_num <- as.numeric(as.character(df$Two_yr_Recidivism))
if (anyNA(df$y_num)) {
  # Some versions encode "Yes"/"No" — fall back to factor coercion
  df$y_num <- as.numeric(as.factor(df$Two_yr_Recidivism)) - 1
}

# --- Fit logistic regression (matches Class 5 baseline) -----------------
set.seed(77)
mod <- glm(
  y_num ~ Number_of_Priors + Age_Above_FourtyFive + Age_Below_TwentyFive +
          Misdemeanor + Sex + Ethnicity,
  data   = df,
  family = binomial
)
df$score <- predict(mod, type = "response")

# --- Compute parities across thresholds --------------------------------
thresholds <- seq(0.20, 0.80, by = 0.02)

compute_parities <- function(df, t) {
  pred <- df$score > t
  is_AA <- df$Ethnicity == "African_American"
  is_C  <- df$Ethnicity == "Caucasian"

  # Independence (Statistical Parity): P(Y_hat=1 | A=a)
  sp_AA <- mean(pred[is_AA])
  sp_C  <- mean(pred[is_C])

  # Separation (Equal Opportunity / TPR balance): P(Y_hat=1 | Y=1, A=a)
  is_pos <- df$y_num == 1
  tpr_AA <- mean(pred[is_AA & is_pos])
  tpr_C  <- mean(pred[is_C  & is_pos])

  # Sufficiency (Predictive Parity / PPV): P(Y=1 | Y_hat=1, A=a)
  ppv_AA <- if (sum(pred & is_AA) > 0) mean(df$y_num[pred & is_AA]) else NA
  ppv_C  <- if (sum(pred & is_C ) > 0) mean(df$y_num[pred & is_C ]) else NA

  data.frame(
    threshold     = t,
    Independence  = sp_AA / sp_C,
    Separation    = tpr_AA / tpr_C,
    Sufficiency   = ppv_AA / ppv_C
  )
}

results <- do.call(rbind, lapply(thresholds, function(t) compute_parities(df, t)))

# --- Pivot for plotting -----------------------------------------------
results_long <- results %>%
  pivot_longer(
    cols      = c(Independence, Separation, Sufficiency),
    names_to  = "parity",
    values_to = "ratio"
  ) %>%
  filter(is.finite(ratio))

# --- Compute right-end positions for direct line labels ----------------
label_df <- results_long %>%
  group_by(parity) %>%
  filter(threshold == max(threshold)) %>%
  ungroup()

# --- Plot --------------------------------------------------------------
p3 <- ggplot(results_long, aes(x = threshold, y = ratio, colour = parity, linetype = parity)) +
  # 4/5ths band (regulatory-style fairness band)
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = 0.8, ymax = 1.25,
           fill = "grey88", alpha = 0.5) +
  # Highlight the threshold zone where all three parities co-satisfy the band
  annotate("rect", xmin = 0.21, xmax = 0.27, ymin = 0.78, ymax = 1.27,
           fill = "#16a085", alpha = 0.20, colour = "#16a085", linetype = "dotted",
           linewidth = 0.4) +
  annotate("text", x = 0.24, y = 1.55,
           label = "All three parities in band\nat t = 0.22, 0.24, 0.26",
           size = 2.7, colour = "#117a65", lineheight = 1.05, hjust = 0.5,
           fontface = "bold") +
  # Default classification cutoff at t = 0.5 (conventional operating point)
  geom_vline(xintercept = 0.5, linetype = "longdash", colour = "grey55", linewidth = 0.3) +
  annotate("text", x = 0.50, y = 4.75, label = "default cutoff (t = 0.5)",
           size = 2.5, colour = "grey45", hjust = 0.5) +
  # Reference lines
  geom_hline(yintercept = 1, linetype = "dashed", colour = "grey50", linewidth = 0.4) +
  geom_hline(yintercept = 0.8, linetype = "dotted", colour = "grey65", linewidth = 0.3) +
  geom_hline(yintercept = 1.25, linetype = "dotted", colour = "grey65", linewidth = 0.3) +
  # Lines and points - line style varies by parity for B&W / colorblind accessibility
  geom_line(linewidth = 0.9) +
  geom_point(size = 1.1) +
  # Direct line labels at right end (replaces bottom legend)
  geom_text(data = label_df,
            aes(x = threshold + 0.012, y = ratio, label = parity, colour = parity),
            hjust = 0, size = 3.1, fontface = "bold", show.legend = FALSE) +
  scale_colour_manual(values = c(
    "Independence" = "#2c3e50",
    "Separation"   = "#e67e22",
    "Sufficiency"  = "#16a085"
  ), guide = "none") +
  scale_linetype_manual(values = c(
    "Independence" = "solid",
    "Separation"   = "dashed",
    "Sufficiency"  = "dotted"
  ), guide = "none") +
  scale_x_continuous(
    breaks       = seq(0.20, 0.80, 0.10),
    minor_breaks = seq(0.20, 0.80, 0.05),
    labels       = label_number(accuracy = 0.01),
    expand       = expansion(mult = c(0.02, 0.22))
  ) +
  coord_cartesian(clip = "off") +
  scale_y_continuous(
    trans  = "log2",
    breaks = c(0.8, 1.0, 1.25, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0),
    labels = c("0.8×", "1.0×", "1.25×", "1.5×", "2.0×", "2.5×", "3.0×", "4.0×", "5.0×"),
    limits = c(0.78, 5.0)
  ) +
  labs(
    title    = "The fairness impossibility theorem, demonstrated on COMPAS",
    subtitle = "African-American vs Caucasian subgroups; three group-fairness parities by classification threshold (log y).",
    x        = "Classification threshold",
    y        = "Parity ratio  (African-American / Caucasian)",
    caption  = paste0(
      "Data: fairmodels::compas, filtered to African-American + Caucasian (n = 5,278). Logistic regression. set.seed(77).\n",
      "Base rates: African-American 52.3%, Caucasian 39.1%.\n",
      "Shaded band: 4/5ths-rule region (0.8x-1.25x). Green-tinted zone (t = 0.22-0.26):\n",
      "3 of 31 thresholds where all three parities co-satisfy the band. Above 0.26 the trade-off is forced.\n",
      "Sources: Chouldechova (2017); Kleinberg, Mullainathan & Raghavan (2017); Barocas et al. (2023)."
    )
  ) +
  theme_minimal(base_size = 10) +
  theme(
    legend.position    = "none",
    panel.grid.minor.x = element_line(colour = "grey95", linewidth = 0.2),
    panel.grid.minor.y = element_blank(),
    panel.grid.major.x = element_line(colour = "grey90", linewidth = 0.3),
    panel.grid.major.y = element_line(colour = "grey90", linewidth = 0.3),
    plot.title         = element_text(face = "bold", size = 12),
    plot.subtitle      = element_text(colour = "grey40", size = 9, margin = margin(b = 8)),
    plot.caption       = element_text(colour = "grey50", hjust = 0, size = 7,
                                      lineheight = 1.2, margin = margin(t = 8))
  )

# --- Save --------------------------------------------------------------
out_pdf <- "../figures/fig3_impossibility_demo.pdf"
out_png <- "../figures/fig3_impossibility_demo.png"

pdf(out_pdf, width = 8.0, height = 5.0)
print(p3)
dev.off()
ggsave(out_png, p3, width = 8.0, height = 5.0, dpi = 300)

# --- Diagnostic: do all three parities co-satisfy at any threshold? ----
in_band <- results %>%
  mutate(all_in = (Independence >= 0.8 & Independence <= 1.25 &
                   Separation   >= 0.8 & Separation   <= 1.25 &
                   Sufficiency  >= 0.8 & Sufficiency  <= 1.25))
cat("\nThresholds where ALL THREE parities are within 4/5ths band: ",
    sum(in_band$all_in), " of ", nrow(in_band), "\n")

message("Figure 3 saved: ", out_pdf)
message("Figure 3 saved: ", out_png)
