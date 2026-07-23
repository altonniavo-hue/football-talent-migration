# ⚽ Determinants of International Football Talent Migration to the European "Big Five"

> A two-step bilateral gravity analysis of player transfers from emerging economies to England, Spain, Germany, Italy and France (1995–2023)

![R](https://img.shields.io/badge/R-276DC3?style=flat&logo=r&logoColor=white)
![Package](https://img.shields.io/badge/fixest-Probit%20%7C%20PPML-2E7D32)
![Obs](https://img.shields.io/badge/Panel-11%2C795%20obs-orange)
![Status](https://img.shields.io/badge/Status-Completed-success)

---

## 📌 Context
Professional football is one of the most globalized high-skill labor markets in the world. Over 1995–2023, close to **80,000 international player transfers** were recorded between emerging economies and the European "Big Five" leagues. For many developing countries, these flows are one of the most significant forms of high-value-added service exports (Mode 4 under GATS). Yet they are almost never captured in official trade statistics, and rarely studied with modern trade-migration econometrics.

## ❓ Research Question
**Beyond athletic merit, which economic, geographic and cultural factors structure the persistent migration of football talent from emerging nations to the Big Five, and what drives the durability of these bilateral transfer corridors?**

## 🗂️ Data
An **original bilateral panel** built as a full Cartesian product of origin countries × five destination leagues × years, so that country-pairs with no transfer are kept as explicit zero flows (crucial for PPML).

| | |
|---|---|
| **Coverage** | 1995–2023 |
| **Observations** | 11,795 origin–destination–year |
| **Structural feature** | 56.5% of corridors are strict zeros |
| **Transfers** | CIES Football Observatory, Transfermarkt |
| **Gravity variables** | CEPII GeoDist (distance, language, colonial ties), CEPII Gravity (bilateral exports) |
| **Macro controls** | World Bank WDI (GDP per capita, lagged one period) |

Concentration is extreme: a Lorenz curve shows that **12.7% of corridors account for 80% of all transfers**, and revenue concentration across leagues stays well above the HHI 0.25 high-concentration threshold.

*Raw transfer data are not redistributed here. See [`/data/README.md`](data/README.md) for sources and reconstruction steps.*

## 🛠️ Methodology
The high share of zeros calls for a **two-step gravity strategy** that separates *whether* a corridor forms from *how many* players flow once it exists.

| Margin | Question | Estimator |
|--------|----------|-----------|
| **Extensive** | Probability a corridor emerges | **Probit** (origin & destination FE) |
| **Intensive** | Volume of players once active | **PPML** (Poisson PML, high-dimensional FE) |

Specification and robustness:
- **RESET test** confirms PPML is correctly specified (p = 0.112) and rejects log-linear OLS (p = 0.000), consistent with Santos Silva & Tenreyro (2006).
- **Pair fixed effects** absorbing all time-invariant bilateral characteristics.
- **Lagged specifications** to address reverse causality and test temporal ordering.
- **Continent-split** estimation (Africa, Americas, Europe) to test parameter heterogeneity.
- **Quadratic GDP** to test the brain-drain / brain-gain non-linearity.

**Stack:** R, `fixest` (`feglm` for Probit, `fepois` for PPML, high-dimensional FE via alternating projections).

## 📈 Key Results

**1. Distance still bites, even in a digital scouting era.**
Elasticities range from **−0.24 to −1.02**; in the preferred PPML specification a 1% rise in distance cuts transfer volume by ~1.02% (near-unit elasticity).

**2. A novel sign reversal in trade integration (the central contribution).**
Stronger bilateral trade *raises the probability* a corridor forms (extensive margin, **+0.049\*\*\***) but *lowers the volume* once it is active (intensive margin, **−0.173\*\*\***). Robust to pair fixed effects and lagged tests, pointing to a long-run **substitution between goods trade and talent exports**.

**3. Historical networks dominate.**
Holding all else equal, a **common language raises expected player flows by ~97.6%** (exp(0.6811)−1) and a **colonial tie by ~47.9%**. For **African** origins, distance becomes statistically insignificant and colonial ties are the primary driver (+0.770\*\*), while the **Americas** show a large distance penalty (−6.36) offset by a strong language premium.

**4. Brain drain is not permanent.**
An inverted-U in origin GDP (linear +0.457\*\*\*, quadratic −0.032\*\*\*) shows talent exports rising with early development, then falling once domestic leagues grow rich enough to retain elite players.

Model fit: **Pseudo-R² = 0.829** in the preferred PPML specification.

<p align="center">
  <img src="outputs/players_exported_by_country.png" width="80%" alt="Players exported to the Big Five by country of origin">
  <br><em>Figure 1 — Emerging and semi-peripheral suppliers of talent to the Big Five (2023/24).</em>
</p>

<p align="center">
  <img src="outputs/lorenz_curve.png" width="60%" alt="Lorenz curve of transfer concentration">
  <br><em>Figure 2 — 12.7% of corridors account for 80% of all transfers.</em>
</p>

## 🧭 What this project demonstrates
- Building and cleaning a large original bilateral panel (11,795 obs) from four different sources
- Applying advanced gravity estimators (Probit, PPML) with high-dimensional fixed effects, not just OLS
- Rigorous validation: RESET test, pair FE, lagged causality, heterogeneity splits
- Translating econometric coefficients into economically meaningful, policy-relevant conclusions

## 📂 Repository structure
```
├── scripts/        # R scripts: data prep, Probit, PPML, robustness, plots
├── outputs/        # figures & result tables
├── data/           # data documentation (sources, reconstruction)
└── docs/           # abstract & summary
```

## 👥 Authors
Master's thesis, M1 International and Environmental Economics, Université Paris 1 Panthéon-Sorbonne (2025–2026), supervised by Alejandro Arciniegas Herrera.

Co-authored by **Alton Niavo**, Lamine Maspimby and Astou Sy.

**Alton Niavo** — [LinkedIn](URL) · [Email](mailto:altonniavo@gmail.com)
