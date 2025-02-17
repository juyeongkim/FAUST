.plotSampleHistograms <- function(sampleName,
                                  analysisMap,
                                  startingCellPop,
                                  projectPath=".")
{
    
    resList <- readRDS(paste0(projectPath,"/faustData/gateData/",
                              startingCellPop,"_resList.rds"))
    selC <- readRDS(paste0(projectPath,"/faustData/gateData/",
                           startingCellPop,"_selectedChannels.rds"))

    exprsMat <- readRDS(paste0(projectPath,"/faustData/sampleData/",sampleName,"/exprsMat.rds"))
    aLevel <- analysisMap[which(analysisMap[,"sampleName"]==sampleName),"analysisLevel"]
    plotList <- list()
    for (channel in selC) {
        channelData <- as.data.frame(exprsMat[,channel,drop=FALSE])
        colnames(channelData) <- "x"
        gateData <- resList[[channel]][[aLevel]]
        channelQs <- as.numeric(quantile(channelData$x,probs=c(0.01,0.99)))
        histLookupLow <- which(channelData$x >= channelQs[1])
        histLookupHigh <- which(channelData$x <= channelQs[2])
        histLookup <- intersect(histLookupLow,histLookupHigh)
        histData <- channelData[histLookup,"x",drop=FALSE]
        p <- .getHistogram(histData,channel,gateData)
        plotList <- append(plotList,list(p))
    }
    pOut <- cowplot::plot_grid(plotlist=plotList)
    cowplot::save_plot(paste0(projectPath,"/faustData/plotData/histograms/",sampleName,".pdf"),
              pOut,
              base_height = (5*ceiling(sqrt(length(selC)))),
              base_width = (5*ceiling(sqrt(length(selC)))))
    return()
}

.getHistogram <- function(histData,channelName,gates) {
    fdBreaks <- pretty(range(histData[,"x"]),
                     n = grDevices::nclass.FD(histData[,"x"]), min.n = 1)
    binWidth <- fdBreaks[2]-fdBreaks[1]
    p <- ggplot(histData,aes(x=x)) +
        geom_histogram(binwidth=binWidth) +
        theme_bw()+
        geom_vline(xintercept=gates,color="red",linetype="dashed")+
        ggtitle(channelName)
    return(p)
}

