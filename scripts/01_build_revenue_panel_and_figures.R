###############################################################
# STEP 0 — SET WORKING DIRECTORY (adapte le chemin si besoin)
###############################################################

setwd("/Users/niavo/Documents/TD économétrie M1")

# Vérifie que tu es au bon endroit
getwd()   # doit afficher : /Users/niavo/Documents/TD économétrie M1

###############################################################
# STEP 1 — PACKAGES
###############################################################

if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  tidyverse, scales, knitr, kableExtra,
  patchwork, treemapify, writexl
)

###############################################################
# STEP 2 — CRÉER LE DATAFRAME DIRECTEMENT DANS R
#           (pas de fichier à télécharger !)
###############################################################

big5_raw <- tribble(
  ~season,    ~league,           ~revenue_bn_eur,
  # PREMIER LEAGUE
  "2004/05","Premier League",1.98,"2005/06","Premier League",2.12,
  "2006/07","Premier League",2.40,"2007/08","Premier League",2.63,
  "2008/09","Premier League",2.58,"2009/10","Premier League",2.53,
  "2010/11","Premier League",2.75,"2011/12","Premier League",2.90,
  "2012/13","Premier League",3.26,"2013/14","Premier League",3.46,
  "2014/15","Premier League",3.90,"2015/16","Premier League",4.87,
  "2016/17","Premier League",5.30,"2017/18","Premier League",5.40,
  "2018/19","Premier League",5.90,"2019/20","Premier League",4.50,
  "2020/21","Premier League",4.80,"2021/22","Premier League",6.10,
  "2022/23","Premier League",6.70,"2023/24","Premier League",7.10,
  # LA LIGA
  "2004/05","La Liga",1.43,"2005/06","La Liga",1.52,
  "2006/07","La Liga",1.64,"2007/08","La Liga",1.75,
  "2008/09","La Liga",1.67,"2009/10","La Liga",1.65,
  "2010/11","La Liga",1.72,"2011/12","La Liga",1.77,
  "2012/13","La Liga",1.85,"2013/14","La Liga",1.97,
  "2014/15","La Liga",2.10,"2015/16","La Liga",2.22,
  "2016/17","La Liga",2.60,"2017/18","La Liga",2.89,
  "2018/19","La Liga",3.40,"2019/20","La Liga",2.60,
  "2020/21","La Liga",2.40,"2021/22","La Liga",3.00,
  "2022/23","La Liga",3.50,"2023/24","La Liga",3.80,
  # BUNDESLIGA
  "2004/05","Bundesliga",1.15,"2005/06","Bundesliga",1.22,
  "2006/07","Bundesliga",1.38,"2007/08","Bundesliga",1.46,
  "2008/09","Bundesliga",1.50,"2009/10","Bundesliga",1.56,
  "2010/11","Bundesliga",1.70,"2011/12","Bundesliga",1.84,
  "2012/13","Bundesliga",2.02,"2013/14","Bundesliga",2.18,
  "2014/15","Bundesliga",2.37,"2015/16","Bundesliga",2.62,
  "2016/17","Bundesliga",2.79,"2017/18","Bundesliga",3.17,
  "2018/19","Bundesliga",3.81,"2019/20","Bundesliga",3.20,
  "2020/21","Bundesliga",3.00,"2021/22","Bundesliga",3.80,
  "2022/23","Bundesliga",4.00,"2023/24","Bundesliga",4.20,
  # SERIE A
  "2004/05","Serie A",1.19,"2005/06","Serie A",1.23,
  "2006/07","Serie A",1.31,"2007/08","Serie A",1.45,
  "2008/09","Serie A",1.48,"2009/10","Serie A",1.52,
  "2010/11","Serie A",1.56,"2011/12","Serie A",1.63,
  "2012/13","Serie A",1.68,"2013/14","Serie A",1.74,
  "2014/15","Serie A",1.82,"2015/16","Serie A",1.90,
  "2016/17","Serie A",2.00,"2017/18","Serie A",2.24,
  "2018/19","Serie A",2.48,"2019/20","Serie A",1.84,
  "2020/21","Serie A",1.72,"2021/22","Serie A",2.40,
  "2022/23","Serie A",2.80,"2023/24","Serie A",3.10,
  # LIGUE 1
  "2004/05","Ligue 1",0.76,"2005/06","Ligue 1",0.81,
  "2006/07","Ligue 1",0.86,"2007/08","Ligue 1",0.93,
  "2008/09","Ligue 1",0.96,"2009/10","Ligue 1",1.01,
  "2010/11","Ligue 1",1.08,"2011/12","Ligue 1",1.14,
  "2012/13","Ligue 1",1.18,"2013/14","Ligue 1",1.23,
  "2014/15","Ligue 1",1.31,"2015/16","Ligue 1",1.40,
  "2016/17","Ligue 1",1.49,"2017/18","Ligue 1",1.63,
  "2018/19","Ligue 1",1.82,"2019/20","Ligue 1",1.30,
  "2020/21","Ligue 1",1.10,"2021/22","Ligue 1",1.60,
  "2022/23","Ligue 1",1.90,"2023/24","Ligue 1",2.00,
  # REST OF EUROPE
  "2004/05","Rest of Europe",2.49,"2005/06","Rest of Europe",2.60,
  "2006/07","Rest of Europe",2.75,"2007/08","Rest of Europe",3.00,
  "2008/09","Rest of Europe",3.10,"2009/10","Rest of Europe",3.20,
  "2010/11","Rest of Europe",3.40,"2011/12","Rest of Europe",3.60,
  "2012/13","Rest of Europe",3.80,"2013/14","Rest of Europe",4.00,
  "2014/15","Rest of Europe",4.30,"2015/16","Rest of Europe",4.60,
  "2016/17","Rest of Europe",5.00,"2017/18","Rest of Europe",5.40,
  "2018/19","Rest of Europe",5.80,"2019/20","Rest of Europe",4.56,
  "2020/21","Rest of Europe",4.78,"2021/22","Rest of Europe",6.10,
  "2022/23","Rest of Europe",7.10,"2023/24","Rest of Europe",8.00
)

