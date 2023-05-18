params.genome = '/lustre/scratch126/tol/teams/jaron/projects/springtails_haploid_selection/0_data/qeAllFusc8.1_refrence/genome.fasta.gz'
params.reads = '/lustre/scratch126/tol/teams/jaron/projects/springtails_haploid_selection/0_data/rnaseq/AF_F_6/*R{1,2}*.fastq.gz'
params.outdir = 'results'

log.info """\
         R N A S E Q   N F   P I P E L I N E    
         ===================================
         genome       : ${params.genome}
         reads        : ${params.reads}
         outdir       : ${params.outdir}
         """
         .stripIndent()

include { raw_qc_flow; rnaseq_aln_flow } from './rnaseq_aln_flows.nf'

workflow {
        read_pairs_ch = Channel .fromFilePairs( params.reads, checkIfExists:true )
        raw_qc_flow( read_pairs_ch)
        rnaseq_aln_flow(params.genome, read_pairs_ch)
}

/*
* Add CPU information to config
* Add CPU information to tasks
* How to link these?
* How to use with containers?
*/
