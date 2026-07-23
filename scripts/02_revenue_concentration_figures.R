###############################################################
# FULL R CODE — GRAPHS, TABLES, DIAGRAMS FOR LATEX
# Thesis: Export of soccer talent to European Big Five leagues
# Theme: Revenue concentration & global talent market
# Reference: Szymanski (2003)
###############################################################

# ── 0. PACKAGES ───────────────────────────────────────────────
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  tidyverse,
  scales,
  ggrepel,
  knitr,
  kableExtra,
  patchwork,
  ggridges,
  RColorBrewer,
  Cairo        # for high-resolution PDF export
)

# ── LOAD DATA ─────────────────────────────────────────────────
rev <- read_csv("~/Documents/TD économétrie M1/big5_revenues_panel.csv/big5_revenues_panel.csv.Rproj")

# Colour palette (Big Five + Rest)
pal_leagues <- c(
  "Premier League" = "#3C1874",
  "La Liga"        = "#D62728",
  "Bundesliga"     = "#FF7F0E",
  "Serie A"        = "#1F77B4",
  "Ligue 1"        = "#2CA02C",
  "Rest of Europe" = "#7F7F7F"
)

big5_list <- c("Premier League","La Liga","Bundesliga","Serie A","Ligue 1")

###############################################################
# FIGURE 1 — Revenue levels by league (line chart)           #
###############################################################

p1 <- rev %>%
  ggplot(aes(x = year_start, y = revenue_bn_eur,
             colour = league, linetype = if_else(league == "Rest of Europe",
                                                 "dashed","solid"))) +
  geom_line(size = 1.1) +
  geom_point(size = 1.8) +
  scale_colour_manual(values = pal_leagues) +
  scale_linetype_identity() +
  scale_x_continuous(breaks = seq(2004, 2023, by = 2)) +
  scale_y_continuous(labels = label_number(suffix = " bn€", accuracy = 0.1)) +
  labs(
    title   = "Revenue levels of the Big Five European football leagues (2004--2024)",
    x       = "Season (start year)",
    y       = "Revenues (billion euros)",
    colour  = "League",
    caption = "Sources: Deloitte Annual Review of Football Finance (2005--2024); UEFA ECFIL."
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position  = "bottom",
    plot.caption     = element_text(size = 7, colour = "grey50"),
    panel.grid.minor = element_blank()
  )

ggsave("fig1_revenue_levels.pdf",  p1, width = 7.5, height = 4.5, device = cairo_pdf)
ggsave("fig1_revenue_levels.png",  p1, width = 7.5, height = 4.5, dpi = 300)


###############################################################
# FIGURE 2 — Big Five share of European revenues (line)      #
###############################################################

big5_share_ts <- rev %>%
  group_by(year_start) %>%
  summarise(
    big5_rev    = sum(revenue_bn_eur[league %in% big5_list]),
    total_rev   = sum(revenue_bn_eur),
    big5_share  = big5_rev / total_rev,
    .groups = "drop"
  )

p2 <- big5_share_ts %>%
  ggplot(aes(x = year_start, y = big5_share)) +
  geom_ribbon(aes(ymin = 0.5, ymax = big5_share), fill = "#08306B", alpha = 0.15) +
  geom_line(colour = "#08306B", size = 1.3) +
  geom_point(colour = "#08306B", size = 2) +
  geom_hline(yintercept = 0.5, linetype = "dashed", colour = "red", size = 0.7) +
  annotate("text", x = 2004.5, y = 0.51, label = "50% threshold",
           colour = "red", size = 3) +
  scale_y_continuous(
    labels = percent_format(accuracy = 1),
    limits = c(0.40, 0.80)
  ) +
  scale_x_continuous(breaks = seq(2004, 2023, by = 2)) +
  labs(
    title   = "Big Five share of total European football revenues (2004--2024)",
    x       = "Season (start year)",
    y       = "Share of European revenues (%)",
    caption = "Sources: Deloitte ARFF; UEFA ECFIL."
  ) +
  theme_minimal(base_size = 11) +
  theme(panel.grid.minor = element_blank(),
        plot.caption = element_text(size = 7, colour = "grey50"))

