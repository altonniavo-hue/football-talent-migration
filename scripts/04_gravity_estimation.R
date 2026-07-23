###############################################################
# 04 — GRAVITY ESTIMATION: Extensive (Probit) & Intensive (PPML)
# Thesis: Determinants of Football Talent Migration to the Big Five
# Data: Base_Memoire_PPML.csv (bilateral panel, 1995-2023)
###############################################################

# ── 0. PACKAGES ──────────────────────────────────────────────
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, fixest, countrycode, modelsummary)

# ── 1. LOAD DATA ─────────────────────────────────────────────
# Semicolon-separated file. Adapt the path if needed.
df <- read.csv2(
  "Base_Memoire_PPML.csv",
  stringsAsFactors = FALSE
) %>%
  mutate(across(c(gdp_origin, gdp_dest, dist, flux_transferts, exportations),
                ~ as.numeric(.)))

# ── 2. VARIABLES ─────────────────────────────────────────────
df <- df %>%
  mutate(
    ln_dist    = log(dist),
    ln_gdp_o   = log(gdp_origin),
    ln_gdp_d   = log(gdp_dest),
    ln_exp     = log1p(exportations),     # log(1+x) to keep zero-trade pairs
    transfer   = as.integer(flux_transferts > 0),  # extensive margin (0/1)
    continent  = countrycode(iso_origin, "iso3c", "continent")
  ) %>%
  # lag macro variables one period to limit reverse causality
  group_by(iso_origin, iso_dest) %>%
  arrange(year, .by_group = TRUE) %>%
  mutate(ln_gdp_o_l1 = lag(ln_gdp_o),
         ln_gdp_d_l1 = lag(ln_gdp_d)) %>%
  ungroup()

# ── 3. EXTENSIVE MARGIN — Probit ─────────────────────────────
# Pr(transfer > 0). Origin + destination fixed effects.
probit <- feglm(
  transfer ~ ln_dist + ln_gdp_o_l1 + ln_gdp_d_l1 +
             comlang_off + colony + ln_exp |
             iso_origin + iso_dest,
  data   = df,
  family = binomial(link = "probit")
)

# ── 4. INTENSIVE MARGIN — PPML ───────────────────────────────
# Volume of transfers. High-dimensional FE: origin + dest + year.
ppml <- fepois(
  flux_transferts ~ ln_dist + ln_gdp_o_l1 + ln_gdp_d_l1 +
                    comlang_off + colony + ln_exp |
                    iso_origin + iso_dest + year,
  data = df
)

# ── 5. ROBUSTNESS — Bilateral pair fixed effects ─────────────
# Absorbs all time-invariant bilateral characteristics (dist, lang, colony).
ppml_pair <- fepois(
  flux_transferts ~ ln_gdp_o_l1 + ln_gdp_d_l1 + ln_exp |
                    iso_origin^iso_dest + year,
  data = df
)

# ── 6. HETEROGENEITY — By continent of origin ────────────────
ppml_africa   <- fepois(flux_transferts ~ ln_dist + ln_gdp_o_l1 + ln_gdp_d_l1 +
                          comlang_off + colony + ln_exp | iso_origin + iso_dest + year,
                        data = filter(df, continent == "Africa"))
ppml_americas <- update(ppml_africa, data = filter(df, continent == "Americas"))
ppml_europe   <- update(ppml_africa, data = filter(df, continent == "Europe"))

# ── 7. NON-LINEAR GDP — Brain drain vs brain gain ────────────
# Inverted-U: positive linear + negative quadratic term on origin GDP.
ppml_quad <- fepois(
  flux_transferts ~ ln_gdp_o_l1 + I(ln_gdp_o_l1^2) + ln_dist +
                    ln_exp + comlang_off + colony |
                    iso_dest + year,
  data = df
)

# ── 8. OUTPUT ────────────────────────────────────────────────
# Baseline comparison
etable(probit, ppml, ppml_pair,
       headers = c("Probit (ext.)", "PPML (int.)", "PPML pair FE"),
       digits = 4)

# Continent split
etable(ppml_africa, ppml_americas, ppml_europe,
       headers = c("Africa", "Americas", "Europe"), digits = 4)

# Non-linear GDP
etable(ppml_quad, digits = 4)

# RESET test on the PPML specification (checks functional form)
fitstat(ppml, ~ ., cluster = ~ iso_origin)
