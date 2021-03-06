#' Filter the transcripts with partial exons.
#'
#' @param gr_input a GenomicRanges Object
#' @return a list of accessible varaiables.
#' @examples
#' file_name <- system.file("extdata", "IL27RA.gtf", package = "exonCLR")
#' intron_filter_by_GRanges(import.gff(file_name))
#' @export
#' @details This function returns a list containing the following elements.    
#' \describe{
#' General Procedure: Filter the transcripts with partial exons in comparison to the Gencode Reference Genome.
#' Then filter the ones with intron retention through a self-learning process within the remaining group. 
#' Output the binary forms of all three groups, their names, count, and all exons as in GRange.
#'     \item{\strong{Output List}}{}
#'     \item{prefiltered_new_exon}{A vector of isoform name(s) which contain partial exon(s)}
#'     \item{remain}{A vector of isoform name(s) that remain in the end of the process}
#'     \item{filtered}{A vector of isoform name(s) which contain intron retention(s)}
#'     \item{prefiltered_binary}{A matrix of binary form(s) of prefiltered transcript(s) with partial exon(s)}
#'     \item{remain_binary}{A matrix of binary form(s) of remaining transcript(s)}
#'     \item{filtered_binary}{A matrix of binary form(s) of filtered transcripts with intron retention(s)}
#'     \item{prefiltered_count}{Number of prefiltered transcript(s) with partial exon(s)}
#'     \item{remain_count}{Number of remaining transcript(s)}
#'     \item{filtered_count}{Number of filtered transcript(s) with intron retention(s)}
#'     \item{isoform_count}{Total number of transcript(s)}
#'     \item{all_exon}{GenomicRanges Object processed after the input, with only the exon reads}
#'     }
#' @import AnnotationHub
#' @importFrom rtracklayer export