###############################################################
# STEP 3 — NETTOYAGE ET VARIABLES DÉRIVÉES
###############################################################

big5_leagues <- c("Premier League","La Liga","Bundesliga","Serie A","Ligue 1")

df <- big5_raw %>%
  mutate(
    year_start = as.integer(str_sub(season, 1, 4)),
    is_big5    = if_else(league %in% big5_leagues, 1L, 0L)
  ) %>%
  arrange(league, year_start) %>%
  group_by(year_start) %>%
  mutate(
    total_europe = sum(revenue_bn_eur),
    market_share = revenue_bn_eur / total_europe,
    big5_total   = sum(revenue_bn_eur[is_big5 == 1]),
    big5_share   = big5_total / total_europe
  ) %>%
  ungroup() %>%
  group_by(league) %>%
  mutate(
    yoy_growth = (revenue_bn_eur - lag(revenue_bn_eur)) / lag(revenue_bn_eur)
  ) %>%
  ungroup()

###############################################################
# STEP 4 — EXPORT CSV + XLSX (maintenant créés dans ton dossier)
###############################################################

write_csv(df, "big5_revenues_panel.csv")
write_xlsx(df, "big5_revenues_panel.xlsx")
cat("✔  CSV et XLSX créés dans :", getwd(), "\n")

###############################################################
# STEP 5 — PALETTE COULEURS
###############################################################

league_colors <- c(
  "Premier League" = "#3F1F69",
  "La Liga"        = "#D4002A",
  "Bundesliga"     = "#E8001C",
  "Serie A"        = "#007AC2",
  "Ligue 1"        = "#1D4E89",
  "Rest of Europe" = "#AAAAAA"
)

###############################################################
# FIGURE 1 — Niveaux de revenus par ligue
###############################################################