ggsave("fig2_big5_share.pdf", p2, width = 7.5, height = 4.5, device = cairo_pdf)
ggsave("fig2_big5_share.png", p2, width = 7.5, height = 4.5, dpi = 300)


###############################################################
# FIGURE 3 — Stacked area chart: composition of revenues     #
###############################################################

p3 <- rev %>%
  filter(league %in% big5_list) %>%
  ggplot(aes(x = year_start, y = revenue_bn_eur, fill = league)) +
  geom_area(alpha = 0.85, colour = "white", size = 0.3) +
  scale_fill_manual(values = pal_leagues) +
  scale_x_continuous(breaks = seq(2004, 2023, by = 2)) +
  scale_y_continuous(labels = label_number(suffix = " bn€", accuracy = 1)) +
  labs(
    title   = "Big Five cumulative revenues — stacked composition (2004--2024)",
    x       = "Season (start year)",
    y       = "Cumulative revenues (billion euros)",
    fill    = "League",
    caption = "Sources: Deloitte Annual Review of Football Finance (2005--2024)."
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position  = "bottom",
    panel.grid.minor = element_blank(),
    plot.caption     = element_text(size = 7, colour = "grey50")
  )

ggsave("fig3_stacked_area.pdf", p3, width = 7.5, height = 4.5, device = cairo_pdf)
ggsave("fig3_stacked_area.png", p3, width = 7.5, height = 4.5, dpi = 300)


###############################################################
# FIGURE 4 — HHI Revenue Concentration Index over time       #
###############################################################

hhi_ts <- rev %>%
  group_by(year_start) %>%
  mutate(s_i = revenue_bn_eur / sum(revenue_bn_eur)) %>%
  summarise(HHI = sum(s_i^2), .groups = "drop")

