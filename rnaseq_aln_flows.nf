include { trimReads; fastqc; multiqc; indexGenomeHisat2; mapToGenomeHisat2  } from './rnaseq_aln_tasks.nf'

workflow raw_qc_flow {
        take:
          read_files
        main:
          fastqc(read_files)
          multiqc("raw", fastqc.out.collect())
}

workflow rnaseq_aln_flow {
        take:
          genome
          read_files
        main:
          trimReads(read_files)
          fastqc( trimReads.out)
          multiqc("trim", fastqc.out.collect())
          indexGenomeHisat2(genome)
          mapToGenomeHisat2(indexGenomeHisat2.out, trimReads.out)
}