fig1 <- df %>%
  filter(league != "Rest of Europe") %>%
  ggplot(aes(x = year_start, y = revenue_bn_eur,
             colour = league, group = league)) +
  geom_line(size = 1.1) +
  geom_point(size = 1.8) +
  annotate("rect", xmin=2019, xmax=2021,
           ymin=-Inf, ymax=Inf, alpha=0.08, fill="grey30") +
  annotate("text", x=2020, y=6.8,
           label="COVID-19", size=3, colour="grey40") +
  scale_colour_manual(values = league_colors) +
  scale_x_continuous(
    breaks = seq(2004, 2023, by = 2),
    labels = function(x) paste0(x,"/",str_sub(x+1,3,4))
  ) +
  scale_y_continuous(
    labels = label_number(suffix=" bn€", accuracy=0.1)
  ) +
  labs(
    title    = "Revenue levels of the Big Five European football leagues",
    subtitle = "Aggregate club revenues per season, 2004/05–2023/24",
    x = "Season", y = "Total revenues (billion euros)",
    colour = "League",
    caption = "Sources: Deloitte Annual Review of Football Finance (2005–2024)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face="bold", size=13),
    plot.subtitle = element_text(colour="grey40"),
    legend.position = "bottom",
    axis.text.x = element_text(angle=45, hjust=1),
    panel.grid.minor = element_blank()
  )

ggsave("fig1_revenue_levels.pdf", fig1, width=8, height=5)
ggsave("fig1_revenue_levels.png", fig1, width=8, height=5, dpi=300)
cat("✔ Figure 1 saved\n")

###############################################################
# FIGURE 2 — Part des Big Five dans les revenus européens
###############################################################

share_df <- df %>%
  group_by(year_start) %>%
  summarise(
    big5_rev  = sum(revenue_bn_eur[league %in% big5_leagues]),
    total_rev = sum(revenue_bn_eur),
    big5_share = big5_rev / total_rev,
    .groups = "drop"
  )

fig2 <- share_df %>%
  ggplot(aes(x = year_start, y = big5_share)) +
  geom_area(fill="#3F1F69", alpha=0.15) +
  geom_line(colour="#3F1F69", size=1.3) +
  geom_point(colour="#3F1F69", size=2) +
  geom_hline(yintercept=0.54,
             linetype="dashed", colour="#D4002A", size=0.8) +
  annotate("text", x=2005, y=0.555,
           label="54% — Deloitte benchmark (2024)",
           size=3, colour="#D4002A") +
  scale_y_continuous(
    labels = percent_format(accuracy=1),
    limits = c(0.50, 0.82)
  ) +
  scale_x_continuous(
    breaks = seq(2004, 2023, by=2),
    labels = function(x) paste0(x,"/",str_sub(x+1,3,4))
  ) +
  labs(
    title    = "Big Five share of total European football revenues",
    subtitle = "Proportion of European top-division revenues, 2004/05–2023/24",
    x = "Season", y = "Big Five revenue share",
    caption = "Sources: Deloitte ARFF; UEFA ECFIL (2024)"
  ) +
  theme_minimal(base_size=12) +
  theme(
    plot.title = element_text(face="bold", size=13),
    plot.subtitle = element_text(colour="grey40"),
    axis.text.x = element_text(angle=45, hjust=1),
    panel.grid.minor = element_blank()
  )

ggsave("fig2_big5_share.pdf", fig2, width=8, height=5)
ggsave("fig2_big5_share.png", fig2, width=8, height=5, dpi=300)
cat("✔ Figure 2 saved\n")

###############################################################
# FIGURE 3 — Stacked bar Big Five vs Reste Europe
###############################################################

bar_df <- df %>%
  mutate(group = if_else(league %in% big5_leagues,
                         "Big Five","Rest of Europe")) %>%
  group_by(year_start, group) %>%
  summarise(revenue = sum(revenue_bn_eur), .groups="drop")

fig3 <- bar_df %>%
  ggplot(aes(x=factor(year_start), y=revenue, fill=group)) +
  geom_col(position="stack", width=0.8) +
  scale_fill_manual(
    values = c("Big Five"="#3F1F69","Rest of Europe"="#BBBBBB")
  ) +
  scale_x_discrete(
    labels
    
    