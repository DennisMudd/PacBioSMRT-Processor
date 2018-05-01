# PacBioSMRT-Processor

## Subfunctions: <br />
1. find_retention.R <br />
2. populateMatrix.R <br />
3. search_pat.R <br />

## Main Functions:<br />
1. intron_filter_by_GRanges.R <br />
- intron_filter_by_GRanges(gr_input)
- @param **gr_input** - GRangesList
- @return {"prefiltered_new_exon", "remain", "filtered", "prefiltered_binary", "remain_binary", "filtered_binary",
       "prefiltered_new_exon_count", "remain_count", "filtered_count","isoform_count", "all_exon"}

2. intron_filter_by_gff.R <br />
- intron_filter_by_gff(gff, custom_gene = NULL)
- @param **gff** - gtf or gff file, **custom_gene** - a vector of strings, containing the gene names
- @return {"stat_prefiltered", "stat_remain", "stat_filtered",
       "analyzed_gene", "percent_filtered",
       "percent_prefiltered", "percent_remain"}
