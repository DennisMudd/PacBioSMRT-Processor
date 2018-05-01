# PacBioSMRT-Processor

## Subfunctions: <br />
1. find_retention.R <br />
2. populateMatrix.R <br />
3. search_pat.R <br />

## Main Functions:<br />
1. intron_filter_by_GRanges.R <br />
- Filter the transcripts with partial exons in comparison to the Gencode Reference Genome. Then filter the ones with intron retention through a self-learning process within the remaining group. Output the binary forms of all three groups, their names, count, and all exons as in GRange.
- intron_filter_by_GRanges(gr_input)
- @param **gr_input** - GRangesList
- @return {"prefiltered_new_exon", "remain", "filtered", "prefiltered_binary", "remain_binary", "filtered_binary",
       "prefiltered_new_exon_count", "remain_count", "filtered_count","isoform_count", "all_exon"}
- @example intron_filter_by_GRanges(import.gff(my.gtf.file))

2. intron_filter_by_gff.R <br />
- Systemetically go through the process of intron_filter_by_GRanges of all selected genes in a gtf file. It produces three types of gtf files for each gene in the same directory. (_remain2.0.gtf, _potential_new_exon.gtf, _filtered2.0.gtf)
- intron_filter_by_gff(gff, custom_gene = NULL) It also creates a subdirectory called **binary_results**. All the binary forms are stored as csv files in this subdirectory.
- @param **gff** - gtf or gff file, **custom_gene** - a vector of strings, containing the gene names
- @return {"stat_prefiltered", "stat_remain", "stat_filtered",
       "analyzed_gene", "percent_filtered",
       "percent_prefiltered", "percent_remain"}
