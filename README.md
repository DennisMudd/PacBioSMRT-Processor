# PacBioSMRT-Processor

## Sub/Preliminary Functions: <br />
1. find_retention.R <br />
2. populateMatrix.R <br />
3. search_pat.R <br />

## Main Functions:<br />
### 1. intron_filter_by_GRanges.R <br />
- Filter the transcripts with partial exons in comparison to the Gencode Reference Genome. Then filter the ones with intron retention through a self-learning process within the remaining group. Output the binary forms of all three groups, their names, count, and all exons as in GRange.
- intron_filter_by_GRanges(gr_input)
- @param: **_gr_input_** - GRangesList
- @return: {"prefiltered_new_exon", "remain", "filtered", "prefiltered_binary", "remain_binary", "filtered_binary",
       "prefiltered_new_exon_count", "remain_count", "filtered_count","isoform_count", "all_exon"}
- @example: intron_filter_by_GRanges(import.gff(my.gtf.file))

### 2. intron_filter_by_gff.R <br />
- Systemetically go through the process of intron_filter_by_GRanges of all selected genes in a gtf file. It produces three types of gtf files for each gene in the same directory. (_remain2.0.gtf, _potential_new_exon.gtf, _filtered2.0.gtf) It also creates a subdirectory called **/binary_results**. All the binary forms are stored as csv files in this subdirectory.
- intron_filter_by_gff(gff, custom_gene = NULL)
- @param: 
  - **_gff_** - gtf or gff file
  - **_custom_gene_** - a vector of strings, containing the gene names
- @return: {"stat_prefiltered", "stat_remain", "stat_filtered",
       "analyzed_gene", "percent_filtered",
       "percent_prefiltered", "percent_remain"}
- @example: intron_filter_by_gff("HumanGenome.gtf", custom_gene = c("CD5", "IL27RA"))

### 3. isoform_group.R <br />
- Cluster the isoforms based on their binary forms. "index" is a vector of integers that represent the group that an isoform belongs to. "exon_binary" represents the simplified binary forms after the clustering. "group" represents a list containing isoform names in each subgroup. 
- isoform_group(input_binary_mat, isoform_names)
- @param: 
  - **_input_binary_mat_** - a matrix of binary forms of transcripts, typically as output from intron_filter_by_GRanges or read from csv files in the /binary_results/ directory
  - **_isoform_names_** - Names of isoforms respective to the input matrix, typically as output from intron_filter_by_GRanges, or contained in the csv files
- @return: {"index", "exon_binary", "group"}
- @example: 
  - temp <- intron_filter_by_GRanges(import.gff(my.gtf.file))
  - isoform_group(temp$remain_binary, temp$remain)
  
### 4. generate_exon_only_binary.R <br />
- Apply isoform_group.R to all csv files(binary forms) in the targeted directory. Simplified the binary forms according to the isoform_group.R and save them as csv files in a new subdirectory.
- generate_exon_only_binary(binary_folder_path, result_folder_name, custom_gene = NULL, file_pattern = "_binary.csv")
- @param: 
  - **_binary_folder_path_** - the path to the folder containing the csv files of binary forms
  - **_result_folder_name_** - User desired output directory name
  - **_custom_gene_** - a vector of strings, containing the gene names
  - **_file_pattern_** - the pre/post-fix of the files name; no need to change if go through the intron_filter_by_gff function
- @return: None
- @example: generate_exon_only_binary(binary_folder_path = "~/binary_results/",
                          result_folder_name = "your.output.dir",
                          custom_gene = NULL)
 
### 5. simplify_GRanges.R (secondary in the process) <br />
- Serves as a embedded function in the next function simplify_gff.R
- simplify_GRanges(input_gr_exon, group_list, input_gene_name, output_folder = "simplified_gtf")
- @param: 
  - **_input_gr_exon_** - GRangeList object
  - **_group_list_** - a list of index for grouping
  - **_input_gene_name_** - gene name
  - **_output_folder_** - output directory name
- @return: A GRangeList object
- @example: simplify_GRanges(GRangeList, isoform_group.group, "CD5")

### 6. simplify_gff.R <br />
- Simplify a gtf/gff file based on the process from previous functions, which filter transcripts with partial exons and intron retentions, and cluster the rest into simplified binary. The simplified gtf file for each gene is stored in the subdirectory **/processed_gtf_files/**. The final output will be a gtf file with an additional prefix of "simplified_" in the working directory.
- simplify_gff(gff, custom_gene = NULL, output_folder = "simplified_gtf")
- @param: 
  - **_gff_** - path of gtf/gff file
  - **_custom_gene_** - a vector of strings, containing the gene names
  - **_output_folder_** - output directory name
- @return: {"output", "computed_genes"}
- @example: simplify_gff(your.gtf.file)

### 7. heatmap_coverage.R <br />
- Generate a heatmap based on the "_exon_only_binary.csv" files that contain simplified binary forms of transcripts that remained. The heatmap is saved as a png file in the created directory **/output_heatmaps/**
- heatmap_coverage(gr_input, output_file_path = getwd(), isoform_group_index)
- @param: 
  - **_gr_input_** - GRangeList object
  - **_output_file_path_** - output directory; if not otherwise specified, the output heatmap folder will be in the local directory.
  - **_isoform_group_index_** - a vector of group number for the input isoforms
- @return: a heatmap of the analyzed gene
- @example: heatmap_coverage(your.gr.input, getwd(), c(1,2,3,1,2))

### 8. generate_heatmap.R (Not a function, side use for generate heatmaps for all files in the directory)<br />
- Simply change to the directory with all the "_exon_only_binary.csv" files and run the script.

### 9. heatmap_coverage.R <br />
- Generate a heatmap based on the "_exon_only_binary.csv" files that contain simplified binary forms of transcripts that remained. The heatmap is saved as a png file in the created directory **/output_heatmaps/**
- heatmap_coverage(gr_input, output_file_path = getwd(), isoform_group_index)
- @param: 
  - **_gr_input_** - GRangeList object
  - **_output_file_path_** - output directory; if not otherwise specified, the output heatmap folder will be in the local directory.
  - **_isoform_group_index_** - a vector of group number for the input isoforms
- @return: a heatmap of the analyzed gene
- @example: heatmap_coverage(your.gr.input, getwd(), c(1,2,3,1,2))
