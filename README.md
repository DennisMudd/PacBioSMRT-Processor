# PacBioSMRT-Processor

## Sub/Preliminary Functions: <br />
1. find_retention.R <br />
2. populateMatrix.R <br />
3. search_pat.R <br />

## Main Functions:<br />
### 1. intron_filter_by_GRanges.R <br />
- Filter the transcripts with partial exons in comparison to the Gencode Reference Genome. Then filter the ones with intron retention through a self-learning process within the remaining group. Output the binary forms of all three groups, their names, count, and all exons as in GRange.
- intron_filter_by_GRanges(gr_input)
- @param: **gr_input** - GRangesList
- @return: {"prefiltered_new_exon", "remain", "filtered", "prefiltered_binary", "remain_binary", "filtered_binary",
       "prefiltered_new_exon_count", "remain_count", "filtered_count","isoform_count", "all_exon"}
- @example: intron_filter_by_GRanges(import.gff(my.gtf.file))

### 2. intron_filter_by_gff.R <br />
- Systemetically go through the process of intron_filter_by_GRanges of all selected genes in a gtf file. It produces three types of gtf files for each gene in the same directory. (_remain2.0.gtf, _potential_new_exon.gtf, _filtered2.0.gtf)
- intron_filter_by_gff(gff, custom_gene = NULL) It also creates a subdirectory called **/binary_results**. All the binary forms are stored as csv files in this subdirectory.
- @param: **_gff_** - gtf or gff file; **_custom_gene_** - a vector of strings, containing the gene names
- @return: {"stat_prefiltered", "stat_remain", "stat_filtered",
       "analyzed_gene", "percent_filtered",
       "percent_prefiltered", "percent_remain"}
- @example: intron_filter_by_gff("HumanGenome.gtf", custom_gene = c("CD5", "IL27RA"))

### 3. isoform_group.R <br />
- Cluster the isoforms based on their binary forms. "index" is a vector of integers that represent the group that an isoform belongs to. "exon_binary" represents the simplified binary forms after the clustering. "group" represents a list containing isoform names in each subgroup. 
- isoform_group(input_binary_mat, isoform_names)
- @param: **_input_binary_mat_** - a matrix of binary forms of transcripts, typically as output from intron_filter_by_GRanges or read from csv files in the /binary_results/ directory; **_isoform_names_** - Names of isoforms respective to the input matrix, typically as output from intron_filter_by_GRanges, or contained in the csv files
- @return: {"index", "exon_binary", "group"}
- @example: 
  - temp <- intron_filter_by_GRanges(import.gff(my.gtf.file))
  - isoform_group(temp$remain_binary, temp$remain)
