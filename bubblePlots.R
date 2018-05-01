bubblePlots <- function(csv, plot_gene_name){
  require(dplyr)
  require(reshape2)
  require(ggplot2)
  dir.create("bubbleplot", showWarnings = F)
  res <- read.csv(csv, header = T, stringsAsFactors = F)

  gene <- res %>% dplyr::filter(gene_name %in% c(plot_gene_name))
  
  gene.melt <- melt(gene, id=c("gene_name", "group"))
  
  
  gene.melt$label <- paste0(gene.melt$gene_name, "_", sprintf("%2d", gene.melt$group))
  
  targetSamples <- grep("TAR$", unique(gene.melt$variable), value = T)
  gene.melt.filt <- gene.melt %>% dplyr::filter(variable %in% targetSamples)
  
  sorted_labels <- unique(gene.melt.filt$label[order(gene.melt.filt$label, decreasing = T)])
  
  gene.melt.filt$label <- factor(gene.melt.filt$label,
                                 levels = sorted_labels)
  
  ggplot(gene.melt.filt, 
         aes(x=variable, y=label, color = value, 
                             size = value)) +
    geom_point(shape = 16) +
    geom_count() +
    #scale_color_gradient(low="blue", high="red") +
    #scale_fill_gradient(low="blue", high="red") +
    #scale_color_gradient2(midpoint=0, low="blue", mid="yellow", high="red", space ="Lab" ) +
    scale_fill_distiller(palette = "RdYlBu") +
    scale_color_distiller(palette = "RdYlBu") +
    #geom_text(size=2, hjust=0, vjust=1) +
    theme_bw() +
    theme(axis.text.x = element_text(size=10, angle = 30, hjust = 1),
          axis.text.y = element_text(size=12),
          axis.title.x = element_text(face="plain", colour="black", size=12),
          axis.title.y = element_text(face="plain", colour="black", size=12),
          panel.grid.minor = element_blank(),
          panel.grid.major = element_blank(),
          plot.background = element_blank(),
          legend.position="right") +
    labs(title="", x = "Samples", y="Isoform groups" )
    graph_height <- 0.7*nrow(gene)
    if(graph_height < 7){graph_height <- 6.5}
    ggsave(file.path(getwd(), "bubbleplot", paste(plot_gene_name, "_bubbleplot.png", sep = "")), height = graph_height, dpi = 400)
}