intron_filter_by_GRanges_ref_only <- function(gr_input){
  ##Prepare gtf file from hg38
  if(!file.exists("Gencode_proteinCoding.gtf")){
    #  library(AnnotationHub)
    ah = AnnotationHub()
    ah = subset(ah,species=="Homo sapiens")
    qhs <- query(ah, c("Ensembl", "gene", "annotation", "grch38"))
    gtf <- qhs[["AH51014"]] #Homo_sapiens.GRCh38.85.gtf
    export(gtf[gtf$transcript_biotype %in% "protein_coding", ], "Gencode_proteinCoding.gtf")
  }
  
  
  gene_name = unique(gr_input[!is.na(gr_input$gffcompare_gene_name)]$gffcompare_gene_name)
  export_gtf_name <- paste("gencode_", gene_name, ".gtf", sep = "")
  if(!file.exists(export_gtf_name)){
    gencode_gtf <- import.gff("Gencode_proteinCoding.gtf")
    gr = gr_input
    gencode_gtf_gene <- gencode_gtf[gencode_gtf$gene_name %in% gr$gffcompare_gene_name]
    if(unique(gr$gffcompare_gene_name[!is.na(gr$gffcompare_gene_name)]) > 1){
      gencode_gtf_gene <- gencode_gtf[gencode_gtf$gene_name %in% unique(gr$gffcompare_gene_name[!is.na(gr$gffcompare_gene_name)])[1]]
    }
    gencode_exon = gencode_gtf_gene[gencode_gtf_gene$type == "exon"]
    export(gencode_exon, export_gtf_name)
  }
  
  gencode_exon = import.gff(export_gtf_name)
  
  gencode_list_input = split(gencode_exon, gencode_exon$transcript_id)
  gencode_base = reduce(gencode_exon)
  gr = gr_input
  gr_exon = gr[gr$type=="exon"]
  gr_list_input = split(gr_exon, gr_exon$transcript_id)
  isoform_names <- names(gr_list_input)
  isoform_count = length(unique(gr_exon$transcript_id))
  
  chr = unique(seqnames(gr_list_input[[1]]))
  chr_num = as.numeric(strsplit(toString(chr), split = "chr")[[1]][2])
  if(is.na(chr_num)){chr_num = 23}
  if(length(GenomicRanges::coverage(gr_exon)) > 1){
    cov = base::as.vector(GenomicRanges::coverage(gr_exon)[[chr_num]])
  }
  if(length(GenomicRanges::coverage(gr_exon)) == 1){
    cov = base::as.vector(GenomicRanges::coverage(gr_exon)[[1]])
  }
  
  extract = which(cov>0)
  extract_high = which(cov>isoform_count*0.1)
  
  gr_extract = reduce(GRanges(chr, range=IRanges(start=extract, end=extract)))
  gr_extract_high = reduce(GRanges(seqnames=chr, range=IRanges(extract_high, extract_high)))
  
  gr_base = reduce(gr_exon)
  gr_subject = gr_extract_high
  gr_intron = GenomicRanges::setdiff(GRanges(seqname=chr, ranges = IRanges(start(gr_base), end(gr_base))), gr_subject)
  gr_exons = gr_subject; gr_exons$type = "exon"
  gr_introns = gr_intron;
  if (length(gr_introns) > 0) { gr_introns$type="intron" }
  gr_tract = c(gr_exons, gr_introns)
  gr_tract = gr_tract[order(start(gr_tract))]
  
  
  new1 <- GRanges(seqnames = chr, range = IRanges(start(gencode_exon), end(gencode_exon)))
  new2 <- GRanges(seqnames = chr, range = IRanges(start(gr_exon), end(gr_exon)))
  recombined_gencode_gr <- c(new1, new2)
  recombined_gencode_gr <- recombined_gencode_gr[order(start(recombined_gencode_gr))]
  recombined_gr_base <- reduce(recombined_gencode_gr)
  
  reduce_intron_start = NULL
  reduce_intron_end = NULL
  if (length(recombined_gr_base) > 1){
    for (i in 1:(length(recombined_gr_base)-1)){
      reduce_intron_start <- c(reduce_intron_start, end(recombined_gr_base)[i]+1)
      reduce_intron_end <- c(reduce_intron_end, start(recombined_gr_base)[i+1]-1)
    }
    reduce_intron_start <- reduce_intron_start[!is.na(reduce_intron_start)]
    reduce_intron_end <- reduce_intron_end[!is.na(reduce_intron_end)]
    reduce_intron = GRanges(seqname=chr, ranges = IRanges(reduce_intron_start, reduce_intron_end))
    gr_combined = c(recombined_gr_base, reduce_intron)
    gr_combined = gr_combined[order(start(gr_combined))]
    piece = c(disjoin(recombined_gencode_gr), reduce_intron)
  }
  
  if(length(recombined_gr_base) == 1){
    gr_combined = recombined_gr_base
    piece = disjoin(recombined_gencode_gr)
  }
  
  
  piece = piece[order(start(piece))]
  piece_width = width(piece)
  piece_start = start(piece)
  piece_end = end(piece)
  
  
  
  stick = NULL
  for(i in 1:length(gr_combined)){stick=c(stick, seq(start(gr_combined[i]), end(gr_combined[i])))} #changed
  stick = GRanges(seqnames=chr, ranges =IRanges(start=stick, end=stick))
  mat = matrix(unlist(lapply(gr_list_input, populateMatrix, stick)), ncol=length(stick), byrow=T)
  mat = t(mat)
  
  mat_gencode = matrix(FALSE, nrow = nrow(mat), ncol = length(gencode_list_input))
  for (j in (1:length(gencode_list_input))){
    temp <- unlist(gencode_list_input[j])
    for (i in (1:length(temp))){
      gencode_start <- start(temp)[i] - start(gr_base)[1] + 1
      gencode_end <- gencode_start + width(temp)[i] - 1
      if(gencode_start < 0 & gencode_end > 0){gencode_start = 1}
      if (gencode_end > 0){mat_gencode[, j][gencode_start:gencode_end] = T}
    }
  }
  
  out_disjoin <- matrix(NA, ncol = ncol(mat), nrow = length(piece))
  gencode_out_disjoin <- matrix(NA, ncol= ncol(mat_gencode), length(piece))
  
  
  # Based on Disjoin
  for (i in 1:(ncol(out_disjoin))){
    a <- mat[, i]
    for(j in 1:(nrow(out_disjoin))){
      tract_e <- sum(width(piece)[1:j])
      tract_s <- tract_e - width(piece)[j] + 1
      compare_region <- a[tract_s:tract_e]
      val <- sum(compare_region, na.rm = TRUE)/(width(piece)[j])
      out_disjoin[j, i] <- val
    }
  }
  # Separation Line
  
  
  # Calculating for gencode standard set
  for(i in (1:ncol(gencode_out_disjoin))){
    for(j in 1:(nrow(gencode_out_disjoin))){
      tract_e <- sum(width(piece)[1:j])
      tract_s <- tract_e - width(piece)[j] + 1
      compare_region <- mat_gencode[, i][tract_s:tract_e]
      val <- sum(compare_region, na.rm = TRUE)/(width(piece)[j])
      if(val != 0 & val != 1){val <- round(val)}
      gencode_out_disjoin[j, i] <- val
    }
  }
  # Recognize head and tail
  for(i in (1:ncol(gencode_out_disjoin))){
    temp <- gencode_out_disjoin[, i]
    first_one <- which(temp==1)[1]
    last_one <- which(temp==1)[sum(temp)]
    if(!is.na(first_one) & first_one > 1){gencode_out_disjoin[, i][1:(first_one-1)] = NA}
    if((length(last_one) != 0)){
      if(last_one < nrow(gencode_out_disjoin)){gencode_out_disjoin[, i][(last_one+1):nrow(gencode_out_disjoin)] = NA}
    }
  }
  # Separation Line
  
  test <- logical(ncol(out_disjoin)) == F
  
  for (i in (1:ncol(out_disjoin))){
    gencode_test <- NULL
    if(!is.na(ncol(gencode_out_disjoin))){
      for(j in (1:ncol(gencode_out_disjoin))){
        temp_test <- find_retention(cbind(gencode_out_disjoin[, j], out_disjoin[,i]), head_tail_test = T)
        gencode_test <- c(gencode_test, temp_test[-1])
      }
    }
    
    if(is.na(ncol(gencode_out_disjoin))){
      gencode_test <- find_retention(cbind(gencode_out_disjoin, out_disjoin[,i]), head_tail_test = T)[1]
    }
    
    if(identical(gencode_test[1:length(gencode_test)],rep(FALSE, length(gencode_test)))){test[i] = F}
    #if(identical(gencode_test[1:(length(gencode_test)-1)],rep(FALSE, length(gencode_test)-1))){pre_test[i] = F} # & gencode_test[length(gencode_test)] == T
  }

  if(sum(test)>0){export(gr[gr$transcript_id %in% isoform_names[test]], paste(gene_name,"_remain3.0.gtf", sep=""))}
  if((length(test) - sum(test))>0){export(gr[gr$transcript_id %in% isoform_names[test==F]], paste(gene_name,"_filtered3.0.gtf", sep=""))}
  
  filtered_binary = NULL
  if((length(test) - sum(test))>0){filtered_binary = out_disjoin[, !test]}
  list("remain" = isoform_names[test], "filtered" = isoform_names[test==F],
       "remain_binary" = out_disjoin[, test], "filtered_binary" = filtered_binary,
       "remain_count" = sum(test), "filtered_count" = (length(test) - sum(test)),
       "isoform_count" = isoform_count, "all_exon" = gr_exon)
}