p4 <- hhi_ts %>%
  ggplot(aes(x = year_start, y = HHI)) +
  geom_line(colour = "#990000", size = 1.2) +
  geom_point(colour = "#990000", size = 2) +
  geom_smooth(method = "loess", se = TRUE, colour = "#CC4444",
              fill = "#FFAAAA", alpha = 0.3, size = 0.8) +
  scale_x_continuous(breaks = seq(2004, 2023, by = 2)) +
  scale_y_continuous(limits = c(0.1, 0.35)) +
  labs(
    Voici le code R **complet et prêt à coller dans RStudio**, qui génère tous les graphiques, tableaux et équations exportables directement en LaTeX pour ton mémoire.
    
    ---
      
      ```r
    ###############################################################
    # FULL R CODE — GRAPHS, TABLES & LaTeX OUTPUT
    # Thesis: Soccer talent export & Big Five revenue concentration
    # Based on: Szymanski (2003), Deloitte ARFF, UEFA ECFIL
    ###############################################################
    
    # ── 0. PACKAGES ───────────────────────────────────────────────
    if (!require("pacman")) install.packages("pacman")
    pacman::p_load(
      tidyverse,
      scales,
      knitr,
      kableExtra,
      ggrepel,
      patchwork,   # combine multiple ggplots
      RColorBrewer
    )
    
    # ── 1. LOAD DATA ───────────────────────────────────────────────
    # (Run the CSV builder script first, then:)
    df <- read_csv("big5_revenues_panel.csv")
    
    # Color palette — consistent across all figures
    league_colors <- c(
      "Premier League" = "#3F1F69",
      "La Liga"        = "#D4002A",
      "Bundesliga"     = "#E8001C",
      "Serie A"        = "#007AC2",
      "Ligue 1"        = "#1D4E89",
      "Rest of Europe" = "#AAAAAA"
    )
    
    big5_leagues <- c("Premier League","La Liga","Bundesliga","Serie A","Ligue 1")
    
    
    ###############################################################
    # FIGURE 1 — Revenue levels by league (line chart)
    ###############################################################
    
    fig1 <- df %>%
      filter(league != "Rest of Europe") %>%
      ggplot(aes(x = year_start, y = revenue_bn_eur,
                 colour = league, group = league)) +
      geom_line(size = 1.1) +
      geom_point(size = 1.8) +
      # Annotate COVID drop
      annotate("rect",
               xmin = 2019, xmax = 2021,
               ymin = -Inf, ymax = Inf,
               alpha = 0.08, fill = "grey30") +
      annotate("text",
               x = 2020, y = 6.8,
               label = "COVID-19", size = 3, colour = "grey40") +
      scale_colour_manual(values = league_colors) +
      scale_x_continuous(
        breaks = seq(2004, 2023, by = 2),
        labels = function(x) paste0(x, "/", str_sub(x + 1, 3, 4))
      ) +
      scale_y_continuous(
        labels = label_number(suffix = " bn€", accuracy = 0.1)
      ) +
      labs(
        title    = "Revenue levels of the Big Five European football leagues",
        subtitle = "Aggregate club revenues per season, 2004/05–2023/24",
        x        = "Season",
        y        = "Total revenues (billion euros)",
        colour   = "League",
        caption  = "Sources: Deloitte Annual Review of Football Finance (2005–2024)"
      ) +
      theme_minimal(base_size = 12) +
      theme(
        plot.title    = element_text(face = "bold", size = 13),
        plot.subtitle = element_text(colour = "grey40"),
        legend.position = "bottom",
        axis.text.x   = element_text(angle = 45, hjust = 1),
        panel.grid.minor = element_blank()
      )
    
    ggsave("fig1_revenue_levels.pdf", fig1, width = 8, height = 5)
    ggsave("fig1_revenue_levels.png", fig1, width = 8, height = 5, dpi = 300)
    cat("Figure 1 saved.\n")
    
    
    ###############################################################
    # FIGURE 2 — Big Five aggregate share of European revenues
    ###############################################################
    
    share_df <- df %>%
      group_by(year_start) %>%
      summarise(
        big5_rev    = sum(revenue_bn_eur[league %in% big5_leagues]),
        total_rev   = sum(revenue_bn_eur),
        big5_share  = big5_rev / total_rev,
        .groups = "drop"
      )
    
    fig2 <- share_df %>%
      ggplot(aes(x = year_start, y = big5_share)) +
      geom_area(fill = "#3F1F69", alpha = 0.15) +
      geom_line(colour = "#3F1F69", size = 1.3) +
      geom_point(colour = "#3F1F69", size = 2) +
      # Reference line at 54% (Deloitte 2024 benchmark)
      geom_hline(yintercept = 0.54,
                 linetype = "dashed", colour = "#D4002A", size = 0.8) +
      annotate("text",
               x = 2005, y = 0.555,
               label = "54% benchmark (Deloitte, 2024)",
               size = 3, colour = "#D4002A") +
      scale_y_continuous(
        labels = percent_format(accuracy = 1),
        limits = c(0.55, 0.80)
      ) +
      scale_x_continuous(
        breaks = seq(2004, 2023, by = 2),
        labels = function(x) paste0(x, "/", str_sub(x + 1, 3, 4))
      ) +
      labs(
        title    = "Big Five share of total European football revenues",
        subtitle = "Proportion of European top-division revenues captured by the Big Five",
        x        = "Season",
        y        = "Big Five revenue share",
        caption  = "Sources: Deloitte ARFF (2005–2024); UEFA ECFIL (2024)"
      ) +
      theme_minimal(base_size = 12) +
      theme(
        plot.title    = element_text(face = "bold", size = 13),
        plot.subtitle = element_text(colour = "grey40"),
        axis.text.x   = element_text(angle = 45, hjust = 1),
        panel.grid.minor = element_blank()
      )
    
    ggsave("fig2_big5_share.pdf", fig2, width = 8, height = 5)
    ggsave("fig2_big5_share.png", fig2, width = 8, height = 5, dpi = 300)
    cat("Figure 2 saved.\n")
    
    
    ###############################################################
    # FIGURE 3 — Stacked bar: Big Five vs Rest of Europe
    ###############################################################
    
    bar_df <- df %>%
      mutate(
        group = if_else(league %in% big5_leagues, "Big Five", "Rest of Europe")
      ) %>%
      group_by(year_start, group) %>%
      summarise(revenue = sum(revenue_bn_eur), .groups = "drop")
    
    fig3 <- bar_df %>%
      ggplot(aes(x = factor(year_start), y = revenue, fill = group)) +
      geom_col(position = "stack", width = 0.8) +
      scale_fill_manual(
        values = c("Big Five" = "#3F1F69", "Rest of Europe" = "#BBBBBB")
      ) +
      scale_x_discrete(
        labels = function(x) paste0(x, "/", str_sub(as.integer(x) + 1, 3, 4))
      ) +
      scale_y_continuous(
        labels = label_number(suffix = " bn€", accuracy = 1)
      ) +
      labs(
        title    = "European football revenues: Big Five vs Rest of Europe",
        subtitle = "Total revenues by group, 2004/05–2023/24",
        x        = "Season",
        y        = "Total revenues (billion euros)",
        fill     = "",
        caption  = "Sources: Deloitte ARFF; UEFA ECFIL"
      ) +
      theme_minimal(base_size = 12) +
      theme(
        plot.title    = element_text(face = "bold", size = 13),
        plot.subtitle = element_text(colour = "grey40"),
        legend.position = "bottom",
        axis.text.x   = element_text(angle = 45, hjust = 1),
        panel.grid.minor = element_blank()
      )
    
    ggsave("fig3_stacked_bar.pdf", fig3, width = 9, height = 5)
    ggsave("fig3_stacked_bar.png", fig3, width = 9, height = 5, dpi = 300)
    cat("Figure 3 saved.\n")
    
    
    ###############################################################
    # FIGURE 4 — Herfindahl-Hirschman Index (HHI)
    ###############################################################
    
    hhi_df <- df %>%
      group_by(year_start) %>%
      mutate(s_i = revenue_bn_eur / sum(revenue_bn_eur)) %>%
      summarise(HHI = sum(s_i^2), .groups = "drop")
    
    fig4 <- hhi_df %>%
      ggplot(aes(x = year_start, y = HHI)) +
      geom_line(colour = "#D4002A", size = 1.2) +
      geom_point(colour = "#D4002A", size = 2) +
      # Concentration thresholds (US DOJ / EC standards)
      geom_hline(yintercept = 0.25,
                 linetype = "dotted", colour = "grey40") +
      annotate("text",
               x = 2005, y = 0.255,
               label = "High concentration threshold (HHI = 0.25)",
               size = 3, colour = "grey40") +
      scale_x_continuous(
        breaks = seq(2004, 2023, by = 2),
        labels = function(x) paste0(x, "/", str_sub(x + 1, 3, 4))
      ) +
      scale_y_continuous(limits = c(0.15, 0.35)) +
      labs(
        title    = "Revenue concentration across European football leagues",
        subtitle = "Herfindahl–Hirschman Index (HHI), 2004/05–2023/24",
        x        = "Season",
        y        = "HHI",
        caption  = "Note: HHI = \\u03a3 s\u1d62\u00b2 where s\u1d62 = league revenue share.\nSources: Deloitte ARFF; UEFA ECFIL"
      ) +
      theme_minimal(base_size = 12) +
      theme(
        plot.title    = element_text(face = "bold", size = 13),
        plot.subtitle = element_text(colour = "grey40"),
        axis.text.x   = element_text(angle = 45, hjust = 1),
        panel.grid.minor = element_blank()
      )
    
    ggsave("fig4_hhi.pdf", fig4, width = 8, height = 5)
    ggsave("fig4_hhi.png", fig4, width = 8, height = 5, dpi = 300)
    cat("Figure 4 saved.\n")
    
    
    ###############################################################
    # FIGURE 5 — Market share treemap (latest season 2023/24)
    ###############################################################
    
    pacman::p_load(treemapify)
    
    tree_df <- df %>%
      filter(year_start == 2023) %>%
      mutate(
        label_pct = paste0(league, "\n",
                           round(market_share * 100, 1), "%")
      )
    
    fig5 <- tree_df %>%
      ggplot(aes(area = revenue_bn_eur,
                 fill = league,
                 label = label_pct)) +
      geom_treemap() +
      geom_treemap_text(
        colour = "white", place = "centre",
        size = 11, fontface = "bold"
      ) +
      scale_fill_manual(values = c(league_colors,
                                   "Rest of Europe" = "#AAAAAA")) +
      labs(
        title   = "European football revenue market shares, 2023/24",
        caption = "Sources: Deloitte ARFF 2024; UEFA ECFIL 2024"
      ) +
      theme_minimal(base_size = 12) +
      theme(
        plot.title    = element_text(face = "bold", size = 13),
        legend.position = "none"
      )
    
    ggsave("fig5_treemap.pdf", fig5, width = 8, height = 5)
    ggsave("fig5_treemap.png", fig5, width = 8, height = 5, dpi = 300)
    cat("Figure 5 saved.\n")
    
    
    ###############################################################
    # FIGURE 6 — Year-on-year revenue growth by league
    ###############################################################
    
    fig6 <- df %>%
      filter(league %in% big5_leagues, !is.na(yoy_growth)) %>%
      ggplot(aes(x = year_start, y = yoy_growth,
                 colour = league, group = league)) +
      geom_line(size = 0.9, alpha = 0.8) +
      geom_hline(yintercept = 0, linetype = "dashed",
                 colour = "grey40", size = 0.7) +
      scale_colour_manual(values = league_colors) +
      scale_y_continuous(
        labels = percent_format(accuracy = 1)
      ) +
      scale_x_continuous(
        breaks = seq(2005, 2023, by = 2),
        labels = function(x) paste0(x, "/", str_sub(x + 1, 3, 4))
      ) +
      labs(
        title    = "Year-on-year revenue growth rate — Big Five leagues",
        subtitle = "Annual percentage change in total league revenues",
        x        = "Season",
        y        = "Revenue growth (YoY %)",
        colour   = "League",
        caption  = "Sources: Deloitte ARFF (2005–2024)"
      ) +
      theme_minimal(base_size = 12) +
      theme(
        plot.title    = element_text(face = "bold", size = 13),
        plot.subtitle = element_text(colour = "grey40"),
        legend.position = "bottom",
        axis.text.x   = element_text(angle = 45, hjust = 1),
        panel.grid.minor = element_blank()
      )
    
    ggsave("fig6_yoy_growth.pdf", fig6, width = 8, height = 5)
    ggsave("fig6_yoy_growth.png", fig6, width = 8, height = 5, dpi = 300)
    cat("Figure 6 saved.\n")
    
    
    ###############################################################
    # TABLE 1 — Revenue summary by league (LaTeX)
    ###############################################################
    
    table1 <- df %>%
      filter(league %in% big5_leagues) %>%
      group_by(league) %>%
      summarise(
        `Rev. 2004/05 (bn€)` = round(first(revenue_bn_eur), 2),
        `Rev. 2023/24 (bn€)` = round(last(revenue_bn_eur),  2),
        `Avg. market share`  = percent(mean(market_share), accuracy = 0.1),
        `Total growth`       = percent(
          (last(revenue_bn_eur) - first(
            
            
            