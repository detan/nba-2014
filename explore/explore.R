# players
choiceList <- list(
  "shot clock" = "SHOT_CLOCK",
  "shot distance" = "SHOT_DIST",
  "dribbles before shot" = "DRIBBLES",
  "touch time" = "TOUCH_TIME",
  "number of shots" = "SHOTS",
  "distance to defender" = "DEF_DISTANCE",
  "proportion 3 pointers" = "PROP_3",
  "proportion shots made" = "PROP_MADE",
  "proportion 3pt. made" = "PROP_3_MADE"
)

output$teamScatter <- renderGgd3({
  team_summary$selected_team <- ifelse(team_summary$tm %in% input$teamRecord, 'selected', 'not selected')
  team_summary <- team_summary[order(team_summary$selected_team), ]
  ggd3(team_summary, layers =list(l1=list(geom=list(type='point',
                                                    mergeOn=list(c('tm')),
                                                    omit=c('selected_team')),
                                             stat=list(
                                               y='identity',
                                               x='identity',
                                               fill='identity',
                                               color='identity',
                                               size='identity'
                                             ))),
        aes = list(x=input$teamx, y = input$teamy,
                   fill=input$teamColor,
                   size=input$teamSize,
                   color=list('selected_team'),
                   additional = list(c('tm'))),
        settings = list(facet = list(titleSize = c(0,0)),
                        margins = list(left=50, bottom=50),
                        width = 600,
                        height = 600,
                        colorScale = list(scale=list(range=c('none', 'yellow'))),
                        xScale=list(axis=list(ticks=4)),
                        yScale=list(axis=list(ticks=4)),
                        fillScale=list(scale=list(
                          domain=range(team_summary[,input$teamColor]))),
                        sizeScale=list(scale=list(
                          domain=range(team_summary[,input$teamSize])))
                        ))
})



output$teamRecord <- renderPlot({
  d <- subset(nba_wl_games, tm %in% input$teamRecord)
  d <- d[order(d$tm, d$date) ,c('date', 'tm', 'final_margin', 'WIN')]
  wins <- plyr::ddply(d, c('tm'), summarize,
                      wins = sum(WIN),
                      losses = length(WIN) - sum(WIN)
                      )
  wlabels <- apply(wins, 1, function(r) {
    paste0(r[1], ": ", r[2], ' wins, ', r[3], ' losses')
  })
  d$tm <- factor(d$tm, labels = wlabels)
  d %>% ggplot(aes(x=date, y=final_margin, fill=factor(WIN)), stroke='none') +
    scale_fill_manual(values = c('red', 'blue'))+
    geom_bar(stat='identity', position='dodge') + facet_wrap(~tm, ncol=1) +
    theme_bw() + xlab('') + ylab('') +
    theme(legend.position='none',
        strip.text.x = element_text(size=14, hjust=0.1),
        strip.background=element_blank(),
        axis.ticks = element_line(size=0),
        panel.border = element_blank())

})
teams <- sort(unique(team_summary$tm))
output$teamRecord_buttons <- renderUI({
  column(width = 12,
         selectInput('teamRecord', '', choices = teams,
                     selected=sample(teams, 3), multiple = TRUE)
         )

})
output$teamScatter_buttons <- renderUI({
  column(width = 12,
         column(width = 3,
                selectInput('teamx', 'x',
                            choices = choiceList,
                            selected = 'SHOT_DIST', width = "100%")
         ),
         column(width = 3,
                selectInput('teamy', 'y',
                            choices = choiceList,
                            selected = 'DEF_DISTANCE', width = "100%")
         ),
         column(width = 3,
                selectInput('teamColor', 'fill',
                            choices = choiceList,
                            selected = 'PROP_3', width = "100%")
         ),
         column(width = 3,
                selectInput('teamSize', 'size',
                            choices = choiceList,
                            selected = 'DRIBBLES', width = "100%")
         ),
         class = 'pad-top'
  )
})

